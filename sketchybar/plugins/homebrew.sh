#!/bin/bash

source "$CONFIG_DIR/scripts/config.sh"

COUNT=$(/opt/homebrew/bin/brew outdated --quiet | wc -l | tr -d ' ')
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

sketchybar --set $NAME icon= label="$COUNT" icon.color=$COLOR label.color=$COLOR