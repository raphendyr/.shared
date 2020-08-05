# ~/.bashrc
[ "$PS1" ] || return

BASH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/bash"
[ -d "$BASH_CACHE_DIR" ] || mkdir -m 0700 -p "$BASH_CACHE_DIR"

HISTCONTROL=ignoredups
HISTFILE="$BASH_CACHE_DIR/bash_history"
HISTSIZE=50000
HISTFILESIZE=10000

# disable flow control
stty -ixon -ixoff
# file creation mode
umask 0022

# define dynamic prompt
# - red for root, green for normal
if [[ $EUID == 0 ]]; then
	# red $host res
	__build_prompt_pre='\[\e[0;31m\]\h\[\e[0m\]'
else
	# green $user res @ green $host res
	__build_prompt_pre='\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]'
fi
# - shorten SPWD
if which spwd >/dev/null; then
	# $ps1 : cyan $(spwd) res
	__build_prompt_init() { PS1="$__build_prompt_pre:\[\e[0;36m\]$(spwd)\[\e[0m\]"; }
else
	# $ps1 : cyan $PWD res
	__build_prompt_pre+=':\[\e[0;36m\]\w\[\e[0m\]'
	__build_prompt_init() { PS1=$__build_prompt_pre; }
	PROMPT_DIRTRIM=4
fi
# - add debian_chroot
if [ -r "/etc/debian_chroot" -a -s "/etc/debian_chroot" ]; then
	# yellow ( $/etc/debian_chroot_chroot ) res $ps1
	__build_prompt_pre="(\[\e[0;33m\]$(cat /etc/debian_chroot)\[\e[0m\])$__build_prompt_pre"
fi
# - handle exit code
function __build_prompt {
	local _exit=$? # store exit code of the last command
	__build_prompt_init
	if [[ $_exit != 0 ]]; then
		# $PS1 light-red $? res
		PS1+=" \[\e[01;31m\]$_exit\[\e[0m\] "
	fi
	PS1+='\$ '
}
[[ "$PROMPT_COMMAND" = "${PROMPT_COMMAND#*__build_prompt}" ]] && PROMPT_COMMAND="__build_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
# PS2..PS4
PS2='\[\e[01;35m\]>\[\e[0m\] ' # magenta > res
PS3='\[\e[01;35m\]?\[\e[0m\]# ' # magenta ? res #
PS4='\[\e[01;30m\]+\[\e[0m\] ' # light-black + res

# Read aliases
[ -f "$HOME/.travis/travis.sh" ] && . "$HOME/.travis/travis.sh"
[ -r "$HOME/.aliases" ] && . "$HOME/.aliases"
[ -r "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
true # set exit 0 for prompt

# vim: set ts=4 sw=4 tw=0 noet syntax=bash filetype=bash :
