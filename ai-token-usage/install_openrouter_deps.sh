#!/bin/bash

# OpenRouter 爬虫依赖安装脚本

echo "=========================================="
echo "安装 OpenRouter 爬虫依赖"
echo "=========================================="
echo ""

# 检查Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ 未安装Homebrew"
    echo "请访问: https://brew.sh"
    exit 1
fi

echo "1. 安装 ChromeDriver..."
if command -v chromedriver &> /dev/null; then
    echo "✓ ChromeDriver 已安装"
else
    brew install chromedriver
    if [ $? -eq 0 ]; then
        echo "✓ ChromeDriver 安装成功"
    else
        echo "❌ ChromeDriver 安装失败"
        exit 1
    fi
fi

echo ""
echo "2. 允许 ChromeDriver 运行（macOS安全设置）..."
xattr -d com.apple.quarantine $(which chromedriver) 2>/dev/null || true
echo "✓ 已设置权限"

echo ""
echo "3. 安装 Python 依赖..."
pip3 install selenium 2>&1 | grep -E "(Requirement|Successfully|ERROR)"

echo ""
echo "=========================================="
echo "✅ 依赖安装完成"
echo "=========================================="
echo ""
echo "测试运行："
echo "  ./scrape_openrouter.sh"
echo ""
