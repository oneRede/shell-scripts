#!/bin/bash

# IP地址记录脚本
# 用途：开机时自动记录本机IP地址

# 配置
LOG_DIR="$HOME/git/sh/monitor_ip/logs"
LOG_FILE="$LOG_DIR/ip_history.log"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 等待网络就绪的函数
wait_for_network() {
    local max_wait=60  # 最多等待60秒
    local count=0
    local ipv4_ready=false
    local ipv6_ready=false

    echo "等待网络接口就绪..." >> "$LOG_FILE"

    while [ $count -lt $max_wait ]; do
        # 检查是否有非回环的IPv4地址
        if ifconfig | grep -E 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v '127.0.0.1' > /dev/null; then
            ipv4_ready=true
        fi

        # 检查是否有全局IPv6地址（排除回环::1和链路本地fe80::）
        if ifconfig | grep 'inet6' | grep -v '::1' | grep -v 'fe80::' > /dev/null; then
            ipv6_ready=true
        fi

        # 如果IPv4和IPv6都就绪，或者等待超过30秒且至少有一个就绪
        if [ "$ipv4_ready" = true ] && [ "$ipv6_ready" = true ]; then
            echo "网络接口已就绪 (IPv4+IPv6, 等待了 ${count} 秒)" >> "$LOG_FILE"
            return 0
        elif [ $count -ge 30 ] && ([ "$ipv4_ready" = true ] || [ "$ipv6_ready" = true ]); then
            if [ "$ipv4_ready" = true ] && [ "$ipv6_ready" = false ]; then
                echo "网络接口部分就绪 (仅IPv4, 等待了 ${count} 秒)" >> "$LOG_FILE"
            elif [ "$ipv4_ready" = false ] && [ "$ipv6_ready" = true ]; then
                echo "网络接口部分就绪 (仅IPv6, 等待了 ${count} 秒)" >> "$LOG_FILE"
            fi
            return 0
        fi

        sleep 1
        count=$((count + 1))
    done

    echo "警告: 等待网络超时 (${max_wait}秒)" >> "$LOG_FILE"
    return 1
}

# 等待网络就绪
wait_for_network

# 获取当前时间戳
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 记录分隔线
echo "==================== $TIMESTAMP ====================" >> "$LOG_FILE"

# 获取主机名
HOSTNAME=$(hostname)
echo "主机名: $HOSTNAME" >> "$LOG_FILE"

# 获取所有活跃的IPv4地址
echo "IPv4地址:" >> "$LOG_FILE"
ifconfig | awk '
/^[a-z]/ { iface=$1; gsub(/:/, "", iface) }
/inet / && !/127\.0\.0\.1/ {
    split($0, a, " ")
    for (i in a) {
        if (a[i] ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) {
            print "  - " iface ": " a[i]
        }
    }
}
' >> "$LOG_FILE"

# 获取所有活跃的IPv6地址（可选）
echo "IPv6地址:" >> "$LOG_FILE"
ifconfig | awk '
/^[a-z]/ { iface=$1; gsub(/:/, "", iface) }
/inet6 / && !/::1/ && !/fe80:/ {
    split($0, a, " ")
    for (i in a) {
        if (a[i] ~ /:/ && a[i] !~ /prefixlen|scopeid/) {
            print "  - " iface ": " a[i]
        }
    }
}
' >> "$LOG_FILE"

# 获取外网IP（可选，需要网络连接）
echo "外网IP:" >> "$LOG_FILE"
EXTERNAL_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || echo "获取失败")
echo "  - $EXTERNAL_IP" >> "$LOG_FILE"

echo "" >> "$LOG_FILE"

# 输出到标准输出（用于调试）
echo "IP地址已记录到: $LOG_FILE"
