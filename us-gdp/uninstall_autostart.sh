#!/bin/bash

# 美国经济数据监控 - 卸载开机自启动脚本

PLIST_DEST="${HOME}/Library/LaunchAgents/com.user.us-economy-monitor.plist"

echo "开始卸载美国经济数据监控开机自启动..."

if [ -f "${PLIST_DEST}" ]; then
    # 卸载 launchd 任务
    launchctl unload "${PLIST_DEST}" 2>/dev/null

    # 删除 plist 文件
    rm "${PLIST_DEST}"

    echo "✓ 开机自启动已成功卸载！"
    echo ""
    echo "注意："
    echo "  - 数据文件和日志未被删除"
    echo "  - 如需重新安装，请运行: ./install_autostart.sh"
else
    echo "✗ 未找到已安装的服务"
    exit 1
fi
