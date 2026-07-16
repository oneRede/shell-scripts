# OpenRouter Token 监控系统

每日自动爬取 OpenRouter Rankings 页面，获取 AI 模型的真实 Token 消耗数据。

## 🎯 功能

- ✅ 每天自动运行（10:00，监控前一天数据）
- ✅ 开机自动运行（延迟10分钟）
- ✅ 无头浏览器爬取（Selenium + Chrome）
- ✅ JSON格式数据保存
- ✅ 自动计算厂商市场份额

## 🚀 快速开始

### 1. 安装依赖

```bash
cd ~/git/sh/ai-token-usage

# 安装 ChromeDriver 和 Python 依赖
./install_openrouter_deps.sh
```

### 2. 测试运行

```bash
# 手动运行一次测试
./scrape_openrouter.sh
```

### 3. 安装自动运行

```bash
# 安装 LaunchAgent（每天10:00 + 开机运行）
./install_openrouter_autostart.sh

# 查看服务状态
launchctl list | grep openrouter
```

## 📊 数据文件

### 输出位置

```
logs/openrouter/
├── rankings_YYYYMMDD.json    # 每日数据（JSON格式）
└── page_YYYYMMDD.html         # HTML备份
```

### JSON格式

```json
{
  "timestamp": "2026-07-16 14:07:39",
  "source": "OpenRouter Rankings (Day View)",
  "url": "https://openrouter.ai/rankings?view=day",
  "rankings": [
    {
      "model": "GLM 5.2",
      "tokens": 659000000000,
      "rank": 1
    }
  ]
}
```

## ⏰ 运行时间

- **每天 10:00** - 定时自动运行（获取昨天的完整数据）
- **开机 +10分钟** - 开机后首次运行

### 数据逻辑

```
今天: 7月16日 10:00
  ✅ 爬虫运行
  ✅ 获取7月15日（昨天）的完整24小时数据
  ✅ 保存为 rankings_20260715.json
  ✅ 文件名和数据都是7月15日

明天: 7月17日 10:00
  ✅ 爬虫运行
  ✅ 获取7月16日（昨天）的完整24小时数据
  ✅ 保存为 rankings_20260716.json
```

**关键点**：
- 运行日期 = 今天
- 数据日期 = 昨天
- 文件名 = 数据日期（昨天）
- 确保获取完整24小时数据

## 📈 数据示例（2026-07-16）

**每日Token消耗：** 2.96万亿 tokens/day  
**月度估算：** 88.92万亿 tokens/月

**Top 7 模型：**
1. GLM 5.2: 659B tokens/day (22.2%)
2. MiniMax M3: 592B tokens/day (20.0%)
3. Nemotron 3 Ultra: 453B tokens/day (15.3%)
4. Claude Opus 4.7: 373B tokens/day (12.6%)
5. DeepSeek V4 Pro: 370B tokens/day (12.5%)
6. Claude Opus 4.8: 362B tokens/day (12.2%)
7. Gemini 3 Flash: 155B tokens/day (5.2%)

**厂商份额（OpenRouter平台）：**
- 中国厂商（GLM+MiniMax）: 42.2%
- Anthropic（Claude）: 24.8%
- Nemotron: 15.3%
- DeepSeek: 12.5%
- Google（Gemini）: 5.2%

## 🔧 管理命令

```bash
# 查看服务状态
launchctl list | grep openrouter

# 手动触发运行
launchctl start com.user.openrouter-scraper

# 查看日志
tail -f ~/git/sh/ai-token-usage/logs/openrouter_launchd_output.log

# 查看最新数据
cat logs/openrouter/rankings_*.json | tail -50

# 卸载自启动
./uninstall_openrouter_autostart.sh
```

## 🔍 故障排查

### ChromeDriver 未安装

```bash
brew install chromedriver
xattr -d com.apple.quarantine $(which chromedriver)
```

### Selenium 未安装

```bash
pip3 install selenium
```

### 页面结构变化

查看保存的 HTML 文件：
```bash
open logs/openrouter/page_YYYYMMDD.html
```

## 📝 项目结构

```
~/git/sh/ai-token-usage/
├── scrape_openrouter.py           # Python爬虫（核心）
├── scrape_openrouter.sh           # Shell包装器
├── install_openrouter_deps.sh     # 依赖安装
├── install_openrouter_autostart.sh # 自启动安装
├── uninstall_openrouter_autostart.sh # 自启动卸载
├── com.user.openrouter-scraper.plist # LaunchAgent配置
├── requirements.txt               # Python依赖
├── .gitignore                    # Git配置
└── logs/openrouter/              # 数据目录
    ├── rankings_*.json           # 每日数据
    └── page_*.html              # HTML备份
```

## ⚠️ 重要说明

1. **数据范围**：OpenRouter数据仅代表该平台（约占全球0.25%流量）
2. **遵守规则**：遵守OpenRouter服务条款，每天仅运行1次
3. **数据外推**：需要结合其他数据源推算全球总量
4. **网站变化**：页面结构可能变化，需定期维护

## 📊 数据使用建议

OpenRouter数据最适合用于：
- ✅ 市场份额追踪（厂商竞争态势）
- ✅ 趋势分析（模型上升/下降）
- ✅ 新模型监测（上市影响）

不适合用于：
- ❌ 全球总量估算（样本太小）
- ❌ 绝对数值参考（仅0.25%流量）

## 🔗 相关链接

- **OpenRouter Rankings**: https://openrouter.ai/rankings
- **OpenRouter文档**: https://openrouter.ai/docs
- **Selenium文档**: https://selenium-python.readthedocs.io/

## 📌 版本信息

- **版本**: v2.2.0
- **状态**: 生产就绪
- **更新时间**: 2026-07-16
- **依赖**: ChromeDriver + Selenium

---

**创建时间**: 2026-07-16  
**最后更新**: 2026-07-16  
**维护状态**: 活跃维护
