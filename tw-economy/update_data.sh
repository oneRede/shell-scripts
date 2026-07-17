#!/bin/bash

# 台湾经济数据手动更新脚本
# 用于手动输入最新的经济数据

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/data"

echo "=========================================="
echo "  台湾经济数据手动更新工具"
echo "=========================================="
echo ""
echo "数据来源建议："
echo "  - GDP增长率：台湾主计总处 https://www.stat.gov.tw/"
echo "  - 出口/进口：财政部关务署 https://web.customs.gov.tw/"
echo ""

# 更新 GDP 数据
echo ">>> 更新 GDP 增长率"
read -p "请输入 GDP 增长率（年增率，%）: " gdp_rate
read -p "请输入数据期间（格式：2024-Q1）: " gdp_period
if [ -n "$gdp_rate" ] && [ -n "$gdp_period" ]; then
    echo "${gdp_rate},${gdp_period}" > "${DATA_DIR}/.gdp_cache"
    echo "✓ GDP 数据已更新"
fi

echo ""

# 更新出口数据
echo ">>> 更新出口额"
read -p "请输入出口额（百万美元）: " exports_million
read -p "请输入数据月份（格式：2024-06）: " exports_period
if [ -n "$exports_million" ] && [ -n "$exports_period" ]; then
    exports_yi=$(python3 -c "print(f'{float($exports_million) / 100:.2f}')")
    echo "${exports_yi},${exports_period}" > "${DATA_DIR}/.exports_cache"
    echo "✓ 出口数据已更新（${exports_yi}亿美元）"
fi

echo ""

# 更新进口数据
echo ">>> 更新进口额"
read -p "请输入进口额（百万美元）: " imports_million
read -p "请输入数据月份（格式：2024-06）: " imports_period
if [ -n "$imports_million" ] && [ -n "$imports_period" ]; then
    imports_yi=$(python3 -c "print(f'{float($imports_million) / 100:.2f}')")
    echo "${imports_yi},${imports_period}" > "${DATA_DIR}/.imports_cache"
    echo "✓ 进口数据已更新（${imports_yi}亿美元）"
fi

echo ""
echo "=========================================="
echo "数据更新完成！"
echo "现在可以运行 ./get_tw_economy.sh 来记录这些数据"
echo "=========================================="
