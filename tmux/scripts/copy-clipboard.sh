#!/usr/bin/env bash

# copy-pipe target for copy mode. Like pbcopy, but leaves the clipboard alone
# when tmux pipes in nothing. A copy-pipe with no selection (stray click,
# focus click, double-click on blank space) makes plain pbcopy empty the
# system clipboard, so the next paste finds nothing.

text=$(cat; printf x)
text=${text%x}
[[ -n $text ]] && printf '%s' "$text" | pbcopy
exit 0
