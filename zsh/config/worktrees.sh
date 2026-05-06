################################################################################
# Git Worktrees
#
# These functions assume a bare repo setup:
#
#   ProjectName/
#     .bare/          <- bare clone (git internals)
#     branch-name/    <- worktrees (folder name usually matches branch name,
#                        but may differ after wt:rename — wt:remove accepts either)
#
# Initial setup:
#   wt:init <remote-url> [folder-name]
#   wt:add <branch>
#
# Most commands must be run from the project root (containing .bare/).
# wt:list, wt:info, and wt:update can be run from any worktree folder.
################################################################################

# ── Private helpers ─────────────────────────────────────────────────

function _wt:require_bare() {
  if [[ ! -d ".bare" ]]; then
    echo "Error: no .bare found in $(pwd). Navigate to project root first."
    return 1
  fi
}

# Find the closest .bare directory by walking up from $PWD
function _wt:bare() {
  local dir=$PWD
  while [[ "$dir" != "/" ]]; do
    [[ -d "$dir/.bare" ]] && { echo "$dir/.bare"; return 0; }
    dir="${dir:h}"
  done
  return 1
}

# Collect all ports assigned across worktrees for a given ENV key (one per line)
function _wt:used_ports() {
  local key=$1
  local bare
  bare=$(_wt:bare) || return

  local port
  while IFS= read -r env_file; do
    port=$(grep -m1 "^${key}=" "$env_file" 2>/dev/null | cut -d= -f2 | tr -d '[:space:]')
    [[ -n "$port" ]] && echo "$port"
  done < <(find "${bare:h}" -name .env -not -path "*/.bare/*" 2>/dev/null)
}

# Read default port from .env.example (falls back to hardcoded default)
function _wt:default_port() {
  local key=$1 fallback=$2
  local bare
  bare=$(_wt:bare) || { echo "$fallback"; return; }

  local val
  val=$(grep -m1 "^${key}=" "${bare:h}/.env.example" 2>/dev/null | cut -d= -f2 | tr -d '[:space:]')
  echo "${val:-$fallback}"
}

# Find first available APP_PORT starting from defaults where app/db/redis all avoid conflicts
function _wt:next_app_port() {
  local bare
  bare=$(_wt:bare) || { echo "3000"; return; }

  local base_app=$(_wt:default_port APP_PORT 3000)
  local base_db=$(_wt:default_port DB_PORT 3306)
  local base_redis=$(_wt:default_port REDIS_PORT 6379)

  # Build set of ALL assigned ports (app, db, redis)
  local -A taken
  local port
  for key in APP_PORT DB_PORT REDIS_PORT; do
    while IFS= read -r port; do
      taken[$port]=1
    done < <(_wt:used_ports "$key")
  done

  # Start from default, find first offset where all three ports are free
  local offset=0
  while true; do
    local app_port=$(( base_app + offset ))
    local db_port=$(( base_db + offset ))
    local redis_port=$(( base_redis + offset ))
    if [[ -z "${taken[$app_port]}" && -z "${taken[$db_port]}" && -z "${taken[$redis_port]}" ]]; then
      echo "$app_port"
      return
    fi
    (( offset++ ))
  done
}

# Write port assignments to .env, preserving any existing non-port variables
function _wt:write_ports() {
  local existing_app_port
  existing_app_port=$(grep -m1 '^APP_PORT=' .env 2>/dev/null | cut -d= -f2)

  local base_app=$(_wt:default_port APP_PORT 3000)
  local base_db=$(_wt:default_port DB_PORT 3306)
  local base_redis=$(_wt:default_port REDIS_PORT 6379)

  local app_port=${existing_app_port:-$(_wt:next_app_port)}
  local offset=$(( app_port - base_app ))
  local db_port=$(( base_db + offset ))
  local redis_port=$(( base_redis + offset ))

  local other_vars=""
  if [[ -f .env ]]; then
    other_vars=$(grep -v '^APP_PORT=\|^DB_PORT=\|^REDIS_PORT=' .env)
  fi

  {
    printf 'APP_PORT=%s\nDB_PORT=%s\nREDIS_PORT=%s\n' \
      "$app_port" "$db_port" "$redis_port"
    [[ -n "$other_vars" ]] && printf '%s\n' "$other_vars"
  } > .env

  echo "Ports — app: $app_port, db: $db_port, redis: $redis_port"
}

