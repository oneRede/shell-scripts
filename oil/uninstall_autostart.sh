#!/bin/bash

PLIST_FILE="com.user.oil-price-monitor.plist"
PLIST_DEST="${HOME}/Library/LaunchAgents/${PLIST_FILE}"

echo "=== 原油价格监控 - 开机自启动卸载 ==="
echo ""

if [ ! -f "$PLIST_DEST" ]; then
    echo "未找到已安装的LaunchAgent"
    exit 0
fi

launchctl unload "$PLIST_DEST" 2>/dev/null
rm -f "$PLIST_DEST"

echo "✓ 开机自启动已卸载"
