#!/usr/bin/env sh
seq "$1" "$2" | xargs -I{} bash -c "echo 'Making cal-{}.txt' >&2;{ [ -e './cal-{}.txt' ] && echo 'File exists: cal-{}.txt'; } || cal '{}' > 'cal-{}.txt'"
