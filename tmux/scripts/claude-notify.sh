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
#   Notification idle / Stop                       -> done
#   SessionEnd                                     -> clear

[ -n "$TMUX_PANE" ] || exit 0

state="${1:-working}"

if [ "$state" = clear ]; then
  tmux set-option -uw -t "$TMUX_PANE" @claude_alert 2>/dev/null || true
else
  tmux set-option -w -t "$TMUX_PANE" @claude_alert "$state" 2>/dev/null || true
fi
