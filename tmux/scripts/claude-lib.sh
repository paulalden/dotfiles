#!/usr/bin/env bash

# Shared helpers for the Claude-in-tmux status feature.
# Sourced by claude-notify.sh, claude-tick.sh, claude-jump.sh, claude-clear-done.sh.
#
# State lives in per-PANE tmux options (keyed by pane id, so it vanishes when a
# pane closes):
#   @claude_pane_state  working|urgent|done   (source of truth)
#   @claude_since       epoch seconds the current state began
#   @claude_notified    "1" once the desktop alert fired for this urgent spell
# and a per-WINDOW rollup that drives the status-bar dot:
#   @claude_alert       working|urgent|done   (max severity of the window's panes)

# Severity rank: higher wins the window rollup. urgent > working > done.
claude_rank() {
  case "$1" in
    urgent) echo 3 ;;
    working) echo 2 ;;
    done) echo 1 ;;
    *) echo 0 ;;
  esac
}

# Is a `claude` process alive on this pane's tty?
# Uses full argv (command=) so `zsh -c "claude …"` wrappers still match, and so
# it works even when claude isn't the pane's foreground process (e.g. mid tool
# call). This is the reconcile-on-read check: a dead pane simply drops out.
claude_alive() {
  local tty="$1"
  [ -n "$tty" ] || return 1
  ps -t "$tty" -o command= 2>/dev/null | grep -qw claude
}

# Recompute a window's @claude_alert rollup from its panes' @claude_pane_state.
# Arg: any target the window resolves from (a pane id or a window id).
claude_rollup() {
  local target="$1" best="" best_rank=0 state rank
  while IFS= read -r state; do
    [ -n "$state" ] || continue
    rank=$(claude_rank "$state")
    if [ "$rank" -gt "$best_rank" ]; then
      best_rank=$rank
      best=$state
    fi
  done < <(tmux list-panes -t "$target" -F '#{@claude_pane_state}' 2>/dev/null)

  if [ -n "$best" ]; then
    tmux set-option -w -t "$target" @claude_alert "$best" 2>/dev/null || true
  else
    tmux set-option -uw -t "$target" @claude_alert 2>/dev/null || true
  fi
}

# Format an age in seconds as a compact string: 45s, 3m, 2h.
fmt_age() {
  local s="$1"
  [ -n "$s" ] && [ "$s" -ge 0 ] 2>/dev/null || { echo ""; return; }
  if [ "$s" -lt 60 ]; then
    echo "${s}s"
  elif [ "$s" -lt 3600 ]; then
    echo "$((s / 60))m"
  else
    echo "$((s / 3600))h"
  fi
}
