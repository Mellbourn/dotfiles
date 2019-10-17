###############################################################################
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases, functions, options, key bindings, etc.
###############################################################################
#echo ".zshrc running"
#zmodload zsh/zprof
#START=$(gdate +%s.%N)
#rm ~/.zcompdump ~/.zcompcache
source ~/.zplugin/bin/zplugin.zsh

fpath=(~/.zsh-personal-completions $fpath)
autoload -U zmv

###############################################################################
# remember your ancestor
###############################################################################
source ~/.bash_profile

# allow command line comments
setopt interactivecomments
###############################################################################
# directory navigation options
###############################################################################
setopt autocd autopushd pushdignoredups globcomplete
export DIRSTACKSIZE=10

###############################################################################
# history
###############################################################################
setopt correct histignorealldups incappendhistory extendedhistory histignorespace histreduceblanks hist_verify

export HISTFILE=~/.zsh_history
export SAVEHIST=$HISTSIZE

###############################################################################
# development
###############################################################################
export ANDROID_HOME=/usr/local/share/android-sdk

###############################################################################
# completion
###############################################################################
setopt nolistbeep
# Do menu-driven completion.
zstyle ':completion:*' menu select

# Color completion for some things.
# converted LSCOLORS using https://geoff.greer.fm/lscolors/
if [[ $OSTYPE == 'linux-gnu' ]]; then
  zstyle ':completion:*' list-colors 'di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=36:ow=36'
else
  zstyle ':completion:*' list-colors 'di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
fi

# formatting and messages
# http://www.masterzen.fr/2009/04/19/in-love-with-zsh-part-one/
zstyle ':completion:*' verbose yes
# describe different versions of completion. Test with: cd<tab>
zstyle ':completion:*:descriptions' format "%F{yellow}--- %d%f"
zstyle ':completion:*:messages' format '%d'
# when no match exists. Test with: cd fdjsakl<tab>
zstyle ':completion:*:warnings' format "%F{red}No matches for:%f %d"
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
# groups matches. Test with cd<tab>
zstyle ':completion:*' group-name ''
# this will only show up if a parameter flag has a name but no description
zstyle ':completion:*' auto-description 'specify: %d'
# this should make completion for some commands faster, haven't noticed though. saves in .zcompcache
zstyle ':completion::complete:*' use-cache 1

# activate approximate completion, but only after regular completion (_complete)
# zstyle ':completion:::::' completer _complete _approximate
# limit to 1 error
# zstyle ':completion:*:approximate:*' max-errors 1
# case insensitive completion
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'

# command line completion for kubectl, only activate if really needed, since this takes 0.2s to load
#if [ -x "$(command -v kubectl)" ]; then
#  source <(kubectl completion zsh)
#fi

###############################################################################
# zplugin - zsh plugin manager
###############################################################################
zplugin ice atload'!_zsh_git_prompt_precmd_hook' lucid
zplugin load woefe/git-prompt.zsh

zplugin ice wait'0a' lucid blockf
zplugin load zsh-users/zsh-completions

zplugin ice wait'2' lucid
zplugin load wfxr/forgit

zplugin ice wait'2' lucid
zplugin snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh

# command-not-found cuases lag in command prompt when starting
#zplugin ice wait'4' lucid
#zplugin snippet OMZ::plugins/command-not-found/command-not-found.plugin.zsh

zplugin ice wait'2' lucid
zplugin load djui/alias-tips

zplugin ice wait'2' lucid
zplugin snippet OMZ::plugins/dircycle/dircycle.plugin.zsh

zplugin ice wait'1' lucid
zplugin load supercrabtree/k

zplugin ice wait'2' lucid
zplugin light laggardkernel/zsh-thefuck

zplugin ice wait"2" lucid as"program" pick"$ZPFX/bin/git-alias" make"PREFIX=$ZPFX"
zplugin load tj/git-extras

#zplugin ice wait"2" lucid as"program" from"gh-r" mv"exa* -> exa" pick"$ZPFX/exa"
#zplugin light ogham/exa

