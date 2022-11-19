#!/usr/bin/env bash

set -eEuo pipefail

BADAPPLE_MP4="$1"

#TMP_DIR="$(mktemp -d)"
TMP_DIR="${TMPDIR}/badapple-ascii/"

RAW_FPS=0
FPS=0
WAIT_TIME=0

trap 'rm -rf "$TMP_DIR"' EXIT ERR INT TERM
trap 'printf "\33c\e[3J"' EXIT ERR INT TERM

mkdir -p "$TMP_DIR/img" "$TMP_DIR/txt"

# Convert mp4 to jpg
echo "Waiting for ffmpeg to convert mp4 to jpg..."
ffmpeg -i "$BADAPPLE_MP4" -vcodec mjpeg "$TMP_DIR/img/%d.jpg" >/dev/null 2>&1

# get fps
echo "Calculating fps..."
RAW_FPS=$(ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate "$BADAPPLE_MP4")
FPS=$(echo "$RAW_FPS" | awk -F/ '{print $1/$2}')
WAIT_TIME="0$(echo "scale=3; 1/$FPS" | bc)"

# Convert jpg to ascii
echo "Waiting for jp2a to finish..."
while read -r f; do
    {
        # shellcheck disable=SC2001
        jp2a "$f" > "$TMP_DIR/txt/$(sed "s|.jpg$||" <<< "$(basename "$f")")"
    } &
done < <(find "$TMP_DIR/img" -type f -name '*.jpg')

wait

echo "Press Enter key to start..."
read -r

# Play ascii arts
while read -r f; do
    printf '\33c\e[3J'
    cat "$TMP_DIR/txt/$f"
    sleep "$WAIT_TIME"
done < <(find "$TMP_DIR/txt" -type f -print0 | xargs -0 basename | sort -n)

