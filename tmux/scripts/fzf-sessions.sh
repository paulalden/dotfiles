#!/usr/bin/env bash

# Fuzzy find tmux sessions - Enter to switch, Ctrl-X to kill

current_session=$(tmux display-message -p '#S')

reload_cmd="tmux list-sessions -F '#S (#{session_windows} windows) #{?session_attached, attached,}'"

eval "$reload_cmd" \
  | fzf --no-tmux +m --reverse --exit-0 --no-preview \
    --header "Enter: switch | Ctrl-X: kill | Ctrl-N: new" \
    --bind "ctrl-x:execute-silent(
      session=\$(echo {} | awk '{print \$1}');
      [ \"\$session\" != \"$current_session\" ] && tmux kill-session -t \"\$session\"
    )+reload($reload_cmd)" \
    --bind "ctrl-n:execute-silent(tmux new-session -d)+reload($reload_cmd)" \
    --bind "enter:become(
      session=\$(echo {} | awk '{print \$1}');
      tmux switch-client -t \"\$session\"
    )"
