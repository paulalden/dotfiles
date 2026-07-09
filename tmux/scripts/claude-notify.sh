#!/usr/bin/env bash

# Claude Code hook -> record this PANE's Claude state. State is passed as $1 and
# drives the status-bar dot (theme.conf), the switcher (fzf-claude.sh) and the
# banner/escalation (claude-tick.sh):
#
#   working  -> yellow ●   (processing)
#   urgent   -> red ●      (needs a click: permission / question)
#   done     -> blue ●     (finished, waiting for you)
#   clear    -> no dot     (session ended)
#
# Wired in claude/settings.json:
#   SessionStart/UserPromptSubmit/Pre+PostToolUse -> working
#   Notification permission/elicitation            -> urgent
#   Stop                                           -> done (see below)
#   SessionEnd                                     -> clear

[ -n "$TMUX_PANE" ] || exit 0

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$dir/claude-lib.sh"

state="${1:-working}"
pane="$TMUX_PANE"

# A `Stop` fires when the turn ends -> "done". But if the turn ended while a
# run_in_background task is still going, the session isn't really idle. The Stop
# payload carries a `background_tasks` array; if any task is still "running",
# stay "working". Claude fires another Stop with an empty array when the task
# finishes, which then marks done. (Older Claude versions omit the field -> done.)
if [ "$state" = done ] && [ ! -t 0 ]; then
  input=$(cat 2>/dev/null)
  running=$(printf '%s' "$input" \
    | jq -r '[.background_tasks[]? | select(.status == "running")] | length' 2>/dev/null)
  case "$running" in
    '' | *[!0-9]*) : ;;
    0) : ;;
    *) state=working ;;
  esac
fi

if [ "$state" = clear ]; then
  tmux set-option -up -t "$pane" @claude_pane_state 2>/dev/null || true
  tmux set-option -up -t "$pane" @claude_since 2>/dev/null || true
  tmux set-option -up -t "$pane" @claude_notified 2>/dev/null || true
else
  prev=$(tmux show-options -qvp -t "$pane" @claude_pane_state 2>/dev/null)
  if [ "$prev" != "$state" ]; then
    tmux set-option -p -t "$pane" @claude_since "$(date +%s)" 2>/dev/null || true
    # Leaving urgent -> allow a fresh desktop alert next time it blocks.
    [ "$prev" = urgent ] && tmux set-option -up -t "$pane" @claude_notified 2>/dev/null || true
  fi
  tmux set-option -p -t "$pane" @claude_pane_state "$state" 2>/dev/null || true
fi

# Refresh the window dot from this window's panes.
claude_rollup "$pane"
