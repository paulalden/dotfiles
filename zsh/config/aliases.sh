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
# alia cat="bat --paging=never --wrap=never --style=plain"
alias editdots="cd ~/Personal/Repos/dotfiles; nvim"

# Vim
alias vimdiff='nvim -d'
alias vim="nvim"
alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'

# Rails / Ruby
alias rspec="bundle exec rspec"
alias be="bundle exec"

# ZSH
alias zsh:reload="source $ZDOTDIR/.zshrc"
alias zsh:edit="nvim $ZDOTDIR/.zshrc"
alias zsh:alias="cat ~/.config/zsh/config/aliases.sh"
alias zsh:alias:edit="nvim ~/.config/zsh/config/aliases.sh"

# Tmux
alias t="tmux"
alias ta="t a -t"
alias tls="t ls"
alias tn="t new -t"

# Olio
alias olio:api:console:production="FILTER=admin bundle exec cap production rails:console"
alias olio:api:console:staging="bundle exec cap staging rails:console"

alias olio:storage="zsh ~/Dev/storage.sh"
alias olio:stop_storage="docker stop redis-dev mysql-dev"
function olio_ips() {
  aws ec2 describe-instances \
    --query "Reservations[*].Instances[*].{InstanceId:InstanceId,PrivateIpAddress:PrivateIpAddress,Name:Tags[?Key=='Name']|[0].Value}" \
    --output table | fzf
}
alias olio:ips="olio_ips"
# function olio_console() {
#   FILTER=admin bundle exec cap $1 rails:console
# }

# Yabai
alias yabai:reload="yabai --restart-service"
alias yabai:restart="yabai --restart-service"
alias yabai:start="yabai --start-service"
alias yabai:stop="yabai --stop-service"
alias yabai:install_sa="sudo yabai --load-sa"
alias yabai:borders:off="yabai -m config window_border off"
alias yabai:borders:on="yabai -m config window_border on"

# SKHD
alias skhd:keys="cat ~/.config/skhd/skhdrc"
alias skhd:start="skhd --start-service"
alias skhd:stop="skhd --stop-service"
alias skhd:restart="skhd --restart-service"
alias skhd:reload="skhd --restart-service"

# Brew
# alias brew:upgrade:all="brew upgrade; sh ~/Personal/Repos/dotfiles/zsh/user/install_neovim_head.sh; nvim --headless '+Lazy! sync' +qa; yabai:stop; yabai:start;"
alias brew:upgrade:all="brew upgrade; nvim --headless '+Lazy! sync' +qa > /dev/null; yabai:stop; yabai:start;"
alias brew:bundle="brew bundle --file ~/.Brewfile"

# Docker Compose
alias dc="docker-compose"
alias dcr="docker-compose run --rm"
# DO NOT use ctrl+c or it will exit the container, instead use ctrl+q+p
function docker-attach() {
  docker attach $(docker-compose ps -q $1)
}

# Rails
alias rails:routes="dcr rails routes | fzf -e"

# Ollama
alias ai:install="docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama"
alias ai:start="docker start ollama"
alias ai:stop="docker stop ollama"
alias ai="docker exec -it ollama ollama run mistral:latest"
alias ai:code="docker exec -it ollama ollama run mistral:ruby-mentor"
alias ai:ls="docker exec -it ollama ollama ls"
alias ai:rm="docker exec -it ollama ollama rm"