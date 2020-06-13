# ~/.zshrc
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[ -d "$ZSH_CACHE_DIR" ] || mkdir -p "$ZSH_CACHE_DIR"

HISTFILE="$ZSH_CACHE_DIR/zsh_history"
HISTSIZE=5000
SAVEHIST=10000

setopt appendhistory autocd extendedglob correct interactive_comments
unsetopt beep nomatch ignoreeof

[ -z "$LS_COLORS" ] && which dircolors >/dev/null && eval `dircolors -b`

zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' list-colors $LS_COLORS
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*:processes' command 'ps -o pid,tty,stat,args -u $UID'

zstyle ':vcs_info:*' actionformats '%F{5}(%F{3}%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats '%F{5}(%F{3}%s%F{5})%F{3}-%F{5}[%F{2}%b%F{6}%m%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

autoload -Uz compinit vcs_info edit-command-line
# .zcompdump incompatible between different versions
compinit -d "$ZSH_CACHE_DIR/zcompdump-${ZSH_VERSION:-$(zsh --version | awk '{print $2}')}"

zle -N edit-command-line
# normal-ish readline behaviour in insert mode
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char
bindkey "^U" backward-kill-line
bindkey "^W" backward-kill-word
bindkey "^K" kill-line
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward
bindkey "^[." insert-last-word
bindkey "^Xe" edit-command-line
bindkey "^X^E" edit-command-line
# up/down arrows
bindkey "^[[A" up-line-or-history
bindkey "^[[B" down-line-or-history
bindkey "^[OA" up-line-or-history
bindkey "^[OB" down-line-or-history
# Alt + left/right arrows move word
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[l" forward-word
bindkey "^[h" backward-word
# home, end, etc.
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[3~" delete-char
bindkey "\e[7~" beginning-of-line
bindkey "\e[8~" end-of-line
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
# vi style line editing
#bindkey -v
# and a few modifications to the default vi bindings
bindkey -a "?" vi-history-search-backward
bindkey -a "/" vi-history-search-forward
bindkey -a "v" edit-command-line
# disable : and cursor keys in command mode
bindkey -ar ":"
bindkey -ar "^[[A"
bindkey -ar "^[[B"
bindkey -ar "^[[C"
bindkey -ar "^[[D"
bindkey -ar "^[OA"
bindkey -ar "^[OB"
bindkey -ar "^[OC"
bindkey -ar "^[OD"

stty erase 
stty erase 
stty intr  

# PS1
#PS1='%B%m%b %~ %(?..%B%F{red}%?%f%b )%# '
#PS1='%F{green}%n@%m%f:%F{cyan}%~%f%(?.. %B%F{red}%?%f%b )%# '
PS1='%F{green}%n@%m%f:%F{cyan}%(6~|%-2~/…/%3~|%~)%f%(?.. %B%F{red}%?%f%b )%# '
#RPS1='%1v'
if [ -r "/etc/debian_chroot" -a -s "/etc/debian_chroot" ]; then
    PS1="($(cat /etc/debian_chroot))$PS1"
fi

# format titles for screen and rxvt
function title() {
     # escape '%' chars and make nonprintables visible
     a=${(V)1//\%/\%\%/}
     # join lines
     a=${a//$'\n'/}
     # add escapes
     [ -n "$a" ] && a=${(q)a}

     case $TERM in xterm*|rxvt*|screen*)
         case $a in
             "ssh\ "*)
                 print -Pn "\e]0;"${a}"\a"
                 ;;
             "")
                 print -Pn "\e]0;%m %~\a"
                 ;;
             *)
                 print -Pn "\e]0;%m %# "${a}"\a"
                 ;;
         esac
         ;;
     esac
}

# precmd is called just before the prompt is printed
function precmd() {
    local docker
    title
    vcs_info
    #psvar[1]="$vcs_info_msg_0_"
    RPS1="$vcs_info_msg_0_"
    if [ "$DOCKER_HOST" ]; then
        docker=${DOCKER_HOST##*://}
        docker=${docker%:*}
        RPS1="%K{blue}%F{white} %B⚓%b$docker %k%f $RPS1"
    fi
}

### git: Show +N/-N when your local branch is ahead-of or behind remote HEAD.
zstyle ':vcs_info:git*+set-message:*' hooks git-st
function +vi-git-st() {
    local ahead behind
    local -a gitstatus

    ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
    (( $ahead )) && gitstatus+=( "+${ahead}" )

    behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
    (( $behind )) && gitstatus+=( "-${behind}" )

    hook_com[misc]+=${(j:/:)gitstatus}
}

# preexec is called just before any command line is executed
function preexec() {
    title "$1"
}

# Read aliases
[ -f "$HOME/.travis/travis.sh" ] && . "$HOME/.travis/travis.sh"
[ -r "$HOME/.aliases" ] && . "$HOME/.aliases"
[ -r "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
true # set exit 0 for prompt

# vim: set ts=4 sw=4 tw=0 noet syntax=zsh filetype=zsh :
