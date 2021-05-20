###############################################################################
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases, functions, options, key bindings, etc.
###############################################################################
#echo ".zshrc running"
#zmodload zsh/zprof
#START=$(gdate +%s.%N)

###############################################################################
# remember your ancestor
###############################################################################
source ~/.bash_profile

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# This must go after tmux auto start https://github.com/romkatv/powerlevel10k/issues/1203
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#rm ~/.zcompdump ~/.zcompcache
source ~/.zinit/bin/zinit.zsh

GENCOMPL_FPATH=~/.zsh-personal-completions/generated
fpath=(~/.zsh-personal-functions ~/.zsh-personal-completions $fpath $GENCOMPL_FPATH)
autoload -U zmv
# personal functions in ~/.zsh-personal-functions
autoload -Uz yb

# helping brew completion is needed if HOMEBREW_PREFIX is not /usr/local
FPATH=$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH

# misc
setopt interactive_comments long_list_jobs extendedglob notify list_packed transient_rprompt

# word movement should stop on slashes
export WORDCHARS=$WORDCHARS:s:/:
###############################################################################
# directory navigation options
###############################################################################
setopt auto_cd auto_pushd pushd_ignore_dups glob_complete numeric_glob_sort
export DIRSTACKSIZE=10

###############################################################################
# history
###############################################################################
# replace histignorealldups with histsavenodups to make zsh autosuggestion option match_prev_cmd work
setopt correct hist_save_no_dups inc_append_history extended_history hist_ignore_space hist_reduce_blanks hist_verify hist_fcntl_lock

export HISTFILE=~/.zsh_history
export SAVEHIST=$HISTSIZE

###############################################################################
# tmux
###############################################################################
zinit lucid light-mode for romkatv/zsh-defer

set_p10k_branch_in_tmux() {
  # backward compatible version (tmux < 2.5) of: tmux select-pane -T "${VCS_STATUS_LOCAL_BRANCH}"
  zsh-defer -1sm -t 0.2 -c 'printf "\033]2;$VCS_STATUS_LOCAL_BRANCH\033\\"'
}
precmd_functions+=set_p10k_branch_in_tmux

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
setopt nolistbeep # could be nobeep, but that will create cases where there is no repsone at all to a <tab>
# Do menu-driven completion.
zstyle ':completion:*' menu select

# make file completion match ls colors - this now done by trapd00r/LS_COLORS
#zstyle ':completion:*' list-colors $LS_COLORS

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
#zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
#very allowing
#zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
# if you use lower, interpret it as either. If you use upper force upper
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# command line completion for kubectl, only activate if really needed, since this takes 0.2s to load
#if [ -x "$(command -v kubectl)" ]; then
#  source <(kubectl completion zsh)
#fi

###############################################################################
# zinit - zsh plugin manager
###############################################################################
zinit depth=1 light-mode for romkatv/powerlevel10k

zinit wait'0a' lucid blockf for zsh-users/zsh-completions

export ZSH_AUTOSUGGEST_USE_ASYNC=1
# for match_prev_cmd to work, it requires histignorealldups to be removed (which is ok: do histsavenodups instead)
export ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
zinit wait'0' lucid atload"!_zsh_autosuggest_start && ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)
" for zsh-users/zsh-autosuggestions

# zsh-notify (as opposed to zbell) only notifies when the pane with the command is not focused
# icons (whether remote or local) affects performance noticably
# silent because zsh-notify does not work on raspberry pi
notification_command_complete_timeout=30
zinit wait'0' silent atload'
  zstyle ":notify:*" command-complete-timeout $notification_command_complete_timeout
  zstyle ":notify:*" enable-on-ssh yes
  zstyle ":notify:*" error-icon "https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Blokkade.png/240px-Blokkade.png"
  zstyle ":notify:*" error-sound "Sosumi"
  zstyle ":notify:*" error-title "⛔️ errored in #{time_elapsed}"
  zstyle ":notify:*" success-icon "https://upload.wikimedia.org/wikipedia/commons/a/a6/Green_approved.png"
  zstyle ":notify:*" success-sound "Blow"
  zstyle ":notify:*" success-title "✅ finished in #{time_elapsed}"' \
  for marzocchi/zsh-notify

