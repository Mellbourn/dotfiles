###############################################################################
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases, functions, options, key bindings, etc.
###############################################################################
echo ".zshrc running"
###############################################################################
# remember your ancestor
###############################################################################
source ~/.bash_profile

###############################################################################
# options!
###############################################################################
setopt autocd autopushd correct pushdignoredups globcomplete
export DIRSTACKSIZE=10

###############################################################################
# history
###############################################################################
setopt histignoredups histignorealldups incappendhistory extendedhistory histignorespace

export HISTFILE=~/.zsh_history
export SAVEHIST=$HISTSIZE

###############################################################################
# completion
###############################################################################
# Do menu-driven completion.
zstyle ':completion:*' menu select

# Color completion for some things.
# http://linuxshellaccount.blogspot.com/2008/12/color-completion-using-zsh-modules-on.html
zstyle ':completion:*' list-colors ${(s.:.)LSCOLORS}

# formatting and messages
# http://www.masterzen.fr/2009/04/19/in-love-with-zsh-part-one/
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format "$fg[yellow]%B--- %d%b"
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format "$fg[red]No matches for:$reset_color %d"
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# activate approximate completion, but only after regular completion (_complete)
zstyle ':completion:::::' completer _complete _approximate
# limit to 1 error
zstyle ':completion:*:approximate:*' max-errors 1
# case insensitive completion
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'

###############################################################################
# zplug - zsh plugin manager
###############################################################################
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'

zplug "zsh-users/zsh-autosuggestions"
zplug "themes/wedisagree", from:oh-my-zsh

# Set the priority when loading
# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
# (If the defer tag is given 2 or above, run after compinit command)
zplug "zsh-users/zsh-syntax-highlighting", defer:2


# zplug check returns true if all packages are installed
# Therefore, when it returns false, run zplug install
if ! zplug check; then
    zplug install
fi

# source plugins and add commands to the PATH
zplug load

###############################################################################
# keybindings
###############################################################################
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward
