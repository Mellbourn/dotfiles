if [ -n "$NEVER" ]; then
export LANG=en_US.UTF-8

eval "$('/opt/homebrew/bin/brew' shellenv)"
fi

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

fpath=(~/.zsh-personal-functions ~/.zsh-personal-completions $fpath $GENCOMPL_FPATH)
if [[ -d ~/.config/pilot/completions ]]; then # app
  fpath=(~/.config/pilot/completions $fpath) # app
fi # app
autoload -U zmv
# personal functions in ~/.zsh-personal-functions
if [[ -d ~/.zsh-personal-functions ]]; then
autoload -Uz $(ls ~/.zsh-personal-functions)
fi
# helping brew completion is needed if HOMEBREW_PREFIX is not /usr/local
# curl is here to enablie curlie to get to curls completions
FPATH=$HOMEBREW_PREFIX/share/zsh/site-functions:$HOMEBREW_PREFIX/opt/curl/share/zsh/site-functions:$FPATH

# fixing weird error of fpath on Klas's MacBook Pro 16" 2023, having 5.8.1 instead of 5.9
#case "$FPATH" in
#    */usr/share/zsh/site-functions:/usr/share/zsh/5.8.1/functions*)
#      FPATH=$FPATH:$HOMEBREW_PREFIX/share/zsh/site-functions:$HOMEBREW_PREFIX/Cellar/zsh/5.9/share/zsh/functions ;;
#esac

# misc
# removed extendedglob since 'noglob git' does not work with djui/alias-tips
setopt interactive_comments long_list_jobs notify list_packed transient_rprompt

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
  # this hack is to avoid running this in subshells (e.g. shelling out from "less")
  if [ "$SHLVL" -lt 5 ] && [ -z "$YAZI_LEVEL" ]; then
    # backward compatible version (tmux < 2.5) of: tmux select-pane -T "${VCS_STATUS_LOCAL_BRANCH}"
    zsh-defer -1sm -t 0.2 -c 'printf "\033]2;$VCS_STATUS_LOCAL_BRANCH\033\\"'
    # note that the above line makes shelling out less convenient to get back from, since you need to fg
    # I could run this without zsh-defer, see below, but then this is only working on the second prompt of a repo
    # printf "\033]2;$VCS_STATUS_LOCAL_BRANCH\033\\"
  fi
}
precmd_functions+=set_p10k_branch_in_tmux

###############################################################################
# dynamic aliases
###############################################################################
if [ -x "$(command -v grc)" ]; then
  # colorize standard commands. Possibilites here $HOMEBREW_PREFIX/share/grc
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

zinit silent light-mode lucid for SinaKhalili/mecho

zinit wait'0a' lucid blockf for zsh-users/zsh-completions

export ZSH_AUTOSUGGEST_USE_ASYNC=1
# for match_prev_cmd to work, it requires histignorealldups to be removed (which is ok: do histsavenodups instead)
export ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
zinit wait'0' lucid atload"!_zsh_autosuggest_start
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

if [ -x "$(command -v zoxide)" ]; then
  export _ZO_EXCLUDE_DIRS=$HOME
  zinit wait'0' lucid as'null' atinit'unalias zi;eval "$(zoxide init zsh --hook prompt)"; alias c=__zoxide_zi zi=zinit' light-mode for zdharma-continuum/null
elif [ -d "$HOMEBREW_PREFIX/share/z.lua" ]; then
  export _ZL_MATCH_MODE=1
  zinit wait'0' lucid as'null' atinit'source $HOMEBREW_PREFIX/share/z.lua/z.lua.plugin.zsh' light-mode for zdharma-continuum/null
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

