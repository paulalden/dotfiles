#!/usr/bin/env bash

# Claude Code hook -> soften the default text colour in the Claude pane.
#
# Claude's markdown leaves reply text uncoloured, so it takes the pane's
# default foreground, which theme.conf's window-active-style sets to
# near-white. A pane-level window-active-style overrides that for this pane
# alone, leaving shell panes on the theme's colour.
#
#   on   -> SessionStart
#   off  -> SessionEnd (the shell left in the pane gets the theme's colour back)
#
# TEXT matches "text": "ansi256(253)" in claude/themes/nord.json, which
# colours your own prompts.

[ -n "$TMUX_PANE" ] || exit 0

TEXT='#dadada'

case "${1:-on}" in
  on) tmux set-option -p -t "$TMUX_PANE" window-active-style "fg=$TEXT" 2>/dev/null ;;
  off) tmux set-option -pu -t "$TMUX_PANE" window-active-style 2>/dev/null ;;
esac

exit 0
