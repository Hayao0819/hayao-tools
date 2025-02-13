#!/usr/bin/env sh
bakdir=""
_ask(){
    printf "%s" "Enter directory name for backup: " >&2
    read -r bakdir
    [ -n "${bakdir-""}" ] || _ask
}

_ask
while [ -d "$bakdir" ] || [ -z "$bakdir" ]; do
    printf "Backup directory exists. " >&2
    _ask
done

mkdir -p "$bakdir"
for f in "$@"; do
    echo "Copying $f to $bakdir/$f.bak" >&2
    cp "${f}" "$bakdir/${f}.bak"
done
