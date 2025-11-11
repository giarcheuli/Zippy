# Zippy - macOS Zip Utility

A modern, native macOS application for managing ZIP archives with a beautiful SwiftUI interface.

## Features

- �️ **Dual-pane Interface**: Browse files on the left, preview ZIP contents on the right
- 📦 **Create Archives**: Compress files and folders into ZIP archives
- � **Extract Archives**: Unzip archives to any location
- 🎯 **Drag & Drop**: Drag files from Finder to create or extract archives
- ⌨️ **Keyboard Shortcuts**: Full keyboard navigation and shortcuts
- 🎨 **Modern UI**: Native macOS design with SwiftUI
- 🔒 **Security**: Input validation and path sanitization
- 📊 **Progress Indicators**: Visual feedback for all operations
- 📋 **Context Menus**: Right-click menus for quick actions
- 📝 **Comprehensive Logging**: Built-in logging for debugging and monitoring

## System Requirements

- macOS 13.0 or later
- No additional dependencies required

## Installation

### Option 1: Pre-built DMG (Recommended)

1. Download `Zippy-1.0.0.dmg` from the releases
2. Open the DMG file
3. Drag `Zippy.app` to your Applications folder
4. Launch Zippy from Applications or Spotlight

### Option 2: Build from Source

```bash
git clone <repository-url>
cd Zippy
swift build --configuration release
./build_dmg.sh  # Creates the DMG package
```

## Usage

### Basic Operations

- **Browse Files**: Use the file browser on the left to navigate your file system
- **Preview ZIP**: Click on any `.zip` file to preview its contents
- **Extract Archive**: Right-click a ZIP file and select "Extract Here" or use `⌘E`
- **Create Archive**: Right-click any file/folder and select "Create Zip Archive" or use `⌘N`

### Keyboard Shortcuts

- `⌘↑` - Go up directory
- `⌘←` / `⌘→` - Navigate back/forward in history
- `⌘R` - Refresh current directory
- `Space` - Preview selected ZIP file
- `⌘N` - Create ZIP from selected item
- `⌘E` - Extract selected ZIP file
- `⌘⇧R` - Global refresh
- `⌘⇧E` - Extract selected ZIP (global)

### Drag & Drop

- Drag ZIP files from Finder onto the file list to extract them
- Drag regular files/folders from Finder onto the file list to create ZIP archives

## Development

Built with:

- Swift 5.9+
- SwiftUI
- ZIPFoundation
- macOS 13.0+ SDK

### Building from Source

```bash
git clone <repository-url>
cd Zippy
swift build --configuration release
```

### Creating Distribution DMG

```bash
./build_dmg.sh
```

This will create `Zippy-1.0.0.dmg` ready for distribution.
