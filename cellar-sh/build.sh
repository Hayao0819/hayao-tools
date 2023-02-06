#!/usr/bin/env bash

set -e


current_dir="$(cd "$(dirname "$0")" || exit 1; pwd)"
fsblib="$current_dir/lib"
fsbfrm="$fsblib/framework/fsbfrm"
build="$current_dir/build"

[[ -d "$build" ]] || mkdir -p "$build"

[[ -e "$fsbfrm" ]] || {
  echo "fsbfrm not found"
  exit 1
}

"${fsblib}/bin/Build-Single.sh" -out "${current_dir}/build/fsblib.sh" BetterShell

fsbfrm (){
    "$fsbfrm" "$@"
}

fsbfrm -C "$current_dir/src" -o "$build" "$@"
