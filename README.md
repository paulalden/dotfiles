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

* Yabai WM & SKHD
* Sketchybar
* Kitty
* Tmux
* Neovim
  - Ruby development focused
  - LSP
  - Treesitter
  - Snacks
  - Git

- Ranger
- Bat

* ZSH
* FZF
* Starship Prompt
* LazyGit

## Screenshots

![Desktop](https://github.com/user-attachments/assets/998e7a07-f164-481c-9533-9565f5396203)
![Neovim](https://github.com/user-attachments/assets/a7d33132-b177-4d1d-aeff-708ebf29c481)
![Tmux](https://github.com/user-attachments/assets/f547c5f2-7582-4d98-8db1-11e7ac666b34)
![Lazygit](https://github.com/user-attachments/assets/cc4fbde6-da74-4a3a-b668-edab709f1abb)
![Tmux Sessions](https://github.com/user-attachments/assets/97508672-318c-43bc-8088-a1cf721093ad)
![Tmux Search](https://github.com/user-attachments/assets/8adc86ee-50fb-41fe-b7cd-74aa724aae50)


## FZF

FZF commands are available both as shell functions and as tmux popup keybindings.

### Tmux Keybindings

All bindings use the tmux prefix (`Ctrl+Space`). Popup windows display a centered title so you know what you're looking at.

**Popup Apps**

| Binding      | Description           |
| ------------ | --------------------- |
| `prefix + f` | Ranger file manager   |
| `prefix + d` | LazySQL               |
| `prefix + h` | Htop                  |
| `prefix + i` | IRB (Ruby REPL)       |
| `prefix + v` | Cloudflare speed test |

**Tmux** (prefix + t, then second key)

| Binding        | Description                                                              |
| -------------- | ------------------------------------------------------------------------ |
| `prefix + t f` | Find and edit a file (Enter: in popup, Ctrl-S: in pane)                  |
| `prefix + t g` | Live ripgrep search (Enter: in popup, Ctrl-S: in pane)                   |
| `prefix + t p` | Switch to another tmux pane across windows                               |
| `prefix + t e` | Sessionizer - find a project directory and open/switch to a tmux session |
| `prefix + t t` | Toggle the status bar                                                    |

**Git** (prefix + g, then second key)

| Binding        | Description                                              |
| -------------- | -------------------------------------------------------- |
| `prefix + g g` | Lazygit                                                  |
| `prefix + g b` | Git branch switcher (sorted by recent, with log preview) |
| `prefix + g l` | Git log browser (Enter to view diff, Ctrl-O to checkout) |
| `prefix + g s` | Git stash browser (Enter to apply, Ctrl-D to drop)       |

**System & Tools**

| Binding      | Description                                |
| ------------ | ------------------------------------------ |
| `prefix + K` | Fuzzy find and kill a process              |
| `prefix + N` | Browse listening ports and kill the process |

### Shell Functions

| Command      | Description                                   |
| ------------ | --------------------------------------------- |
| `fe [query]` | Find and open a file in `$EDITOR`             |
| `fo [query]` | Find a file - Ctrl-O to `open`, Enter to edit |
| `fcd`        | cd into a directory (including hidden)         |

### Built-in FZF Keybindings

| Binding  | Description                                        |
| -------- | -------------------------------------------------- |
| `Ctrl+R` | Search shell history (Ctrl-Y to copy to clipboard) |
| `Ctrl+T` | Find files/directories with preview                |

## Neovim

### Ruby Debugging (DAP)

Debug Ruby files, RSpec tests, and Rails servers directly in Neovim using `nvim-dap` with the `rdbg` adapter (from the `debug` gem). Two debugging UIs are available: `nvim-dap-ui` (multi-panel layout) and `nvim-dap-view` (single-window).

**Prerequisites:**

The `debug` gem must be available in your project. It's already bundled as a dependency of `ruby-lsp`, but you can also add it explicitly:

```ruby
# Gemfile
group :development, :test do
  gem "debug"
end
```

**Keybindings:**

| Binding      | Description                     |
| ------------ | ------------------------------- |
| `<leader>db` | Toggle breakpoint               |
| `<leader>dc` | Start/continue debugging        |
| `<leader>di` | Step into                       |
| `<leader>do` | Step over                       |
| `<leader>dO` | Step out                        |
| `<leader>du` | Toggle DAP UI (multi-panel)     |
| `<leader>dv` | Toggle DAP View (single-window) |
| `<leader>dw` | Add watch expression (DAP View) |

**DAP UI** opens automatically when a debug session starts and closes when it ends. It shows scopes, breakpoints, stacks, watches, and a REPL in a multi-panel layout.

**DAP View** is toggled manually with `<leader>dv`. Switch between sections using the winbar keys:

| Key | Section                                      |
| --- | -------------------------------------------- |
| `S` | Scopes — inspect local/global variables      |
| `W` | Watches — evaluate custom expressions        |
| `B` | Breakpoints — view and manage breakpoints    |
| `T` | Threads — navigate call stacks               |
| `E` | Exceptions — configure exception breakpoints |
| `R` | REPL — interactive debug console             |

Press `g?` inside any section to see all available actions (expand, edit, delete, etc.).

**Debugging Ruby files and RSpec:**

1. Open a Ruby file and set breakpoints with `<leader>db`
2. Start debugging with `<leader>dc` and choose a launch config:
   - **Run current file** — runs `ruby <file>` under the debugger
   - **RSpec - current file** — runs `bundle exec rspec <file>` under the debugger
3. DAP UI opens automatically showing scopes, breakpoints, stacks, and a REPL
4. Step through code with `<leader>di` / `<leader>do` / `<leader>dO`
5. Optionally open DAP View with `<leader>dv` for a focused single-window view

**Debugging a Rails server:**

Rails requires an attach workflow since Puma manages its own process lifecycle:

1. Start Rails with rdbg in a separate terminal or tmux pane:
   ```bash
   bundle exec rdbg --open --port 12345 --nonstop -c -- bin/rails server
   ```
2. Set breakpoints in a controller/model with `<leader>db`
3. Attach with `<leader>dc` → **Attach to Rails server**
4. Hit the route in your browser — Neovim will pause at the breakpoint
5. Step through code and inspect variables in DAP UI or DAP View

### Testing (Neotest)

Run RSpec tests from within Neovim using `neotest` with the `neotest-rspec` adapter.

| Binding      | Description               |
| ------------ | ------------------------- |
| `<leader>tn` | Run nearest test          |
| `<leader>tf` | Run current file          |
| `<leader>ts` | Run full test suite       |
| `<leader>to` | Show test output          |
| `<leader>tS` | Toggle test summary panel |

### Rails Navigation

`vim-rails` provides Rails-aware navigation commands:

| Command               | Description                                      |
| --------------------- | ------------------------------------------------ |
| `:Emodel <name>`      | Jump to a model                                  |
| `:Econtroller <name>` | Jump to a controller                             |
| `:Eview <name>`       | Jump to a view                                   |
| `:Emigration <name>`  | Jump to a migration                              |
| `:A`                  | Jump to alternate file (e.g. model → test)       |
| `:R`                  | Jump to related file (e.g. migration → schema)   |
| `gf`                  | Enhanced go-to-file that understands Rails paths |

## Yabai

The WM needs to add hacks to get it working fully:

- [Partially disable system integrity](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection)
- [Setup user to run script injection](<https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#macos-big-sur---automatically-load-scripting-addition-on-startup>)

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
