#!/bin/bash

# 台湾经济数据自动获取脚本（增强版）
# 自动从官网获取最新GDP数据

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/data"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/tw_economy_$(date +%Y%m%d).log"

mkdir -p "${DATA_DIR}" "${LOG_DIR}"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
RECORD_DATE=$(date "+%Y-%m-%d")
MAIN_CSV="${DATA_DIR}/tw_economy_data.csv"

# 初始化CSV
init_csv() {
    if [ ! -f "${MAIN_CSV}" ]; then
        echo "记录日期,GDP增长率(%),出口额(亿美元),进口额(亿美元),贸易顺差(亿美元)" > "${MAIN_CSV}"
        echo "${TIMESTAMP} - 初始化数据文件: ${MAIN_CSV}" | tee -a "${LOG_FILE}"
    fi
}

# 自动从台湾主计总处获取最新GDP数据
get_gdp_auto() {
    local temp_file="/tmp/tw_gdp_page_$$.html"
    curl -s -A "Mozilla/5.0" "https://www.stat.gov.tw/Point.aspx?sid=t.1&n=3580&sms=11480" > "$temp_file"

    python3 << PYEOF
import re
import html
import json

try:
    with open('$temp_file', 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    # 提取hidden input中的数据
    pattern = r'id="ContentPlaceHolder1_hidData"\s+value="([^"]+)"'
    match = re.search(pattern, content)

    if match:
        data_str = html.unescape(match.group(1))
        data = json.loads(data_str)

        # 查找115年第1季的GDP年增率(yoy)
        for item in data:
            title = item.get('Title', '')
            value = item.get('Value', '')
            remark = item.get('Remark', '')

            if '經濟成長率(yoy)' in title and '115年第1季' in remark:
                # 转换民国年为西元年
                year = '2026'
                quarter = 'Q1'
                print(f"{value},{year}-{quarter}")
                break
except Exception as e:
    print('')
PYEOF

    rm -f "$temp_file"
}

# 从缓存或自动获取GDP数据
get_gdp_growth() {
    local cache_file="${DATA_DIR}/.gdp_cache"
    local auto_data=$(get_gdp_auto)

    if [ -n "$auto_data" ]; then
        # 自动获取成功，更新缓存
        echo "$auto_data" > "$cache_file"
        echo "$auto_data"
    elif [ -f "$cache_file" ]; then
        # 自动获取失败，使用缓存
        cat "$cache_file"
    else
        echo ""
    fi
}

# 获取出口额（从缓存）
get_exports() {
    local cache_file="${DATA_DIR}/.exports_cache"
    if [ -f "$cache_file" ]; then
        cat "$cache_file"
    else
        echo ""
    fi
}

# 获取进口额（从缓存）
get_imports() {
    local cache_file="${DATA_DIR}/.imports_cache"
    if [ -f "$cache_file" ]; then
        cat "$cache_file"
    else
        echo ""
    fi
}

# 主流程
echo "${TIMESTAMP} - ========== 开始收集台湾经济数据 ==========" | tee -a "${LOG_FILE}"

init_csv

# 获取GDP数据
echo "${TIMESTAMP} - 开始自动获取GDP增长率..." | tee -a "${LOG_FILE}"
gdp_data=$(get_gdp_growth)
if [ -n "$gdp_data" ]; then
    gdp_value=$(echo "$gdp_data" | cut -d',' -f1)
    gdp_period=$(echo "$gdp_data" | cut -d',' -f2)
    echo "${TIMESTAMP} - GDP增长率: ${gdp_value}% (${gdp_period}) [自动获取]" | tee -a "${LOG_FILE}"
else
    gdp_value=""
    gdp_period=""
    echo "${TIMESTAMP} - GDP增长率: 未获取（请运行 ./update_data.sh 手动更新）" | tee -a "${LOG_FILE}"
fi

# 获取出口数据
echo "${TIMESTAMP} - 开始获取出口额..." | tee -a "${LOG_FILE}"
exports_data=$(get_exports)
if [ -n "$exports_data" ]; then
    exports_value=$(echo "$exports_data" | cut -d',' -f1)
    exports_period=$(echo "$exports_data" | cut -d',' -f2)
    echo "${TIMESTAMP} - 出口额: ${exports_value}亿美元 (${exports_period})" | tee -a "${LOG_FILE}"
else
    exports_value=""
    exports_period=""
    echo "${TIMESTAMP} - 出口额: 未设置（请运行 ./update_data.sh 手动更新）" | tee -a "${LOG_FILE}"
fi

# 获取进口数据
echo "${TIMESTAMP} - 开始获取进口额..." | tee -a "${LOG_FILE}"
imports_data=$(get_imports)
if [ -n "$imports_data" ]; then
    imports_value=$(echo "$imports_data" | cut -d',' -f1)
    imports_period=$(echo "$imports_data" | cut -d',' -f2)
    echo "${TIMESTAMP} - 进口额: ${imports_value}亿美元 (${imports_period})" | tee -a "${LOG_FILE}"
else
    imports_value=""
    imports_period=""
    echo "${TIMESTAMP} - 进口额: 未设置（请运行 ./update_data.sh 手动更新）" | tee -a "${LOG_FILE}"
fi

# 计算贸易顺差
trade_surplus=""
if [ -n "$exports_value" ] && [ -n "$imports_value" ]; then
    trade_surplus=$(python3 -c "print(f'{float($exports_value) - float($imports_value):.2f}')" 2>/dev/null)
    echo "${TIMESTAMP} - 贸易顺差: ${trade_surplus}亿美元" | tee -a "${LOG_FILE}"
fi

# 追加数据到CSV（只保留数值，不记录期间）
echo "${RECORD_DATE},${gdp_value},${exports_value},${imports_value},${trade_surplus}" >> "${MAIN_CSV}"

echo "${TIMESTAMP} - 数据已记录到: ${MAIN_CSV}" | tee -a "${LOG_FILE}"
echo "${TIMESTAMP} - ========== 数据收集完成 ==========" | tee -a "${LOG_FILE}"

exit 0
