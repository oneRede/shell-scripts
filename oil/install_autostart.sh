#!/bin/bash

# 原油价格监控 - 开机自启动安装脚本

PLIST_FILE="com.user.oil-price-monitor.plist"
PLIST_SOURCE="/Users/rede/git/sh/oil/${PLIST_FILE}"
PLIST_DEST="${HOME}/Library/LaunchAgents/${PLIST_FILE}"

echo "=== 原油价格监控 - 开机自启动安装 ==="
echo ""

if [ ! -f "$PLIST_SOURCE" ]; then
    echo "错误: plist文件不存在: $PLIST_SOURCE"
    exit 1
fi

mkdir -p "${HOME}/Library/LaunchAgents"

if [ -f "$PLIST_DEST" ]; then
    echo "检测到已安装的LaunchAgent，正在重新安装..."
    launchctl unload "$PLIST_DEST" 2>/dev/null
    rm -f "$PLIST_DEST"
fi

cp "$PLIST_SOURCE" "$PLIST_DEST"
launchctl load "$PLIST_DEST"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ 开机自启动已安装成功！"
    echo ""
    echo "配置详情："
    echo "  服务名称: com.user.oil-price-monitor"
    echo "  运行频率: 每小时一次"
    echo "  配置文件: $PLIST_DEST"
    echo ""
    echo "正在测试运行..."
    ~/git/sh/oil/get_oil_price.sh
else
    echo ""
    echo "✗ 安装失败"
    exit 1
fi
