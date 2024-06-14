#!/usr/bin/env sh
bakdir=""
printf "%s" "Enter directory name for backup:"
read -r bakdir
[ -n "${bakdir-""}" ] || exit 1

mkdir -p "$bakdir"
for f in "$@"; do
    echo "Copying $f to $bakdir/$f.bak" >&2
    cp "${f}" "$bakdir/${f}.bak"
done
