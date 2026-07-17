#!/bin/bash

# 美国经济数据监控 - 安装开机自启动脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_FILE="${SCRIPT_DIR}/com.user.us-economy-monitor.plist"
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
PLIST_DEST="${LAUNCH_AGENTS_DIR}/com.user.us-economy-monitor.plist"

echo "开始安装美国经济数据监控开机自启动..."

# 确保 LaunchAgents 目录存在
mkdir -p "${LAUNCH_AGENTS_DIR}"

# 复制 plist 文件
cp "${PLIST_FILE}" "${PLIST_DEST}"
echo "✓ 已复制配置文件到: ${PLIST_DEST}"

# 加载 launchd 任务
launchctl unload "${PLIST_DEST}" 2>/dev/null  # 先卸载（如果存在）
launchctl load "${PLIST_DEST}"

if [ $? -eq 0 ]; then
    echo "✓ 开机自启动安装成功！"
    echo ""
    echo "配置信息："
    echo "  - 任务标识: com.user.us-economy-monitor"
    echo "  - 运行时间: 每周一上午 9:00"
    echo "  - 开机启动: 是"
    echo "  - 数据文件: ${SCRIPT_DIR}/data/us_economy_data.csv"
    echo "  - 日志目录: ${SCRIPT_DIR}/logs/"
    echo ""
    echo "管理命令："
    echo "  - 查看状态: launchctl list | grep us-economy"
    echo "  - 立即运行: launchctl start com.user.us-economy-monitor"
    echo "  - 卸载服务: ${SCRIPT_DIR}/uninstall_autostart.sh"
    echo ""
    echo "首次运行："
    echo "  ${SCRIPT_DIR}/get_us_economy.sh"
else
    echo "✗ 安装失败，请检查错误信息"
    exit 1
fi
