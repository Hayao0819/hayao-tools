#!/usr/bin/env bash

set -euo pipefail
cd "$(dirname "$0")" || exit 1

{
    make clean && make
} >/dev/null 2>&1 || {
    echo "Test: Build failed" >&2
    exit 1
}

main() {
    local test_file=""
    for test_file in ./test/*-in.txt; do
        echo "Test: Running test: $test_file" >&2
        lexer_out="$(./regex "$(cat < <("$test_file"))" || true)"
        expected_out="$(cat "${test_file/in/out}")"
        if [ "$lexer_out" != "$expected_out" ]; then
            echo "Test: Test failed for $test_file" >&2
            diff <(echo "$lexer_out") <(echo "$expected_out") || true
        else
            echo "Test: Test passed" >&2
        fi
    done

}

main "$@"
