#!/usr/bin/env bash

# Fuzzy search man pages and open the selected one
page=$(man -k . 2>/dev/null | sort -u | \
  fzf --no-tmux --header 'Select man page' \
      --preview 'man {1} 2>/dev/null | head -80' \
      --exit-0 | \
  awk '{print $1}')

if [[ -n "$page" ]]; then
  man "$page"
fi
