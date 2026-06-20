#!/bin/bash
# Build SPERG.app — compiles main.swift and assembles a menu-bar .app bundle.
set -euo pipefail

cd "$(dirname "$0")"

APP="SPERG.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "Cleaning previous build..."
rm -rf "$APP"
mkdir -p "$MACOS" "$RESOURCES"

echo "Compiling..."
swiftc -O Sources/main.swift -o "$MACOS/SPERG"

echo "Assembling bundle..."
cp Info.plist "$CONTENTS/Info.plist"

echo "Building app icon..."
./makeicon.sh "$RESOURCES/AppIcon.icns"

# Ad-hoc codesign so Gatekeeper/IOKit are happy on the local machine.
codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || \
    echo "  (codesign skipped — unsigned bundle still runs locally)"

echo "Done -> $APP"
echo "Run with:  open $APP   (or double-click it in Finder)"
