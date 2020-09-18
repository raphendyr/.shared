function +my-add-jobs-to-RPS() {
	local count info
	count=${#jobstates} # in powerlevel10k: ${(%):-%j}
	if (( $count > 0 )); then
		if (( $count == 1 )); then
			(( ${(Mw)#jobstates#running:} )) && info="%F{2}⚙" || info="%F{11}⚙⁺"
		else
			info="%F{2}⚙ ${(Mw)#jobstates#running:}"
			count=${(Mw)#jobstates#suspended:}
			(( $count > 0 )) && info+="%F{11}⁺$count"
		fi
		RPS1="$info%k%f $RPS1"
	fi
}

add-zsh-hook precmd +my-add-jobs-to-RPS


function +my-add-jobs-trap-CHLD() {
	setopt localoptions
	local fn
	# reexecute precmd hooks
	for fn (precmd $precmd_functions); do
		(( $+functions[$fn] )) && $fn
	done
	# redraw
	{ zle && zle reset-prompt ; } 2>/dev/null || true
}

# Note `trap +my-add-jobs-trap-CHLD CHLD` uses subshell, which breaks zle
# TODO: support hooks like system to add functions to traps
TRAPCHLD() {
	+my-add-jobs-trap-CHLD
}
