#!/usr/bin/env bash
#
# Install CLI tools on Ubuntu/Debian before running ./install
#
# Usage:
#   sudo bash install-linux.sh             Install everything
#   sudo bash install-linux.sh --uninstall Remove manually-installed binaries

set -e

# --- Uninstall mode ---
if [[ "${1:-}" == "--uninstall" ]]; then
  echo "==> Removing manually-installed binaries..."
  rm -f /usr/local/bin/lazygit
  rm -f /usr/local/bin/diff-so-fancy
  rm -f /usr/local/bin/fd
  rm -f /usr/local/bin/bat
  echo "Done. apt-installed packages are untouched — remove with apt if needed."
  exit 0
fi

# --- Preflight ---
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run with sudo: sudo bash install-linux.sh"
  exit 1
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Detect architecture for GitHub binary downloads
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)  LAZYGIT_ARCH="x86_64" ;;
  aarch64) LAZYGIT_ARCH="arm64" ;;
  *)
    echo "WARNING: Unsupported architecture $ARCH for binary downloads."
    echo "lazygit and diff-so-fancy will need to be installed manually."
    LAZYGIT_ARCH=""
    ;;
esac

# --- apt packages ---
APT_PACKAGES=(
  software-properties-common
  zsh
  git
  git-lfs
  fzf
  fd-find
  ripgrep
  tmux
  htop
  jq
  wget
  curl
  ncurses-term
  python3-pip
)

echo "The following apt packages will be installed:"
printf '  %s\n' "${APT_PACKAGES[@]}"
echo ""
echo "The following PPAs will be added:"
echo "  ppa:neovim-ppa/stable (neovim)"
echo ""
echo "The following will be downloaded from GitHub:"
echo "  lazygit (latest release)"
echo "  diff-so-fancy (latest release)"
echo ""
read -p "Proceed? [y/N] " answer
[[ "$answer" =~ ^[Yy]$ ]] || exit 0

echo ""
echo "==> Installing apt packages..."
apt update
apt install -y "${APT_PACKAGES[@]}"

# fd-find installs as fdfind on Debian/Ubuntu
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  ln -s "$(which fdfind)" /usr/local/bin/fd
fi

# bat: try apt first, handle batcat rename
if ! command -v bat &>/dev/null; then
  if apt install -y bat 2>/dev/null; then
    : # installed as bat
  elif command -v batcat &>/dev/null; then
    ln -s "$(which batcat)" /usr/local/bin/bat
  fi
fi

# eza: try apt, fall back to cargo
if ! command -v eza &>/dev/null; then
  if ! apt install -y eza 2>/dev/null; then
    echo "eza not in apt repos. Install manually: cargo install eza"
  fi
fi

# --- Neovim via PPA ---
echo ""
echo "==> Installing Neovim via PPA..."
add-apt-repository -y ppa:neovim-ppa/stable
apt update
apt install -y neovim

# --- lazygit from GitHub ---
echo ""
if [[ -n "$LAZYGIT_ARCH" ]]; then
  echo "==> Installing lazygit..."
  LAZYGIT_VERSION=$(curl -sf "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') || true
  if [[ -z "$LAZYGIT_VERSION" ]]; then
    echo "WARNING: Could not determine lazygit version. Skipping."
  else
    if curl -fLo "$TMPDIR/lazygit.tar.gz" "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"; then
      tar xf "$TMPDIR/lazygit.tar.gz" -C "$TMPDIR" lazygit
      install "$TMPDIR/lazygit" /usr/local/bin
      echo "  Installed lazygit $LAZYGIT_VERSION"
    else
      echo "WARNING: Failed to download lazygit. Skipping."
    fi
  fi

  # --- diff-so-fancy from GitHub ---
  echo ""
  echo "==> Installing diff-so-fancy..."
  if curl -fLo "$TMPDIR/diff-so-fancy" "https://github.com/so-fancy/diff-so-fancy/releases/latest/download/diff-so-fancy"; then
    chmod +x "$TMPDIR/diff-so-fancy"
    mv "$TMPDIR/diff-so-fancy" /usr/local/bin/
    echo "  Installed diff-so-fancy"
  else
    echo "WARNING: Failed to download diff-so-fancy. Skipping."
  fi
fi

# --- Set default shell ---
echo ""
if command -v zsh &>/dev/null; then
  current_shell=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f7)
  if [[ "$current_shell" != *zsh* ]]; then
    read -p "Set zsh as default shell for ${SUDO_USER:-$USER}? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      chsh -s "$(which zsh)" "${SUDO_USER:-$USER}"
      echo "Shell changed. Log out and back in for it to take effect."
    fi
  else
    echo "zsh is already the default shell."
  fi
else
  echo "WARNING: zsh not found after install. Shell not changed."
fi

echo ""
echo "Done. Run ./install to set up dotfiles symlinks."
