#!/usr/bin/env bash

set -eEuo pipefail
cd "$(dirname "$(realpath "$0")")" || exit 1

if [[ ! -d venv ]]; then
    python -m venv venv
    pip install -r requirements.txt
fi

#shellcheck source=/dev/null
source venv/bin/activate || exit 1


python ./show-graph-csv.py "$@"
