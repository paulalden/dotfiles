#!/usr/bin/env bash

# Interactive git add with diff preview
files=$(git ls-files --modified --others --exclude-standard | \
  fzf --no-tmux --multi \
      --header 'Select files to stage' \
      --preview 'git diff --color=always {} 2>/dev/null || bat --color=always {}' \
      --exit-0)

if [[ -n "$files" ]]; then
  echo "$files" | xargs git add
  echo "Staged files:"
  git diff --cached --name-only
  read -r -p "Press Enter to close..."
fi
