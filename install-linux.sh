#!/usr/bin/env bash
#
# Install CLI tools on Ubuntu/Debian before running ./install
# Run with: sudo bash install-linux.sh

set -e

echo "==> Installing apt packages..."
apt update
apt install -y \
  zsh \
  git \
  git-lfs \
  fzf \
  bat \
  eza \
  fd-find \
  ripgrep \
  tmux \
  htop \
  jq \
  wget \
  curl \
  ncurses-term \
  python3-pip

# fd-find installs as fdfind on Debian/Ubuntu — symlink to fd
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
  ln -s "$(which fdfind)" /usr/local/bin/fd
fi

# bat installs as batcat on Debian/Ubuntu — symlink to bat
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
  ln -s "$(which batcat)" /usr/local/bin/bat
fi

echo "==> Installing Neovim (appimage)..."
curl -Lo /tmp/nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod +x /tmp/nvim.appimage
mv /tmp/nvim.appimage /usr/local/bin/nvim

echo "==> Installing lazygit..."
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
install /tmp/lazygit /usr/local/bin
rm /tmp/lazygit /tmp/lazygit.tar.gz

echo "==> Installing diff-so-fancy..."
curl -Lo /usr/local/bin/diff-so-fancy https://github.com/so-fancy/diff-so-fancy/releases/latest/download/diff-so-fancy
chmod +x /usr/local/bin/diff-so-fancy

echo "==> Setting zsh as default shell..."
chsh -s "$(which zsh)"

echo "Done. Log out and back in for zsh to take effect, then run ./install"
