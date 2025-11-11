#!/bin/bash

# Zippy DMG Build Script
# Creates a distributable DMG file for the Zippy macOS application

set -e  # Exit on any error

echo "🚀 Building Zippy for distribution..."

# Configuration
APP_NAME="Zippy"
VERSION="1.0.0"
BUILD_DIR=".build/release"
APP_DIR="${APP_NAME}.app"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
VOLUME_NAME="${APP_NAME} ${VERSION}"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "${APP_DIR}"
rm -f "${DMG_NAME}"

# Build the application
echo "🔨 Building application..."
swift build --configuration release

# Create app bundle structure
echo "📦 Creating app bundle..."
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

# Copy executable
echo "📋 Copying executable..."
cp "${BUILD_DIR}/${APP_NAME}" "${APP_DIR}/Contents/MacOS/"

# Copy resources
echo "🎨 Copying resources..."
if [ -d "Sources/Resources" ]; then
    cp -r "Sources/Resources/"* "${APP_DIR}/Contents/Resources/" 2>/dev/null || true
fi

# Create Info.plist
echo "📄 Creating Info.plist..."
cat > "${APP_DIR}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.zippy.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 Zippy. All rights reserved.</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>ZIP Archive</string>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>zip</string>
            </array>
            <key>CFBundleTypeIconFile</key>
            <string>AppIcon</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Default</string>
        </dict>
    </array>
</dict>
</plist>
EOF

# Set executable permissions
echo "🔧 Setting permissions..."
chmod +x "${APP_DIR}/Contents/MacOS/${APP_NAME}"

# Create DMG
echo "💿 Creating DMG file..."
# Create a temporary disk image
hdiutil create -volname "${VOLUME_NAME}" -srcfolder "${APP_DIR}" -ov -format UDZO "${DMG_NAME}"

echo "✅ Build complete!"
echo "📁 DMG created: ${DMG_NAME}"
echo "📏 DMG size: $(du -h "${DMG_NAME}" | cut -f1)"

# Verify the app bundle
echo "🔍 Verifying app bundle..."
if [ -f "${APP_DIR}/Contents/MacOS/${APP_NAME}" ]; then
    echo "✅ Executable found"
else
    echo "❌ Executable missing"
    exit 1
fi

if [ -f "${APP_DIR}/Contents/Info.plist" ]; then
    echo "✅ Info.plist found"
else
    echo "❌ Info.plist missing"
    exit 1
fi

echo ""
echo "🎉 Zippy is ready for distribution!"
echo "   DMG: ${DMG_NAME}"
echo "   Size: $(du -h "${DMG_NAME}" | cut -f1)"
echo ""
echo "To install: Open the DMG and drag Zippy.app to your Applications folder."