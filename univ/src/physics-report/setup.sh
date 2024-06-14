#!/usr/bin/env bash

script_path="$(dirname "$(realpath "$0")")"

# Setup venv
python3 -m venv "$script_path/venv"

# Activate venv
# shellcheck source=/dev/null
source "$script_path/venv/bin/activate"

# Install dependencies
pip install -r "$script_path/requirements.txt"
