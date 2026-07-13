#!/bin/bash

# Google (GOOGL) 股价获取脚本
# 每10分钟运行一次，记录当前股价

# 设置日志目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/googl_price_$(date +%Y%m%d).log"

# 创建日志目录
mkdir -p "${LOG_DIR}"

# 获取当前时间戳
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 方法1: 使用腾讯财经 API（推荐，可靠）
get_price_method1() {
    local response=$(curl -s -m 10 "http://qt.gtimg.cn/q=usGOOGL" | iconv -f gbk -t utf-8 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$response" ] && [[ "$response" == *"~"* ]]; then
        echo "$response" | python3 -c "
import sys
try:
    data = sys.stdin.read().strip()
    if '~' in data:
        parts = data.split('~')
        if len(parts) > 35:
            price = float(parts[3]) if parts[3] else 0
            prev_close = float(parts[4]) if parts[4] else 0
            open_price = float(parts[5]) if parts[5] else 0
            volume = int(float(parts[6])) if parts[6] else 0
            high = float(parts[33]) if len(parts) > 33 and parts[33] else price
            low = float(parts[34]) if len(parts) > 34 and parts[34] else price
            pe_ttm = float(parts[39]) if len(parts) > 39 and parts[39] and parts[39] != '0' else 0
            pe_static = float(parts[51]) if len(parts) > 51 and parts[51] and parts[51] != '0' else 0

            if price > 0:
                print(f'{price:.2f}|{open_price:.2f}|{high:.2f}|{low:.2f}|{volume}|{prev_close:.2f}|{pe_ttm:.2f}|{pe_static:.2f}')
            else:
                print('')
        else:
            print('')
    else:
        print('')
except:
    print('')
" 2>/dev/null
    fi
}

# 方法2: 备用
get_price_method2() {
    echo ""
}

# 尝试获取价格
PRICE_DATA=""
METHOD="未知"

PRICE_DATA=$(get_price_method1)
if [ -n "$PRICE_DATA" ] && [[ "$PRICE_DATA" =~ \| ]]; then
    METHOD="腾讯财经"
else
    PRICE_DATA=""
fi

if [ -z "$PRICE_DATA" ]; then
    PRICE_DATA=$(get_price_method2)
    if [ -n "$PRICE_DATA" ] && [[ "$PRICE_DATA" =~ \| ]]; then
        METHOD="新浪财经"
    else
        PRICE_DATA=""
    fi
fi

if [ -z "$PRICE_DATA" ]; then
    echo "${TIMESTAMP} - ERROR: 无法获取 GOOGL 股价（所有数据源均失败）" | tee -a "${LOG_FILE}"
    exit 1
fi

IFS='|' read -r PRICE OPEN HIGH LOW VOLUME PREV_CLOSE PE_TTM PE_STATIC <<< "$PRICE_DATA"

if (( $(echo "$PREV_CLOSE > 0" | bc -l) )); then
    CHANGE=$(echo "$PRICE - $PREV_CLOSE" | bc -l)
    CHANGE_PCT=$(echo "scale=2; ($CHANGE / $PREV_CLOSE) * 100" | bc -l)
    CHANGE_STR=$(printf "%+.2f (%+.2f%%)" $CHANGE $CHANGE_PCT)
else
    CHANGE=0
    CHANGE_PCT=0
    CHANGE_STR="N/A"
fi

PE_INFO=""
if (( $(echo "$PE_TTM < 0" | bc -l) )); then
    PE_INFO=" | 动态P/E:N/A(亏损)"
else
    if (( $(echo "$PE_STATIC > 0" | bc -l) )); then
        PE_INFO=" | 静态P/E:${PE_STATIC}"
    fi
    if (( $(echo "$PE_TTM > 0" | bc -l) )); then
        PE_INFO="${PE_INFO} 动态P/E:${PE_TTM}"
    fi
fi

echo "${TIMESTAMP} - GOOGL 股价: \$${PRICE} ${CHANGE_STR} | 开:\$${OPEN} 高:\$${HIGH} 低:\$${LOW} 量:${VOLUME}${PE_INFO} [来源: ${METHOD}]" | tee -a "${LOG_FILE}"

CSV_FILE="${LOG_DIR}/googl_price.csv"
if [ ! -f "${CSV_FILE}" ]; then
    echo "时间戳,价格(USD),开盘价,最高价,最低价,成交量,涨跌额,涨跌幅(%),动态市盈率,数据源" > "${CSV_FILE}"
fi
echo "${TIMESTAMP},${PRICE},${OPEN},${HIGH},${LOW},${VOLUME},${CHANGE},${CHANGE_PCT},${PE_TTM},${METHOD}" >> "${CSV_FILE}"

exit 0
