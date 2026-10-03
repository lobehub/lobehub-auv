#!/bin/sh
# Builds "<output>/LobeHub Computer Use.icns" from icon/app-stable.embedded.svg.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
output=${1:-"$root/build/icon"}
name='LobeHub Computer Use'
work=$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/lobehub-helper-icon.XXXXXX")
trap '/bin/rm -rf "$work"' EXIT

/usr/bin/xcrun swiftc -O "$root/icon/compose.swift" -o "$work/compose"
"$work/compose" "$root/icon/app-stable.embedded.svg" "$work/icon-1024.png"

iconset="$work/$name.iconset"
mkdir -p "$iconset" "$output"
for size in 16 32 128 256 512; do
  /usr/bin/sips -z "$size" "$size" "$work/icon-1024.png" --out "$iconset/icon_${size}x${size}.png" >/dev/null
  double=$((size * 2))
  /usr/bin/sips -z "$double" "$double" "$work/icon-1024.png" --out "$iconset/icon_${size}x${size}@2x.png" >/dev/null
done
/usr/bin/iconutil -c icns "$iconset" -o "$output/$name.icns"
echo "$output/$name.icns"
