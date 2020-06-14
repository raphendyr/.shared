# Setup vcs_info
autoload -Uz vcs_info

zstyle ':vcs_info:*' actionformats '%F{5}(%F{3}%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats '%F{5}(%F{3}%s%F{5})%F{3}-%F{5}[%F{2}%b%F{6}%m%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
zstyle ':vcs_info:*' enable git

# git: Show +N/-N when your local branch is ahead-of or behind remote HEAD.
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

function +vi-precmd() {
	vcs_info
	RPS1="$vcs_info_msg_0_"
}

add-zsh-hook precmd +vi-precmd
