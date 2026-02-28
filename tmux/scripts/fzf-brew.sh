#!/usr/bin/env bash

# Browse Homebrew packages - install or uninstall
action=$(printf "install\nuninstall" | fzf --no-tmux --header 'Homebrew action')

case "$action" in
  install)
    pkgs=$(brew formulae | fzf --no-tmux --multi --header 'Select formulae to install' \
      --preview 'brew info {}')
    if [[ -n "$pkgs" ]]; then
      echo "$pkgs" | xargs brew install
      read -r -p "Press Enter to close..."
    fi
    ;;
  uninstall)
    pkgs=$(brew leaves | fzf --no-tmux --multi --header 'Select formulae to uninstall' \
      --preview 'brew info {}')
    if [[ -n "$pkgs" ]]; then
      echo "$pkgs" | xargs brew uninstall
      read -r -p "Press Enter to close..."
    fi
    ;;
esac