# give extra color to exa
#zplugin ice wait'2' lucid atclone"dircolors -b LS_COLORS > c.zsh" atpull'%atclone' pick"c.zsh" nocompile'!'
#zplugin light trapd00r/LS_COLORS

# fasd takes 0.06s
zplugin ice wait'0' lucid atinit'eval "$(fasd --init auto)"'
zplugin light zdharma/null

# Not really plugins, but very good to have async anyway
# sourcing rvm takes 0.51s, so there will be a lag when it is sourced
# also, loading rvm as a zplugin will make it ignore the .ruby-version file if you are already inside that folder
zplugin ice wait'4' lucid atinit'if [ -s $HOME/.rvm/scripts/rvm ]; then source "$HOME/.rvm/scripts/rvm"; fi'
zplugin light zdharma/null

# python environent will also cause a lag
# this takes 0.166s
zplugin ice wait'2a' lucid atinit'command -v pyenv > /dev/null && eval "$(pyenv init -)"'
zplugin light zdharma/null
zplugin ice wait'2b' lucid atinit'command -v pyenv-virtualenv-init > /dev/null && eval "$(pyenv virtualenv-init -)"'
zplugin light zdharma/null
export WORKON_HOME=~/.py_virtualenvs
zplugin ice wait'2c' lucid atinit'if [ -x "$(command -v python3)" ]; then export VIRTUALENVWRAPPER_PYTHON=$(command -v python3); elif [ -x "$(command -v python3)" ]; then export VIRTUALENVWRAPPER_PYTHON=$(command -v python2); fi'
zplugin light zdharma/null
# this taskes 0.39s
zplugin ice wait'3' lucid atinit'if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then source /usr/local/bin/virtualenvwrapper.sh; fi'
zplugin light zdharma/null

# yarn must be run after node is defined, takes 0.31s, and only adds /usr/local/bin
#zplugin ice wait'2' lucid atinit'export PATH="$PATH:$(yarn global bin)"'
#zplugin light zdharma/null

# TODO: convert these to zplugin
# zplug "lukechilds/zsh-better-npm-completion", defer:2
# # I should only activate this when I need to generate completions
# #zplug "RobSis/zsh-completion-generator", defer:2
#
if [[ $OSTYPE == 'linux-gnu' ]]; then
  export PATH="$PATH:$(yarn global bin)"
#  zplug "holygeek/git-number", as:command, use:'git-*', lazy:true
  zplugin load zsh-users/zsh-syntax-highlighting
  zplugin ice wait"1" lucid atload"!_zsh_autosuggest_start"
  zplugin load zsh-users/zsh-autosuggestions
fi

###############################################################################
# add-ons installed by homebrew
###############################################################################

if [ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# fuzzy completion: ^R, ^T, ⌥C, **
export FZF_DEFAULT_COMMAND="fd --type file"
# --ansi makes fzf a bit slower, but I haven't really noticed, this preview is used for ** completion
export FZF_DEFAULT_OPTS="--ansi --select-1 --height 40%"
# this harmed kill -9 and git co **
#export FZF_COMPLETION_OPTS="--preview '(bat --color always --paging never {} 2> /dev/null || tree -C {}) 2> /dev/null | head -200' --preview-window=right:33%"
# this is slow for large sets, could be sorted with ' | sort -u' but that is just the initial sorting
export FZF_ALT_C_COMMAND='fd --type directory'
export FZF_ALT_C_OPTS="--preview 'CLICOLOR_FORCE=1 ls -GF {} | head -200' --preview-window=right:20%"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'less {} 2> /dev/null | head -200' --preview-window=right:33%"
[ -f ~/.fzf.`basename $SHELL` ] && source ~/.fzf.`basename $SHELL`

# set up direnv
if [ -x "$(command -v direnv)" ]; then
  eval "$(direnv hook $SHELL)"
fi
# this needs to be done just once, and you will be prompted about it
# direnv allow

###############################################################################
# prompt
###############################################################################

export ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg[magenta]%}"
export PROMPT_PERCENT_OF_LINE=20
function myPromptWidth() {
  echo $(( ${COLUMNS:-80} * PROMPT_PERCENT_OF_LINE / 100 ))
}
width_part='$(myPromptWidth)'
PROMPT="%K{106}%F%${width_part}<…<%4~%f%k%(?..%{$fg[red]%} %?%{$reset_color%})%(1j.%{$fg[cyan]%} %j%{$reset_color%}.) "
git_part='$(gitprompt)'
RPROMPT="${git_part} %F{106}%*%f"

