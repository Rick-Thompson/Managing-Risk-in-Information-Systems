#!/bin/bash

# Check if directory argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory>"
    echo "Example: $0 /path/to/markdown/files"
    exit 1
fi

# Check if the directory exists
if [ ! -d "$1" ]; then
    echo "Error: Directory '$1' does not exist."
    exit 1
fi

# Change to the specified directory
cd "$1" || exit 1

# Find all markdown files and process them
find . -maxdepth 1 -name "*.md" -type f | while read -r file; do
    echo "Processing: $file"
    
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Process the file: add an extra # to all lines that start with #
    sed 's/^#/#&/' "$file" > "$temp_file"
    
    # Replace the original file with the modified content
    mv "$temp_file" "$file"
    
    echo "Updated: $file"
done

echo "Finished processing markdown files in directory: $1"