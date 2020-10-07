# ~/.bashrc
[ "$PS1" ] || return

BASH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/bash"
[ -d "$BASH_CACHE_DIR" ] || mkdir -m 0700 -p "$BASH_CACHE_DIR"

HISTCONTROL=ignoredups
HISTFILE="$BASH_CACHE_DIR/bash_history"
HISTSIZE=50000
HISTFILESIZE=10000
shopt -s histappend

shopt -s checkwinsize
# disable flow control
stty -ixon -ixoff
# file creation mode
umask 0022

# add dynamic and colored prompt
if [[ $PROMPT_COMMAND != *'__build_prompt'* || $PROMPT_COMMAND != *'__update_title'* ]]; then
	BASH_ROOT=$(cd ~; rc=$(readlink .bashrc); cd "${rc%/*}"; echo "$PWD")
	[[ -e "$BASH_ROOT/dynamic-prompt.bash" ]] && . "$BASH_ROOT/dynamic-prompt.bash"
fi

# Aliases
[ -f "$HOME/.travis/travis.sh" ] && . "$HOME/.travis/travis.sh"
[ -r "$HOME/.aliases" ] && . "$HOME/.aliases"

# Completion
[ -z "${BASH_COMPLETION_VERSINFO:-}" ] \
	&& ! shopt -oq posix \
	&& [ -f /etc/bash_completion ] \
	&& . /etc/bash_completion

# Local changes
[ -r "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"

true # set exit 0 for prompt

# vim: set ts=4 sw=4 tw=0 noet syntax=bash filetype=bash :
