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
# Usage: wt:create <remote-url> [folder-name]
function wt:create() {
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
}

# Create a new worktree with a new branch
# Usage: wt:new <branch-name> [base=sprint_ee]
function wt:new() {
  _wt:require_bare || return 1

  local base="${2:-sprint_ee}"
  git -C .bare worktree add "../$1" -b "$1" "$base"
  cd "$1" && git submodule update --init --recursive
}

# Remove a worktree
# Usage: wt:remove <branch-name>
function wt:remove() {
  _wt:require_bare || return 1

  git -C .bare worktree remove "$1"
}
