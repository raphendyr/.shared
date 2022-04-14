# check terminal color support
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
		if { command -v infocmp && infocmp && { infocmp | grep -qsF 'colors#' ; }; } >&/dev/null \
			|| { command -v tput && tput setaf 1; } >&/dev/null
		then
			unset NO_COLOR
		fi
		;;
esac


# define dynamic prompt
PROMPT_DIRTRIM=4

# - red for root, green for normal user, cyan for $PWD
if [[ $NO_COLOR ]]; then
	# $user @ $host :
	__build_prompt_pre='\u@\h:\w'
elif [[ $EUID = 0 ]]; then
	# red $host res :
	__build_prompt_pre='\[\e[0;31m\]\h\[\e[0m\]:\[\e[0;36m\]\w\[\e[0m\]'
else
	# green $user res @ green $host res :
	__build_prompt_pre='\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;36m\]\w\[\e[0m\]'
fi

# - add debian_chroot
if [[ -r "/etc/debian_chroot" && -s "/etc/debian_chroot" ]]; then
	if [[ $NO_COLOR ]]; then
		# ( $/etc/debian_chroot_chroot ) $ps1
		__build_prompt_pre="($(cat /etc/debian_chroot))$__build_prompt_pre"
	else
		# yellow ( $/etc/debian_chroot_chroot ) res $ps1
		__build_prompt_pre="(\[\e[0;33m\]$(cat /etc/debian_chroot)\[\e[0m\])$__build_prompt_pre"
	fi
fi

# - handle exit code
if [[ $NO_COLOR ]]; then
	__build_prompt() {
		local _exit=$? # store exit code of the last command
		PS1=$__build_prompt_pre
		[[ $_exit != 0 ]] && PS1+=" $_exit "
		PS1+='\$ '
	}
else
	__build_prompt() {
		local _exit=$? # store exit code of the last command
		PS1=$__build_prompt_pre
		# $PS1 light-red $? res
		[[ $_exit != 0 ]] && PS1+=" \[\e[01;31m\]$_exit\[\e[0m\] "
		PS1+='\$ '
	}
fi

# - add the "hook"
[[ $PROMPT_COMMAND == *'__build_prompt'* ]] \
	|| PROMPT_COMMAND="__build_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# PS2..PS4
if [[ $NO_COLOR ]]; then
	PS2='> '
	PS3='?# '
	PS4='+ '
else
	PS2='\[\e[01;35m\]>\[\e[0m\] ' # magenta > res
	PS3='\[\e[01;35m\]?\[\e[0m\]# ' # magenta ? res #
	PS4='\[\e[01;30m\]+\[\e[0m\] ' # light-black + res
fi


# update title of the terminal
if [[ $SSH_TTY ]]; then
	__PROMPT_TITLE='\u@\H \w'
	__PROMPT_TAB='\H \W'
	if [[ -z $NO_COLOR && $(locale charmap) = 'UTF-8' ]]; then
		__PROMPT_TITLE='🖧 '"$__PROMPT_TITLE"
		[[ $EUID = 0 ]] && __PROMPT_TAB='⌥ '"$__PROMPT_TAB"
		__PROMPT_TAB='🖧 '"$__PROMPT_TAB"
	elif [[ $EUID = 0 ]]; then
		__PROMPT_TAB='# '"$__PROMPT_TAB"
	fi
elif [[ $EUID == 0 ]]; then
	__PROMPT_TITLE='\u@\h \w'
	__PROMPT_TAB='\h \W'
	[[ -z $NO_COLOR && $(locale charmap) = 'UTF-8' ]] \
		&& __PROMPT_TAB='⌥ '"$__PROMPT_TAB" \
		|| __PROMPT_TAB='# '"$__PROMPT_TAB"
else
	__PROMPT_TITLE='\h \w'
	__PROMPT_TAB='\W'
fi

case "$TERM" in
	xterm*|rxvt*)
		# OSC 0: Set icon name and window title
		# OSC 1: Set icon name
		# OSC 2: Set window title
		# OSC 30: Set tab text in Konsole (non-standard)
		# command: ESC ] <id> ; <data> BEL
		__update_title() {
			printf "\033]0;%s\007" "${__PROMPT_TITLE@P}"
			printf "\033]30;%s\007" "${__PROMPT_TAB@P}"
		}
		;;
	screen*)
		# ESC k ... ESC \
		__update_title() { printf "\033k%s\033\134" "${__PROMPT_TITLE@P}"; }
		;;
esac

typeset -f -- __update_title >/dev/null \
	&& [[ ${PROMPT_COMMAND:-} != *'__update_title'* ]] \
	&& PROMPT_COMMAND="__update_title${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
