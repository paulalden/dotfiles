# Shamelessly stolen from:
# https://github.com/Mach-OS/Machfiles/blob/master/zsh/.config/zsh/zsh-functions

# Function to source config files if they exist
# Usage: zsh_add_config "zsh-prompt"
function zsh_add_config() {
  [ -f "$ZDOTDIR/$1" ] && source "$ZDOTDIR/$1"
}

# Function to source files from anywhere if they exist
# Usage: zsh_add_file "./zsh-prompt"
function zsh_add_file() {
  [ -f "$1" ] && source "$1"
}

# Add remove plugins and source
# Usage:
# zsh_add_plugin "zsh-users/zsh-autosuggestions"
function zsh_add_plugin() {
  local PLUGIN_NAME
  PLUGIN_NAME=$(echo "$1" | cut -d "/" -f 2)

  if [ -d "$ZDOTDIR/plugins/$PLUGIN_NAME" ]; then
    zsh_add_config "plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" || zsh_add_config "plugins/$PLUGIN_NAME/$PLUGIN_NAME.zsh"
  else
    git clone "https://github.com/$1.git" "$ZDOTDIR/plugins/$PLUGIN_NAME"
  fi
}
