###############################################################################
# .profile is read by many shells in the absence of their own shell-specific config files.
###############################################################################
# shellcheck shell=bash
#echo ".profile running"

# directory for git repositories, should be set up before tmux starts
export CODE_DIR=~/code

if [ -z "$HOMEBREW_PREFIX" ]; then
  if [ -d "/opt/homebrew" ]; then
    HOMEBREW_PREFIX="/opt/homebrew"
  elif [ -d "/home/linuxbrew/.linuxbrew" ]; then
    HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  else
    HOMEBREW_PREFIX="/usr/local"
  fi
  export HOMEBREW_PREFIX
fi

# in order to force $HOMEBREW_PREFIX/bin to be unique and early in path, remove it first
PATH="${PATH//:$HOMEBREW_PREFIX\/bin/}"
if [ -d "$HOMEBREW_PREFIX/bin" ]; then
  PATH="$HOMEBREW_PREFIX/bin${PATH:+":$PATH"}"
fi
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"

if [ -x "$(command -v code)" ]; then
  export EDITOR="code -wr"
else
  export EDITOR=vi
fi
