#!/usr/bin/env bash

current_dir="$(cd "$(dirname "$0")" || exit 1; pwd)"
cd "$current_dir/go" || exit 1
go build -buildmode=c-shared -o ../out/libhello.so .
