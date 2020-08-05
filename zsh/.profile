# ~/.profile
#umask 022

export DEBEMAIL=jaakko@n-1.fi
export LIBVIRT_DEFAULT_URI="qemu:///system"

if which vim >/dev/null; then
	export EDITOR=vim
	export VISUAL=vim
fi

# add private bin filders
for d in "bin" ".bin" ".local/bin"; do
	[ -d "$HOME/$d" ] && PATH="$HOME/$d:$PATH"
done
unset d

[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"
# vim: set ts=4 sw=4 tw=0 noet syntax=zsh filetype=zsh :
