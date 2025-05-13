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

    local test_file=""
    for test_file in "$test_dir/"*"-in.txt"; do
        echo "Test: Running test: $(basename "$test_file")" >&2
        lexer_out="$(./kadai2 "$(cat "$test_file")" || true)"
        expected_out="$(cat "${test_file/in/out}")"
        if [ "$lexer_out" != "$expected_out" ]; then
            echo "Test: Test failed for $test_file" >&2
            diff <(echo "$lexer_out") <(echo "$expected_out") || true
        else
            echo "Test: Test passed" >&2
        fi
    done
    cd "$OLDPWD" || return 1
}

main() {
    do_test "."
}

main "$@"
