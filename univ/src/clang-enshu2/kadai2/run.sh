#!/bin/sh
cd "$(dirname "$0")" || exit 1
gcc -o kadai2 graph.c
printf '%s\n' ./data/*.dat | sort -V | while read -r f; do
    printf "%s" "$(basename "$f" | sed "s/\.dat//")は"
    ./kadai2 "$f"
done
