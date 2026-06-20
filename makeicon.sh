#!/bin/bash
# makeicon.sh — build AppIcon.icns from makeicon.swift.
# Usage: ./makeicon.sh <output.icns>
set -euo pipefail
cd "$(dirname "$0")"

OUT="${1:-AppIcon.icns}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

swiftc -O makeicon.swift -o "$TMP/makeicon"
"$TMP/makeicon" "$TMP/master.png"

ICONSET="$TMP/AppIcon.iconset"
mkdir -p "$ICONSET"
sizes=(16 32 128 256 512)
for s in "${sizes[@]}"; do
    s2=$((s * 2))
    sips -z "$s"  "$s"  "$TMP/master.png" --out "$ICONSET/icon_${s}x${s}.png"     >/dev/null
    sips -z "$s2" "$s2" "$TMP/master.png" --out "$ICONSET/icon_${s}x${s}@2x.png"  >/dev/null
done

iconutil -c icns "$ICONSET" -o "$OUT"
echo "Wrote $OUT"
