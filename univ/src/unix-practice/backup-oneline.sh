#!/usr/bin/env sh

printf "%s\n" "$@" | xargs -I{} bash -c "echo 'Copying {} to {}.bak' && cp '{}' '{}.bak'"
