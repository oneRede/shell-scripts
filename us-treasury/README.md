# 美国30年期国债收益率监控脚本

这个脚本每4小时获取一次美国30年期国债收益率，并记录到日志文件中。

## 文件说明

- `get_us_treasury.sh` - 主脚本，获取美国30年期国债收益率
- `install_autostart.sh` - 安装开机自启动
- `uninstall_autostart.sh` - 卸载开机自启动
- `logs/` - 日志目录
  - `us_treasury_YYYYMMDD.log` - 每日日志文件
  - `us_treasury.csv` - CSV格式的历史数据

## 使用方法

### 手动运行
```bash
~/git/sh/us-treasury/get_us_treasury.sh
```

### 设置开机自启动（推荐）

**安装：**
```bash
~/git/sh/us-treasury/install_autostart.sh
```

**卸载：**
```bash
~/git/sh/us-treasury/uninstall_autostart.sh
```

**查看服务状态：**
```bash
launchctl list | grep us-treasury
```

### 查看日志

查看今天的日志：
```bash
tail -f ~/git/sh/us-treasury/logs/us_treasury_$(date +%Y%m%d).log
```

查看CSV数据：
```bash
cat ~/git/sh/us-treasury/logs/us_treasury.csv
```

## 数据源

**主要数据源：TradingEconomics** ✅
- 稳定的经济数据API
- 提供美国30年期国债收益率
- 单位：百分比（%）
- 免费，无需API密钥

**备用数据源：**
- 美国财政部官网
- 美联储FRED数据库

## 数据说明

- **品种**: 美国30年期国债收益率（US 30-Year Treasury Yield）
- **单位**: 百分比（%）
- **更新频率**: 每4小时（0:00, 4:00, 8:00, 12:00, 16:00, 20:00）
- **市场时间**: 美国东部时间交易日有实时更新

## 收益率意义

美国30年期国债收益率是重要的经济指标：

- **基准利率**: 长期借贷成本的基准
- **经济预期**: 反映市场对未来30年经济和通胀的预期
- **风险偏好**: 避险情绪上升时，国债价格上涨，收益率下降
- **货币政策**: 受美联储政策影响显著

## 收益率水平参考

- **2-3%**: 低利率环境，经济增长放缓或宽松货币政策
- **3-4%**: 正常水平，经济稳定增长
- **4-5%**: 较高水平，可能面临通胀压力或紧缩政策
- **5%以上**: 高利率环境，强通胀或激进加息周期

## 注意事项

- 收益率每天波动，建议关注趋势而非单日变化
- 周末和节假日美国市场休市，数据可能不更新
- 收益率与债券价格成反比关系

## 数据分析

CSV文件可以用Excel、Python pandas等工具进行分析：

```python
import pandas as pd
import matplotlib.pyplot as plt

# 读取收益率数据
df = pd.read_csv('~/git/sh/us-treasury/logs/us_treasury.csv')
df['时间戳'] = pd.to_datetime(df['时间戳'])

# 绘制收益率曲线
plt.figure(figsize=(12, 6))
plt.plot(df['时间戳'], df['收益率(%)'])
plt.title('美国30年期国债收益率走势')
plt.xlabel('时间')
plt.ylabel('收益率 (%)')
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.show()

# 计算统计数据
print(f"平均收益率: {df['收益率(%)'].mean():.3f}%")
print(f"最高收益率: {df['收益率(%)'].max():.3f}%")
print(f"最低收益率: {df['收益率(%)'].min():.3f}%")
print(f"标准差: {df['收益率(%)'].std():.3f}%")
```

## 相关链接

- [TradingEconomics - 美国国债收益率](https://tradingeconomics.com/united-states/government-bond-yield)
- [美国财政部 - 利率统计](https://home.treasury.gov/policy-issues/financing-the-government/interest-rate-statistics)
- [FRED - 30年期国债收益率](https://fred.stlouisfed.org/series/DGS30)
- [美联储官网](https://www.federalreserve.gov/)

## 扩展功能

未来可能添加的功能：
- 同时监控2年期、10年期国债收益率
- 计算收益率曲线倒挂指标（2年期-10年期利差）
- 收益率突破关键点位时发送通知
- 与其他经济指标联动分析
