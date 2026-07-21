#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
OpenRouter Rankings 数据爬取脚本 v3.0
每日自动获取**昨天**的模型排名和Token消耗数据
"""

import json
import re
import time
from datetime import datetime, timedelta
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# 配置
SCRIPT_DIR = Path(__file__).parent
LOG_DIR = SCRIPT_DIR / "logs"
DATA_DIR = SCRIPT_DIR / "data"
OPENROUTER_DIR = DATA_DIR / "openrouter"
URL = "https://openrouter.ai/rankings?view=day"

# 创建目录
OPENROUTER_DIR.mkdir(parents=True, exist_ok=True)

def setup_driver():
    """配置无头Chrome浏览器"""
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument('--disable-gpu')
    chrome_options.add_argument('--window-size=1920,1080')
    chrome_options.add_argument('user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36')

    try:
        # Let Selenium automatically manage ChromeDriver version
        # This will download the correct version matching the installed Chrome
        driver = webdriver.Chrome(options=chrome_options)
        return driver
    except Exception as e:
        print(f"❌ Chrome启动失败: {e}")
        print("💡 提示: Selenium会自动下载匹配的ChromeDriver")
        print("   如果失败，请检查Chrome浏览器是否已安装")
        return None

def parse_token_count(text):
    """解析Token数量文本（如 '1.2M' 或 '806B tokens'）"""
    text = text.replace(',', '').replace('tokens', '').strip()

    match = re.search(r'([\d.]+)\s*([KMB])?', text, re.IGNORECASE)
    if match:
        num = float(match.group(1))
        unit = match.group(2)

        if unit:
            unit = unit.upper()
            if unit == 'K':
                return int(num * 1_000)
            elif unit == 'M':
                return int(num * 1_000_000)
            elif unit == 'B':
                return int(num * 1_000_000_000)
        return int(num)

    return 0

def parse_html_content(html):
    """从HTML内容中提取模型排名数据（正则表达式方法）"""
    rankings = []

    # 正则匹配模式：找到模型名和token数
    # 格式: >ModelName</a>...XXB tokens</div>
    pattern = r'>([^<]{4,})</a>.*?(\d+\.?\d*[KMB]\s*tokens)'

    matches = re.findall(pattern, html, re.DOTALL)

    # 过滤无效数据
    blacklist = ['skip to content', 'view all', 'see more', 'learn more']

    for model, tokens_text in matches:
        model = model.strip()
        model_lower = model.lower()

        # 跳过明显的导航链接
        if any(black in model_lower for black in blacklist):
            continue

        tokens = parse_token_count(tokens_text)

        # 只保留有效数据（至少10M tokens且模型名合理）
        if tokens >= 10_000_000 and len(model) >= 3:
            # 避免重复
            if not any(r['model'] == model for r in rankings):
                rankings.append({
                    'model': model,
                    'tokens': tokens,
                    'tokens_t': round(tokens / 1_000_000_000_000, 3),
                    'tokens_unit': 'T',
                    'rank': len(rankings) + 1
                })

    # 按tokens降序排序并重新分配rank
    rankings.sort(key=lambda x: x['tokens'], reverse=True)
    for idx, r in enumerate(rankings, 1):
        r['rank'] = idx

    return rankings[:20]  # 只保留Top 20

def scrape_openrouter():
    """爬取OpenRouter Rankings数据"""
    print(f"🌐 正在访问 {URL}")
    print(f"📅 获取昨天的数据")

    driver = setup_driver()
    if not driver:
        return None

    try:
        # 访问页面
        driver.get(URL)

        # 等待页面加载
        print("⏳ 等待页面加载...")
        wait = WebDriverWait(driver, 30)

        # 等待body加载
        wait.until(EC.presence_of_element_located((By.TAG_NAME, "body")))

        # 额外等待JavaScript执行
        time.sleep(3)

        # 获取完整HTML
        html = driver.page_source

        # 计算昨天的日期
        yesterday = datetime.now() - timedelta(days=1)
        date_suffix = yesterday.strftime("%Y%m%d")

        # 保存HTML用于调试
        html_file = OPENROUTER_DIR / f"page_{date_suffix}.html"
        with open(html_file, 'w', encoding='utf-8') as f:
            f.write(html)
        print(f"✓ 已保存HTML: {html_file}")

        # 使用正则表达式解析
        print("📊 正在解析HTML...")
        rankings = parse_html_content(html)

        return rankings, yesterday

    except Exception as e:
        print(f"❌ 爬取失败: {e}")
        import traceback
        traceback.print_exc()
        return None

    finally:
        driver.quit()

def save_results(data):
    """保存爬取结果"""
    if not data:
        print("❌ 没有数据可保存")
        return False

    rankings, target_date = data

    if not rankings:
        print("❌ 没有数据可保存")
        return False

    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    date_suffix = target_date.strftime("%Y%m%d")
    date_display = target_date.strftime("%Y年%m月%d日")

    # 计算总token和月度估算
    total_tokens = sum(r['tokens'] for r in rankings)
    monthly_estimate = total_tokens * 30
    monthly_estimate_t = round(monthly_estimate / 1_000_000_000_000, 2)

    # 保存原始JSON（包含月度估算）
    json_file = OPENROUTER_DIR / f"rankings_{date_suffix}.json"
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump({
            'crawl_time': timestamp,
            'target_date': target_date.strftime("%Y-%m-%d"),
            'source': 'OpenRouter Rankings (Day View)',
            'url': URL,
            'note': f'数据代表{date_display}的Token消耗',
            'statistics': {
                'total_tokens_per_day': total_tokens,
                'monthly_estimate_tokens': monthly_estimate,
                'monthly_estimate_t': monthly_estimate_t,
                'monthly_estimate_unit': 'T tokens',
                'model_count': len(rankings)
            },
            'rankings': rankings
        }, f, indent=2, ensure_ascii=False)

    print(f"✓ JSON已保存: {json_file}")

    # 计算总token消耗和市场份额
    total_tokens = sum(r['tokens'] for r in rankings)

    print(f"\n📊 数据摘要 ({date_display}):")
    print(f"  爬取时间: {timestamp}")
    print(f"  数据日期: {date_display}")
    print(f"  总Token消耗: {total_tokens:,} tokens/day")
    print(f"  月度估算: {total_tokens * 30 / 1_000_000_000_000:.2f} 万亿tokens/月")
    print(f"  统计模型数: {len(rankings)}")
    print(f"\nTop 10 模型:")

    vendor_tokens = {}
    for i, r in enumerate(rankings[:10], 1):
        print(f"  {i}. {r['model']}: {r['tokens'] / 1_000_000_000:.1f}B tokens/day")

        # 按厂商分类
        model_lower = r['model'].lower()
        if 'claude' in model_lower or 'anthropic' in model_lower:
            vendor_tokens['Anthropic'] = vendor_tokens.get('Anthropic', 0) + r['tokens']
        elif 'gpt' in model_lower or 'openai' in model_lower:
            vendor_tokens['OpenAI'] = vendor_tokens.get('OpenAI', 0) + r['tokens']
        elif 'gemini' in model_lower or 'google' in model_lower:
            vendor_tokens['Google'] = vendor_tokens.get('Google', 0) + r['tokens']
        elif 'deepseek' in model_lower:
            vendor_tokens['DeepSeek'] = vendor_tokens.get('DeepSeek', 0) + r['tokens']
        elif 'llama' in model_lower or 'mixtral' in model_lower or 'qwen' in model_lower:
            vendor_tokens['开源模型'] = vendor_tokens.get('开源模型', 0) + r['tokens']
        elif 'glm' in model_lower or 'minimax' in model_lower:
            vendor_tokens['中国厂商'] = vendor_tokens.get('中国厂商', 0) + r['tokens']

    # 计算市场份额
    print(f"\n📈 厂商份额（OpenRouter平台，{date_display}）:")
    for vendor, tokens in sorted(vendor_tokens.items(), key=lambda x: x[1], reverse=True):
        share = (tokens / total_tokens * 100) if total_tokens > 0 else 0
        print(f"  {vendor}: {share:.1f}% ({tokens / 1_000_000_000:.0f}B tokens/day)")

    return True

def main():
    """主函数"""
    print("=" * 60)
    print("OpenRouter Rankings 数据爬取 v3.0")
    print(f"运行时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

    # 计算目标日期（昨天）
    yesterday = datetime.now() - timedelta(days=1)
    print(f"目标日期: {yesterday.strftime('%Y年%m月%d日')} (昨天)")
    print("=" * 60)
    print()

    # 爬取数据
    result = scrape_openrouter()

    if result:
        # 保存结果
        if save_results(result):
            print("\n" + "=" * 60)
            print("✅ 爬取完成")
            print("=" * 60)
            return 0

    print("\n" + "=" * 60)
    print("❌ 爬取失败")
    print("=" * 60)
    print("\n💡 故障排查:")
    print("  1. 检查ChromeDriver: brew install chromedriver")
    print("  2. 查看HTML文件: data/openrouter/page_*.html")
    print("  3. 网页结构可能已变化")
    return 1

if __name__ == '__main__':
    exit(main())
