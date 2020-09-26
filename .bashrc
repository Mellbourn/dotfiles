###############################################################################
# .bashrc subshells run only this, not .bash_profile
###############################################################################
#echo ".bashrc running"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# history settings
# HISTSIZE 2500 had good performance (250ms startup, contains about three to four months history)
export HISTSIZE=9999
if  [[ $SHELL == *bash ]]; then
  export HISTFILESIZE=$HISTSIZE
  # make sure history is saved
  shopt -s histappend
  # http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
  export HISTFILE=~/.bash_history_not_truncated
  # stop duplicates in history
  export HISTCONTROL=ignoreboth:erasedups
  # and synced https://unix.stackexchange.com/questions/18212/bash-history-ignoredups-and-erasedups-setting-conflict-with-common-history
  PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND"

  [ -f ~/.fzf.`basename $SHELL` ] && source ~/.fzf.`basename $SHELL`
fi
