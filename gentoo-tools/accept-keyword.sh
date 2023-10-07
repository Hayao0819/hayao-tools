#!/usr/bin/env bash
# 指定されたパッケージでキーワードを許容します
#
# accept-keyword <package> <keyword>

write_file="/etc/portage/package.accept_keywords/$(cut -d "/" -f 2)"
[[ -e "$write_file" ]] && {
    echo "Warning: file exists ($write_file)"
}
echo "$1 ${2:-"*"}" >> "$write_file"

