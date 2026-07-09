#!/usr/bin/env bash

# Switch between Claude Code sessions running in tmux.  (prefix t a)
#
# Lists every pane running claude, tagged with the attention state set by
# claude-notify.sh (the per-pane @claude_pane_state option) and how long it has
# been in that state:
#   ●  urgent   needs a click   (red)
#   ○  done     finished        (blue)
#   ·  working                  (yellow)
# Sorted attention-first, then oldest-first. Dead panes are dropped on read.
# Enter jumps to that session / window / pane; a live preview shows each pane.

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$dir/claude-lib.sh"

now=$(date +%s)
tab=$(printf '\t')
us=$(printf '\037')   # field sep for tmux -F: non-whitespace, so empty fields survive `read`
esc=$(printf '\033')

# state  since  tty  target  title
fmt="#{@claude_pane_state}$us#{@claude_since}$us#{pane_tty}$us"
fmt+="#{session_name}:#{window_index}.#{pane_index}$us#{pane_title}"

rows=""
while IFS="$us" read -r state since tty tgt title; do
  claude_alive "$tty" || continue    # reconcile-on-read: drop dead panes
  case "$state" in
    urgent)  rank=0; color=91; glyph='●' ;;
    done)    rank=1; color=94; glyph='○' ;;
    working) rank=2; color=93; glyph='·' ;;
    *)       rank=3; color=90; glyph='·' ;;
  esac
  age=""
  [ -n "$since" ] && age=$(fmt_age $((now - since)))
  t=$(printf '%s' "$title" | sed 's/^[^A-Za-z0-9]* *//')   # strip Claude's ✳ glyph
  dot="${esc}[${color}m${glyph}${esc}[0m"
  line=$(printf '%-16s %s  %-4s %s' "$tgt" "$dot" "$age" "$t")
  rows+="$rank$tab${since:-0}$tab$line"$'\n'
done < <(tmux list-panes -a \
  -f '#{||:#{!=:#{@claude_pane_state},},#{==:#{pane_current_command},claude}}' \
  -F "$fmt" 2>/dev/null)

# Sort by rank, then oldest-first; drop the two hidden sort columns.
rows=$(printf '%s' "$rows" | sed '/^$/d' | sort -t"$tab" -k1,1n -k2,2n | cut -f3-)

# Nothing running: show a note instead of flashing an empty popup.
if [ -z "$rows" ]; then
  printf '(no Claude sessions running — press Esc)\n' \
    | fzf --no-tmux +m --reverse --no-preview --header "Claude Sessions"
  exit 0
fi

switch_to() {
  local tgt session win
  tgt=$(printf '%s' "$1" | awk '{print $1}')   # session:window.pane
  session="${tgt%%:*}"
  win="${tgt#*:}"; win="${win%%.*}"
  tmux switch-client -t "$session"
  tmux select-window -t "$session:$win"
  tmux select-pane -t "$tgt"
}

legend="Enter: switch   ${esc}[91m●${esc}[0m blocked   ${esc}[93m●${esc}[0m working   ${esc}[94m●${esc}[0m done"

sel=$(printf '%s\n' "$rows" \
  | fzf --no-tmux --ansi +m --reverse --exit-0 \
    --header "$legend" \
    --preview 'tmux capture-pane -pe -t {1}' \
    --preview-window=right,60%) || exit 0

switch_to "$sel"
