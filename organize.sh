#!/bin/bash

DOWNLOADS_DIR="/downloads"
LIBRARY_DIR="/music"

move_based_on_metadata() {
    local file="$1"
    local filename=$(basename -- "$file")
    local artist=$(ffprobe -v error -show_entries stream_tags=artist -of default=noprint_wrappers=1:nokey=1 "$file")
    local album=$(ffprobe -v error -show_entries stream_tags=album -of default=noprint_wrappers=1:nokey=1 "$file")
    local title=$(ffprobe -v error -show_entries stream_tags=title -of default=noprint_wrappers=1:nokey=1 "$file")
    
    # Fallback for missing artist
    if [ -z "$artist" ]; then
        artist="VA"
    fi
    
    # Construct the target directory path
    local target_dir="$LIBRARY_DIR/$artist"
    if [ ! -z "$album" ]; then
        target_dir="$target_dir/$album"
    fi
    
    # Modify filename based on presence of '-' or parentheses

    if [ -z "$title" ]; then
        local new_filename="$filename"
    else
        local new_filename="$title"
    fi
    new_filename="${new_filename%%-*}"
    new_filename="${new_filename%%\(*}"
    new_filename="${new_filename%%\)*}"

    # Append the file extension if it's missing
    if [[ ! "$new_filename" == *".opus" ]]; then
        new_filename="$new_filename.opus"
    fi

    # Create the target directory if it doesn't exist
    mkdir -p "$target_dir"
    
    # Move and rename the file
    mv "$file" "$target_dir/$new_filename"
}

export -f move_based_on_metadata
export DOWNLOADS_DIR
export LIBRARY_DIR

# Find all Opus files and process them
find "$DOWNLOADS_DIR" -type f -iname "*.opus" -exec bash -c 'move_based_on_metadata "$0"' {} \;
