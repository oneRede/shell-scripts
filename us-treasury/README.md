# 美国30年期国债收益率及国债总量监控脚本

这个脚本每4小时获取一次美国30年期国债收益率和美国国债总量，并记录到日志文件中。

## 文件说明

- `get_us_treasury.sh` - 主脚本，获取美国30年期国债收益率和国债总量
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

**主要数据源：**

1. **国债收益率 - TradingEconomics** ✅
   - 稳定的经济数据API
   - 提供美国30年期国债收益率
   - 单位：百分比（%）
   - 免费，无需API密钥

2. **国债总量 - FRED (联邦储备经济数据库)** ✅
   - 美国联邦政府总债务
   - 数据代码：GFDEBTN
   - 单位：亿美元
   - 季度更新

**备用数据源：**
- 美国财政部官网
- 美联储FRED数据库（国债收益率）

## 数据说明

### 国债收益率
- **品种**: 美国30年期国债收益率（US 30-Year Treasury Yield）
- **单位**: 百分比（%）
- **更新频率**: 每4小时（0:00, 4:00, 8:00, 12:00, 16:00, 20:00）
- **市场时间**: 美国东部时间交易日有实时更新

### 国债总量
- **品种**: 美国联邦政府总债务（Federal Debt Total Public Debt）
- **单位**: 亿美元（从百万美元转换）
- **更新频率**: 季度更新（每季度末）
- **数据来源**: FRED - GFDEBTN

### CSV 格式
```csv
时间戳,收益率(%),国债总量(亿美元),数据源
2026-07-17 09:43:52,4.566,390654.21,TradingEconomics
```

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

# 读取数据
df = pd.read_csv('~/git/sh/us-treasury/logs/us_treasury.csv')
df['时间戳'] = pd.to_datetime(df['时间戳'])

# 绘制双Y轴图表
fig, ax1 = plt.subplots(figsize=(12, 6))

# 左Y轴 - 收益率
ax1.set_xlabel('时间')
ax1.set_ylabel('收益率 (%)', color='tab:blue')
ax1.plot(df['时间戳'], df['收益率(%)'], color='tab:blue', label='30年期国债收益率')
ax1.tick_params(axis='y', labelcolor='tab:blue')
ax1.grid(True, alpha=0.3)

# 右Y轴 - 国债总量
ax2 = ax1.twinx()
ax2.set_ylabel('国债总量 (亿美元)', color='tab:red')
ax2.plot(df['时间戳'], df['国债总量(亿美元)'], color='tab:red', label='国债总量')
ax2.tick_params(axis='y', labelcolor='tab:red')

plt.title('美国30年期国债收益率与国债总量走势')
fig.tight_layout()
plt.show()

# 计算统计数据
print(f"平均收益率: {df['收益率(%)'].mean():.3f}%")
print(f"最高收益率: {df['收益率(%)'].max():.3f}%")
print(f"最低收益率: {df['收益率(%)'].min():.3f}%")
print(f"最新国债总量: {df['国债总量(亿美元)'].iloc[-1]:.2f}亿美元")
```

## 相关链接

- [TradingEconomics - 美国国债收益率](https://tradingeconomics.com/united-states/government-bond-yield)
- [美国财政部 - 利率统计](https://home.treasury.gov/policy-issues/financing-the-government/interest-rate-statistics)
- [FRED - 30年期国债收益率](https://fred.stlouisfed.org/series/DGS30)
- [FRED - 美国国债总量](https://fred.stlouisfed.org/series/GFDEBTN)
- [美联储官网](https://www.federalreserve.gov/)

## 扩展功能

未来可能添加的功能：
- 同时监控2年期、10年期国债收益率
- 计算收益率曲线倒挂指标（2年期-10年期利差）
- 收益率突破关键点位时发送通知
- 与其他经济指标联动分析
