#!/bin/bash

# 碳酸锂价格获取脚本
# 每10分钟运行一次，记录当前碳酸锂价格

# 设置日志目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
DATA_DIR="${SCRIPT_DIR}/data"
LOG_FILE="${LOG_DIR}/lithium_price_$(date +%Y%m%d).log"

# 创建日志目录
mkdir -p "${LOG_DIR}" "${DATA_DIR}"

# 获取当前时间戳
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 方法1: 使用 TradingEconomics（碳酸锂价格 - 中国市场）
get_price_method1() {
    local response=$(curl -s -m 15 "https://tradingeconomics.com/commodity/lithium" -H "User-Agent: Mozilla/5.0")
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "$response" | python3 -c "
import sys, re
try:
    content = sys.stdin.read()
    match = re.search(r'\"last\":([0-9.]+)', content)
    if match:
        price = float(match.group(1))
        print(f'{price:.2f}')
    else:
        print('')
except:
    print('')
" 2>/dev/null
    fi
}

# 方法2: 备用数据源（如果有的话）
get_price_method2() {
    # 预留给其他数据源
    echo ""
}

# 尝试获取价格
PRICE=""
METHOD="未知"
CURRENCY="CNY"

# 先尝试方法1（TradingEconomics）
PRICE=$(get_price_method1)
if [ -n "$PRICE" ] && [[ "$PRICE" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$PRICE > 1000" | bc -l) )); then
    METHOD="TradingEconomics"
else
    PRICE=""
fi

# 如果方法1失败，尝试方法2
if [ -z "$PRICE" ]; then
    PRICE=$(get_price_method2)
    if [ -n "$PRICE" ] && [[ "$PRICE" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        METHOD="备用数据源"
    else
        PRICE=""
    fi
fi

# 检查是否成功获取价格
if [ -z "$PRICE" ]; then
    echo "${TIMESTAMP} - ERROR: 无法获取碳酸锂价格（所有数据源均失败）" | tee -a "${LOG_FILE}"
    echo "${TIMESTAMP} - INFO: 建议访问以下网站查看碳酸锂价格：" | tee -a "${LOG_FILE}"
    echo "  - TradingEconomics: https://tradingeconomics.com/commodity/lithium" | tee -a "${LOG_FILE}"
    echo "  - 上海有色网: https://www.smm.cn/" | tee -a "${LOG_FILE}"
    echo "  - 生意社: https://www.100ppi.com/" | tee -a "${LOG_FILE}"
    exit 1
fi

# 记录价格
echo "${TIMESTAMP} - 碳酸锂价格: ¥${PRICE} ${CURRENCY}/吨 [来源: ${METHOD}]" | tee -a "${LOG_FILE}"

# 同时保存到CSV格式的文件，便于后续分析
CSV_FILE="${DATA_DIR}/lithium_price.csv"
if [ ! -f "${CSV_FILE}" ]; then
    echo "时间戳,价格(CNY/吨),数据源" > "${CSV_FILE}"
fi
echo "${TIMESTAMP},${PRICE},${METHOD}" >> "${CSV_FILE}"

exit 0
