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

# The directory is what actually identifies a session, so show it: an
# auto-numbered name like "7" means nothing on its own. It is searchable too,
# so typing a project name finds its session whatever the session is called.
rows() {
  local name path meta
  while IFS="$tab" read -r name path meta; do
    printf '%s%s%s  %s\n' "$name" "$tab" "${path/#"$HOME"/\~}" "$meta"
  done < <(tmux list-sessions \
    -F "#S${tab}#{pane_current_path}${tab}(#{session_windows} windows)#{?session_attached, attached,}")
}

# `tmux new-session -d` with no -s makes tmux auto-number the session (4, 47,
# 6, 7...), which is what filled the picker with names relating to nothing.
# Name it after the directory it opens in instead, like tmux-sessionizer does.
new_session() {
  local dir base name n=2
  dir=$(tmux display-message -p '#{pane_current_path}')
  [ -d "$dir" ] || dir="$HOME"
  base=$(basename "$dir" | tr ' .:' '_')
  name="$base"
  while tmux has-session -t "=$name" 2>/dev/null; do
    name="$base-$n"
    n=$((n + 1))
  done
  tmux new-session -d -s "$name" -c "$dir"
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

  tmux kill-session -t "=$target" \
    || tmux display-message -d 2000 "Could not kill session: $target"
}

switch_session() {
  [ -n "$1" ] || return 0
  tmux switch-client -t "=$1"
}

rename_session() {
  local target="$1" name
  [ -n "$target" ] || return 0
  printf 'Rename "%s" to: ' "$target"
  read -r name
  [ -n "$name" ] && tmux rename-session -t "=$target" "$name"
}

case "${1:-}" in
  --rows)
    rows
    exit 0
    ;;
  --new)
    new_session
    exit 0
    ;;
  --switch)
    switch_session "$2"
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
    --delimiter "$tab" --tabstop 16 \
    --header "Enter: switch | Ctrl-X: kill | Ctrl-A: new | Ctrl-R: rename" \
    --bind "ctrl-x:execute-silent($self --kill {1})+reload($self --rows)" \
    --bind "ctrl-a:execute-silent($self --new)+reload($self --rows)" \
    --bind "ctrl-r:execute($self --rename {1})+reload($self --rows)" \
    --bind "enter:become($self --switch {1})"
