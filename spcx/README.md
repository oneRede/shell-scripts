# SPCX.O Stock Monitor

SpaceX (SPCX) 股价监控系统 - 每10分钟自动更新并推送到 GitHub

## ✅ 已验证信息

**SpaceX 股票信息** (2026-07-13):
- 股票代码: SPCX
- 交易所: 东方财富网可查询
- 最新价格: $145.30
- 涨跌: -$6.86 (-4.51%)
- 开盘: $150.13 | 最高: $150.57 | 最低: $145.07
- 成交量: 46,825,995
- **注意**: 东方财富API对美股价格需除以1000（已修正）

## 📁 项目结构

```
~/git/sh/spcx/
├── README.md                    # 项目说明
├── USAGE.md                     # 详细使用指南
├── get_spcx_price.sh           # 自动获取股价脚本
├── manual_input.sh             # 手动录入脚本 ⭐
├── auto_commit.sh              # 自动提交到 GitHub
├── install_autostart.sh        # 安装开机自启动
├── uninstall_autostart.sh      # 卸载自启动
├── com.user.spcx-price-monitor.plist  # LaunchAgent 配置
└── logs/
    ├── spcx_price.csv          # 历史数据 (CSV格式)
    └── spcx_price_YYYYMMDD.log # 每日日志
```

## 🚀 快速开始

### 方式1: 手动录入 (推荐)

由于 API 限制，推荐使用手动录入方式：

```bash
# 1. 访问东方财富网查看实时价格
# http://quote.eastmoney.com/us/SPCX.html

# 2. 运行手动录入脚本
~/git/sh/spcx/manual_input.sh

# 3. 按提示输入价格信息
# 4. 数据自动保存到 CSV 和日志文件
```

### 方式2: 自动监控 (需要配置API)

```bash
# 安装开机自启动
~/git/sh/spcx/install_autostart.sh

# 卸载
~/git/sh/spcx/uninstall_autostart.sh
```

## 📊 查看数据

```bash
# 查看今日日志
tail -f ~/git/sh/spcx/logs/spcx_price_$(date +%Y%m%d).log

# 查看 CSV 数据
cat ~/git/sh/spcx/logs/spcx_price.csv | column -t -s,

# 查看最新价格
tail -1 ~/git/sh/spcx/logs/spcx_price.csv
```

## 🔄 推送到 GitHub

### 手动推送

```bash
cd ~/git/sh
git add spcx/logs/spcx_price.csv
git commit -m "Update SPCX stock data"
git push
```

### 自动推送 (每小时)

```bash
# 添加到 crontab
(crontab -l 2>/dev/null; echo "0 * * * * ~/git/sh/spcx/auto_commit.sh >> ~/git/sh/spcx/logs/git_push.log 2>&1") | crontab -

# 查看 crontab
crontab -l

# 删除自动推送
crontab -l | grep -v "auto_commit.sh" | crontab -
```

## 📈 数据分析

使用 Python 分析股价数据：

```python
import pandas as pd
import matplotlib.pyplot as plt

# 读取数据
df = pd.read_csv('~/git/sh/spcx/logs/spcx_price.csv')
df['时间戳'] = pd.to_datetime(df['时间戳'])

# 绘制价格走势
plt.figure(figsize=(14, 6))
plt.plot(df['时间戳'], df['价格(USD)'], marker='o')
plt.title('SpaceX (SPCX) 股价走势', fontsize=16)
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
```

## 🔧 故障排查

### 问题: 自动获取股价失败

**原因**: 东方财富 API 在自动化脚本中受限制

**解决方案**:
1. 使用 `manual_input.sh` 手动录入
2. 配置付费 API (Alpha Vantage, IEX Cloud, Finnhub)
3. 使用浏览器自动化 (Selenium)
4. 配置代理服务器

详细说明请查看 [USAGE.md](USAGE.md)

## 📝 数据格式

CSV 文件格式：
```csv
时间戳,价格(USD),开盘价,最高价,最低价,成交量,涨跌额,涨跌幅(%),数据源
2026-07-13 19:30:00,145.30,150.13,150.57,145.07,46825995,-6.86,-4.51,东方财富网(修正后)
```

## 🔗 相关链接

- **东方财富网**: http://quote.eastmoney.com/us/SPCX.html
- **新浪财经**: https://finance.sina.com.cn/stock/usstock/
- **腾讯财经**: https://gu.qq.com/

## 📚 相关项目

- [黄金价格监控](../gold/)
- [碳酸锂价格监控](../lithium/)
- [USD/JPY汇率监控](../usdjpy/)
- [原油价格监控](../oil/)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可

MIT License

---

**最后更新**: 2026-07-13  
**状态**: ✅ 手动录入模式正常运行 | 换算规则已修正  
**股价**: $145.30 (-4.51%)
