#!/bin/bash

# 美国经济季度数据收集脚本
# 收集指标：GDP增长率、失业率、通货膨胀率、个人消费支出、消费者信心指数
# 每周运行一次，增量更新数据

# 设置目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
DATA_DIR="${SCRIPT_DIR}/data"
LOG_FILE="${LOG_DIR}/us_economy_$(date +%Y%m%d).log"

# 创建必要的目录
mkdir -p "${LOG_DIR}" "${DATA_DIR}"

# 获取当前时间戳和日期
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
RECORD_DATE=$(date "+%Y-%m-%d")

# 数据文件路径
MAIN_CSV="${DATA_DIR}/us_economy_data.csv"

# 初始化CSV文件（如果不存在）
init_csv() {
    if [ ! -f "${MAIN_CSV}" ]; then
        echo "记录日期,GDP增长率(%),失业率(%),通货膨胀率(%),个人消费支出(%),消费者信心指数" > "${MAIN_CSV}"
        echo "${TIMESTAMP} - 初始化数据文件: ${MAIN_CSV}" | tee -a "${LOG_FILE}"
    fi
}

# 获取GDP增长率（季度环比年化）
get_gdp_growth() {
    curl -s --max-time 10 "https://fred.stlouisfed.org/graph/fredgraph.csv?id=A191RL1Q225SBEA" | tail -1 | awk -F',' '{
        if (NF == 2 && $2 != "") {
            split($1, date, "-")
            year = date[1]
            month = date[2]
            quarter = int((month - 1) / 3) + 1
            printf "%s,%s-Q%d\n", $2, year, quarter
        }
    }' 2>/dev/null || echo ""
}

# 获取失业率（最近季度的月度平均）
get_unemployment() {
    curl -s --max-time 10 "https://fred.stlouisfed.org/graph/fredgraph.csv?id=UNRATE" | tail -6 | python3 -c '
import sys
from collections import defaultdict
quarterly_data = defaultdict(list)
for line in sys.stdin:
    row = line.strip().split(",")
    if len(row) == 2 and row[1] and row[1].strip():
        date = row[0]
        if len(date) >= 7:
            year = date[:4]
            month = int(date[5:7])
            quarter = (month - 1) // 3 + 1
            quarter_key = f"{year}-Q{quarter}"
            try:
                quarterly_data[quarter_key].append(float(row[1]))
            except:
                pass
if quarterly_data:
    latest_quarter = sorted(quarterly_data.keys())[-1]
    avg_value = sum(quarterly_data[latest_quarter]) / len(quarterly_data[latest_quarter])
    print(f"{avg_value:.2f},{latest_quarter}")
' 2>/dev/null || echo ""
}

# 获取通货膨胀率（CPI同比增长）
get_inflation() {
    curl -s --max-time 10 "https://fred.stlouisfed.org/graph/fredgraph.csv?id=CPIAUCSL" | tail -15 | python3 -c '
import sys
quarterly_data = {}
for line in sys.stdin:
    row = line.strip().split(",")
    if len(row) == 2 and row[1] and row[1].strip():
        date = row[0]
        if len(date) >= 7:
            year = date[:4]
            month = int(date[5:7])
            quarter = (month - 1) // 3 + 1
            quarter_key = f"{year}-Q{quarter}"
            try:
                quarterly_data[quarter_key] = float(row[1])
            except:
                pass
quarters = sorted(quarterly_data.keys())
if len(quarters) >= 5:
    latest = quarters[-1]
    year_ago = quarters[-5]
    if year_ago in quarterly_data and latest in quarterly_data:
        yoy_change = ((quarterly_data[latest] - quarterly_data[year_ago]) / quarterly_data[year_ago]) * 100
        print(f"{yoy_change:.2f},{latest}")
' 2>/dev/null || echo ""
}

# 获取个人消费支出（PCE）增长率
get_pce() {
    curl -s --max-time 10 "https://fred.stlouisfed.org/graph/fredgraph.csv?id=PCE" | tail -15 | python3 -c '
import sys
quarterly_data = {}
for line in sys.stdin:
    row = line.strip().split(",")
    if len(row) == 2 and row[1] and row[1].strip():
        date = row[0]
        if len(date) >= 7:
            year = date[:4]
            month = int(date[5:7])
            quarter = (month - 1) // 3 + 1
            quarter_key = f"{year}-Q{quarter}"
            try:
                quarterly_data[quarter_key] = float(row[1])
            except:
                pass
quarters = sorted(quarterly_data.keys())
if len(quarters) >= 5:
    latest = quarters[-1]
    year_ago = quarters[-5]
    if year_ago in quarterly_data and latest in quarterly_data:
        yoy_change = ((quarterly_data[latest] - quarterly_data[year_ago]) / quarterly_data[year_ago]) * 100
        print(f"{yoy_change:.2f},{latest}")
' 2>/dev/null || echo ""
}

