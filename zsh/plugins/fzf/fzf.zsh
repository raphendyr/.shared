for f in \
	/usr/share/doc/fzf/examples/key-bindings.zsh \
	/usr/share/doc/fzf/examples/completion.zsh \
	"$HOME/.local/lib/Homebrew/opt/fzf/shell/key-bindings.zsh" \
	"$HOME/.local/lib/Homebrew/opt/fzf/shell/completion.zsh" \
; do
	[ -e "$f" ] && . "$f"
done; unset f

if command -v fdfind >/dev/null || command -v fd >/dev/null; then
	# Use fd (https://github.com/sharkdp/fd) instead of the default find

	if command -v fdfind >/dev/null; then
		# NOTE: In Debian, the binary is 'fdfind'
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

	FZF_FILE_PREVIEW_OPTS="--bind \
ctrl-b:preview-page-up,ctrl-f:preview-page-down,\
ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down,\
ctrl-y:preview-up,ctrl-e:preview-down,\
shift-up:preview-page-up,shift-down:preview-page-down,\
home:preview-top,end:preview-bottom"
	if command -v bat >/dev/null; then
		FZF_FILE_PREVIEW_OPTS="$FZF_FILE_PREVIEW_OPTS --preview 'bat --color=always --style=numbers --line-range=:200 {}'"
	else
		FZF_FILE_PREVIEW_OPTS="$FZF_FILE_PREVIEW_OPTS --preview 'head -n200 {}'"
	fi

	fzf-preview-files() {
		FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_FILE_PREVIEW_OPTS" fzf -m "$@"
	}

	# **<TAB>
	FZF_DEFAULT_COMMAND="$FZF_FD_COMMAND"
	# ^R = Search history
	# ^T = Paste selected file to the command line
	FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND -t f --"
	FZF_CTRL_T_OPTS="-m $FZF_FILE_PREVIEW_OPTS"
	# ALT-C = cd into the selected directory
	FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND -H -E .git -E __pycache__ -E venv -t d --"
	[[ $NO_COLOR ]] \
		&& FZF_DEFAULT_OPTS='--layout=reverse --no-color' \
		|| FZF_DEFAULT_OPTS='--layout=reverse --ansi'
fi
