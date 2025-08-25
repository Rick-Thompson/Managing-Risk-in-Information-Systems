#!/bin/bash

# Script to add section numbers to markdown chapters
# Supports 3 levels deep (e.g., 1.1, 1.1.1, 1.1.1.1)

# Function to process a single chapter file
process_chapter() {
    local chapter_file="$1"
    local chapter_num="$2"
    local temp_file="${chapter_file}.tmp"
    
    # Initialize counters
    local section_num=0
    local subsection_num=0
    local subsubsection_num=0
    
    echo "Processing Chapter $chapter_num: $chapter_file"
    
    # Read the file line by line
    while IFS= read -r line; do
        # Check if line starts with ### (but not #### or more)
        if [[ "$line" =~ ^###[[:space:]] ]] && [[ ! "$line" =~ ^#### ]]; then
            # Level 1 section (###)
            section_num=$((section_num + 1))
            subsection_num=0
            subsubsection_num=0
            
            # Extract the heading text after ### and spaces
            heading_text=$(echo "$line" | sed 's/^###[[:space:]]\+//')
            # Remove any existing numbering at the start
            heading_text=$(echo "$heading_text" | sed -E 's/^[0-9]+\.[0-9]+(\.[0-9]+)*[[:space:]]+//')
            
            echo "### ${chapter_num}.${section_num} ${heading_text}"
            
        elif [[ "$line" =~ ^####[[:space:]] ]] && [[ ! "$line" =~ ^##### ]]; then
            # Level 2 subsection (####)
            subsection_num=$((subsection_num + 1))
            subsubsection_num=0
            
            # Extract the heading text after #### and spaces
            heading_text=$(echo "$line" | sed 's/^####[[:space:]]\+//')
            # Remove any existing numbering at the start
            heading_text=$(echo "$heading_text" | sed -E 's/^[0-9]+\.[0-9]+(\.[0-9]+)*[[:space:]]+//')
            
            echo "#### ${chapter_num}.${section_num}.${subsection_num} ${heading_text}"
            
        elif [[ "$line" =~ ^#####[[:space:]] ]]; then
            # Level 3 subsubsection (#####)
            subsubsection_num=$((subsubsection_num + 1))
            
            # Extract the heading text after ##### and spaces
            heading_text=$(echo "$line" | sed 's/^#####[[:space:]]\+//')
            # Remove any existing numbering at the start
            heading_text=$(echo "$heading_text" | sed -E 's/^[0-9]+\.[0-9]+(\.[0-9]+)*[[:space:]]+//')
            
            echo "##### ${chapter_num}.${section_num}.${subsection_num}.${subsubsection_num} ${heading_text}"
            
        else
            # Not a heading, output as-is
            echo "$line"
        fi
    done < "$chapter_file" > "$temp_file"
    
    # Replace the original file with the processed one
    mv "$temp_file" "$chapter_file"
    echo "✓ Completed Chapter $chapter_num"
}

# Main execution
main() {
    # Check if we're in the right directory
    if [[ ! -f "050-foreword.md" ]]; then
        echo "Error: This script should be run from the book's root directory."
        echo "Current directory: $(pwd)"
        exit 1
    fi
    
    # Create a backup directory
    backup_dir="backup_$(date +%Y%m%d_%H%M%S)"
    echo "Creating backup in $backup_dir..."
    mkdir -p "$backup_dir"
    
    # Find all chapter directories and process them
    chapter_count=0
    for chapter_dir in chapter*/; do
        if [[ -d "$chapter_dir" ]]; then
            chapter_count=$((chapter_count + 1))
            chapter_file="${chapter_dir}100-chapter.md"
            
            if [[ -f "$chapter_file" ]]; then
                # Create backup
                cp -r "$chapter_dir" "$backup_dir/"
                
                # Extract chapter number from directory name
                chapter_num=$(echo "$chapter_dir" | sed -E 's/chapter0*([0-9]+).*/\1/')
                
                # Process the chapter
                process_chapter "$chapter_file" "$chapter_num"
            else
                echo "Warning: No 100-chapter.md found in $chapter_dir"
            fi
        fi
    done
    
    if [[ $chapter_count -eq 0 ]]; then
        echo "Error: No chapter directories found!"
        exit 1
    fi
    
    echo ""
    echo "✅ Section numbering complete!"
    echo "📁 Backup created in: $backup_dir"
    echo "📚 Processed $chapter_count chapters"
}

# Run the main function
main