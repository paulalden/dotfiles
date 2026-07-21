#!/usr/bin/env bash

# Live sidebar listing every Claude Code session in tmux.  (prefix a s)
#
# Runs inside the narrow left split created by claude-sidebar-toggle.sh and
# redraws every 2s from the same claude_list rows as the fzf switcher. Each
# session gets two numbered lines — state glyph + session:window.pane + age,
# then the pane title in grey — with a scrolling viewport when the list
# outgrows the pane.
#
# Keys:  ctrl-n/ctrl-p, arrows, wheel   move the cursor
#        Enter, click, 1-9    jump to the session and close the sidebar
#        j                    jump but keep the sidebar open
#        o                    peek: live preview popup of the pane (any key closes)
#        s                    silence the row (matches the popup's ctrl-s):
#                             grey z, no banner/escalation, auto-clears on
#                             its next state change
#        x                    clear the row's attention marker (stays listed)
#        /                    open the fuzzy switcher popup on top
#        ?                    help screen (legend + keys); any key returns
#        q, Esc               close the sidebar
#
# The selection is tracked by pane id so it follows its row through re-sorts;
# the sidebar pane itself never appears in the list (it runs bash, not
# claude, and carries no @claude_pane_state).

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$dir/claude-lib.sh"

TICK=2         # seconds between refreshes; matches the claude-tick.sh cadence
HDR_LINES=4    # pad + title + pad + rule
FOOT_LINES=1   # closing rule ("? help" lives in the title line)
GUTTER=13      # main row overhead: "  N G " + " " + 4-char age + right pad
TITLE_GUTTER=7 # title row indent (aligns under the label column)
EDGE=4         # combined side margins for the rules
MIN_AREA=3     # never let the viewport collapse entirely
ESC_WAIT=0.1   # secs to tell bare Esc from an arrow/mouse CSI; bigger values
               # survive laggy links but delay Esc-to-close by the same amount
claude_sgr "$grey11" GREY11        # tmux's own chrome grey — the rules
claude_sgr "$magenta" SEL_ACCENT   # the selection bar ▎
# Row width budget: $CLAUDE_SIDEBAR_WIDTH (claude-lib.sh, used by the toggle
# for the split) comfortably fits GUTTER + a typical session:window.pane
# target; the layout re-measures `tput cols` live, so resizing just
# re-truncates.

us=$(printf '\037')
esc=$(printf '\033')
ctrl_n=$(printf '\016')   # ctrl-n / ctrl-p: same motions as in the fzf popup
ctrl_p=$(printf '\020')

tput civis
printf '%s[?1002;1006h' "$esc"   # mouse: button events, SGR encoding
trap 'printf "%s[?1002;1006l" "$esc"; tput cnorm' EXIT
trap 'resized=1' WINCH

resized=0
cur=0
sel_id=""
top=0

grey="${esc}[${CLAUDE_GREY}m"
off="${esc}[0m"

