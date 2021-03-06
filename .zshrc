###############################################################################
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases, functions, options, key bindings, etc.
###############################################################################
#echo ".zshrc running"
#zmodload zsh/zprof
#START=$(gdate +%s.%N)
#rm ~/.zcompdump ~/.zcompcache
source ~/.zinit/bin/zinit.zsh

fpath=(~/.zsh-personal-functions ~/.zsh-personal-completions $fpath)
autoload -U zmv
# personal functions in ~/.zsh-personal-functions
autoload -Uz yb

# helping brew completion is needed if HOMEBREW_PREFIX is not /usr/local
FPATH=$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH

###############################################################################
# remember your ancestor
###############################################################################
source ~/.bash_profile

# misc
setopt interactivecomments long_list_jobs

# word movement should stop on slashes
export WORDCHARS=$WORDCHARS:s:/:
###############################################################################
# directory navigation options
###############################################################################
setopt autocd autopushd pushdignoredups globcomplete
export DIRSTACKSIZE=10

###############################################################################
# history
###############################################################################
# replace histignorealldups with histsavenodups to make zsh autosuggestion option match_prev_cmd work
setopt correct histsavenodups incappendhistory extendedhistory histignorespace histreduceblanks hist_verify hist_fcntl_lock

export HISTFILE=~/.zsh_history
export SAVEHIST=$HISTSIZE

###############################################################################
# dynamic aliases
###############################################################################
if [ -x "$(command -v grc)" ]; then
  # colorize standard commands. Possibilites here /opt/homebrew/share/grc
  # don't add
  # * netstat - waits for command to finish
  # * ifconfig - completion breaks
  # * ps - completion buggy
  # some problems
  # * diff - crashes sometimes
  # * env - if given utility parameter, it modifies output formatting
  for a in df diff dig du env id last lsof traceroute ulimit uptime whois
  do
    # function rather than alias is needed to preserve completions
    $a() {
      # could forcing color be dangerous for some pipes? It is needed for less
      grc --colour=on $0 "$@"
    }
  done
fi

###############################################################################
# development
###############################################################################
export ANDROID_HOME=$HOMEBREW_PREFIX/share/android-sdk

###############################################################################
# completion
###############################################################################
setopt nolistbeep
# Do menu-driven completion.
zstyle ':completion:*' menu select

# Color completion for some things.

# make file completion match ls colors
zstyle ':completion:*' list-colors $LS_COLORS

# formatting and messages
# http://www.masterzen.fr/2009/04/19/in-love-with-zsh-part-one/
zstyle ':completion:*' extra-verbose yes
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
# zinit - zsh plugin manager
###############################################################################
zinit ice atload'!_zsh_git_prompt_precmd_hook' lucid
zinit load woefe/git-prompt.zsh

zinit ice wait'0a' lucid blockf
zinit load zsh-users/zsh-completions

zinit ice wait'0' lucid
zinit snippet OMZP::magic-enter
MAGIC_ENTER_GIT_COMMAND="l"
MAGIC_ENTER_OTHER_COMMAND="l"

zinit ice wait'1' lucid
zinit load supercrabtree/k

zinit ice wait'1' atload"zpcdreplay" atclone'./zplug.zsh' lucid
zinit load g-plane/zsh-yarn-autocompletions

zinit ice wait'2' lucid if'[[ -x "$(command -v fzf)" ]]'
zinit load wfxr/forgit

zinit ice wait'2' lucid
zinit snippet OMZP::colored-man-pages

# command-not-found cuases lag in command prompt when starting, also makes unkown commands slower
#zinit ice wait'4' lucid atinit'source "$HOMEBREW_PREFIX/Homebrew/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"'
#zinit light zdharma/null

zinit ice wait'2' lucid
zinit load djui/alias-tips

zinit ice wait'2' lucid
zinit snippet OMZP::dircycle

zinit ice wait'2' lucid atinit'alias f=fuck'
zinit light laggardkernel/zsh-thefuck

# load diff-so-fancy if not already present (it can have been installed by homebrew)
zinit ice wait'2' lucid as"program" pick"bin/git-dsf" if'[[ ! -x "$(command -v diff-so-fancy)" ]]'
zinit light zdharma/zsh-diff-so-fancy

zinit ice wait'2' lucid as"completion"
zinit light nilsonholger/osx-zsh-completions

zinit ice wait'2' lucid
zinit light mellbourn/zabb

