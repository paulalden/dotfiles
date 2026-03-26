################################################################################
# ZSH configuration
################################################################################

# Exit early for non-interactive shells
[[ -o interactive ]] || return

DISABLE_AUTO_TITLE="true" # Disable auto-setting terminal title.
COMPLETION_WAITING_DOTS="true" # Display red dots whilst waiting for completion.
DISABLE_UNTRACKED_FILES_DIRTY="true" # Disable marking untracked files
INC_APPEND_HISTORY="true"
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history # Persist history
HISTSIZE=1000000
SAVEHIST=1000000
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Ensure no duplicates are recorded in the history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS

# Disable highlight of pastes text
zle_highlight=('paste:none')

# Enabled features
setopt autocd extendedglob nomatch menucomplete interactive_comments

# Disable ctrl-s to freeze terminal.
[[ -t 0 ]] && stty stop undef

# Unset defaults
unsetopt correct_all BEEP

# Colors
autoload -Uz colors && colors

################################################################################
# Command Completions
################################################################################

autoload -Uz compinit

zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
zmodload zsh/complist

# Include hidden files
_comp_options+=(globdots)

# Cache compinit (only rebuild dump once per day)
if [[ -f $ZDOTDIR/.zcompdump(#qNmh-24) ]]; then
  compinit -C
else
  compinit
fi

################################################################################
# Plugins and packages
################################################################################

source "$ZDOTDIR/user/packages.sh"

zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-history-substring-search"
zsh_add_plugin "hlissner/zsh-autopair"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting" # Must be last

zsh_add_config "config/vim-mode.sh"
zsh_add_config "config/exports.sh"
zsh_add_config "config/aliases.sh"
zsh_add_config "config/fzf.sh"

################################################################################
# Imports
################################################################################

zsh_add_file "$HOME/secrets.sh" # Shhhh, don't commit secrets

################################################################################
# Misc
################################################################################


ulimit -Sn 10240 # Increase the default number of sockers (helps with rspec tests in Chrome)

################################################################################
# Extras
################################################################################

# Cache eval output for faster startup (regenerate with: rm ~/.cache/zsh/*)
function _cached_eval() {
  local name=$1; shift
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  local cache_file="$cache_dir/$name.zsh"
  if [[ ! -f "$cache_file" || ! -s "$cache_file" ]]; then
    mkdir -p "$cache_dir"
    "$@" > "$cache_file"
  fi
  source "$cache_file"
}

source "$ZDOTDIR/user/prompt.sh"
_cached_eval fzf fzf --zsh


[[ "$(uname)" == "Darwin" ]] && eval "$(/opt/homebrew/bin/zsh-patina activate)"

# Local overrides (not tracked in repo)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
