## My Virtualenv
#
VIRTUAL_ENV_DISABLE_PROMPT='disabled'

function +virtualenv-precmd() {
	if [[ $VIRTUAL_ENV ]]; then
		if [[ -z $_VIRTUAL_ENV_RPS ]]; then
			_VIRTUAL_ENV_RPS="%F{4}◢ ${VIRTUAL_ENV##*/} $(python --version | cut -d' ' -f2)%k%f"
		fi
		RPS1="$_VIRTUAL_ENV_RPS $RPS1"
	elif [[ $_VIRTUAL_ENV_RPS ]]; then
		unset _VIRTUAL_ENV_RPS
	fi
}

add-zsh-hook precmd +virtualenv-precmd
