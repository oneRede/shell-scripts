#!/bin/bash

# 存储器价格监控 - 开机自启动卸载脚本

PLIST_FILE="com.user.memory-price-monitor.plist"
PLIST_DEST="${HOME}/Library/LaunchAgents/${PLIST_FILE}"

echo "=== 存储器价格监控 - 开机自启动卸载 ==="
echo ""

# 检查是否已安装
if [ ! -f "$PLIST_DEST" ]; then
    echo "未检测到已安装的LaunchAgent"
    echo "配置文件不存在: $PLIST_DEST"
    exit 0
fi

# 卸载LaunchAgent
echo "正在卸载LaunchAgent..."
launchctl unload "$PLIST_DEST" 2>/dev/null

# 删除plist文件
rm -f "$PLIST_DEST"

if [ ! -f "$PLIST_DEST" ]; then
    echo ""
    echo "✓ 开机自启动已成功卸载！"
    echo ""
    echo "如需重新安装，请运行："
    echo "  ~/git/sh/memory/install_autostart.sh"
    echo ""
else
    echo ""
    echo "✗ 卸载失败"
    exit 1
fi
