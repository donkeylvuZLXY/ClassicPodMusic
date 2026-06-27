#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
PAYLOAD_DIR="$BUILD_DIR/Payload"
OUTPUT_DIR="$ROOT_DIR/dist"
APP_NAME="ClassicPodMusic"

rm -rf "$BUILD_DIR" "$OUTPUT_DIR"
mkdir -p "$PAYLOAD_DIR" "$OUTPUT_DIR"

xcodebuild \
  -project "$ROOT_DIR/ClassicPodMusic.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath "$BUILD_DIR/DerivedData" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build

APP_PATH="$BUILD_DIR/DerivedData/Build/Products/Release-iphoneos/$APP_NAME.app"

if [ ! -d "$APP_PATH" ]; then
  echo "Build completed, but $APP_PATH was not found."
  exit 1
fi

cp -R "$APP_PATH" "$PAYLOAD_DIR/"
cd "$BUILD_DIR"
zip -qry "$OUTPUT_DIR/$APP_NAME-unsigned.ipa" Payload

echo "Unsigned IPA created at: $OUTPUT_DIR/$APP_NAME-unsigned.ipa"
