#!/usr/bin/env bash

# Claude Code hook -> record this window's Claude state as the @claude_alert
# tmux window option. State is passed as $1 and drives the status-bar dot
# (theme.conf) and the session switcher (fzf-claude.sh):
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

state="${1:-working}"

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
  tmux set-option -uw -t "$TMUX_PANE" @claude_alert 2>/dev/null || true
else
  tmux set-option -w -t "$TMUX_PANE" @claude_alert "$state" 2>/dev/null || true
fi
