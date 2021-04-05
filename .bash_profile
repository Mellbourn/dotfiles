###############################################################################
# .bash_profile is read by login shells, but not run by subshells
###############################################################################
#START=$(gdate +%s.%N)
#echo ".bash_profile running"
# fortune takes 0.017s
#fortune

if [ -f ~/.profile ]; then
  source ~/.profile
fi

# only start tmux if you are not already in tmux, or you are starting up Visual Studio Code from spotlight
if [ -n "$PS1" ] && [ -z "$TMUX" ] && [ -z "$NO_TMUX" ] && command -v tmux &>/dev/null && [ -z "$VSCODE_PID" ]; then
  # use this "if" to suppress tmux in *debugging* in vscode
  if [ -z "$VSCODE_WORKSPACE_FOLDER" ]; then
    exec ~/bin/tmux-attach-or-new
  fi
fi

export PROCESSOR_ARCHITECTURE=$(uname -p)

if [ -x "$(command -v lsb_release)" ] && [[ $(lsb_release -si) == 'Ubuntu' ]]; then
  export OS_UBUNTU=1
  if dpkg -l ubuntu-desktop >/dev/null 2>&1; then
    export UBUNTU_DESKTOP=1
  fi
fi

UNAME=$(uname)
if [[ $UNAME == 'Linux' ]]; then
  export UNAME_LINUX=1
elif [[ $UNAME == 'Darwin' ]]; then
  export UNAME_MACOS=1
fi

if grep -q Raspbian /etc/os-release 2>/dev/null; then
  export DOTFILES_LITE=1
fi

if [ -n "$SHELL" ]; then
  export SHELLNAME=$(echo $SHELL | sed 's#.*/##')
else
  export SHELLNAME=$(ps -o comm= -c "$$" | sed 's/-//')
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
export PATH=~/bin:$PATH:$HOMEBREW_PREFIX/sbin
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi
if [ -d $HOMEBREW_PREFIX/opt/awscli@1/bin ]; then
  # this is needed while we are using an old awscli
  export PATH=$PATH:$HOMEBREW_PREFIX/opt/awscli@1/bin
fi
if [ -d ~/.cargo/bin ]; then
  export PATH=$PATH:~/.cargo/bin
fi
export CLICOLOR=1
export GCAL='--starting-day=Monday --iso-week-number=yes --with-week-number --cc-holidays=SE'
if [[ -n $UNAME_LINUX ]]; then
  # WSL
  # export LSCOLORS=gxfxcxdxbxegedabaggxgx
  export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=36:ow=36'
  alias ls='ls --color=auto'

  export LESSOPEN="| $(which highlight) %s --out-format ansi --quiet --force"
  export LESS=" --LONG-PROMPT --RAW-CONTROL-CHARS --ignore-case --HILITE-UNREAD --status-column"
else
  # macOS
  # fix for ENFILE: file table overflow
  ulimit -n 20000

  export LSCOLORS=gxfxcxdxbxegedabagacad
  # for gnu ls, converted LSCOLORS using https://geoff.greer.fm/lscolors/
  export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
  export LESSOPEN="| $(which highlight) %s --out-format xterm256 --quiet --force --style darkplus"
  export LESS=" --LONG-PROMPT --RAW-CONTROL-CHARS --ignore-case --quit-if-one-screen --HILITE-UNREAD --status-column"
fi
# git-delta can't handle a status column
export DELTA_PAGER="less -+J -+W"
# this is to compile vim
export C_INCLUDE_PATH=/System/Library/Frameworks/Python.framework/Headers
# why is this important? This doesn't always work on old raspbian
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
# make gpg prompt work, otherwise I get "Inappropriate ioctl for device"
export GPG_TTY=$(tty)
export CHEATCOLORS=true
# git checkout should only complete local branches (unless origin/), since I have fzf for more complex scenarios
export GIT_COMPLETION_CHECKOUT_NO_GUESS=1
# this takes about 0.02s and is used by some Klarna seach docker containers
if [ -x "$(command -v ifconfig)" ]; then
  HOST_IP=$(ifconfig | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v 127.0.0.1 | awk '{ print $2 }' | cut -f2 -d: | head -n1)
else
  HOST_IP=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
fi
export HOST_IP=$HOST_IP
set -o emacs

function current_context() {
  osascript -e 'tell application "ControlPlane"' -e 'get current context' -e 'end tell'
}

if [[ $BASH_VERSINFO == 4 ]]; then
  # bash shell options
  shopt -s autocd globstar
fi
if [[ $SHELL == *bash ]]; then
  ### prompt
  if [ -x "$(command -v brew)" ] && [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi

  export PROMPT_DIRTRIM=3
  if [ -f $HOMEBREW_PREFIX/share/liquidprompt ]; then
    . $HOMEBREW_PREFIX/share/liquidprompt
  fi

  # ctrl-p and ctrl-n now searches history
  bind '"":history-search-backward'
  bind '"":history-search-forward'
fi

# this line is added by iTerm command "Install shell integration"
#test -e "${HOME}/.iterm2_shell_integration.$SHELLNAME" && source "${HOME}/.iterm2_shell_integration.$SHELLNAME"

if [ -f /usr/libexec/java_home ] && ! /usr/libexec/java_home 2>&1 | grep -q 'Unable to locate a Java Runtime'; then
  JAVA_HOME_FROM_COMMAND="$(/usr/libexec/java_home -v 1.8)"
  if [[ $JAVA_HOME_FROM_COMMAND == *"JavaAppletPlugin"* ]]; then
    export JAVA_HOME=$(print /Library/Java/JavaVirtualMachines/jdk1.8.*.jdk/Contents/Home)
  else
    export JAVA_HOME=$JAVA_HOME_FROM_COMMAND
  fi
fi

export PATH=$HOME/.nodebrew/current/bin:$PATH

# ansible needs sqlite3
# macOS provides an older sqlite3.
#If you need to have this software first in your PATH run:
#  echo 'export PATH="$HOMEBREW_PREFIX/opt/sqlite/bin:$PATH"' >> ~/.bash_profile
export PATH="$HOMEBREW_PREFIX/opt/sqlite/bin:$PATH"
# For compilers to find this software you may need to set:
#    LDFLAGS:  -L$HOMEBREW_PREFIX/opt/sqlite/lib
#    CPPFLAGS: -I$HOMEBREW_PREFIX/opt/sqlite/include
# For pkg-config to find this software you may need to set:
#    PKG_CONFIG_PATH: $HOMEBREW_PREFIX/opt/sqlite/lib/pkgconfig

# ansible also needed openssl
# If you need to have this software first in your PATH run:
#  echo 'export PATH="$HOMEBREW_PREFIX/opt/openssl@1.1/bin:$PATH"' >> ~/.bash_profile
export PATH="$HOMEBREW_PREFIX/opt/openssl@1.1/bin:$PATH"
# For compilers to find this software you may need to set:
#    LDFLAGS:  -L$HOMEBREW_PREFIX/opt/openssl@1.1/lib
#    CPPFLAGS: -I$HOMEBREW_PREFIX/opt/openssl@1.1/include
# For pkg-config to find this software you may need to set:
#    PKG_CONFIG_PATH: $HOMEBREW_PREFIX/opt/openssl@1.1/lib/pkgconfig

### aliases
. ~/.aliases

#echo ".bash_profile took:"
#END=$(gdate +%s.%N)
#echo "$END - $START" | bc
