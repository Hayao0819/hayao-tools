#!/usr/bin/env bash

set -eEuo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT ERR INT TERM

script_path="$(dirname "$(realpath "$0")")"
cd "$script_path" || exit 1

source_codes=("$script_path/"*.c)
data_file="./data/under100M.dat"

run() {
    local _basename _args
    _basename=$(basename "$1")
    _args=("${@:2}")
    echo "$ $_basename ${_args[*]} > /dev/null" >&2
    "$@" >/dev/null
}

compile() {
    local source_code="$1"
    local binfile
    binfile="$tmpdir/$(basename "$source_code" .c)"
    gcc -Wall -O2 -o "$binfile" "$source_code"
    echo "$binfile"
}

head -n 50000 "$data_file" >"${tmpdir}/data_for_bubble.dat"

main() {

    local _data="$data_file"
    for source_code in "${source_codes[@]}"; do
        binfile=$(compile "$source_code")

        # データファイルがbubble.cの場合は、データファイルを変更する
        _data="$data_file"
        if [[ $(basename "$source_code") == "bubble.c" ]]; then
            _data="${tmpdir}/data_for_bubble.dat"
        fi
        data_lines=$(wc -l <"$_data")

        local _line
        for _line in 1000 5000 10000 20000 50000 100000 500000 1000000; do
            if [[ $_line -gt $data_lines ]]; then
                continue
            fi
            run $binfile "$_data" $_line 100000000
        done
    done
}

main
