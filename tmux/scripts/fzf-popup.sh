#!/usr/bin/env bash

# Wrapper that dims the background panes while a popup script runs.
# Usage: fzf-popup.sh <script> [args...]
#
# Detects the parent window automatically via TMUX_PANE.

# Find the window containing the pane that launched this popup
WINDOW_ID=$(tmux list-panes -a -F '#{pane_id} #{window_id}' | awk -v pane="$TMUX_PANE" '$1 != pane {print $2}' | head -1)

# Fallback: use the active window of the current client
if [[ -z "$WINDOW_ID" ]]; then
  WINDOW_ID=$(tmux display-message -p '#{window_id}')
fi

# Export the active pane in the original window so scripts can send commands to it
export CALLER_PANE=$(tmux list-panes -t "$WINDOW_ID" -F '#{pane_id} #{pane_active}' | awk '$2 == 1 {print $1}')

# Dim the original window's panes
tmux set -t "$WINDOW_ID" -w window-style "fg=#464f62,bg=#1c1f26"
tmux set -t "$WINDOW_ID" -w window-active-style "fg=#464f62,bg=#1c1f26"

# Restore original styles on exit (matches theme.conf values)
restore() {
  tmux set -t "$WINDOW_ID" -w window-style "fg=#74819a,bg=#282e38" 2>/dev/null
  tmux set -t "$WINDOW_ID" -w window-active-style "fg=#ECEFF4,bg=#2e3440" 2>/dev/null
}
trap restore EXIT

# Run the actual script
"$@"
