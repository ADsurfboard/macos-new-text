#!/bin/zsh
set -euo pipefail

INSTALLED_APP="$HOME/Applications/新建文本.app"
EXTENSION_ID="com.zhangshao.NewText.FinderExtension"

/usr/bin/pluginkit -e ignore -i "$EXTENSION_ID" >/dev/null 2>&1 || true

if [[ -d "$INSTALLED_APP" ]]; then
    /usr/bin/pluginkit -r "$INSTALLED_APP/Contents/PlugIns/NewTextFinderExtension.appex" >/dev/null 2>&1 || true
    TRASH_DESTINATION="$HOME/.Trash/新建文本-$(date +%Y%m%d-%H%M%S).app"
    mv "$INSTALLED_APP" "$TRASH_DESTINATION"
    print "应用已移入废纸篓：$TRASH_DESTINATION"
else
    print "未找到已安装的应用。"
fi

/usr/bin/killall Finder >/dev/null 2>&1 || true