###############################################################################
# fun functions
###############################################################################
function co() {
    local branches branch
    branches=$(git branch -a) &&
    branch=$(echo "$branches" | egrep -i "$1"  | fzf +s +m) &&
    git checkout $(echo "$branch" | sed "s:.* remotes/origin/::" | sed "s:.* ::")
}

# git co foo**<tab>
_fzf_complete_git() {
    ARGS="$@"
    local branches
    branches=$(git branch -vv --all)
    if [[ $ARGS == 'git co'* ]]; then
        _fzf_complete "--reverse --multi" "$@" < <(
            echo $branches
        )
    else
        eval "zle ${fzf_default_completion:-expand-or-complete}"
    fi
}
_fzf_complete_git_post() {
     awk '{print $1}' | sed "s:remotes/origin/::"
}

function go() {
    local repos repo
    repos=$(find $CODE_DIR -name .git -type d -maxdepth 3 -prune | egrep -i "$1"  | sed 's#/.git$##') &&
    repo=$(echo "$repos" | fzf +s +m) &&
    cd $(echo "$repo" | sed "s:.* remotes/origin/::" | sed "s:.* ::")
}

function fd() {
  command fd --color always $* | less
}
alias fd='noglob fd'

function rg() {
  command rg --pretty --smart-case --no-line-number $* | less
}
alias rg='noglob rg'

alias sd='noglob sd'

# highlighter
function h {
  grep --color=always -E "$1|$" $2 | less
}

# like z, but if there are alternatives show them in fzf
c() {
  local dir
  dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "${dir}" || return 1
}

# Use Ctrl-x,Ctrl-l to get the output of the last command
insert-last-command-output() {
LBUFFER+="$(eval $history[$((HISTCMD-1))])"
}
zle -N insert-last-command-output
bindkey "^X^L" insert-last-command-output

if [ -x "$(command -v bat)" ]; then
  # this MUST be run after woefe/git-prompt.zsh
  alias cat=bat
fi

###############################################################################
# Suffix aliases - http://zshwiki.org/home/examples/aliassuffix
###############################################################################
alias -s zip="zipinfo"

###############################################################################
# keybindings
###############################################################################
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward
# make zsh behave like bash for ctrl-u (fine to modify since most others will have bash)
bindkey "^U" backward-kill-line
# edit command line like in bash (zsh has 'fc' but it has to execute the command first)
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

###############################################################################
# Syntax highlighting for the shell
# syntax highlighting should be loaded after all widgets, to work with them
###############################################################################
if [ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets root)
export ZSH_HIGHLIGHT_STYLES[assign]='bg=18,fg=220' # dark blue background
export ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=219,bg=236' # pink
export ZSH_HIGHLIGHT_STYLES[commandseparator]='bg=21,fg=195' # light on dark blue
export ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=94' # brown
export ZSH_HIGHLIGHT_STYLES[globbing]='fg=99' # lilac
export ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=63' # softer lilac
export ZSH_HIGHLIGHT_STYLES[path]='fg=cyan,underline' # make folders same colors as in ls
export ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=243,underline'
export ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=white,underline'
export ZSH_HIGHLIGHT_STYLES[redirection]='fg=148,bold,bg=235' # >> yellow-green
export ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=182' # light pink

[[ -f /Users/klas.mellbourn/code/klarna/klarna-app/bin/completion/klapp.zsh.sh ]] && . /Users/klas.mellbourn/code/klarna/klarna-app/bin/completion/klapp.zsh.sh || true

# it is 0.05s faster to load compinit in turbo mode, but all completions should be loaded with zplugin then
#zplugin ice wait'0z' lucid atinit'zpcompinit; zpcdreplay'
#zplugin light zdharma/null
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit
zplugin cdreplay

#echo ".zshrc finished:"
#END=$(gdate +%s.%N)
#echo "$END - $START" | bc
#zprof
