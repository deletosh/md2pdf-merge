#!/bin/bash

# md2pdf-merge.sh - A script to merge numerically ordered markdown files into a single PDF
# Usage: ./md2pdf-merge.sh [input_directory] [output_filename]

# Set default values
input_dir="${1:-.}"  # Default to current directory if not specified
output_file="${2:-merged_document.pdf}"  # Default output filename

# Display usage information if help flag is provided
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $(basename "$0") [input_directory] [output_filename]"
    echo ""
    echo "  input_directory   Directory containing markdown files (default: current directory)"
    echo "  output_filename   Name of the output PDF file (default: merged_document.pdf)"
    echo ""
    echo "Example:"
    echo "  $(basename "$0")                             # Use current directory, default output name"
    echo "  $(basename "$0") ./docs                      # Use ./docs directory, default output name"
    echo "  $(basename "$0") ./docs my_document.pdf      # Use ./docs directory, custom output name"
    echo "  $(basename "$0") . 'Model Context Protocol.pdf' # Current directory, output with spaces"
    exit 0
fi

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc is not installed. Please install it first."
    echo "Installation instructions: https://pandoc.org/installing.html"
    exit 1
fi

# Check if librsvg is installed (for SVG conversion)
if ! command -v rsvg-convert &> /dev/null; then
    echo "Warning: rsvg-convert is not installed. SVG images will not be processed correctly."
    echo "To install on macOS: brew install librsvg"
    echo "Continuing anyway, but SVG images may not appear correctly..."
    echo ""
fi

echo "Looking for markdown files in: $input_dir"

# Create a temporary file to store the combined markdown
temp_file=$(mktemp)

# Check if input directory exists
if [ ! -d "$input_dir" ]; then
    echo "Error: Input directory '$input_dir' does not exist or is not a directory."
    rm "$temp_file"
    exit 1
fi

# First, list all markdown files to see what's available
echo "Available markdown files in $input_dir:"
ls -la "$input_dir"/*.md 2>/dev/null || echo "No markdown files found"

# Find all markdown files that match the pattern and sort them numerically
echo "Finding and sorting markdown files..."

# Mac-compatible way to store files in an array
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
    rm "$temp_file"
    exit 1
fi

# List the files being processed
echo "Files to be merged (in this order):"
for i in "${!files[@]}"; do
    echo "[$((i+1))] ${files[$i]}"
done

# Append each file to the temporary file with a page break between them
first_file=true
for file in "${files[@]}"; do
    filename=$(basename "$file")
    echo "Processing: $filename"

    # Add a page break before each file (except the first one)
    if [ "$first_file" = true ]; then
        first_file=false
    else
        echo -e "\n\\pagebreak\n" >> "$temp_file"
    fi

    # Append the file content - handle spaces in filenames properly
    cat "$file" >> "$temp_file"
done

echo "Converting merged markdown to PDF..."
echo "Output file: $output_file"

# Convert the combined markdown to PDF with enhanced options
pandoc "$temp_file" \
    -o "$output_file" \
    --pdf-engine=xelatex \
    -V geometry:margin=1in \
    -V fontsize=11pt \
    --toc \
    -V toc-title="Table of Contents" \
    --extract-media=./media \
    --self-contained \
    --fail-if-warnings=false

# Check if conversion was successful
if [ $? -eq 0 ]; then
    echo "Successfully created merged PDF: $output_file"
else
    echo "PDF generation had warnings or errors, but the file may still have been created."
    echo "If SVG conversion failed, try installing librsvg: brew install librsvg"

    if [ -f "$output_file" ]; then
        echo "The output file $output_file exists - it may be usable."
    else
        echo "The output file $output_file was not created."

        # Fallback to HTML if PDF failed
        echo "Trying to generate HTML instead as a fallback..."
        html_output="${output_file%.pdf}.html"

        pandoc "$temp_file" \
            -o "$html_output" \
            --self-contained \
            --toc \
            --metadata title="Merged Document"

        if [ $? -eq 0 ]; then
            echo "Successfully created HTML fallback: $html_output"
        else
            echo "Failed to create HTML fallback as well."
        fi
    fi
fi

# Clean up the temporary file
rm "$temp_file"
