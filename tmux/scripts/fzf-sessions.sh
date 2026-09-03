#!/usr/bin/env bash

# Fuzzy find tmux sessions - Enter to switch, Ctrl-X to kill
#
# Re-entrant: fzf calls this script back with --rows / --kill / --rename for
# the reload and action bindings, which keeps the quoting out of --bind.

# Degrade gracefully when fzf is missing.
command -v fzf >/dev/null 2>&1 || { echo 'fzf not installed'; sleep 2; exit 1; }

self="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/fzf-sessions.sh"

# A tab separates the session name from its description, so names containing
# spaces survive the round trip through fzf's {1} placeholder.
tab=$(printf '\t')

rows() {
  tmux list-sessions \
    -F "#S${tab}(#{session_windows} windows)#{?session_attached, attached,}"
}

# Killing the session the client is attached to would detach the client
# (detach-on-destroy is on), so move the client elsewhere first.
kill_session() {
  local target="$1" next
  [ -n "$target" ] || return 0

  if [ "$target" = "$(tmux display-message -p '#S')" ]; then
    next=$(tmux list-sessions -F '#{session_id}' \
      | grep -vxF "$(tmux display-message -p '#{session_id}')" | head -1)
    if [ -z "$next" ]; then
      tmux display-message -d 2000 'Cannot kill the last session'
      return 0
    fi
    tmux switch-client -t "$next"
  fi

  tmux kill-session -t "$target" \
    || tmux display-message -d 2000 "Could not kill session: $target"
}

rename_session() {
  local target="$1" name
  [ -n "$target" ] || return 0
  printf 'Rename "%s" to: ' "$target"
  read -r name
  [ -n "$name" ] && tmux rename-session -t "$target" "$name"
}

case "${1:-}" in
  --rows)
    rows
    exit 0
    ;;
  --kill)
    kill_session "$2"
    exit 0
    ;;
  --rename)
    rename_session "$2"
    exit 0
    ;;
esac

rows \
  | fzf --no-tmux +m --reverse --exit-0 --no-preview \
    --delimiter "$tab" \
    --header "Enter: switch | Ctrl-X: kill | Ctrl-A: new | Ctrl-R: rename" \
    --bind "ctrl-x:execute-silent($self --kill {1})+reload($self --rows)" \
    --bind "ctrl-a:execute-silent(tmux new-session -d)+reload($self --rows)" \
    --bind "ctrl-r:execute($self --rename {1})+reload($self --rows)" \
    --bind "enter:become(tmux switch-client -t {1})"
