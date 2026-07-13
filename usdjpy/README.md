# USD/JPY汇率监控脚本

这个脚本每小时获取一次美元兑日元汇率，并记录到日志文件中。

## 文件说明

- `get_usdjpy.sh` - 主脚本，获取USD/JPY汇率
- `install_autostart.sh` - 安装开机自启动
- `uninstall_autostart.sh` - 卸载开机自启动
- `logs/` - 日志目录
  - `usdjpy_YYYYMMDD.log` - 每日日志文件
  - `usdjpy.csv` - CSV格式的历史数据

## 使用方法

### 手动运行
```bash
~/git/sh/usdjpy/get_usdjpy.sh
```

### 设置开机自启动（推荐）

**安装：**
```bash
~/git/sh/usdjpy/install_autostart.sh
```

**卸载：**
```bash
~/git/sh/usdjpy/uninstall_autostart.sh
```

**查看服务状态：**
```bash
launchctl list | grep usdjpy
```

### 查看日志

查看今天的日志：
```bash
tail -f ~/git/sh/usdjpy/logs/usdjpy_$(date +%Y%m%d).log
```

查看CSV数据：
```bash
cat ~/git/sh/usdjpy/logs/usdjpy.csv
```

## 数据源

脚本会按顺序尝试以下数据源（均为免费，无需API密钥）：

1. **fxratesapi.com** - 稳定的外汇汇率API ✅ (主要数据源)
2. **TradingEconomics** - 金融市场数据
3. **Yahoo Finance** - 金融数据平台

所有数据源当前均已验证可用。

## 汇率说明

- **货币对**: USD/JPY（美元兑日元）
- **单位**: 1美元 = X日元
- **更新频率**: 每小时（每小时整点）
- **市场时间**: 24小时外汇市场，周末可能无更新

## 汇率水平参考

USD/JPY历史参考：

- **100-110**: 日元相对强势
- **110-130**: 正常波动区间
- **130-150**: 日元相对弱势
- **150以上**: 日元极度弱势，可能引发干预

**当前汇率区间**: 约160日元（2026年）

## 影响因素

USD/JPY汇率主要受以下因素影响：

1. **利差**: 美日两国利率差异
2. **货币政策**: 美联储和日本央行政策
3. **风险偏好**: 避险情绪时日元升值
4. **贸易流动**: 日本进出口贸易
5. **政府干预**: 日本政府汇率干预

## 注意事项

- 外汇市场24小时交易，但周末流动性较低
- 汇率波动受多种因素影响，建议关注趋势
- 重大经济事件发布时汇率波动加剧

## 数据分析

CSV文件可以用Excel、Python pandas等工具进行分析：

```python
import pandas as pd
import matplotlib.pyplot as plt

# 读取汇率数据
df = pd.read_csv('~/git/sh/usdjpy/logs/usdjpy.csv')
df['时间戳'] = pd.to_datetime(df['时间戳'])

# 绘制汇率走势
plt.figure(figsize=(12, 6))
plt.plot(df['时间戳'], df['汇率(JPY)'])
plt.title('USD/JPY汇率走势')
plt.xlabel('时间')
plt.ylabel('汇率 (JPY)')
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()

# 计算统计数据
print(f"平均汇率: ¥{df['汇率(JPY)'].mean():.2f}")
print(f"最高汇率: ¥{df['汇率(JPY)'].max():.2f}")
print(f"最低汇率: ¥{df['汇率(JPY)'].min():.2f}")
print(f"波动率: {df['汇率(JPY)'].std():.2f}")

# 计算每日涨跌幅
df['涨跌'] = df['汇率(JPY)'].diff()
df['涨跌幅(%)'] = df['汇率(JPY)'].pct_change() * 100
print(f"\n今日涨跌: {df['涨跌'].iloc[-1]:.4f}")
print(f"今日涨跌幅: {df['涨跌幅(%)'].iloc[-1]:.2f}%")
```

## 相关链接

- [fxratesapi](https://fxratesapi.com/)
- [TradingEconomics - USD/JPY](https://tradingeconomics.com/usdjpy:cur)
- [日本央行](https://www.boj.or.jp/)
- [美联储](https://www.federalreserve.gov/)

## 扩展功能

未来可能添加的功能：
- 同时监控其他货币对（EUR/USD, GBP/USD等）
- 汇率预警功能（突破关键位时通知）
- 技术指标计算（移动平均线、RSI等）
- 与其他经济指标关联分析
