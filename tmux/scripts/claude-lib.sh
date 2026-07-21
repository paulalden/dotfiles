#!/usr/bin/env bash

# Shared helpers for the Claude-in-tmux status feature.
# Sourced by claude-notify.sh, claude-tick.sh, claude-jump.sh,
# claude-clear-done.sh, fzf-claude.sh, claude-sidebar.sh,
# claude-sidebar-toggle.sh.
#
# State lives in per-PANE tmux options (keyed by pane id, so it vanishes when a
# pane closes):
#   @claude_pane_state  working|urgent|done   (source of truth)
#   @claude_since       epoch seconds the current state began
#   @claude_notified    "1" once the desktop alert fired for this urgent spell
# and a per-WINDOW rollup that drives the status-bar dot:
#   @claude_alert       working|urgent|done   (max severity of the window's panes)

# Severity rank: higher wins the window rollup. urgent > working > done.
claude_rank() {
  case "$1" in
    urgent) echo 3 ;;
    working) echo 2 ;;
    done) echo 1 ;;
    *) echo 0 ;;
  esac
}

# Is a `claude` process alive on this pane's tty?
# Only the command word of each process counts (basename of argv[0]), so a
# stray "claude" argument — `git commit -m 'claude fix'`, `grep claude x` —
# never reads as a live session. Scanning every process on the tty (not just
# the foreground one) still catches claude mid tool-call, and the claude
# child of a `zsh -c "claude …"` wrapper shows up on the same tty under its
# own argv[0]. This is the reconcile-on-read check: a dead pane drops out.
claude_alive() {
  local tty="$1"
  [ -n "$tty" ] || return 1
  ps -t "$tty" -o command= 2>/dev/null | awk '
    { n = split($1, p, "/"); if (p[n] == "claude") { found = 1; exit } }
    END { exit found ? 0 : 1 }'
}

# Recompute a window's @claude_alert rollup from its panes' @claude_pane_state.
# Arg: any target the window resolves from (a pane id or a window id).
claude_rollup() {
  local target="$1" best="" best_rank=0 state rank
  while IFS= read -r state; do
    [ -n "$state" ] || continue
    rank=$(claude_rank "$state")
    if [ "$rank" -gt "$best_rank" ]; then
      best_rank=$rank
      best=$state
    fi
  done < <(tmux list-panes -t "$target" -F '#{@claude_pane_state}' 2>/dev/null)

  if [ -n "$best" ]; then
    tmux set-option -w -t "$target" @claude_alert "$best" 2>/dev/null || true
  else
    tmux set-option -uw -t "$target" @claude_alert 2>/dev/null || true
  fi
}

# The Nord palette, from the shared source of truth (dual-parsed by tmux
# and bash), so the list renderers match the status-bar dots exactly.
_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$_lib_dir/../config/nord.conf"

# claude_sgr <#rrggbb> <varname> — store the hex color as SGR truecolor
# foreground params in <varname>. printf -v: no subshell per lookup.
claude_sgr() {
  local h="${1#\#}"
  printf -v "$2" '38;2;%d;%d;%d' "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}

claude_sgr "$red" CLAUDE_RED
claude_sgr "$yellow" CLAUDE_YELLOW
claude_sgr "$blue" CLAUDE_BLUE
claude_sgr "$grey9" CLAUDE_GREY   # chrome / no-state

# Width of the sidebar split. Lives here so claude-sidebar-toggle.sh (which
# creates the pane) and claude-sidebar.sh (whose row budget assumes it) share
# one constant instead of coupling through prose comments.
CLAUDE_SIDEBAR_WIDTH=34

# Map a pane state to its list styling, echoed as "<sgr-params> <glyph>".
# "parked" is a pseudo-state consumers pass when the parked flag is set.
claude_style() {
  case "$1" in
    urgent) echo "$CLAUDE_RED ●" ;;
    done) echo "$CLAUDE_BLUE ●" ;;
    working) echo "$CLAUDE_YELLOW ●" ;;
    parked) echo "$CLAUDE_GREY z" ;;
    *) echo "$CLAUDE_GREY ○" ;;
  esac
}

# Unset a pane's attention options (state / since / notified / parked).
# Callers decide when to re-run claude_rollup — some batch clears first.
claude_clear_pane() {
  local pane="$1"
  tmux set-option -up -t "$pane" @claude_pane_state 2>/dev/null || true
  tmux set-option -up -t "$pane" @claude_since 2>/dev/null || true
  tmux set-option -up -t "$pane" @claude_notified 2>/dev/null || true
  tmux set-option -up -t "$pane" @claude_parked 2>/dev/null || true
}

