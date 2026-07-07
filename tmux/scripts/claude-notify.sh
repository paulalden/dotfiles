#!/usr/bin/env bash

# Claude Code `Notification` hook -> flag the Claude window in the tmux status
# bar. The tier is passed as $1, chosen by the matcher in claude/settings.json:
#
#   urgent = needs a click  (permission prompt / question)  -> red ●
#   done   = finished/idle   (waiting for your next message) -> dim ○
#
# The marker is rendered by window-status-format (theme.conf) and cleared on
# view by the pane-focus-in hook (options.conf).

[ -n "$TMUX_PANE" ] || exit 0

level="${1:-done}"

# Don't badge a window you're already looking at — you can see it needs you.
watching=$(tmux display-message -p -t "$TMUX_PANE" \
  '#{&&:#{window_active},#{session_attached}}' 2>/dev/null)
[ "$watching" = 1 ] && exit 0

tmux set-option -w -t "$TMUX_PANE" @claude_alert "$level" 2>/dev/null || true
