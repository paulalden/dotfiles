#!/usr/bin/env bash

# Fuzzy find tmux windows where Claude is waiting (bell flag set).
# Enter: switch to that session + window.

windows=$(tmux list-windows -a -f '#{@claude_alert}' -F '#{session_name}:#{window_index}  [#{@claude_alert}] #{window_name}')

# Nothing waiting: show a friendly note instead of flashing an empty popup.
if [ -z "$windows" ]; then
  printf '(no Claude sessions waiting — press Esc)\n' \
    | fzf --no-tmux +m --reverse --no-preview --header "Claude Waiting"
  exit 0
fi

target=$(printf '%s\n' "$windows" \
  | fzf --no-tmux +m --reverse --exit-0 --no-preview \
    --header "Enter: switch to the waiting Claude") || exit 0

session_window=$(echo "$target" | awk '{print $1}')
tmux switch-client -t "${session_window%%:*}"
tmux select-window -t "$session_window"
