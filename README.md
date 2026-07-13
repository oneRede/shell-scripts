# Shell脚本集合

这是一个包含多个实用监控脚本的仓库，主要用于价格监控和系统监控。

## 📁 项目结构

```
sh/
├── gold/           # 黄金价格监控
├── lithium/        # 碳酸锂价格监控
├── us-treasury/    # 美国30年期国债收益率监控
├── usdjpy/         # USD/JPY汇率监控
├── oil/            # 原油价格监控
├── natural-gas/    # 天然气价格监控
└── monitor_ip/     # IP监控脚本
```

## 🔥 价格监控系统

### 1. 黄金价格监控 (`gold/`)

每10分钟自动获取国际黄金价格（XAU/USD）。

**功能特点：**
- ✅ 实时黄金价格监控
- ✅ 数据源：fxratesapi.com（免费API）
- ✅ 开机自启动支持
- ✅ 双格式记录（日志 + CSV）

**使用方法：**
```bash
# 安装开机自启动
~/git/sh/gold/install_autostart.sh

# 手动运行
~/git/sh/gold/get_gold_price.sh

# 查看日志
tail -f ~/git/sh/gold/logs/gold_price_$(date +%Y%m%d).log
```

**当前价格：** $4,067.35 /盎司

### 2. 碳酸锂价格监控 (`lithium/`)

每10分钟自动获取中国市场碳酸锂价格。

**功能特点：**
- ✅ 电池级碳酸锂价格监控
- ✅ 数据源：TradingEconomics（免费API）
- ✅ 开机自启动支持
- ✅ 双格式记录（日志 + CSV）

**使用方法：**
```bash
# 安装开机自启动
~/git/sh/lithium/install_autostart.sh

# 手动运行
~/git/sh/lithium/get_lithium_price.sh

# 查看日志
tail -f ~/git/sh/lithium/logs/lithium_price_$(date +%Y%m%d).log
```

**当前价格：** ¥155,000 /吨

### 3. 美国30年期国债收益率监控 (`us-treasury/`)

每4小时自动获取美国30年期国债收益率。

**功能特点：**
- ✅ 美国30年期国债收益率监控
- ✅ 数据源：TradingEconomics（免费API）
- ✅ 开机自启动支持
- ✅ 双格式记录（日志 + CSV）
- ✅ 每天6次采集（0:00, 4:00, 8:00, 12:00, 16:00, 20:00）

**使用方法：**
```bash
# 安装开机自启动
~/git/sh/us-treasury/install_autostart.sh

# 手动运行
~/git/sh/us-treasury/get_us_treasury.sh

# 查看日志
tail -f ~/git/sh/us-treasury/logs/us_treasury_$(date +%Y%m%d).log
```

**当前收益率：** 4.587%

### 4. USD/JPY汇率监控 (`usdjpy/`)

每小时自动获取美元兑日元汇率。

**功能特点：**
- ✅ USD/JPY实时汇率监控
- ✅ 多数据源备份（fxratesapi、TradingEconomics、Yahoo Finance）
- ✅ 开机自启动支持
- ✅ 双格式记录（日志 + CSV）
- ✅ 每小时整点采集

**使用方法：**
```bash
# 安装开机自启动
~/git/sh/usdjpy/install_autostart.sh

# 手动运行
~/git/sh/usdjpy/get_usdjpy.sh

# 查看日志
tail -f ~/git/sh/usdjpy/logs/usdjpy_$(date +%Y%m%d).log
```

**当前汇率：** ¥162.09

### 5. 原油价格监控 (`oil/`)

每小时自动获取WTI原油价格。

**功能特点：**
- ✅ WTI原油价格监控
- ✅ 数据源：TradingEconomics（免费API）
- ✅ 开机自启动支持
- ✅ 日志记录
- ✅ 每小时整点采集

**使用方法：**
```bash
# 安装开机自启动
~/git/sh/oil/install_autostart.sh

# 手动运行
~/git/sh/oil/get_oil_price.sh

# 查看日志
tail -f ~/git/sh/oil/logs/oil_price_$(date +%Y%m%d).log
```

