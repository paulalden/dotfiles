#!/bin/bash

DOTFILES="$HOME/Personal/Repos/dotfiles"
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

# --- Sketchybar ---
sed -i '' "s|config-[a-z0-9-]*\.sh|$sketchybar_config|" "$DOTFILES/sketchybar/scripts/config.sh"

# --- Kitty ---
sed -i '' "s|include ./themes/.*\.conf|include ./themes/$kitty_theme|" "$DOTFILES/kitty/kitty.conf"
kill -SIGUSR1 $(pgrep -f kitty) 2>/dev/null

# --- Tmux ---
sed -i '' "s|/theme[a-z0-9-]*\.conf\"|/$tmux_theme\"|" "$DOTFILES/tmux/tmux.conf"
tmux source-file "$HOME/.config/tmux/tmux.conf" 2>/dev/null

# --- Neovim ---
for sock in $(find /var/folders -name "nvim.*.0" -type s 2>/dev/null); do
  nvim --server "$sock" --remote-send "<Cmd>colorscheme $nvim_colorscheme<CR>" 2>/dev/null
done

# --- Reload Sketchybar last ---
sketchybar --reload 2>/dev/null

echo "$new_theme"
