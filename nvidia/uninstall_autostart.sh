#!/bin/bash

# NVIDIA 股价监控 - 开机自启动卸载脚本

PLIST_FILE="com.user.nvda-price-monitor.plist"
PLIST_DEST="${HOME}/Library/LaunchAgents/${PLIST_FILE}"

echo "=== NVIDIA (NVDA) 股价监控 - 开机自启动卸载 ==="
echo ""

# 检查是否已安装
if [ ! -f "$PLIST_DEST" ]; then
    echo "未检测到已安装的LaunchAgent"
    echo "配置文件不存在: $PLIST_DEST"
    exit 0
fi

# 卸载LaunchAgent
launchctl unload "$PLIST_DEST" 2>/dev/null

# 删除plist文件
rm -f "$PLIST_DEST"

if [ $? -eq 0 ]; then
    echo "✓ 开机自启动已成功卸载"
    echo ""
    echo "注意: 日志文件保留在 ~/git/sh/nvidia/logs/ 目录"
    echo "如需删除日志，请手动执行: rm -rf ~/git/sh/nvidia/logs/"
else
    echo "✗ 卸载失败"
    exit 1
fi