# Toggle a pane's parked ("silenced") flag — `s` in the sidebar, ctrl-s in
# the switcher. Silenced panes stay listed (grey z, sorted last) but are
# excluded from the banner, desktop escalation, and the jump key — a
# conscious "not now". The flag clears itself on the pane's next state
# transition (claude-notify.sh): silencing applies to the current spell only.
claude_park_toggle() {
  local pane="$1"
  if [ "$(tmux show-options -qvp -t "$pane" @claude_parked 2>/dev/null)" = 1 ]; then
    tmux set-option -up -t "$pane" @claude_parked 2>/dev/null || true
  else
    tmux set-option -p -t "$pane" @claude_parked 1 2>/dev/null || true
  fi
}

# Colored state legend for the list renderers — "● blocked  ○ done  · working"
# in claude_list's sort order, so every view teaches the same model. $1
# (optional) is an SGR param string to tint the state names; glyphs always
# take their state color.
claude_legend() {
  local name_sgr="$1" esc s color glyph name out=""
  esc=$(printf '\033')
  for s in urgent done working; do
    read -r color glyph <<<"$(claude_style "$s")"
    case "$s" in urgent) name=blocked ;; *) name=$s ;; esac
    if [ -n "$name_sgr" ]; then
      out+="${esc}[${color}m${glyph}${esc}[0m ${esc}[${name_sgr}m${name}${esc}[0m  "
    else
      out+="${esc}[${color}m${glyph}${esc}[0m ${name}  "
    fi
  done
  printf '%s' "${out%  }"
}

# List live Claude panes, one row per pane, sorted attention-first
# (urgent > done > working > other > parked) then oldest-first. Fields are US
# (\037) separated so empty ones survive `read`:
#   pane_id  state  parked  since  age  session:window.pane  title
# Dead panes are dropped (reconcile-on-read via claude_alive); `since`/`age`/
# `parked` may be empty; the title has Claude's leading ✳ glyph stripped.
claude_list() {
  local us tab now fmt rows id state parked since tty tgt title rank age t
  us=$(printf '\037')
  tab=$(printf '\t')
  now=$(date +%s)
  fmt="#{pane_id}$us#{@claude_pane_state}$us#{@claude_parked}$us#{@claude_since}$us#{pane_tty}$us"
  fmt+="#{session_name}:#{window_index}.#{pane_index}$us#{pane_title}"

  rows=""
  while IFS="$us" read -r id state parked since tty tgt title; do
    claude_alive "$tty" || continue
    case "$state" in
      urgent) rank=0 ;;
      done) rank=1 ;;
      working) rank=2 ;;
      *) rank=3 ;;
    esac
    [ "$parked" = 1 ] && rank=4   # consciously deferred -> bottom of the list
    age=""
    [ -n "$since" ] && age=$(fmt_age $((now - since)))
    # tr strips any literal US byte from the title so it can't desync the
    # field split in consumers; sed drops Claude's leading ✳ glyph.
    t=$(printf '%s' "$title" | tr -d '\037' | sed 's/^[^A-Za-z0-9]* *//')
    rows+="$rank$tab${since:-0}$tab$id$us$state$us$parked$us$since$us$age$us$tgt$us$t"$'\n'
  done < <(tmux list-panes -a \
    -f '#{||:#{!=:#{@claude_pane_state},},#{==:#{pane_current_command},claude}}' \
    -F "$fmt" 2>/dev/null)

  # Sort by rank, then oldest-first; drop the two hidden sort columns.
  printf '%s' "$rows" | sed '/^$/d' | sort -t"$tab" -k1,1n -k2,2n | cut -f3-
}

# Jump the attached client to a pane, given a session:window.pane target.
# Fails (non-zero) when the target vanished between listing and jumping, so
# callers can keep their UI open instead of switching into thin air. The
# existence check runs BEFORE any client movement — a stale target must never
# strand the client half-switched in the wrong session or window.
claude_goto() {
  local tgt="$1" session win
  session="${tgt%%:*}"
  win="${tgt#*:}"
  win="${win%%.*}"
  tmux list-panes -t "$tgt" -F '' >/dev/null 2>&1 || return 1
  tmux switch-client -t "$session" 2>/dev/null \
    && tmux select-window -t "$session:$win" 2>/dev/null \
    && tmux select-pane -t "$tgt" 2>/dev/null
}

# Format an age in seconds as a compact string: 45s, 3m, 2h.
fmt_age() {
  local s="$1"
  [ -n "$s" ] && [ "$s" -ge 0 ] 2>/dev/null || { echo ""; return; }
  if [ "$s" -lt 60 ]; then
    echo "${s}s"
  elif [ "$s" -lt 3600 ]; then
    echo "$((s / 60))m"
  else
    echo "$((s / 3600))h"
  fi
}
