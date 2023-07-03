#!/bin/sh
# shellcheck disable=SC1090
. ~/.profile

set -eu

shared_dir=$(cd ~/.local/bin; f=$(readlink "setup-macos.sh"); cd "${f%/*}/../.."; echo "$PWD")
git_root=$(cd "$shared_dir/.."; echo "$PWD")

export HOMEBREW_NO_AUTO_UPDATE=1

brew bundle --file "$shared_dir/Brewfile" --force dump

open -a Terminal "$HOME/.local/libexec/monday-macos-brew-install.sh"

num_changes=$(cd "$git_root"; git status --untracked-files=no --porcelain | wc -l)
num_changes=${num_changes##* }

terminal-notifier \
    -group 'fi.n-1.monday' \
    -title '💤☕😴' \
    -subtitle "Weekly Monday tasks done." \
    -message "Dirty: $num_changes pending changes | $(date '+%-l:%M%p %d.%m.')"
