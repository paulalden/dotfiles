#!/bin/sh

source "$CONFIG_DIR/scripts/config.sh"

# Check if the built-in camera is actively streaming via IOKit
# Works without TCC/camera permissions on Apple Silicon Macs
if ioreg -c AppleH13CamIn -rd 2 2>/dev/null | grep -q '"FrontCameraStreaming" = Yes'; then
  sketchybar --set "$NAME" \
    icon="󰖠" \
    icon.color=$RED \
    label.drawing=off \
    drawing=on
else
  sketchybar --set "$NAME" drawing=off
fi