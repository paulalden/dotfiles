#!/usr/bin/env bash

# Extract URLs from the current tmux pane scrollback and open selected one
tmux capture-pane -pS -5000 | \
  grep -oE 'https?://[^ >"]+' | \
  sort -u | \
  fzf --no-tmux --header 'Select URL to open' --exit-0 | \
  xargs -r open
