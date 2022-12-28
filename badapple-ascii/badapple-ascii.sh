#!/usr/bin/env bash
set -eEuo pipefail

BADAPPLE_MP4="$(realpath "$1")"
TMP_DIR="$(mktemp -d)"
RAW_FPS=0 FPS=0 WAIT_TIME=0

trap 'rm -rf "$TMP_DIR"' EXIT ERR INT TERM
[[ -e "$BADAPPLE_MP4" ]] || { echo "File not found: $BADAPPLE_MP4" >&2 && exit 1; }
mkdir -p "$TMP_DIR/img" "$TMP_DIR/txt"

# Convert mp4 to jpg
echo "Waiting for ffmpeg to convert mp4 to jpg..." >&2
ffmpeg -i "$BADAPPLE_MP4" -vcodec mjpeg "$TMP_DIR/img/%d.jpg" >/dev/null 2>&1

# get fps
echo "Calculating fps..." >&2
RAW_FPS=$(ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate "$BADAPPLE_MP4")
FPS=$(echo "$RAW_FPS" | awk -F/ '{print $1/$2}')
WAIT_TIME="0$(echo "scale=3; 1/$FPS" | bc)"

# Convert jpg to ascii
echo "Waiting for jp2a to finish..." >&2
while read -r f; do
    # shellcheck disable=SC2001
    jp2a "$f" > "$TMP_DIR/txt/$(sed "s|.jpg$||" <<< "$(basename "$f")")" &
done < <(find "$TMP_DIR/img" -type f -name '*.jpg')

# Wait
wait
echo "Press Enter key to start..." >&2
read -r

# Play ascii arts
trap 'printf "\33c\e[3J"' EXIT ERR INT TERM
while read -r f; do
    printf "\033[%d;%dH" "1" "1"
    cat "$TMP_DIR/txt/$f"
    sleep "$WAIT_TIME"
done < <(find "$TMP_DIR/txt" -type f -print0 | xargs -0 basename | sort -n)

