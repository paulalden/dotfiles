# Usage:
# zsh_add_completion "esc/conda-zsh-completion" false
#
function zsh_add_completion() {
  PLUGIN_NAME=$(echo $1 | cut -d "/" -f 2)

  if [ -d "$ZDOTDIR/plugins/$PLUGIN_NAME" ]; then
    # For completions
    completion_file_path=$(ls $ZDOTDIR/plugins/$PLUGIN_NAME/_*)
    fpath+="$(dirname "${completion_file_path}")"
    zsh_add_file "plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh"
  else
    git clone "https://github.com/$1.git" "$ZDOTDIR/plugins/$PLUGIN_NAME"
    fpath+=$(ls $ZDOTDIR/plugins/$PLUGIN_NAME/_*)
    [ -f $ZDOTDIR/.zccompdump ] && $ZDOTDIR/.zccompdump
  fi

  completion_file="$(basename "${completion_file_path}")"

  if [ "$2" = true ]; then
    compinit "${completion_file:1}"
  fi
}