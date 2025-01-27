#!/usr/bin/env bash

set -eEuo pipefail

script_path="$(dirname "$(realpath "$0")")"
c_files=("$script_path/"*.c)
data_files=("$script_path/data/"*.dat)
out_dir="$script_path/out"

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
    command_exist jq
    command_exist bc
}

prepare() {
    # Prepare temporary directory
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT ERR INT TERM

    # Prepare output directory
    mkdir -p "$out_dir"
}

build_cfile() {
    local cfile="$1"
    local cfile_name
    cfile_name="$(basename "$cfile")"
    local cfile_name_noext="${cfile_name%.*}"
    local binfile="$tmpdir/$cfile_name_noext"

    gcc -Wall -O2 -o "$binfile" "$cfile"
    echo "$binfile"
}

get_max_value() {
    local data="$1"
    case $(basename "$data") in
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

# run_benchmark_max_value [ソートするファイル(省略可)]
# ソートする値の最大値の違いで比較
run_benchmark_max_value() {
    local data_line=0
    local common_hyperfine_args=() hyperfine_args=()
    local target_data="${1-""}"
    local _data_files=("${data_files[@]}")
    local _max_value=0

    common_hyperfine_args=(
        --show-output
        -r 5
    )

    if [[ -n "${target_data-""}" ]]; then
        _data_files=("$target_data")
    fi

    for data in "${_data_files[@]}"; do
        hyperfine_args=(
            "${common_hyperfine_args[@]}"
            --export-json "$out_dir/$(basename "$data").json"
        )
        data_line=$(wc -l <"$data")
        _max_value=$(get_max_value "$data")
        for cfile in "${c_files[@]}"; do
            binfile=$(build_cfile "$cfile")
            hyperfine_args+=("$binfile $data $data_line  $_max_value > /dev/null")
        done
        hyperfine "${hyperfine_args[@]}"
    done
}

# run_benchmark_max_value [ソートするファイル]
run_benchmark_data_num() {
    local data_line=0
    local common_hyperfine_args=() hyperfine_args=()
    local target_data="${1-""}"
    local _data_files=()

    common_hyperfine_args=(
        --show-output
        -r 10
    )

    if [[ -z "${target_data-""}" ]]; then
        echo "Specity target data to be sorted" >&2
        exit 1
    fi

    local splited_data_dir="${tmpdir}/data"
    mkdir -p "$splited_data_dir"

    local target_data_lines
    target_data_lines=$(wc -l <"$target_data")

    local _max_value
    _max_value=$(get_max_value "$target_data")

    local _s _calced_lines
    while read -r _s; do
        _calced_lines=$(bc -l <<<"scale=0; $_s * $target_data_lines" | cut -d "." -f 1)
        head -n "$_calced_lines" "$target_data" >"$splited_data_dir/${_s}_split.dat"
        _data_files+=("$splited_data_dir/${_s}_split.dat")
        wc -l <"$splited_data_dir/${_s}_split.dat"
        echo "$_calced_lines"
    done < <(seq -f "%0.1f" 0.1 0.1 1)

    for data in "${_data_files[@]}"; do
        hyperfine_args=(
            "${common_hyperfine_args[@]}"
            --export-json "$out_dir/$(basename "$data").json"
        )
        data_line=$(wc -l <"$data")
        for cfile in "${c_files[@]}"; do
            binfile=$(build_cfile "$cfile")
            hyperfine_args+=("$binfile $data $data_line $_max_value > /dev/null")
        done
        hyperfine "${hyperfine_args[@]}"
    done
}

main() {
    local target_data="${1-""}"

    check_env
    prepare
    # run_benchmark_max_value "$target_data"
    run_benchmark_data_num "$target_data"
}

main "$@"
