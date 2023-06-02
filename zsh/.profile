# ~/.profile
#umask 022

export AWS_SESSION_TOKEN_TTL=2h
export AWS_ASSUME_ROLE_TTL=2h
export AWS_MIN_TTL=15m
export DEBFULLNAME="Jaakko Kantojärvi"
export DEBEMAIL=jaakko@n-1.fi
export LIBVIRT_DEFAULT_URI="qemu:///system"

if command -v vim >/dev/null; then
	export EDITOR=vim
	export VISUAL=vim
fi


## set PATH

add_path() {
	[ -d "$1" ] || return
	set -- "$(cd "$1"; pwd -P)" "$2"
	case ":$PATH:" in *":$1:"*) return ;; esac
	[ "$2" = "append" ] && PATH="$PATH:$1" || PATH="$1:$PATH"
}

# add private binary paths
add_path "$HOME/bin"
add_path "$HOME/.bin"
add_path "$HOME/.local/bin"

# add Homebrew paths
add_path "$HOME/.local/lib/Homebrew/bin"
add_path "$HOME/.local/lib/Homebrew/opt/openssl@3/bin" prepend
add_path "$HOME/.local/lib/Homebrew/opt/python/bin"
add_path "$HOME/.local/lib/Homebrew/opt/ruby/bin"

# add software specific paths
add_path "$HOME/go/bin"

if command -v ruby > /dev/null; then
	ruby_ver="$(ruby --version | cut -d' ' -f2 | cut -d. -f1-2).0"
	for d in ".gem/ruby" ".local/lib/Homebrew/lib/ruby/gems"; do
		add_path "$HOME/$d/$ruby_ver/bin" append
	done
	unset d ruby_ver
fi

if command -v python3 > /dev/null; then
	python_ver="$(python3 --version | cut -d' ' -f2 | cut -d. -f1-2)"
	for d in "Library/Python"; do
		add_path "$HOME/$d/$python_ver/bin" append
	done
	unset d python_ver
fi


unset -f add_path

[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"
# vim: set ts=4 sw=4 tw=0 noet syntax=zsh filetype=zsh :
