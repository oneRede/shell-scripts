#!/bin/bash

# OpenRouter 爬虫自启动安装脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_FILE="${SCRIPT_DIR}/com.user.openrouter-scraper.plist"
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
TARGET_PLIST="${LAUNCH_AGENTS_DIR}/com.user.openrouter-scraper.plist"

echo "=========================================="
echo "OpenRouter 爬虫 - 安装自启动"
echo "=========================================="
echo ""

# 创建 LaunchAgents 目录
mkdir -p "${LAUNCH_AGENTS_DIR}"

# 检查 plist 文件
if [ ! -f "${PLIST_FILE}" ]; then
    echo "❌ 错误: 找不到 plist 配置文件"
    exit 1
fi

# 卸载旧的（如果存在）
if [ -f "${TARGET_PLIST}" ]; then
    echo "检测到已安装的版本，正在卸载..."
    launchctl unload "${TARGET_PLIST}" 2>/dev/null
    rm -f "${TARGET_PLIST}"
fi

# 复制 plist 文件
cp "${PLIST_FILE}" "${TARGET_PLIST}"
echo "✓ 已复制配置文件到 ${TARGET_PLIST}"

# 加载服务
launchctl load "${TARGET_PLIST}"

if [ $? -eq 0 ]; then
    echo "✓ 服务已加载成功"
    echo ""
    echo "配置信息:"
    echo "  - 运行时间: 每天 10:00（监控前一天数据）"
    echo "  - 开机运行: 是（延迟10分钟）"
    echo "  - 脚本路径: ${SCRIPT_DIR}/scrape_openrouter.sh"
    echo "  - 日志目录: ${SCRIPT_DIR}/logs/openrouter/"
    echo ""
    echo "查看服务状态:"
    echo "  launchctl list | grep openrouter"
    echo ""
    echo "手动触发运行:"
    echo "  launchctl start com.user.openrouter-scraper"
    echo ""
    echo "查看日志:"
    echo "  tail -f ${SCRIPT_DIR}/logs/openrouter_launchd_output.log"
    echo ""
    echo "卸载服务:"
    echo "  cd ${SCRIPT_DIR} && ./uninstall_openrouter_autostart.sh"
else
    echo "❌ 服务加载失败"
    exit 1
fi

echo "=========================================="
