#!/usr/bin/env bash
#
# Remove dotfiles symlinks and optionally restore from backup.
#
# Usage:
#   ./uninstall.sh                      Remove symlinks only
#   ./uninstall.sh --restore <timestamp> Remove symlinks and restore backup

set -e

BACKUP_ROOT="$HOME/.dotfiles-backup"
RESTORE_TIMESTAMP=""
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --restore)
      RESTORE_TIMESTAMP="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: ./uninstall.sh [--restore <timestamp>]"
      exit 1
      ;;
  esac
done

# All symlink targets (union of mac + linux configs)
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

echo "==> Removing dotfiles symlinks..."
removed=0
for target in "${TARGETS[@]}"; do
  expanded="${target/#\~/$HOME}"

  # Only remove if it's a symlink pointing into our repo
  if [[ -L "$expanded" ]]; then
    link_target=$(readlink "$expanded")
    if [[ "$link_target" == "$BASEDIR"/* ]]; then
      rm "$expanded"
      echo "  Removed $target"
      removed=$((removed + 1))
    fi
  fi
done
echo "Removed $removed symlink(s)."

# Restore from backup if requested
if [[ -n "$RESTORE_TIMESTAMP" ]]; then
  RESTORE_DIR="$BACKUP_ROOT/$RESTORE_TIMESTAMP"
  if [[ ! -d "$RESTORE_DIR" ]]; then
    echo "Error: backup $RESTORE_DIR not found."
    echo "Available backups:"
    ls "$BACKUP_ROOT" 2>/dev/null || echo "  (none)"
    exit 1
  fi

  echo ""
  echo "==> Restoring from $RESTORE_DIR..."
  restored=0
  for item in "$RESTORE_DIR"/*; do
    [[ ! -e "$item" ]] && continue
    rel="${item#$RESTORE_DIR/}"
    dest="$HOME/$rel"
    mkdir -p "$(dirname "$dest")"
    cp -R "$item" "$dest"
    echo "  Restored $rel"
    restored=$((restored + 1))
  done
  echo "Restored $restored item(s)."
fi

# Reverse macOS defaults if on Mac
if [[ "$(uname)" == "Darwin" ]]; then
  echo ""
  read -p "Reverse macOS defaults changes (Dock, Finder, keyboard)? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "==> Reversing macOS defaults..."
    defaults delete NSGlobalDomain KeyRepeat 2>/dev/null || true
    defaults delete NSGlobalDomain InitialKeyRepeat 2>/dev/null || true
    defaults delete NSGlobalDomain ApplePressAndHoldEnabled 2>/dev/null || true
    defaults delete com.apple.dock autohide 2>/dev/null || true
    defaults delete com.apple.dock autohide-delay 2>/dev/null || true
    defaults delete com.apple.dock autohide-time-modifier 2>/dev/null || true
    defaults delete com.apple.dock mru-spaces 2>/dev/null || true
    defaults delete NSGlobalDomain AppleShowAllExtensions 2>/dev/null || true
    defaults delete NSGlobalDomain NSAutomaticSpellingCorrectionEnabled 2>/dev/null || true
    defaults delete NSGlobalDomain NSAutomaticWindowAnimationsEnabled 2>/dev/null || true
    killall Dock Finder &>/dev/null || true
    echo "Done. Some changes may require logout to fully revert."
  fi
fi

# Reverse chsh if on Linux
if [[ "$(uname)" == "Linux" ]]; then
  current_shell=$(getent passwd "$USER" | cut -d: -f7)
  if [[ "$current_shell" == *zsh* ]]; then
    echo ""
    read -p "Revert default shell from zsh to bash? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      chsh -s "$(which bash)"
      echo "Shell reverted to bash. Log out and back in for it to take effect."
    fi
  fi
fi

echo ""
echo "Uninstall complete."