# set up a bell after command that run longer than this many seconds (regardless of focus or result)
if [[ -n $UNAME_LINUX ]]; then
  zbell_duration=$notification_command_complete_timeout
else
  # on macOS zsh-notify is generally better
  zbell_duration=600
fi
zbell_ignore+=($EDITOR $PAGER vim code less bat cat man run-help lnav)
zinit wait'0' lucid for OMZP::zbell

# exa doesn't download well on WSL
# zinit wait'0' lucid as"program" from"gh-r" mv"exa* -> exa" pick"$ZPFX/exa" light-mode for ogham/exa
export TIME_STYLE=long-iso
if [ -x "$(command -v exa)" ]; then
  function x() {
    command exa -F --color-scale --group-directories-first --color=always --git-ignore --git -x $*
  }
  function xl() {
    command exa -F --color-scale --group-directories-first --color=always --git-ignore --git -l $* | command less -r
  }
else
  alias x=l
  alias xl=ll
fi

if [ -x "$(command -v zoxide)" ]; then
  export _ZO_MAXAGE=400
  export _ZO_EXCLUDE_DIRS=$HOME
  zinit wait'0' lucid as'null' atinit'unalias zi;eval "$(zoxide init --no-aliases zsh)" && alias z=__zoxide_z c=__zoxide_zi zi=zinit' light-mode for zdharma/null
elif [ -d "$HOMEBREW_PREFIX/share/z.lua" ]; then
  export _ZL_MATCH_MODE=1
  zinit wait'0' lucid as'null' atinit'source $HOMEBREW_PREFIX/share/z.lua/z.lua.plugin.zsh' light-mode for zdharma/null
  alias c="z -I"
else
  # zoxide not available on old raspberry pi. fasd is pure shell, but slow: fasd takes 0.06s
  zinit wait'0' lucid as"program" pick"$ZPFX/fasd" make"PREFIX=$ZPFX install" \
    atinit'eval "$(fasd --init auto)" && alias sd="noglob sd"' light-mode for clvv/fasd
  c() {
    local dir
    dir="$(fasd -Rdl "$1" | $FZF -1 -0 --no-sort +m)" && cd "${dir}" || return 1
  }
fi

zinit wait'1' lucid for OMZP::magic-enter
MAGIC_ENTER_GIT_COMMAND="l"
MAGIC_ENTER_OTHER_COMMAND="l"

zinit wait'1' lucid for supercrabtree/k

zinit wait'1' atclone'./zplug.zsh' lucid for g-plane/zsh-yarn-autocompletions

if [ ! -x "$(command -v dircolors)" ]; then
  alias dircolors=gdircolors
fi
# add LOTS of file type colors
zinit wait'1' atclone"dircolors -b LS_COLORS > clrs.zsh" \
    atpull'%atclone' pick"clrs.zsh" nocompile'!' \
    atload'zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"' \
    lucid light-mode for trapd00r/LS_COLORS

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
zinit wait'1' lucid as'null' \
  atinit"[ -f ~/.fzf.$SHELLNAME ] && source ~/.fzf.$SHELLNAME && bindkey 'ç' fzf-cd-widget #option-c" light-mode for zdharma/null

# has to be loaded aftr fzf, so that it overwrites ^R
zinit wait'1' lucid for zdharma/history-search-multi-word

zinit wait'1' lucid light-mode for "cedi/meaningful-error-codes"

zinit wait'1' lucid if'[[ -x "$(command -v fzf)" ]]' for wfxr/forgit
# gi for forgit_ignore was a confusing alias
forgit_ignore=forgig

