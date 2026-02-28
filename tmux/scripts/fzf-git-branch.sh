#!/usr/bin/env bash

# Fuzzy find and checkout a git branch
# Shows local and remote branches with last commit info
branch=$(git branch -a --sort=-committerdate \
  --format='%(refname:short) %(committerdate:relative) %(subject)' | \
  fzf --no-tmux --header 'Switch branch' \
      --preview 'git log --oneline --graph --color=always {1} -- | head -20' \
      --exit-0 | \
  awk '{print $1}')

if [[ -n "$branch" ]]; then
  # Strip origin/ prefix for remote branches
  branch="${branch#origin/}"
  git checkout "$branch" 2>/dev/null || git checkout -b "$branch" "origin/$branch"
fi
