# format titles for screen and rxvt
function +my-title() {
	local title tab

	if [[ $1 ]]; then
		# escape '%' chars and make nonprintables visible
		title=${(V)1//\%/\%\%/}
		# join lines
		title=${title//$'\n'/}
		# split words
		title=(${(z)title})

		# create a minimalistic command list
		local commands=() cmdid=1 take=x i word
		for ((i=1; i <= ${#title}; i++)); do
			word=${title[$i]}
			if [[ ${title[$i]} =~ '^([|;)(}{]|\|\||&&)$' ]]; then
				if [[ ${commands[$cmdid-1]} = ';' ]]; then
					commands[$cmdid-1]=${title[$i]}
				else
					commands[$((cmdid++))]=${title[$i]}
				fi
				take=x
			elif [[ ${title[$i]} =~ '^[0-9]*[<>]&?$' ]]; then
				(( i++ ))
			elif [[ $take ]]; then
				commands[$((cmdid++))]=${title[$i]}
				take=
			fi
		done
		tab=${(pj::)commands}

		# NOTE: escape, so that `print -P` doesn't expand contents of the title/tab
		tab="$__my_title_tab_prefix%1~ %# ${(q)tab}" # nbsp
		title="$__my_title_prefix${__my_title_prefix:+%# }${(qpj: :)title}" # nbsp
	else
		tab="$__my_title_tab_prefix%1~"
		title="$__my_title_prefix%(6~|%-2~/…/%3~|%~)"
	fi
	+my-title-set "$title" "$tab"
}


if [[ $SSH_TTY ]]; then
	__my_title_prefix='%n@%M '
	__my_title_tab_prefix='%M '
	if [[ -z $NO_COLOR && $(locale charmap) = 'UTF-8' ]]; then
		__my_title_prefix='🖧 '"$__my_title_prefix" # nbsp
		if [[ $EUID = 0 ]]; then
			__my_title_tab_prefix='⌥ '"$__my_title_tab_prefix" # nbsp
		fi
		__my_title_tab_prefix='🖧 '"$__my_title_tab_prefix" # nbsp
	elif [[ $EUID = 0 ]]; then
		__my_title_tab_prefix='# '"$__my_title_tab_prefix"
	fi
elif [[ $EUID = 0 ]]; then
	__my_title_prefix='%n@%m '
	__my_title_tab_prefix='%m '
	if [[ -z $NO_COLOR && $(locale charmap) = 'UTF-8' ]]; then
		__my_title_tab_prefix='⌥ '"$__my_title_tab_prefix" # nbsp
	else
		__my_title_tab_prefix='# '"$__my_title_tab_prefix"
	fi
else
	__my_title_prefix='%m '
	__my_title_tab_prefix=''
fi


case $TERM in
	xterm*|rxvt*)
		+my-title-set() {
			# OSC: 0 -> set icon + title, 1 -> set icon, 2 -> set title
			# NOTE: OSC should end with ST "\e\\", but that doen't seem to work well
			print -Pn "\e]0;$1\a"
			#print -Pn "\e]7;%~\a" # Konsole/iTerm set current dir
			print -Pn "\e]30;$2\a" # Konsole set tab text (non-standard)
		}
		;;
	screen*)
		+my-title-set() {
			print -Pn "\ek$1\e\\"
		}
		;;
	*)
		+my-title-set() {}
		;;
esac


if typeset -f -- '+my-title-set' >/dev/null; then
	# precmd is called just before prompt is printed
	add-zsh-hook precmd +my-title
	# preexec is called just before any command line is executed
	add-zsh-hook preexec +my-title
fi
