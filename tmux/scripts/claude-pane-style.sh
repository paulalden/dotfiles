#!/usr/bin/env bash

# Claude Code hook -> soften the default text colour in the Claude pane.
#
# Claude's markdown leaves reply text uncoloured, so it takes the pane's
# default foreground, which theme.conf's window-active-style sets to
# near-white. A pane-level window-active-style overrides that for this pane
# alone, leaving shell panes on the theme's colour.
#
# The pane-level style replaces the theme's whole style, not just its fg, and
# an active pane with no bg falls back to window-style's darker inactive bg.
# So the pane gets the theme's style with only fg changed.
#
#   on       -> SessionStart
#   off      -> SessionEnd (the shell left in the pane gets the theme's colour back)
#   refresh  -> tmux.conf, so a theme switch or reload reaches open Claude panes
#
# TEXT is grey 253. Your own messages are dimmer: "text" in
# claude/themes/nord.json, Nord grey7 through Kitty's color18.

TEXT='#dadada'

style() {
  local theme
  theme=$(tmux show-options -gv window-active-style 2>/dev/null)
  printf '%s' "${theme:+$theme,}fg=$TEXT"
}

case "${1:-on}" in
  on)
    [ -n "$TMUX_PANE" ] || exit 0
    tmux set-option -p -t "$TMUX_PANE" window-active-style "$(style)" 2>/dev/null
    ;;
  off)
    [ -n "$TMUX_PANE" ] || exit 0
    tmux set-option -pu -t "$TMUX_PANE" window-active-style 2>/dev/null
    ;;
  refresh)
    s=$(style)
    for p in $(tmux list-panes -a -F '#{pane_id}' 2>/dev/null); do
      [ -n "$(tmux show-options -pqv -t "$p" window-active-style)" ] &&
        tmux set-option -p -t "$p" window-active-style "$s"
    done
    ;;
esac

exit 0
