#!/bin/bash

# 台湾经济数据监控 - 卸载开机自启动脚本

LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
TARGET_PLIST="${LAUNCH_AGENTS_DIR}/com.user.tw-economy-monitor.plist"

echo "开始卸载台湾经济数据监控开机自启动..."

if [ -f "${TARGET_PLIST}" ]; then
    # 卸载服务
    launchctl unload "${TARGET_PLIST}" 2>/dev/null

    # 删除配置文件
    rm "${TARGET_PLIST}"

    if [ $? -eq 0 ]; then
        echo "✓ 开机自启动已成功卸载"
    else
        echo "✗ 配置文件删除失败"
        exit 1
    fi
else
    echo "⚠ 未找到配置文件，可能未安装或已被删除"
fi