# Approximate display width: chars + count of non-ASCII chars (each assumed
# double-width) — exact for ASCII and CJK/emoji, one column generous per
# accented latin char. Padding derives from this too, never from printf's
# %-*s, whose field widths count bytes and misalign multibyte text.
disp_w() {
  local t="${1//[[:ascii:]]/}"
  echo $((${#1} + ${#t}))
}

# trunc <string> <max> — cut to <max> display columns (per disp_w), appending
# … when cut. The … is budgeted at 2, exactly what disp_w will report for it,
# so disp_w(result) <= max always holds and padding derived from disp_w stays
# consistent (the … really renders 1 column, so a cut string may sit one
# column narrower than max — never wider).
trunc() {
  local s="$1" max="$2" w
  [ "$max" -lt 1 ] && return
  w=$(disp_w "$s")
  [ "$w" -le "$max" ] && { printf '%s' "$s"; return; }
  while s="${s%?}" && [ -n "$s" ]; do
    w=$(($(disp_w "$s") + 2))   # +2: what disp_w counts for the …
    [ "$w" -le "$max" ] && break
  done
  printf '%s…' "$s"
}

move_up() { [ "$cur" -gt 0 ] && cur=$((cur - 1)) && sel_id="${ids[cur]}"; }
move_down() { [ "$cur" -lt $((n - 1)) ] && cur=$((cur + 1)) && sel_id="${ids[cur]}"; }

# Jump to row $1 and close. If the pane died since the last refresh, stay
# open — the next tick drops the row.
jump() {
  local tgt="${tgts[$1]}"
  if claude_goto "$tgt"; then
    tmux kill-pane -t "$TMUX_PANE"
  else
    tmux display-message "Claude pane $tgt is gone"
  fi
}

# Live preview popup of row $1's pane (the `o` peek key). Any key closes it.
peek() {
  local tgt="${tgts[$1]}"
  tmux display-popup -T "#[align=centre] $tgt " -w 80% -h 75% -E \
    "$dir/claude-preview.sh '$tgt'"
}

# Jump to row $1 but keep the sidebar open (the `j` key).
visit() {
  claude_goto "${tgts[$1]}" || tmux display-message "Claude pane ${tgts[$1]} is gone"
}

# Select row $1 and jump — shared by Enter, mouse clicks, and digit keys.
pick() {
  cur=$1
  sel_id="${ids[cur]}"
  jump "$cur"
}

# Clear row $1's attention marker without visiting it (the `x` key). The
# pane stays listed while its claude lives; hooks re-mark it on the next
# event, so this only quiets the current done/urgent flag.
dismiss() {
  local id="${ids[$1]}"
  claude_clear_pane "$id"
  claude_rollup "$id"
}

# Silence/unsilence row $1 (the `s` key, matching the popup's ctrl-s): a
# conscious "not now". See claude_park_toggle in claude-lib.sh.
silence() {
  claude_park_toggle "${ids[$1]}"
}

# Validate a row index against the visible viewport, then select and jump —
# the single bounds check shared by mouse clicks and digit keys.
pick_at() {
  local idx="$1"
  [ "$n" -eq 0 ] && return
  { [ "$idx" -lt "$top" ] || [ "$idx" -ge $((top + visible)) ] || [ "$idx" -ge "$n" ]; } && return
  pick "$idx"
}

# Full-screen legend + key reference (the `?` key). Any key returns; the
# next loop pass repaints the list over it.
show_help() {
  local s color glyph name
  printf '%s[2J%s[H' "$esc" "$esc"
  printf '\n  %s[1mSidebar help%s\n\n' "$esc" "$off"
  for s in urgent working done parked ''; do
    read -r color glyph <<<"$(claude_style "$s")"
    case "$s" in
      urgent) name='blocked — needs a click' ;;
      working) name='working' ;;
      done) name='done — finished' ;;
      parked) name='silenced — quiet for now' ;;
      *) name='running, no marker' ;;
    esac
    printf '  %s[%sm%s%s  %s%s%s\n' "$esc" "$color" "$glyph" "$off" "$grey" "$name" "$off"
  done
  printf '\n'
  while IFS='|' read -r key act; do
    printf '  %-13s %s%s%s\n' "$key" "$grey" "$act" "$off"
  done <<'HELP'
^n/^p, wheel|move the cursor
enter, click|jump to session
1-9|jump to row N
j|jump, keep sidebar
o|peek: live preview
s|toggle silence
x|clear marker
/|fuzzy switcher
q, esc|close sidebar
HELP
  printf '\n  %sany key to go back%s' "$grey" "$off"
  read -rsn1
}

# After ESC [ <: consume the SGR mouse report "b;x;yM|m" and act on it.
# Left-press on a row jumps; the wheel moves the cursor.
read_mouse() {
  local seq="" c b rest y
  while read -rsn1 -t 0.05 c; do
    seq+="$c"
    case "$c" in M | m) break ;; esac
  done
  case "$seq" in *M) ;; *) return ;; esac   # act on press only, not release
  b="${seq%%;*}"
  rest="${seq#*;}"
  y="${rest#*;}"
  y="${y%M}"
  case "$b" in
    64) move_up ;;
    65) move_down ;;
    0)
      [ "$y" -lt "$y0" ] && return
      pick_at $((top + (y - y0) / 2))
      ;;
  esac
}