# fzf-tab doesn't currently work in Ubuntu https://github.com/Aloxaf/fzf-tab/issues/189
zinit ice wait'2' lucid
zinit load Aloxaf/fzf-tab
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -l --blocks name,permission,size,date --color=always --icon=always $realpath'
zstyle ':fzf-tab:complete:ls:*' fzf-preview '[ -f "$realpath" ] && bat --color=always $realpath || lsd -l --blocks name,permission,size,date --color=always --icon=always $realpath'
zstyle ':fzf-tab:complete:export:*' fzf-preview 'printenv $word'
zstyle ':fzf-tab:complete:ssh:*' fzf-preview 'ping -c1 $word'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# this was cool but a bit too slow - adds blank lines after ls after a while
#zinit ice wait'2' lucid
#zinit light marlonrichert/zsh-autocomplete
#zstyle ':autocomplete:*' config off
#zstyle ':autocomplete:*' min-input 2
##zstyle ':autocomplete:*' min-delay 0.4
#zstyle ':autocomplete:tab:*' insert-unambiguous yes
#zstyle ':autocomplete:tab:*' widget-style menu-select
# when fzf work test this
#zstyle ':autocomplete:tab:*' fzf-completion yes
# this doesn't really repair ctrl-space
#bindkey $key[ControlSpace] set-mark-command

# some nice OMZ functions: take, alias, try_alias_value, omz_urlencode, omz_urldecode
zinit ice wait'4' lucid
zinit snippet OMZ::lib/functions.zsh

zinit ice wait'4' lucid
zinit snippet OMZ::plugins/web-search/web-search.plugin.zsh

zinit ice wait'4' lucid
zinit light paulirish/git-open

zinit ice wait'4' lucid
zinit light peterhurford/git-it-on.zsh

# set up a bell after command that run longer than this many seconds
zbell_duration=180
zbell_ignore+=($EDITOR $PAGER vim code less bat cat man run-help)
zinit ice wait'4' lucid
zinit snippet OMZP::zbell
# test reporting time too for heavy operations
export REPORTTIME=300

zinit ice wait'4' lucid atload'ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(autopair-insert)'
zinit light hlissner/zsh-autopair

# exa doesn't download well on WSL
# zinit ice wait'2' lucid as"program" from"gh-r" mv"exa* -> exa" pick"$ZPFX/exa"
# zinit light ogham/exa
export TIME_STYLE=long-iso
export EXA_COLORS="uu=38;5;248:da=1;34:di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
if [ -x "$(command -v exa)" ]; then
  function x() {
    command exa -F --color-scale --group-directories-first --color=always --git-ignore --git -x $*
  }
  function xl() {
    command exa -F --color-scale --group-directories-first --color=always --git-ignore --git -l $* | less -r
  }
else
  alias x=l
  alias xl=ll
fi

# give extra color to exa
#zinit ice wait'2' lucid atclone"dircolors -b LS_COLORS > c.zsh" atpull'%atclone' pick"c.zsh" nocompile'!'
#zinit light trapd00r/LS_COLORS

if [ -d "$HOMEBREW_PREFIX/share/z.lua" ]; then
  export _ZL_MATCH_MODE=1
  zinit ice wait'0' lucid atinit'source $HOMEBREW_PREFIX/share/z.lua/z.lua.plugin.zsh'
  zinit light zdharma/null
  alias c="z -I"
elif [ -x "$(command -v zoxide)" ]; then
  export _ZO_MAXAGE=400
  export _ZO_EXCLUDE_DIRS=$HOME
  zinit ice wait'0' lucid atinit'eval "$(zoxide init --no-aliases zsh)" && alias z=__zoxide_z c=__zoxide_zi'
  zinit light zdharma/null
else
  # zoxide not available on old raspberry pi. fasd is pure shell, but slow: fasd takes 0.06s
  zinit ice wait'0' lucid as"program" pick"$ZPFX/fasd" make"PREFIX=$ZPFX install" atinit'eval "$(fasd --init auto)" && alias sd="noglob sd"'
  zinit light clvv/fasd
  c() {
    local dir
    dir="$(fasd -Rdl "$1" | $FZF -1 -0 --no-sort +m)" && cd "${dir}" || return 1
  }
fi

