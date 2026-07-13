#!/bin/bash

# 黄金价格监控 - Cron任务卸载脚本

SCRIPT_PATH="/Users/rede/git/sh/gold/get_gold_price.sh"

echo "=== 黄金价格监控 - Cron任务卸载 ==="
echo ""

# 检查是否存在cron任务
if ! crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH" > /dev/null; then
    echo "未找到相关的cron任务"
    exit 0
fi

echo "找到以下cron任务："
crontab -l | grep -F "$SCRIPT_PATH"
echo ""

read -p "确认要删除此任务吗? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    crontab -l | grep -v -F "$SCRIPT_PATH" | crontab -
    echo ""
    echo "✓ Cron任务已删除"
    echo ""
    echo "注意: 日志文件仍保留在 ~/git/sh/gold/logs/"
else
    echo "取消卸载"
fi
