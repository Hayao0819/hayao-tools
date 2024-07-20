#!/usr/bin/env sh

current_path="$(
    cd "$(dirname "$0")" || exit 1
    pwd
)"
cd "$current_path" || exit 1
go build -o out/gistrge .
