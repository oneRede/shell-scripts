#!/bin/bash

# OpenRouter Rankings 爬取脚本 - Shell包装器

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="${SCRIPT_DIR}/scrape_openrouter.py"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/openrouter_scrape_$(date +%Y%m%d).log"

mkdir -p "${LOG_DIR}"

echo "=========================================="
echo "OpenRouter Rankings 数据爬取"
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

# 检查Python脚本
if [ ! -f "${PYTHON_SCRIPT}" ]; then
    echo "❌ 错误: 找不到 ${PYTHON_SCRIPT}"
    exit 1
fi

# 检查依赖
if ! python3 -c "import selenium" 2>/dev/null; then
    echo "⚠️  未安装selenium，正在安装..."
    pip3 install selenium
fi

# 运行Python脚本
echo ""
python3 "${PYTHON_SCRIPT}" 2>&1 | tee -a "${LOG_FILE}"

exit_code=${PIPESTATUS[0]}

echo ""
echo "=========================================="
if [ $exit_code -eq 0 ]; then
    echo "✅ 爬取成功"
    echo "日志: ${LOG_FILE}"
else
    echo "❌ 爬取失败"
    echo "查看日志: ${LOG_FILE}"
fi
echo "=========================================="

exit $exit_code