# command-not-found cuases lag in command prompt when starting, also makes unkown commands slower
#zinit wait'1' lucid as'null' atinit'source "$HOMEBREW_PREFIX/Homebrew/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"' light-mode for zdharma/null

zinit wait'1' lucid for \
  djui/alias-tips \
  OMZP::dircycle

zinit wait'1' lucid atinit'alias f=fuck' light-mode for laggardkernel/zsh-thefuck

# load diff-so-fancy if not already present (it can have been installed by homebrew)
zinit wait'1' lucid as"program" pick"bin/git-dsf" if'[[ ! -x "$(command -v diff-so-fancy)" ]]' light-mode for \
  zdharma/zsh-diff-so-fancy

zinit wait'1' lucid as"completion" light-mode for nilsonholger/osx-zsh-completions

zinit wait'1' lucid light-mode for mellbourn/zabb

# fzf-tab doesn't currently work in Ubuntu https://github.com/Aloxaf/fzf-tab/issues/189
zinit wait'1' lucid atclone'source fzf-tab.zsh && build-fzf-tab-module' atpull'%atclone' for Aloxaf/fzf-tab
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
#zinit wait'1' lucid light-mode for marlonrichert/zsh-autocomplete
#zstyle ':autocomplete:*' config off
#zstyle ':autocomplete:*' min-input 2
##zstyle ':autocomplete:*' min-delay 0.4
#zstyle ':autocomplete:tab:*' insert-unambiguous yes
#zstyle ':autocomplete:tab:*' widget-style menu-select
# when fzf work test this
#zstyle ':autocomplete:tab:*' fzf-completion yes
# this doesn't really repair ctrl-space
#bindkey $key[ControlSpace] set-mark-command

zinit wait'2' lucid for unixorn/git-extra-commands

# list programs to generate completions for here
zstyle :plugin:zsh-completion-generator programs fzf
zinit wait'2' lucid atclone'if [ ! -d "$GENCOMPL_FPATH" ]; then
  mkdir -p $GENCOMPL_FPATH
fi' for RobSis/zsh-completion-generator

# some nice OMZ functions: take, alias, try_alias_value, omz_urlencode, omz_urldecode
zinit wait'2' lucid for \
  OMZ::lib/functions.zsh \
  OMZ::plugins/web-search/web-search.plugin.zsh

zinit wait'2' lucid light-mode for \
  paulirish/git-open \
  peterhurford/git-it-on.zsh

zinit wait'2' lucid atload'ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(autopair-insert)' light-mode for hlissner/zsh-autopair

if [[ -n $UNAME_MACOS ]]; then
  # this works great _on macOS_
  zinit wait'2' lucid light-mode as"program" pick"src/trash" for morgant/tools-osx
fi

if [ -z "$DOTFILES_LITE" ]
then
  # Not really plugins, but very good to have async anyway
  # sourcing rvm takes 0.51s, so there will be a lag when it is sourced
  # also, loading rvm as a zinit will make it ignore the .ruby-version file if you are already inside that folder
  zinit wait'2' lucid as'null' \
    atinit'if [ -s $HOME/.rvm/scripts/rvm ]; then source "$HOME/.rvm/scripts/rvm"; fi' light-mode for zdharma/null

  # # python environent will also cause a lag
  # # this takes 0.166s
  # zinit wait'2a' lucid as'null' atinit'command -v pyenv > /dev/null && eval "$(pyenv init -)"' light-mode for zdharma/null
  # zinit wait'2b' lucid as'null' atinit'command -v pyenv-virtualenv-init > /dev/null && eval "$(pyenv virtualenv-init -)"' light-mode for zdharma/null
  # export WORKON_HOME=~/.py_virtualenvs
  # zinit wait'2c' lucid as'null' atinit'if [ -x "$(command -v python3)" ]; then export VIRTUALENVWRAPPER_PYTHON=$(command -v python3); elif [ -x "$(command -v python3)" ]; then export VIRTUALENVWRAPPER_PYTHON=$(command -v python2); fi' light-mode for zdharma/null
  # # this taskes 0.39s
  # # this has to be loaded much later than the preceding plugins, otherwise you will get "No module named virtualenvwrapper  "
  # zinit wait'9' lucid as'null' atinit'if [ -f $HOMEBREW_PREFIX/bin/virtualenvwrapper.sh ]; then source $HOMEBREW_PREFIX/bin/virtualenvwrapper.sh; fi' light-mode for zdharma/null

  # yarn must be run after node is defined, takes 0.31s, and only adds $HOMEBREW_PREFIX/bin
  #zinit wait'2' lucid as'null' atinit'export PATH="$PATH:$(yarn global bin)"' light-mode for zdharma/null
