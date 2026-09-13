#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
PRODUCTS_DIR="$BUILD_DIR/.products"
APP_BUNDLE="$PRODUCTS_DIR/新建文本.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
EXTENSION_BUNDLE="$APP_CONTENTS/PlugIns/NewTextFinderExtension.appex"
EXTENSION_CONTENTS="$EXTENSION_BUNDLE/Contents"
SDK_PATH="$(xcrun --sdk macosx --show-sdk-path)"
ARCH_NAME="$(uname -m)"
TARGET="$ARCH_NAME-apple-macosx26.0"

if [[ "$ARCH_NAME" != "arm64" && "$ARCH_NAME" != "x86_64" ]]; then
    print -u2 "不支持的处理器架构：$ARCH_NAME"
    exit 1
fi

if [[ -d "$APP_BUNDLE" ]]; then
    /usr/bin/pluginkit -r "$EXTENSION_BUNDLE" >/dev/null 2>&1 || true
fi

rm -rf "$APP_BUNDLE"
mkdir -p \
    "$APP_CONTENTS/MacOS" \
    "$APP_CONTENTS/Resources" \
    "$EXTENSION_CONTENTS/MacOS" \
    "$EXTENSION_CONTENTS/Resources"

cp "$ROOT_DIR/Resources/AppInfo.plist" "$APP_CONTENTS/Info.plist"
cp "$ROOT_DIR/Resources/ExtensionInfo.plist" "$EXTENSION_CONTENTS/Info.plist"

swiftc \
    -sdk "$SDK_PATH" \
    -target "$TARGET" \
    -O \
    -whole-module-optimization \
    -module-name NewText \
    "$ROOT_DIR/Sources/App/AppModel.swift" \
    "$ROOT_DIR/Sources/App/ContentView.swift" \
    "$ROOT_DIR/Sources/App/NewTextApp.swift" \
    -framework AppKit \
    -framework FinderSync \
    -framework SwiftUI \
    -o "$APP_CONTENTS/MacOS/NewText"

swiftc \
    -sdk "$SDK_PATH" \
    -target "$TARGET" \
    -O \
    -whole-module-optimization \
    -parse-as-library \
    -module-name NewTextFinderExtension \
    "$ROOT_DIR/Sources/Core/NewTextFileCreator.swift" \
    "$ROOT_DIR/Sources/FinderExtension/MenuIconFactory.swift" \
    "$ROOT_DIR/Sources/FinderExtension/PreferredEditor.swift" \
    "$ROOT_DIR/Sources/FinderExtension/FinderSync.swift" \
    -framework AppKit \
    -framework FinderSync \
    -Xlinker -e \
    -Xlinker _NSExtensionMain \
    -o "$EXTENSION_CONTENTS/MacOS/NewTextFinderExtension"

ICONSET_DIR="$BUILD_DIR/AppIcon.iconset"
rm -rf "$ICONSET_DIR"
swift "$ROOT_DIR/Scripts/GenerateIcon.swift" "$ICONSET_DIR"
iconutil -c icns "$ICONSET_DIR" -o "$APP_CONTENTS/Resources/AppIcon.icns"
rm -rf "$ICONSET_DIR"

codesign \
    --force \
    --sign - \
    --timestamp=none \
    --entitlements "$ROOT_DIR/Resources/Extension.entitlements" \
    "$EXTENSION_BUNDLE"

codesign \
    --force \
    --sign - \
    --timestamp=none \
    "$APP_BUNDLE"

codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"
print "构建完成：$APP_BUNDLE"
