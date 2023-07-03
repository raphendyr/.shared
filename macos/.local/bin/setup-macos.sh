#!/bin/sh
set -eux

# keyboard
defaults write -g InitialKeyRepeat -int 15 # ms, UI min 15ms and max 225ms
defaults write -g KeyRepeat -int 2 # *15ms, UI min is 2 (30ms)

# mouse
defaults write -g com.apple.scrollwheel.scaling "-1" # disable mouse wheel scrolling

defaults write -g AppleAccentColor -int 1
defaults write -g AppleAntiAliasingThreshold -int 4
defaults write -g AppleAquaColorVariant -int 1
defaults write -g AppleEnableSwipeNavigateWithScrolls -bool NO
defaults write -g AppleHighlightColor "1.000000 0.874510 0.701961 Orange"
defaults write -g AppleInterfaceStyle "Dark"
defaults write -g AppleLanguages -array "en-FI" "fi-FI"
defaults write -g AppleLocale "en_FI"
defaults write -g AppleMeasurementUnits "Centimeters"
defaults write -g AppleMenuBarFontSize "large"
defaults write -g AppleMetricUnits -bool YES
defaults write -g AppleMiniaturizeOnDoubleClick -bool NO
defaults write -g AppleShowAllExtensions -bool YES
defaults write -g AppleShowScrollBars "Always"
defaults write -g AppleSpacesSwitchOnActivate -bool NO
defaults write -g AppleTemperatureUnit "Celsius"

# window
defaults write -g NSWindowSupportsAutomaticInlineTitle -bool false

## Homebrew, binaries and apps

if ! which brew > /dev/null; then
    homebrew_path="$HOME/.local/lib/Homebrew"
    if ! [ -d "$homebrew_path" ]; then
        # shellcheck disable=SC2015
        mkdir -p "${homebrew_path%/*}" \
            && cd "${homebrew_path%/*}" \
            || { echo "Failed to create path ${homebrew_path%/*}" >&2; exit 1; }
        git clone https://github.com/Homebrew/brew.git "${homebrew_path##*/}"
    fi
    PATH="$homebrew_path/bin:$PATH"
    rehash
    brew analytics off  # disable analytics
    echo "Remeber to reload ~/.profile !"
fi

shared_dir=$(cd ~/.local/bin; f=$(readlink "setup-macos.sh"); cd "${f%/*}/../.."; echo "$PWD")

brew bundle --file "$shared_dir/Brewfile" install

xattr -dr com.apple.quarantine /Applications/Easy\ Move+Resize.app

echo "Setting few system wide launch options, this requires sudo..."
sudo defaults write /Library/LaunchAgents/net.pulsesecure.pulsetray.plist Disabled 1 || true
sudo defaults write /Library/LaunchAgents/com.fortinet.forticlient.fct_launcher.plist RunAtLoad 0 || true
sudo defaults write /Library/LaunchAgents/com.fortinet.forticlient.credential_store.plist RunAtLoad 0 || true
