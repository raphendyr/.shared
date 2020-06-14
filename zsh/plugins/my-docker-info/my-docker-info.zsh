function +my-add-docker-to-RPS() {
	local docker
	if [ "$DOCKER_HOST" ]; then
		docker=${DOCKER_HOST##*://}
		docker=${docker%:*}
		RPS1="%K{019}%F{255} ⚓%b$docker %k%f $RPS1"
	fi
}

add-zsh-hook precmd +my-add-docker-to-RPS