# Stop containers, remove worktree directory, prune refs, delete branch.
# force=true → git branch -D (drops unmerged); force=false → git branch -d.
function _wt:destroy() {
  local wt_path=$1 branch=$2 force=$3

  if [[ -d "$wt_path" ]]; then
    docker compose -f "$wt_path/docker-compose.yml" --env-file "$wt_path/.env" down &>/dev/null || true
    git -C "$wt_path" submodule deinit --all -f 2>/dev/null
    rm -rf "$wt_path"
  fi

  git -C .bare worktree prune

  if [[ "$force" == true ]]; then
    git -C .bare branch -D "$branch" 2>/dev/null
  else
    git -C .bare branch -d "$branch" 2>/dev/null || \
      echo "Warning: branch '$branch' has unmerged changes. Re-run with F to force delete."
  fi
}

# ── Public commands ─────────────────────────────────────────────────

# Create a new bare repo setup
#
# wt:init <remote-url> [folder-name]
function wt:init() {
  if [[ -z "$1" ]]; then
    echo "Usage: wt:init <remote-url> [folder-name]"
    return 1
  fi
  local folder="${2:-$(basename "$1" .git)}"
  mkdir "$folder"
  git clone --bare "$1" "$folder/.bare"
  cd "$folder" && git -C .bare config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
  git -C .bare fetch
}

# List all worktrees
#
# wt:list
function wt:list() {
  local bare
  bare=$(_wt:bare) || { echo "Error: no .bare found in or above $(pwd)."; return 1; }

  git -C "$bare" worktree list --porcelain | while IFS= read -r line; do
    [[ "$line" == "branch "* ]] && echo "${line#branch refs/heads/}"
  done
}

