#!/usr/bin/env bash

# Browse git stashes with diff preview
# Enter to apply, Ctrl-D to drop
git stash list | \
  fzf --no-tmux --header 'Enter: apply, Ctrl-D: drop' \
      --preview 'git stash show -p --color=always $(echo {} | cut -d: -f1)' \
      --preview-window=right,60% \
      --bind 'ctrl-d:become(git stash drop $(echo {} | cut -d: -f1))' \
      --exit-0 | \
  cut -d: -f1 | xargs -r git stash apply
