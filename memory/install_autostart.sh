#!/bin/bash

# 存储器价格监控 - 开机自启动安装脚本

PLIST_FILE="com.user.memory-price-monitor.plist"
PLIST_SOURCE="/Users/rede/git/sh/memory/${PLIST_FILE}"
PLIST_DEST="${HOME}/Library/LaunchAgents/${PLIST_FILE}"

echo "=== 存储器价格监控 - 开机自启动安装 ==="
echo ""

# 检查plist文件是否存在
if [ ! -f "$PLIST_SOURCE" ]; then
    echo "错误: plist文件不存在: $PLIST_SOURCE"
    exit 1
fi

# 创建LaunchAgents目录（如果不存在）
mkdir -p "${HOME}/Library/LaunchAgents"

# 检查是否已经安装
if [ -f "$PLIST_DEST" ]; then
    echo "检测到已安装的LaunchAgent"
    echo ""
    read -p "是否要重新安装? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消安装"
        exit 0
    fi
    # 先卸载现有的
    launchctl unload "$PLIST_DEST" 2>/dev/null
    rm -f "$PLIST_DEST"
fi

# 复制plist文件到LaunchAgents目录
cp "$PLIST_SOURCE" "$PLIST_DEST"

# 加载LaunchAgent
launchctl load "$PLIST_DEST"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ 开机自启动已安装成功！"
    echo ""
    echo "配置详情："
    echo "  服务名称: com.user.memory-price-monitor"
    echo "  运行频率: 每天上午9点"
    echo "  开机启动: 是"
    echo "  币种: 人民币 (CNY)"
    echo "  配置文件: $PLIST_DEST"
    echo "  日志目录: /Users/rede/git/sh/memory/logs/"
    echo ""
    echo "查看服务状态："
    echo "  launchctl list | grep memory-price"
    echo ""
    echo "查看日志："
    echo "  tail -f ~/git/sh/memory/logs/launchd.out.log"
    echo "  tail -f ~/git/sh/memory/logs/launchd.err.log"
    echo ""
    echo "卸载命令："
    echo "  ~/git/sh/memory/uninstall_autostart.sh"
    echo ""

    # 立即运行一次测试
    echo "正在测试运行..."
    ~/git/sh/memory/get_memory_price.sh

else
    echo ""
    echo "✗ 安装失败"
    exit 1
fi
