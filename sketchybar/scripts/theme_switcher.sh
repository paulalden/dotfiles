#!/bin/bash

DOTFILES="$HOME/Personal/Repos/dotfiles"
THEME_FILE="$HOME/.config/theme"

# Read current theme, default to nord
current_theme=$(cat "$THEME_FILE" 2>/dev/null || echo "nord")

# Toggle
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

# --- Sketchybar ---
if [ "$new_theme" = "2049" ]; then
  sed -i '' 's|config-nord\.sh|config-2049.sh|' "$DOTFILES/sketchybar/scripts/config.sh"
else
  sed -i '' 's|config-2049\.sh|config-nord.sh|' "$DOTFILES/sketchybar/scripts/config.sh"
fi

# --- Kitty ---
if [ "$new_theme" = "2049" ]; then
  sed -i '' 's|include ./themes/nord.conf|include ./themes/2049.conf|' "$DOTFILES/kitty/kitty.conf"
else
  sed -i '' 's|include ./themes/2049.conf|include ./themes/nord.conf|' "$DOTFILES/kitty/kitty.conf"
fi
kill -SIGUSR1 $(pgrep -f kitty) 2>/dev/null

# --- Tmux ---
if [ "$new_theme" = "2049" ]; then
  sed -i '' 's|/theme\.conf"|/theme-2049.conf"|; s|/theme-nord\.conf"|/theme-2049.conf"|' "$DOTFILES/tmux/tmux.conf"
else
  sed -i '' 's|/theme-2049\.conf"|/theme.conf"|' "$DOTFILES/tmux/tmux.conf"
fi
tmux source-file "$HOME/.config/tmux/tmux.conf" 2>/dev/null

# --- Neovim ---
# Send colorscheme command to all running Neovim instances via nvim --server
if [ "$new_theme" = "2049" ]; then
  nvim_colorscheme="2049"
else
  nvim_colorscheme="onenord"
fi

# Find all Neovim server sockets (macOS stores them in /var/folders)
for sock in $(find /var/folders -name "nvim.*.0" -type s 2>/dev/null); do
  nvim --server "$sock" --remote-send "<Cmd>colorscheme $nvim_colorscheme<CR>" 2>/dev/null
done

# --- Reload Sketchybar last ---
sketchybar --reload 2>/dev/null

echo "$new_theme"
