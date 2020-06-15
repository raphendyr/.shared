for f in \
	/usr/share/doc/fzf/examples/key-bindings.zsh \
	/usr/share/doc/fzf/examples/completion.zsh \
; do
	[ -e "$f" ] && . "$f"
done; unset f

if which fdfind >/dev/null; then
	# Use fd (https://github.com/sharkdp/fd) instead of the default find
	# NOTE: fdfind is the binary in Debian
	# thse are used for **<TAB>
	_fzf_compgen_path() {
		echo "$1"
		command fdfind -c always -HL -E ".git" . "$1"
	}
	_fzf_compgen_dir() {
		command fdfind -c always -HL -E ".git" -t d . "$1"
	}

	FZF_DEFAULT_COMMAND='fdfind -c always'
	FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND -t f --"
	FZF_CTRL_T_OPTS='-m'
	FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND -H -E .git -E __pycache__ -E venv -t d --"
	FZF_DEFAULT_OPTS='--ansi --layout=reverse'
fi
