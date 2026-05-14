#!/usr/bin/env bash

# Find and edit a file in the current pane's directory using fzf.
# Respects .gitignore (fd default). Hidden files are off by default —
# press Ctrl-H inside fzf to toggle them on/off.
# Enter: edit in popup, Ctrl-S: edit in caller pane
RESULT_FILE=/tmp/tmux-fzf-result

FD_BASE="fd --type f --strip-cwd-prefix --follow --exclude .git --exclude node_modules"

file=$($FD_BASE | \
  fzf --no-tmux --preview 'fzf-preview.sh {}' \
    --prompt '> ' \
    --header 'Enter: edit here · Ctrl-S: edit in pane · Ctrl-H: toggle hidden' \
    --bind "ctrl-s:become(echo '{}' > $RESULT_FILE)" \
    --bind "ctrl-h:transform:[[ \$FZF_PROMPT == '> ' ]] && echo 'change-prompt(hidden> )+reload($FD_BASE --hidden)' || echo 'change-prompt(> )+reload($FD_BASE)'" \
    --exit-0)

if [[ -n "$file" ]]; then
  ${EDITOR:-nvim} "$file"
fi
