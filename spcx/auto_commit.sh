#!/bin/bash

# SPCX 股价自动提交到 GitHub 脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/../.."

# 检查是否在git仓库中
if [ ! -d .git ]; then
    echo "错误: 不在git仓库中"
    exit 1
fi

# 添加文件
git add spcx/logs/spcx_price.csv spcx/logs/spcx_price_*.log

# 检查是否有变更
if git diff --cached --quiet; then
    echo "没有新的数据需要提交"
    exit 0
fi

# 获取最新价格
LATEST_PRICE=$(tail -1 spcx/logs/spcx_price.csv | cut -d',' -f2)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 提交
git commit -m "Update SPCX stock data: \$${LATEST_PRICE} - ${TIMESTAMP}"

# 推送
git push origin main || git push origin master

echo "✓ 已推送到 GitHub"