if [ -z "$DOTFILES_LITE" ]
then
  # Not really plugins, but very good to have async anyway
  # sourcing rvm takes 0.51s, so there will be a lag when it is sourced
  # also, loading rvm as a zinit will make it ignore the .ruby-version file if you are already inside that folder
  zinit ice wait'4' lucid atinit'if [ -s $HOME/.rvm/scripts/rvm ]; then source "$HOME/.rvm/scripts/rvm"; fi'
  zinit light zdharma/null

  # # python environent will also cause a lag
  # # this takes 0.166s
  # zinit ice wait'2a' lucid atinit'command -v pyenv > /dev/null && eval "$(pyenv init -)"'
  # zinit light zdharma/null
  # zinit ice wait'2b' lucid atinit'command -v pyenv-virtualenv-init > /dev/null && eval "$(pyenv virtualenv-init -)"'
  # zinit light zdharma/null
  # export WORKON_HOME=~/.py_virtualenvs
  # zinit ice wait'2c' lucid atinit'if [ -x "$(command -v python3)" ]; then export VIRTUALENVWRAPPER_PYTHON=$(command -v python3); elif [ -x "$(command -v python3)" ]; then export VIRTUALENVWRAPPER_PYTHON=$(command -v python2); fi'
  # zinit light zdharma/null
  # # this taskes 0.39s
  # # this has to be loaded much later than the preceding plugins, otherwise you will get "No module named virtualenvwrapper  "
  # zinit ice wait'10' lucid atinit'if [ -f $HOMEBREW_PREFIX/bin/virtualenvwrapper.sh ]; then source $HOMEBREW_PREFIX/bin/virtualenvwrapper.sh; fi'
  # zinit light zdharma/null

  # yarn must be run after node is defined, takes 0.31s, and only adds $HOMEBREW_PREFIX/bin
  #zinit ice wait'2' lucid atinit'export PATH="$PATH:$(yarn global bin)"'
  #zinit light zdharma/null
fi

# TODO: convert these to zinit
# zplug "lukechilds/zsh-better-npm-completion", defer:2
# # I should only activate this when I need to generate completions
# #zplug "RobSis/zsh-completion-generator", defer:2
#
if [[ -n $UNAME_LINUX ]]; then
  #  zplug "holygeek/git-number", as:command, use:'git-*', lazy:true

  zinit ice wait'1' lucid atload"!_zsh_autosuggest_start && ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)
"
  zinit load zsh-users/zsh-autosuggestions
fi

###############################################################################
# add-ons installed by homebrew
###############################################################################

if [ -f $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)
fi
export ZSH_AUTOSUGGEST_USE_ASYNC=1
# for match_prev_cmd to work, it requires histignorealldups to be removed (which is ok: do histsavenodups instead)
export ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)

###############################################################################
# make paste safe and fix pasted urls, https://forum.endeavouros.com/t/tip-better-url-pasting-in-zsh/6962
# This is what inverts the text when pasting. Is it really needed, I can't provoke the "unsafe" behaviour.
# The following must be after autosuggestion. It could affect performance?
###############################################################################
if [ -z "$UBUNTU_DESKTOP" ]; then
  autoload -U url-quote-magic bracketed-paste-magic
  zle -N self-insert url-quote-magic
  zle -N bracketed-paste bracketed-paste-magic
  # Now the fix, setup these two hooks:
  pasteinit() {
    OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
    zle -N self-insert url-quote-magic
  }
  pastefinish() {
    zle -N self-insert $OLD_SELF_INSERT
  }
  zstyle :bracketed-paste-magic paste-init pasteinit
  zstyle :bracketed-paste-magic paste-finish pastefinish
  # n.b. ZSH_AUTOSUGGEST_CLEAR_WIDGETS must also be extended, and that is done in two ways above
fi

###############################################################################
# fzf
###############################################################################

if [ -x "$(command -v fdfind)" ]; then
  # alternate name used on ubuntu/debian
  export FD=fdfind
else
  export FD=fd
fi

