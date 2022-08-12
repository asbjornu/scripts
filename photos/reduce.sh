#!/bin/bash

me=$(basename "$0")

help_message="\
Usage: $me input.gif output.gif

This script will take an animated GIF and delete every other frame."

input="$1"
output="$2"

if [[ -z "$input" ]]; then
    echo "$help_message"
    exit 1
fi

if [[ -z "$output" ]]; then
    echo "$help_message"
    exit 1
fi

# Make a copy of the file
cp "$input" "$output"

# Get the number of frames
numframes=$(gifsicle -I "$input" | grep -P "\d+ images" --only-matching | grep -P "\d+" --only-matching)

# Deletion
let i=0
while [[ $i -lt $numframes  ]]; do
    rem=$(( $i % 2 ))

    if [ $rem -eq 0 ]
    then
        gifsicle $output --delete "#"$(($i/2)) -o $output
    fi

    let i=i+1
done
