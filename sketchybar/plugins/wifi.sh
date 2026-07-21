#!/usr/bin/env bash

# https://snelson.us/2024/09/determining-a-macs-ssid-like-an-animal/

source "$CONFIG_DIR/scripts/config.sh"

ICON_DISCONNECTED="󰖪"
ICON_CONNECTED="󰖩"

update() {
  ssid=$(ipconfig getsummary $(networksetup -listallhardwareports |
    awk '/Hardware Port: Wi-Fi/{getline; print $2}') |
    awk -F ' SSID : ' '/ SSID : / {print $2}')

  if [ -z "$ssid" ]; then
    LABEL="Disconnected"
    ICON=$ICON_DISCONNECTED
    COLOR=$RED
  else
    LABEL=$ssid
    ICON=$ICON_CONNECTED
    COLOR=$GREEN
  fi

  sketchybar --set $NAME \
    icon="$ICON" \
    label="$LABEL" \
    icon.color="$COLOR" \
    label.color="$COLOR" \
    icon.font="$FONT:Bold:23.0" \
    label.font="$FONT:Bold:13.0"
}

click() {
  CURRENT_WIDTH="$(sketchybar --query $NAME | jq -r .label.width)"

  WIDTH=0
  if [ "$CURRENT_WIDTH" -eq "0" ]; then
    WIDTH=dynamic
  fi

  sketchybar --animate sin 20 --set $NAME label.width="$WIDTH"
}

case "$SENDER" in
"wifi_change")
  update
  ;;
"mouse.clicked")
  click
  ;;
esac
