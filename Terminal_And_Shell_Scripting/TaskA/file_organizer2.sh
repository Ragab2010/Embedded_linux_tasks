#!/usr/bin/bash

############## Input Handling ##############
INPUT_DIR="${1:-.}"

# Check if the input directory exists
if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: Directory ($INPUT_DIR) does not exist."
    exit 1
fi

############## File Organization ##############
# Navigate to the input directory
cd "$INPUT_DIR" || exit

for item in *; do
    # Skip if it's a directory or hidden file (starting with .)
    if [[ -d "$item" || "$item" == .* ]]; then
        continue
    fi

    # Extract file extension
    EXT="${item##*.}"
    
    # Handle files with no extension
    if [[ "$EXT" == "$item" ]]; then
        EXT="misc"
    fi
    
    # Create subdirectory for the file extension if it doesn't exist
    if [[ ! -d "$EXT" ]]; then
        mkdir "$EXT"
    fi
    
    # Move the file into the appropriate subdirectory
    mv "$item" "$EXT/"
done

echo "Files have been organized successfully."
