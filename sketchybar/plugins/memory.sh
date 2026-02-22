#!/bin/bash

source "$CONFIG_DIR/scripts/config.sh"

TOTAL_MEM=$(sysctl -n hw.memsize)
TOTAL_MEM_MB=$((TOTAL_MEM / 1024 / 1024))

PAGE_SIZE=$(sysctl -n hw.pagesize)
VM_STAT=$(vm_stat)

ACTIVE=$(echo "$VM_STAT" | awk '/Pages active/ {gsub(/\./, "", $3); print $3}')
WIRED=$(echo "$VM_STAT" | awk '/Pages wired/ {gsub(/\./, "", $4); print $4}')
COMPRESSED=$(echo "$VM_STAT" | awk '/Pages occupied by compressor/ {gsub(/\./, "", $5); print $5}')

USED_PAGES=$((ACTIVE + WIRED + COMPRESSED))
USED_MB=$((USED_PAGES * PAGE_SIZE / 1024 / 1024))
MEM_PERCENT=$((USED_MB * 100 / TOTAL_MEM_MB))

case "${MEM_PERCENT}" in
9[0-9] | 100)
  COLOR=$RED
  ;;
[7-8][0-9])
  COLOR=$ORANGE
  ;;
[5-6][0-9])
  COLOR=$YELLOW
  ;;
[0-4][0-9] | [0-9])
  COLOR=$GREEN
  ;;
*)
  COLOR=$RED
  ;;
esac

sketchybar --set $NAME \
  label="${MEM_PERCENT}%" \
  icon="󱤓" \
  icon.color=$COLOR \
  label.color=$COLOR
