#!/bin/bash

# Check if the input file is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <input.m3u>"
    exit 1
fi

# Input and Output filenames
m3u_file="$1"
pls_file="${m3u_file%.m3u}.pls"

# Initialize the PLS file
echo "[playlist]" > "$pls_file"

# Variables to keep track of entry numbers and total entries
entry_count=0
total_length=0

# Read the m3u file line by line
while IFS= read -r line; do
    # Check if it's an info line (e.g. #EXTINF:123, Artist - Title)
    if [[ "$line" =~ ^#EXTINF ]]; then
        # Extract length and title information
        length=$(echo "$line" | sed -e 's/^#EXTINF:\([0-9]*\),.*/\1/')
        title=$(echo "$line" | sed -e 's/^#EXTINF:[0-9]*,\(.*\)/\1/')
    elif [[ ! "$line" =~ ^# ]]; then
        # Increment entry count and save the file and title information
        entry_count=$((entry_count + 1))
        echo "File${entry_count}=${line}" >> "$pls_file"
        echo "Title${entry_count}=${title}" >> "$pls_file"
        echo "Length${entry_count}=${length}" >> "$pls_file"
        total_length=$((total_length + length))
    fi
done < "$m3u_file"

# Write the total number of entries and version
echo "NumberOfEntries=$entry_count" >> "$pls_file"
echo "Version=2" >> "$pls_file"

echo "Converted $m3u_file to $pls_file successfully."
