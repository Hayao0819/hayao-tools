#!/usr/bin/env bash

# if [ "$#" -ne 3 ]; then
if (($# != 2)); then
    echo "Usage: $0 <file1.csv> <file2.csv>"
    exit 1
fi

file1="$1" file2="$2"

if [ ! -f "$file1" ] || [ ! -f "$file2" ]; then
    echo "Error: Both files must exist."
    exit 1
fi

join -t, -1 1 -2 1 -a 1 -e "NULL" -o auto <(sort -t, -k1,1 "$file1") <(sort -t, -k1,1 "$file2")
