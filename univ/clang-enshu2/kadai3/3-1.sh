#!/usr/bin/env bash

set -eEuo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT ERR INT TERM

script_path="$(dirname "$(realpath "$0")")"
cd "$script_path" || exit 1

source_code="$script_path/bucketsort.c"
binfile="$tmpdir/bucketsort"
data_dir="./data"

get_max_value() {
    local data="$1"
    case $(basename "$data") in
    "bubble-data"*)
        echo 100
        ;;
    "under10K"*)
        echo 10000
        ;;
    "under100K"*)
        echo 100000
        ;;
    "under1M"*)
        echo 1000000
        ;;
    "under10M"*)
        echo 10000000
        ;;
    "under100M"*)
        echo 100000000
        ;;
    "under1G"*)
        echo 1000000000
        ;;
    *)
        echo "Invalid data file"
        exit 1
        ;;
    esac
}

run() {
    local _basename _args
    _basename=$(basename "$1")
    _args=("${@:2}")
    echo "$ $_basename ${_args[*]} > /dev/null" >&2
    "$@" >/dev/null
}

gcc -Wall -O2 -o "$binfile" "$source_code"

run $binfile $data_dir/under10K.dat 250000 10000
run $binfile $data_dir/under10K.dat 500000 10000

for data in "10K" "100K" "1M" "10M" "100M" "1G"; do
    data_file="$data_dir/under$data.dat"

    data_lines=$(wc -l <"$data_file")
    max_value=$(get_max_value "$(basename "$data_file")")

    run $binfile $data_file "$data_lines" "$max_value"
done
