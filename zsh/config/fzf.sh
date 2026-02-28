# -----------------------------------------------------------------------------
# FZF exports and functions
# -----------------------------------------------------------------------------

# Set default config file
export FZF_DEFAULT_OPTS_FILE=~/.fzfrc

# History
# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'CTRL-Y to copy into clipboard'
  --height=100%
  --preview-window=:hidden"

# Files / Directories
# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target,.DS_Store
  --preview 'fzf-preview.sh {}'
  --height=100%"

export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow'

################################################################################
# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
################################################################################
fe() {
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

################################################################################
# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
################################################################################
fo() {
  IFS=$'\n' out=("$(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)")
  key=$(head -1 <<<"$out")
  file=$(head -2 <<<"$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
  fi
}

################################################################################
# fda - including hidden directories
################################################################################
fda() {
  local dir
  dir=$(find ${1:-.} -type d 2>/dev/null | fzf +m) && cd "$dir"
}

################################################################################
# fdr - cd to selected parent directory
################################################################################
fdr() {
  local declare dirs=()
  get_parent_dirs() {
    if [[ -d "${1}" ]]; then dirs+=("$1"); else return; fi
    if [[ "${1}" == '/' ]]; then
      for _dir in "${dirs[@]}"; do echo $_dir; done
    else
      get_parent_dirs $(dirname "$1")
    fi
  }
  local DIR=$(get_parent_dirs $(realpath "${1:-$PWD}") | fzf-tmux --tac)
  cd "$DIR"
}

################################################################################
# fh - repeat history
################################################################################
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}

