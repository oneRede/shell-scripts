# 美国经济季度数据监控

自动收集美国主要经济指标的季度数据，包括：GDP增长率、失业率、通货膨胀率、个人消费支出和消费者信心指数。

## 功能特点

- **多指标监控**：一次性收集5个核心经济指标
- **季度数据格式**：统一使用 `YYYY-Qn` 格式（如：2024-Q3）
- **增量更新**：已有数据保留，新数据自动追加
- **容错机制**：某项数据获取失败不影响其他数据
- **自动运行**：支持开机启动，每周一上午9:00自动更新

## 数据来源

所有数据来自美国联邦储备经济数据库（FRED）：

| 指标 | 数据源 | FRED代码 |
|------|--------|----------|
| GDP增长率 | Real GDP Growth Rate | A191RL1Q225SBEA |
| 失业率 | Unemployment Rate | UNRATE |
| 通货膨胀率 | Consumer Price Index | CPIAUCSL |
| 个人消费支出 | Personal Consumption Expenditures | PCE |
| 消费者信心指数 | University of Michigan Consumer Sentiment | UMCSENT |

## 安装

### 1. 手动运行测试

```bash
cd ~/git/sh/us-gdp
chmod +x get_us_economy.sh
./get_us_economy.sh
```

### 2. 安装开机自启动

```bash
chmod +x install_autostart.sh
./install_autostart.sh
```

安装后，脚本将：
- 开机时自动运行一次
- 每周一上午 9:00 自动运行

## 文件结构

```
us-gdp/
├── get_us_economy.sh              # 主数据收集脚本
├── install_autostart.sh           # 安装开机启动
├── uninstall_autostart.sh         # 卸载开机启动
├── com.user.us-economy-monitor.plist  # macOS launchd 配置
├── data/
│   └── us_economy_data.csv        # 经济数据记录（按日期）
├── logs/
│   ├── us_economy_YYYYMMDD.log    # 每日运行日志
│   ├── launchd.log                # launchd 标准输出
│   └── launchd_error.log          # launchd 错误日志
└── README.md                      # 本文件
```

## 数据格式

### CSV 文件示例 (us_economy_data.csv)

```csv
记录日期,GDP增长率(%),失业率(%),通货膨胀率(%),个人消费支出(%),消费者信心指数
2024-07-17,2.1,4.27,3.46,5.71,47.30
2024-07-24,2.1,4.30,3.50,5.75,48.00
2024-07-31,2.1,4.25,3.48,5.73,47.80
```

**说明**：
- 每次运行记录一行数据，以运行日期作为记录
- 每个指标只保留数值，简洁清晰
- 空值表示该次运行未能获取数据
- 可以看到数据随时间的变化趋势

## 管理命令

### 查看服务状态

```bash
launchctl list | grep us-economy
```

### 立即运行一次

```bash
launchctl start com.user.us-economy-monitor
```

或直接运行脚本：

```bash
./get_us_economy.sh
```

### 查看最新数据

```bash
cat data/us_economy_data.csv
```

### 查看运行日志

```bash
# 查看今天的日志
cat logs/us_economy_$(date +%Y%m%d).log

# 查看最近的日志
ls -lt logs/us_economy_*.log | head -5
```

### 卸载服务

```bash
./uninstall_autostart.sh
```

## 数据说明

### 1. GDP增长率
- **单位**：百分比（%）
- **类型**：季度环比年化增长率
- **更新频率**：每季度末发布（通常延迟1个月）

### 2. 失业率
- **单位**：百分比（%）
- **计算方式**：季度内月度失业率的平均值
- **更新频率**：每月更新

### 3. 通货膨胀率
- **单位**：百分比（%）
- **类型**：CPI同比增长率
- **更新频率**：每月更新

### 4. 个人消费支出
- **单位**：百分比（%）
- **类型**：同比增长率
- **更新频率**：每月更新

### 5. 消费者信心指数
- **单位**：指数值
- **计算方式**：季度内月度指数的平均值
- **更新频率**：每月更新

## 注意事项

1. **数据延迟**：经济数据通常有1-3个月的发布延迟，当前季度的数据可能不完整
2. **网络依赖**：需要网络连接才能获取数据
3. **数据修正**：FRED可能会修正历史数据，脚本会自动更新已有数据
4. **时区**：所有时间戳使用系统本地时区

## 故障排查

### 数据获取失败

查看日志文件了解详细错误：

```bash
tail -f logs/us_economy_$(date +%Y%m%d).log
```

常见原因：
- 网络连接问题
- FRED 服务暂时不可用
- Python3 未安装

### launchd 服务未运行

```bash
# 检查服务状态
launchctl list | grep us-economy

# 手动加载服务
launchctl load ~/Library/LaunchAgents/com.user.us-economy-monitor.plist

# 查看 launchd 错误日志
cat logs/launchd_error.log
```

## 数据访问建议

### 命令行查询

```bash
# 查看所有数据
column -t -s',' data/us_economy_quarterly.csv

# 查看最近5个季度
tail -6 data/us_economy_quarterly.csv | column -t -s','

# 只查看GDP和失业率
cut -d',' -f1,2,3 data/us_economy_quarterly.csv | column -t -s','
```

### 导入到 Excel/Numbers

直接打开 `data/us_economy_quarterly.csv` 文件即可。

### 编程访问

Python 示例：

```python
import pandas as pd

# 读取数据
df = pd.read_csv('~/git/sh/us-gdp/data/us_economy_quarterly.csv')

# 查看最近数据
print(df.tail())

# 绘图
df.plot(x='年季度', y=['GDP增长率(%)', '失业率(%)'])
```

## 参考链接

- [FRED 官网](https://fred.stlouisfed.org/)
- [美国经济分析局 (BEA)](https://www.bea.gov/)
- [美国劳工统计局 (BLS)](https://www.bls.gov/)

## 更新日志

- **2024-07-17**: 初始版本，支持5个核心经济指标
