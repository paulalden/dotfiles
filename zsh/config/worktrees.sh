################################################################################
# Git Worktrees
#
# These functions assume a bare repo setup:
#
#   ProjectName/
#     .bare/          <- bare clone (git internals)
#     branch-name/    <- worktrees (folder name matches branch name)
#
# Initial setup:
#   wt:init <remote-url> [folder-name]
#   wt:add <branch>
#
# Run all commands from the project root (the directory containing .bare/)
################################################################################

# ── Private helpers ─────────────────────────────────────────────────

function _wt:require_bare() {
  if [[ ! -d ".bare" ]]; then
    echo "Error: no .bare found in $(pwd). Navigate to project root first."
    return 1
  fi
}

# Find the project root (directory containing .bare/)
function _wt:project_root() {
  local dir=$PWD
  while [[ "$dir" != "/" ]]; do
    [[ -d "$dir/.bare" ]] && { echo "$dir"; return 0; }
    dir="${dir:h}"
  done
  return 1
}

# Find the next available port by taking the highest in use + 1, or base if none found
# Usage: _wt:next_port <base> <ENV_KEY>
function _wt:next_port() {
  local base=$1 key=$2
  local max=$base
  local root
  root=$(_wt:project_root) || { echo "$base"; return; }

  local port
  while IFS= read -r env_file; do
    port=$(grep -m1 "^${key}=" "$env_file" 2>/dev/null | cut -d= -f2 | tr -d '[:space:]')
    [[ -n "$port" ]] && (( port >= max )) && max=$(( port + 1 ))
  done < <(find "$root" -name .env -not -path "*/.bare/*" 2>/dev/null)

  echo "$max"
}

# Write port assignments to .env, preserving any existing non-port variables
function _wt:write_ports() {
  local existing_app_port
  existing_app_port=$(grep -m1 '^APP_PORT=' .env 2>/dev/null | cut -d= -f2)

  local app_port=${existing_app_port:-$(_wt:next_port 3000 APP_PORT)}
  local offset=$(( app_port - 3000 ))
  local db_port=$(( 3306 + offset ))
  local redis_port=$(( 6379 + offset ))

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
  _wt:require_bare || return 1

  git -C .bare worktree list
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
# wt:remove <branch-name> [--force]
function wt:remove() {
  _wt:require_bare || return 1
  if [[ -z "$1" ]]; then
    echo "Usage: wt:remove <branch-name> [--force]"
    return 1
  fi

  local branch="$1"
  local force=false
  [[ "$2" == "--force" ]] && force=true

  if [[ ! -d "$branch" ]]; then
    echo "Error: worktree directory '$branch' not found."
    return 1
  fi

  if [[ "$force" != true ]]; then
    echo "This will remove worktree '$branch', stop its containers, and delete the local branch."
    read -q "REPLY?Continue? [y/N] " || { echo "\nAborted."; return 1; }
    echo
  fi

  docker compose -f "$branch/docker-compose.yml" --env-file "$branch/.env" down &>/dev/null || true
  git -C "$branch" submodule deinit --all -f 2>/dev/null
  rm -rf "$branch"
  git -C .bare worktree prune
  git -C .bare branch -d "$branch" 2>/dev/null || {
    echo "Warning: branch '$branch' has unmerged changes. Use 'git -C .bare branch -D $branch' to force delete."
  }
}

# Show available commands
#
# wt:help
function wt:help() {
  cat <<'HELP'
Worktree commands (run from project root containing .bare/):

  wt:init <remote-url> [folder]   Clone a repo as a bare repo ready for worktrees
  wt:add <branch>                 Check out an existing remote branch as a worktree
  wt:create <branch> [base]       Create a new branch and worktree (base defaults to master)
  wt:list                         List all worktrees
  wt:rename <old> <new>            Rename worktree directory and branch
  wt:remove <branch> [--force]    Stop containers, remove worktree, prune refs (confirms first)
  wt:help                         Show this help
HELP
}

# ── Tab completion ──────────────────────────────────────────────────

function _wt:branches() {
  local root
  root=$(_wt:project_root) || return
  local branches=(${(f)"$(git -C "$root/.bare" branch --format='%(refname:short)' 2>/dev/null)"})
  compadd -a branches
}

compdef _wt:branches wt:add wt:rename wt:remove
