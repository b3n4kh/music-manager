#!/bin/bash

DOWNLOADS_DIR="/downloads"
CONVERTED_DIR="$(mktemp -d)"

OVERRIDE=0
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -o|--override) OVERRIDE=1 ;;
        *) echo "Unknown parameter passed: $1" >&2; exit 1 ;;
    esac
    shift
done

convert_if_audio() {
    local input="$1"
    local mime=$(file --brief --mime-type "$input")
    
    if [[ $mime == audio/* ]]; then
        local output="${CONVERTED_DIR}/${input##${DOWNLOADS_DIR}/}"
        output="${output%.*}.opus"
        
        mkdir -p "$(dirname "$output")"
        if ffmpeg -i "$input" -c:a libopus -b:a 192k -map_metadata 0 "$output" 2>/dev/null; then
            if [[ $OVERRIDE -eq 1 ]]; then
                rm -f "$input"
            fi
            mv "$output" "${input%.*}.opus"
            echo "${input%.*}.opus"
        else
            echo "Error converting file: $input" >&2
        fi
    fi
}

export -f convert_if_audio
export DOWNLOADS_DIR
export CONVERTED_DIR
export OVERRIDE

# Use GNU Parallel to find and convert all files in parallel
find "$DOWNLOADS_DIR" -type f -exec bash -c 'convert_if_audio "$0"' {} \;

trap "exit 1" HUP INT PIPE QUIT TERM
trap 'rm -rf "$CONVERTED_DIR"' EXIT
