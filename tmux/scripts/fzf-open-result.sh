#!/usr/bin/env bash

# Opens the file saved in /tmp/tmux-fzf-result in the active tmux pane
RESULT_FILE=/tmp/tmux-fzf-result

[[ -f "$RESULT_FILE" ]] || exit 0

args=$(cat "$RESULT_FILE")
rm -f "$RESULT_FILE"

tmux send-keys "${EDITOR:-nvim} $args" Enter
