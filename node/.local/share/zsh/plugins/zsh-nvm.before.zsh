# Before loading nvm plugin
export NVM_DIR="$HOME/.local/share/nvm"
NVM_LAZY_LOAD=true
NVM_COMPLETION=true

function +zsh-nvm-precmd() {
	if [[ $NVM_BIN ]]; then
		if [[ -z $_ZSH_NVM_RPS || $NVM_BIN != ${_ZSH_NVM_BIN:-} ]]; then
			_ZSH_NVM_BIN=$NVM_BIN
			_ZSH_NVM_RPS="%F{4}◢ Node $(node --version)%k%f"
		fi
		RPS1="$_ZSH_NVM_RPS $RPS1"
	elif [[ $_ZSH_NVM_RPS ]]; then
		unset _ZSH_NVM_RPS
	fi
}

add-zsh-hook precmd +zsh-nvm-precmd
