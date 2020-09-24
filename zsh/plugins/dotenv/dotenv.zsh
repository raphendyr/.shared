## Dotenv
# based on https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/dotenv/dotenv.plugin.zsh

## Settings
: ${ZSH_DOTENV_QUIET:=}
: ${ZSH_DOTENV_PROMPT:=yes}
: ${ZSH_DOTENV_FILE:=.env}
: ${ZSH_DOTENV_ALLOWED_LIST:="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}}/dotenv-allowed.list"}
: ${ZSH_DOTENV_DISALLOWED_LIST:="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}}/dotenv-disallowed.list"}
typeset -r ZSH_DOTENV_FILE
typeset -r ZSH_DOTENV_ALLOWED_LIST
typeset -r ZSH_DOTENV_DISALLOWED_LIST

## Context
_ZSH_DOTENV_DEACTIVE=()
_ZSH_DOTENV_HEAD=
_ZSH_DOTENV_SESSION_ALLOW=()
_ZSH_DOTENV_STACK=()
_ZSH_DOTENV_STACK_TOP_WD=


## Functions

# utils

+dotenv-debug() {
	local ps=$PS4
	if [[ -z $ZSH_DOTENV_QUIET ]]; then
		[[ $ps == *%x* ]] && ps=${ps//\%x/[dotenv]} || ps=${ps/+/+[dotenv]}
		while [[ $# > 0 ]]; do
			case "$1" in
				[A-Za-z]=*) ps=${ps//\%${1%%=*}/${1#*=}} ;;
				--) shift; break ;;
				*) break ;;
			esac
			shift
		done
		printf "%s %s\n" "${(%)ps}" "$(sed 's/\(PASSWORD\|SECRET\|TOKEN\)=\('"'[^']*'"'\|"[^"]*"\|[^[:space:]"'\'']*\)/\1= [hidden] /g' <<< "$*")"
	fi
}

