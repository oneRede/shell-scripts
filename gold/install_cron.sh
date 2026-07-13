#!/bin/bash

# 黄金价格监控 - Cron任务安装脚本

SCRIPT_PATH="/Users/rede/git/sh/gold/get_gold_price.sh"
CRON_COMMAND="*/10 * * * * ${SCRIPT_PATH} >> /Users/rede/git/sh/gold/logs/cron.log 2>&1"

echo "=== 黄金价格监控 - Cron任务安装 ==="
echo ""

# 检查脚本是否存在
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "错误: 脚本文件不存在: $SCRIPT_PATH"
    exit 1
fi

# 检查脚本是否有执行权限
if [ ! -x "$SCRIPT_PATH" ]; then
    echo "添加执行权限..."
    chmod +x "$SCRIPT_PATH"
fi

# 检查是否已经存在相同的cron任务
if crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH" > /dev/null; then
    echo "检测到现有的cron任务："
    crontab -l | grep -F "$SCRIPT_PATH"
    echo ""
    read -p "是否要替换现有任务? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消安装"
        exit 0
    fi
    # 删除现有任务
    crontab -l | grep -v -F "$SCRIPT_PATH" | crontab -
fi

# 添加新的cron任务
(crontab -l 2>/dev/null; echo "$CRON_COMMAND") | crontab -

echo ""
echo "✓ Cron任务已安装成功！"
echo ""
echo "任务详情："
echo "  时间: 每10分钟运行一次"
echo "  脚本: $SCRIPT_PATH"
echo "  日志: /Users/rede/git/sh/gold/logs/"
echo ""
echo "当前的crontab配置："
crontab -l | grep -F "$SCRIPT_PATH"
echo ""
echo "查看日志命令:"
echo "  tail -f ~/git/sh/gold/logs/gold_price_\$(date +%Y%m%d).log"
echo ""
echo "卸载命令:"
echo "  ~/git/sh/gold/uninstall_cron.sh"
echo ""
