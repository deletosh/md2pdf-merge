# Markdown Conversion Toolkit

A suite of tools for converting multiple markdown files to PDF and EPUB formats. These scripts are perfect for creating documentation, books, or offline reading materials from web content.

Created by [@deletosh](https://github.com/deletosh), these tools are frequently used in combination with [MarkDownload - Markdown Web Clipper](https://github.com/deathau/markdownload) to download documentation and guides for offline use. The workflow allows you to clip web content as markdown and then batch convert it to well-formatted documents for archiving or reading.

## Features

- Automatically finds and merges markdown files with numeric prefixes (e.g., "01 - Introduction.md")
- Preserves the order of files based on their numeric prefixes
- Creates a table of contents for navigation
- Adds page breaks between documents
- Handles spaces in filenames
- Works on macOS and Linux
- Perfect companion to [MarkDownload - Markdown Web Clipper](https://github.com/deathau/markdownload) for creating offline documentation collections

## Tools Included

This toolkit includes two main tools:

1. **md2pdf-merge.sh**: Combines markdown files into a single PDF document
2. **md2epub-merge.sh**: Combines markdown files into a single EPUB e-book

## Prerequisites

### For Both Tools
- **Pandoc**: Required for all conversions
  ```
  # macOS
  brew install pandoc
  
  # Ubuntu/Debian
  sudo apt-get install pandoc
  ```

### For PDF Conversion
- **LaTeX**: Required for PDF generation
  ```
  # macOS
  brew install basictex
  
  # Ubuntu/Debian
  sudo apt-get install texlive
  ```

- **librsvg** (optional but recommended): For SVG image support
  ```
  # macOS
  brew install librsvg
  
  # Ubuntu/Debian
  sudo apt-get install librsvg2-bin
  ```

## Installation

1. Download the scripts:
   ```
   curl -O https://raw.githubusercontent.com/deletosh/markdown-tools/main/md2pdf-merge.sh
   curl -O https://raw.githubusercontent.com/deletosh/markdown-tools/main/md2epub-merge.sh
   ```

2. Make them executable:
   ```
   chmod +x md2pdf-merge.sh
   chmod +x md2epub-merge.sh
   ```

## Web Clipper Integration

These tools work seamlessly with [MarkDownload - Markdown Web Clipper](https://github.com/deathau/markdownload) to create offline documentation collections:

1. Use MarkDownload to clip web documentation as markdown files
2. Save the clips with numeric prefixes to maintain order (e.g., "01 - Introduction.md")
3. Run either script to combine them into a single, well-formatted document
4. Enjoy your offline documentation with proper formatting and table of contents

## Usage: PDF Conversion

```
./md2pdf-merge.sh [input_directory] [output_filename]
```

### Parameters

- `input_directory`: Directory containing the markdown files (default: current directory)
- `output_filename`: Name of the output PDF file (default: merged_document.pdf)

### Examples

```bash
# Use current directory, default output name (merged_document.pdf)
./md2pdf-merge.sh

# Use a specific directory, default output name
./md2pdf-merge.sh ./docs

# Use a specific directory and custom output name
./md2pdf-merge.sh ./docs my_document.pdf

# Use current directory with an output filename containing spaces
./md2pdf-merge.sh . 'My Final Document.pdf'
```

## Usage: EPUB Conversion

```
./md2epub-merge.sh [input_directory] [output_filename]
```

### Parameters

- `input_directory`: Directory containing the markdown files (default: current directory)
- `output_filename`: Name of the output EPUB file (default: merged_document.epub)

### Examples

```bash
# Use current directory, default output name (merged_document.epub)
./md2epub-merge.sh

# Use a specific directory, default output name
./md2epub-merge.sh ./docs

# Use a specific directory and custom output name
./md2epub-merge.sh ./docs my_ebook.epub

# Use current directory with an output filename containing spaces
./md2epub-merge.sh . 'My Programming Guide.epub'
```

## File Naming Convention

Both scripts look for markdown files with numeric prefixes followed by any text, such as:

- 01 - Introduction - Model Context Protocol.md
- 02 - For Server Developers - Model Context Protocol.md
- 03 - For Claude Desktop Users - Model Context Protocol.md

Files are sorted numerically based on their prefixes, so the order will be preserved in the final document.

## Customizing Your Documents

### PDF Customization

The PDF script includes settings for:
- Page margins (default: 1 inch)
- Font size (default: 11pt)
- Table of contents

You can modify these in the script by editing the pandoc parameters.

### EPUB Customization

To customize the metadata of your EPUB (such as title, author, language), edit the metadata section in the script:

```bash
# Find this section in the md2epub-merge.sh script
cat > "$temp_dir/metadata.yaml" << EOF
---
title: "Merged Document"
author: "Generated with md2epub"
date: "$(date +"%Y-%m-%d")"
lang: "en-US"
---
EOF
```

The EPUB script also includes CSS styling for better formatting.

## Troubleshooting

### PDF Conversion Issues

#### SVG Images Not Appearing
If you see warnings about SVG conversion, install the librsvg package:

```
brew install librsvg   # macOS
sudo apt install librsvg2-bin   # Ubuntu/Debian
```

#### Other LaTeX Errors
You might need additional LaTeX packages depending on your document content:

```
# macOS
tlmgr install <package-name>

# Ubuntu/Debian
sudo apt-get install texlive-latex-extra
```

### EPUB Conversion Issues

#### "No such file or directory" Error
If you encounter a "file does not exist" error:
- Ensure your output path is writable
- Check if you have permission to create files in the target directory
- Try using an absolute path for the output file

#### Images Not Appearing
If images from your markdown files aren't appearing in the EPUB:
- Make sure image paths in your markdown are relative to the markdown file
- For web images, download them locally first and update the links in your markdown

#### EPUB Validation Errors
EPUBs have strict formatting requirements. If your reader reports errors:
- Check that your markdown is well-formed
- Use a validator like [EPUBCheck](https://github.com/w3c/epubcheck) to find specific issues

## Which Format Should I Choose?

- **PDF**: Best for documents that need to maintain exact formatting, printed materials, or documents with complex layouts
- **EPUB**: Better for e-readers, mobile devices, and when you want text reflow capabilities

## License

These scripts are provided under the MIT License. Feel free to modify and distribute them as needed.
