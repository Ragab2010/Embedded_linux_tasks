#!/usr/bin/bash

# ${var}: Expands to the value of var.
# ${var-default}: Uses default if var is unset.
# ${var:-default}: Uses default if var is unset or null.
# ${var:=default}: Assigns default to var if it’s unset and then expands.
# ${var:+value}: Expands to value if var is set and non-null; otherwise expands to nothing.
# ${#var}: Gives the length of variable var.


############## Input Handling ##############
INPUT_DIR="${1:-.}" # use  . directory if the $1 is unset 

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
    if [[ -d $item || $item == .* ]]; then
        continue
    fi

    # Extract file extension
    EXT="${item##*.}"
    
    # Handle files with no extension
    if [[ $EXT == $item ]]; then
        EXT="misc"
    fi
    
    # Create subdirectory for the file extension if it doesn't exist
    if [[ ! -d $EXT ]]; then
        mkdir $EXT
    fi
    
    # Move the file into the appropriate subdirectory
    mv $item "$EXT/"
done

echo "Files have been organized successfully."
