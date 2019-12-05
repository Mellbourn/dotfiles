###############################################################################
# .profile is read by many shells in the absence of their own shell-specific config files.
###############################################################################
#echo ".profile running"

# directory for git repositories, should be set up before tmux starts
export CODE_DIR=~/code

if [ -x "$(command -v code)" ]; then
  export EDITOR="code -w -r"
else
  export EDITOR=vi
fi

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
