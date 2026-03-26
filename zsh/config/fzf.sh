# -----------------------------------------------------------------------------
# FZF exports and functions
# -----------------------------------------------------------------------------

# Set default config file
export FZF_DEFAULT_OPTS_FILE=~/.fzfrc

# History
# CTRL-Y to copy the command into clipboard
if [[ "$(uname)" == "Darwin" ]]; then
  _fzf_clip_cmd="pbcopy"
else
  _fzf_clip_cmd="xclip -selection clipboard"
fi
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | $_fzf_clip_cmd)+abort'
  --color header:italic
  --header 'CTRL-Y to copy into clipboard'
  --height=100%
  --preview-window=:hidden"
unset _fzf_clip_cmd

# Files / Directories
# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target,.DS_Store
  --preview 'fzf-preview.sh {}'
  --height=100%"

export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow'

################################################################################
# fcd - cd into a directory (including hidden)
################################################################################
fcd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git ${1:+--search-path "$1"} | \
    fzf --no-tmux --no-preview) && cd "$dir"
}

################################################################################
# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
################################################################################
fe() {
  IFS=$'\n' files=($(fd --type f --strip-cwd-prefix --hidden --follow --exclude .git | \
    fzf --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

################################################################################
# fo [FUZZY PATTERN] - Open file with open or $EDITOR
#   - CTRL-O to open with `open` command
#   - Enter to open with $EDITOR
################################################################################
fo() {
  IFS=$'\n' out=("$(fd --type f --strip-cwd-prefix --hidden --follow --exclude .git | \
    fzf --query="$1" --exit-0 --expect=ctrl-o)")
  key=$(head -1 <<<"$out")
  file=$(head -2 <<<"$out" | tail -1)
  if [[ -n "$file" ]]; then
    if [[ "$key" = ctrl-o ]] && command -v open &>/dev/null; then
      open "$file"
    else
      ${EDITOR:-vim} "$file"
    fi
  fi
}