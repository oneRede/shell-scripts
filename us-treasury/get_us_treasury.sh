#!/bin/bash

# 美国30年期国债收益率及国债总量获取脚本
# 每4小时运行一次，记录当前收益率和国债总量

# 设置日志目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/us_treasury_$(date +%Y%m%d).log"

# 创建日志目录
mkdir -p "${LOG_DIR}"

# 获取当前时间戳
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 方法1: 使用 TradingEconomics（美国30年期国债收益率）
get_yield_method1() {
    local response=$(curl -s -m 15 "https://tradingeconomics.com/united-states/government-bond-yield" -H "User-Agent: Mozilla/5.0")
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "$response" | python3 -c "
import sys, re
try:
    content = sys.stdin.read()
    # 查找30年期国债收益率
    match = re.search(r'\"last\":([0-9.]+)', content)
    if match:
        yield_rate = float(match.group(1))
        print(f'{yield_rate:.3f}')
    else:
        print('')
except:
    print('')
" 2>/dev/null
    fi
}

# 方法2: 使用 FRED（备用数据源）
get_yield_method2() {
    curl -s "https://fred.stlouisfed.org/graph/fredgraph.csv?id=DGS30" | tail -1 | awk -F',' '{print $2}'
}

# 获取美国国债总量（单位：百万美元，转换为亿美元）
get_debt_total() {
    curl -s "https://fred.stlouisfed.org/graph/fredgraph.csv?id=GFDEBTN" | tail -1 | awk -F',' '{
        # 将百万美元转换为亿美元（除以100）
        debt_million = $2
        debt_yi = debt_million / 100
        printf "%.2f\n", debt_yi
    }'
}

# 尝试获取收益率
YIELD=""
METHOD="未知"

# 先尝试方法1（TradingEconomics）
YIELD=$(get_yield_method1)
if [ -n "$YIELD" ] && [[ "$YIELD" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$YIELD > 0" | bc -l) )); then
    METHOD="TradingEconomics"
else
    YIELD=""
fi

# 如果方法1失败，尝试方法2（FRED）
if [ -z "$YIELD" ]; then
    YIELD=$(get_yield_method2)
    if [ -n "$YIELD" ] && [[ "$YIELD" =~ ^[0-9]+\.?[0-9]*$ ]] && (( $(echo "$YIELD > 0" | bc -l) )); then
        METHOD="FRED"
    else
        YIELD=""
    fi
fi

# 获取国债总量
DEBT_TOTAL=$(get_debt_total)
if [ -z "$DEBT_TOTAL" ] || ! [[ "$DEBT_TOTAL" =~ ^[0-9]+\.?[0-9]*$ ]]; then
    DEBT_TOTAL=""
fi

# 检查是否成功获取收益率
if [ -z "$YIELD" ]; then
    echo "${TIMESTAMP} - ERROR: 无法获取美国30年期国债收益率（所有数据源均失败）" | tee -a "${LOG_FILE}"
    echo "${TIMESTAMP} - INFO: 建议访问以下网站查看国债收益率：" | tee -a "${LOG_FILE}"
    echo "  - TradingEconomics: https://tradingeconomics.com/united-states/government-bond-yield" | tee -a "${LOG_FILE}"
    echo "  - US Treasury: https://home.treasury.gov/policy-issues/financing-the-government/interest-rate-statistics" | tee -a "${LOG_FILE}"
    echo "  - FRED: https://fred.stlouisfed.org/series/DGS30" | tee -a "${LOG_FILE}"
    exit 1
fi

# 记录收益率和国债总量
echo "${TIMESTAMP} - 美国30年期国债收益率: ${YIELD}% [来源: ${METHOD}]" | tee -a "${LOG_FILE}"
if [ -n "$DEBT_TOTAL" ]; then
    echo "${TIMESTAMP} - 美国国债总量: ${DEBT_TOTAL}亿美元" | tee -a "${LOG_FILE}"
else
    echo "${TIMESTAMP} - 美国国债总量: 未获取" | tee -a "${LOG_FILE}"
fi

# 同时保存到CSV格式的文件，便于后续分析
CSV_FILE="${LOG_DIR}/us_treasury.csv"
if [ ! -f "${CSV_FILE}" ]; then
    echo "时间戳,收益率(%),国债总量(亿美元),数据源" > "${CSV_FILE}"
fi
echo "${TIMESTAMP},${YIELD},${DEBT_TOTAL},${METHOD}" >> "${CSV_FILE}"

exit 0
