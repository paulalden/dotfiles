#!/usr/bin/env bash

# Source the active theme. Its name lives in ~/.config/theme (written by
# theme_switcher.sh); resolving it here means switching themes never edits a
# git-tracked file.
theme="$(cat "$HOME/.config/theme" 2>/dev/null || echo nord)"
case "$theme" in
  2049) source "$CONFIG_DIR/scripts/config-2049.sh" ;;
  evergreen) source "$CONFIG_DIR/scripts/config-evergreen.sh" ;;
  *) source "$CONFIG_DIR/scripts/config-nord.sh" ;;
esac
