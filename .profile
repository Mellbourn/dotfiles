###############################################################################
# .profile is read by many shells in the absence of their own shell-specific config files.
###############################################################################
# shellcheck shell=bash
#echo ".profile running"

# directory for git repositories, should be set up before tmux starts
export CODE_DIR=~/code

if [ -d "/opt/homebrew/bin" ]; then
  export HOMEBREW_PREFIX=/opt/homebrew
  PATH=$HOMEBREW_PREFIX/bin:$PATH
else
  export HOMEBREW_PREFIX=/usr/local
fi
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"

if [ -x "$(command -v code)" ]; then
  export EDITOR="code -wr"
else
  export EDITOR=vi
fi

#export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
