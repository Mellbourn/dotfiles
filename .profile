###############################################################################
# .profile is read by many shells in the absence of their own shell-specific config files.
###############################################################################
echo ".profile running"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
