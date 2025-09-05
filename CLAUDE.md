# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a comprehensive macOS development environment dotfiles repository focused on productivity tools and workflows. The setup includes window management (Yabai), terminal emulation (Kitty), multiplexing (Tmux), text editing (Neovim), and shell configuration (ZSH).

## Installation and Setup Commands

### Initial Setup
```bash
# Install dotfiles using dotbot
./install

# Install Homebrew packages
brew bundle --file homebrew/Brewfile

# Install Ruby gems
bundle install
```

### Development Commands
```bash
# Format Neovim Lua files
stylua neovim/lua/

# Edit dotfiles quickly
editdots  # Alias that opens dotfiles in nvim

# Update tmux plugins
tmux source ~/.config/tmux/tmux.conf

# Reload yabai configuration
yabai --restart-service
```

## Architecture Overview

### Configuration Structure
- **Dotbot Management**: Uses `install.conf.yaml` for symlink management and `./install` script for setup
- **Modular Organization**: Each tool has its own directory with focused configuration files
- **Plugin Systems**: Neovim (Lazy.nvim), Tmux (TPM), ZSH (manual plugin management)

### Key Directories
- `neovim/`: Complete Neovim configuration with Lua-based plugin system
- `tmux/`: Tmux configuration split into options, keybindings, and themes
- `zsh/`: ZSH configuration with modular loading (exports, aliases, functions)
- `yabai/`: Window manager configuration requiring special macOS permissions
- `sketchybar/`: Status bar configuration with custom plugins and scripts

### Neovim Configuration
- **Plugin Manager**: Lazy.nvim with lazy loading enabled
- **LSP Setup**: Mason for LSP management, focused on Ruby development
- **Key Features**: Treesitter, completion, AI assistance (CodeCompanion), formatting
- **Config Structure**: 
  - `lua/config/`: Core configuration (options, keymaps, autocmds)
  - `lua/plugins/`: Individual plugin configurations
  - `stylua.toml`: Formatting rules for Lua code

### Tmux Configuration
- **Plugin Manager**: TPM (Tmux Plugin Manager)
- **Key Plugins**: Resurrect (session persistence), Continuum (auto-save), Floax (floating windows)
- **Config Structure**: Split into `options.conf`, `keybindings.conf`, and `theme.conf`

### ZSH Configuration
- **Plugin Management**: Manual plugin loading from `zsh/plugins/`
- **Key Plugins**: autosuggestions, syntax-highlighting, history-substring-search
- **Config Structure**: Modular loading from `zsh/config/` directory

## Development Workflow Patterns

### Ruby Development Focus
- LSP configured for Ruby, Rails, and related tools
- Specific aliases for Rails commands and Ruby tools
- Gemfile management for Ruby utilities

### AI-Assisted Development
- CodeCompanion plugin integrated with multiple AI providers
- Slash commands for common development tasks (/commit, /explain, /fix)
- Tools available: @cmd_runner, @editor, @files, @full_stack_dev

### Window Management
- Yabai requires System Integrity Protection modifications
- SKHD for keyboard shortcuts
- Sketchybar for status bar with custom plugins

## Important Notes

### macOS Specific Requirements
- Yabai setup requires disabling System Integrity Protection partially
- Homebrew installation path optimized for Apple Silicon (`/opt/homebrew/`)
- Terminal applications configured for macOS (Kitty, Ghostty)

### Plugin Management
- Neovim plugins auto-install on first run via Lazy.nvim
- Tmux plugins require manual installation: `<prefix> + I`
- ZSH plugins are committed to the repository

### Path Configuration
- Custom PATH setup in `zsh/config/exports.sh` prioritizes Homebrew tools
- Local binaries in `~/.local/bin` and `~/.bin`
- Python, PostgreSQL, and other tools have specific PATH entries

## Testing and Validation

### Configuration Testing
```bash
# Test Neovim configuration
nvim --headless -c "checkhealth" -c "q"

# Validate tmux configuration
tmux source ~/.config/tmux/tmux.conf

# Test ZSH configuration
zsh -n ~/.zshenv
```

### Linting
```bash
# Format Neovim Lua files
stylua neovim/lua/

# Validate YAML files
yamllint install.conf.yaml
```