#!/usr/bin/env sh

set -e -u
cd "$(dirname "$0")" || exit 1
mkdir -p build
meson setup ./build
cd build || exit 1
ninja
