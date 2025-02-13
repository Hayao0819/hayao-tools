#!/usr/bin/env bash
set -eEuo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" || exit

if [[ ! -e "venv" ]]; then
    python3 -m venv venv
fi

#shellcheck source=/dev/null
source venv/bin/activate

pip install -r requirements.txt

# Download the dataset
mkdir -p data
cd ./data || exit
signate download -c 104

# Unzip the dataset
unzip test.zip
unzip train.zip
