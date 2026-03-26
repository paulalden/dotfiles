################################################################################
# Exported Variables
################################################################################

# Build PATH once (last entry has highest priority)
path=(
  $HOME/.local/scripts
  $HOME/.local/bin
  $HOME/.bin
  /usr/local/bin
  $path
)

if [[ "$(uname)" == "Darwin" ]]; then
  path=(
    /opt/homebrew/opt/openssl@3.5/bin
    /opt/homebrew/opt/rustup/bin
    /opt/homebrew/bin
    /opt/homebrew/sbin
    /opt/homebrew/opt/python@3.13/bin
    /opt/homebrew/opt/yarn/bin
    /opt/homebrew/opt/postgresql@15/bin
    $path
  )

  export LIBRARY_PATH=$LIBRARY_PATH:/opt/homebrew/opt/zstd/lib/
  export CXX=/usr/bin/clang++
  export TERMINAL=kitty
  export HOMEBREW_NO_ENV_HINTS=1

  if [[ -z "$JAVA_HOME" ]] && [[ -x /usr/libexec/java_home ]]; then
    export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null)
  fi
fi

# You may need to manually set your language environment
export LANG=en_GB.UTF-8

export EDITOR=nvim
export MANPAGER='nvim +Man!'

# Mobile app
export NODE_ENV=development

# Increase the function nesting limit to 100 or higher
export FUNCNEST=100

export COLORTERM=truecolor
