for f in \
	/usr/share/doc/fzf/examples/key-bindings.zsh \
	/usr/share/doc/fzf/examples/completion.zsh \
	"$HOME/.local/lib/Homebrew/opt/fzf/shell/key-bindings.zsh" \
	"$HOME/.local/lib/Homebrew/opt/fzf/shell/completion.zsh" \
; do
	[ -e "$f" ] && . "$f"
done; unset f

if which fdfind >/dev/null || which fd >/dev/null; then
	# Use fd (https://github.com/sharkdp/fd) instead of the default find
	# NOTE: fdfind is the binary in Debian

	if which fdfind >/dev/null; then
		FZF_FD_COMMAND='fdfind'
	else
		FZF_FD_COMMAND='fd'
	fi

	# these are used for **<TAB>
	_fzf_compgen_path() {
		echo "$1"
		command "$FZF_FD_COMMAND" -HL -E ".git" . "$1"
	}
	_fzf_compgen_dir() {
		command "$FZF_FD_COMMAND" -HL -E ".git" -t d . "$1"
	}

	FZF_DEFAULT_COMMAND="$FZF_FD_COMMAND"
	FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND -t f --"
	FZF_CTRL_T_OPTS='-m'
	FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND -H -E .git -E __pycache__ -E venv -t d --"
	[[ $NO_COLOR ]] \
		&& FZF_DEFAULT_OPTS='--layout=reverse --no-color' \
		|| FZF_DEFAULT_OPTS='--layout=reverse --ansi'
fi
