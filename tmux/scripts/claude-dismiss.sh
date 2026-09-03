#!/usr/bin/env bash

# prefix-ad -> dismiss every Claude marker in the current session. Unlike the
# pane-focus-in auto-clear (done only), this is an explicit user action, so it
# fully clears working/urgent/done on every pane of every window in the
# session. Arg $1: any target the session resolves from (a session id/name,
# window id, or pane id).

target="$1"
[ -n "$target" ] || exit 0

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$dir/claude-lib.sh"

# Clear every pane across all windows of the session.
while IFS= read -r pane; do
  [ -n "$pane" ] || continue
  claude_clear_pane "$pane"
done < <(tmux list-panes -s -t "$target" -F '#{pane_id}' 2>/dev/null)

# The status dot is per-window, so refresh each window's rollup.
while IFS= read -r win; do
  [ -n "$win" ] || continue
  claude_rollup "$win"
done < <(tmux list-windows -t "$target" -F '#{window_id}' 2>/dev/null)
