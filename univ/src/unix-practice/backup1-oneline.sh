#!/usr/bin/env sh

mkdir -p backup && printf "%s\n" "$@" | xargs -I{} bash -c "echo 'Copying {} to backup/{}.bak' && cp '{}' 'backup/{}.bak'"



#for f in "$@"; do
#    echo "Copying $f to backup/$f.bak" >&2
#    cp "${f}" "backup/${f}.bak"
#done
