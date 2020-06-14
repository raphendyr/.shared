# format titles for screen and rxvt
function +my-title() {
	local a
	# escape '%' chars and make nonprintables visible
	a=${(V)1//\%/\%\%/}
	# join lines
	a=${a//$'\n'/}
	# add escapes
	[ -n "$a" ] && a=${(q)a}

	case $a in
		"ssh\ "*)
			;;
		"")
			a="%m %~"
			;;
		*)
			a="%m %# $a"
			;;
	esac
	case $TERM in
		xterm*|rxvt*)
			# OSC: 0 -> set icon + title, 1 -> set icon, 2 -> set title
			# NOTE: OSC should end with ST "\e\\", but that doen't seem to work well
			print -Pn "\e]0;$a\a"
			#print -Pn "\e]7;%~\a" # Konsole/iTerm set current dir
			#print -Pn "\e]30;%m: %1~\a" # Konsole set tab text
			;;
		screen*)
			print -Pn "\ek$a\e\\"
			;;
	esac
}

# preexec is called just before any command line is executed
add-zsh-hook precmd +my-title
add-zsh-hook preexec +my-title
