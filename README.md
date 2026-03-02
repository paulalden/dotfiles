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


## FZF

FZF commands are available both as shell functions and as tmux popup keybindings.

### Tmux Keybindings

All bindings use the tmux prefix (`Ctrl+Space`):

**Files & Navigation**

| Binding | Description |
|---------|-------------|
| `prefix + e` | Sessionizer - find a project directory and open/switch to a tmux session |
| `prefix + E` | Find and edit a file in the current directory |
| `prefix + p` | Switch to another tmux pane across windows |
| `prefix + s` | Live ripgrep search, Enter to open file at match |
| `prefix + u` | Extract URLs from tmux pane scrollback and open in browser |

**Git**

| Binding | Description |
|---------|-------------|
| `prefix + G` | Git branch switcher (sorted by recent, with log preview) |
| `prefix + L` | Git log browser (Enter to view diff, Ctrl-O to checkout) |
| `prefix + S` | Git stash browser (Enter to apply, Ctrl-D to drop) |
| `prefix + A` | Interactive git add with diff preview |

**System & Tools**

| Binding | Description |
|---------|-------------|
| `prefix + K` | Fuzzy find and kill a process |
| `prefix + N` | Browse listening ports and kill the process |
| `prefix + B` | Homebrew install/uninstall with preview |
| `prefix + D` | Exec into a running Docker container |
| `prefix + T` | Browse tldr cheat sheets with preview |
| `prefix + m` | Fuzzy search and open man pages |

### Shell Functions

| Command | Description |
|---------|-------------|
| `tm [name]` | Create or switch to a tmux session (fuzzy select if no name given) |
| `fs [query]` | Switch tmux session with fuzzy search |
| `ftpane` | Switch to a tmux pane with fuzzy search |
| `fe [query]` | Find and open a file in `$EDITOR` |
| `fo [query]` | Find a file - Ctrl-O to `open`, Enter to edit |
| `fda` | cd into a directory (including hidden) |
| `fdr` | cd to a parent directory |
| `fh` | Search and re-run a command from shell history |
| `fkill` | Fuzzy find and kill a process |

### Built-in FZF Keybindings

| Binding | Description |
|---------|-------------|
| `Ctrl+R` | Search shell history (Ctrl-Y to copy to clipboard) |
| `Ctrl+T` | Find files/directories with preview |

## Neovim

### Ruby Debugging (DAP)

Debug Ruby files, RSpec tests, and Rails servers directly in Neovim using `nvim-dap` with the `rdbg` adapter (from the `debug` gem).

**Prerequisites:**

The `debug` gem must be available in your project. It's already bundled as a dependency of `ruby-lsp`, but you can also add it explicitly:

```ruby
# Gemfile
group :development, :test do
  gem "debug"
end
```

**Keybindings:**

| Binding | Description |
|---------|-------------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Start/continue debugging |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>du` | Toggle DAP UI |

**Usage:**

1. Open a Ruby file and set breakpoints with `<leader>db`
2. Start debugging with `<leader>dc` — you'll be prompted to choose a launch config:
   - **Run current file** — runs `ruby <file>` under the debugger
   - **RSpec - current file** — runs `bundle exec rspec <file>` under the debugger
   - **Rails server** — starts `bundle exec rails server` under the debugger
3. The DAP UI opens automatically showing scopes, breakpoints, stacks, and a REPL
4. Step through code with `<leader>di` / `<leader>do` / `<leader>dO`
5. Close the UI with `<leader>du`

### Testing (Neotest)

Run RSpec tests from within Neovim using `neotest` with the `neotest-rspec` adapter.

| Binding | Description |
|---------|-------------|
| `<leader>tn` | Run nearest test |
| `<leader>tf` | Run current file |
| `<leader>ts` | Run full test suite |
| `<leader>to` | Show test output |
| `<leader>tS` | Toggle test summary panel |

### Rails Navigation

`vim-rails` provides Rails-aware navigation commands:

| Command | Description |
|---------|-------------|
| `:Emodel <name>` | Jump to a model |
| `:Econtroller <name>` | Jump to a controller |
| `:Eview <name>` | Jump to a view |
| `:Emigration <name>` | Jump to a migration |
| `:A` | Jump to alternate file (e.g. model → test) |
| `:R` | Jump to related file (e.g. migration → schema) |
| `gf` | Enhanced go-to-file that understands Rails paths |

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