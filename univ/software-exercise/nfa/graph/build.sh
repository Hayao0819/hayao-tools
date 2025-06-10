#!/bin/sh
set -eu
cd "$(dirname "$0")" || exit 1
for f in *.dot; do
    echo "Generating image for $f"
    dot -Tpng "$f" -o "${f%.dot}.png"
done
