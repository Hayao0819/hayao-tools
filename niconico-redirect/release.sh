#!/usr/bin/env bash

current_dir=$(
    cd "$(dirname "$0")" || exit
    pwd
)

zip -r niconico-redirect.zip "$current_dir"
