#!/bin/sh

url=$1
def_name=${url##*/}
def_name=${def_name%.git}
plugin_name=${2:-$def_name}

if [ -z "$url" -o -z "$plugin_name" ]; then
	echo "usage: $0 <url> [name]" >&2
	exit 64
fi

plugin="_git/$plugin_name"

if ! [ -e "$plugin" ]; then
	git submodule add --depth 1 "$url" "$plugin"
fi

for dir in \
	autoload \
	colors \
	compiler \
	doc \
	ftdetect \
	ftplugin \
	indent \
	macros \
	plugin \
	syntax \
; do
	if [ -e "$plugin/$dir/" ]; then
		find "$plugin/$dir/" -type f | while read file; do
			path="${file#$plugin/}"
			path_dir="${path%/*}"
			path_rev=$(echo $path_dir | sed 's,[^/]\+,..,g')
			if ! [ -e "$path" ]; then
				mkdir -p "$path_dir"
				ln -vsT "$path_rev/$file" "$path"
			fi
		done
	fi
done
