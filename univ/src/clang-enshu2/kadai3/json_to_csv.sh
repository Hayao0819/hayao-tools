#!/usr/bin/env bash

set -eEuo pipefail

# script_path="$(dirname "$(realpath "$0")")"
json_dir="${1-""}"

# Ignore bubble.c
readarray -t c_files < <(printf '%s\n' "${c_files[@]}" | grep -v 'bubble.c')

command_exist() {
    if ! type "$1" 2>/dev/null 1>/dev/null; then
        echo "$1 is not installed"
        exit 1
    fi
}

check_env() {
    command_exist gcc
    command_exist hyperfine
}

main() {
    local json_name json_name_noext
    if [[ -z "$json_dir" || ! -e "$json_dir" ]]; then
        echo "Usage: json_to_csv.sh <dir>" >&2
        return 1
    fi

    local _commands=() _methods=()
    local _csv_avgs

    readarray -t _csv_avgs < <(
        for json in "$json_dir/"*".json"; do
            json_name="$(basename "$json")"
            json_name_noext="${json_name%.*}"
            readarray -t _commands < <(jq -r ".results[].command" <"$json")
            readarray -t _methods < <(printf "%s\n" "${_commands[@]}" | cut -d " " -f 1 | xargs -I{} basename {} | sort)
            local _m=""
            for _m in "${_methods[@]}"; do
                local avg=0
                avg=$(jq -r ".results[] | select(.command == \"$(printf "%s\n" "${_commands[@]}" | grep "$_m")\") | .mean" <"$json")
                echo "$json_name_noext,$_m,$avg"
            done
        done
    )

    local _m
    for _m in "bucket" "quicksort" "heapsort" "merge"; do
        local _csv_avg
        printf "%s\n" "${_csv_avgs[@]}" | grep "$_m" | sort -rn
    done
}

main
