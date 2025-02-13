#!/usr/bin/env bash

script_path="$(dirname "$(realpath "$0")")"

if [ ! -d "$script_path/venv" ]; then
    "$script_path/setup.sh"
fi

# Activate venv
# shellcheck source=/dev/null
source "$script_path/venv/bin/activate"

# Run the script
python3 "$script_path/main.py"