# Show detailed worktree info in a table
#
# wt:info
function wt:info() {
  local bare
  bare=$(_wt:bare) || { echo "Error: no .bare found in or above $(pwd)."; return 1; }

  local -a wt_branches wt_hashes wt_dates wt_ahead wt_dirty wt_docker wt_ports
  local wt_branch wt_hash wt_date_str wt_counts wt_behind wt_a wt_ahead_str
  local wt_path_str wt_port_str p_app p_db p_redis
  local max_br=6 max_date=16 max_ahead=9 max_port=14

  # First pass: collect data and find max branch length
  git -C "$bare" worktree list --porcelain | while IFS= read -r line; do
    if [[ "$line" == "worktree "* ]]; then
      wt_path_str="${line#worktree }"
    elif [[ "$line" == "HEAD "* ]]; then
      wt_hash="${line#HEAD }"
      wt_hash="${wt_hash[1,7]}"
    elif [[ "$line" == "branch "* ]]; then
      wt_branch="${line#branch refs/heads/}"
    elif [[ "$line" == "bare" ]]; then
      wt_branch="" wt_hash="" wt_path_str=""
    elif [[ -z "$line" && -n "$wt_branch" ]]; then
      wt_branches+=("$wt_branch")
      wt_hashes+=("$wt_hash")

      wt_date_str=$(git -C "$bare" log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M' "$wt_branch" 2>/dev/null || echo "unknown")
      wt_dates+=("$wt_date_str")
      (( ${#wt_date_str} > max_date )) && max_date=${#wt_date_str}

      wt_counts=$(git -C "$bare" rev-list --left-right --count "master...$wt_branch" 2>/dev/null)
      wt_behind=${wt_counts%%	*} wt_a=${wt_counts##*	}
      wt_ahead_str="↑${wt_a:-0} ↓${wt_behind:-0}"
      wt_ahead+=("$wt_ahead_str")
      (( ${#wt_ahead_str} > max_ahead )) && max_ahead=${#wt_ahead_str}

      # Dirty status
      if [[ -d "$wt_path_str" ]]; then
        if [[ -n $(git -C "$wt_path_str" status --porcelain 2>/dev/null) ]]; then
          wt_dirty+=("✗")
        else
          wt_dirty+=("✓")
        fi
      else
        wt_dirty+=("?")
      fi

      # Docker status
      if [[ -f "$wt_path_str/docker-compose.yml" && -f "$wt_path_str/.env" ]]; then
        if docker compose -f "$wt_path_str/docker-compose.yml" --env-file "$wt_path_str/.env" ps --status running 2>/dev/null | grep -q .; then
          wt_docker+=("●")
        else
          wt_docker+=("○")
        fi
      else
        wt_docker+=("─")
      fi

      # Ports from .env
      if [[ -f "$wt_path_str/.env" ]]; then
        p_app=$(grep -m1 '^APP_PORT=' "$wt_path_str/.env" 2>/dev/null | cut -d= -f2 | tr -d '[:space:]')
        p_db=$(grep -m1 '^DB_PORT=' "$wt_path_str/.env" 2>/dev/null | cut -d= -f2 | tr -d '[:space:]')
        p_redis=$(grep -m1 '^REDIS_PORT=' "$wt_path_str/.env" 2>/dev/null | cut -d= -f2 | tr -d '[:space:]')
        if [[ -n "$p_app" || -n "$p_db" || -n "$p_redis" ]]; then
          wt_port_str="${p_app:-─}:${p_db:-─}:${p_redis:-─}"
        else
          wt_port_str="─"
        fi
      else
        wt_port_str="─"
      fi
      wt_ports+=("$wt_port_str")
      (( ${#wt_port_str} > max_port )) && max_port=${#wt_port_str}

      (( ${#wt_branch} > max_br )) && max_br=${#wt_branch}
      wt_branch="" wt_hash="" wt_path_str=""
    fi
  done

  local hash_len=7
  local br_col=$(( max_br + 2 )) ha_col=$(( hash_len + 2 ))
  local da_col=$(( max_date + 2 )) ah_col=$(( max_ahead + 2 ))
  local po_col=$(( max_port + 2 ))

  # Border parts
  local br_line ha_line da_line ah_line st_line po_line
  printf -v br_line '%*s' "$br_col" '' && br_line="${br_line// /─}"
  printf -v ha_line '%*s' "$ha_col" '' && ha_line="${ha_line// /─}"
  printf -v da_line '%*s' "$da_col" '' && da_line="${da_line// /─}"
  printf -v ah_line '%*s' "$ah_col" '' && ah_line="${ah_line// /─}"
  printf -v st_line '%*s' 5 '' && st_line="${st_line// /─}"
  printf -v po_line '%*s' "$po_col" '' && po_line="${po_line// /─}"

  # Table
  printf '┌%s┬%s┬%s┬%s┬%s┬%s┬%s┐\n' "$br_line" "$st_line" "$st_line" "$po_line" "$ha_line" "$da_line" "$ah_line"
  printf '│ %-*s │ %s │ %s │ %-*s │ %-*s │ %-*s │ %-*s │\n' \
    "$max_br" "Branch" "Git" "Doc" "$max_port" "App:Db:Redis" "$hash_len" "Hash" "$max_date" "Last Committed" "$max_ahead" "vs master"
  printf '├%s┼%s┼%s┼%s┼%s┼%s┼%s┤\n' "$br_line" "$st_line" "$st_line" "$po_line" "$ha_line" "$da_line" "$ah_line"
  for (( i=1; i<=${#wt_branches}; i++ )); do
    printf '│ %-*s │  %s  │  %s  │ %-*s │ %-*s │ %-*s │ %-*s │\n' \
      "$max_br" "${wt_branches[$i]}" \
      "${wt_dirty[$i]}" \
      "${wt_docker[$i]}" \
      "$max_port" "${wt_ports[$i]}" \
      "$hash_len" "${wt_hashes[$i]}" \
      "$max_date" "${wt_dates[$i]}" \
      "$max_ahead" "${wt_ahead[$i]}"
  done
  printf '└%s┴%s┴%s┴%s┴%s┴%s┴%s┘\n' "$br_line" "$st_line" "$st_line" "$po_line" "$ha_line" "$da_line" "$ah_line"
}

# Add an existing remote branch as a worktree
#
# wt:add <branch-name>
function wt:add() {
  _wt:require_bare || return 1
  if [[ -z "$1" ]]; then
    echo "Usage: wt:add <branch-name>"
    return 1
  fi

  git -C .bare worktree prune
  git -C .bare worktree add "../$1" "$1" || return 1
  cd "$1" && git submodule update --init --recursive && _wt:write_ports
}

# Create a new worktree with a new branch
#
# wt:create <branch-name> [base=master]
function wt:create() {
  _wt:require_bare || return 1
  if [[ -z "$1" ]]; then
    echo "Usage: wt:create <branch-name> [base-branch]"
    return 1
  fi

  local base="${2:-master}"
  git -C .bare worktree prune
  git -C .bare worktree add "../$1" -b "$1" "$base" || return 1
  cd "$1" && git submodule update --init --recursive && _wt:write_ports
}

# Rename a worktree directory (and optionally its branch)
#
# wt:rename <old-name> <new-name>
function wt:rename() {
  _wt:require_bare || return 1
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: wt:rename <old-name> <new-name>"
    return 1
  fi

  local old="$1" new="$2"
  local root=$PWD

  if [[ ! -d "$old" ]]; then
    echo "Error: worktree directory '$old' not found."
    return 1
  fi

  if [[ -d "$new" ]]; then
    echo "Error: directory '$new' already exists."
    return 1
  fi

  # Resolve the worktree's gitdir link to find its .bare/worktrees/<id> entry
  local gitdir_link
  gitdir_link=$(cat "$old/.git" 2>/dev/null) || {
    echo "Error: '$old/.git' is not a worktree link file."
    return 1
  }
  # Extract path from "gitdir: /path/to/..."
  local wt_git_dir="${gitdir_link#gitdir: }"

  # Make absolute if relative
  [[ "$wt_git_dir" != /* ]] && wt_git_dir="$root/$old/$wt_git_dir"

  if [[ ! -d "$wt_git_dir" ]]; then
    echo "Error: worktree git dir '$wt_git_dir' not found."
    return 1
  fi

  # Create parent directory for new location if needed (e.g. test/wt-rename-test)
  mkdir -p "${new:h}" 2>/dev/null

  # Move the worktree directory
  mv "$old" "$new" || return 1

  # Update .bare/worktrees/<id>/gitdir to point to new location
  echo "$root/$new" > "$wt_git_dir/gitdir"

  # Update the .git link inside the worktree (path may have changed relative to .bare)
  echo "gitdir: $wt_git_dir" > "$new/.git"

  git -C .bare branch -m "$old" "$new" 2>/dev/null && {
    echo "Renamed branch '$old' → '$new'"
  } || {
    echo "Note: kept branch name '$old' (may differ from directory name or have unmerged changes)."
  }

  echo "Worktree moved: $old → $new"
}

# Remove a worktree
#
# wt:remove <branch-or-path> [--force]
function wt:remove() {
  _wt:require_bare || return 1
  if [[ -z "$1" ]]; then
    echo "Usage: wt:remove <branch-or-path> [--force]"
    return 1
  fi

  local arg="$1"
  local force=false
  [[ "$2" == "--force" ]] && force=true

  local root=$PWD

  # Resolve arg → (wt_path, branch). Accepts branch name OR directory path
  # (relative to root or absolute). Names can diverge after a partial wt:rename.
  local wt_path="" branch=""
  local cur_path="" cur_branch="" cur_rel=""
  while IFS= read -r line; do
    if [[ "$line" == "worktree "* ]]; then
      cur_path="${line#worktree }"
    elif [[ "$line" == "branch refs/heads/"* ]]; then
      cur_branch="${line#branch refs/heads/}"
      cur_rel="${cur_path#$root/}"
      if [[ "$cur_branch" == "$arg" || "$cur_rel" == "$arg" || "$cur_path" == "$arg" ]]; then
        wt_path="$cur_path"
        branch="$cur_branch"
        break
      fi
    fi
  done < <(git -C .bare worktree list --porcelain)

  # No matching worktree — may be a stale entry, or a branch with no worktree
  if [[ -z "$wt_path" ]]; then
    git -C .bare worktree prune
    if git -C .bare show-ref --verify --quiet "refs/heads/$arg"; then
      git -C .bare branch -d "$arg" 2>/dev/null && {
        echo "Removed orphan branch '$arg'."
      } || {
        echo "Warning: branch '$arg' has unmerged changes. Use 'git -C .bare branch -D $arg' to force delete."
      }
    else
      echo "No matching worktree or branch for '$arg'. Pruned any stale entries."
    fi
    return 0
  fi

  local display="${wt_path#$root/}"

  if [[ "$force" != true ]]; then
    if [[ "$display" == "$branch" ]]; then
      echo "This will remove worktree '$display', stop its containers, and delete the local branch."
    else
      echo "This will remove worktree '$display' (branch '$branch'), stop its containers, and delete the branch."
    fi
    read -q "REPLY?Continue? [y/N] " || { echo "\nAborted."; return 1; }
    echo
  fi

  _wt:destroy "$wt_path" "$branch" false
}

# Iterate worktrees in a table; per-row prompt fills the Result cell as you go
#
# wt:cleanup
function wt:cleanup() {
  _wt:require_bare || return 1

  local -a wt_paths wt_branches wt_hashes wt_dates wt_dirties wt_dirty_counts wt_unpushed
  local cur_path="" cur_branch="" cur_hash=""
  local date_str dirty_count status_str unpushed_str ahead commits

  while IFS= read -r line; do
    if [[ "$line" == "worktree "* ]]; then
      cur_path="${line#worktree }"
    elif [[ "$line" == "HEAD "* ]]; then
      cur_hash="${line#HEAD }"
      cur_hash="${cur_hash[1,7]}"
    elif [[ "$line" == "branch refs/heads/"* ]]; then
      cur_branch="${line#branch refs/heads/}"
    elif [[ "$line" == "bare" ]]; then
      cur_path="" cur_branch="" cur_hash=""
    elif [[ -z "$line" && -n "$cur_branch" ]]; then
      wt_paths+=("$cur_path")
      wt_branches+=("$cur_branch")
      wt_hashes+=("$cur_hash")

      if [[ -d "$cur_path" ]]; then
        date_str=$(git -C "$cur_path" log -1 --format='%cd' --date=format:'%Y-%m-%d %H:%M' "$cur_branch" 2>/dev/null || echo "unknown")
        dirty_count=$(git -C "$cur_path" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        if (( dirty_count > 0 )); then
          status_str="dirty: $dirty_count"
        else
          status_str="clean"
        fi
        if git -C "$cur_path" rev-parse --abbrev-ref --symbolic-full-name '@{u}' &>/dev/null; then
          ahead=$(git -C "$cur_path" rev-list --count '@{u}..HEAD' 2>/dev/null)
          if (( ahead > 0 )); then
            unpushed_str="$ahead unpushed"
          else
            unpushed_str="up-to-date"
          fi
        else
          commits=$(git -C "$cur_path" rev-list --count HEAD 2>/dev/null)
          unpushed_str="no upstream (${commits:-0})"
        fi
      else
        date_str="missing"
        status_str="stale"
        unpushed_str="—"
        dirty_count=0
      fi
      wt_dates+=("$date_str")
      wt_dirties+=("$status_str")
      wt_dirty_counts+=("$dirty_count")
      wt_unpushed+=("$unpushed_str")

      cur_path="" cur_branch="" cur_hash=""
    fi
  done < <(git -C .bare worktree list --porcelain)

  if (( ${#wt_branches} == 0 )); then
    echo "No worktrees found."
    return 0
  fi

  local max_br=6 max_ha=7 max_da=14 max_st=8 max_un=14 max_re=7
  local i
  for (( i=1; i<=${#wt_branches}; i++ )); do
    (( ${#wt_branches[$i]} > max_br )) && max_br=${#wt_branches[$i]}
    (( ${#wt_dates[$i]}    > max_da )) && max_da=${#wt_dates[$i]}
    (( ${#wt_dirties[$i]}  > max_st )) && max_st=${#wt_dirties[$i]}
    (( ${#wt_unpushed[$i]} > max_un )) && max_un=${#wt_unpushed[$i]}
  done

  local br_line ha_line da_line st_line un_line re_line
  printf -v br_line '%*s' $((max_br + 2)) '' && br_line="${br_line// /─}"
  printf -v ha_line '%*s' $((max_ha + 2)) '' && ha_line="${ha_line// /─}"
  printf -v da_line '%*s' $((max_da + 2)) '' && da_line="${da_line// /─}"
  printf -v st_line '%*s' $((max_st + 2)) '' && st_line="${st_line// /─}"
  printf -v un_line '%*s' $((max_un + 2)) '' && un_line="${un_line// /─}"
  printf -v re_line '%*s' $((max_re + 2)) '' && re_line="${re_line// /─}"

  printf '┌%s┬%s┬%s┬%s┬%s┬%s┐\n' "$br_line" "$ha_line" "$da_line" "$st_line" "$un_line" "$re_line"
  printf '│ %-*s │ %-*s │ %-*s │ %-*s │ %-*s │ %-*s │\n' \
    $max_br "Branch" $max_ha "Hash" $max_da "Last Committed" $max_st "Status" $max_un "Unpushed" $max_re "Result"
  printf '├%s┼%s┼%s┼%s┼%s┼%s┤\n' "$br_line" "$ha_line" "$da_line" "$st_line" "$un_line" "$re_line"

  local -a actions
  local action result_label reply prompt_text row_prefix
  local wt_path branch hash date dirty dc unpushed

  for (( i=1; i<=${#wt_branches}; i++ )); do
    wt_path="${wt_paths[$i]}"
    branch="${wt_branches[$i]}"
    hash="${wt_hashes[$i]}"
    date="${wt_dates[$i]}"
    dirty="${wt_dirties[$i]}"
    dc="${wt_dirty_counts[$i]}"
    unpushed="${wt_unpushed[$i]}"

    row_prefix=$(printf '│ %-*s │ %-*s │ %-*s │ %-*s │ %-*s │ ' \
      $max_br "$branch" $max_ha "$hash" $max_da "$date" $max_st "$dirty" $max_un "$unpushed")

    prompt_text="Delete? |  [y/N/f] "
    action=""
    while true; do
      printf '\r\033[K%s%s' "$row_prefix" "$prompt_text"
      read -sk 1 reply
      case "$reply" in
        y|Y)
          if (( dc > 0 )); then
            prompt_text="Delete? | [f] to force "
            continue
          fi
          action=delete; result_label="deleted"; break ;;
        f|F)
          action=force; result_label="forced"; break ;;
        *)
          action=skip; result_label="skipped"; break ;;
      esac
    done

    printf '\r\033[K%s%-*s │\n' "$row_prefix" $max_re "$result_label"
    actions+=("$action")
  done

  printf '└%s┴%s┴%s┴%s┴%s┴%s┘\n' "$br_line" "$ha_line" "$da_line" "$st_line" "$un_line" "$re_line"

  local deleted=0 skipped=0
  for (( i=1; i<=${#wt_branches}; i++ )); do
    case "${actions[$i]}" in
      delete) _wt:destroy "${wt_paths[$i]}" "${wt_branches[$i]}" false; (( deleted++ )) ;;
      force)  _wt:destroy "${wt_paths[$i]}" "${wt_branches[$i]}" true;  (( deleted++ )) ;;
      skip)   (( skipped++ )) ;;
    esac
  done

  echo "Cleanup complete: $deleted deleted, $skipped skipped."
}

# Fetch latest changes from origin into the bare repo
#
# wt:update
function wt:update() {
  local bare
  bare=$(_wt:bare) || { echo "Error: no .bare found in or above $(pwd)."; return 1; }

  echo "Fetching into ${bare}…"
  git -C "$bare" fetch --all --prune || return 1
  echo "Done."
}

# Show available commands
#
# wt:help
function wt:help() {
  cat <<'HELP'
Worktree commands (most require project root containing .bare/):
  * = also works from any worktree folder

  wt:init <remote-url> [folder]   Clone a repo as a bare repo ready for worktrees
  wt:add <branch>                 Check out an existing remote branch as a worktree
  wt:create <branch> [base]       Create a new branch and worktree (base defaults to master)
  wt:list                       * List worktree branch names
  wt:info                       * Show detailed worktree info table
  wt:update                     * Fetch latest changes from origin into .bare
  wt:rename <old> <new>            Rename worktree directory and branch
  wt:remove <branch-or-path> [--force]
                                  Stop containers, remove worktree, prune refs (confirms first)
  wt:cleanup                      Iterate worktrees and prompt per-branch to delete (Y/N/F)
  wt:help                         Show this help
HELP
}

# ── Tab completion ──────────────────────────────────────────────────

function _wt:branches() {
  local bare
  bare=$(_wt:bare) || return
  local branches=(${(f)"$(git -C "$bare" branch --format='%(refname:short)' 2>/dev/null)"})
  compadd -a branches
}

compdef _wt:branches wt:add wt:rename wt:remove
