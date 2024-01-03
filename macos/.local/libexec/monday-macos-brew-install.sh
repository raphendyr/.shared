#!/bin/sh

# export SUDO_ASKPASS=/usr/bin/false
shared_dir=$(
	f=$(command -v setup-macos.sh) \
	&& cd "${f%/*}" \
	&& f=$(readlink "$f") \
	&& cd "${f%/*}/../.." \
	&& echo "$PWD" \
	|| exit 1
)

export HOMEBREW_NO_AUTO_UPDATE=1

brew_upgrade() {
	brew update \
	&& brew bundle --file "$shared_dir/Brewfile" install \
	&& brew upgrade --greedy
}

mas_upgrade() {
	if ! command -v mas > /dev/null; then
		echo "No 'mas' found. Skipping App Store updates."
		return
	fi
	if [ "$(mas outdated)" ]; then
		mas upgrade
	fi
}

set -x
if brew_upgrade && mas_upgrade; then
	echo "All done!"
else
	echo "Something failed! Please fix."
fi
echo "  Press enter to exit.."
read -r reply
