# IP地址监控脚本

## 功能说明

这是一个用于自动记录本机IP地址的脚本系统，可在macOS开机时自动运行。

## 文件结构

```
~/git/sh/monitor_ip/
├── README.md                      # 说明文档
├── record_ip.sh                   # IP记录脚本
├── com.user.recordip.plist        # launchd配置文件
├── install.sh                     # 安装脚本
├── uninstall.sh                   # 卸载脚本
└── logs/                          # 日志目录
    ├── ip_history.log             # IP历史记录
    ├── stdout.log                 # 标准输出日志
    └── stderr.log                 # 错误日志
```

## 记录内容

脚本会记录以下信息：
- 时间戳
- 主机名
- IPv4地址（所有非回环接口）
- IPv6地址（所有非本地接口）
- 外网IP地址

## 使用方法

### 手动运行

```bash
cd ~/git/sh/monitor_ip
./record_ip.sh
```

### 安装开机自动运行

```bash
cd ~/git/sh/monitor_ip
./install.sh
```

安装后，脚本将在每次开机时自动执行。

### 卸载开机自动运行

```bash
cd ~/git/sh/monitor_ip
./uninstall.sh
```

### 查看运行状态

```bash
# 检查启动项是否已加载
launchctl list | grep recordip

# 查看IP历史记录
cat ~/git/sh/monitor_ip/logs/ip_history.log

# 查看最近一次记录
tail -n 20 ~/git/sh/monitor_ip/logs/ip_history.log
```

### 手动启动/停止（已安装的情况下）

```bash
# 停止
launchctl unload ~/Library/LaunchAgents/com.user.recordip.plist

# 启动
launchctl load ~/Library/LaunchAgents/com.user.recordip.plist

# 立即运行一次
launchctl start com.user.recordip
```

## 验证测试

1. **测试脚本功能**：
   ```bash
   ./record_ip.sh
   cat logs/ip_history.log
   ```

2. **测试安装**：
   ```bash
   ./install.sh
   launchctl list | grep recordip
   ```

3. **测试开机启动**：
   重启电脑后检查日志文件是否有新记录。

4. **测试卸载**：
   ```bash
   ./uninstall.sh
   launchctl list | grep recordip  # 应该无输出
   ```

## 日志示例

```
==================== 2026-07-10 09:19:03 ====================
主机名: rededeMac-mini.local
IPv4地址:
  - en1: 172.16.10.8
  - en1: 172.16.11.255
IPv6地址:
  - en1: 240e:83:9001:1a:2500::d8
外网IP:
  - 124.126.11.233
```

## 注意事项

1. 获取外网IP需要网络连接，如果网络未就绪会显示"获取失败"
2. 日志文件会持续追加，建议定期清理
3. 如需修改日志位置，请同时修改 `record_ip.sh` 和 `com.user.recordip.plist` 中的路径
4. macOS系统重启后launchd会自动加载已安装的启动项

## 故障排除

### 启动项未运行

1. 检查plist文件格式：
   ```bash
   plutil -lint ~/Library/LaunchAgents/com.user.recordip.plist
   ```

2. 查看错误日志：
   ```bash
   cat ~/git/sh/monitor_ip/logs/stderr.log
   ```

3. 检查脚本权限：
   ```bash
   ls -l ~/git/sh/monitor_ip/record_ip.sh
   ```

### 无法获取外网IP

这通常是因为网络未连接或curl超时，不影响本地IP记录。可以增加超时时间或移除外网IP检测部分。
