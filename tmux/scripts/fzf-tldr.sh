#!/usr/bin/env bash

# Browse tldr cheat sheets with preview
cmd=$(tldr --list | \
  fzf --no-tmux --preview 'tldr {1} --color always' \
      --preview-window=right,60% \
      --exit-0)

if [[ -n "$cmd" ]]; then
  tldr "$cmd"
  read -r -p "Press Enter to close..."
fi
