# 碳酸锂价格监控脚本

这个脚本每10分钟获取一次碳酸锂价格（电池级碳酸锂），并记录到日志文件中。

## 文件说明

- `get_lithium_price.sh` - 主脚本，获取碳酸锂价格
- `install_autostart.sh` - 安装开机自启动
- `uninstall_autostart.sh` - 卸载开机自启动
- `logs/` - 日志目录
  - `lithium_price_YYYYMMDD.log` - 每日日志文件
  - `lithium_price.csv` - CSV格式的历史数据

## 使用方法

### 手动运行
```bash
~/git/sh/lithium/get_lithium_price.sh
```

### 设置开机自启动（推荐）

**安装：**
```bash
~/git/sh/lithium/install_autostart.sh
```

**卸载：**
```bash
~/git/sh/lithium/uninstall_autostart.sh
```

**查看服务状态：**
```bash
launchctl list | grep lithium-price
```

### 查看日志

查看今天的日志：
```bash
tail -f ~/git/sh/lithium/logs/lithium_price_$(date +%Y%m%d).log
```

查看CSV数据：
```bash
cat ~/git/sh/lithium/logs/lithium_price.csv
```

## 数据源

**主要数据源：TradingEconomics** ✅
- 稳定的商品价格数据API
- 提供中国市场碳酸锂价格
- 单位：人民币/吨（CNY/ton）
- 免费，无需API密钥

**备用数据源：**
- 上海有色网 (SMM)
- 生意社

## 价格说明

- **品种**: 电池级碳酸锂（99.5% Li2CO3 min）
- **市场**: 中国市场价格
- **单位**: 人民币/吨（CNY/ton）
- **更新频率**: 每10分钟

## 注意事项

- 碳酸锂价格波动较大，受新能源汽车市场影响明显
- 价格为现货价格或期货价格，具体以数据源标注为准
- 建议结合多个数据源综合判断市场趋势

## 数据分析

CSV文件可以用Excel、Python pandas等工具进行分析：

```python
import pandas as pd
df = pd.read_csv('~/git/sh/lithium/logs/lithium_price.csv')
print(df.describe())

# 计算价格变化
df['价格变化'] = df['价格(CNY/吨)'].diff()
print(df.tail(10))
```

## 相关链接

- [TradingEconomics - 碳酸锂](https://tradingeconomics.com/commodity/lithium)
- [上海有色网](https://www.smm.cn/)
- [生意社 - 碳酸锂](https://www.100ppi.com/)
