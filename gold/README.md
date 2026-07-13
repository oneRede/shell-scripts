# 黄金价格监控脚本

这个脚本每分钟获取一次黄金交易价格（XAU/USD），并记录到日志文件中。

## 文件说明

- `get_gold_price.sh` - 主脚本，获取黄金价格
- `logs/` - 日志目录
  - `gold_price_YYYYMMDD.log` - 每日日志文件
  - `gold_price.csv` - CSV格式的历史数据

## 使用方法

### 手动运行
```bash
~/git/sh/gold/get_gold_price.sh
```

### 方式一：开机自启动（推荐）

使用macOS的LaunchAgent实现开机自启动和定时运行：

**安装开机自启动：**
```bash
~/git/sh/gold/install_autostart.sh
```

**卸载开机自启动：**
```bash
~/git/sh/gold/uninstall_autostart.sh
```

**查看服务状态：**
```bash
launchctl list | grep gold-price
```

**优点：**
- ✅ 开机自动启动
- ✅ 系统级守护进程，更稳定
- ✅ 独立的日志文件（launchd.out.log / launchd.err.log）
- ✅ 重启后自动恢复运行

---

### 方式二：使用Cron定时任务

**安装Cron任务：**
```bash
~/git/sh/gold/install_cron.sh
```

**卸载Cron任务：**
```bash
~/git/sh/gold/uninstall_cron.sh
```

**手动配置：**
```bash
crontab -e
# 添加: */10 * * * * /Users/rede/git/sh/gold/get_gold_price.sh >> /Users/rede/git/sh/gold/logs/cron.log 2>&1
```

**注意：** Cron方式需要确保系统允许cron运行（系统偏好设置 → 安全性与隐私）

### 查看日志

查看今天的日志：
```bash
tail -f ~/git/sh/gold/logs/gold_price_$(date +%Y%m%d).log
```

查看CSV数据：
```bash
cat ~/git/sh/gold/logs/gold_price.csv
```

## 数据源

脚本会按顺序尝试以下数据源（均为免费，无需API密钥）：
1. **fxratesapi.com** - 稳定的外汇汇率API，提供实时黄金价格 ✅
2. **Yahoo Finance** - 黄金期货价格（GC=F）
3. **东方财富网** - 国内伦敦金价格数据

当前主要数据源：fxratesapi.com（已验证可用）

## 注意事项

- 每10分钟获取一次价格，避免API限流
- 价格单位：美元/盎司（USD per ounce）
- 数据源会自动切换，优先使用最稳定的API
- 所有数据源均为免费，无需申请API密钥

## 停止定时任务

```bash
crontab -e
# 删除或注释掉相关行
```

## 数据分析

CSV文件可以用Excel、Python pandas等工具进行分析：

```python
import pandas as pd
df = pd.read_csv('~/git/sh/gold/logs/gold_price.csv')
print(df.describe())
```
