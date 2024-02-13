#!/bin/bash

DOWNLOADS_DIR="/downloads"
CONVERTED_DIR="$(mktemp -d)"
LIBRARY_DIR="/music"
OVERRIDE=1

source /usr/local/bin/convert_to_opus.sh
source /usr/local/bin/organize.sh

process_file() {
    local file="$1"
    echo "Detected new file: $file"
    convert_if_audio "$file" | while read converted_file; do
        echo "Processing converted file: $converted_file"
        move_based_on_metadata "$converted_file"
    done
}

process_directory() {
    local dir="$1"
    find "$dir" -type f | while read file; do
        process_file "$file"
    done
}

inotify_loop() {
    inotifywait -m -e close_write,moved_to,create --format '%w%f' "${DOWNLOADS_DIR}" --recursive | while read path; do
        if [ -d "$path" ]; then
            # If the path is a directory, process all files within it
            echo "Detected new directory: $path"
            process_directory "$path"
        elif [ -f "$path" ]; then
            # If the path is a file, process the file
            process_file "$path"
        fi
    done
}

inotify_loop
