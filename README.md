# dotfiles

My MacOS focused development environment dotfiles.

## Installation

### Fresh macOS Setup

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USER/dotfiles.git ~/Personal/Repos/dotfiles
cd ~/Personal/Repos/dotfiles

# 2. Run the install script (installs Homebrew and dotbot if needed, then symlinks everything)
./install

# 3. Install Homebrew packages
brew bundle --file ~/.Brewfile

# 4. Open a new terminal to load ZSH configuration
```

### Post-Install

```bash
# Install tmux plugins (open tmux first, then press prefix + I)
tmux

# Neovim plugins auto-install on first launch
nvim
```

### Requirements

- macOS (Apple Silicon, paths assume `/opt/homebrew/`)
- Xcode Command Line Tools (`xcode-select --install`)
- SSH key at `~/.ssh/id_rsa` (optional, for git/GitHub)
- `~/secrets.sh` for private environment variables (optional)

## Applications

- Nord Color Scheme
- Homebrew
+ Yabai WM & SKHD
+ Sketchybar
+ Kitty
+ Tmux
+ Neovim
  - Ruby development focused
  - LSP
  - Treesitter
  - Snacks
  - Git
- Ranger
- Bat
+ ZSH
+ FZF
+ Starship Prompt
+ LazyGit

## Screenshots

![Desktop](https://github.com/user-attachments/assets/a48505e1-9de0-490e-97ea-6c0097467886)

![Neovim](https://github.com/user-attachments/assets/1e079905-ed3b-41a0-9589-0a16ab6f9c84)

![Tmux, Neovim and Lazygit](https://github.com/user-attachments/assets/35deebbf-0b3e-4469-81c8-0b734036fffd)

![FZF Floating interface](https://github.com/user-attachments/assets/96ccf3d3-333d-4427-822c-91d185231a2e)


## Yabai

The WM needs to add hacks to get it working fully:

+ [Partially disable system integrity](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection)
+ [Setup user to run script injection](https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#macos-big-sur---automatically-load-scripting-addition-on-startup)

After upgrading Yabai, you need to follow these steps to properly setup application following:

https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#updating-to-the-latest-release

## Claude

Installing claude-code

Add/edit ~/.claude/settings.json to have:

```
{

"apiKeyHelper": "~/.claude/anthropic_key.sh"

}
```

Then in ~/.claude/anthropic_key.sh:

```
echo "sk-........."
```

and make it executable with:

chmod +x ~/.claude/anthropic_key.sh