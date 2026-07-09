#!/usr/bin/env bash

# pane-focus-in hook -> clear a `done` (blue) marker once you actually look at
# the pane. Leaves working/urgent untouched. Arg $1: the focused pane id.
#
# This fires on every pane focus, so the common (not-done) path stays cheap: one
# tmux query, then exit. The library is only sourced when there's a dot to clear.

pane="$1"
[ -n "$pane" ] || exit 0
[ "$(tmux show-options -qvp -t "$pane" @claude_pane_state 2>/dev/null)" = done ] || exit 0

tmux set-option -up -t "$pane" @claude_pane_state 2>/dev/null || true
tmux set-option -up -t "$pane" @claude_since 2>/dev/null || true

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$dir/claude-lib.sh"
claude_rollup "$pane"
