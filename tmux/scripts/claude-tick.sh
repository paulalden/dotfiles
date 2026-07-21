#!/usr/bin/env bash

# Runs every ~2s from status-right (#()). Sweeps the panes carrying Claude
# state, then prints the bottom-right "needs you" banner. Three side jobs:
#   1. clean    - clear state for panes whose claude has died (no SessionEnd)
#   2. rollup   - refresh the window dot for any window it cleaned
#   3. escalate - macOS-notify urgent panes untouched for >= ALERT_AFTER seconds
# All side-effects are idempotent (the @claude_notified flag de-dups alerts), so
# it is safe to run once per redraw per attached client.

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$dir/claude-lib.sh"

ALERT_AFTER=60   # seconds a pane must stay urgent before a desktop alert

now=$(date +%s)
tab=$(printf '\t')
us=$(printf '\037')   # field sep for tmux -F: non-whitespace, so empty fields survive `read`

# pane  window  tty  state  since  notified  parked  on-screen
fmt="#{pane_id}$us#{window_id}$us#{pane_tty}$us#{@claude_pane_state}$us"
fmt+="#{@claude_since}$us#{@claude_notified}$us#{@claude_parked}$us"
fmt+="#{&&:#{session_attached},#{window_active}}"   # window is on an attached client's screen

dirty=""          # windows we cleaned, recomputed after the sweep
urgent_lines=""   # "since<TAB>name" per live urgent pane, for the banner

while IFS="$us" read -r pane win tty state since notified parked onscreen; do
  [ -n "$state" ] || continue

  # 1. Clean: claude gone from this pane -> drop its state, mark the window.
  if ! claude_alive "$tty"; then
    claude_clear_pane "$pane"
    dirty+="$win"$'\n'
    continue
  fi

  # Parked panes are a conscious "not now": no banner, no escalation. The
  # flag clears on the pane's next state transition (claude-notify.sh).
  [ "$parked" = 1 ] && continue

  [ "$state" = urgent ] || continue

  # Skip sessions you can already see (active window of an attached client) --
  # no banner and no alert for a pane that's on your screen.
  [ "$onscreen" = 1 ] && continue

  name=$(tmux display-message -p -t "$pane" '#{pane_title}' 2>/dev/null \
    | sed 's/^[^A-Za-z0-9]* *//; s/["\\]//g')
  since=${since:-$now}

  # 3. Escalate: blocked long enough and not yet alerted.
  age=$((now - since))
  if [ "$notified" != 1 ] && [ "$age" -ge "$ALERT_AFTER" ]; then
    osascript -e "display notification \"${name:-A session} needs your input\" with title \"Claude\"" >/dev/null 2>&1
    tmux set-option -p -t "$pane" @claude_notified 1 2>/dev/null || true
  fi

  urgent_lines+="$since$tab$name"$'\n'
done < <(tmux list-panes -a -F "$fmt" 2>/dev/null)

# 2. Rollup: refresh the dot on every window we cleaned.
for win in $(printf '%s' "$dirty" | sort -u); do
  [ -n "$win" ] && claude_rollup "$win"
done

# Banner: oldest-blocked first, with its age; "+N" when several are blocked.
[ -n "$urgent_lines" ] || exit 0
count=$(printf '%s' "$urgent_lines" | grep -c .)
first=$(printf '%s' "$urgent_lines" | sort -t"$tab" -k1,1n | head -1)
since=$(printf '%s' "$first" | cut -f1)
name=$(printf '%s' "$first" | cut -f2- | cut -c1-28)
age=$(fmt_age $((now - since)))
[ -n "$age" ] && name="$name ($age)"
[ "$count" -gt 1 ] && name="$name +$((count - 1))"
printf '#[bg=%s,fg=%s,bold] 🔔 %s needs you #[bg=default,fg=default]  ' "$orange" "$bg" "$name"
