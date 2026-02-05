################################################################################
# ZSH configuration
################################################################################

DISABLE_AUTO_TITLE="true" # Disable auto-setting terminal title.
COMPLETION_WAITING_DOTS="true" # Display red dots whilst waiting for completion.
DISABLE_UNTRACKED_FILES_DIRTY="true" # Disable marking untracked files
INC_APPEND_HISTORY="true"
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history # Persist history
HISTSIZE=1000000
SAVEHIST=1000000
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

setopt appendhistory

# Ensure no duplicates are recorded in the history
setopt HIST_IGNORE_ALL_DUPS

# Disable highlight of pastes text
zle_highlight=('paste:none')

# Enabled features
setopt autocd extendedglob nomatch menucomplete interactive_comments

# Disable ctrl-s to freeze terminal.
stty stop undef

# Unset defaults
unsetopt correct_all BEEP

# Colors
autoload -Uz colors && colors

################################################################################
# Command Completions
################################################################################

autoload -Uz compinit

fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)

zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
zmodload zsh/complist

# Include hidden files
_comp_options+=(globdots)

compinit

################################################################################
# Plugins and packages
################################################################################

source "$ZDOTDIR/user/packages.sh"

zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-history-substring-search"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting"
zsh_add_plugin "hlissner/zsh-autopair"

zsh_add_config "config/vim_mode.sh"
zsh_add_config "config/exports.sh"
zsh_add_config "config/aliases.sh"
zsh_add_config "config/helpers.sh"
zsh_add_config "config/fzf.sh"

################################################################################
# Imports
################################################################################

zsh_add_file "$HOME/secrets.sh" # Shhhh, don't commit secrets

################################################################################
# Misc
################################################################################

ssh-add -q --apple-use-keychain ~/.ssh/id_rsa # Ensure that the ssh_key is added to the ssh-agent

ulimit -Sn 10240 # Increase the default number of sockers (helps with rspec tests in Chrome)

################################################################################
# Extras
################################################################################

eval "$(starship init zsh)"

. $(brew --prefix asdf)/libexec/asdf.sh