while :; do
  # Build the rows.
  ids=()
  tgts=()
  states=()
  labels=()
  ages=()
  titles=()
  cols=$(tput cols)
  lines=$(tput lines)
  w=$((cols - GUTTER))
  [ "$w" -lt 4 ] && w=4
  while IFS="$us" read -r id state parked since age tgt title; do
    ids+=("$id")
    tgts+=("$tgt")
    [ "$parked" = 1 ] && state=parked   # pseudo-state: grey z, sorted last
    states+=("$state")
    # Pad by display width (disp_w), not printf's byte-counted %-*s. The
    # outer trunc re-cuts on absurdly narrow panes where the clamped $w
    # alone would overflow; the age renders separately (grey) at draw time.
    t=$(trunc "$tgt" "$w")
    pad=$((w - $(disp_w "$t")))
    [ "$pad" -lt 0 ] && pad=0
    labels+=("$(trunc "$(printf '%s%*s' "$t" "$pad" '')" $((cols - 11)))")
    ages+=("$age")
    titles+=("$(trunc "$title" $((cols - TITLE_GUTTER - 1)))")
  done < <(claude_list)
  n=${#ids[@]}

  # Re-anchor the cursor to the previously selected pane, else clamp.
  if [ -n "$sel_id" ] && [ "$n" -gt 0 ]; then
    for i in "${!ids[@]}"; do
      [ "${ids[i]}" = "$sel_id" ] && { cur=$i; break; }
    done
  fi
  [ "$cur" -ge "$n" ] && cur=$((n - 1))
  [ "$cur" -lt 0 ] && cur=0
  sel_id=""
  [ "$n" -gt 0 ] && sel_id="${ids[cur]}"

  # Viewport: rows live between header and footer, 2 lines per row. Scroll
  # to keep the cursor visible; ↑/↓ markers eat a line each, so re-shrink
  # the page until it stabilises.
  area=$((lines - HDR_LINES - FOOT_LINES))
  [ "$area" -lt "$MIN_AREA" ] && area=$MIN_AREA
  page=$((area / 2))
  [ "$page" -lt 1 ] && page=1
  [ "$top" -gt $((n - 1)) ] && top=$((n - 1))
  [ "$top" -lt 0 ] && top=0
  [ "$cur" -lt "$top" ] && top=$cur
  [ "$cur" -ge $((top + page)) ] && top=$((cur - page + 1))
  up=0
  down=0
  for _ in 1 2; do
    [ "$top" -gt 0 ] && up=1
    down=0
    [ $((top + page)) -lt "$n" ] && down=1
    newpage=$(((area - up - down) / 2))
    [ "$newpage" -lt 1 ] && newpage=1
    [ "$newpage" -eq "$page" ] && break
    page=$newpage
    [ "$cur" -ge $((top + page)) ] && top=$((cur - page + 1))
  done
  visible=$((n - top))
  [ "$visible" -gt "$page" ] && visible=$page
  y0=$((HDR_LINES + 1 + up))   # screen line of the first visible row (mouse)

  rule=$(printf '%*s' $((cols - EDGE)) '' | sed 's/ /─/g')

  # Draw: cursor-home, every line ends in clear-to-eol, clear-below at the
  # end. Never `clear` — that flickers.
  printf '%s[H' "$esc"
  printf '%s[K\n' "$esc"
  # "  Claude sessions (N)" left, "? help " right-aligned as a suffix.
  hpad=$((cols - 20 - ${#n} - 8))
  [ "$hpad" -lt 1 ] && hpad=1
  printf '  %s[1mClaude sessions%s %s(%s)%s%*s%s? help %s%s[K\n' \
    "$esc" "$off" "$grey" "$n" "$off" "$hpad" '' "$grey" "$off" "$esc"
  printf '%s[K\n' "$esc"
  printf '  %s[%sm%s%s%s[K\n' "$esc" "$GREY11" "$rule" "$off" "$esc"
  if [ "$n" -eq 0 ]; then
    printf '  %s(no Claude sessions)%s%s[K\n' "$grey" "$off" "$esc"
  else
    [ "$up" -eq 1 ] && printf '  %s↑ %s more%s%s[K\n' "$grey" "$top" "$off" "$esc"
    for ((i = top; i < top + visible; i++)); do
      read -r color glyph <<<"$(claude_style "${states[i]}")"
      num=' '
      [ $((i - top)) -lt 9 ] && num=$((i - top + 1))
      if [ "$i" -eq "$cur" ]; then
        # Selection: a green left bar in the padding column; the row itself
        # renders exactly like an unselected one.
        printf '%s[%sm▎%s %s%s%s %s[%sm%s%s[0m %s %s%4s%s%s[K\n' \
          "$esc" "$SEL_ACCENT" "$off" "$grey" "$num" "$off" "$esc" "$color" "$glyph" "$esc" \
          "${labels[i]}" "$grey" "${ages[i]}" "$off" "$esc"
      else
        printf '  %s%s%s %s[%sm%s%s[0m %s %s%4s%s%s[K\n' \
          "$grey" "$num" "$off" "$esc" "$color" "$glyph" "$esc" "${labels[i]}" "$grey" "${ages[i]}" "$off" "$esc"
      fi
      if [ "$i" -eq "$cur" ]; then
        # The bar carries down the entry's second line too.
        printf '%s[%sm▎%s%*s%s%s%s%s[K\n' \
          "$esc" "$SEL_ACCENT" "$off" "$((TITLE_GUTTER - 2))" '' "$grey" "${titles[i]}" "$off" "$esc"
      else
        printf '%*s%s%s%s%s[K\n' "$((TITLE_GUTTER - 1))" '' "$grey" "${titles[i]}" "$off" "$esc"
      fi
    done
    [ "$down" -eq 1 ] && printf '  %s↓ %s more%s%s[K\n' "$grey" "$((n - top - visible))" "$off" "$esc"
  fi

  # Footer: just the closing rule. The full key/legend reference lives
  # behind `?` (show_help), hinted at in the title line.
  printf '  %s[%sm%s%s%s[K' "$esc" "$GREY11" "$rule" "$off" "$esc"
  printf '%s[J' "$esc"

  # Wait for a key; the timeout is the refresh tick.
  key=""
  if read -rsn1 -t "$TICK" key; then
    case "$key" in
      "$ctrl_n") move_down ;;
      "$ctrl_p") move_up ;;
      q) exit 0 ;;
      j) [ "$n" -gt 0 ] && visit "$cur" ;;
      o) [ "$n" -gt 0 ] && peek "$cur" ;;
      s) [ "$n" -gt 0 ] && silence "$cur" ;;
      x) [ "$n" -gt 0 ] && dismiss "$cur" ;;
      '?') show_help ;;
      /)
        if command -v fzf >/dev/null 2>&1; then
          tmux display-popup -T '#[align=centre] Claude Sessions ' -E -w 70% -h 60% \
            "$dir/fzf-popup.sh $dir/fzf-claude.sh"
        else
          tmux display-message 'fzf not installed — switcher unavailable'
        fi
        ;;
      [1-9]) pick_at $((top + key - 1)) ;;
      "") [ "$n" -gt 0 ] && jump "$cur" ;;   # Enter
      "$esc")
        if ! read -rsn1 -t "$ESC_WAIT" k1; then
          exit 0   # bare Esc closes; arrows/mouse continue below
        fi
        [ "$k1" = "$esc" ] && exit 0   # rapid double-tap Esc closes too
        if [ "$k1" = '[' ]; then
          read -rsn1 -t "$ESC_WAIT" k2 || k2=""
          case "$k2" in
            A) move_up ;;
            B) move_down ;;
            '<') read_mouse ;;
          esac
        fi
        ;;
    esac
  fi
  if [ "$resized" -eq 1 ]; then
    resized=0
    sleep 0.1   # let tmux finish the resize before re-measuring the pane
    # (worst case the old layout lingers one tick if the signal landed
    # mid-read; the next pass always re-measures)
  fi
done
