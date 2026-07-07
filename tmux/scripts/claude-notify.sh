#!/usr/bin/env bash

# Claude Code `Notification` hook -> set a per-window tmux marker by urgency.
#
#   urgent  = needs a click  (permission prompt / question)  -> red  ●
#   done    = finished/idle   (waiting for your next message) -> dim  ○
#
# The marker is rendered by window-status-format in theme.conf and cleared
# on view by the pane-focus-in hook in options.conf.

[ -n "$TMUX_PANE" ] || exit 0

input=$(cat)
ntype=$(printf '%s' "$input" | jq -r '.notification_type // empty')
msg=$(printf '%s' "$input" | jq -r '.message // empty')

case "$ntype" in
  permission_prompt | elicitation_dialog | agent_needs_input)
    level=urgent ;;
  idle_prompt | agent_completed)
    level=done ;;
  *)
    # Fall back to the message text if the type is missing or unknown.
    case "$msg" in
      *permission* | *approve*) level=urgent ;;
      *waiting* | *finished* | *complete*) level=done ;;
      *) exit 0 ;;
    esac ;;
esac

tmux set-option -w -t "$TMUX_PANE" @claude_alert "$level"
