#!/usr/bin/env bash

# Switch between Claude Code sessions running in tmux.  (prefix a a)
#
# Lists every pane running claude, tagged with the attention state set by
# claude-notify.sh (the per-pane @claude_pane_state option) and how long it has
# been in that state:
#   ●  urgent   needs a click   (red)
#   ●  done     finished        (blue)
#   ●  working                  (yellow)
#   z  parked   deferred        (grey)
# Sorted attention-first, then oldest-first (claude_list in claude-lib.sh).
# Enter jumps to that session / window / pane; a live preview shows each pane.
# In-list actions reload the list in place:
#   ctrl-x  clear the row's attention marker
#   ctrl-s  silence / unsilence the row (quiet: no banner or escalation)
# ctrl-p is deliberately left alone — it's fzf's default move-up.
#
# Re-entrant: called by fzf itself with --rows / --clear / --park for the
# reload and action bindings.

# Degrade gracefully when fzf is missing.
command -v fzf >/dev/null 2>&1 || { echo 'fzf not installed'; sleep 2; exit 1; }

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$dir/claude-lib.sh"

us=$(printf '\037')
esc=$(printf '\033')

rows() {
  local id state parked since age tgt title color glyph dot
  while IFS="$us" read -r id state parked since age tgt title; do
    [ "$parked" = 1 ] && state=parked
    read -r color glyph <<<"$(claude_style "$state")"
    dot="${esc}[${color}m${glyph}${esc}[0m"
    printf '%-16s %s  %-4s %s\n' "$tgt" "$dot" "$age" "$title"
  done < <(claude_list)
}

case "${1:-}" in
  --rows)
    rows
    exit 0
    ;;
  --clear)
    claude_clear_pane "$2"
    claude_rollup "$2"
    exit 0
    ;;
  --park)
    claude_park_toggle "$2"
    exit 0
    ;;
esac

list=$(rows)

# Nothing running: show a note instead of flashing an empty popup.
if [ -z "$list" ]; then
  printf '(no Claude sessions running — press Esc)\n' \
    | fzf --no-tmux +m --reverse --no-preview --header "Claude Sessions"
  exit 0
fi

self="$dir/fzf-claude.sh"
legend="Enter: switch   $(claude_legend)
ctrl-x: clear   ctrl-s: silence"

sel=$(printf '%s\n' "$list" \
  | fzf --no-tmux --ansi +m --reverse --exit-0 \
    --header "$legend" \
    --preview 'tmux capture-pane -pe -t {1}' \
    --preview-window=right,60% \
    --bind "ctrl-x:execute-silent($self --clear {1})+reload($self --rows)" \
    --bind "ctrl-s:execute-silent($self --park {1})+reload($self --rows)") || exit 0

claude_goto "$(printf '%s' "$sel" | awk '{print $1}')" \
  || tmux display-message 'Claude pane is gone'
