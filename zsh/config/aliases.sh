################################################################################
# Aliases
#
# To remove an alias: `unalias `
################################################################################

# General
alias ls="eza -s type"
alias la="ls -la"
alias lazygit="lazygit -ucd ~/.config/lazygit/"
alias grep="grep --color=auto"
alias editdots="nvim ~/dev/dotfiles"

# Vim
alias vimdiff='nvim -d'
alias vim="nvim"
alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'

# ZSH
alias zsh:reload='source $ZDOTDIR/.zshrc'
alias zsh:edit="nvim $ZDOTDIR/.zshrc"
alias zsh:alias="cat ~/.config/zsh/config/aliases.sh"
alias zsh:alias:edit="nvim ~/.config/zsh/config/aliases.sh"

# Tmux
alias t="tmux"
alias ta="t a -t"
alias tls="t ls"
alias tn="t new -t"

# Yabai
alias yabai:reload="yabai --stop-service; pkill -x yabai; rm -f /tmp/yabai_${USER}.lock; yabai --start-service"
alias yabai:restart="yabai --stop-service; pkill -x yabai; rm -f /tmp/yabai_${USER}.lock; yabai --start-service"
alias yabai:start="yabai --start-service"
alias yabai:stop="yabai --stop-service"
alias yabai:install_sa="sudo yabai --load-sa"
alias yabai:borders:off="borders active_color=0x00000000 inactive_color=0x00000000 width=0.0"
alias yabai:borders:on="borders active_color=0xffcbb1c7 inactive_color=0xff2e3440 width=5.0"

# SKHD
alias skhd:keys="cat ~/.config/skhd/skhdrc"
alias skhd:start="skhd --start-service"
alias skhd:stop="skhd --stop-service"
alias skhd:restart="skhd --restart-service"
alias skhd:reload="skhd --restart-service"

# Brew
alias brew:upgrade:all="brew upgrade; nvim --headless '+Lazy! sync' +qa > /dev/null; yabai:stop; yabai:start; sketchybar --trigger brew_update"
alias brew:upgrade="brew upgrade && sketchybar --trigger brew_update"
alias brew:bundle="brew bundle --file ~/.Brewfile"
alias brew:dump="brew bundle dump --force --file ~/dev/dotfiles/homebrew/Brewfile"

# Docker Compose
alias dc="docker-compose"
alias dcr="docker-compose run --rm"
alias dce="docker-compose exec"

# DO NOT use ctrl+c or it will exit the container, instead use ctrl+q+p
function docker-attach() {
  docker attach $(docker-compose ps -q $1)
}

alias speed-test="cloudflare-speed-cli"

# Utilities
function list_colors() {
  for i in {0..255}; do
    printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
  done
}