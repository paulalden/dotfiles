#!/usr/bin/env bash

# prefix t A -> jump straight to the oldest blocked (urgent) Claude session,
# skipping the switcher popup. Falls back to a message when nothing is blocked.

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$dir/claude-lib.sh"

us=$(printf '\037')   # field sep for tmux -F: non-whitespace, so empty fields survive `read`
fmt="#{@claude_since}$us#{pane_tty}$us#{session_name}:#{window_index}.#{pane_index}"

target=""
while IFS="$us" read -r since tty tgt; do
  claude_alive "$tty" || continue   # skip dead panes (reconcile-on-read)
  target="$tgt"
  break
done < <(tmux list-panes -a -f '#{==:#{@claude_pane_state},urgent}' -F "$fmt" \
  | sort -t"$us" -k1,1n)

if [ -z "$target" ]; then
  tmux display-message 'No blocked Claude sessions'
  exit 0
fi

session="${target%%:*}"
win="${target#*:}"; win="${win%%.*}"
tmux switch-client -t "$session"
tmux select-window -t "$session:$win"
tmux select-pane -t "$target"
