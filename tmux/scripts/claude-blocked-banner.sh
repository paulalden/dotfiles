#!/usr/bin/env bash

# Emit a bottom-right status-bar notification when any Claude window is blocked
# (needs a click). Wired into status-right via #(...); reads the @claude_alert
# state set by claude-notify.sh. Prints nothing when nothing is blocked.

names=$(tmux list-windows -a -f '#{==:#{@claude_alert},urgent}' -F '#{pane_title}' 2>/dev/null)
[ -z "$names" ] && exit 0

count=$(printf '%s\n' "$names" | grep -c .)
name=$(printf '%s\n' "$names" | head -1 | sed 's/^[^A-Za-z0-9]* *//' | cut -c1-28)
[ "$count" -gt 1 ] && name="$name +$((count - 1))"

printf '#[bg=#d08770,fg=#2e3440,bold] 🔔 %s needs you #[bg=default,fg=default]  ' "$name"
