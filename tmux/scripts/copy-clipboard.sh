#!/usr/bin/env bash

# copy-pipe target for copy mode. Like pbcopy, but leaves the clipboard alone
# when tmux pipes in nothing. A copy-pipe with no selection (stray click,
# focus click, double-click on blank space) makes plain pbcopy empty the
# system clipboard, so the next paste finds nothing.

text=$(cat; printf x)
text=${text%x}

# Copies from a Claude Code pane, or carrying Claude's ⏺ or the old ▌ bar (a
# transcript left in the scrollback after Claude exits), go through
# copy-clean.pl to drop the bar and line numbers and rejoin wrapped lines. The
# bar is now │, which tables and tree output also start lines with, so it
# can't mark a copy alone. Other copies pass through untouched, and so does
# any copy the cleaner fails on.
read -r cmd width < <(tmux display-message -p '#{pane_current_command} #{pane_width}' 2>/dev/null)
if [[ $cmd == claude || $text == *▌* || $text == *⏺* ]]; then
  if clean=$(printf '%s' "$text" | perl "$(dirname "$0")/copy-clean.pl" "$cmd" "$width" && printf x); then
    text=${clean%x}
  fi
fi

[[ -n $text ]] && printf '%s' "$text" | pbcopy
exit 0
