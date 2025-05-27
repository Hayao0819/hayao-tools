#!/usr/bin/env bash

set -euo pipefail
cd "$(dirname "$0")" || exit 1
current_dir="$(pwd)"
test_dir="$current_dir/test"

print_file() {
    echo -e "- $(basename "$1")"
    echo
    echo -e '#sourcecode[```'
    cat "$1"
    echo -e '```]'
}

# do_test DIR
do_create_testcase() {
    cd "$1" || return 1

    echo "Test: Compiling in $(sed "s|$current_dir||g" < <(pwd))" >&2
    ({ make clean && make; } >/dev/null 2>&1) || {
        echo "Test: Build failed" >&2
        return 1
    }

    local test_file=""
    for test_file in "$test_dir/"*"-in.txt"; do
        out_file="${test_file/in/out}"
        print_file "$test_file"
        echo
        print_file "$out_file"
        echo
    done
    cd "$OLDPWD" || return 1
}

main() {
    do_create_testcase "."
}

main "$@"
