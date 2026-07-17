#!/bin/bash

# 台湾经济数据收集脚本
# 收集指标：GDP增长率、出口额、进口额
# 每周运行一次，获取最新月度数据
# 数据来源：手动配置或从公开统计网站抓取

# 设置目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
DATA_DIR="${SCRIPT_DIR}/data"
LOG_FILE="${LOG_DIR}/tw_economy_$(date +%Y%m%d).log"

# 创建必要的目录
mkdir -p "${LOG_DIR}" "${DATA_DIR}"

# 获取当前时间戳和日期
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
RECORD_DATE=$(date "+%Y-%m-%d")

# 数据文件路径
MAIN_CSV="${DATA_DIR}/tw_economy_data.csv"

# 初始化CSV文件（如果不存在）
init_csv() {
    if [ ! -f "${MAIN_CSV}" ]; then
        echo "记录日期,GDP增长率(%),GDP数据期间,出口额(亿美元),出口数据月份,进口额(亿美元),进口数据月份,贸易顺差(亿美元)" > "${MAIN_CSV}"
        echo "${TIMESTAMP} - 初始化数据文件: ${MAIN_CSV}" | tee -a "${LOG_FILE}"
    fi
}

# 获取台湾GDP增长率
# 注意：由于数据源限制，这里使用占位符，实际使用时需要从台湾主计总处官网手动更新
get_gdp_growth() {
    # 尝试从本地缓存文件读取（如果存在）
    local cache_file="${DATA_DIR}/.gdp_cache"
    if [ -f "$cache_file" ]; then
        cat "$cache_file"
    else
        echo ""
    fi
}

# 获取台湾出口额
# 数据来源：台湾财政部关务署统计网站
get_exports() {
    # 尝试从本地缓存文件读取（如果存在）
    local cache_file="${DATA_DIR}/.exports_cache"
    if [ -f "$cache_file" ]; then
        cat "$cache_file"
    else
        echo ""
    fi
}

# 获取台湾进口额
get_imports() {
    # 尝试从本地缓存文件读取（如果存在）
    local cache_file="${DATA_DIR}/.imports_cache"
    if [ -f "$cache_file" ]; then
        cat "$cache_file"
    else
        echo ""
    fi
}

# 主流程
echo "${TIMESTAMP} - ========== 开始收集台湾经济数据 ==========" | tee -a "${LOG_FILE}"
echo "${TIMESTAMP} - 提示：首次运行需要手动设置数据，请运行 ./update_data.sh" | tee -a "${LOG_FILE}"

# 初始化CSV
init_csv

# 收集各项数据
echo "${TIMESTAMP} - 开始获取GDP增长率..." | tee -a "${LOG_FILE}"
gdp_data=$(get_gdp_growth)
if [ -n "$gdp_data" ]; then
    gdp_value=$(echo "$gdp_data" | cut -d',' -f1)
    gdp_period=$(echo "$gdp_data" | cut -d',' -f2)
    echo "${TIMESTAMP} - GDP增长率: ${gdp_value}% (${gdp_period})" | tee -a "${LOG_FILE}"
else
    gdp_value=""
    gdp_period=""
    echo "${TIMESTAMP} - GDP增长率: 未设置（请运行 ./update_data.sh 手动更新）" | tee -a "${LOG_FILE}"
fi

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

# 追加数据到CSV
echo "${RECORD_DATE},${gdp_value},${gdp_period},${exports_value},${exports_period},${imports_value},${imports_period},${trade_surplus}" >> "${MAIN_CSV}"

echo "${TIMESTAMP} - 数据已记录到: ${MAIN_CSV}" | tee -a "${LOG_FILE}"
echo "${TIMESTAMP} - ========== 数据收集完成 ==========" | tee -a "${LOG_FILE}"

exit 0
