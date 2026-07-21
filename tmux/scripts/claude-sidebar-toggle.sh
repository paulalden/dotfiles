#!/usr/bin/env bash

# prefix a s -> toggle the Claude sessions sidebar in the given (or current)
# window: a full-height left split running claude-sidebar.sh. The pane is
# marked with the @claude_sidebar option so a second press finds and closes
# it. Window-local: each window can have its own sidebar.

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$dir/claude-lib.sh"   # provides CLAUDE_SIDEBAR_WIDTH, shared with the sidebar

win="${1:-$(tmux display-message -p '#{window_id}')}"
existing=$(tmux list-panes -t "$win" -f '#{==:#{@claude_sidebar},1}' -F '#{pane_id}' 2>/dev/null | head -1)

if [ -n "$existing" ]; then
  tmux kill-pane -t "$existing" 2>/dev/null || true
else
  # -P prints the new pane id so the marker is set before a second toggle
  # could race to look for it.
  id=$(tmux split-window -hbf -l "$CLAUDE_SIDEBAR_WIDTH" -t "$win" -P -F '#{pane_id}' \
    "exec $dir/claude-sidebar.sh" 2>/dev/null)
  [ -n "$id" ] || exit 0
  tmux set-option -p -t "$id" @claude_sidebar 1 2>/dev/null || true
  # A slightly darker backdrop ($grey14 from the shared palette) frames the
  # sidebar as chrome, echoing the themed popups its siblings get for free.
  tmux select-pane -t "$id" -P "bg=$grey14" 2>/dev/null || true
  # Best-effort double-press handling: if two toggles race past each other's
  # marker check, whichever sees another marked pane bows out. That ends with
  # at most one sidebar; a tight double press can also end with zero, which
  # is what open-then-close meant anyway.
  others=$(tmux list-panes -t "$win" -f '#{==:#{@claude_sidebar},1}' -F '#{pane_id}' 2>/dev/null \
    | grep -cv "^$id\$")
  if [ "$others" -gt 0 ]; then
    tmux kill-pane -t "$id" 2>/dev/null || true
  fi
fi
