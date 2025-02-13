#!/usr/bin/env bash
array=(5 3 1 2 6 0.3 0.2 20 46 12 250)
for i in "${array[@]}"; do
    (
        sleep "$(bc <<<"scale=3; $i / 100")"
        echo "$i"
    ) &
done
wait
