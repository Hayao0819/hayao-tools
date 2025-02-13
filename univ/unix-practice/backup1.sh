#!/usr/bin/env sh
mkdir -p backup
for f in "$@"; do
    echo "Copying $f to backup/$f.bak" >&2
    cp "${f}" "backup/${f}.bak"
done
