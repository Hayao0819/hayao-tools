#!/usr/bin/env bash

# shellcheck source=/dev/null
source <(curl -sL https://raw.githubusercontent.com/Hayao0819/Hayao-Tools/master/libretranslate-sh/libretranslate.sh)

export LIBRETRANSLATE_URL="https://translate.argosopentech.com/"
TargetLanguage="${1:-"en"}"
while true; do
    read -p "> " -r -e Text
    libre_translate_translate_auto "${Text}" "${TargetLanguage}"
done