+dotenv-common-prefix() {
	# return:
	# - _dotenv_prefix
	[[ $1 == $2 ]] && { _dotenv_prefix=$1; return; }

	local a=(${(@s:/:)1}) b=(${(@s:/:)2}) common=() m
	[[ ${#a} < ${#b} ]] && m=${#a} || m=${#b}
	if [[ $m > 0 ]]; then
		for i ({1..$m}); do
			[[ ${a[i]} != ${b[i]} ]] && break
			common+=${a[i]}
		done
	fi
	_dotenv_prefix="/${(j:/:)common}"
}

# stack

+dotenv-stack-push() {
	local context dotenv=$1 backward=$2
	context=("$dotenv" "$backward")
	_ZSH_DOTENV_STACK+=("${(pj:\0:)context}0")
	_ZSH_DOTENV_STACK_TOP_WD=${${dotenv%$ZSH_DOTENV_FILE}%%/}
}

+dotenv-stack-pop() {
	local context
	[[ $_ZSH_DOTENV_STACK ]] || return 1
	context=${_ZSH_DOTENV_STACK[-1]}
	shift -p 1 _ZSH_DOTENV_STACK
	context=("${(@0)${context[1,-2]}}")
	dotenv=${context[1]}
	shift 1 context
	backward=${(pj:\0:)context}

	local _dotenv_stack_top_env _dotenv_stack_top_wd
	if +dotenv-stack-peek-dotenv; then
		_ZSH_DOTENV_STACK_TOP_WD=$_dotenv_stack_top_wd
	else
		_ZSH_DOTENV_STACK_TOP_WD=
	fi
}

+dotenv-stack-peek-dotenv() {
	# returns:
	# - _dotenv_stack_top_env
	# - _dotenv_stack_top_wd
	local context
	[[ $_ZSH_DOTENV_STACK ]] || return 1
	context=${_ZSH_DOTENV_STACK[-1]}
	context=("${(@0)${context[1,-2]}}")
	_dotenv_stack_top_env=${context[1]}
	_dotenv_stack_top_wd=${${_dotenv_stack_top_env%$ZSH_DOTENV_FILE}%%/}
}

# activate / deactivate

+dotenv-activate() {
	local dotwd=$1 dotenv=$2 confirmation

	if [[ -s $ZSH_DOTENV_DISALLOWED_LIST ]] && grep -qs -Fx "$dotwd" "$ZSH_DOTENV_DISALLOWED_LIST"; then
		# early return if disallowed
		return
	fi

	if { [[ -s $ZSH_DOTENV_ALLOWED_LIST ]] && grep -qs -Fx "$dotwd" "$ZSH_DOTENV_ALLOWED_LIST"; } \
		|| [[ ${_ZSH_DOTENV_SESSION_ALLOW[(ie)$dotwd]} -le ${#_ZSH_DOTENV_SESSION_ALLOW} ]]
	then
		# allow
	elif [[ -o interactive && "$ZSH_DOTENV_PROMPT" == yes ]]; then
		# print same-line prompt and output newline character if necessary
		echo "Found dotenv '$dotenv' file."
		[[ $NO_COLOR ]] \
			&& confirmation="([Y]es/[n]o/[a]lways/n[e]ver)" \
			|| confirmation="%f(%F{2}%B%UY%u%bes%f/%F{2}%B%Ua%u%blways%f/%F{3}%B%Un%u%bo%f/%F{3}n%B%Ue%u%bver%f)"
		echo -n "${(%)${${PS3/\?/Source it?}//\#/}} ${(%)confirmation} "
		read -k 1 confirmation || break
		[[ $confirmation != $'\n' ]] && echo

		case "$confirmation" in
			[nN]) _ZSH_DOTENV_DEACTIVE+=($dotwd) ; return ;;
			[eE]) echo "$dotwd" >> "$ZSH_DOTENV_DISALLOWED_LIST"; return ;;
			[aA]) echo "$dotwd" >> "$ZSH_DOTENV_ALLOWED_LIST" ;;
			[yY]|$'\n') _ZSH_DOTENV_SESSION_ALLOW+=($dotwd) ;;
			*)  # invalid input -> cancel
				echo "Dotenv not sourced. Run 'dotenv-load' to load it."
				return ;;
		esac
	else
		# disallow, but no session safe (someone might enable prompt)
		return
	fi

	# zsh -c "
	# 	declare -r __vars=\$(declare +r | sort)
	# 	declare -r __aliases=\$(alias | sort)
	# 	. ./$ZSH_DOTENV_FILE 8>&- 9>&-
	# 	diff <(echo \$__vars) <(declare +r | sort) >&8
	# 	diff <(echo \$__aliases) <(alias | sort) >&9
	# " 8>&1 9>&1

	local linenum=-1 dotenv_num=$((${#_ZSH_DOTENV_STACK} + 1))
	local backward=() line name value old word
	local MATCH MBEGIN MEND
	local -a match mbegin mend
	while read -r line; do
		(( linenum++ ))
		[[ $line =~ '^\s*#.*' ]] && continue
		#line=(${(Az)line})
		if [[ $line =~ '^alias\s+' ]]; then
			for word (${(Az)line}); do
				[[ $word = 'alias' ]] && continue
				if ! [[ $word =~ '^[A-Za-z_][A-Za-z0-9_-]*=' ]]; then
					+dotenv-debug "N=$ZSH_DOTENV_FILE" "i=$linenum" "I=$dotenv_num" -- "Invalid alias: $word" >&2
					continue
				fi
				name=${word%%=*}
				if value=$(eval "alias $word" && alias -L -- "$name"); then
					old=$(alias -L -- "$name")
					if [[ $old ]]; then
						backward+=($old)
					else
						backward+=("unalias $name")
					fi
					+dotenv-debug "N=$ZSH_DOTENV_FILE" "i=$linenum" "I=$dotenv_num" -- "$value"
					eval "$value"
				else
					+dotenv-debug "N=$ZSH_DOTENV_FILE" "i=$linenum" "I=$dotenv_num" -- "Invalid line: $line" >&2
				fi
			done
		elif [[ $line =~ '^(export\s+)?([A-Za-z_][A-Za-z0-9_]*)=' ]]; then
			name=${match[2]}
			if value=$(eval "$line"; export "$name"; declare -p -- "$name") 2>/dev/null; then
				if [[ ${(P)name+x} ]]; then
					old=$(typeset -p -- "$name")
				else
					old="unset $name"
				fi
				backward+=("[[ \$(declare -p -- ${(q)name}) == ${(qq)value} ]] && { unset ${(q)name}; $old; }")
				+dotenv-debug "N=$ZSH_DOTENV_FILE" "i=$linenum" "I=$dotenv_num" -- "$value"
				eval "$value"
			else
				+dotenv-debug "N=$ZSH_DOTENV_FILE" "i=$linenum" "I=$dotenv_num" -- "Invalid line: $line" >&2
			fi
		else
			+dotenv-debug "N=$ZSH_DOTENV_FILE" "i=$linenum" "I=$dotenv_num" -- "Invalid line: $line" >&2
		fi
	done < "$dotenv"

	+dotenv-stack-push "$dotenv" "${(F)${(@Oa)backward}}"
}

+dotenv-deactivate() {
	local oldwd=$_ZSH_DOTENV_STACK_TOP_WD dotenv backward
	if +dotenv-stack-pop; then
		source <(echo "$backward")
		_ZSH_DOTENV_HEAD=${oldwd:h}

		if ! [[ $ZSH_DOTENV_QUIET ]]; then
			local dotenv_num=$((${#_ZSH_DOTENV_STACK} + 1)) linenum=0
			for line (${(f)backward}); do
				+dotenv-debug "I=$dotenv_num" "N=-" "i=$linenum" -- "$line"
				(( linenum++ ))
			done
		fi
	fi
}

# interface

dotenv-unload() {
	local cwd=${PWD:A} dotwd=$_ZSH_DOTENV_STACK_TOP_WD
	if [[ $dotwd ]]; then
		+dotenv-deactivate
		if [[ $cwd/ == $dotwd/* ]]; then
			_ZSH_DOTENV_DEACTIVE+=("$dotwd")
		fi
	fi
}

dotenv-load() {
	local cwd="${PWD:A}" dotenv dotwd _dotenv_prefix

	local automatic=
	local arg OPTIND=1 OPTARG
	while getopts 'a' arg; do
		case $arg in
			a) automatic=yes ;;
		esac
	done

	if [[ $_ZSH_DOTENV_HEAD ]]; then
		while [[ $_ZSH_DOTENV_STACK_TOP_WD && $_ZSH_DOTENV_STACK_TOP_WD/ != $cwd/ && $_ZSH_DOTENV_STACK_TOP_WD/ == $cwd/* ]]; do
			+dotenv-deactivate
		done
		if [[ $automatic == yes && $_ZSH_DOTENV_HEAD/ == $cwd/* ]]; then
			# triggered when "cd .."
			# NOTE: don't clean _ZSH_DOTENV_DEACTIVE
			# echo "-- early exit cos: $_ZSH_DOTENV_HEAD/ == $cwd/*"
			return 0
		else
			+dotenv-common-prefix "$_ZSH_DOTENV_HEAD" "$cwd"
			dotwd=$_dotenv_prefix
		fi
	elif [[ $cwd/ == $HOME/* ]]; then
		dotwd=$HOME
	fi

	# echo "-- cwd  : $cwd"
	# echo "-- head : $_ZSH_DOTENV_HEAD"
	# echo "-- top s: $_ZSH_DOTENV_STACK_TOP_WD"
	# echo "-- dotwd: $dotwd"

	local tocheck=("${(@s:/:)${${cwd#$dotwd}%%/}}")
	if [[ $tocheck || $automatic != yes ]]; then
		for dir ("${(@)tocheck}"); do
			[[ $dir ]] && dotwd="$dotwd/$dir"
			[[ $_ZSH_DOTENV_STACK_TOP_WD && $_ZSH_DOTENV_STACK_TOP_WD == $dotwd ]] && continue
			dotenv="$dotwd/$ZSH_DOTENV_FILE"
			# echo " -- test: $dotenv"
			if [[ -f "$dotenv" ]]; then
				[[ $automatic == yes && ${_ZSH_DOTENV_DEACTIVE[(ie)$dotwdv]} -le ${#_ZSH_DOTENV_DEACTIVE} ]] && break # disabled
				+dotenv-activate "$dotwd" "$dotenv"
			fi
		done
	fi
	_ZSH_DOTENV_HEAD=$dotwd
}


+dotenv-cwd-hook() { dotenv-load -a; }
add-zsh-hook chpwd +dotenv-cwd-hook

# chpwd hook is not triggered when terminal is spawned (or this file is loaded)
+dotenv-init-precmd() {
	+dotenv-cwd-hook
	add-zsh-hook -d precmd +dotenv-init-precmd
}
add-zsh-hook precmd +dotenv-init-precmd


+dotenv-promp-precmd() {
	if [[ $_ZSH_DOTENV_STACK ]]; then
		RPS1="%F{3}▼${${#_ZSH_DOTENV_STACK}:#1}%k%f $RPS1"
	fi
}
add-zsh-hook precmd +dotenv-promp-precmd


#  vim: set ts=4 sw=4 tw=0 noet syn=zsh ft=zsh :
