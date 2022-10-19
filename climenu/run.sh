#!/usr/bin/env bash

current_path="$(dirname "$(readlink -f "$0")")"
executable_path="${current_path}/climenu"

remove_file=false
if [[ "$1" = "-d" ]]; then
    remove_file=true
    shift
fi

gcc -lncurses -o "${executable_path}" "${current_path}/main.c" 
chmod +x "${executable_path}"

[[ "$remove_file" = true ]] && trap 'rm -f "${executable_path}"' EXIT INT TERM HUP

"${executable_path}" "$@" 
