# Shell脚本集合

这是一个包含多个实用监控脚本的仓库，主要用于价格监控和系统监控。

## 📁 项目结构

```
sh/
├── gold/           # 黄金价格监控
├── lithium/        # 碳酸锂价格监控
├── us-treasury/    # 美国30年期国债收益率监控
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

## 🛠️ 系统监控

### 4. IP监控 (`monitor_ip/`)

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
```

### 查看所有运行中的服务

```bash
launchctl list | grep -E "(gold-price|lithium-price|us-treasury)"
```

### 卸载所有监控系统

```bash
~/git/sh/gold/uninstall_autostart.sh
~/git/sh/lithium/uninstall_autostart.sh
~/git/sh/us-treasury/uninstall_autostart.sh
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
