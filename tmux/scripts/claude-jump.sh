#!/usr/bin/env bash

# prefix t A / prefix a A -> jump to the oldest blocked (urgent) Claude session,
# skipping the switcher popup. Falls back to a message when nothing is blocked.

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$dir/claude-lib.sh"

us=$(printf '\037')

# claude_list sorts urgent first, oldest first, and drops dead panes — so the
# first unparked urgent row is the one to jump to (parked = deliberately
# deferred, so the jump key skips it).
target=""
while IFS="$us" read -r id state parked since age tgt title; do
  [ "$state" = urgent ] || continue
  [ "$parked" = 1 ] && continue
  target="$tgt"
  break
done < <(claude_list)

if [ -z "$target" ]; then
  tmux display-message 'No blocked Claude sessions'
  exit 0
fi

claude_goto "$target" || tmux display-message 'Claude pane is gone'
