#!/bin/bash

# 碳酸锂价格监控 - 开机自启动卸载脚本

PLIST_FILE="com.user.lithium-price-monitor.plist"
PLIST_DEST="${HOME}/Library/LaunchAgents/${PLIST_FILE}"

echo "=== 碳酸锂价格监控 - 开机自启动卸载 ==="
echo ""

# 检查是否已安装
if [ ! -f "$PLIST_DEST" ]; then
    echo "未找到已安装的LaunchAgent"
    exit 0
fi

echo "找到以下LaunchAgent配置："
echo "  $PLIST_DEST"
echo ""

read -p "确认要卸载开机自启动吗? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 卸载LaunchAgent
    launchctl unload "$PLIST_DEST" 2>/dev/null

    # 删除plist文件
    rm -f "$PLIST_DEST"

    echo ""
    echo "✓ 开机自启动已卸载"
    echo ""
    echo "注意: "
    echo "  - 脚本文件仍保留在 ~/git/sh/lithium/"
    echo "  - 日志文件仍保留在 ~/git/sh/lithium/logs/"
else
    echo "取消卸载"
fi
