#!/bin/bash
# Build a local macOS .app launcher for InspirationBar.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="InspirationBar"
BUNDLE_ID="com.chaomusstudio.inspirationbar"
DIST_DIR="$PROJECT_DIR/.."
APP_DIR="$DIST_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ICONSET_DIR="$DIST_DIR/AppIcon.iconset"

cd "$PROJECT_DIR"

stop_running_app() {
    local pids
    pids="$(pgrep -x "$APP_NAME" || true)"
    if [[ -z "$pids" ]]; then
        return
    fi

    echo "==> Stopping running $APP_NAME: $pids"
    pkill -x "$APP_NAME" || true

    for _ in {1..20}; do
        if ! pgrep -x "$APP_NAME" >/dev/null; then
            return
        fi
        sleep 0.2
    done

    echo "==> Force stopping $APP_NAME"
    pkill -9 -x "$APP_NAME" || true
    sleep 0.2
}

stop_running_app

echo "==> Building $APP_NAME"
swift build -c release

echo "==> Creating app bundle"
stop_running_app
rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp ".build/release/$APP_NAME" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

echo "==> Creating app icon"
rm -rf "$ICONSET_DIR"
swift "$PROJECT_DIR/tools/make_app_icon.swift" "$ICONSET_DIR"
iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"

cat > "$CONTENTS_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>InspirationBar</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>MIT License</string>
</dict>
</plist>
PLIST

printf "APPL????" > "$CONTENTS_DIR/PkgInfo"

echo ""
echo "Done: $APP_DIR"
echo "Tip: double-click it, or drag it to the Dock as a launcher."
