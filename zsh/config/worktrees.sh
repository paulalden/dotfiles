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
# Usage: wt:init <remote-url> [folder-name]
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

# Find the next APP_PORT not already used by a sibling worktree
function _wt:next_port() {
  local base=3000
  local used=()

  for env_file in ../*/.env(N); do
    local port
    port=$(grep -m1 '^APP_PORT=' "$env_file" 2>/dev/null | cut -d= -f2)
    [[ -n "$port" ]] && used+=("$port")
  done

  local port=$base
  while (( ${used[(Ie)$port]} )); do
    (( port++ ))
  done

  echo "$port"
}

# List all worktrees
function wt:list() {
  _wt:require_bare || return 1

  git -C .bare worktree list
}

# Add an existing remote branch as a worktree
# Usage: wt:add <branch-name>
function wt:add() {
  _wt:require_bare || return 1

  git -C .bare worktree add "../$1" "$1"
  cd "$1" && git submodule update --init --recursive
  local port=$(_wt:next_port)
  echo "APP_PORT=$port" > .env
  echo "Created .env with APP_PORT=$port"
}

# Create a new worktree with a new branch
# Usage: wt:create <branch-name> [base=sprint_ee]
function wt:create() {
  _wt:require_bare || return 1

  local base="${2:-sprint_ee}"
  git -C .bare worktree add "../$1" -b "$1" "$base"
  cd "$1" && git submodule update --init --recursive
  local port=$(_wt:next_port)
  echo "APP_PORT=$port" > .env
  echo "Created .env with APP_PORT=$port"
}

# Remove a worktree
# Usage: wt:remove <branch-name>
function wt:remove() {
  _wt:require_bare || return 1

  git -C "$1" submodule deinit --all -f 2>/dev/null
  git -C .bare worktree remove "$1"
}