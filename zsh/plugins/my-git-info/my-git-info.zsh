# Setup vcs_info
autoload -Uz vcs_info

# style
if [[ $NO_COLOR ]]; then
	zstyle ':vcs_info:*' actionformats '%s[%b|%a] '
	zstyle ':vcs_info:*' formats       '%s[%b%m%u] '
	zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat ':%r'
else
	zstyle ':vcs_info:*' actionformats '%F{5}%s%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
	zstyle ':vcs_info:*' formats       '%F{5}%s%F{5}[%F{2}%b%F{6}%m%F{9}%u%F{5}]%f '
	zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
fi
zstyle ':vcs_info:*' enable git

# quilt
zstyle ':vcs_info:*' quilt-standalone +vi-quilt-active
zstyle ':vcs_info:*' use-quilt true

function +vi-quilt-active() {
	[[ $PWD == /usr/src(|/*) && -f .pc/.version ]] && return 0
	return 1
}

# git: Show +N/-N when your local branch is ahead-of or behind remote HEAD.
zstyle ':vcs_info:git*+set-message:*' hooks git-st
function +vi-git-st() {
	local ahead behind stashes
	local -a gitstatus

	# ahead/behind
	ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
	(( $ahead )) && gitstatus+=( "+${ahead//[[:space:]]}" )
	behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
	(( $behind )) && gitstatus+=( "-${behind//[[:space:]]}" )
	hook_com[misc]+=${(j:/:)gitstatus}

	# stashes
	#stashes=$(git stash list 2>/dev/null | wc -l)
	stashes="${hook_com[base]}/.git/logs/refs/stash"
	stashes=$(test -e "$stashes" && wc -l < "$stashes")
	(( $stashes )) && hook_com[unstaged]="@${stashes//[[:space:]]}"

	# remember git root
	gr=$(realpath "--relative-to=$PWD" "${hook_com[base]}" 2>/dev/null)
	[ -z "$gr" -o ${#gr} -gt ${#hook_com[base]} ] && gr=${hook_com[base]}
}

# set RPS1 to vcs_info (this should be the first plugin touching that)
function +vi-precmd() {
	vcs_info
	RPS1="$vcs_info_msg_0_"
	[ "$vcs_info_msg_0_" ] || unset gr
}

add-zsh-hook precmd +vi-precmd
