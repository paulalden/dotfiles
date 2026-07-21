#!/usr/bin/env bash

source "$CONFIG_DIR/scripts/config.sh"

export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:$PATH"
export HOMEBREW_DOWNLOAD_CONCURRENCY=8
export HOMEBREW_NO_ENV_HINTS=1

BREW=/opt/homebrew/bin/brew

# SketchyBar runs under launchd with SIGCHLD set to SIG_IGN, which the plugin
# inherits. That makes `brew outdated` crash while version-checking auto-updating
# casks: brew spawns `plutil` to read the app's Info.plist, the kernel auto-reaps
# the child before brew can read its exit status, and brew dies with
# "undefined method 'exitstatus' for nil" (empty output -> a wrong count of 0).
# Run brew via a tiny perl wrapper that resets SIGCHLD to its default first.
brew_safe() { /usr/bin/perl -e '$SIG{CHLD}="DEFAULT"; exec @ARGV' "$BREW" "$@"; }

# Refresh Homebrew's catalog at most once every 10 minutes so `brew outdated`
# learns about new upstream versions. (Homebrew's own auto-update is throttled
# to ~24h, which makes the count under-report between refreshes.)
STAMP="${HOME}/.cache/sketchybar/brew_update.stamp"
mkdir -p "$(dirname "$STAMP")"
if [ ! -f "$STAMP" ] || [ -n "$(find "$STAMP" -mmin +10 2>/dev/null)" ]; then
  brew_safe update --quiet >/dev/null 2>&1
  touch "$STAMP"
fi

# Count outdated against the local catalog (fast, deterministic, no network).
PINNED=$(HOMEBREW_NO_AUTO_UPDATE=1 brew_safe list --pinned --quiet 2>/dev/null)
if [ -n "$PINNED" ]; then
  OUTDATED=$(HOMEBREW_NO_AUTO_UPDATE=1 brew_safe outdated --quiet 2>/dev/null | grep -vxF "$PINNED")
else
  OUTDATED=$(HOMEBREW_NO_AUTO_UPDATE=1 brew_safe outdated --quiet 2>/dev/null)
fi

COUNT=$(echo "$OUTDATED" | grep -c .)

COLOR=$RED

case "${COUNT}" in
[3-5][0-9])
  COLOR=$RED
  ;;
[1-2][0-9])
  COLOR=$ORANGE
  ;;
[1-9])
  COLOR=$YELLOW
  ;;
*)
  COLOR=$FG
  ;;
esac

sketchybar --set "$NAME" icon= label="$COUNT" icon.color="$COLOR" label.color="$COLOR"

# Remove old popup items
sketchybar --remove '/homebrew.pkg\..*/' 2>/dev/null

# Add popup items for each outdated package
if [ "$COUNT" -gt 0 ]; then
  INDEX=0
  while IFS= read -r pkg; do
    if [ -n "$pkg" ]; then
      sketchybar --add item "homebrew.pkg.$INDEX" popup.homebrew \
        --set "homebrew.pkg.$INDEX" \
        icon= \
        icon.color=$YELLOW \
        icon.font="$FONT:Bold:14.0" \
        icon.padding_left=10 \
        label="$pkg" \
        label.font="$FONT:Regular:13.0" \
        label.color=$FG \
        label.padding_right=10
      INDEX=$((INDEX + 1))
    fi
  done <<< "$OUTDATED"
fi