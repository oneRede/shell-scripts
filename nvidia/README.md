# NVIDIA (NVDA) 股价监控

自动监控 NVIDIA (NVDA) 股价，每10分钟更新一次并自动推送到 GitHub。

## ✅ 股票信息

**NVIDIA Corporation (NVDA)**
- 股票代码: NVDA
- 交易所: 纳斯达克 (NASDAQ)
- 行业: 半导体 / AI芯片
- 数据源: 东方财富网
- **重要**: 使用除以1000的换算规则（美股标准）

## 📁 项目结构

```
~/git/sh/nvidia/
├── README.md                    # 项目说明
├── get_nvda_price.sh           # 自动获取股价脚本
├── manual_input.sh             # 手动录入脚本 ⭐
├── auto_commit.sh              # 自动提交到 GitHub
├── install_autostart.sh        # 安装开机自启动
├── uninstall_autostart.sh      # 卸载自启动
├── com.user.nvda-price-monitor.plist  # LaunchAgent 配置
└── logs/
    ├── nvda_price.csv          # 历史数据 (CSV格式)
    └── nvda_price_YYYYMMDD.log # 每日日志
```

## 🚀 快速开始

### 方式1: 手动录入 (推荐)

由于 API 限制，推荐使用手动录入方式：

```bash
# 1. 访问东方财富网查看实时价格
# http://quote.eastmoney.com/us/NVDA.html

# 2. 运行手动录入脚本
~/git/sh/nvidia/manual_input.sh

# 3. 按提示输入价格信息
# 4. 数据自动保存到 CSV 和日志文件
```

### 方式2: 自动监控 (需要配置API)

```bash
# 安装开机自启动
~/git/sh/nvidia/install_autostart.sh

# 卸载
~/git/sh/nvidia/uninstall_autostart.sh
```

## 📊 查看数据

```bash
# 查看今日日志
tail -f ~/git/sh/nvidia/logs/nvda_price_$(date +%Y%m%d).log

# 查看 CSV 数据
cat ~/git/sh/nvidia/logs/nvda_price.csv | column -t -s,

# 查看最新价格
tail -1 ~/git/sh/nvidia/logs/nvda_price.csv
```

## 🔄 推送到 GitHub

### 手动推送

```bash
cd ~/git/sh
git add nvidia/logs/nvda_price.csv
git commit -m "Update NVDA stock data"
git push
```

### 自动推送 (每小时)

```bash
# 添加到 crontab
(crontab -l 2>/dev/null; echo "0 * * * * ~/git/sh/nvidia/auto_commit.sh >> ~/git/sh/nvidia/logs/git_push.log 2>&1") | crontab -

# 查看 crontab
crontab -l

# 删除自动推送
crontab -l | grep -v "nvidia/auto_commit.sh" | crontab -
```

## 📈 数据分析

使用 Python 分析股价数据：

```python
import pandas as pd
import matplotlib.pyplot as plt

# 读取数据
df = pd.read_csv('~/git/sh/nvidia/logs/nvda_price.csv')
df['时间戳'] = pd.to_datetime(df['时间戳'])

# 绘制价格走势
plt.figure(figsize=(14, 6))
plt.plot(df['时间戳'], df['价格(USD)'], marker='o', linewidth=2)
plt.title('NVIDIA (NVDA) 股价走势', fontsize=16)
plt.xlabel('时间')
plt.ylabel('价格 (USD)')
plt.grid(True, alpha=0.3)
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# 统计信息
print(f"当前价格: ${df['价格(USD)'].iloc[-1]:.2f}")
print(f"最高价格: ${df['价格(USD)'].max():.2f}")
print(f"最低价格: ${df['价格(USD)'].min():.2f}")
print(f"平均价格: ${df['价格(USD)'].mean():.2f}")
print(f"价格波动: ${df['价格(USD)'].std():.2f}")
```

## 🔧 管理命令

### 查看服务状态

```bash
launchctl list | grep nvda-price
```

### 卸载自启动

```bash
~/git/sh/nvidia/uninstall_autostart.sh
```

### 手动停止服务

```bash
launchctl unload ~/Library/LaunchAgents/com.user.nvda-price-monitor.plist
```

### 手动启动服务

```bash
launchctl load ~/Library/LaunchAgents/com.user.nvda-price-monitor.plist
```

## 📝 数据格式

CSV 文件格式：
```csv
时间戳,价格(USD),开盘价,最高价,最低价,成交量,涨跌额,涨跌幅(%),数据源
2026-07-13 19:35:00,125.45,124.80,126.20,124.50,28456789,+0.85,+0.68,东方财富网
```

## 💡 使用提示

1. **交易时间**: 美股交易时间为北京时间 21:30-04:00（夏令时）或 22:30-05:00（冬令时）
2. **数据更新**: 建议在交易时间内每10分钟更新一次
3. **数据备份**: CSV 文件应定期备份或推送到 GitHub
4. **API限制**: 如遇东方财富 API 限制，使用手动录入模式

## 🔗 相关链接

- **东方财富网**: http://quote.eastmoney.com/us/NVDA.html
- **Yahoo Finance**: https://finance.yahoo.com/quote/NVDA
- **NVIDIA 官网**: https://www.nvidia.com/
- **NASDAQ**: https://www.nasdaq.com/market-activity/stocks/nvda

## 📚 相关项目

- [SpaceX 股价监控](../spcx/)
- [黄金价格监控](../gold/)
- [碳酸锂价格监控](../lithium/)
- [USD/JPY汇率监控](../usdjpy/)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可

MIT License

---

**创建时间**: 2026-07-13  
**状态**: ✅ 手动录入模式正常运行  
**数据换算**: 除以 1000（美股标准）
