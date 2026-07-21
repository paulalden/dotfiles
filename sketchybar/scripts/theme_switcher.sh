#!/usr/bin/env bash

DOTFILES="$HOME/Personal/repos/dotfiles"
THEME_FILE="$HOME/.config/theme"

# Read current theme, default to nord
current_theme=$(cat "$THEME_FILE" 2>/dev/null || echo "nord")

if [ "$1" = "toggle" ]; then
  if [ "$current_theme" = "nord" ]; then
    new_theme="2049"
  else
    new_theme="nord"
  fi
elif [ -n "$1" ]; then
  new_theme="$1"
else
  echo "$current_theme"
  exit 0
fi

echo "$new_theme" > "$THEME_FILE"

# --- Theme mappings ---
case "$new_theme" in
  2049)
    sketchybar_config="config-2049.sh"
    kitty_theme="2049.conf"
    tmux_theme="theme-2049.conf"
    nvim_colorscheme="2049"
    ;;
  evergreen)
    sketchybar_config="config-evergreen.sh"
    kitty_theme="evergreen.conf"
    tmux_theme="theme-evergreen.conf"
    nvim_colorscheme="2049"
    ;;
  *)
    sketchybar_config="config-nord.sh"
    kitty_theme="nord.conf"
    tmux_theme="theme.conf"
    nvim_colorscheme="onenord"
    ;;
esac

# Each tool loads its theme from an untracked override file (or, for
# sketchybar, straight from $THEME_FILE), so switching never dirties a tracked
# file. $sketchybar_config is unused here — config.sh self-resolves.

# nord is the base default already loaded by kitty.conf / tmux.conf, so an
# override that re-loaded it would double-include (kitty treats that as an
# error). For nord we remove the override — a missing one is tolerated
# (kitty ignores it, tmux uses source-file -q); other themes get written.

# --- Kitty --- untracked include override (themes/active.conf)
if [ "$new_theme" = "nord" ]; then
  rm -f "$DOTFILES/kitty/themes/active.conf"
else
  printf 'include %s\n' "$kitty_theme" > "$DOTFILES/kitty/themes/active.conf"
fi
kill -SIGUSR1 $(pgrep -f kitty) 2>/dev/null

# --- Tmux --- untracked source override (config/theme-active.conf)
if [ "$new_theme" = "nord" ]; then
  rm -f "$DOTFILES/tmux/config/theme-active.conf"
else
  printf 'source-file ~/.config/tmux/config/%s\n' "$tmux_theme" \
    > "$DOTFILES/tmux/config/theme-active.conf"
fi
tmux source-file "$HOME/.config/tmux/tmux.conf" 2>/dev/null

# --- Neovim ---
for sock in $(find /var/folders -name "nvim.*.0" -type s 2>/dev/null); do
  nvim --server "$sock" --remote-send "<Cmd>colorscheme $nvim_colorscheme<CR>" 2>/dev/null
done

# --- Reload Sketchybar last ---
sketchybar --reload 2>/dev/null

echo "$new_theme"
