# dotfiles

My MacOS focused development environment dotfiles.

## Installation

Link dotbot paths and run `brew bundle --file .Brewfile`

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