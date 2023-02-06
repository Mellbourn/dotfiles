###############################################################################
# .bash_profile is read by login shells, but not run by subshells
###############################################################################
# shellcheck shell=bash
# shellcheck disable=SC1091
#START=$(gdate +%s.%N)
#echo ".bash_profile running"
# fortune takes 0.017s
#fortune

if [ -f "$HOME"/.profile ]; then
  source "$HOME"/.profile
fi

# start tmux unless you are already in tmux, you have set NO_TMUX or you are starting up VSCode from Spotlight
if [ -n "$PS1" ] && [ -z "$TMUX" ] && [ -z "$NO_TMUX" ] && command -v tmux &>/dev/null && [ -z "$VSCODE_PID" ]; then
  # use this "if" to suppress tmux in *debugging* in vscode
  if [ -z "$VSCODE_WORKSPACE_FOLDER" ]; then
    exec "$HOME"/bin/tmux-attach-or-new
  fi
fi

PROCESSOR_ARCHITECTURE=$(uname -p)
export PROCESSOR_ARCHITECTURE

if [ -x "$(command -v lsb_release)" ] && [[ $(lsb_release -si) == 'Ubuntu' ]]; then
  export OS_UBUNTU=1
  if dpkg -l ubuntu-desktop >/dev/null 2>&1; then
    export UBUNTU_DESKTOP=1
  fi
fi

UNAME=$(uname)
if [[ $UNAME == 'Linux' ]]; then
  export UNAME_LINUX=1
  if [[ $(uname -m) == *"64"* ]]; then
    export UNAME_LINUX_64=1
  fi
elif [[ $UNAME == 'Darwin' ]]; then
  export UNAME_MACOS=1
fi

if grep -q Raspbian /etc/os-release 2>/dev/null; then
  export DOTFILES_LITE=1
fi

if [[ $(hostname) == *"MacBook-Pro-16"* ]]; then
  export FIRSTVET=1
fi

if [[ -n $FIRSTVET ]]; then
  export GITHUB_ORGANIZATION=firstvetcom
fi

if [ -n "$SHELL" ]; then
  SHELLNAME=${SHELL//*\//}
  export SHELLNAME
else
  SHELLNAME=$(ps -o comm= -c "$$" | sed 's/-//')
  export SHELLNAME
fi

if [ -f "$HOME"/.protocol ]; then
  source "$HOME"/.protocol
fi

if [ -f "$HOME"/.bashrc ]; then
  source "$HOME"/.bashrc
fi

if [ -f "$HOME"/.local_settings ]; then
  source "$HOME"/.local_settings
fi

addFirstInPath() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="$1${PATH:+":$PATH"}"
  fi
}
addLastInPath() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="${PATH:+"$PATH:"}$1"
  fi
}
### environment variables
addLastInPath "$HOMEBREW_PREFIX/sbin"
export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
if [ -d /snap ]; then
  addLastInPath "/snap/croc/current"
fi
addFirstInPath "$HOME/.manually-installed/bin"
addLastInPath "$HOME/.manually-installed/lsd"
addFirstInPath "$HOME/.local/bin"
# this is needed while we are using an old awscli
addLastInPath "$HOMEBREW_PREFIX/opt/awscli@1/bin"
addFirstInPath "$HOME"/.cargo/bin
addFirstInPath "$HOME"/bin
addFirstInPath "$HOME"/bin/mts

export CLICOLOR=1
export GCAL='--starting-day=Monday --iso-week-number=yes --with-week-number --cc-holidays=SE'
if [[ -n $UNAME_LINUX ]]; then
  # WSL
  #export LSCOLORS=gxfxcxdxbxegedabaggxgx
  # LS_COLORS now set by trapd00r/LS_COLORS
  #export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=36:ow=36'
  alias ls='ls --color=auto'
else
  # macOS
  # fix for ENFILE: file table overflow
  ulimit -n 20000

  # translated from LS_COLORS using https://geoff.greer.fm/lscolors/
  export LSCOLORS=gxfxcxdxbxegedabagacad
  # LS_COLORS now set by trapd00r/LS_COLORS
  #export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
fi
if (($(command less --version | head -1 | cut -d ' ' -f2) >= 590)); then
  LESSOPEN="| $(which highlight) %s --quiet --force --out-format xterm256 --style darkplus"
  export LESSOPEN
  # note: --file-size takes noticable extra startup time on large (100k) files
  export LESS=" --LONG-PROMPT --RAW-CONTROL-CHARS --ignore-case --HILITE-UNREAD --status-column --quiet \
    --no-histdups --save-marks --quit-if-one-screen --incsearch --use-color"
else
  LESSOPEN="| $(which highlight) %s --quiet --force --out-format ansi"
  export LESSOPEN
  export LESS=" --LONG-PROMPT --RAW-CONTROL-CHARS --ignore-case --HILITE-UNREAD --status-column --quiet"