if [[ -z "$KLA" ]]; then
  zinit wait'0' lucid as'null' atinit'source $HOME/.asdf/asdf.sh
  # setup direnv
  if [ -z "$DOTFILES_LITE" ] && [ -x "$(command -v direnv)" ]; then
    source ${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc
  fi
  # java_home
  if [ -x "${ASDF_DIR:-$HOME/.asdf}"/shims/java ]; then
    source "${ASDF_DIR:-$HOME/.asdf}"/plugins/java/set-java-home.zsh
  fi
  ' light-mode for zdharma-continuum/null
fi
fpath=(${ASDF_DIR:-$HOME/.asdf}/completions $fpath)

if [[ -n $UNAME_MACOS ]]; then
  # this works great _on macOS_
  zinit wait'0' lucid light-mode as"program" pick"src/trash" for morgant/tools-osx
fi

zinit wait'1' lucid for OMZP::magic-enter
MAGIC_ENTER_GIT_COMMAND="g sts"
MAGIC_ENTER_OTHER_COMMAND="l"

zinit wait'1' lucid for supercrabtree/k

zinit wait'1' lucid light-mode for lukechilds/zsh-better-npm-completion
zinit wait'1' atclone'./zplug.zsh' lucid for g-plane/zsh-yarn-autocompletions
zinit wait'1' lucid light-mode for jscutlery/nx-completion
zinit wait'1' lucid light-mode for favware/zsh-lerna

if [ ! -x "$(command -v dircolors)" ]; then
  alias dircolors=gdircolors
fi
# add LOTS of file type colors
zinit wait'1' atclone"dircolors -b LS_COLORS > clrs.zsh" \
    atpull'%atclone' pick"clrs.zsh" nocompile'!' \
    atload'zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"' \
    lucid light-mode for trapd00r/LS_COLORS

 if command -v fd &>/dev/null; then
  export FD=fd
else
  # alternate name used on ubuntu/debian
  export FD=fdfind
fi

# fuzzy completion: ^R, ^T, ⌥C, **
export FZF_DEFAULT_COMMAND="$FD --type file"
# --ansi makes fzf a bit slower, but I haven't really noticed, this preview is used for ** completion
# colors are dracula theme
export FZF_DEFAULT_OPTS="--ansi --select-1 --height ~40% --reverse --tiebreak=begin --bind alt-up:preview-page-up,alt-down:preview-page-down,alt-shift-up:preview-top,alt-shift-down:preview-bottom,alt-a:select-all \
 --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
export FZF_TMUX_OPTS="-d 70%"
# tmux was a bit slower
#export FZF_TMUX=1
#FZF="fzf-tmux"
FZF=fzf
# this harmed kill -9 and git co **
#export FZF_COMPLETION_OPTS="--preview '(bat --color always --paging never {} 2> /dev/null || tree -C {}) 2> /dev/null | head -200' --preview-window=right:33%"
# this is slow for large sets, could be sorted with ' | sort -u' but that is just the initial sorting
export FZF_ALT_C_COMMAND="$FD --type directory"
export FZF_ALT_C_OPTS="--preview 'CLICOLOR_FORCE=1 ls -GF {} | head -200' --preview-window=right:20%"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview '~/bin/preview.sh {}' --preview-window=right:33%"
zinit wait'1' lucid as'null' \
  atinit"[ -f ~/.fzf.$SHELLNAME ] && source ~/.fzf.$SHELLNAME && bindkey 'ç' fzf-cd-widget #option-c" light-mode for zdharma-continuum/null

# history search has to be loaded aftr fzf, so that it overwrites ^R
if [[ -x $(command -v atuin) ]]; then
  zinit wait'1' lucid light-mode atinit"bindkey '^xr' history-search-multi-word" for zdharma-continuum/history-search-multi-word
  export ATUIN_NOBIND="true"
  zinit wait"1" lucid light-mode atinit"bindkey '^r' atuin-search" for atuinsh/atuin
else
  zinit wait'1' lucid for zdharma-continuum/history-search-multi-word
fi

zinit wait'1' lucid light-mode for "cedi/meaningful-error-codes"

zinit wait'1' lucid if'[[ -x "$(command -v fzf)" ]]' --atload='export PATH="$PATH:$FORGIT_INSTALL_DIR/bin"' for wfxr/forgit
# gi for forgit_ignore was a confusing alias
#forgit_ignore=forgig
# ctrl-d to drop stash with gss
export FORGIT_STASH_FZF_OPTS='
--bind="ctrl-d:reload(git stash drop $(cut -d: -f1 <<<{}) 1>/dev/null && git stash list)"
--bind="enter:execute(echo {} | cut -d: -f1 | xargs -I % git stash pop %)+accept"
--bind="tab:execute(echo {} | cut -d: -f1 | xargs -I % git stash apply %)+accept"
--prompt="[ctrl-d]: drop, [enter]: pop, [tab]: apply   "
'
export FORGIT_DIFF_GIT_OPTS='--no-ext-diff'
export FORGIT_LOG_GIT_OPTS='--date=format-local:%Y-%m-%dT%H:%M'
export FORGIT_LOG_FORMAT='%C(yellow)%h %C(magenta)%<(15,trunc)%an %C(cyan)%cd %C(auto)%d%Creset %s'
if [[ -x $(command -v delta) ]]; then
  export FORGIT_PAGER='delta --wrap-max-lines 0 -w ${FZF_PREVIEW_COLUMNS:-$COLUMNS}'
fi

# command-not-found cuases lag in command prompt when starting, also makes unkown commands slower
#zinit wait'1' lucid as'null' atinit'source "$HOMEBREW_PREFIX/Homebrew/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"' light-mode for zdharma-continuum/null

zinit wait'1' lucid light-mode for "djui/alias-tips"
zinit wait'1' lucid light-mode for OMZP::dircycle

zinit wait'1' lucid atinit'alias f=fuck' light-mode for laggardkernel/zsh-thefuck

# load diff-so-fancy if not already present (it can have been installed by homebrew)
zinit wait'1' lucid as"program" pick"bin/git-dsf" if'[[ ! -x "$(command -v diff-so-fancy)" ]]' light-mode for \
  zdharma-continuum/zsh-diff-so-fancy

zinit wait'1' lucid as"completion" light-mode pick"_*" for nilsonholger/osx-zsh-completions

zinit wait'1' lucid light-mode for mellbourn/zabb

# fzf-tab doesn't currently work in Ubuntu https://github.com/Aloxaf/fzf-tab/issues/189
zinit wait'1' lucid atclone'source fzf-tab.zsh && build-fzf-tab-module' atpull'%atclone' for Aloxaf/fzf-tab
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# preview directory's content with lsd when completing cd
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

zinit wait'1' lucid as'null' \
  atinit"[ -f ~/.config/broot/launcher/bash/br ] && source ~/.config/broot/launcher/bash/br" light-mode for zdharma-continuum/null

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

# make text copy operations generic: clipcopy/clippaste
zinit wait'2' lucid for OMZL::clipboard.zsh

if [ -z "$DOTFILES_LITE" ]
then
  # Not really plugins, but very good to have async anyway
  # sourcing rvm takes 0.51s, so there will be a lag when it is sourced
  # also, loading rvm as a zinit will make it ignore the .ruby-version file if you are already inside that folder
  #if [ -d ~/.rbenv ]; then
  #  zinit wait'2' lucid as'null' \
  #    atinit'eval "$(rbenv init -)"' light-mode for zdharma-continuum/null
  #else
  #  zinit wait'2' lucid as'null' \
  #    atinit'if [ -s $HOME/.rvm/scripts/rvm ]; then source "$HOME/.rvm/scripts/rvm"; fi' light-mode for zdharma-continuum/null
  #fi
  if [ -s $HOME/.rvm/scripts/rvm ]; then
    source "$HOME/.rvm/scripts/rvm"
    rvm implode
  fi

  # # python environent will also cause a lag
  # # this takes 0.166s
  # zinit wait'2a' lucid as'null' atinit'command -v pyenv > /dev/null && eval "$(pyenv init -)"' light-mode for zdharma-continuum/null
  # zinit wait'2b' lucid as'null' atinit'command -v pyenv-virtualenv-init > /dev/null && eval "$(pyenv virtualenv-init -)"' light-mode for zdharma-continuum/null
  # export WORKON_HOME=~/.py_virtualenvs
  # zinit wait'2c' lucid as'null' atinit'if [ -x "$(command -v python3)" ]; then export VIRTUALENVWRAPPER_PYTHON=$(command -v python3); elif [ -x "$(command -v python3)" ]; then export VIRTUALENVWRAPPER_PYTHON=$(command -v python2); fi' light-mode for zdharma-continuum/null
  # # this taskes 0.39s
  # # this has to be loaded much later than the preceding plugins, otherwise you will get "No module named virtualenvwrapper  "
  # zinit wait'9' lucid as'null' atinit'if [ -f $HOMEBREW_PREFIX/bin/virtualenvwrapper.sh ]; then source $HOMEBREW_PREFIX/bin/virtualenvwrapper.sh; fi' light-mode for zdharma-continuum/null

  # yarn must be run after node is defined, takes 0.31s, and only adds $HOMEBREW_PREFIX/bin
  #zinit wait'2' lucid as'null' atinit'export PATH="$PATH:$(yarn global bin)"' light-mode for zdharma-continuum/null
fi

if [[ -n $UNAME_LINUX ]]; then
  if [[ -n $OS_RASPBIAN   ]]; then
    zinit wait'2' lucid light-mode from"gh-r" as"program" bpick"*-unknown-linux-gnueabihf*" \
      mv'ripgrep-*/rg -> rg' completions for BurntSushi/ripgrep
  else
    zinit wait'2' lucid light-mode from"gh-r" as"program" \
      mv'ripgrep-*/rg -> rg' completions for BurntSushi/ripgrep
  fi
  fd_version_output=$(fdfind --version 2>/dev/null)
  if [[ $? -ne 0 ]]; then
      echo "fdfind is not installed."
  fi
  if [[ $fd_version_output =~ fd(find)?[[:space:]]*([0-9]+)\..* ]]; then
      fd_version="${match[1]}"
  else
      echo "Could not determine fd version."
  fi
  if (( fd_version < 10 )); then
    if [[ -n $OS_RASPBIAN   ]]; then
      zinit wait'2' lucid light-mode from"gh-r" as"program" atinit'export FD=fd' \
        bpick"*-unknown-linux-gnueabihf*" mv'fd-*/fd -> fd' for @sharkdp/fd
    else
      zinit wait'2' lucid light-mode from"gh-r" as"program" atinit'export FD=fd' \
         mv'fd-*/fd -> fd' for @sharkdp/fd
    fi
  fi


  if [[ -n $OS_RASPBIAN   ]]; then
    # this is for raspberry pi, mainly
    zinit wait'2' lucid if'[[ ! -x "$(command -v delta)" ]]' from"gh-r" as"program" \
      bpick"*-arm-unknown-linux-gnueabihf*" mv'delta-*/delta -> delta' for dandavison/delta
  else
    # WSL
    zinit wait'2' lucid if'[[ ! -x "$(command -v delta)" ]]' from"gh-r" as"program" \
      mv'delta-*/delta -> delta' for dandavison/delta
  fi

  if [[ -n $OS_RASPBIAN   ]]; then
    # this is for raspberry pi, mainly
    zinit wait'2' lucid from"gh-r" as"program" \
      bpick"*-arm-unknown-linux-gnueabihf*" mv'bat-*/bat -> bat' for @sharkdp/bat
    zinit wait'2' lucid from"gh-r" as"completion" id-as"sharkdp/_bat" \
      mv"bat-*/autocomplete/bat.zsh -> _bat" \
      pick"_bat" for @sharkdp/bat
  fi

  zinit wait'2' lucid light-mode from"gh-r" as"program" for jesseduffield/lazygit
fi

# note that this is for completion of cyme only, the command is gotten from cargo
zinit wait'2' lucid light-mode from"gh" pick"doc/_cyme" as"completion" for tuna-f1sh/cyme

# docfd finds strings in documenation files, e.g. pdf, word etc
zinit wait'2' lucid light-mode from'gh-r' as'program' for darrenldl/docfd

###############################################################################
# add-ons installed by homebrew
###############################################################################

###############################################################################
# make paste safe and fix pasted urls, https://forum.endeavouros.com/t/tip-better-url-pasting-in-zsh/6962
# This is what inverts the text when pasting. Is it really needed, I can't provoke the "unsafe" behaviour.
# The following must be after autosuggestion. It could affect performance?
# commented out because it hurts insertion of emojis
###############################################################################
# if [ -z "$UBUNTU_DESKTOP" ]; then
  #autoload -U url-quote-magic bracketed-paste-magic
  #zle -N self-insert url-quote-magic
  #zle -N bracketed-paste bracketed-paste-magic
  ## Now the fix, setup these two hooks:
  #pasteinit() {
  #  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  #  zle -N self-insert url-quote-magic
  #}
  #pastefinish() {
  #  zle -N self-insert $OLD_SELF_INSERT
  #}
  #zstyle :bracketed-paste-magic paste-init pasteinit
  #zstyle :bracketed-paste-magic paste-finish pastefinish
  # n.b. ZSH_AUTOSUGGEST_CLEAR_WIDGETS must also be extended, and that is done in two ways above
#fi

###############################################################################
# fzf
###############################################################################

###############################################################################
# fun functions
###############################################################################
function yy() {
    tmp="$(mktemp -t "yazi-cwd.XXXXX")"
    yazi --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

function dasel() {
  command dasel --colour $* | less
}
function httpp() {
  # note that this will remove header info, if you need it, add "-p hb" or "-v" parameter
  command http --pretty=all $* | command less -r
}

function bri() {
  brew info --json "$1"| jq -r '.[0].homepage'| xargs open
}

function co() {
    local branches branch
    branches=$(git branch -a --color=always | sed -E 's|remotes/[^/]+/|\x1b[31m&\x1b[0m|g') &&
    branch=$(echo "$branches" | egrep -i "$1"  | $FZF +s +m --preview "echo {} | sed 's/^[ *+]*//'| xargs git log --color=always -100") &&
    git switch $(echo "$branch" | sed "s:.* remotes/origin/::" | sed "s:.* ::")
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

function fd() {
  if [ -t 1 ]; then
    if [[ -n $SSH_CONNECTION || -n $SSH_CLIENT || -n $SSH_TTY ]]; then
      command $FD -c always $* | less
    else
      command $FD --hyperlink -c always $* | less
    fi
  else
    command $FD $*
  fi
}
alias fd='noglob fd'

function rg() {
  if [[ -n $SSH_CONNECTION || -n $SSH_CLIENT || -n $SSH_TTY ]]; then
    command rg --color=always --heading $* | less
  else
    command rg --color=always --heading $* --hyperlink-format=vscode | less
  fi
}
alias rg='noglob rg'

# highlighter
function h {
  grep --color=always -E "$1|$" $2 | less
}

# make lazygit change dir if repo is changed during running lg
lg() {
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
            cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
            rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}

# decode JWT tokens
function jwtd() {
  cut -d"." -f1,2 <<< $1 | sed 's/\./\n/g' | base64 --decode | jq
}

# copies file to clipboard. You can then
# cmd-v paste into gmail
# copy an image file and then paste image in some apps, like google docs
pbcopyfile(){ osascript -e{'on run{a}','set the clipboard to posix file a',end} "$(greadlink -f -- "$1")";}

# Use Ctrl-x,Ctrl-l to get the output of the last command
insert-last-command-output() {
LBUFFER+="$(eval $history[$((HISTCMD-1))])"
}
zle -N insert-last-command-output
bindkey "^X^L" insert-last-command-output

###############################################################################
# Suffix aliases - http://zshwiki.org/home/examples/aliassuffix
# these become "executable"
###############################################################################
alias -s zip="zipinfo"
alias -s {avdl,c,coffee,css,el,gql,gradle,graphql,h,handlebars,hpp,html,http,java,js,json,json5,jsx,lock,log,md,py,rb,scss,swift,text,ts,tsx,txt,xml,yaml,yml,yo}=code

###############################################################################
# keybindings
###############################################################################
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward
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

# make most kill commands in zsh copy to global pastboard as well as zsh clipboard
if [[ $UNAME == 'Darwin' ]]; then
  # M-w copies to global pasteboard as well as zsh clipboard
  pb-copy-region-as-kill () {
    zle copy-region-as-kill
    print -rn $CUTBUFFER | pbcopy
  }
  zle -N pb-copy-region-as-kill
  bindkey -e '\ew' pb-copy-region-as-kill
  # Ctrl-u copies to global pasteboard as well as zsh clipboard - is this overkill?
  pb-backward-kill-line () {
    zle backward-kill-line
    print -rn $CUTBUFFER | pbcopy
  }
  zle -N pb-backward-kill-line
  # make zsh behave like bash for ctrl-u (fine to modify since most others will have bash, and ^x^k kills whole line)
  bindkey -e '^u' pb-backward-kill-line
  # Ctrl-k copies to global pasteboard as well as zsh clipboard - is this overkill?
  pb-kill-line () {
    zle kill-line
    print -rn $CUTBUFFER | pbcopy
  }
  zle -N pb-kill-line
  bindkey -e '^k' pb-kill-line
  # Ctrl-x Ctrl-k copies to global pasteboard as well as zsh clipboard - is this overkill?
  pb-kill-buffer () {
    zle kill-buffer
    print -rn $CUTBUFFER | pbcopy
  }
  zle -N pb-kill-buffer
  bindkey -e '^x^k' pb-kill-buffer
fi

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
# This last async call is also where compinit should be called, see https://github.com/zdharma-continuum/zinit#calling-compinit-with-turbo-mode
###############################################################################
if false; then
  zinit wait'2' lucid --atinit="ZINIT[COMPINIT_OPTS]=-C; zicompinit; autoload -U +X bashcompinit && bashcompinit; zicdreplay" --atload="
    export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
    export ZSH_HIGHLIGHT_STYLES[assign]='bg=18,fg=220' # dark blue background # migrated
    export ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=219,bg=236' # pink # migrated to fsh
    export ZSH_HIGHLIGHT_STYLES[commandseparator]='bg=21,fg=195' # light on dark blue # migrat→
    export ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=94' # brown # migrated to fsh
    export ZSH_HIGHLIGHT_STYLES[globbing]='fg=99' # lilac
    export ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=63' # softer lilac
    export ZSH_HIGHLIGHT_STYLES[path]='fg=30,underline' # make folders same colors as in ls
    export ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=243,underline' #migrated
    export ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=white,underline' # migrated
    export ZSH_HIGHLIGHT_STYLES[redirection]='fg=148,bold,bg=235' # >> yellow-green #migrated
    export ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=182' # light pink
" light-mode for zsh-users/zsh-syntax-highlighting
else
  # loads theme ~/.config/fsh/improved-default.ini for zdharma-continuum/fast-syntax-highlighting
  zinit wait'2' lucid --atinit="ZINIT[COMPINIT_OPTS]=-C; zicompinit; autoload -U +X bashcompinit && bashcompinit; zicdreplay" --atload="fast-theme XDG:improved-default >> /tmp/fast-theme.log" light-mode for zdharma-continuum/fast-syntax-highlighting
fi

# colored man pages must be loaded after syntax-highlighting
zinit wait'2b' lucid for \
  OMZP::colored-man-pages \

if [ -x "$(command -v lsd)" ]; then
  alias ls=lsd
  alias ll='ls -l --date relative --blocks permission,size,date,name'
fi

# Visual Studio Code shell integration. This slows down startup time by about 10ms
[[ "$TERM_PROGRAM" == "vscode" ]] && source "/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/contrib/terminal/browser/media/shellIntegration-rc.zsh"

# load explicit compdefs after compinit (not sure why this is necessary)
zinit wait'2b' lucid as'null' atinit'

if [ -x "$(command -v bat)" ]; then
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

  compdef less=less
  function batgrep() {
    command batgrep --color --smart-case --context=0 $* | command less -+J -+W
  }
  alias batgrep="noglob batgrep"
fi
compdef lsd=ls
if [ -x "$(command -v prettyping)" ]; then
  alias ping="prettyping --nolegend"
  compdef prettyping=ping
fi
if [ -x "$(command -v jira)" ]; then
  eval "$(jira completion zsh)" && compdef _jira jira
fi
if [ -x "$(command -v circleci)" ]; then
  eval "$(circleci completion zsh)" && compdef _circleci circleci
fi
if [ -x "$(command -v curlie)" ]; then
  # for this to work, an addition to fpath is necessary, see above
  compdef _curl curlie
  alias curl=curlie
fi
# azure-cli command completions
[[ -f ~/.zsh-personal-functions/az.completion ]] && . ~/.zsh-personal-functions/az.completion || true

# tabtab completions for pnpm
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

# repair c completion after it was boken by zinit
compdef __zoxide_z_complete __zoxide_zi
compdef __zoxide_z_complete z

' light-mode for zdharma-continuum/null

# it is 0.05s faster to load compinit in turbo mode, but all completions should be loaded with zinit then
if [[ -n "$KLA" ]]; then
  # weirdly, this is needed at k, test if "zi cd" gets compsleted
  autoload -U +X compinit && compinit
fi
#autoload -U +X bashcompinit && bashcompinit
#zinit cdreplay

if [ -f ~/.keprc ]; then
  ZSH_VERSION_TEMP="$ZSH_VERSION"
  unset ZSH_VERSION
  source ~/.keprc
  export ZSH_VERSION="$ZSH_VERSION_TEMP"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#echo ".zshrc finished:"
#END=$(gdate +%s.%N)
#echo "$END - $START" | bc
#zprof
