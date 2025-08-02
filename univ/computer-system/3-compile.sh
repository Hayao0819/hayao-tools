#!/bin/sh

set -e -u

cd "$(dirname "$0")" || exit 1
source_file="$1"
out_dir="$(dirname "$source_file")"
basename_file="$(basename "$source_file" | sed 's/\.[^.]*$//')"

mkdir -p "$out_dir"
for optimize in 0 1 2 3; do
    out_file="$out_dir/${basename_file}-o${optimize}.s"
    gcc -S -O"$optimize" "$source_file" -o "$out_file"
done
