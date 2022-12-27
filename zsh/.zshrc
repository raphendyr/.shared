# ~/.zshrc
[[ $ZSH ]] || ZSH="${${(%):-%x}:A:h}"
[[ $ZSH == ${HOME:A} ]] && ZSH="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
[[ $ZSH_DATA_DIR ]] || ZSH_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
[[ $ZSH_CACHE_DIR ]] || ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d $ZSH_CACHE_DIR ]] || mkdir -m 0700 -p "$ZSH_CACHE_DIR"

# History
setopt appendhistory extended_history hist_expire_dups_first hist_ignore_dups
HISTFILE="$ZSH_CACHE_DIR/zsh_history"
HISTSIZE=50000
SAVEHIST=10000
HISTORY_IGNORE="(ls|ls *|cd|cd..|cd ..|pwd|exit|rm -rf *)"
HISTORY_IGNORE_SESSION="(  *|exit|rm -rf *)"
zshaddhistory() {
	emulate -L zsh
	# when HISTORY_IGNORE requires EXTENDED_GLOB syntax
	#setopt extendedglob
	[[ $1 != ${~HISTORY_IGNORE_SESSION} ]]
}

# Check color support
export NO_COLOR=yes
case "$TERM" in
	''|dumb|vt100|xterm|xterm-old)
		# Known no-color terminals
		;;
	xterm-color|*-256color)
		# TERM can indicate a color support
		unset NO_COLOR
		;;
	*)
		# Try to detect
		# 1) Check terminfo databas
		# 2) If not, we can try to test with tput. If it works,
		#    assume color support is compliant with Ecma-48 (ISO/IEC-6429).
		if { command -v infocmp && infocmp && { infocmp | grep -qsF 'colors#' ; }; } >/dev/null 2>&1 \
			|| { command -v tput && tput setaf 1; } >/dev/null 2>&1
		then
			unset NO_COLOR
		fi
		;;
esac


setopt autocd extendedglob correct interactive_comments
unsetopt beep nomatch ignoreeof
setopt hup # send hup to jobs on disown (exit)

if [[ -z $LS_COLORS && -z $NO_COLOR ]]; then
	# recalculate if dircolors exists, elese use a cached entry
	command -v dircolors >/dev/null && eval `dircolors -b` \
		|| LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'
fi

zstyle ':completion:*' completer _expand _complete
[[ $LS_COLORS ]] && zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*:processes' command 'ps -o pid,tty,stat,args -u $UID'

autoload -Uz compinit bashcompinit edit-command-line
# .zcompdump incompatible between different versions
compinit -d "$ZSH_CACHE_DIR/zcompdump-${ZSH_VERSION:-$(zsh --version | cut -d' ' -f2)}"
bashcompinit

zle -N edit-command-line
# normal-ish readline behaviour in insert mode
bindkey "^H" backward-delete-char # backspace + ctrl
bindkey "^?" backward-delete-char # backspace
bindkey "^U" backward-kill-line
bindkey "^W" backward-kill-word
bindkey "^K" kill-line
bindkey "^F" kill-word
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
bindkey "\e[1~" beginning-of-line # home
# bindkey "\e[2~" # insert
bindkey "\e[3~" delete-char # delete
bindkey "\e[3;5~" kill-word # delete + ctrl
bindkey "\e[4~" end-of-line # end
# bindkey "\e[5~" # page up
# bindkey "\e[6~" # page down
bindkey "\e[7~" beginning-of-line # home
bindkey "\e[8~" end-of-line # end
bindkey "\e[H" beginning-of-line # xterm home
bindkey "\e[F" end-of-line # xterm end
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
if [[ $NO_COLOR ]]; then
	PS1='%n@%m'
elif [[ $EUID == 0 ]]; then
	PS1='%F{red}%B%m%b%f'
else
	PS1='%F{green}%n%f@%F{green}%m%f'
fi
# full path: ':%F{cyan}%~%f'
[[ $NO_COLOR ]] \
	&& PS1="$PS1"':%(6~|%-2~/…/%3~|%~)%(?.. %? )%# ' \
	|| PS1="$PS1"':%F{cyan}%(6~|%-2~/…/%3~|%~)%(?.. %F{red}%B%?%b )%f%# '
if [ -r "/etc/debian_chroot" -a -s "/etc/debian_chroot" ]; then
	[[ $NO_COLOR ]] \
		&& PS1="($(cat /etc/debian_chroot))$PS1" \
		|| PS1="(%F{yellow}$(cat /etc/debian_chroot)%f)$PS1"
fi
if [[ $NO_COLOR ]]; then
	PS2='> '
	PS3='?# '
	PS4='+%N:%i> '
else
	PS2='%F{magenta}%B%_%b%f> '
	PS3='%F{magenta}%B?%b%f# '
	PS4='%B%F{black}+%b%f%F{blue}%I%f:%F{cyan}%N%f:%F{blue}%i%f> '
fi
# RPROMPT
#RPS1='%1v'
setopt transient_rprompt # remove right prompt after command is entered

# Handle functions and plugins
[[ -d "$ZSH_DATA_DIR/functions" ]] && fpath=("$ZSH_DATA_DIR/functions" $fpath)
[[ -d "$ZSH/functions" ]] && fpath=("$ZSH/functions" $fpath)
# Main plugins, with specific order of loading
if [[ -d "$ZSH/plugins" ]]; then
	autoload -Uz add-zsh-hook
	for _plugin in \
		my-title \
		my-git-info \
		my-virtualenv \
		my-docker-info \
		dotenv \
		my-jobs-info \
		fzf \
		my-downloadable \
	; do
		_path="$ZSH/plugins/$_plugin/$_plugin.zsh"
		if [[ -f $_path ]]; then
			. "$_path"
			[[ -f "${_path:h}.local.zsh" ]] && . "${_path:h}.local.zsh"
		else
			echo "Unable read '$_path', are submodules downloaded?"
		fi
	done; unset _plugin _path
fi
# Rest of the plugins, which are optionally installed to the system
if [[ -d "$ZSH_DATA_DIR/plugins" ]]; then
	autoload -Uz add-zsh-hook
	for _plugin ("$ZSH_DATA_DIR/plugins/"*/); do
		for _path ("$_plugin${${_plugin%/}##*/}.plugin.zsh" "$_plugin${${_plugin%/}##*/}.zsh"); do
			if [[ -f $_path ]]; then
				[[ -f "${_path:h}.before.zsh" ]] && . "${_path:h}.before.zsh"
				. "$_path"
				[[ -f "${_path:h}.after.zsh" ]] && . "${_path:h}.after.zsh"
				break
			fi
		done
	done; unset _plugin _path
fi
# autload all functions from fpaths under HOME
for _path ($fpath); do
	[[ $_path != "$HOME/"* ]] && break
	for _function in "$_path/"*(.); do
		[[ -f $_function && ${_function:t} != _* ]] && autoload -Uz "${_function:t}"
	done
done; unset _path _function

# Read aliases
[ -f "$HOME/.travis/travis.sh" ] && . "$HOME/.travis/travis.sh"
[ -r "$HOME/.aliases" ] && . "$HOME/.aliases"
[ -r "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
true # set exit 0 for prompt

# vim: set ts=4 sw=4 tw=0 noet syntax=zsh filetype=zsh :
