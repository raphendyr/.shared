function +my-downloadable-msg() {
	local ps=$PS4
	[[ $ps == *%x* ]] && ps=${ps//\%x/[my-downloadable]} || ps=${ps/+/+[my-downloadable]}
	printf "%s %s\n" "${(%)ps}" "$1"
}

function +my-downloadable-download() {
	local url="$1"
	local fn="${2:-${url##*/}}"
	+my-downloadable-msg "downloading $url"
	curl -LsS -o "$fn" "$url"
}

function +my-downloadable-verify() {
	local fn="$1" sums="$2"
	awk '$2 ~ /'"$fn"'/ {print $1 " " "'"$fn"'"}' "$sums" | sha256sum -c -
}

function +my-downloadable-verify-simple() {
	local fn="$1" sum="$2"
	echo "$(head -n1 "$sum") $fn" | sha256sum -c -
}

function +my-downloadable-install() {
	local fn="$1"
	mv "$fn" "$HOME/.local/bin/$fn"
	chmod +x "$HOME/.local/bin/$fn"
}

function +my-downloadable() {
	local code=0 os="" tmp=""
	case "$1" in
		'')
			echo "usage: $0 <binary>" >&2
			return 64
			;;
		drone)
			case "$OSTYPE" in
				darwin*) os="darwin" ;;
				linux*) os="linux" ;;
				*) +my-downloadable-msg "Unknown OS '$OSTYPE' for drone." ; return 1 ;;
			esac
			tmp=$(mktemp -d /tmp/download-drone.XXXXX) && (
				cd "$tmp" \
				&& +my-downloadable-download "https://github.com/drone/drone-cli/releases/latest/download/drone_${os}_amd64.tar.gz" \
				&& +my-downloadable-download 'https://github.com/drone/drone-cli/releases/latest/download/drone_checksums.txt' \
				&& +my-downloadable-verify "drone_${os}_amd64.tar.gz" 'drone_checksums.txt' \
				&& tar -zxf "drone_${os}_amd64.tar.gz" 'drone' \
				&& +my-downloadable-install 'drone' \
				&& +my-downloadable-msg "command 'drone' ready, executing..." \
			) || code=1
			if [ "$tmp" -a -d "$tmp" ]; then rm -r "$tmp"; fi
			return $code
			;;
		dyff)
			case "$OSTYPE" in
				darwin*) os="darwin" ;;
				linux*) os="linux" ;;
				*) +my-downloadable-msg "Unknown OS '$OSTYPE' for dyff." ; return 1 ;;
			esac
			tmp=$(mktemp -d /tmp/download-dyff.XXXXX) && (
				cd "$tmp" \
				&& +my-downloadable-download "https://github.com/homeport/dyff/releases/latest/download/dyff_1.4.0_${os}_amd64.tar.gz" \
				&& +my-downloadable-download 'https://github.com/homeport/dyff/releases/latest/download/checksums.txt' \
				&& +my-downloadable-verify "dyff_1.4.0_${os}_amd64.tar.gz" 'checksums.txt' \
				&& tar -zxf "dyff_1.4.0_${os}_amd64.tar.gz" 'dyff' \
				&& +my-downloadable-install 'dyff' \
				&& +my-downloadable-msg "command 'dyff' ready, executing..." \
			) || code=1
			if [ "$tmp" -a -d "$tmp" ]; then rm -r "$tmp"; fi
			return $code
			;;
		kubectl)
			case "$OSTYPE" in
				darwin*) os="darwin" ;;
				linux*) os="linux" ;;
				*) +my-downloadable-msg "Unknown OS '$OSTYPE' for minikube." ; return 1 ;;
			esac
			local version="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
			tmp=$(mktemp -d /tmp/download-kubectl.XXXXX) && (
				cd "$tmp" \
				&& +my-downloadable-download "https://dl.k8s.io/release/$version/bin/$os/amd64/kubectl" \
				&& +my-downloadable-download "https://dl.k8s.io/release/$version/bin/$os/amd64/kubectl.sha256" \
				&& +my-downloadable-verify-simple "kubectl" "kubectl.sha256" \
				&& +my-downloadable-install 'kubectl' \
				&& +my-downloadable-msg "command 'kubectl' ready, executing..." \
			) || code=1
			if [ "$tmp" -a -d "$tmp" ]; then rm -r "$tmp"; fi
			return $code
			;;
		minikube)
			case "$OSTYPE" in
				darwin*) os="darwin" ;;
				linux*) os="linux" ;;
				*) +my-downloadable-msg "Unknown OS '$OSTYPE' for minikube." ; return 1 ;;
			esac
			tmp=$(mktemp -d /tmp/download-minikube.XXXXX) && (
				cd "$tmp" \
				&& +my-downloadable-download "https://storage.googleapis.com/minikube/releases/latest/minikube-${os}-amd64" \
				&& +my-downloadable-download "https://storage.googleapis.com/minikube/releases/latest/minikube-${os}-amd64.sha256" \
				&& +my-downloadable-verify-simple "minikube-${os}-amd64" "minikube-${os}-amd64.sha256" \
				&& mv "minikube-${os}-amd64" 'minikube' \
				&& +my-downloadable-install 'minikube' \
				&& +my-downloadable-msg "command 'minikube' ready, executing..." \
			) || code=1
			if [ "$tmp" -a -d "$tmp" ]; then rm -r "$tmp"; fi
			return $code
			;;
		*)
			echo "Uknown binary '$1'" >&2
			return 64
			;;
	esac
}

for _binary in \
	drone \
	dyff \
	kubectl \
	minikube \
; do
	if ! command -v "$_binary" >/dev/null; then
		function "$_binary"() {
			if +my-downloadable "$0"; then
				unset -f "$0"
				rehash
				"$0" "$@"
			else
				return $?
			fi
		}
	fi
done
unset _binary
