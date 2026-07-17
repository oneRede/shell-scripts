#!/bin/bash

# 黄金价格获取脚本
# 每10分钟运行一次，记录当前黄金价格

# 设置日志目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
DATA_DIR="${SCRIPT_DIR}/data"
LOG_FILE="${LOG_DIR}/gold_price_$(date +%Y%m%d).log"

# 创建日志目录
mkdir -p "${LOG_DIR}" "${DATA_DIR}"

# 获取当前时间戳
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 方法1: 使用 fxratesapi.com（免费，无需API密钥）
get_price_method1() {
    local response=$(curl -s "https://api.fxratesapi.com/latest?base=XAU&currencies=USD")
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if data.get('success') and 'rates' in data and 'USD' in data['rates']:
        # XAU to USD rate, 需要转换为 USD per ounce
        rate = data['rates']['USD']
        # rate是1盎司黄金等于多少美元
        print(f'{rate:.2f}')
    else:
        print('')
except:
    print('')
" 2>/dev/null
    fi
}

# 方法2: 使用 Yahoo Finance（降低频率后可能可用）
get_price_method2() {
    local response=$(curl -s -m 10 "https://query1.finance.yahoo.com/v8/finance/chart/GC=F?interval=1d&range=1d" -H "User-Agent: Mozilla/5.0")
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    price = data['chart']['result'][0]['meta']['regularMarketPrice']
    print(f'{price:.2f}')
except:
    print('')
" 2>/dev/null
    fi
}

# 方法3: 使用国内数据源 - 东方财富（伦敦金）
get_price_method3() {
    local response=$(curl -s -m 10 "http://push2.eastmoney.com/api/qt/stock/get?secid=113.AUTD&fields=f58" -H "User-Agent: Mozilla/5.0")
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'data' in data and data['data'] and 'f58' in data['data']:
        # f58是最新价
        price = data['data']['f58']
        print(f'{price:.2f}')
    else:
        print('')
except:
    print('')
" 2>/dev/null
    fi
}

# 尝试获取价格
PRICE=""
METHOD="未知"

# 先尝试方法1（fxratesapi）
PRICE=$(get_price_method1)
if [ -n "$PRICE" ] && [[ "$PRICE" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$PRICE > 1000" | bc -l) )); then
    METHOD="fxratesapi.com"
else
    PRICE=""
fi

# 如果方法1失败，尝试方法2（Yahoo Finance）
if [ -z "$PRICE" ]; then
    PRICE=$(get_price_method2)
    if [ -n "$PRICE" ] && [[ "$PRICE" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$PRICE > 1000" | bc -l) )); then
        METHOD="Yahoo Finance"
    else
        PRICE=""
    fi
fi

# 如果方法2也失败，尝试方法3（东方财富）
if [ -z "$PRICE" ]; then
    PRICE=$(get_price_method3)
    if [ -n "$PRICE" ] && [[ "$PRICE" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$PRICE > 1000" | bc -l) )); then
        METHOD="东方财富网"
    else
        PRICE=""
    fi
fi

# 检查是否成功获取价格
if [ -z "$PRICE" ]; then
    echo "${TIMESTAMP} - ERROR: 无法获取黄金价格（所有数据源均失败）" | tee -a "${LOG_FILE}"
    exit 1
fi

# 记录价格
echo "${TIMESTAMP} - 黄金价格 (XAU/USD): \$${PRICE} /盎司 [来源: ${METHOD}]" | tee -a "${LOG_FILE}"

# 同时保存到CSV格式的文件，便于后续分析
CSV_FILE="${DATA_DIR}/gold_price.csv"
if [ ! -f "${CSV_FILE}" ]; then
    echo "时间戳,价格(USD/盎司),数据源" > "${CSV_FILE}"
fi
echo "${TIMESTAMP},${PRICE},${METHOD}" >> "${CSV_FILE}"

exit 0
