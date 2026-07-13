# 原油价格监控脚本

每小时获取WTI原油价格并记录到日志。

## 使用方法

### 手动运行
```bash
~/git/sh/oil/get_oil_price.sh
```

### 开机自启动
```bash
# 安装
~/git/sh/oil/install_autostart.sh

# 卸载
~/git/sh/oil/uninstall_autostart.sh
```

## 数据说明

- **品种**: WTI原油 (West Texas Intermediate)
- **单位**: 美元/桶
- **数据源**: TradingEconomics
- **更新频率**: 每小时

## 查看日志

```bash
tail -f ~/git/sh/oil/logs/oil_price_$(date +%Y%m%d).log
```
