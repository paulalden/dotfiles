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
#   wt:create <remote-url> <folder-name>
#   wt:add <branch>
#
# Run all commands from the project root (the directory containing .bare/)
################################################################################

# Create a new bare repo setup
#
# wt:init <remote-url> [folder-name]
function wt:init() {
  local folder="${2:-$(basename "$1" .git)}"
  mkdir "$folder"
  git clone --bare "$1" "$folder/.bare"
  cd "$folder"
  git -C .bare config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
  git -C .bare fetch
}

function _wt:require_bare() {
  if [[ ! -d ".bare" ]]; then
    echo "Error: no .bare found in $(pwd). Navigate to project root first."
    return 1
  fi
}

# Find the next available port starting from base, skipping any already in .env files
# Usage: _wt:next_port <base> <ENV_KEY>
function _wt:next_port() {
  local base=$1 key=$2
  local used=()

  for env_file in ../*/.env(N); do
    local port
    port=$(grep -m1 "^${key}=" "$env_file" 2>/dev/null | cut -d= -f2)
    [[ -n "$port" ]] && used+=("$port")
  done

  local port=$base
  while (( ${used[(Ie)$port]} )); do
    (( port++ ))
  done

  echo "$port"
}

function _wt:write_ports() {
  local existing_app_port
  existing_app_port=$(grep -m1 '^APP_PORT=' .env 2>/dev/null | cut -d= -f2)

  local app_port=${existing_app_port:-$(_wt:next_port 3000 APP_PORT)}
  local offset=$(( app_port - 3000 ))
  local db_port=$(( 3306 + offset ))
  local redis_port=$(( 6379 + offset ))

  printf 'APP_PORT=%s\nDB_PORT=%s\nREDIS_PORT=%s\n' \
    "$app_port" "$db_port" "$redis_port" > .env

  echo "Ports — app: $app_port, db: $db_port, redis: $redis_port"
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

  git -C .bare worktree add "../$1" "$1" || return 1
  cd "$1" && git submodule update --init --recursive
  _wt:write_ports
}

# Create a new worktree with a new branch
#
# wt:create <branch-name> [base=sprint_ee]
function wt:create() {
  _wt:require_bare || return 1

  local base="${2:-sprint_ee}"
  git -C .bare worktree add "../$1" -b "$1" "$base" || return 1
  cd "$1" && git submodule update --init --recursive
  _wt:write_ports
}

# Remove a worktree
#
# wt:remove <branch-name>
function wt:remove() {
  _wt:require_bare || return 1

  docker compose -f "$1/docker-compose.yml" --env-file "$1/.env" down &>/dev/null || true
  git -C "$1" submodule deinit --all -f 2>/dev/null
  rm -rf "$1"
  git -C .bare worktree prune
}