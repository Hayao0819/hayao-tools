#!/usr/bin/env sh
for f in "$@"; do
    echo "Copying $f to $f.bak" >&2
    cp "${f}" "${f}.bak"
done
