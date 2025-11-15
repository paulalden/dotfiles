################################################################################
# Exported Variables
################################################################################

# First items are added first, but referred to last - first in, last out.
export PATH=/usr/local/bin:$PATH # Recommended by brew doctor
export PATH=$HOME/.bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.local/scripts:$PATH
export PATH=/opt/homebrew/opt/postgresql@15/bin:$PATH
export PATH=/opt/homebrew/opt/yarn:$PATH
export PATH=/opt/homebrew/opt/python@3.13:$PATH
export PATH=/opt/homebrew/sbin:$PATH # Recommended by brew doctor
export PATH=/opt/homebrew/bin:$PATH  # Brew is first as everything else uses that
export PATH=/opt/homebrew/opt/rustup/bin:$PATH
export PATH=/opt/homebrew/opt/openssl@3.5/bin:$PATH
export PATH=/opt/homebrew/opt/openssl@3:$PATH

export LIBRARY_PATH=$LIBRARY_PATH:/opt/homebrew/opt/zstd/lib/ # Fix for MySQL2 gem not compiling
export CXX=/usr/bin/clang++

# You may need to manually set your language environment
export LANG=en_GB.UTF-8

# Olio API specific
export RAILS_ENV=development

# Disable homebrew post-install messages
export HOMEBREW_NO_ENV_HINTS=1

# Preferred programs
export EDITOR=nvim
export TERMINAL=kitty
export MANPAGER='nvim +Man!'

# Mobile app
export NODE_ENV=development
export JAVA_HOME=$(/usr/libexec/java_home)

export AWS_REGION=eu-west-1