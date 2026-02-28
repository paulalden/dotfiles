#!/usr/bin/env bash

# Live interactive ripgrep with file preview
# Type to search, Enter to open in editor at the matching line
RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case"

result=$(fzf --no-tmux --ansi --disabled \
    --bind "start:reload:$RG_PREFIX {q} || true" \
    --bind "change:reload:$RG_PREFIX {q} || true" \
    --delimiter : \
    --header 'Live grep (Enter to edit)' \
    --preview 'bat --color=always --highlight-line {2} {1} 2>/dev/null' \
    --preview-window '+{2}/2' \
    --exit-0)

if [[ -n "$result" ]]; then
  file=$(echo "$result" | awk -F: '{print $1}')
  line=$(echo "$result" | awk -F: '{print $2}')
  ${EDITOR:-nvim} "+$line" "$file"
fi
