# 存储器价格监控

从 [CFM闪存市场](https://chinaflashmarket.com/price) 获取存储器（Flash Wafer、DDR、SSD、eMMC等）价格数据，并自动转换为人民币。

## 功能特点

- 自动爬取存储器价格数据
- 自动获取美元兑人民币汇率并转换价格
- 支持多种存储器类型（Flash Wafer、DDR、内存条、SSD、移动存储等）
- 每天自动运行一次（上午9点）
- 保存详细日志和CSV格式数据
- 支持开机自启动

## 安装

### 开机自启动（推荐）

使用 macOS LaunchAgent 实现开机自启动，每天上午9点自动运行：

```bash
cd ~/git/sh/memory
chmod +x install_autostart.sh uninstall_autostart.sh get_memory_price.sh
./install_autostart.sh
```

### 手动运行

```bash
cd ~/git/sh/memory
./get_memory_price.sh
```

## 数据存储

### 日志文件

- 位置: `logs/memory_price_YYYYMMDD.log`
- 格式: 人类可读的文本格式
- 内容: 按类别分组的详细价格信息（人民币）

### CSV文件

- 位置: `logs/memory_price.csv`
- 格式: CSV格式，便于数据分析
- 字段: 时间戳,类别,产品,当前价(CNY),涨跌额(CNY),涨跌幅(%),前收盘价(CNY),高点(CNY),低点(CNY),汇率(USD/CNY)

## 监控的存储器类型

1. **存储芯片**
   - Flash Wafer (QLC, TLC)
   - DDR (DDR4, DDR5)

2. **服务器内存条**
   - DDR4 RDIMM
   - DDR5 RDIMM

3. **PC内存和存储**
   - 内存条（渠道/行业）
   - SSD（渠道/行业）

4. **移动存储**
   - LPDDR
   - eMMC / eMCP
   - UFS / uMCP

5. **移动存储设备**
   - 闪存卡
   - USB 2.0 / 3.0

## 查看日志

```bash
# 查看最新日志
tail -f ~/git/sh/memory/logs/memory_price_$(date +%Y%m%d).log

# 查看CSV数据
cat ~/git/sh/memory/logs/memory_price.csv
```

## 服务管理

```bash
# 查看服务状态
launchctl list | grep memory-price

# 手动启动服务
launchctl start com.user.memory-price-monitor

# 手动停止服务
launchctl stop com.user.memory-price-monitor

# 卸载自启动
./uninstall_autostart.sh
```

## 数据源

- 来源: [CFM闪存市场](https://chinaflashmarket.com/price)
- 更新频率: 实时更新
- 原始币种: 美元 (USD)
- 显示币种: 人民币 (CNY)
- 汇率来源: 自动获取实时汇率

## 注意事项

1. 需要Python 3环境
2. 需要bc命令（用于价格计算）
3. 需要网络连接
4. 数据更新频率取决于数据源的更新
5. CSV文件会持续增长，建议定期归档
6. 汇率会自动获取，获取失败时使用默认汇率7.25
