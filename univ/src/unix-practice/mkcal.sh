#!/bin/sh
set -eu
n="${1-""}" end=${2-""}
while [ "$n" -le "$end" ]; do
    echo "Make cal-${n}.txt" >&2
    if [ -e "cal-${n}.txt" ]; then
        echo "File exists: cal-$n.txt"
    else
        cal "$n" > "cal-${n}.txt"
    fi
    n=$(( n+1 ))
done
