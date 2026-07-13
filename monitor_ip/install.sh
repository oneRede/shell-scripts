#!/bin/bash

# 安装IP记录开机启动项

SCRIPT_DIR="$HOME/git/sh/monitor_ip"
PLIST_FILE="com.user.recordip.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

echo "正在安装IP记录开机启动项..."

# 创建LaunchAgents目录（如果不存在）
mkdir -p "$LAUNCH_AGENTS_DIR"

# 复制plist文件到LaunchAgents目录
cp "$SCRIPT_DIR/$PLIST_FILE" "$LAUNCH_AGENTS_DIR/$PLIST_FILE"

if [ $? -eq 0 ]; then
    echo "✓ plist文件已复制到 $LAUNCH_AGENTS_DIR"
else
    echo "✗ 复制plist文件失败"
    exit 1
fi

# 加载启动项
launchctl load "$LAUNCH_AGENTS_DIR/$PLIST_FILE"

if [ $? -eq 0 ]; then
    echo "✓ 启动项已加载"
    echo ""
    echo "安装完成！脚本将在每次开机时自动运行。"
    echo ""
    echo "日志文件位置: $SCRIPT_DIR/logs/ip_history.log"
    echo ""
    echo "可以使用以下命令查看状态："
    echo "  launchctl list | grep recordip"
    echo ""
    echo "如需卸载，请运行: ./uninstall.sh"
else
    echo "✗ 加载启动项失败"
    echo "可能的原因："
    echo "  1. 启动项已经加载（尝试先运行 ./uninstall.sh）"
    echo "  2. plist文件格式错误"
    exit 1
fi
