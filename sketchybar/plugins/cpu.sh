#!/bin/bash

source "$CONFIG_DIR/scripts/config.sh"

CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
CPU_PERCENT=$(ps -Ao pcpu= | awk -v cores="$CORE_COUNT" '{sum+=$1} END {printf "%.0f", sum/cores}')

COLOR=$(color_for_value "$CPU_PERCENT" 90 $RED 60 $ORANGE 30 $YELLOW 0 $GREEN)

sketchybar --set $NAME \
  label="$CPU_PERCENT%" \
  icon="" \
  icon.color=$COLOR \
  label.color=$COLOR
