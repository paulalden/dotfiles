#!/usr/bin/env bash

# Browse git log with fzf and preview diffs
git log --oneline --color=always --decorate | \
  fzf --no-tmux --ansi --no-sort --style=default \
      --header 'Git log (Enter to view, Ctrl-O to checkout)' \
      --preview 'git show --color=always --stat --patch {1}' \
      --preview-window=right,60% \
      --bind 'enter:execute(git show --color=always {1} | less -R)' \
      --bind 'ctrl-o:become(git checkout {1})'
