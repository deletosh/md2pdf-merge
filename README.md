# Markdown to PDF Merger

This script combines multiple markdown files into a single PDF document with a table of contents. It's especially useful for documentation, books, or reports that are split across multiple files.

Created by [@deletosh](https://github.com/deletosh), this tool is frequently used in combination with [MarkDownload - Markdown Web Clipper](https://github.com/deathau/markdownload) to download documentation and guides for offline use. The workflow allows you to clip web content as markdown and then batch convert it to a well-formatted PDF for archiving or offline reading.

## Features

- Automatically finds and merges markdown files with numeric prefixes (e.g., "01 - Introduction.md")
- Preserves the order of files based on their numeric prefixes
- Creates a table of contents
- Adds page breaks between documents
- Handles spaces in filenames
- Falls back to HTML if PDF generation fails
- Works on macOS and Linux
- Perfect companion to [MarkDownload - Markdown Web Clipper](https://github.com/deathau/markdownload) for creating offline documentation collections

## Prerequisites

- **Pandoc**: The script uses Pandoc to convert markdown to PDF
  ```
  # macOS
  brew install pandoc
  
  # Ubuntu/Debian
  sudo apt-get install pandoc
  ```

- **LaTeX**: Required by Pandoc for PDF generation
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

1. Download the script:
   ```
   curl -O https://raw.githubusercontent.com/deletosh/md2pdf/main/md2pdf-merge.sh
   ```

2. Make it executable:
   ```
   chmod +x md2pdf-merge.sh
   ```

## Usage

```
./md2pdf-merge.sh [input_directory] [output_filename]
```

### Parameters

- `input_directory`: Directory containing the markdown files (default: current directory)
- `output_filename`: Name of the output PDF file (default: merged_document.pdf)

### Web Clipper Integration

This tool works seamlessly with [MarkDownload - Markdown Web Clipper](https://github.com/deathau/markdownload) to create offline documentation collections:

1. Use MarkDownload to clip web documentation as markdown files
2. Save the clips with numeric prefixes to maintain order (e.g., "01 - Introduction.md")
3. Run this script to combine them into a single, well-formatted PDF
4. Enjoy your offline documentation with proper formatting and table of contents

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

## File Naming Convention

The script looks for markdown files with numeric prefixes followed by any text, such as:

- 01 - Introduction - Model Context Protocol.md
- 02 - For Server Developers - Model Context Protocol.md
- 03 - For Claude Desktop Users - Model Context Protocol.md

Files are sorted numerically based on their prefixes, so the order will be preserved in the final PDF.

## Troubleshooting

### SVG Images Not Appearing

If you see warnings about SVG conversion, install the librsvg package:

```
brew install librsvg   # macOS
sudo apt install librsvg2-bin   # Ubuntu/Debian
```

### PDF Generation Fails

If PDF generation fails, the script will attempt to create an HTML file instead. This can be useful for troubleshooting or as a fallback.

### Other LaTeX Errors

You might need additional LaTeX packages depending on your document content:

```
# macOS
tlmgr install <package-name>

# Ubuntu/Debian
sudo apt-get install texlive-latex-extra
```

## License

This script is provided under the MIT License. Feel free to modify and distribute it as needed.