# fuzzy completion: ^R, ^T, ⌥C, **
export FZF_DEFAULT_COMMAND="$FD --type file"
# --ansi makes fzf a bit slower, but I haven't really noticed, this preview is used for ** completion
export FZF_DEFAULT_OPTS="--ansi --select-1 --height 40% --reverse --tiebreak=begin --bind end:preview-down,home:preview-up"
export FZF_TMUX_OPTS="-d 70%"
# tmux was a bit slower
#export FZF_TMUX=1
#FZF="fzf-tmux"
FZF=fzf
# this harmed kill -9 and git co **
#export FZF_COMPLETION_OPTS="--preview '(bat --color always --paging never {} 2> /dev/null || tree -C {}) 2> /dev/null | head -200' --preview-window=right:33%"
# this is slow for large sets, could be sorted with ' | sort -u' but that is just the initial sorting
export FZF_ALT_C_COMMAND='$FD --type directory'
export FZF_ALT_C_OPTS="--preview 'CLICOLOR_FORCE=1 ls -GF {} | head -200' --preview-window=right:20%"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
if [ -x "$(command -v bat)" ]; then
  export FZF_CTRL_T_OPTS="--preview 'bat --color always {} | head -120' --preview-window=right:33%"
fi
[ -f ~/.fzf.$SHELLNAME ] && source ~/.fzf.$SHELLNAME

# set up direnv
if [ -z "$DOTFILES_LITE" ] && [ -x "$(command -v direnv)" ]; then
  eval "$(direnv hook $SHELL)"
fi
# this needs to be done just once, and you will be prompted about it
# direnv allow

###############################################################################
# prompt
###############################################################################
UNUSUAL_HOSTNAME=$(hostname -s)
WELL_KNOWN_COMPUTERS=("KlasKlarnaMacHN" "Klass-Mac-mini-2020-M1" "Klass-Mac-mini-2018")
if [[ " ${WELL_KNOWN_COMPUTERS[@]} " =~ " ${UNUSUAL_HOSTNAME} " ]]; then
  UNUSUAL_HOSTNAME=
fi
UNUSUAL_NAME=${LOGNAME}@
if [[ $LOGNAME == *"ellbourn"* ]] || [[ $LOGNAME == *"klas"* ]]; then
  UNUSUAL_NAME=
fi
export ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg[magenta]%}"
if [ -n "$DOTFILES_LITE" ]; then
  # ssh terminal causes unicode to show as two left cursor, https://github.com/woefe/git-prompt.zsh/issues/8
  export ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}v"
  export ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}*"
  export ZSH_THEME_GIT_PROMPT_STASHED="%{$fg[blue]%}~"
  export ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[red]%}x"
  export ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg[red]%}+"
  export ZSH_THEME_GIT_PROMPT_UNTRACKED="..."