fi

# TODO: convert these to zinit
# zplug "lukechilds/zsh-better-npm-completion", defer:2
if [[ -n $UNAME_LINUX ]]; then
  #  zplug "holygeek/git-number", as:command, use:'git-*', lazy:true
fi

###############################################################################
# add-ons installed by homebrew
###############################################################################

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

# set up direnv
if [ -z "$DOTFILES_LITE" ] && [ -x "$(command -v direnv)" ]; then
  eval "$(direnv hook $SHELL)"
fi
# this needs to be done just once, and you will be prompted about it
# direnv allow

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
# syntax highlighting should be loaded AFTER all widgets, to work with them
# This last async call is also where compinit should be called, see https://github.com/zdharma/zinit#calling-compinit-with-turbo-mode
###############################################################################
# loads theme ~/.config/fsh/improved-default.ini for zdharma/fast-syntax-highlighting
zinit wait'2' lucid --atinit="ZINIT[COMPINIT_OPTS]=-C; zicompinit; autoload -U +X bashcompinit && bashcompinit; zicdreplay" --atload="fast-theme XDG:improved-default >> /tmp/fast-theme.log" light-mode for zdharma/fast-syntax-highlighting

# colored man pages must be loaded after syntax-highlighting
zinit wait'2b' lucid for \
  OMZP::colored-man-pages \

if [ -x "$(command -v bat)" ]; then
  # this MUST be run after woefe/git-prompt.zsh
  alias cat=bat
  # this function does not work for piping to less with (less) arguments (any flags will become bat flags)
  function less() {
    local filename="${@:$#}" # last parameter, MUST be the filename
    local flaglength=$(($# - 1))
    if ((flaglength > 0)); then
      local other="${@:1:$flaglength}"
      bat $filename --pager "less $LESS $other"
    elif ((flaglength == 0)); then
      bat $filename --pager "less $LESS"
    else
      # no arg at all -> piping
      command less
    fi
  }
fi
if [ -x "$(command -v lsd)" ]; then
  alias ls=lsd
fi

# load explicit compdefs after compinit (not sure why this is necessary)
zinit wait'2b' lucid as'null' atinit'

[[ -f /Users/klas.mellbourn/code/klarna/klarna-app/bin/completion/klapp.zsh.sh ]] && . /Users/klas.mellbourn/code/klarna/klarna-app/bin/completion/klapp.zsh.sh || true

# this MUST be run after woefe/git-prompt.zsh
if [ -x "$(command -v bat)" ]; then
  compdef less=less
  function batgrep() {
    command batgrep --color --smart-case --context=0 $* | command less -+J -+W
  }
  alias batgrep="noglob batgrep"
fi
if [ $(command -v _exa) ]; then
  compdef x="exa"
  compdef xl="exa"
fi
compdef lsd=ls
if [ -x "$(command -v prettyping)" ]; then
  alias ping="prettyping --nolegend"
  compdef prettyping=ping
fi

' light-mode for zdharma/null

# it is 0.05s faster to load compinit in turbo mode, but all completions should be loaded with zinit then
#autoload -U +X compinit && compinit
#autoload -U +X bashcompinit && bashcompinit
#zinit cdreplay

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#echo ".zshrc finished:"
#END=$(gdate +%s.%N)
#echo "$END - $START" | bc
#zprof
