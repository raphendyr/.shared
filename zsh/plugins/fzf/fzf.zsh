for f in \
	/usr/share/doc/fzf/examples/key-bindings.zsh \
	/usr/share/doc/fzf/examples/completion.zsh \
	"$HOME/.local/lib/Homebrew/opt/fzf/shell/key-bindings.zsh" \
	"$HOME/.local/lib/Homebrew/opt/fzf/shell/completion.zsh" \
; do
	[ -e "$f" ] && . "$f"
done; unset f

if [[ $NO_COLOR ]]; then
	FZF_DEFAULT_OPTS='--layout=reverse --no-color'
	BAT_COLOR_OPTS='--color=never'
	GIT_COLOR_OPTS='--color=never'
	GIT_COLOR_VALUE='never'
	LS_COLOR_OPTS=''
else
	FZF_DEFAULT_OPTS='--layout=reverse --ansi'
	BAT_COLOR_OPTS='--color=always'
	GIT_COLOR_OPTS='--color=always'
	GIT_COLOR_VALUE='always'
	LS_COLOR_OPTS="-FG"
fi

FZF_PREVIEW_OPTS="--bind \
ctrl-p:toggle-preview,ctrl-o:toggle-sort,\
ctrl-b:preview-page-up,ctrl-f:preview-page-down,\
ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down,\
ctrl-y:preview-up,ctrl-e:preview-down,\
shift-up:preview-page-up,shift-down:preview-page-down,\
home:preview-top,end:preview-bottom"
if command -v bat >/dev/null; then
	FZF_FILE_PREVIEW_CMD="bat $BAT_COLOR_OPTS --style=numbers --line-range=:200"
	FZF_FILE_PREVIEW_OPTS="$FZF_PREVIEW_OPTS --preview '$FZF_FILE_PREVIEW_CMD {}'"
else
	FZF_FILE_PREVIEW_CMD="head -n200"
	FZF_FILE_PREVIEW_OPTS="$FZF_PREVIEW_OPTS --preview '$FZF_FILE_PREVIEW_CMD {}'"
fi


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

	fzf-preview-files() {
		FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_FILE_PREVIEW_OPTS" fzf -m "$@"
	}

	# **<TAB>
	FZF_DEFAULT_COMMAND="command $FZF_FD_COMMAND"
	# ^R = Search history
	# ^T = Paste selected file to the command line
	FZF_CTRL_T_COMMAND="command $FZF_FD_COMMAND -t f --"
	FZF_CTRL_T_OPTS="$FZF_FILE_PREVIEW_OPTS"
	# ALT-C = cd into the selected directory
	FZF_ALT_C_COMMAND="command $FZF_FD_COMMAND -H -E .git -E __pycache__ -E venv -t d --"
	FZF_ALT_C_OPTS="" # TODO: directory preview
fi

