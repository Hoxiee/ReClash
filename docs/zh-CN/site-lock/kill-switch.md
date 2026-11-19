# 断网保护

桌面端断网保护会阻断 ReClash 的 TUN 之外的所有流量，因此隧道中断时不会泄漏任何数据。它适用于 Linux 和 Windows，并需要 TUN 和 Helper。

macOS 没有断网保护。Android 使用系统的“始终开启的 VPN”并启用 **阻止没有 VPN 的连接**；参见[在 Android 上](README.md#on-android)。

## 在哪里找到它

打开 **工具 → 网络**，找到 **断网保护** 部分。相同的控件也在[站点锁定](README.md)页面上。其状态显示为 **等待 TUN**、**已启用** 或 **阻断中**。

## 它会阻断什么

阻断是严格的。断网保护就绪期间，ReClash 的 TUN 之外的所有流量都会被阻断，包括 TUN 排除的地址，例如路由排除项和绕过的私有网络。允许在 TUN 之外通行的有：

- 回环；
- Core 自身，使其能够访问它的服务器；
- DHCP 和链路本地流量；
- 局域网，只要 **允许局域网** 处于开启状态（默认开启）。

> [!WARNING]
> 断网保护就绪期间，并行运行的其他 VPN 也会失去互联网连接。

## 何时就绪

在标准模式下，断网保护在运行期间 TUN 启动时就绪，而不是在 Core 启动或 ReClash 启动时。一旦就绪，它会在崩溃、Core 重启、恢复以及应用更新后的重新启动期间保持就绪。当你主动停止时它会解除：关闭代理、关闭 TUN，或正常退出 ReClash。重启计算机同样会解除它；在 Windows 上，注销也会解除，因为快速启动会让会话在关机后保留。

通过 URL scheme 链接或诊断停止操作停止，不会解除它；请使用 **解除阻断**。

**ReClash 停止时也保持阻断** 是始终模式。此时只要 ReClash 的 TUN 没有运行，电脑就没有互联网，即使 ReClash 被卸载后也是如此，除非你先移除 Helper。开启它时会要求确认。

## 仪表盘提示

当断网保护正在阻断且没有运行 TUN 时，仪表盘会显示 **断网保护正在阻断网络**，并提供 **启动**，在标准模式下还有 **解除阻断**。

## 在 Linux 上

Helper 把规则保存在它自己的 nftables 表 `inet reclash_killswitch_<uid>` 中，其中 `<uid>` 是 `id -u` 的输出。它需要 `nftables` 软件包。用下面的命令查看该表：

```sh
sudo nft list table inet reclash_killswitch_<uid>
```

如果 Helper 无法确定自己的 cgroup，它会拒绝安装阻断规则，状态会报告防火墙故障，而不是连 Core 一起阻断。

重启后的 Helper 会在 ReClash 连接它之前恢复该表；重启系统后，只有始终模式会从开机起就阻断。如果有程序清空了防火墙，Helper 会在约 10 秒内重新应用该表。

紧急情况下，请使用 **工具 → Core → 移除 Helper**，或在设置中关闭断网保护。

## 在 Windows 上

断网保护是一组持久的 Windows 筛选平台（WFP）过滤器，位于 ReClash 自己的提供程序之下。紧急情况下，请在管理员终端中从 ReClash 文件夹运行 `ReClashService.exe lift-site-lock`：它会停止 Helper，并移除站点锁定和断网保护的过滤器。
