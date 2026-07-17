#!/bin/bash

# 美元日元汇率获取脚本
# 每小时运行一次，记录当前汇率

# 设置日志目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
DATA_DIR="${SCRIPT_DIR}/data"
LOG_FILE="${LOG_DIR}/usdjpy_$(date +%Y%m%d).log"

# 创建日志目录
mkdir -p "${LOG_DIR}" "${DATA_DIR}"

# 获取当前时间戳
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 方法1: 使用 fxratesapi.com（免费，无需API密钥）
get_rate_method1() {
    local response=$(curl -s -m 15 "https://api.fxratesapi.com/latest?base=USD&currencies=JPY")
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if data.get('success') and 'rates' in data and 'JPY' in data['rates']:
        rate = data['rates']['JPY']
        print(f'{rate:.4f}')
    else:
        print('')
except:
    print('')
" 2>/dev/null
    fi
}

# 方法2: 使用 TradingEconomics
get_rate_method2() {
    local response=$(curl -s -m 15 "https://tradingeconomics.com/usdjpy:cur" -H "User-Agent: Mozilla/5.0")
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "$response" | python3 -c "
import sys, re
try:
    content = sys.stdin.read()
    match = re.search(r'\"last\":([0-9.]+)', content)
    if match:
        rate = float(match.group(1))
        print(f'{rate:.4f}')
    else:
        print('')
except:
    print('')
" 2>/dev/null
    fi
}

# 方法3: 使用 Yahoo Finance
get_rate_method3() {
    local response=$(curl -s -m 15 "https://query1.finance.yahoo.com/v8/finance/chart/JPY=X?interval=1d&range=1d" -H "User-Agent: Mozilla/5.0")
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    rate = data['chart']['result'][0]['meta']['regularMarketPrice']
    print(f'{rate:.4f}')
except:
    print('')
" 2>/dev/null
    fi
}

# 尝试获取汇率
RATE=""
METHOD="未知"

# 先尝试方法1（fxratesapi）
RATE=$(get_rate_method1)
if [ -n "$RATE" ] && [[ "$RATE" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$RATE > 50" | bc -l) )); then
    METHOD="fxratesapi.com"
else
    RATE=""
fi

# 如果方法1失败，尝试方法2（TradingEconomics）
if [ -z "$RATE" ]; then
    RATE=$(get_rate_method2)
    if [ -n "$RATE" ] && [[ "$RATE" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$RATE > 50" | bc -l) )); then
        METHOD="TradingEconomics"
    else
        RATE=""
    fi
fi

# 如果方法2也失败，尝试方法3（Yahoo Finance）
if [ -z "$RATE" ]; then
    RATE=$(get_rate_method3)
    if [ -n "$RATE" ] && [[ "$RATE" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$RATE > 50" | bc -l) )); then
        METHOD="Yahoo Finance"
    else
        RATE=""
    fi
fi

# 检查是否成功获取汇率
if [ -z "$RATE" ]; then
    echo "${TIMESTAMP} - ERROR: 无法获取USD/JPY汇率（所有数据源均失败）" | tee -a "${LOG_FILE}"
    exit 1
fi

# 记录汇率
echo "${TIMESTAMP} - USD/JPY汇率: ¥${RATE} [来源: ${METHOD}]" | tee -a "${LOG_FILE}"

# 同时保存到CSV格式的文件，便于后续分析
CSV_FILE="${DATA_DIR}/usdjpy.csv"
if [ ! -f "${CSV_FILE}" ]; then
    echo "时间戳,汇率(JPY),数据源" > "${CSV_FILE}"
fi
echo "${TIMESTAMP},${RATE},${METHOD}" >> "${CSV_FILE}"

exit 0
