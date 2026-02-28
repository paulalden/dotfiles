#!/usr/bin/env bash

# Find and edit a file in the current pane's directory using fzf
file=$(fd --type f --strip-cwd-prefix --hidden --follow --exclude .git --exclude node_modules | \
  fzf --no-tmux --preview 'fzf-preview.sh {}' --exit-0)

if [[ -n "$file" ]]; then
  ${EDITOR:-nvim} "$file"
fi
