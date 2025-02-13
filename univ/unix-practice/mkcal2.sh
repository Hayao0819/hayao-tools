#!/bin/sh
set -eu
help_text="Usage: ./mkcal2.sh [startyear] [endyear] [step]"
n="${1-""}" end=${2-""}

# shellcheck disable=SC2120
_usage(){
    printf "%s\n" "${@}" >&2 && exit 1
}

# $# <= 1
[ $# -le 1 ] && _usage "$help_text"

#$n < $end
[ "$n" -ge "$end" ] && _usage "$help_text" "Endyear should be greater than startyear."

while [ "$n" -le "$end" ]; do
    echo "Make cal-${n}.txt" >&2
    if [ -e "cal-${n}.txt" ]; then
        echo "File exists: cal-$n.txt" >&2
    else
        cal "$n" > "cal-${n}.txt"
    fi
    n=$(( n+${3-1} ))
done
