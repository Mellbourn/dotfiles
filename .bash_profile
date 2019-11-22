###############################################################################
# .bash_profile is read by login shells, but not run by subshells
###############################################################################
#START=$(gdate +%s.%N)
#echo ".bash_profile running"
# fortune takes 0.017s
#fortune

if [ -n "$PS1" ] && [ -z "$TMUX" ] && [ -z "$NO_TMUX" ] && command -v tmux &> /dev/null; then
  exec ~/bin/tmux-attach-or-new
fi

# fix for ENFILE: file table overflow
ulimit -n 20000

if [[ `uname` == 'Linux' ]]
then
  export UNAME_LINUX=1
fi
if grep -q Raspbian /etc/os-release 2> /dev/null
then
  export DOTFILES_LITE=1
fi
if [ -n "$SHELL" ]; then
  export SHELLNAME=`echo $SHELL|sed 's#.*/##'`
else
  export SHELLNAME=`ps -o comm= -c "$$"|sed 's/-//'`
fi

if [ -f ~/.profile ]; then
  source ~/.profile
fi

if [ -f ~/.protocol ]; then
  source ~/.protocol
fi

if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

if [ -f ~/.local_settings ]; then
  source ~/.local_settings
fi

### environment variables
export PATH=$PATH:~/bin
if [ -d "$HOME/.local/bin" ] ; then
  PATH="$HOME/.local/bin:$PATH"
fi
if [ -d ~/.cargo/bin ]; then
  export PATH=$PATH:~/.cargo/bin
fi
export CLICOLOR=1
if [[ -n $UNAME_LINUX ]]; then
  # WSL
  # export LSCOLORS=gxfxcxdxbxegedabaggxgx
  export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=36:ow=36'
  alias ls='ls --color=auto'

  export LESSOPEN="| $(which highlight) %s --out-format ansi --quiet --force"
  export LESS=" --LONG-PROMPT --RAW-CONTROL-CHARS --ignore-case --HILITE-UNREAD --status-column"
else
  # macOS
  export LSCOLORS=gxfxcxdxbxegedabagacad
  export LESSOPEN="| $(which highlight) %s --out-format xterm256 --quiet --force --style darkplus"
  export LESS=" --LONG-PROMPT --RAW-CONTROL-CHARS --ignore-case --quit-if-one-screen --HILITE-UNREAD --status-column"
fi
# this is to compile vim
export C_INCLUDE_PATH=/System/Library/Frameworks/Python.framework/Headers
# why is this important? This doesn't always work on old raspbian
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
if [ -x "$(command -v code)" ]; then
  export EDITOR="code --wait"
else
  export EDITOR=vi
fi
# make gpg prompt work, otherwise I get "Inappropriate ioctl for device"
export GPG_TTY=$(tty)
export CHEATCOLORS=true
# git checkout should only complete local branches (unless origin/), since I have fzf for more complex scenarios
export GIT_COMPLETION_CHECKOUT_NO_GUESS=1

set -o emacs

function current_context {
   osascript -e 'tell application "ControlPlane"' -e 'get current context' -e 'end tell'
}

if [[ $BASH_VERSINFO == 4 ]]; then
  # bash shell options
  shopt -s autocd globstar
fi
if  [[ $SHELL == *bash ]];
then
  ### prompt
  if [ -x "$(command -v brew)" ] && [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi

  export PROMPT_DIRTRIM=3
  if [ -f /usr/local/share/liquidprompt ]; then
    . /usr/local/share/liquidprompt
  fi

  # ctrl-p and ctrl-n now searches history
  bind '"":history-search-backward'
  bind '"":history-search-forward'
fi

# this line is added by iTerm command "Install shell integration"
#test -e "${HOME}/.iterm2_shell_integration.$SHELLNAME" && source "${HOME}/.iterm2_shell_integration.$SHELLNAME"

if [ -f /usr/libexec/java_home ]; then
  export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
fi

export PATH=$HOME/.nodebrew/current/bin:$PATH

# ansible needs sqlite3
# macOS provides an older sqlite3.
#If you need to have this software first in your PATH run:
#  echo 'export PATH="/usr/local/opt/sqlite/bin:$PATH"' >> ~/.bash_profile
export PATH="/usr/local/opt/sqlite/bin:$PATH"
# For compilers to find this software you may need to set:
#    LDFLAGS:  -L/usr/local/opt/sqlite/lib
#    CPPFLAGS: -I/usr/local/opt/sqlite/include
# For pkg-config to find this software you may need to set:
#    PKG_CONFIG_PATH: /usr/local/opt/sqlite/lib/pkgconfig

# ansible also needed openssl
# If you need to have this software first in your PATH run:
#  echo 'export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"' >> ~/.bash_profile
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
# For compilers to find this software you may need to set:
#    LDFLAGS:  -L/usr/local/opt/openssl@1.1/lib
#    CPPFLAGS: -I/usr/local/opt/openssl@1.1/include
# For pkg-config to find this software you may need to set:
#    PKG_CONFIG_PATH: /usr/local/opt/openssl@1.1/lib/pkgconfig

### aliases
. ~/.aliases

#echo ".bash_profile took:"
#END=$(gdate +%s.%N)
#echo "$END - $START" | bc
