function +my-downloadable-msg() {
	local ps=$PS4
	[[ $ps == *%x* ]] && ps=${ps//\%x/[my-downloadable]} || ps=${ps/+/+[my-downloadable]}
	printf "%s %s\n" "${(%)ps}" "$1"
}

function +my-downloadable-download() {
	local url="$1"
	local fn="${2:-${url##*/}}"
	+my-downloadable-msg "downloading $url"
	curl -LfsS -o "$fn" "$url"
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
	local code=0 os="" arch="" version="" github_download="" tmp=""
	case "$OSTYPE" in
		darwin*) os="darwin" ;;
		linux*) os="linux" ;;
		*) +my-downloadable-msg "Unknown OS '$OSTYPE'." ; return 1 ;;
	esac
	case "$(uname -m)" in
		x86_64) arch='amd64' ;;
		*) +my-downloadable-msg "Unknown CPU architecture '$(uname -m)'." ; return 1 ;;
	esac
	version="${2:-}"
	if [[ -z $version ]]; then version='latest'; fi
	if [[ ${version#v} == "$version" && $version != 'latest' ]]; then version="v$version"; fi
	if [[ $version = 'latest' ]]
		then github_download='latest/download'
		else github_download="download/$version"
	fi

	case "$1" in
		'')
			echo "usage: $0 <binary> [version]" >&2
			return 64
			;;
		argocd)
			tmp=$(mktemp -d /tmp/download-argocd.XXXXX) && (
				cd "$tmp" \
				&& +my-downloadable-download "https://github.com/argoproj/argo-cd/releases/$github_download/argocd-${os}-${arch}" \
				&& +my-downloadable-download "https://github.com/argoproj/argo-cd/releases/$github_download/cli_checksums.txt" \
				&& +my-downloadable-verify "argocd-${os}-${arch}" 'cli_checksums.txt' \
				&& mv "argocd-${os}-${arch}" 'argocd' \
				&& +my-downloadable-install 'argocd' \
			) || code=1
			if [ "$tmp" -a -d "$tmp" ]; then rm -r "$tmp"; fi
			return $code
			;;
		drone)
			tmp=$(mktemp -d /tmp/download-drone.XXXXX) && (
				cd "$tmp" \
				&& +my-downloadable-download "https://github.com/harness/drone-cli/releases/$github_download/drone_${os}_${arch}.tar.gz" \
				&& +my-downloadable-download "https://github.com/harness/drone-cli/releases/$github_download/drone_checksums.txt" \
				&& +my-downloadable-verify "drone_${os}_${arch}.tar.gz" 'drone_checksums.txt' \
				&& tar -zxf "drone_${os}_${arch}.tar.gz" 'drone' \
				&& +my-downloadable-install 'drone' \
			) || code=1
			if [ "$tmp" -a -d "$tmp" ]; then rm -r "$tmp"; fi
			return $code
			;;
		dyff)
			if [[ $version = 'latest' ]]; then
				version=$(curl -LfsS 'https://api.github.com/repos/homeport/dyff/releases/latest' \
					| jq -r '.tag_name')
			fi
			tmp=$(mktemp -d /tmp/download-dyff.XXXXX) && (
				cd "$tmp" \
				&& +my-downloadable-download "https://github.com/homeport/dyff/releases/download/$version/dyff_${version#v}_${os}_${arch}.tar.gz" \
				&& +my-downloadable-download "https://github.com/homeport/dyff/releases/download/$version/checksums.txt" \
				&& +my-downloadable-verify "dyff_${version#v}_${os}_${arch}.tar.gz" 'checksums.txt' \
				&& tar -zxf "dyff_${version#v}_${os}_${arch}.tar.gz" 'dyff' \
				&& +my-downloadable-install 'dyff' \
			) || code=1
			if [ "$tmp" -a -d "$tmp" ]; then rm -r "$tmp"; fi
			return $code
			;;
		kubectl)
			if [[ $version = 'latest' ]]; then
				version=$(curl -LfsS https://dl.k8s.io/release/stable.txt)
			fi
			tmp=$(mktemp -d /tmp/download-kubectl.XXXXX) && (
				cd "$tmp" \
				&& +my-downloadable-download "https://dl.k8s.io/release/$version/bin/$os/${arch}/kubectl" \
				&& +my-downloadable-download "https://dl.k8s.io/release/$version/bin/$os/${arch}/kubectl.sha256" \
				&& +my-downloadable-verify-simple "kubectl" "kubectl.sha256" \
				&& +my-downloadable-install 'kubectl' \
			) || code=1
			if [ "$tmp" -a -d "$tmp" ]; then rm -r "$tmp"; fi
			return $code
			;;
		minikube)
			tmp=$(mktemp -d /tmp/download-minikube.XXXXX) && (
				cd "$tmp" \
				&& +my-downloadable-download "https://storage.googleapis.com/minikube/releases/latest/minikube-${os}-${arch}" \
				&& +my-downloadable-download "https://storage.googleapis.com/minikube/releases/latest/minikube-${os}-${arch}.sha256" \
				&& +my-downloadable-verify-simple "minikube-${os}-${arch}" "minikube-${os}-${arch}.sha256" \
				&& mv "minikube-${os}-${arch}" 'minikube' \
				&& +my-downloadable-install 'minikube' \
			) || code=1
			if [ "$tmp" -a -d "$tmp" ]; then rm -r "$tmp"; fi
			return $code
			;;
		terraform)
			# TODO: dynamic version
			local version="1.0.0"
			# TODO: verify sig https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_SHA256SUMS.sig
			tmp=$(mktemp -d /tmp/download-terraform.XXXXX) && (
				cd "$tmp" \
				&& +my-downloadable-download "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os}_${arch}.zip" \
				&& +my-downloadable-download "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_SHA256SUMS" \
				&& +my-downloadable-verify "terraform_${version}_${os}_${arch}.zip" "terraform_${version}_SHA256SUMS" \
				&& unzip "terraform_${version}_${os}_${arch}.zip" 'terraform' \
				&& +my-downloadable-install 'terraform' \
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
	argocd \
	drone \
	dyff \
	kubectl \
	minikube \
	terraform \
; do
	if ! command -v "$_binary" >/dev/null; then
		function "$_binary"() {
			if +my-downloadable "$0"; then
				unset -f "$0"
				rehash
				+my-downloadable-msg "command '$0' ready, executing..." \
				"$0" "$@"
			else
				return $?
			fi
		}
	fi
done
unset _binary
