#!/bin/bash

# 天然气价格获取脚本
# 每小时运行一次，记录当前天然气价格

# 设置日志目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
DATA_DIR="${SCRIPT_DIR}/data"
LOG_FILE="${LOG_DIR}/natural_gas_$(date +%Y%m%d).log"

# 创建日志目录
mkdir -p "${LOG_DIR}" "${DATA_DIR}"

# 获取当前时间戳
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 方法1: 使用 TradingEconomics（天然气价格）
get_price_method1() {
    local response=$(curl -s -m 15 "https://tradingeconomics.com/commodity/natural-gas" -H "User-Agent: Mozilla/5.0")
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "$response" | python3 -c "
import sys, re
try:
    content = sys.stdin.read()
    match = re.search(r'\"last\":([0-9.]+)', content)
    if match:
        price = float(match.group(1))
        print(f'{price:.3f}')
    else:
        print('')
except:
    print('')
" 2>/dev/null
    fi
}

# 方法2: 备用数据源
get_price_method2() {
    echo ""
}

# 尝试获取价格
PRICE=""
METHOD="未知"

# 先尝试方法1（TradingEconomics）
PRICE=$(get_price_method1)
if [ -n "$PRICE" ] && [[ "$PRICE" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$PRICE > 0.1" | bc -l) )); then
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
    echo "${TIMESTAMP} - ERROR: 无法获取天然气价格（所有数据源均失败）" | tee -a "${LOG_FILE}"
    exit 1
fi

# 记录价格
echo "${TIMESTAMP} - 天然气价格: \$${PRICE}/MMBtu [来源: ${METHOD}]" | tee -a "${LOG_FILE}"

exit 0
