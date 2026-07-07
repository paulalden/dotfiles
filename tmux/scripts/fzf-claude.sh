#!/usr/bin/env bash

# Switch between Claude Code sessions running in tmux.
#
# Lists every pane whose foreground process is `claude`, tagged with the
# attention state set by scripts/claude-notify.sh (the @claude_alert window
# option):
#   ●  needs a click  (permission / question)
#   ○  finished, waiting for you
#   ·  working
# Sorted attention-first. Enter jumps to that session / window / pane.

tab=$(printf '\t')

fmt="#{?#{==:#{@claude_alert},urgent},0,#{?#{==:#{@claude_alert},done},1,2}}$tab"
fmt+="#{session_name}:#{window_index}.#{pane_index}$tab"
fmt+="#{?#{==:#{@claude_alert},urgent},●,#{?#{==:#{@claude_alert},done},○,·}}$tab"
fmt+="#{pane_title}"

rows=$(tmux list-panes -a -f '#{==:#{pane_current_command},claude}' -F "$fmt" \
  | sort -k1,1 \
  | awk -F'\t' 'BEGIN{e=sprintf("%c",27)} { c=($1==0)?"91":($1==1)?"94":"93"; dot=e"["c"m●"e"[0m"; t=$4; sub(/^[^A-Za-z0-9]+ +/,"",t); printf "%-14s %s  %s\n", $2, dot, t }')

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

# Exactly one session: jump straight there, no menu.
if [ "$(printf '%s\n' "$rows" | grep -c .)" -eq 1 ]; then
  switch_to "$rows"
  exit 0
fi

esc=$(printf '\033')
legend="Enter: switch   ${esc}[91m●${esc}[0m blocked   ${esc}[93m●${esc}[0m working   ${esc}[94m●${esc}[0m done"

sel=$(printf '%s\n' "$rows" \
  | fzf --no-tmux --ansi +m --reverse --exit-0 --no-preview \
    --header "$legend") || exit 0

switch_to "$sel"
