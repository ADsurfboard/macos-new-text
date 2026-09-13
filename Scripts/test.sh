#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_BUILD_DIR="$ROOT_DIR/build/tests"
TEST_EXECUTABLE="$TEST_BUILD_DIR/NewTextCoreTests"
SDK_PATH="$(xcrun --sdk macosx --show-sdk-path)"
ARCH_NAME="$(uname -m)"

mkdir -p "$TEST_BUILD_DIR"

swiftc \
    -sdk "$SDK_PATH" \
    -target "$ARCH_NAME-apple-macosx26.0" \
    "$ROOT_DIR/Sources/Core/NewTextFileCreator.swift" \
    "$ROOT_DIR/Tests/NewTextCoreTests.swift" \
    -o "$TEST_EXECUTABLE"

"$TEST_EXECUTABLE"

ICON_TEST_EXECUTABLE="$TEST_BUILD_DIR/MenuIconTests"
swiftc \
    -sdk "$SDK_PATH" \
    -target "$ARCH_NAME-apple-macosx26.0" \
    "$ROOT_DIR/Sources/FinderExtension/MenuIconFactory.swift" \
    "$ROOT_DIR/Tests/MenuIconTests.swift" \
    -framework AppKit \
    -o "$ICON_TEST_EXECUTABLE"

"$ICON_TEST_EXECUTABLE"
