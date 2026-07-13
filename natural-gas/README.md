# 天然气价格监控脚本

每小时获取天然气价格并记录到日志。

## 使用方法

### 手动运行
```bash
~/git/sh/natural-gas/get_natural_gas.sh
```

### 开机自启动
```bash
# 安装
~/git/sh/natural-gas/install_autostart.sh

# 卸载
~/git/sh/natural-gas/uninstall_autostart.sh
```

## 数据说明

- **品种**: 天然气期货
- **单位**: 美元/MMBtu (百万英热单位)
- **数据源**: TradingEconomics
- **更新频率**: 每小时

## 查看日志

```bash
tail -f ~/git/sh/natural-gas/logs/natural_gas_$(date +%Y%m%d).log
```