fi
export PROMPT_PERCENT_OF_LINE=20
function myPromptWidth() {
  echo $(( ${COLUMNS:-80} * PROMPT_PERCENT_OF_LINE / 100 ))
}
width_part='$(myPromptWidth)'
if [ -x "$(command -v md5sum)" ]; then
  local prompt_hashcolor=$((16#${$(echo $HOST|md5sum):0:2}))
else
  local prompt_hashcolor=$(echo $HOST|cksum|awk '{print $1%233+23}')
fi
# other good: 239+17, 233+23, 253+3
if [[ -n $UNAME_LINUX ]]; then
  local prompt_ending="%(!.#.%%)"
else
  local prompt_ending="%(!..)"
fi
PROMPT="%K{${prompt_hashcolor}}%F%${width_part}<…<%4~%(?..%{$bg[red]%} %?)%(1j.%{$bg[cyan]%} %j.)%k%F{${prompt_hashcolor}}${prompt_ending}%f "
git_part='$(gitprompt)'
RPROMPT="${git_part}%F{021}${UNUSUAL_NAME}%F{033}${UNUSUAL_HOSTNAME}%f %F{106}%*%f"

###############################################################################
# fun functions
###############################################################################
# usage: cd services && getTreeidForService orders
function getTreeidForService() {
	noglob git cat-file -p @^{tree} | \
     grep "services$" | \
     awk '{ system("git cat-file -p " $3) }' | \
     egrep "$1$" | \
     awk '{ print substr($3, 0, 11) }'
}

function co() {
    local branches branch
    branches=$(git branch -a) &&
    branch=$(echo "$branches" | egrep -i "$1"  | $FZF +s +m) &&
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
# Use fd (https://github.com/sharkdp/fd) instead of the default find
_fzf_complete_git_post() {
     awk '{print $1}' | sed "s:remotes/origin/::"
}
_fzf_compgen_path() {
  $FD --follow . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  $FD --type d --follow . "$1"
}

function go() {
    local repos repo
    repos=$(find $CODE_DIR -name .git -type d -maxdepth 3 -prune | egrep -i "$1"  | sed 's#/.git$##') &&
    repo=$(echo "$repos" | $FZF +s +m) &&
    cd $(echo "$repo" | sed "s:.* remotes/origin/::" | sed "s:.* ::")
}

function fd() {
  command $FD --color always $* | less
}
alias fd='noglob fd'

function rg() {
  command rg --pretty --smart-case --no-line-number $* | less
}
alias rg='noglob rg'

# highlighter
function h {
  grep --color=always -E "$1|$" $2 | less
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
# make zsh behave like bash for ctrl-u (fine to modify since most others will have bash, and ^x^k kills whole line)
bindkey "^U" backward-kill-line
# edit command line like in bash (zsh has 'fc' but it has to execute the command first)
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line
# insert matching completions in command line
zle -C all-matches complete-word _my_generic
zstyle ':completion:all-matches::::' completer _all_matches
zstyle ':completion:all-matches:*' old-matches only
_my_generic () {
  local ZSH_TRACE_GENERIC_WIDGET=  # works with "setopt nounset"
  _generic "$@"
}
globalias() {
   # Get last word to the left of the cursor:
   # (z) splits into words using shell parsing
   # (A) makes it an array even if there's only one element
   local word=${${(Az)LBUFFER}[-1]}
   if [[ $GLOBALIAS_FILTER_VALUES[(Ie)$word] -eq 0 ]]; then
      zle expand-word
   fi
}
zle -N globalias
bindkey '^X^a' globalias

# binding needed in VS Code integrated terminal when "terminal.integrated.macOptionIsMeta" is true
#bindkey -s "\e2" @   # option-2 maps to the at-sign
#bindkey -s "\e4" \$  # option-4 maps to dollar
#bindkey -s "\e7" \|  # option-7 maps to vertical bar
#bindkey -s "\e8" \[  # option-8 maps to left square bracket
#bindkey -s "\e9" \]  # option-9 maps to right square bracket
#bindkey -s '\e&' \\  # option-shift-7 maps to backslash ('&' is found on the US keyboard!)
#bindkey -s '\e*' \{  # option-shift-8 maps to left curly brace ('*' is found on the US keyboard!)
#bindkey -s '\e(' \}  # option-shift-9 maps to right curly brace ('(' is found on the US keyboard!)

# binding needed in VS Code integrated terminal when "terminal.integrated.macOptionIsMeta" is false
bindkey '' accept-and-hold # option-a
bindkey 'ƒ' forward-word # option-b
bindkey 'ç' fzf-cd-widget #option-c
bindkey '∂' delete-word #option-d
bindkey '›' backward-word # option-f
bindkey '¸' get-line # option-g
bindkey '˛' run-help #option-h
bindkey 'ﬁ' down-case-word #option-l
bindkey '‘' history-search-forward #option-n
bindkey 'π' history-search-backward #option-p
bindkey '•' push-line #option-q
bindkey 'ß' spell-word #option-s
bindkey '†' transpose-words #option-t
bindkey 'ü' up-case-word #option-u
bindkey 'Ω' copy-region-as-kill #option-w
bindkey '≈' execute-named-cmd #option-x
bindkey 'µ' yank-pop #option-y
bindkey '¿' which-command #option-?

###############################################################################
# Syntax highlighting for the shell
# syntax highlighting should be loaded after all widgets, to work with them
###############################################################################
# loads theme ~/.config/fsh/improved-default.ini for zdharma/fast-syntax-highlighting
zinit ice wait lucid --atload="fast-theme XDG:improved-default >> /tmp/fast-theme.log"
zinit light zdharma/fast-syntax-highlighting

[[ -f /Users/klas.mellbourn/code/klarna/klarna-app/bin/completion/klapp.zsh.sh ]] && . /Users/klas.mellbourn/code/klarna/klarna-app/bin/completion/klapp.zsh.sh || true

# it is 0.05s faster to load compinit in turbo mode, but all completions should be loaded with zinit then
#zinit ice wait'0z' lucid atinit'zpcompinit; zpcdreplay'
#zinit light zdharma/null
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit
zinit cdreplay

if [ $(command -v _exa) ]; then
  compdef x='exa'
  compdef xl='exa'
fi
if [ -x "$(command -v lsd)" ]; then
  alias ls=lsd
  compdef lsd=ls
fi

#echo ".zshrc finished:"
#END=$(gdate +%s.%N)
#echo "$END - $START" | bc
#zprof
