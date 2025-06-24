#!/usr/bin/env bash

set -euo pipefail
cd "$(dirname "$0")" || exit 1
current_dir="$(pwd)"
test_dir="$current_dir/test"

# do_test DIR
do_test() {
    cd "$1" || return 1

    echo "Test: Compiling in $(sed "s|$current_dir||g" < <(pwd))" >&2
    ({ make clean && make; } >/dev/null 2>&1) || {
        echo "Test: Build failed" >&2
        return 1
    }

    for reg_file in "$test_dir/"*-reg.txt; do
        nbase="${reg_file##*/}"
        nbase="${nbase%-reg.txt}"
        target_file="$test_dir/${nbase}-target.txt"
        echo "Test: Running test: $nbase" >&2
        regex="$(cat "$reg_file")"
        if [ ! -f "$target_file" ]; then
            echo "Test: Missing target file $target_file" >&2
            continue
        fi

        for opt in "" "-v" "-s" "-sv"; do
            case "$opt" in
            "") suffix="" ;;
            "-v") suffix="-v" ;;
            "-s") suffix="-s" ;;
            "-sv") suffix="-sv" ;;
            esac
            echo "===== $nbase $opt =====" # 区切りを明示
            grep_out="$(./kadai5 $opt "$regex" "$target_file" || true)"
            expected_out_file="$test_dir/${nbase}-expected${suffix}.txt"
            if [ -f "$expected_out_file" ]; then
                expected_out="$(cat "$expected_out_file")"
                if [ "$grep_out" != "$expected_out" ]; then
                    echo "Test: Test failed for $reg_file ($opt)" >&2
                    diff <(echo "$grep_out") <(echo "$expected_out") || true
                else
                    echo "Test: Test passed ($opt)" >&2
                fi
            else
                echo "$grep_out"
                # echo "$grep_out" >"$expected_out_file"
                # echo "Test: Created $expected_out_file ($opt)" >&2
            fi
        done
    done
    cd "$OLDPWD" || return 1
}

do_test_multifile() {
    cd "$1" || return 1

    echo "Test: Compiling in $(sed "s|$current_dir||g" < <(pwd))" >&2
    ({ make clean && make; } >/dev/null 2>&1) || {
        echo "Test: Build failed" >&2
        return 1
    }

    # 複数ファイルをまとめてテスト
    for reg_file in "$test_dir/"*-reg.txt; do
        nbase="${reg_file##*/}"
        nbase="${nbase%-reg.txt}"
        n=$(echo "$nbase" | grep -oE '^[0-9]+')
        target_files=()
        for i in $(seq $((n - 1)) $((n + 1))); do
            tf="$test_dir/${i}-target.txt"
            if [ -f "$tf" ]; then
                target_files+=("$tf")
            fi
        done
        if [ -z "${target_files[*]}" ]; then
            continue
        fi
        regex="$(cat "$reg_file")"
        for opt in "" "-v" "-s" "-sv"; do
            case "$opt" in
            "") suffix="" ;;
            "-v") suffix="-v" ;;
            "-s") suffix="-s" ;;
            "-sv") suffix="-sv" ;;
            esac
            echo "===== multifile $nbase $opt ====="
            grep_out="$(./kadai5 $opt "$regex" "${target_files[@]}" || true)"
            expected_out_file="$test_dir/${nbase}-expected-multifile${suffix}.txt"
            if [ -f "$expected_out_file" ]; then
                expected_out="$(cat "$expected_out_file")"
                if [ "$grep_out" != "$expected_out" ]; then
                    echo "Test: Test failed for $reg_file multifile ($opt)" >&2
                    diff <(echo "$grep_out") <(echo "$expected_out") || true
                else
                    echo "Test: Test passed multifile ($opt)" >&2
                fi
            else
                echo "$grep_out"
                # echo "$grep_out" >"$expected_out_file"
                # echo "Test: Created $expected_out_file multifile ($opt)" >&2
            fi
        done
    done
    cd "$OLDPWD" || return 1
}

main() {
    do_test "."
    do_test_multifile "."
}

main "$@"
