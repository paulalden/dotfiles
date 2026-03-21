#!/usr/bin/env bash

# Find and edit a file in the current pane's directory using fzf
# Enter: edit in popup, Ctrl-S: edit in caller pane
RESULT_FILE=/tmp/tmux-fzf-result

file=$(fd --type f --strip-cwd-prefix --hidden --follow --exclude .git --exclude node_modules | \
  fzf --no-tmux --preview 'fzf-preview.sh {}' \
    --header 'Enter: edit here, Ctrl-S: edit in pane' \
    --bind "ctrl-s:become(echo '{}' > $RESULT_FILE)" \
    --exit-0)

if [[ -n "$file" ]]; then
  ${EDITOR:-nvim} "$file"
fi
