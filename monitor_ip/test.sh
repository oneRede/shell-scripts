#!/bin/bash

# 测试脚本 - 验证IP监控系统的所有功能

echo "================================"
echo "IP监控系统验证测试"
echo "================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试计数
PASSED=0
FAILED=0

# 测试函数
test_case() {
    local name=$1
    local command=$2

    echo -n "测试: $name ... "

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ 通过${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗ 失败${NC}"
        ((FAILED++))
        return 1
    fi
}

# 1. 检查文件存在性
echo "--- 文件结构检查 ---"
test_case "record_ip.sh存在" "[ -f ~/git/sh/monitor_ip/record_ip.sh ]"
test_case "install.sh存在" "[ -f ~/git/sh/monitor_ip/install.sh ]"
test_case "uninstall.sh存在" "[ -f ~/git/sh/monitor_ip/uninstall.sh ]"
test_case "plist文件存在" "[ -f ~/git/sh/monitor_ip/com.user.recordip.plist ]"
test_case "README.md存在" "[ -f ~/git/sh/monitor_ip/README.md ]"
echo ""

# 2. 检查文件权限
echo "--- 权限检查 ---"
test_case "record_ip.sh可执行" "[ -x ~/git/sh/monitor_ip/record_ip.sh ]"
test_case "install.sh可执行" "[ -x ~/git/sh/monitor_ip/install.sh ]"
test_case "uninstall.sh可执行" "[ -x ~/git/sh/monitor_ip/uninstall.sh ]"
echo ""

# 3. 检查plist文件格式
echo "--- plist格式验证 ---"
test_case "plist格式正确" "plutil -lint ~/git/sh/monitor_ip/com.user.recordip.plist"
echo ""

# 4. 测试脚本功能
echo "--- 功能测试 ---"
# 清空日志
rm -f ~/git/sh/monitor_ip/logs/ip_history.log

# 运行脚本
cd ~/git/sh/monitor_ip
./record_ip.sh > /dev/null 2>&1

test_case "日志文件已创建" "[ -f ~/git/sh/monitor_ip/logs/ip_history.log ]"
test_case "日志文件不为空" "[ -s ~/git/sh/monitor_ip/logs/ip_history.log ]"
test_case "记录了时间戳" "grep -q '====' ~/git/sh/monitor_ip/logs/ip_history.log"
test_case "记录了主机名" "grep -q '主机名:' ~/git/sh/monitor_ip/logs/ip_history.log"
test_case "记录了IPv4地址" "grep -q 'IPv4地址:' ~/git/sh/monitor_ip/logs/ip_history.log"
test_case "记录了IPv6地址" "grep -q 'IPv6地址:' ~/git/sh/monitor_ip/logs/ip_history.log"
test_case "记录了外网IP" "grep -q '外网IP:' ~/git/sh/monitor_ip/logs/ip_history.log"
echo ""

# 5. 测试多次运行（日志追加）
echo "--- 日志追加测试 ---"
./record_ip.sh > /dev/null 2>&1
./record_ip.sh > /dev/null 2>&1

RECORD_COUNT=$(grep -c "====" ~/git/sh/monitor_ip/logs/ip_history.log)
test_case "日志正确追加 (应有3条记录)" "[ $RECORD_COUNT -eq 3 ]"
echo ""

# 6. 显示测试结果
echo "================================"
echo "测试结果汇总"
echo "================================"
echo -e "通过: ${GREEN}${PASSED}${NC}"
echo -e "失败: ${RED}${FAILED}${NC}"
echo "总计: $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}所有测试通过！✓${NC}"
    echo ""
    echo "查看日志文件："
    echo "  cat ~/git/sh/monitor_ip/logs/ip_history.log"
    echo ""
    echo "安装开机自动运行："
    echo "  cd ~/git/sh/monitor_ip && ./install.sh"
    exit 0
else
    echo -e "${RED}有测试失败，请检查！✗${NC}"
    exit 1
fi
