#!/bin/bash

# 卸载IP记录开机启动项

PLIST_FILE="com.user.recordip.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

echo "正在卸载IP记录开机启动项..."

# 卸载启动项
launchctl unload "$LAUNCH_AGENTS_DIR/$PLIST_FILE" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ 启动项已卸载"
else
    echo "⚠ 启动项可能未加载或已经卸载"
fi

# 删除plist文件
rm -f "$LAUNCH_AGENTS_DIR/$PLIST_FILE"

if [ $? -eq 0 ]; then
    echo "✓ plist文件已删除"
    echo ""
    echo "卸载完成！"
else
    echo "✗ 删除plist文件失败"
    exit 1
fi
