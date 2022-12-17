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
	# skip prompt update in subshells
	if [[ ${ZSH_SUBSHELL:-0} -gt 0 ]]; then
		return
	fi
	local fn
	# reexecute precmd hooks
	for fn (precmd $precmd_functions); do
		(( $+functions[$fn] )) && $fn
	done
	# redraw
	{ zle && zle reset-prompt ; } 2>/dev/null || true
}

# Note `trap +my-add-jobs-trap-CHLD CHLD` uses subshell, which breaks zle
add-my-hook trapchld +my-add-jobs-trap-CHLD
