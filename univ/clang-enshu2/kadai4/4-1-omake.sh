#!/usr/bin/env bash

set -eEuo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT ERR INT TERM

script_path="$(dirname "$(realpath "$0")")"
cd "$script_path" || exit 1

source_codes=("$script_path/shellB.c" "$script_path/quicksort.c")

declare -A bin_files
data_dir="./data"
out_dir="$script_path/out/4-1"

make_binary() {
    for source_code in "${source_codes[@]}"; do
        bin_files["$source_code"]="$tmpdir/$(basename "$source_code" .c)"
        gcc -Wall -O2 -o "${bin_files["$source_code"]}" "$source_code"
    done
}

command_exist() {
    if ! type "$1" 2>/dev/null 1>/dev/null; then
        echo "$1 is not installed"
        exit 1
    fi
}

check_env() {
    command_exist gcc
    command_exist hyperfine
    command_exist jq
    command_exist bc
}

run() {
    local _basename _args
    _basename=$(basename "$1")
    _args=("${@:2}")
    echo "$ $_basename ${_args[*]} > /dev/null" >&2
    "$@" >/dev/null
}

run_benchmark() {
    local common_hyperfine_args=(
        --show-output
        -r 10
    )

    local data_file="$data_dir/under10M.dat" bench_lines=()
    for source_code in "${source_codes[@]}"; do
        # Run benchmark
        local report_file="$out_dir/${source_code##*/}.json"
        local hyperfine_args=(
            "${common_hyperfine_args[@]}"
            --export-json "$report_file"
        )
        readarray -t bench_lines < <(seq 100000 100000 1000000)
        for line in "${bench_lines[@]}"; do
            hyperfine_args+=(
                "${bin_files["$source_code"]} $data_file $line"
            )
        done
        run hyperfine "${hyperfine_args[@]}"

        # Parse report
        local report_csv=()
        readarray -t report_csv < <(jq -r '.results[] | [.command, .mean][]' "$report_file" | cut -d " " -f 3 | sed -e "N;s/\n/,/g")
        printf "%s\n" "${report_csv[@]}" >"$out_dir/${source_code##*/}.csv"
        printf "%s\n" "${report_csv[@]}" | ./show-graph-csv.sh "$out_dir/${source_code##*/}.png"
    done
}

joined_result() {
    local csv_files=()
    for source_code in "${source_codes[@]}"; do
        csv_files+=("$out_dir/${source_code##*/}.csv")
    done
    ./join-csv.sh "${csv_files[@]}" >"$out_dir/joined.csv"
}

main() {

    mkdir -p "$out_dir"

    check_env
    make_binary
    run_benchmark
    joined_result
}

main
