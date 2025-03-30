#!/bin/bash

# md2epub-merge.sh - A script to merge numerically ordered markdown files into a single EPUB
# Usage: ./md2epub-merge.sh [input_directory] [output_filename]

# Set default values
input_dir="${1:-.}"  # Default to current directory if not specified
output_file="${2:-merged_document.epub}"  # Default output filename

# Display usage information if help flag is provided
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $(basename "$0") [input_directory] [output_filename]"
    echo ""
    echo "  input_directory   Directory containing markdown files (default: current directory)"
    echo "  output_filename   Name of the output EPUB file (default: merged_document.epub)"
    echo ""
    echo "Example:"
    echo "  $(basename "$0")                             # Use current directory, default output name"
    echo "  $(basename "$0") ./docs                      # Use ./docs directory, default output name"
    echo "  $(basename "$0") ./docs my_document.epub     # Use ./docs directory, custom output name"
    echo "  $(basename "$0") . 'My Book.epub'            # Current directory, output with spaces"
    exit 0
fi

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc is not installed. Please install it first."
    echo "Installation instructions: https://pandoc.org/installing.html"
    exit 1
fi

# Check pandoc version
pandoc_version=$(pandoc --version | head -1 | cut -d' ' -f2)
echo "Pandoc version: $pandoc_version"

# Make sure input_dir is absolute path
if [[ ! "$input_dir" = /* ]]; then
    input_dir="$(pwd)/$input_dir"
fi

# Make sure output_file is absolute path
if [[ ! "$output_file" = /* ]]; then
    output_file="$(pwd)/$output_file"
fi

# Check if input directory exists
if [ ! -d "$input_dir" ]; then
    echo "Error: Input directory '$input_dir' does not exist or is not a directory."
    exit 1
fi

# Create a temporary directory for working files
temp_dir=$(mktemp -d)
echo "Created temporary directory: $temp_dir"

# Create metadata.yaml file for EPUB
cat > "$temp_dir/metadata.yaml" << EOF
---
title: "Merged Document"
author: "Generated with md2epub"
date: "$(date +"%Y-%m-%d")"
lang: "en-US"
---
EOF
echo "Created EPUB metadata file: $temp_dir/metadata.yaml"

# Check if the metadata file was created successfully
if [ ! -f "$temp_dir/metadata.yaml" ]; then
    echo "Error: Failed to create metadata file"
    rm -rf "$temp_dir"
    exit 1
fi

# First, list all markdown files to see what's available
echo "Searching for markdown files in: $input_dir"

# Find all markdown files that match the pattern and sort them numerically
echo "Finding and sorting markdown files..."

# Use find with proper quoting to handle spaces in filenames
files=()
while IFS= read -r line; do
    # Only add non-empty lines to the array
    if [ -n "$line" ]; then
        files+=("$line")
    fi
done < <(find "$input_dir" -maxdepth 1 -type f -name "[0-9][0-9]*.md" | sort -n)

# Check if any files were found
if [ ${#files[@]} -eq 0 ]; then
    echo "Error: No markdown files matching the pattern found in $input_dir"
    rm -rf "$temp_dir"
    exit 1
fi

# List the files being processed
echo "Files to be merged (in this order):"
for i in "${!files[@]}"; do
    echo "[$((i+1))] $(basename "${files[$i]}")"
    # Check if file exists and is readable
    if [ ! -f "${files[$i]}" ]; then
        echo "Error: File does not exist: ${files[$i]}"
        rm -rf "$temp_dir"
        exit 1
    fi
    if [ ! -r "${files[$i]}" ]; then
        echo "Error: File is not readable: ${files[$i]}"
        rm -rf "$temp_dir"
        exit 1
    fi
done

# Create content file
content_file="$temp_dir/content.md"
echo "Content will be written to: $content_file"

# Append each file to the content file with chapter headings
for file in "${files[@]}"; do
    filename=$(basename "$file")
    echo "Processing: $filename"

    # Extract title from filename (assuming format like "01 - Title.md")
    title=$(basename "$file" .md | sed -E 's/^[0-9]+ *- *//')

    # Add a chapter heading
    echo -e "# $title\n" >> "$content_file"

    # Append the file content
    cat "$file" >> "$content_file"

    # Add a newline at the end of each file
    echo -e "\n" >> "$content_file"
done

# Check if content file was created successfully
if [ ! -f "$content_file" ]; then
    echo "Error: Content file was not created: $content_file"
    rm -rf "$temp_dir"
    exit 1
fi

# Check content file size
content_size=$(wc -c < "$content_file")
echo "Content file size: $content_size bytes"
if [ "$content_size" -eq 0 ]; then
    echo "Error: Content file is empty"
    rm -rf "$temp_dir"
    exit 1
fi

# Create output directory if it doesn't exist
output_dir=$(dirname "$output_file")
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
    echo "Created output directory: $output_dir"
fi

# Create a CSS file with basic styling
cat > "$temp_dir/epub.css" << EOF
body {
  font-family: serif;
  margin: 5%;
  text-align: justify;
}
h1, h2, h3, h4, h5, h6 {
  font-family: sans-serif;
  margin-top: 2em;
}
h1 {
  page-break-before: always;
}
code {
  font-family: monospace;
}
pre {
  background-color: #f8f8f8;
  border: 1px solid #ccc;
  border-radius: 3px;
  padding: 0.5em;
  overflow: auto;
}
EOF
echo "Created CSS file: $temp_dir/epub.css"

echo "Converting merged markdown to EPUB..."
echo "Output file: $output_file"

# Convert to EPUB
pandoc \
    -f markdown \
    -t epub \
    --css="$temp_dir/epub.css" \
    --metadata-file="$temp_dir/metadata.yaml" \
    --toc \
    --toc-depth=2 \
    -o "$output_file" \
    "$content_file"

# Check if conversion was successful
if [ $? -eq 0 ]; then
    echo "Successfully created EPUB: $output_file"
else
    echo "Failed to create EPUB with initial attempt. Trying alternative approach..."

    # Try alternative approach with standalone pandoc option
    pandoc \
        -f markdown \
        -t epub \
        --css="$temp_dir/epub.css" \
        --metadata-file="$temp_dir/metadata.yaml" \
        --toc \
        --toc-depth=2 \
        --standalone \
        -o "$output_file" \
        "$content_file"

    # Check if alternative approach worked
    if [ $? -eq 0 ]; then
        echo "Successfully created EPUB with alternative approach: $output_file"
    else
        echo "Both approaches failed."
    fi
fi

# Clean up
rm -rf "$temp_dir"

echo "Script completed. EPUB file created at: $output_file"
