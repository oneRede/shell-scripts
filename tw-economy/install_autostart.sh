#!/bin/bash

# 台湾经济数据监控 - 开机自启动安装脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_FILE="${SCRIPT_DIR}/com.user.tw-economy-monitor.plist"
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
TARGET_PLIST="${LAUNCH_AGENTS_DIR}/com.user.tw-economy-monitor.plist"

echo "开始安装台湾经济数据监控开机自启动..."

# 创建 LaunchAgents 目录（如果不存在）
mkdir -p "${LAUNCH_AGENTS_DIR}"

# 复制 plist 文件
cp "${PLIST_FILE}" "${TARGET_PLIST}"

if [ $? -eq 0 ]; then
    echo "✓ 已复制配置文件到: ${TARGET_PLIST}"

    # 加载服务
    launchctl unload "${TARGET_PLIST}" 2>/dev/null
    launchctl load "${TARGET_PLIST}"

    if [ $? -eq 0 ]; then
        echo "✓ 开机自启动安装成功！"
        echo ""
        echo "配置信息："
        echo "  - 任务标识: com.user.tw-economy-monitor"
        echo "  - 运行时间: 每周一上午 9:00"
        echo "  - 开机启动: 是"
        echo "  - 数据文件: ${SCRIPT_DIR}/data/tw_economy_data.csv"
        echo "  - 日志目录: ${SCRIPT_DIR}/logs/"
        echo ""
        echo "管理命令："
        echo "  - 查看状态: launchctl list | grep tw-economy"
        echo "  - 立即运行: launchctl start com.user.tw-economy-monitor"
        echo "  - 卸载服务: ${SCRIPT_DIR}/uninstall_autostart.sh"
        echo ""
        echo "首次使用："
        echo "  1. 运行 ${SCRIPT_DIR}/update_data.sh 手动输入最新数据"
        echo "  2. 运行 ${SCRIPT_DIR}/get_tw_economy.sh 记录数据"
    else
        echo "✗ 服务加载失败"
        exit 1
    fi
else
    echo "✗ 配置文件复制失败"
    exit 1
fi
