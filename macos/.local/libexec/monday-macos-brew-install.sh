#!/bin/sh
set -eu

export SUDO_ASKPASS=/usr/bin/false
shared_dir=$(cd ~/.local/bin; f=$(readlink "setup-macos.sh"); cd "${f%/*}/../.."; echo "$PWD")

export HOMEBREW_NO_AUTO_UPDATE=1

if brew update \
	&& brew bundle --file "$shared_dir/Brewfile" install \
	&& brew upgrade --greedy \
; then
	echo "All done!"
else
	echo "Something failed! Please fix."
fi
echo "  Press enter to exit.."
read -r reply
