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

# 获取数据年月（默认为上个月）
last_month=$(date -v-1m +%Y-%m)
current_year=$(date +%Y)
current_quarter="Q$(($(date +%-m) / 3))"
echo ">>> 数据所属期间"
read -p "请输入数据年月（格式: YYYY-MM，直接回车使用上个月 ${last_month}）: " data_month
if [ -z "$data_month" ]; then
    data_month="$last_month"
fi
echo "数据期间设置为: ${data_month}"

echo ""

# 更新 GDP 数据
echo ">>> 更新 GDP 增长率"
read -p "请输入 GDP 增长率（年增率 %，无数据请直接回车）: " gdp_rate
if [ -n "$gdp_rate" ]; then
    echo "${gdp_rate},${current_year}-${current_quarter}" > "${DATA_DIR}/.gdp_cache"
    echo "✓ GDP 数据已更新: ${gdp_rate}% (${current_year}-${current_quarter})"
else
    echo "未发布,${current_year}-${current_quarter}" > "${DATA_DIR}/.gdp_cache"
    echo "✓ GDP 数据标记为: 未发布 (${current_year}-${current_quarter})"
fi

echo ""

# 更新出口数据
echo ">>> 更新出口额"
read -p "请输入出口额（百万美元，无数据请直接回车）: " exports_million
if [ -n "$exports_million" ]; then
    exports_yi=$(python3 -c "print(f'{float($exports_million) / 100:.2f}')")
    echo "${exports_yi},${data_month}" > "${DATA_DIR}/.exports_cache"
    echo "✓ 出口数据已更新: ${exports_yi}亿美元 (${data_month})"
else
    echo "未发布,${data_month}" > "${DATA_DIR}/.exports_cache"
    echo "✓ 出口数据标记为: 未发布 (${data_month})"
fi

echo ""

# 更新进口数据
echo ">>> 更新进口额"
read -p "请输入进口额（百万美元，无数据请直接回车）: " imports_million
if [ -n "$imports_million" ]; then
    imports_yi=$(python3 -c "print(f'{float($imports_million) / 100:.2f}')")
    echo "${imports_yi},${data_month}" > "${DATA_DIR}/.imports_cache"
    echo "✓ 进口数据已更新: ${imports_yi}亿美元 (${data_month})"
else
    echo "未发布,${data_month}" > "${DATA_DIR}/.imports_cache"
    echo "✓ 进口数据标记为: 未发布 (${data_month})"
fi

echo ""
echo "=========================================="
echo "数据更新完成！"
echo "现在可以运行 ./get_tw_economy.sh 来记录这些数据"
echo "=========================================="
