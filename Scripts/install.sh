#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_APP="$ROOT_DIR/build/.products/新建文本.app"
INSTALL_DIRECTORY="$HOME/Applications"
INSTALLED_APP="$INSTALL_DIRECTORY/新建文本.app"
EXTENSION_ID="com.zhangshao.NewText.FinderExtension"

"$ROOT_DIR/Scripts/build.sh"
mkdir -p "$INSTALL_DIRECTORY"

if [[ -d "$INSTALLED_APP" ]]; then
    /usr/bin/pluginkit -r "$INSTALLED_APP/Contents/PlugIns/NewTextFinderExtension.appex" >/dev/null 2>&1 || true
    rm -rf "$INSTALLED_APP"
fi

/usr/bin/ditto "$SOURCE_APP" "$INSTALLED_APP"
/usr/bin/pluginkit -a "$INSTALLED_APP/Contents/PlugIns/NewTextFinderExtension.appex"
/bin/sleep 1
/usr/bin/pluginkit -e use -i "$EXTENSION_ID" || true
/usr/bin/killall Finder >/dev/null 2>&1 || true
/usr/bin/open "$INSTALLED_APP"

print "已安装：$INSTALLED_APP"
print "如应用显示“等待启用”，请点击“打开扩展设置”完成一次性确认。"
