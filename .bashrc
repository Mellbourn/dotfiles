if [ -f /usr/local/opt/nvm/nvm.sh ]; then
  export NVM_DIR="$HOME/.nvm"
  . "/usr/local/opt/nvm/nvm.sh"
fi

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export HISTFILESIZE=2500
# stop duplicates in history
export HISTCONTROL=ignoreboth:erasedups
