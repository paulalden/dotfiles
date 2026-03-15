#!/usr/bin/env bash

# Browse listening ports and kill the selected process
pid=$(lsof -iTCP -sTCP:LISTEN -n -P 2>/dev/null | tail -n +2 | \
  fzf --no-tmux --no-preview --header 'Select port to kill process' \
      --exit-0 | \
  awk '{print $2}')

if [[ -n "$pid" ]]; then
  kill -9 "$pid"
  echo "Killed process $pid"
  read -r -p "Press Enter to close..."
fi
