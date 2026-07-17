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
if [ -n "$gdp_rate" ]; then
    echo "${gdp_rate},2026-Q1" > "${DATA_DIR}/.gdp_cache"
    echo "✓ GDP 数据已更新: ${gdp_rate}%"
fi

echo ""

# 更新出口数据
echo ">>> 更新出口额"
read -p "请输入出口额（百万美元）: " exports_million
if [ -n "$exports_million" ]; then
    exports_yi=$(python3 -c "print(f'{float($exports_million) / 100:.2f}')")
    echo "${exports_yi},2026-06" > "${DATA_DIR}/.exports_cache"
    echo "✓ 出口数据已更新: ${exports_yi}亿美元"
fi

echo ""

# 更新进口数据
echo ">>> 更新进口额"
read -p "请输入进口额（百万美元）: " imports_million
if [ -n "$imports_million" ]; then
    imports_yi=$(python3 -c "print(f'{float($imports_million) / 100:.2f}')")
    echo "${imports_yi},2026-06" > "${DATA_DIR}/.imports_cache"
    echo "✓ 进口数据已更新: ${imports_yi}亿美元"
fi

echo ""
echo "=========================================="
echo "数据更新完成！"
echo "现在可以运行 ./get_tw_economy.sh 来记录这些数据"
echo "=========================================="