# Git integration
if command -v git >/dev/null; then
	_fzf_is_git_repo() {
		git rev-parse HEAD >/dev/null 2>&1
	}

	_fzf_git_files() {
		setopt localoptions pipefail no_aliases 2>/dev/null
		local ret=0 out
		if _fzf_is_git_repo; then
			out=$(
				git -c color.status=$GIT_COLOR_VALUE status --short --no-renames \
				| fzf ${=FZF_DEFAULT_OPTS} --height 40% --multi --nth 2..,.. \
					${=FZF_PREVIEW_OPTS} \
					--preview="read -r s f <<< {}; f=\${(Q)f}; if [[ \$s = '??' ]]; then if [[ -d \$f ]]; then ls $LS_COLOR_OPTS -1 -- \$f; else $FZF_FILE_PREVIEW_CMD -- \$f; fi; else git diff ${=GIT_COLOR_OPTS} -- \$f | sed 1,4d; fi" \
				| cut -c4-
				# | sed 's/.* -> //' ## select destination of renames
			)
			ret=$?
			LBUFFER+=$out
		fi
		zle reset-prompt
		return $ret
	}
	zle     -N      _fzf_git_files
	bindkey '^gf'   _fzf_git_files

	_fzf_git_branches() {
		setopt localoptions pipefail no_aliases 2>/dev/null
		local ret=0 out
		if _fzf_is_git_repo; then
			out=$(
				git branch -a ${=GIT_COLOR_OPTS} | grep -v '/HEAD\s' \
				| fzf ${=FZF_DEFAULT_OPTS} --height 40% --multi --tac \
					--preview-window right:70% ${=FZF_PREVIEW_OPTS} \
					--preview "git log -48 --oneline --graph --date=short ${=GIT_COLOR_OPTS} --pretty='format:%C(bold blue)%cd %C(auto)%h%d %s' \$(sed -e 's/^\*//' -e 's/^[[:space:]]*//' <<< {})" \
				| sed -e 's/^\*//' -e 's/^[[:space:]]*//' -e 's#^remotes/[^/]*/##'
			)
			ret=$?
			LBUFFER+=$out
		fi
		zle reset-prompt
		return $ret
	}
	zle     -N      _fzf_git_branches
	bindkey '^gb'   _fzf_git_branches

	_fzf_git_tags() {
		setopt localoptions pipefail no_aliases 2>/dev/null
		local ret=0 out
		if _fzf_is_git_repo; then
			out=$(
				git tag --sort -version:refname \
				| fzf ${=FZF_DEFAULT_OPTS} --height 40% --multi \
					--preview-window right:70% ${=FZF_PREVIEW_OPTS} \
					--preview "git show $GIT_COLOR_OPTS {}"
			)
			ret=$?
			LBUFFER+=$out
		fi
		zle reset-prompt
		return $ret
	}
	zle     -N      _fzf_git_tags
	bindkey '^gt'   _fzf_git_tags

	_fzf_git_hashes() {
		# TODO: add support for selecting multiple hashes
		setopt localoptions pipefail no_aliases 2>/dev/null
		local ret=0 out
		if _fzf_is_git_repo; then
			out=$(
				git log ${=GIT_COLOR_OPTS} --date=short --format="%C(bold blue)%cd %C(auto)%h%d %s %C(green)[%an]" --graph \
				| fzf ${=FZF_DEFAULT_OPTS} --height 40% --no-sort \
					${=FZF_PREVIEW_OPTS} \
					--preview "git show ${=GIT_COLOR_OPTS} \$(grep -o '[a-f0-9]\\{7,\\}' <<< {} | head -1)" \
				| grep -o '[a-f0-9]\{7,\}' | head -1
			)
			ret=$?
			LBUFFER+=$out
		fi
		zle reset-prompt
		return $ret
	}
	zle     -N      _fzf_git_hashes
	bindkey '^gh'   _fzf_git_hashes
	bindkey '^gg'   _fzf_git_hashes

	_fzf_git_remotes() {
		setopt localoptions pipefail no_aliases 2>/dev/null
		local ret=0 out
		if _fzf_is_git_repo; then
			out=$(
				git remote -v | awk '{print $1 "\t" $2}' | uniq \
				| fzf ${=FZF_DEFAULT_OPTS} --height 40% --tac \
					${=FZF_PREVIEW_OPTS} \
					--preview "git log -128 ${=GIT_COLOR_OPTS} --oneline --graph --date=short --pretty='format:%C(bold blue)%cd %C(auto)%h%d %s' {1}" \
				| cut -f1
			)
			ret=$?
			LBUFFER+=$out
		fi
		zle reset-prompt
		return $ret
	}
	zle     -N      _fzf_git_remotes
	bindkey '^gr'   _fzf_git_remotes

	_fzf_git_stashed() {
		setopt localoptions pipefail no_aliases 2>/dev/null
		local ret=0 out
		if _fzf_is_git_repo; then
			out=$(
				git stash list \
				| fzf ${=FZF_DEFAULT_OPTS} --height 40% -d: \
					--preview "git show $GIT_COLOR_OPTS {1}" \
				| cut -d: -f1
			)
			ret=$?
			LBUFFER+=$out
		fi
		zle reset-prompt
		return $ret
	}
	zle     -N      _fzf_git_stashed
	bindkey '^gs'   _fzf_git_stashed

	git-history() {
		setopt localoptions pipefail no_aliases 2>/dev/null
		local ret=0 out relative=x
		while [[ $# -gt 0 ]]; do
			case "$1" in
				-r) relative=x ;;
				-R) relative= ;;
			esac
			shift
		done
		out=$(
			git log ${=GIT_COLOR_OPTS} --graph --decorate --abbrev-commit --all \
				--pretty='format:%C(auto)%h %d %s %C(green)[%an] %C(bold blue)%ad' ${relative:+--date=relative} \
			| fzf ${=FZF_DEFAULT_OPTS} --no-sort \
				${=FZF_PREVIEW_OPTS} \
				--preview "git show $GIT_COLOR_OPTS \$(grep -o '[a-f0-9]\\{7,\\}' <<< {} | head -1)" \
			| grep -o "[a-f0-9]\{7,\}"
		)
		res=$?
		if [[ $out ]]; then
			git --no-pager log -1 $out
		fi
		return $res
	}
fi
