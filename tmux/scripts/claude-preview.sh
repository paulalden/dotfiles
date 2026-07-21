#!/usr/bin/env bash

# Live view of one tmux pane — the sidebar's `o` (peek) popup.
# Redraws the pane's visible content once a second; any key closes. Runs
# inside a display-popup started by claude-sidebar.sh.

tgt="$1"
[ -n "$tgt" ] || exit 1

esc=$(printf '\033')

tput civis
trap 'tput cnorm' EXIT

while :; do
  printf '%s[H' "$esc"
  # [K per line, [J after: same no-flicker redraw as the sidebar itself.
  # Capture checked on its own — a pipeline would report awk's status.
  if out=$(tmux capture-pane -ep -t "$tgt" 2>/dev/null); then
    printf '%s\n' "$out" | awk -v k="${esc}[K" '{print $0 k}'
  else
    printf ' %s[90m(pane is gone — press any key)%s[0m%s[K' "$esc" "$esc" "$esc"
  fi
  printf '%s[J' "$esc"
  read -rsn1 -t 1 && exit 0
done
