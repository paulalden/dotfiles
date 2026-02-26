################################################################################
# Exported Variables
################################################################################

# Build PATH once (last entry has highest priority)
path=(
  /opt/homebrew/opt/openssl@3.5/bin
  /opt/homebrew/opt/rustup/bin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /opt/homebrew/opt/python@3.13/bin
  /opt/homebrew/opt/yarn/bin
  /opt/homebrew/opt/postgresql@15/bin
  $HOME/.local/scripts
  $HOME/.local/bin
  $HOME/.bin
  /usr/local/bin
  $path
)

export LIBRARY_PATH=$LIBRARY_PATH:/opt/homebrew/opt/zstd/lib/ # Fix for MySQL2 gem not compiling
export CXX=/usr/bin/clang++

# You may need to manually set your language environment
export LANG=en_GB.UTF-8

# Disable homebrew post-install messages
export HOMEBREW_NO_ENV_HINTS=1

# Preferred programs
export EDITOR=nvim
export TERMINAL=kitty
export MANPAGER='nvim +Man!'

# Mobile app
export NODE_ENV=development
# Cache JAVA_HOME to avoid subprocess on every shell start
if [[ -z "$JAVA_HOME" ]] && [[ -x /usr/libexec/java_home ]]; then
  export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null)
fi

# Increase the function nesting limit to 100 or higher
export FUNCNEST=100

export COLORTERM=truecolor