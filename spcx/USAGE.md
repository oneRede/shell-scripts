# SPCX.O 股价监控系统使用指南

## ⚠️ 重要说明

由于东方财富 API 在自动化脚本中可能受到访问限制，本项目提供了多种数据获取方式。

## 📊 SpaceX 股价信息

**验证信息（2026-07-13）：**
- ✅ SpaceX 已在东方财富网上市交易
- 股票代码: SPCX
- 最新价格: $145.30
- 涨跌: -$6.86 (-4.51%)
- 成交量: 46,825,995
- **重要**: 东方财富API美股价格字段需除以1000（已修正）

## 🔍 查看实时股价

### 方法1: 东方财富网页版
访问: http://quote.eastmoney.com/us/SPCX.html

### 方法2: 新浪财经
访问: https://finance.sina.com.cn/stock/usstock/

### 方法3: 腾讯财经
访问: https://gu.qq.com/us/SPCX

## 📝 数据录入方式

由于 API 限制，提供以下方式记录股价数据：

### 方式1: 手动录入脚本（推荐）

```bash
~/git/sh/spcx/manual_input.sh
```

该脚本会提示你输入从网页查看的价格信息，自动保存到日志和CSV文件。

### 方式2: 浏览器自动化（待实现）

可以使用 Selenium 或 Puppeteer 自动抓取网页数据。

### 方式3: 修改脚本使用其他API

如果你有其他可用的股票 API（如 Alpha Vantage、IEX Cloud 等），可以修改 `get_spcx_price.sh` 添加相应的数据源。

## 🚀 自动监控设置

### 当前状态
- ❌ 自动API暂时不可用
- ✅ 手动录入脚本可用
- ✅ 数据存储和日志系统正常

### 临时解决方案

每10分钟手动运行：
```bash
# 设置定时提醒（macOS）
(crontab -l 2>/dev/null; echo "*/10 * * * * osascript -e 'display notification \"请更新 SPCX 股价\" with title \"股价监控提醒\"'") | crontab -
```

### 自动化方案（需要配置）

1. **使用付费API服务**
   - Alpha Vantage (免费层级: 5次/分钟)
   - IEX Cloud (免费层级: 50,000次/月)
   - Finnhub (免费层级: 60次/分钟)

2. **使用浏览器自动化**
   ```bash
   # 安装 Selenium
   pip3 install selenium webdriver-manager
   ```

3. **使用代理服务**
   如果是IP被限制，可以配置代理访问东方财富API

## 📈 数据文件位置

- **每日日志**: `~/git/sh/spcx/logs/spcx_price_YYYYMMDD.log`
- **CSV数据**: `~/git/sh/spcx/logs/spcx_price.csv`
- **系统日志**: `~/git/sh/spcx/logs/launchd.out.log`

## 🔧 故障排查

### 问题1: API 返回 502 错误
**原因**: 东方财富服务器限制或网络问题  
**解决**: 使用手动录入脚本或配置代理

### 问题2: 数据为空
**原因**: 股票代码不正确或市场休市  
**解决**: 确认股票代码，检查交易时间

### 问题3: LaunchAgent 未运行
**解决**:
```bash
# 检查状态
launchctl list | grep spcx-price

# 重新加载
launchctl unload ~/Library/LaunchAgents/com.user.spcx-price-monitor.plist
launchctl load ~/Library/LaunchAgents/com.user.spcx-price-monitor.plist
```

## 💡 推荐工作流程

1. **每10分钟**访问东方财富网查看实时价格
2. 运行 `~/git/sh/spcx/manual_input.sh` 录入数据
3. 数据自动保存到 CSV 文件
4. 定期提交到 Git 仓库：
   ```bash
   cd ~/git/sh
   git add spcx/logs/spcx_price.csv
   git commit -m "Update SPCX stock data"
   git push
   ```

## 📊 数据分析

查看CSV数据：
```bash
cat ~/git/sh/spcx/logs/spcx_price.csv | column -t -s,
```

使用 Python 分析：
```python
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('~/git/sh/spcx/logs/spcx_price.csv')
df['时间戳'] = pd.to_datetime(df['时间戳'])

plt.figure(figsize=(12, 6))
plt.plot(df['时间戳'], df['价格(USD)'])
plt.title('SPCX 股价走势')
plt.xlabel('时间')
plt.ylabel('价格 (USD)')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
```

## 🔄 自动推送到 GitHub

创建自动提交脚本 `auto_commit.sh`:
```bash
#!/bin/bash
cd ~/git/sh
git add spcx/logs/spcx_price.csv
git commit -m "Update SPCX: $(tail -1 spcx/logs/spcx_price.csv | cut -d',' -f2) - $(date '+%Y-%m-%d %H:%M')"
git push
```

添加到 crontab（每小时提交一次）：
```bash
0 * * * * ~/git/sh/spcx/auto_commit.sh >> ~/git/sh/spcx/logs/git_push.log 2>&1
```

## 📞 技术支持

如果需要实现全自动化监控，可以考虑：
1. 申请付费API密钥
2. 配置浏览器自动化
3. 使用VPN或代理服务
4. 联系东方财富申请API访问权限

---

**最后更新**: 2026-07-13  
**状态**: 手动录入模式运行中
