# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a comprehensive macOS development environment dotfiles repository focused on productivity tools and workflows. The setup includes window management (Yabai), terminal emulation (Kitty), multiplexing (Tmux), text editing (Neovim), and shell configuration (ZSH).

## Installation and Setup Commands

### Initial Setup
```bash
# Install dotfiles: installs Homebrew/dotbot if missing, symlinks everything,
# installs Brewfile packages and tmux plugins, prompts before the window
# management extras (yabai/skhd/sketchybar).
./install
```

### Development Commands
```bash
# Edit dotfiles quickly
editdots  # Alias that opens dotfiles in nvim

# Update tmux plugins (TPM): prefix + U inside tmux, or:
~/.config/tmux/plugins/tpm/bin/update_plugins all

# Update a zsh plugin (they are git clones under zsh/plugins/)
git -C zsh/plugins/<name> pull

# Reload yabai configuration
yabai --restart-service
```

## Architecture Overview

### Configuration Structure
- **Dotbot Management**: Uses `install.conf.yaml` for symlink management and `./install` script for setup
- **Window Management Links**: `install.wm.yaml` links yabai, skhd and sketchybar, and only runs if you accept the prompt in `./install`
- **Uninstall**: `./uninstall` runs the dotfiles uninstaller

### Key Directories
- `neovim/`: Complete Neovim configuration with Lua-based plugin system
- `tmux/`: Tmux configuration split into options, keybindings, and themes
- `zsh/`: ZSH configuration with modular loading (exports, aliases, fzf, vim mode)
- `yabai/`: Window manager configuration requiring special macOS permissions
- `sketchybar/`: Status bar configuration with custom plugins and scripts
- `claude/`: Claude Code settings, hooks, statusline, and local plugins (marketplace + timestamps)
  - `settings.json`, `CLAUDE.md`, `statusline-command.sh` and the hook are symlinked into `~/.claude/`, so edits apply to every Claude Code session at once

### Neovim Configuration
- **Plugin Manager**: Lazy.nvim. Plugins load at startup by default (`lazy = false`); a spec must opt in to lazy loading.
- **LSP Setup**: Native Neovim 0.11+ LSP configuration (no Mason), focused on Ruby development
- **Key Features**: Treesitter, completion, AI assistance (CodeCompanion), formatting
- **AI Assistance**: CodeCompanion is configured in `lua/plugins/codecompanion.lua` with the Anthropic adapter
- **Config Structure**: 
  - `lua/config/`: Core configuration (options, keymaps, autocmds)
  - `lua/plugins/`: Individual plugin configurations
  - `stylua.toml`: Formatting rules for Lua code

### Tmux Configuration
- **Key Plugins**: Resurrect (session persistence), Continuum (auto-save)
- **Config Structure**: Split into `options.conf`, `keybindings.conf`, and `theme.conf`

### ZSH Configuration
- **Key Plugins**: autosuggestions, syntax-highlighting, history-substring-search, autopair
- **Config Structure**: Modular loading from `zsh/config/` directory, plus `zsh/user/` for the prompt (`prompt.sh`) and plugin-loading helpers (`packages.sh`)

## Important Notes

### macOS Specific Requirements
- Yabai setup requires disabling System Integrity Protection partially
- Homebrew installation path optimized for Apple Silicon (`/opt/homebrew/`)
- Terminal applications configured for macOS (Kitty)

### Plugin Management
- Neovim plugins auto-install on first run via Lazy.nvim
- Tmux plugins install automatically during `./install`; add new ones with `<prefix> + I`, update with `<prefix> + U` (TPM)
- ZSH plugins are committed to the repository under `zsh/plugins/` and loaded manually

### Gotchas
- `install.conf.yaml`: entries under `link:` must keep 4-space indentation, or dotbot fails. Run `yamllint install.conf.yaml` after editing.

### Path Configuration
- Custom PATH setup in `zsh/config/exports.sh` prioritizes Homebrew tools
- Local binaries in `~/.local/bin` and `~/.bin`
- Python, PostgreSQL, and other tools have specific PATH entries

## Testing and Validation

### Configuration Testing
```bash
# Test Neovim configuration
nvim --headless -c "checkhealth" -c "q"

# Reload and validate tmux configuration
tmux source ~/.config/tmux/tmux.conf

# Test ZSH configuration
for f in zsh/config/*.sh zsh/user/*.sh; do zsh -n "$f"; done
```

### Linting
```bash
# Format Neovim Lua files
stylua neovim/lua/

# Validate YAML files
yamllint install.conf.yaml
```