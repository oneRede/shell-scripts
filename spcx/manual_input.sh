#!/bin/bash

# SPCX 股价手动录入脚本
# 当自动API无法使用时，可以手动输入从东方财富网查看的价格

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/spcx_price_$(date +%Y%m%d).log"
CSV_FILE="${LOG_DIR}/spcx_price.csv"

mkdir -p "${LOG_DIR}"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "=== SPCX 股价手动录入 ==="
echo "请访问东方财富网查看 SpaceX (SPCX) 实时价格"
echo "网址: http://quote.eastmoney.com/us/SPCX.html"
echo ""

read -p "当前价格 (USD): " PRICE
read -p "开盘价 (USD): " OPEN
read -p "最高价 (USD): " HIGH
read -p "最低价 (USD): " LOW
read -p "成交量: " VOLUME
read -p "昨收价 (USD): " PREV_CLOSE

# 计算涨跌
if [ -n "$PREV_CLOSE" ] && (( $(echo "$PREV_CLOSE > 0" | bc -l) )); then
    CHANGE=$(echo "$PRICE - $PREV_CLOSE" | bc -l)
    CHANGE_PCT=$(echo "scale=2; ($CHANGE / $PREV_CLOSE) * 100" | bc -l)
    CHANGE_STR=$(printf "%+.2f (%+.2f%%)" $CHANGE $CHANGE_PCT)
else
    CHANGE=0
    CHANGE_PCT=0
    CHANGE_STR="N/A"
fi

METHOD="手动录入"

# 记录到日志
echo "${TIMESTAMP} - SPCX 股价: \$${PRICE} ${CHANGE_STR} | 开:\$${OPEN} 高:\$${HIGH} 低:\$${LOW} 量:${VOLUME} [来源: ${METHOD}]" | tee -a "${LOG_FILE}"

# 保存到CSV
if [ ! -f "${CSV_FILE}" ]; then
    echo "时间戳,价格(USD),开盘价,最高价,最低价,成交量,涨跌额,涨跌幅(%),数据源" > "${CSV_FILE}"
fi
echo "${TIMESTAMP},${PRICE},${OPEN},${HIGH},${LOW},${VOLUME},${CHANGE},${CHANGE_PCT},${METHOD}" >> "${CSV_FILE}"

echo ""
echo "✓ 数据已保存"
echo "日志文件: ${LOG_FILE}"
echo "CSV文件: ${CSV_FILE}"
