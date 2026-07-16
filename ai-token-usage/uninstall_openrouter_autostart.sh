#!/bin/bash

# OpenRouter 爬虫自启动卸载脚本

LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
TARGET_PLIST="${LAUNCH_AGENTS_DIR}/com.user.openrouter-scraper.plist"

echo "=========================================="
echo "OpenRouter 爬虫 - 卸载自启动"
echo "=========================================="
echo ""

# 检查服务是否安装
if [ ! -f "${TARGET_PLIST}" ]; then
    echo "服务未安装，无需卸载"
    exit 0
fi

# 卸载服务
launchctl unload "${TARGET_PLIST}" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ 服务已卸载"
else
    echo "⚠️  服务可能未在运行"
fi

# 删除 plist 文件
rm -f "${TARGET_PLIST}"
echo "✓ 已删除配置文件"

echo ""
echo "卸载完成！"
echo "历史数据保留在 logs/openrouter/ 目录中"
echo "=========================================="
