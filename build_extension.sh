#!/usr/bin/env bash
set -euo pipefail

# -----------------------
# Config
# -----------------------
EXT_NAME="FormatIndex2"      # used for output filename only
BASE_VERSION="0.2"           # major.minor part of the version; patch/build comes from build_number.txt
LIB_NAME="FormatIndex2"      # TOP-LEVEL folder name inside the .oxt = Basic library name
OUT_DIR="dist"
BUILD_FILE="build_number.txt"
# -----------------------

err() { echo "ERROR: $*" >&2; exit 1; }

# Required source paths (in your project directory)
REQ_FILES=(
  "description.xml"
  "Addons.xcu"
  "META-INF/manifest.xml"
  "${LIB_NAME}/script.xlb"
  "${LIB_NAME}/dialog.xlb"
  "${LIB_NAME}/FormatIndex2.xba"
)

for f in "${REQ_FILES[@]}"; do
  [[ -f "$f" ]] || err "Missing required file: $f"
done

mkdir -p "$OUT_DIR"

STAGE_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t "${EXT_NAME}.XXXXXX")"
cleanup() { rm -rf "$STAGE_DIR"; }
trap cleanup EXIT

# Read and bump build number, then construct full VERSION
if [[ -f "$BUILD_FILE" ]]; then
  BUILD_NUM="$(<"$BUILD_FILE")"
else
  BUILD_NUM="0"
fi

if ! [[ "$BUILD_NUM" =~ ^[0-9]+$ ]]; then
  err "Invalid build number in $BUILD_FILE: '$BUILD_NUM'"
fi

BUILD_NUM=$((BUILD_NUM + 1))
echo "$BUILD_NUM" > "$BUILD_FILE"

VERSION="${BASE_VERSION}.${BUILD_NUM}"

# Create required dirs in staging
mkdir -p "$STAGE_DIR/META-INF" "$STAGE_DIR/$LIB_NAME" "$STAGE_DIR/description"

# Copy core files
cp -f "description.xml" "$STAGE_DIR/description.xml"
cp -f "Addons.xcu" "$STAGE_DIR/Addons.xcu"
cp -f "META-INF/manifest.xml" "$STAGE_DIR/META-INF/manifest.xml"

# Copy description directory if it exists
if [[ -d "description" ]]; then
  cp -rf "description/"* "$STAGE_DIR/description/"
fi

# Copy the Basic library folder as a top-level directory
cp -f "${LIB_NAME}/script.xlb" "$STAGE_DIR/$LIB_NAME/script.xlb"
cp -f "${LIB_NAME}/dialog.xlb" "$STAGE_DIR/$LIB_NAME/dialog.xlb"
cp -f "${LIB_NAME}/FormatIndex2.xba" "$STAGE_DIR/$LIB_NAME/FormatIndex2.xba"

# Optional extras
for extra in LICENSE README.md README.txt description.png icon.png icon.svg; do
  [[ -f "$extra" ]] && cp -f "$extra" "$STAGE_DIR/$extra"
done

# Update version inside staged description.xml (LibreOffice reads version from here)
if sed --version >/dev/null 2>&1; then
  # GNU sed
  sed -i -E "s/<version[[:space:]]+value=\"[^\"]+\"[[:space:]]*\/>/<version value=\"${VERSION}\"\/>/" \
    "$STAGE_DIR/description.xml"
else
  # BSD/macOS sed
  sed -i '' -E "s/<version[[:space:]]+value=\"[^\"]+\"[[:space:]]*\/>/<version value=\"${VERSION}\"\/>/" \
    "$STAGE_DIR/description.xml"
fi

grep -q "<version value=\"${VERSION}\"" "$STAGE_DIR/description.xml" \
  || err "Failed to update version in staged description.xml"

OUT_FILE="${OUT_DIR}/${EXT_NAME}-${VERSION}.oxt"
rm -f "$OUT_FILE"

(
  cd "$STAGE_DIR"
  zip -q -r -9 "$OLDPWD/$OUT_FILE" .
)

echo "Built: $OUT_FILE"
echo "Sanity checks:"
echo "  unzip -l \"$OUT_FILE\" | sed -n '1,60p'"
echo "  unzip -p \"$OUT_FILE\" description.xml | grep -n \"<version\""