fi
# git-delta can't handle a status column
export DELTA_PAGER="less -+J -+W"
# why is this important? This doesn't always work on old raspbian
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
# enable flipper compilation
#export FLIPPER_ENABLED=1
# make gpg prompt work, otherwise I get "Inappropriate ioctl for device"
GPG_TTY=$(tty)
export GPG_TTY
export CHEATCOLORS=true
# git checkout should only complete local branches (unless origin/), since I have fzf for more complex scenarios
export GIT_COMPLETION_CHECKOUT_NO_GUESS=1
export FLIPPER_ENABLED=1
# GENCOMPL_FPATH is only used by zsh, but is needed by bootstrap
export GENCOMPL_FPATH=~/.zsh-personal-completions/generated
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

if [[ $SHELL == *bash ]]; then
  # bash shell options
  shopt -s autocd globstar
  ### prompt
  if [ -x "$(command -v brew)" ] && [ -f "$HOMEBREW_PREFIX"/etc/bash_completion ]; then
    . "$HOMEBREW_PREFIX"/etc/bash_completion
  fi

  # ctrl-p and ctrl-n now searches history
  bind '"":history-search-backward'
  bind '"":history-search-forward'
fi

# this line is added by iTerm command "Install shell integration"
#test -e "${HOME}/.iterm2_shell_integration.$SHELLNAME" && source "${HOME}/.iterm2_shell_integration.$SHELLNAME"

###############################################################################
# Java and Android development
###############################################################################
if [ -d "$HOME/Library/Android/sdk" ]; then
  export ANDROID_HOME=$HOME/Library/Android/sdk
elif [ -d "$HOMEBREW_PREFIX/share/android-sdk" ]; then
  export ANDROID_HOME=$HOMEBREW_PREFIX/share/android-sdk
fi

if [ ! -x "${ASDF_DIR:-$HOME/.asdf}"/shims/java ]; then
  if [ -d "/Applications/Android Studio.app/Contents/jre/Contents/Home" ]; then
    export JAVA_HOME="/Applications/Android Studio.app/Contents/jre/Contents/Home"
  elif [ -f /usr/libexec/java_home ] && ! /usr/libexec/java_home 2>&1 | grep -q 'Unable to locate a Java Runtime'; then
    JAVA_HOME_FROM_COMMAND="$(/usr/libexec/java_home -v 1.8)"
    if [[ $JAVA_HOME_FROM_COMMAND == *"JavaAppletPlugin"* ]]; then
      JAVA_HOME=$(print /Library/Java/JavaVirtualMachines/jdk1.8.*.jdk/Contents/Home)
      export JAVA_HOME
    else
      export JAVA_HOME=$JAVA_HOME_FROM_COMMAND
    fi
  fi
fi

addLastInPath "$ANDROID_HOME/tools/bin"
addLastInPath "$ANDROID_HOME/platform-tools"
addFirstInPath /Applications/Android\ Studio.app/Contents/jre/Contents/Home/bin

# bc settings
export BC_ENV_ARGS="-l -q"

# ansible needs sqlite3
# macOS provides an older sqlite3.
#If you need to have this software first in your PATH run:
#  echo 'export PATH="$HOMEBREW_PREFIX/opt/sqlite/bin:$PATH"' >> "$HOME"/.bash_profile
addFirstInPath "$HOMEBREW_PREFIX/opt/sqlite/bin"
# For compilers to find this software you may need to set:
#    LDFLAGS:  -L$HOMEBREW_PREFIX/opt/sqlite/lib
#    CPPFLAGS: -I$HOMEBREW_PREFIX/opt/sqlite/include
# For pkg-config to find this software you may need to set:
#    PKG_CONFIG_PATH: $HOMEBREW_PREFIX/opt/sqlite/lib/pkgconfig

# ansible also needed openssl
# If you need to have this software first in your PATH run:
#  echo 'export PATH="$HOMEBREW_PREFIX/opt/openssl@1.1/bin:$PATH"' >> "$HOME"/.bash_profile
addFirstInPath "$HOMEBREW_PREFIX/opt/openssl@1.1/bin"
# For compilers to find this software you may need to set:
#    LDFLAGS:  -L$HOMEBREW_PREFIX/opt/openssl@1.1/lib
#    CPPFLAGS: -I$HOMEBREW_PREFIX/opt/openssl@1.1/include
# For pkg-config to find this software you may need to set:
#    PKG_CONFIG_PATH: $HOMEBREW_PREFIX/opt/openssl@1.1/lib/pkgconfig

### aliases
. "$HOME"/.aliases

#echo ".bash_profile took:"
#END=$(gdate +%s.%N)
#echo "$END - $START" | bc