# 获取消费者信心指数（季度平均）
get_consumer_confidence() {
    curl -s --max-time 10 "https://fred.stlouisfed.org/graph/fredgraph.csv?id=UMCSENT" | tail -6 | python3 -c '
import sys
from collections import defaultdict
quarterly_data = defaultdict(list)
for line in sys.stdin:
    row = line.strip().split(",")
    if len(row) == 2 and row[1] and row[1].strip():
        date = row[0]
        if len(date) >= 7:
            year = date[:4]
            month = int(date[5:7])
            quarter = (month - 1) // 3 + 1
            quarter_key = f"{year}-Q{quarter}"
            try:
                quarterly_data[quarter_key].append(float(row[1]))
            except:
                pass
if quarterly_data:
    latest_quarter = sorted(quarterly_data.keys())[-1]
    avg_value = sum(quarterly_data[latest_quarter]) / len(quarterly_data[latest_quarter])
    print(f"{avg_value:.2f},{latest_quarter}")
' 2>/dev/null || echo ""
}

# 主流程
echo "${TIMESTAMP} - ========== 开始收集美国经济季度数据 ==========" | tee -a "${LOG_FILE}"

# 初始化CSV
init_csv

# 收集各项数据
echo "${TIMESTAMP} - 开始获取GDP增长率..." | tee -a "${LOG_FILE}"
gdp_data=$(get_gdp_growth)
if [ -n "$gdp_data" ]; then
    gdp_value=$(echo "$gdp_data" | cut -d',' -f1)
    gdp_quarter=$(echo "$gdp_data" | cut -d',' -f2)
    echo "${TIMESTAMP} - GDP增长率: ${gdp_value}% (${gdp_quarter})" | tee -a "${LOG_FILE}"
else
    gdp_value=""
    gdp_quarter=""
    echo "${TIMESTAMP} - GDP增长率: 未获取" | tee -a "${LOG_FILE}"
fi

echo "${TIMESTAMP} - 开始获取失业率..." | tee -a "${LOG_FILE}"
unemployment_data=$(get_unemployment)
if [ -n "$unemployment_data" ]; then
    unemployment_value=$(echo "$unemployment_data" | cut -d',' -f1)
    unemployment_quarter=$(echo "$unemployment_data" | cut -d',' -f2)
    echo "${TIMESTAMP} - 失业率: ${unemployment_value}% (${unemployment_quarter})" | tee -a "${LOG_FILE}"
else
    unemployment_value=""
    unemployment_quarter=""
    echo "${TIMESTAMP} - 失业率: 未获取" | tee -a "${LOG_FILE}"
fi

echo "${TIMESTAMP} - 开始获取通货膨胀率..." | tee -a "${LOG_FILE}"
inflation_data=$(get_inflation)
if [ -n "$inflation_data" ]; then
    inflation_value=$(echo "$inflation_data" | cut -d',' -f1)
    inflation_quarter=$(echo "$inflation_data" | cut -d',' -f2)
    echo "${TIMESTAMP} - 通货膨胀率: ${inflation_value}% (${inflation_quarter})" | tee -a "${LOG_FILE}"
else
    inflation_value=""
    inflation_quarter=""
    echo "${TIMESTAMP} - 通货膨胀率: 未获取" | tee -a "${LOG_FILE}"
fi

echo "${TIMESTAMP} - 开始获取个人消费支出..." | tee -a "${LOG_FILE}"
pce_data=$(get_pce)
if [ -n "$pce_data" ]; then
    pce_value=$(echo "$pce_data" | cut -d',' -f1)
    pce_quarter=$(echo "$pce_data" | cut -d',' -f2)
    echo "${TIMESTAMP} - 个人消费支出: ${pce_value}% (${pce_quarter})" | tee -a "${LOG_FILE}"
else
    pce_value=""
    pce_quarter=""
    echo "${TIMESTAMP} - 个人消费支出: 未获取" | tee -a "${LOG_FILE}"
fi

echo "${TIMESTAMP} - 开始获取消费者信心指数..." | tee -a "${LOG_FILE}"
confidence_data=$(get_consumer_confidence)
if [ -n "$confidence_data" ]; then
    confidence_value=$(echo "$confidence_data" | cut -d',' -f1)
    confidence_quarter=$(echo "$confidence_data" | cut -d',' -f2)
    echo "${TIMESTAMP} - 消费者信心指数: ${confidence_value} (${confidence_quarter})" | tee -a "${LOG_FILE}"
else
    confidence_value=""
    confidence_quarter=""
    echo "${TIMESTAMP} - 消费者信心指数: 未获取" | tee -a "${LOG_FILE}"
fi

# 追加数据到CSV（以记录日期为主键，每次运行添加新行）
echo "${RECORD_DATE},${gdp_value},${unemployment_value},${inflation_value},${pce_value},${confidence_value}" >> "${MAIN_CSV}"

echo "${TIMESTAMP} - 数据已记录到: ${MAIN_CSV}" | tee -a "${LOG_FILE}"
echo "${TIMESTAMP} - ========== 数据收集完成 ==========" | tee -a "${LOG_FILE}"

exit 0
