#!/bin/bash

# 存储器价格获取脚本
# 从 chinaflashmarket.com 获取 Flash Wafer 和 DDR 价格
# 每天运行一次，记录当前价格（转换为人民币）

# 设置日志目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/memory_price_$(date +%Y%m%d).log"

# 创建日志目录
mkdir -p "${LOG_DIR}"

# 获取当前时间戳
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 获取美元兑人民币汇率
get_usd_cny_rate() {
    # 方法1: 使用exchangerate-api.com (免费)
    local rate=$(curl -s -m 10 "https://open.er-api.com/v6/latest/USD" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'rates' in data and 'CNY' in data['rates']:
        print(data['rates']['CNY'])
except:
    pass
" 2>/dev/null)

    if [ -n "$rate" ] && [[ "$rate" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        echo "$rate"
        return 0
    fi

    # 方法2: 使用新浪财经接口
    local rate=$(curl -s -m 10 "https://hq.sinajs.cn/rn=1&list=fx_susdcny" | grep -o 'CNY=[0-9.]*' | cut -d= -f2)

    if [ -n "$rate" ] && [[ "$rate" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        echo "$rate"
        return 0
    fi

    # 方法3: 使用固定汇率作为备选
    echo "7.25"
}

# 获取汇率
USD_TO_CNY=$(get_usd_cny_rate)
echo "${TIMESTAMP} - INFO: 使用汇率 1 USD = ${USD_TO_CNY} CNY" | tee -a "${LOG_FILE}"

# 获取并解析价格数据
get_memory_prices() {
    local response=$(curl -s -L -m 20 "https://chinaflashmarket.com/price" \
        -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
        -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
        -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8")

    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "$response" | python3 "${SCRIPT_DIR}/parse_price.py" 2>/dev/null
    fi
}

# 尝试获取价格
PRICE_DATA=$(get_memory_prices)

# 检查是否成功获取价格
if [ -z "$PRICE_DATA" ] || [[ "$PRICE_DATA" == ERROR:* ]]; then
    echo "${TIMESTAMP} - ERROR: 无法获取存储器价格数据" | tee -a "${LOG_FILE}"
    echo "${TIMESTAMP} - INFO: 请检查网络连接或数据源是否可用" | tee -a "${LOG_FILE}"
    echo "${TIMESTAMP} - INFO: 可访问 https://chinaflashmarket.com/price 查看实时价格" | tee -a "${LOG_FILE}"
    if [[ "$PRICE_DATA" == ERROR:* ]]; then
        echo "${TIMESTAMP} - DEBUG: ${PRICE_DATA}" | tee -a "${LOG_FILE}"
    fi
    exit 1
fi

# 统计数据条数
ITEM_COUNT=$(echo "$PRICE_DATA" | wc -l | xargs)
echo "${TIMESTAMP} - SUCCESS: 成功获取 ${ITEM_COUNT} 条存储器价格数据 [来源: CFM闪存市场]" | tee -a "${LOG_FILE}"

# 保存详细数据到日志
echo "${TIMESTAMP} - 存储器价格详情 (人民币):" >> "${LOG_FILE}"
echo "----------------------------------------" >> "${LOG_FILE}"

# 按类别分组显示
CATEGORIES=$(echo "$PRICE_DATA" | cut -d'|' -f1 | sort -u)

while IFS= read -r category; do
    if [ -z "$category" ]; then
        continue
    fi

    echo "" >> "${LOG_FILE}"
    echo "【${category}】" | tee -a "${LOG_FILE}"

    # 筛选该类别的数据
    echo "$PRICE_DATA" | grep "^${category}|" | while IFS='|' read -r cat product current change change_pct prev high low; do
        # 转换为人民币
        current_cny=$(echo "scale=2; $current * $USD_TO_CNY" | bc -l)
        prev_cny=$(echo "scale=2; $prev * $USD_TO_CNY" | bc -l)
        high_cny=$(echo "scale=2; $high * $USD_TO_CNY" | bc -l)
        low_cny=$(echo "scale=2; $low * $USD_TO_CNY" | bc -l)
        change_cny=$(echo "scale=2; $change * $USD_TO_CNY" | bc -l)

        # 格式化涨跌显示
        if [ -n "$change" ] && [ "$change" != "0" ] && [ "$change" != "0.00" ]; then
            if [[ "$change" =~ ^- ]]; then
                change_str="${change_cny} (${change_pct}%)"
            else
                change_str="+${change_cny} (+${change_pct}%)"
            fi
        else
            change_str="0.00 (0.00%)"
        fi

        echo "  ${product}: ¥${current_cny} [${change_str}] | 前:¥${prev_cny} 高:¥${high_cny} 低:¥${low_cny}" | tee -a "${LOG_FILE}"
    done
done

echo "" >> "${LOG_FILE}"
echo "========================================" >> "${LOG_FILE}"

# 同时保存到CSV格式的文件，便于后续分析
CSV_FILE="${LOG_DIR}/memory_price.csv"
if [ ! -f "${CSV_FILE}" ]; then
    echo "时间戳,类别,产品,当前价(CNY),涨跌额(CNY),涨跌幅(%),前收盘价(CNY),高点(CNY),低点(CNY),汇率(USD/CNY)" > "${CSV_FILE}"
fi

# 追加所有数据到CSV (转换为人民币)
echo "$PRICE_DATA" | while IFS='|' read -r category product current change change_pct prev high low; do
    if [ -n "$product" ] && [ -n "$current" ]; then
        current_cny=$(echo "scale=2; $current * $USD_TO_CNY" | bc -l)
        prev_cny=$(echo "scale=2; $prev * $USD_TO_CNY" | bc -l)
        high_cny=$(echo "scale=2; $high * $USD_TO_CNY" | bc -l)
        low_cny=$(echo "scale=2; $low * $USD_TO_CNY" | bc -l)
        change_cny=$(echo "scale=2; $change * $USD_TO_CNY" | bc -l)
        echo "${TIMESTAMP},${category},${product},${current_cny},${change_cny},${change_pct},${prev_cny},${high_cny},${low_cny},${USD_TO_CNY}" >> "${CSV_FILE}"
    fi
done

exit 0
