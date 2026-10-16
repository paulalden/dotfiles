#!/usr/bin/env bash

# Popup body for prefix-x: asks before killing the pane behind the popup.
# Enter or y/Y kills it; any other key cancels.

printf '\n  Kill this pane? [Y/n] '
IFS= read -rsn1 key

case "$key" in
  "" | y | Y) tmux kill-pane ;;
esac
