#!/usr/bin/env bash

# Rewrite saved pane paths that no longer exist to their nearest existing
# ancestor, before tmux-resurrect restores them.
#
# resurrect passes each saved path straight to `tmux new-window -c "$dir"` with
# no existence check. tmux does not error on a missing directory: it creates the
# pane anyway, and the shell then starts in a deleted cwd and prints
# "getcwd: cannot access parent directories" on every prompt, with `ls` showing
# nothing. Deleting a worktree or project directory is enough to poison every
# later restore, because continuum replays the same saved path each start.
#
# Wired to resurrect's pre-restore-all hook (see options.conf), which runs
# synchronously before the save file is read. Safe to run by hand.
#
# This only fixes saved paths. The same getcwd error also appears when the tmux
# *server* process itself holds a deleted cwd, because every pane it spawns
# inherits that directory even when -c names a live one. Nothing can chdir a
# running server, so that case needs `tmux kill-server` and a fresh start.

set -uo pipefail

resurrect_dir="$(tmux show-option -gqv '@resurrect-dir')"
resurrect_dir="${resurrect_dir/#\~/$HOME}"
resurrect_dir="${resurrect_dir:-$HOME/.tmux/resurrect}"

last="$resurrect_dir/last"
[ -f "$last" ] || exit 0

# `last` is a symlink to a timestamped snapshot. Rewrite the snapshot itself so
# the symlink stays intact and the correction survives into later restores.
target="$last"
if [ -L "$last" ]; then
  link="$(readlink "$last")"
  case "$link" in
    /*) target="$link" ;;
    *) target="$resurrect_dir/$link" ;;
  esac
fi
[ -f "$target" ] || exit 0

# Walk up until something that exists is found. $HOME is the last resort, since
# restoring a pane at / is rarely what was meant.
nearest_existing_dir() {
  local dir="$1"
  while [ -n "$dir" ] && [ "$dir" != "/" ] && [ ! -d "$dir" ]; do
    dir="$(dirname "$dir")"
  done
  if [ -d "$dir" ] && [ "$dir" != "/" ]; then
    printf '%s' "$dir"
  else
    printf '%s' "$HOME"
  fi
}

tmp="$(mktemp "${TMPDIR:-/tmp}/resurrect-prune.XXXXXX")" || exit 0
trap 'rm -f "$tmp"' EXIT

changed=0
while IFS= read -r line || [ -n "$line" ]; do
  # Only `pane` lines carry a directory, in tab-separated field 8. cut keeps
  # empty fields intact, which splitting on $IFS would collapse.
  if [ "${line%%$'\t'*}" != "pane" ]; then
    printf '%s\n' "$line" >>"$tmp"
    continue
  fi

  field="$(printf '%s' "$line" | cut -f8)"
  # resurrect prefixes the path with ':' so the field is never empty.
  prefix=""
  dir="$field"
  case "$dir" in
    :*) prefix=":"; dir="${dir#:}" ;;
  esac
  dir="${dir/#\~/$HOME}"

  if [ -z "$dir" ] || [ -d "$dir" ]; then
    printf '%s\n' "$line" >>"$tmp"
    continue
  fi

  replacement="$(nearest_existing_dir "$dir")"
  printf '%s\t%s%s\t%s\n' \
    "$(printf '%s' "$line" | cut -f1-7)" \
    "$prefix" "$replacement" \
    "$(printf '%s' "$line" | cut -f9-)" >>"$tmp"
  changed=1
done <"$target"

if [ "$changed" -eq 1 ]; then
  cat "$tmp" >"$target"
fi
