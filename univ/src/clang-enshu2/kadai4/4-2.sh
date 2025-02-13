#!/usr/bin/env bash

set -eEuo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT ERR INT TERM

script_path="$(dirname "$(realpath "$0")")"
cd "$script_path" || exit 1

source_codes=("$script_path/select.c" "$script_path/lselect.c")

declare -A bin_files
data_dir="./data"

make_binary() {
    for source_code in "${source_codes[@]}"; do
        bin_files["$source_code"]="$tmpdir/$(basename "$source_code" .c)"
        gcc -Wall -O2 -o "${bin_files["$source_code"]}" "$source_code"
    done
}


run() {
    local _basename _args
    _basename=$(basename "$1")
    _args=("${@:2}")
    echo "$ $_basename ${_args[*]}" >&2
    "$@"
}


compare_time(){
    local data_file="$data_dir/for-select.dat"
    for source_code in "${source_codes[@]}"; do
        run "${bin_files["$source_code"]}" "$data_file" 20000000 10000
    done
    wait
}

main() {
    make_binary
    compare_time
}

main
