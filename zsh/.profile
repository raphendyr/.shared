# ~/.profile
#umask 022

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

# add Homebrew paths
for d in "bin" "opt/ruby/bin" "opt/python/bin"; do
	add_path "$HOME/.local/lib/Homebrew/$d"
done

# add private binary paths
for d in "bin" ".bin" ".local/bin"; do
	add_path "$HOME/$d"
done

# add software specific paths
if command -v ruby > /dev/null; then
	ruby_ver="$(ruby --version | cut -d' ' -f2 | cut -d. -f1-2).0"
	for d in ".gem/ruby" ".local/lib/Homebrew/lib/ruby/gems"; do
		add_path "$HOME/$d/$ruby_ver/bin" append
	done
	unset ruby_ver
fi

if command -v python3 > /dev/null; then
	python_ver="$(python3 --version | cut -d' ' -f2 | cut -d. -f1-2)"
	for d in "Library/Python"; do
		add_path "$HOME/$d/$python_ver/bin" append
	done
	unset python_ver
fi

unset d
unset -f add_path

[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"
# vim: set ts=4 sw=4 tw=0 noet syntax=zsh filetype=zsh :
