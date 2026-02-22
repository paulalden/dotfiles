#!/bin/bash

source "$CONFIG_DIR/scripts/config.sh"

CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
CPU_INFO=$(ps -eo pcpu,user)
CPU_SYS=$(echo "$CPU_INFO" | grep -v $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")
CPU_USER=$(echo "$CPU_INFO" | grep $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")
CPU_PERCENT="$(echo "$CPU_SYS $CPU_USER" | awk '{printf "%.0f\n", ($1 + $2)*100}')"

COLOR=$(color_for_value "$CPU_PERCENT" 90 $RED 60 $ORANGE 30 $YELLOW 0 $GREEN)

sketchybar --set $NAME \
  label="$CPU_PERCENT%" \
  icon="" \
  icon.color=$COLOR \
  label.color=$COLOR
