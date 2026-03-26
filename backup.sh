#!/usr/bin/env bash
#
# Backup existing config files before installing dotfiles.
# Creates ~/.dotfiles-backup/<timestamp>/ with copies of anything
# that would be replaced by dotbot symlinks.

set -e

BACKUP_ROOT="$HOME/.dotfiles-backup"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

# All paths that dotbot will symlink over (union of mac + linux configs)
TARGETS=(
  ~/.config/bat
  ~/.config/htop
  ~/.config/kitty
  ~/.config/lazygit
  ~/.config/nvim
  ~/.config/ranger
  ~/.config/sketchybar
  ~/.config/skhd
  ~/.config/tmux
  ~/.config/yabai
  ~/.config/zsh
  ~/.gitconfig
  ~/.gitignore_global
  ~/.zshenv
  ~/.editorconfig
  ~/.fzfrc
  ~/.Brewfile
)

backed_up=0

for target in "${TARGETS[@]}"; do
  expanded="${target/#\~/$HOME}"

  # Skip if doesn't exist
  [[ ! -e "$expanded" ]] && continue

  # Skip if already a symlink (nothing to back up — it's managed)
  [[ -L "$expanded" ]] && continue

  # Create backup dir on first real file found
  if [[ $backed_up -eq 0 ]]; then
    mkdir -p "$BACKUP_DIR"
    echo "Backing up to $BACKUP_DIR"
  fi

  # Preserve directory structure relative to ~
  rel="${expanded#$HOME/}"
  dest="$BACKUP_DIR/$rel"
  mkdir -p "$(dirname "$dest")"
  cp -R "$expanded" "$dest"
  echo "  $rel"
  backed_up=$((backed_up + 1))
done

if [[ $backed_up -eq 0 ]]; then
  echo "Nothing to back up — no existing config files found (or all are already symlinks)."
else
  echo "Backed up $backed_up item(s)."
  echo "Restore with: ./uninstall.sh --restore $TIMESTAMP"
fi
