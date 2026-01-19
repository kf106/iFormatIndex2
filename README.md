# Index Formatter Extension for LibreOffice Writer

This extension provides a macro to format index entries in LibreOffice Writer documents.

## Building the Extension

Run the build script to create the .oxt file:

```bash
./build_extension.sh
```

This will create `format_index2-<version>.oxt` in the parent directory, where 'version' is set in the script.

## Installation

1. Open LibreOffice Writer
2. Go to **Tools → Extension Manager**
3. Click **Add...**
4. Select the `format_index2-1.0.0.oxt` file
5. Click **Accept** when prompted
6. Restart LibreOffice if prompted

Or just double-click on the extension file.

## Usage

After installation, the macro appears at the bottom of the **Tools** menu as "Index Formatter"

The extension assumes your index uses **Index 2** and **Index 1** paragraphs, and that redirection index entries are added to the top of the first page of the index.

## What it does

1. Finds the index start page from the first Index 1 or Index 2 paragraph
2. Removes target page numbers from Index 1 and Index 2 paragraphs where unnecessary
3. Removes trailing tabs from Index 1 paragraphs
4. Applies italic formatting to "see" and "see also" in Index 2 paragraphs
5. Removes tab and page number from "see"/"see also" entries
6. Bubbles "see also" entries to the bottom of Index 2 blocks

## Uninstallation

1. Go to **Tools → Extension Manager**
2. Select "Format Index 2 Paragraphs"
3. Click **Remove**
4. Restart LibreOffice if prompted

## Notes
Only tested on Ubuntu 24.04