**当前价格：** $74.43/桶

### 6. 天然气价格监控 (`natural-gas/`)

每小时自动获取天然气价格。

**功能特点：**
- ✅ 天然气期货价格监控
- ✅ 数据源：TradingEconomics（免费API）
- ✅ 开机自启动支持
- ✅ 日志记录
- ✅ 每小时整点采集

**使用方法：**
```bash
# 安装开机自启动
~/git/sh/natural-gas/install_autostart.sh

# 手动运行
~/git/sh/natural-gas/get_natural_gas.sh

# 查看日志
tail -f ~/git/sh/natural-gas/logs/natural_gas_$(date +%Y%m%d).log
```

**当前价格：** $2.90/MMBtu

## 🛠️ 系统监控

### 7. IP监控 (`monitor_ip/`)

IP地址变化监控脚本。

## 📊 数据格式

所有价格监控脚本都会生成两种格式的数据：

1. **文本日志** (`logs/*.log`)：便于人类阅读
2. **CSV文件** (`logs/*.csv`)：便于数据分析

CSV格式示例：
```csv
时间戳,价格,数据源
2026-07-13 10:30:16,4067.99,fxratesapi.com
2026-07-13 10:40:21,4068.15,fxratesapi.com
```

## 🚀 快速开始

### 安装所有监控系统

```bash
# 黄金价格监控（每10分钟）
~/git/sh/gold/install_autostart.sh

# 碳酸锂价格监控（每10分钟）
~/git/sh/lithium/install_autostart.sh

# 美国30年期国债收益率监控（每4小时）
~/git/sh/us-treasury/install_autostart.sh

# USD/JPY汇率监控（每小时）
~/git/sh/usdjpy/install_autostart.sh

# 原油价格监控（每小时）
~/git/sh/oil/install_autostart.sh

# 天然气价格监控（每小时）
~/git/sh/natural-gas/install_autostart.sh
```

### 查看所有运行中的服务

```bash
launchctl list | grep -E "(gold-price|lithium-price|us-treasury|usdjpy|oil-price|natural-gas)"
```

### 卸载所有监控系统

```bash
~/git/sh/gold/uninstall_autostart.sh
~/git/sh/lithium/uninstall_autostart.sh
~/git/sh/us-treasury/uninstall_autostart.sh
~/git/sh/usdjpy/uninstall_autostart.sh
~/git/sh/oil/uninstall_autostart.sh
~/git/sh/natural-gas/uninstall_autostart.sh
```

## 💡 技术栈

- **Shell Script** - 主要脚本语言
- **Python3** - JSON解析和数据处理
- **macOS LaunchAgent** - 开机自启动和定时任务
- **curl** - HTTP请求

## 📈 数据分析示例

使用Python分析价格数据：

```python
import pandas as pd
import matplotlib.pyplot as plt

# 读取黄金价格数据
df_gold = pd.read_csv('~/git/sh/gold/logs/gold_price.csv')
df_gold['时间戳'] = pd.to_datetime(df_gold['时间戳'])

# 绘制价格趋势
plt.figure(figsize=(12, 6))
plt.plot(df_gold['时间戳'], df_gold['价格(USD/盎司)'])
plt.title('黄金价格趋势')
plt.xlabel('时间')
plt.ylabel('价格 (USD/盎司)')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
```

## 📝 开发计划

- [ ] 添加价格预警功能（价格突破阈值时发送通知）
- [ ] 支持更多商品价格监控（原油、铜、镍等）
- [ ] Web界面展示价格趋势图表
- [ ] 支持数据导出到数据库
- [ ] 添加价格预测功能

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📄 许可

MIT License

## 🔗 相关链接

- [TradingEconomics](https://tradingeconomics.com/)
- [fxratesapi](https://fxratesapi.com/)
- [macOS LaunchAgent 文档](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)

---

**最后更新：** 2026-07-13
