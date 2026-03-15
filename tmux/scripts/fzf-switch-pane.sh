#!/usr/bin/env bash

# Fuzzy find and switch to a tmux pane
panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
current_pane=$(tmux display-message -p '#I:#P')

target=$(echo "$panes" | grep -v "$current_pane" | fzf --no-tmux +m --reverse --exit-0 --no-preview) || exit 0

target_window=$(echo "$target" | awk 'BEGIN{FS=":|-"} {print$1}')
target_pane=$(echo "$target" | awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1)

tmux select-pane -t "${target_window}.${target_pane}"
tmux select-window -t "$target_window"
