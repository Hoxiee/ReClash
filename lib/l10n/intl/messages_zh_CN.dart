// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_CN';

  static String m0(time) => "已连接 ${time}";

  static String m1(code) =>
      "Windows 拒绝运行 ReClashCore.exe（错误 ${code}）。智能应用控制、AppLocker 等应用控制策略会拦截未签名程序，请在该策略中放行 ReClash 或关闭策略后重试。";

  static String m2(name) =>
      "应用连续两次未能完成启动。为打断崩溃循环，已取消选中配置 ${name}，并跳过本次自动配置，你可以随时重新选中它。";

  static String m3(url) => "是否要通过 ${url} 创建配置？";

  static String m4(count) => "${count} 天前";

  static String m5(count) => "${count} 天";

  static String m6(label) => "确定删除选中的${label}吗？";

  static String m7(label) => "确定删除当前${label}吗？";

  static String m8(count) => "${Intl.plural(count, other: '${count} 个参数')}";

  static String m9(label) => "${label}详情";

  static String m10(label) => "${label}不能为空";

  static String m11(count) => "${count} 个条目";

  static String m12(label) => "${label}当前已存在";

  static String m13(name) => "${name} 已是最新版本";

  static String m14(name) => "${name} 已更新";

  static String m15(time) => "${time}前";

  static String m16(count) => "${count} 小时前";

  static String m17(count) => "${count} 小时";

  static String m18(target) => "${target} 是一个无效的策略";

  static String m19(proxyName) => "${proxyName} 是一个无效的代理";

  static String m20(providerName) => "${providerName} 是一个无效的代理集";

  static String m21(subRule) => "${subRule} 是一个无效的SUB_RULE";

  static String m22(appName) =>
      "1. 打开 系统设置 > 隐私与安全性\n2. 选择 定位服务\n3. 在右侧列表中找到并勾选 ${appName}\n\n完成设置后，返回应用即可正常使用。感谢您的配合。";

  static String m23(label, max) => "${label}最多${max}个字符";

  static String m24(count) => "${count} 分钟前";

  static String m25(count) => "${count} 个月前";

  static String m26(label) => "暂无${label}";

  static String m27(label) => "${label}必须为数字";

  static String m28(label) => "${label} 必须在 1024 到 49151 之间";

  static String m29(count) => "${count} 个代理";

  static String m30(count) => "${count} 条规则";

  static String m31(darkAt, lightAt) => "${darkAt} 至 ${lightAt} 使用深色";

  static String m32(count) => "${count} 秒";

  static String m33(count) => "已选择 ${count} 项";

  static String m34(alive, total) => "当前可用 ${alive} / ${total} 个服务器";

  static String m35(band) => "第 ${band} 档";

  static String m36(bands) => "延迟档：${bands}";

  static String m37(count) => "${count} 次失败后正在冷却";

  static String m38(answered, total) => "${total} 个中有 ${answered} 个响应";

  static String m39(seconds) => "还剩 ${seconds} 秒";

  static String m40(count) => "连续失败 ${count} 次";

  static String m41(measured, total) => "已测量 ${measured} / ${total}";

  static String m42(preset) => "${preset} · 已调整";

  static String m43(left, cap) => "本小时还剩 ${left}/${cap} 次探测";

  static String m44(seconds) => "${seconds} 秒";

  static String m45(eligible, total) => "${total} 台中 ${eligible} 台可用";

  static String m46(eligible, total, blocked) =>
      "${total} 个中 ${eligible} 个通过，${blocked} 个被拦下";

  static String m47(from, to) => "${from} → ${to}";

  static String m48(time) => "${time}前切换";

  static String m49(count) => "${count} 台";

  static String m50(host) => "提供方已迁移至 ${host}";

  static String m51(count) => "订阅将在 ${count} 天后到期";

  static String m52(value) => "提供方建议 ${value}";

  static String m53(total) => "剩余（共 ${total}）";

  static String m54(label) => "${label}必须为URL";

  static String m55(count) => "${count} 年前";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("关于"),
    "accessControl": MessageLookupByLibrary.simpleMessage("访问控制"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "只允许选中应用进入VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage("配置应用访问代理"),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "应用访问控制已关闭",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "选中应用将会被排除在VPN之外",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage("访问控制设置"),
    "account": MessageLookupByLibrary.simpleMessage("账号"),
    "action": MessageLookupByLibrary.simpleMessage("操作"),
    "actionMode": MessageLookupByLibrary.simpleMessage("切换模式"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("系统代理"),
    "actionStart": MessageLookupByLibrary.simpleMessage("启动/停止"),
    "actionTun": MessageLookupByLibrary.simpleMessage("虚拟网卡"),
    "actionView": MessageLookupByLibrary.simpleMessage("显示/隐藏"),
    "add": MessageLookupByLibrary.simpleMessage("添加"),
    "addNetwork": MessageLookupByLibrary.simpleMessage("添加网络"),
    "addProfile": MessageLookupByLibrary.simpleMessage("添加配置"),
    "addProxies": MessageLookupByLibrary.simpleMessage("添加代理"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("添加策略组"),
    "addProxyProviders": MessageLookupByLibrary.simpleMessage("添加代理集"),
    "addRule": MessageLookupByLibrary.simpleMessage("添加规则"),
    "addWidget": MessageLookupByLibrary.simpleMessage("添加组件"),
    "addedRules": MessageLookupByLibrary.simpleMessage("附加规则"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage("附加参数"),
    "address": MessageLookupByLibrary.simpleMessage("地址"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("WebDAV服务器地址"),
    "addressTip": MessageLookupByLibrary.simpleMessage("请输入有效的WebDAV地址"),
    "advancedConfig": MessageLookupByLibrary.simpleMessage("进阶配置"),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage("提供多样化配置"),
    "agree": MessageLookupByLibrary.simpleMessage("同意"),
    "allowBypass": MessageLookupByLibrary.simpleMessage("允许应用绕过VPN"),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage("开启后部分应用可绕过VPN"),
    "allowLan": MessageLookupByLibrary.simpleMessage("局域网代理"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage("允许通过局域网访问代理"),
    "announce": MessageLookupByLibrary.simpleMessage("公告"),
    "app": MessageLookupByLibrary.simpleMessage("应用"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage("应用访问控制"),
    "appIcon": MessageLookupByLibrary.simpleMessage("应用图标"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "启动器会在几秒后重绘图标。部分启动器上固定的快捷方式可能消失。",
    ),
    "appIconCool": MessageLookupByLibrary.simpleMessage("冷色"),
    "appIconDarkMono": MessageLookupByLibrary.simpleMessage("深色单色"),
    "appIconInverted": MessageLookupByLibrary.simpleMessage("反色"),
    "appIconMono": MessageLookupByLibrary.simpleMessage("单色"),
    "appIconSepia": MessageLookupByLibrary.simpleMessage("复古"),
    "appearance": MessageLookupByLibrary.simpleMessage("外观"),
    "appearanceDesc": MessageLookupByLibrary.simpleMessage("主题、颜色、图标与面板外观"),
    "appearanceIcon": MessageLookupByLibrary.simpleMessage("图标"),
    "appearanceLayout": MessageLookupByLibrary.simpleMessage("布局"),
    "appearanceMotion": MessageLookupByLibrary.simpleMessage("动效"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("主题"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage("追加系统DNS"),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage("强制为配置附加系统DNS"),
    "application": MessageLookupByLibrary.simpleMessage("应用程序"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage("修改应用程序相关设置"),
    "authentication": MessageLookupByLibrary.simpleMessage("认证"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "为本地代理端口启用认证，防止本机其他应用擅自使用",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "认证启用时不生效",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("授权"),
    "authorized": MessageLookupByLibrary.simpleMessage("已授权"),
    "auto": MessageLookupByLibrary.simpleMessage("自动"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage("自动检查更新"),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage("应用启动时自动检查更新"),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage("自动关闭连接"),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "切换节点后自动关闭连接",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("自启动"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage("跟随系统自启动"),
    "autoRun": MessageLookupByLibrary.simpleMessage("自动运行"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage("应用打开时自动运行"),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage("自动设置系统DNS"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("自动更新"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage("自动更新间隔（分钟）"),
    "back": MessageLookupByLibrary.simpleMessage("返回"),
    "backup": MessageLookupByLibrary.simpleMessage("备份"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage("备份与恢复"),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "通过WebDAV或者文件同步数据",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("备份成功"),
    "basicConfig": MessageLookupByLibrary.simpleMessage("基础配置"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage("全局修改基础配置"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("基础信息"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("基础策略"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "为保证后台运行，请关闭本应用的电池优化。点击前往设置。",
    ),
    "batteryOptimizationStatusTip": MessageLookupByLibrary.simpleMessage(
      "由于系统限制，运行状态下无法正确获取电池优化状态",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("绑定"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("黑名单模式"),
    "blockConnection": MessageLookupByLibrary.simpleMessage("阻止连接"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("排除域名"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage("仅在系统代理启用时生效"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage("缓存已损坏，是否清空？"),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("取消全选"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "切换代理失败，已恢复上一次的选择",
    ),
    "changeServer": MessageLookupByLibrary.simpleMessage("更换服务器"),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage("重大变更"),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("新功能"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("问题修复"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("性能优化"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("已回滚"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage("校验 TLS 证书"),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "拒绝不受信任的证书。关闭后订阅和备份将暴露于中间人攻击",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("检查更新"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage("当前应用已经是最新版了"),
    "classicDashboard": MessageLookupByLibrary.simpleMessage("经典"),
    "classicDashboardDesc": MessageLookupByLibrary.simpleMessage("磁贴网格与启动按钮"),
    "clearData": MessageLookupByLibrary.simpleMessage("清除数据"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("清除搜索"),
    "clientNotSupported": MessageLookupByLibrary.simpleMessage("客户端不受支持"),
    "clientNotSupportedTip": MessageLookupByLibrary.simpleMessage("面板不支持此客户端。"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("导出剪贴板"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("剪贴板导入"),
    "close": MessageLookupByLibrary.simpleMessage("关闭"),
    "closeConnections": MessageLookupByLibrary.simpleMessage("关闭连接"),
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "暂停 VPN 时断开所有现有连接",
    ),
    "color": MessageLookupByLibrary.simpleMessage("颜色"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("配色方案"),
    "columns": MessageLookupByLibrary.simpleMessage("列数"),
    "compatible": MessageLookupByLibrary.simpleMessage("兼容模式"),
    "configDataDetected": MessageLookupByLibrary.simpleMessage("检测到配置中存在数据"),
    "confirm": MessageLookupByLibrary.simpleMessage("确定"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage("确定要清除所有数据？"),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "确定要删除当前策略组吗？",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage("确定要退出当前窗口吗?"),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage("确定要强制崩溃核心？"),
    "confirmOverwriteTip": MessageLookupByLibrary.simpleMessage("确定后将会覆盖已有数据"),
    "connected": MessageLookupByLibrary.simpleMessage("已连接"),
    "connectedFor": m0,
    "connecting": MessageLookupByLibrary.simpleMessage("连接中..."),
    "connection": MessageLookupByLibrary.simpleMessage("连接"),
    "connections": MessageLookupByLibrary.simpleMessage("连接"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage("查看当前连接数据"),
    "connectivity": MessageLookupByLibrary.simpleMessage("连通性："),
    "content": MessageLookupByLibrary.simpleMessage("内容"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage("内容不能为空"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("内容主题"),
    "contrast": MessageLookupByLibrary.simpleMessage("对比度"),
    "contrastAmoledHint": MessageLookupByLibrary.simpleMessage(
      "纯黑背景下 +0.3 对比度通常更易读",
    ),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage("控制全局附加规则"),
    "copy": MessageLookupByLibrary.simpleMessage("复制"),
    "copyDiagnostics": MessageLookupByLibrary.simpleMessage("复制版本信息"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("复制环境变量"),
    "copyLink": MessageLookupByLibrary.simpleMessage("复制链接"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("复制成功"),
    "core": MessageLookupByLibrary.simpleMessage("内核"),
    "coreBlockedByPolicyTip": m1,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows 智能应用控制拦截了未签名的 ReClashCore.exe。请打开 Windows 安全中心 → 应用和浏览器控制 → 智能应用控制设置，选择「关闭」后重新启动 ReClash。智能应用控制关闭后无法再开启，除非重装 Windows。",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("核心状态"),
    "country": MessageLookupByLibrary.simpleMessage("区域"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("检测到崩溃"),
    "crashDetectedTip": m2,
    "crashTest": MessageLookupByLibrary.simpleMessage("崩溃测试"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("崩溃分析"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "开启后，应用崩溃时自动上传不包含敏感信息的崩溃日志",
    ),
    "create": MessageLookupByLibrary.simpleMessage("创建"),
    "createProfile": MessageLookupByLibrary.simpleMessage("创建配置"),
    "createProfileFromUrlTip": m3,
    "creationTime": MessageLookupByLibrary.simpleMessage("创建时间"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage(
      "FlClash — 本应用的基础客户端",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "FlClashX — 机场功能与思路",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage("mihomo — 代理内核"),
    "custom": MessageLookupByLibrary.simpleMessage("自定义"),
    "customUserAgentLabel": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "cut": MessageLookupByLibrary.simpleMessage("剪切"),
    "dark": MessageLookupByLibrary.simpleMessage("深色"),
    "darkAt": MessageLookupByLibrary.simpleMessage("深色开始"),
    "dashboard": MessageLookupByLibrary.simpleMessage("仪表盘"),
    "dashboardStyle": MessageLookupByLibrary.simpleMessage("面板样式"),
    "dataChangedSave": MessageLookupByLibrary.simpleMessage("检测到数据有更改，是否保存"),
    "dataCollectionContent": MessageLookupByLibrary.simpleMessage(
      "本应用使用 Firebase Crashlytics 收集崩溃信息以改进应用稳定性。\n收集的数据包括设备信息和崩溃详情，不包含个人敏感数据。\n您可以在设置中关闭此功能。",
    ),
    "dataCollectionTip": MessageLookupByLibrary.simpleMessage("数据收集说明"),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "保存更改失败，已回滚",
    ),
    "day": MessageLookupByLibrary.simpleMessage("天"),
    "days": MessageLookupByLibrary.simpleMessage("天"),
    "daysAgo": m4,
    "daysGenitive": MessageLookupByLibrary.simpleMessage("天"),
    "daysLeft": m5,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage("默认域名服务器"),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage("用于解析DNS服务器"),
    "defaultText": MessageLookupByLibrary.simpleMessage("默认"),
    "delay": MessageLookupByLibrary.simpleMessage("延迟"),
    "delayTest": MessageLookupByLibrary.simpleMessage("延迟测试"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "deleteMultipTip": m6,
    "deleteTip": m7,
    "desc": MessageLookupByLibrary.simpleMessage(
      "多平台 mihomo 客户端：重构的仪表盘、更聪明的分流以及完善的订阅支持。开源，无广告，无遥测。",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("目标地址"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("目标地理定位"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("目标IP ASN"),
    "desync": MessageLookupByLibrary.simpleMessage("DPI 绕过"),
    "desyncArgs": MessageLookupByLibrary.simpleMessage("引擎参数"),
    "desyncArgsCount": m8,
    "desyncArgsHint": MessageLookupByLibrary.simpleMessage(
      "-A torst,conn -L s,o --split 1",
    ),
    "desyncArgsQuoteError": MessageLookupByLibrary.simpleMessage("引号未闭合"),
    "desyncCache": MessageLookupByLibrary.simpleMessage("策略缓存"),
    "desyncCacheDesc": MessageLookupByLibrary.simpleMessage("所选策略按网络分别保存"),
    "desyncCacheTtl": MessageLookupByLibrary.simpleMessage("缓存有效期"),
    "desyncDefaultName": MessageLookupByLibrary.simpleMessage("默认阶梯"),
    "desyncDesc": MessageLookupByLibrary.simpleMessage("ByeDPI 失同步策略"),
    "desyncEngine": MessageLookupByLibrary.simpleMessage("引擎"),
    "desyncForceTcp": MessageLookupByLibrary.simpleMessage("强制 TCP"),
    "desyncForceTcpDesc": MessageLookupByLibrary.simpleMessage(
      "阻止上述分类的 QUIC；失同步无法作用于 UDP",
    ),
    "desyncModeByedpi": MessageLookupByLibrary.simpleMessage("ByeDPI"),
    "desyncModeTitle": MessageLookupByLibrary.simpleMessage("连接模式"),
    "desyncModeVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "desyncRouting": MessageLookupByLibrary.simpleMessage("路由"),
    "desyncSaveCurrent": MessageLookupByLibrary.simpleMessage("保存当前"),
    "desyncStrategyNameHint": MessageLookupByLibrary.simpleMessage("策略名称"),
    "desyncStrategySection": MessageLookupByLibrary.simpleMessage("策略"),
    "desyncTtl12Hours": MessageLookupByLibrary.simpleMessage("12 小时"),
    "desyncTtl28Hours": MessageLookupByLibrary.simpleMessage("28 小时"),
    "desyncTtlHour": MessageLookupByLibrary.simpleMessage("1 小时"),
    "desyncTtlWeek": MessageLookupByLibrary.simpleMessage("7 天"),
    "details": m9,
    "detectionTip": MessageLookupByLibrary.simpleMessage("依赖第三方api，仅供参考"),
    "determiningIp": MessageLookupByLibrary.simpleMessage("正在获取 IP..."),
    "developerMode": MessageLookupByLibrary.simpleMessage("开发者模式"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage("开发者模式已启用。"),
    "deviceLimitReached": MessageLookupByLibrary.simpleMessage("设备数量已达上限"),
    "deviceLimitReachedTip": MessageLookupByLibrary.simpleMessage(
      "面板反馈此订阅的设备数量已达上限。订阅配置仍已更新。",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("直连"),
    "disableUDP": MessageLookupByLibrary.simpleMessage("禁用UDP"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("免责声明"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "本软件仅供学习交流、科研等非商业性质的用途，严禁将本软件用于商业目的。如有任何商业行为，均与本软件无关。",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("已断开"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage("发现新版本"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage("更新DNS相关设置"),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS劫持"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS模式"),
    "domain": MessageLookupByLibrary.simpleMessage("域名"),
    "download": MessageLookupByLibrary.simpleMessage("下载"),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage("正在下载更新"),
    "edit": MessageLookupByLibrary.simpleMessage("编辑"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage("编辑全局规则"),
    "editNetwork": MessageLookupByLibrary.simpleMessage("编辑网络"),
    "editProxy": MessageLookupByLibrary.simpleMessage("编辑代理"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("编辑策略组"),
    "editRule": MessageLookupByLibrary.simpleMessage("编辑规则"),
    "emptyTip": m10,
    "en": MessageLookupByLibrary.simpleMessage("英语"),
    "enterManually": MessageLookupByLibrary.simpleMessage("手动输入"),
    "entries": MessageLookupByLibrary.simpleMessage("个条目"),
    "entriesCount": m11,
    "exclude": MessageLookupByLibrary.simpleMessage("从最近任务中隐藏"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage("应用在后台时,从最近任务中隐藏应用"),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage("排除节点过滤器"),
    "excludeType": MessageLookupByLibrary.simpleMessage("排除类型"),
    "existsTip": m12,
    "exit": MessageLookupByLibrary.simpleMessage("退出"),
    "expand": MessageLookupByLibrary.simpleMessage("标准"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("预期状态"),
    "expireTime": MessageLookupByLibrary.simpleMessage("到期时间"),
    "exportFile": MessageLookupByLibrary.simpleMessage("导出文件"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("导出日志"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("导出成功"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("表现力"),
    "externalController": MessageLookupByLibrary.simpleMessage("外部控制器"),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "开启后将可以通过9090端口控制Clash内核",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("外部获取"),
    "externalLink": MessageLookupByLibrary.simpleMessage("外部链接"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fakeip过滤"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fakeip范围"),
    "fallback": MessageLookupByLibrary.simpleMessage("Fallback"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage("一般情况下使用境外DNS"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Fallback过滤"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("高保真"),
    "file": MessageLookupByLibrary.simpleMessage("文件"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("直接上传配置文件"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage("文件有修改，是否保存修改"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("查找进程"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage("开启后会有一定性能损耗"),
    "followProfile": MessageLookupByLibrary.simpleMessage("跟随配置"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("字体"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage("您确定要强制重启核心吗？"),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("果缤纷"),
    "general": MessageLookupByLibrary.simpleMessage("常规"),
    "geoAutoUpdate": MessageLookupByLibrary.simpleMessage("自动更新"),
    "geoAutoUpdateInterval": MessageLookupByLibrary.simpleMessage("自动更新间隔"),
    "geoAutoUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "自动更新间隔必须大于0",
    ),
    "geoOptions": MessageLookupByLibrary.simpleMessage("Geo 选项"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo 资源"),
    "geoSkipped": m13,
    "geoUpdated": m14,
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo低内存模式"),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage("开启将使用Geo低内存加载器"),
    "geoipCode": MessageLookupByLibrary.simpleMessage("Geoip代码"),
    "global": MessageLookupByLibrary.simpleMessage("全局"),
    "go": MessageLookupByLibrary.simpleMessage("前往"),
    "goDownload": MessageLookupByLibrary.simpleMessage("前往下载"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage("前往配置脚本"),
    "gratitude": MessageLookupByLibrary.simpleMessage("致谢"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage("ReClash 建立在他们的工作之上"),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage("是否缓存修改"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper 服务不可用，无法启用 TUN 模式，请重新安装 ReClash。",
    ),
    "heroChecking": MessageLookupByLibrary.simpleMessage("正在检查网络…"),
    "heroCheckingHint": MessageLookupByLibrary.simpleMessage("正在测量所选节点"),
    "heroConnecting": MessageLookupByLibrary.simpleMessage("连接中…"),
    "heroJustNow": MessageLookupByLibrary.simpleMessage("刚刚"),
    "heroLinkBroken": MessageLookupByLibrary.simpleMessage("连接不可用"),
    "heroLinkDown": MessageLookupByLibrary.simpleMessage("节点无响应"),
    "heroLinkPaused": MessageLookupByLibrary.simpleMessage("流量已暂停，保护处于等待状态"),
    "heroLinkSlow": MessageLookupByLibrary.simpleMessage("节点响应缓慢"),
    "heroNoNetworkHint": MessageLookupByLibrary.simpleMessage("等待网络连接"),
    "heroNotProtected": MessageLookupByLibrary.simpleMessage("未受保护"),
    "heroPaused": MessageLookupByLibrary.simpleMessage("已暂停 — 受信任网络"),
    "heroProtected": MessageLookupByLibrary.simpleMessage("已受保护"),
    "heroReconnecting": MessageLookupByLibrary.simpleMessage("正在重新连接…"),
    "heroReconnectingHint": MessageLookupByLibrary.simpleMessage("正在恢复隧道"),
    "heroRoutingAgo": m15,
    "heroRoutingStub": MessageLookupByLibrary.simpleMessage("智能路由已关闭"),
    "heroTapToConnect": MessageLookupByLibrary.simpleMessage("点按开启保护"),
    "heroTapToResume": MessageLookupByLibrary.simpleMessage("点按以恢复保护"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("从列表中隐藏"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("隐藏密码"),
    "host": MessageLookupByLibrary.simpleMessage("主机"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("追加Hosts"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("快捷键冲突"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("快捷键管理"),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage("使用键盘控制应用程序"),
    "hour": MessageLookupByLibrary.simpleMessage("小时"),
    "hours": MessageLookupByLibrary.simpleMessage("小时"),
    "hoursAgo": m16,
    "hoursCount": m17,
    "hoursGenitive": MessageLookupByLibrary.simpleMessage("小时"),
    "hoursPlural": MessageLookupByLibrary.simpleMessage("小时"),
    "icon": MessageLookupByLibrary.simpleMessage("图片"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("图标记录"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("图标样式"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("图标链接"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage("忽略电池优化"),
    "import": MessageLookupByLibrary.simpleMessage("导入"),
    "importFile": MessageLookupByLibrary.simpleMessage("通过文件导入"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("从URL导入"),
    "importUrl": MessageLookupByLibrary.simpleMessage("通过URL导入"),
    "inbound": MessageLookupByLibrary.simpleMessage("入站"),
    "includeAllProxies": MessageLookupByLibrary.simpleMessage("包含所有代理"),
    "includeAllProxiesTip": MessageLookupByLibrary.simpleMessage(
      "引入不包含策略组的所有代理，可在下方额外添加策略组",
    ),
    "includeAllProxyProviders": MessageLookupByLibrary.simpleMessage("包含所有代理集"),
    "includeAllProxyProvidersTip": MessageLookupByLibrary.simpleMessage(
      "开启后将覆盖引入的代理集",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("长期有效"),
    "init": MessageLookupByLibrary.simpleMessage("初始化"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage("请输入正确的快捷键"),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage("输入策略组名称"),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage("输入规则内容"),
    "installUpdate": MessageLookupByLibrary.simpleMessage("安装更新"),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "读取应用列表权限已被拒绝，无法获取已安装的应用。请前往系统设置手动开启。",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "当前系统在授权前不会提供已安装的应用列表，授权后即可配置分应用代理。",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "需要读取应用列表权限",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("智能选择"),
    "interfaceName": MessageLookupByLibrary.simpleMessage("网卡名称"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage("出站连接使用的网卡名称"),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage("出站网卡"),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("清空"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("自定义"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage("跟随配置"),
    "internet": MessageLookupByLibrary.simpleMessage("互联网"),
    "interval": MessageLookupByLibrary.simpleMessage("间隔"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("内网 IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage("无效备份文件"),
    "invalidPolicy": m18,
    "invalidProxy": m19,
    "invalidProxyProvider": m20,
    "invalidSubRule": m21,
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/掩码"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage("开启后将可以接收IPv6流量"),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage("允许IPv6入站"),
    "ja": MessageLookupByLibrary.simpleMessage("日语"),
    "justNow": MessageLookupByLibrary.simpleMessage("刚刚"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage("TCP保持活动间隔"),
    "key": MessageLookupByLibrary.simpleMessage("键"),
    "language": MessageLookupByLibrary.simpleMessage("语言"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage("启动未完成"),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "应用上次在启动过程中意外退出。已跳过本次自动配置，你可以手动启动重试。",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("布局"),
    "license": MessageLookupByLibrary.simpleMessage("许可证"),
    "light": MessageLookupByLibrary.simpleMessage("浅色"),
    "lightAt": MessageLookupByLibrary.simpleMessage("浅色开始"),
    "list": MessageLookupByLibrary.simpleMessage("列表"),
    "listen": MessageLookupByLibrary.simpleMessage("监听"),
    "loading": MessageLookupByLibrary.simpleMessage("加载中..."),
    "local": MessageLookupByLibrary.simpleMessage("本地"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage("备份数据到本地"),
    "locationPermission": MessageLookupByLibrary.simpleMessage("位置权限"),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "位置权限已被拒绝，无法获取当前 Wi-Fi 名称。请前往系统设置手动开启位置权限。",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "根据系统要求，获取Wi-Fi名称需要您授予位置权限。Android 上请选择“始终允许”，否则应用在后台时无法获取 Wi-Fi 名称。",
    ),
    "locationPermissionGuide": m22,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "需要位置权限",
    ),
    "log": MessageLookupByLibrary.simpleMessage("日志"),
    "logLevel": MessageLookupByLibrary.simpleMessage("日志等级"),
    "logcat": MessageLookupByLibrary.simpleMessage("日志捕获"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage("禁用将会隐藏日志入口"),
    "logs": MessageLookupByLibrary.simpleMessage("日志"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("日志捕获记录"),
    "logsTest": MessageLookupByLibrary.simpleMessage("日志测试"),
    "loopback": MessageLookupByLibrary.simpleMessage("回环解锁工具"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage("用于UWP回环解锁"),
    "loose": MessageLookupByLibrary.simpleMessage("宽松"),
    "madeBy": MessageLookupByLibrary.simpleMessage("作者"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("匹配来源IP"),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "matchTargetDesc": MessageLookupByLibrary.simpleMessage(
      "目标为 MATCH-TARGET 的规则路由到这里，默认取本配置末尾 MATCH 规则的目标。",
    ),
    "matchTargetTitle": MessageLookupByLibrary.simpleMessage("匹配目标"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("最大失败次数"),
    "maxLengthTip": m23,
    "maximize": MessageLookupByLibrary.simpleMessage("最大化"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("内存信息"),
    "messageTest": MessageLookupByLibrary.simpleMessage("消息测试"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("这是一条消息。"),
    "metaInfo": MessageLookupByLibrary.simpleMessage("订阅"),
    "min": MessageLookupByLibrary.simpleMessage("最小"),
    "minimize": MessageLookupByLibrary.simpleMessage("最小化"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("退出时最小化"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage("修改系统默认退出事件"),
    "minute": MessageLookupByLibrary.simpleMessage("分钟"),
    "minutesAgo": m24,
    "minutesGenitive": MessageLookupByLibrary.simpleMessage("分钟"),
    "minutesPlural": MessageLookupByLibrary.simpleMessage("分钟"),
    "mixedPort": MessageLookupByLibrary.simpleMessage("混合端口"),
    "mode": MessageLookupByLibrary.simpleMessage("模式"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("单色"),
    "monthsAgo": m25,
    "more": MessageLookupByLibrary.simpleMessage("更多"),
    "multipleValuesTip": MessageLookupByLibrary.simpleMessage("多个值使用逗号分隔"),
    "name": MessageLookupByLibrary.simpleMessage("名称"),
    "nameserver": MessageLookupByLibrary.simpleMessage("域名服务器"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage("用于解析域名"),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage("域名服务器策略"),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage("指定对应域名服务器策略"),
    "network": MessageLookupByLibrary.simpleMessage("网络"),
    "networkDesc": MessageLookupByLibrary.simpleMessage("修改网络相关设置"),
    "networkDetection": MessageLookupByLibrary.simpleMessage("网络检测"),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID（家庭 Wi-Fi）或网段（192.168.1.0/24）",
    ),
    "networkException": MessageLookupByLibrary.simpleMessage("网络异常，请检查连接后重试"),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("网络速度"),
    "networkType": MessageLookupByLibrary.simpleMessage("网络类型"),
    "networksEmpty": MessageLookupByLibrary.simpleMessage("暂无受信任的网络"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("中性"),
    "newDashboard": MessageLookupByLibrary.simpleMessage("新外观"),
    "newDashboardDesc": MessageLookupByLibrary.simpleMessage("连接圆环与下方流量"),
    "newDashboardTitle": MessageLookupByLibrary.simpleMessage("新版"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("下一个匹配"),
    "noAnnouncements": MessageLookupByLibrary.simpleMessage("暂无公告"),
    "noData": MessageLookupByLibrary.simpleMessage("暂无数据"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("暂无快捷键"),
    "noInfo": MessageLookupByLibrary.simpleMessage("暂无信息"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage("不再提示"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("无网络"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("无网络应用"),
    "noRecords": MessageLookupByLibrary.simpleMessage("暂无记录"),
    "noResolve": MessageLookupByLibrary.simpleMessage("不解析IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage("不解析主机名"),
    "none": MessageLookupByLibrary.simpleMessage("无"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage("当前代理组无法选中"),
    "notTrustedNow": MessageLookupByLibrary.simpleMessage("当前网络不受信任"),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage("没有配置文件,请先添加配置文件"),
    "nullTip": m26,
    "numberTip": m27,
    "off": MessageLookupByLibrary.simpleMessage("关闭"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("仅图标"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage("仅统计代理"),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "开启后，将只统计代理流量",
    ),
    "openInBrowser": MessageLookupByLibrary.simpleMessage("在浏览器中打开"),
    "optional": MessageLookupByLibrary.simpleMessage("可选"),
    "options": MessageLookupByLibrary.simpleMessage("选项"),
    "other": MessageLookupByLibrary.simpleMessage("其他"),
    "otherContributors": MessageLookupByLibrary.simpleMessage("其他贡献者"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("出站模式"),
    "override": MessageLookupByLibrary.simpleMessage("覆写"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("覆写DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage("开启后将覆盖配置中的DNS选项"),
    "overrideMode": MessageLookupByLibrary.simpleMessage("覆写模式"),
    "overrideNetworkSettings": MessageLookupByLibrary.simpleMessage("覆盖网络设置"),
    "overrideNetworkSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "使用应用的端口、IPv6、allow-lan、find-process-mode 和 TUN 栈，替代订阅中的值",
    ),
    "overrideScript": MessageLookupByLibrary.simpleMessage("覆写脚本"),
    "overwriteTypeCustom": MessageLookupByLibrary.simpleMessage("自定义"),
    "overwriteTypeCustomDesc": MessageLookupByLibrary.simpleMessage(
      "自定义模式，支持完全自定义修改代理组以及规则",
    ),
    "pageAnimation": MessageLookupByLibrary.simpleMessage("页面动画"),
    "pageAnimationDesc": MessageLookupByLibrary.simpleMessage("切换页面时使用动画"),
    "palette": MessageLookupByLibrary.simpleMessage("调色板"),
    "password": MessageLookupByLibrary.simpleMessage("密码"),
    "paste": MessageLookupByLibrary.simpleMessage("粘贴"),
    "pasteFromClipboard": MessageLookupByLibrary.simpleMessage("粘贴"),
    "pause": MessageLookupByLibrary.simpleMessage("暂停"),
    "pauseVpn": MessageLookupByLibrary.simpleMessage("正在暂停VPN..."),
    "paused": MessageLookupByLibrary.simpleMessage("已暂停"),
    "perpetualSubscription": MessageLookupByLibrary.simpleMessage("永久订阅"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("从相册选择"),
    "pickNetwork": MessageLookupByLibrary.simpleMessage("选择网络"),
    "pickNetworkDesc": MessageLookupByLibrary.simpleMessage("周围可见的 Wi-Fi 网络"),
    "pickNetworkEmpty": MessageLookupByLibrary.simpleMessage("未找到 Wi-Fi 网络"),
    "pickNetworkGrantLocation": MessageLookupByLibrary.simpleMessage(
      "列出附近的 Wi-Fi 网络需要位置权限",
    ),
    "pickNetworkRefresh": MessageLookupByLibrary.simpleMessage("刷新"),
    "pickNetworkScanning": MessageLookupByLibrary.simpleMessage(
      "正在搜索附近的 Wi-Fi 网络…",
    ),
    "pinWindow": MessageLookupByLibrary.simpleMessage("窗口置顶"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage("请绑定WebDAV"),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage("请输入脚本名称"),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "请上传有效的二维码",
    ),
    "port": MessageLookupByLibrary.simpleMessage("端口"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage("请输入不同的端口"),
    "portTip": m28,
    "preferH3Desc": MessageLookupByLibrary.simpleMessage("优先使用DOH的http/3"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("前置条件"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("请按下按键"),
    "preview": MessageLookupByLibrary.simpleMessage("预览"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("上一个匹配"),
    "process": MessageLookupByLibrary.simpleMessage("进程"),
    "profile": MessageLookupByLibrary.simpleMessage("配置"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("请输入有效间隔时间格式"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("请输入自动更新间隔时间"),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "配置文件已经修改,是否关闭自动更新 ",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入配置名称",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入有效配置URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入配置URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("配置"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("配置排序"),
    "project": MessageLookupByLibrary.simpleMessage("项目"),
    "providerView": MessageLookupByLibrary.simpleMessage("服务商视图"),
    "providerViewDesc": MessageLookupByLibrary.simpleMessage(
      "允许此订阅设置代理页面外观，你自己更改的项目会保留。",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("外部资源"),
    "proxies": MessageLookupByLibrary.simpleMessage("代理"),
    "proxiesCount": m29,
    "proxiesEmpty": MessageLookupByLibrary.simpleMessage("代理为空"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("代理链"),
    "proxyDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "检测到选中的代理存在异常",
    ),
    "proxyFilter": MessageLookupByLibrary.simpleMessage("节点过滤器"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("策略组"),
    "proxyGroupDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "检测到当前策略组异常",
    ),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage("策略组为空"),
    "proxyGroupNameDuplicate": MessageLookupByLibrary.simpleMessage("策略组名称重复"),
    "proxyGroupNameEmpty": MessageLookupByLibrary.simpleMessage("策略组名称不能为空"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("代理域名服务器"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage("用于解析代理节点的域名"),
    "proxyProviderDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "检测到选中的代理集存在异常",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("代理集"),
    "proxyProvidersEmpty": MessageLookupByLibrary.simpleMessage("代理集为空"),
    "proxyProvidersNotEmpty": MessageLookupByLibrary.simpleMessage("代理集不能为空"),
    "proxyType": MessageLookupByLibrary.simpleMessage("代理类型"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("修剪缓存"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("纯黑模式"),
    "qrcode": MessageLookupByLibrary.simpleMessage("二维码"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage("扫描二维码获取配置文件"),
    "quickFill": MessageLookupByLibrary.simpleMessage("一键填入"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("彩虹"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir端口"),
    "redo": MessageLookupByLibrary.simpleMessage("重做"),
    "reduceMotion": MessageLookupByLibrary.simpleMessage("减少动效"),
    "reduceMotionDesc": MessageLookupByLibrary.simpleMessage("关闭装饰性动画"),
    "reduceMotionSystemHint": MessageLookupByLibrary.simpleMessage("系统设置中已启用"),
    "reload": MessageLookupByLibrary.simpleMessage("重新加载"),
    "remaining": MessageLookupByLibrary.simpleMessage("剩余"),
    "remainingTraffic": MessageLookupByLibrary.simpleMessage("剩余"),
    "remote": MessageLookupByLibrary.simpleMessage("远程"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage("备份数据到WebDAV"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("远程目标"),
    "remove": MessageLookupByLibrary.simpleMessage("移除"),
    "renewSubscription": MessageLookupByLibrary.simpleMessage("续订订阅"),
    "request": MessageLookupByLibrary.simpleMessage("请求"),
    "requests": MessageLookupByLibrary.simpleMessage("请求"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage("查看最近请求记录"),
    "reset": MessageLookupByLibrary.simpleMessage("重置"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "当前页面存在更改，确定重置吗？",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("确定要重置吗?"),
    "resources": MessageLookupByLibrary.simpleMessage("资源"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage("外部资源相关信息"),
    "respectRules": MessageLookupByLibrary.simpleMessage("遵守规则"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS连接跟随rules,需配置proxy-server-nameserver",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("重启"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage("您确定要重启核心吗？"),
    "restore": MessageLookupByLibrary.simpleMessage("恢复"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("恢复所有数据"),
    "restoreException": MessageLookupByLibrary.simpleMessage("恢复异常"),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage("通过文件恢复数据"),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "通过WebDAV恢复数据",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage("仅恢复配置文件"),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("恢复策略"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage("兼容"),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("覆盖"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("恢复成功"),
    "resume": MessageLookupByLibrary.simpleMessage("恢复"),
    "roleAuthor": MessageLookupByLibrary.simpleMessage("作者与维护者"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("路由地址"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage("配置监听路由地址"),
    "routeMode": MessageLookupByLibrary.simpleMessage("路由模式"),
    "routeModeBypassPrivate": MessageLookupByLibrary.simpleMessage("绕过私有路由地址"),
    "routeModeConfig": MessageLookupByLibrary.simpleMessage("使用配置"),
    "ru": MessageLookupByLibrary.simpleMessage("俄语"),
    "rule": MessageLookupByLibrary.simpleMessage("规则"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage("逻辑规则 AND"),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage("匹配完整域名"),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "匹配域名关键字",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "通配符匹配，仅支持*和?通配符",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "匹配域名后缀",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "匹配DSCP标记 (仅限 tproxy udp 入站)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage("匹配请求目标端口范围"),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage("匹配 IP 所属国家代码"),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "匹配 Geosite 内的域名",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage("匹配入站名称"),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage("匹配入站端口"),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage("匹配入站类型"),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "匹配入站用户名，支持使用 / 分隔多个用户名",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage("匹配 IP 所属 ASN"),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "匹配 IP 地址范围, IP-CIDR6 只是一个别名",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage("匹配 IP 地址范围"),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "匹配 IP 后缀范围",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage("匹配所有请求，无需条件"),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage("匹配TCP或者UDP"),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage("逻辑规则 NOT"),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("逻辑规则 OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "使用进程匹配，在Android平台可以匹配包名",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "使用进程名称正则表达式匹配，在Android平台可以匹配包名",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "使用完整进程路径匹配",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "使用进程路径正则表达式匹配",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "引用规则集合，需配置rule-providers",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "匹配来源 IP 所属国家代码",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "匹配来源 IP 所属 ASN",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "匹配来源 IP 地址范围",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "匹配来源 IP 后缀范围",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage("匹配请求来源端口范围"),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "匹配至子规则,需要注意括号的使用",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "匹配 Linux USER ID",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("规则为空"),
    "ruleName": MessageLookupByLibrary.simpleMessage("规则名称"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("规则集"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("规则目标"),
    "rules": MessageLookupByLibrary.simpleMessage("规则"),
    "rulesCount": m30,
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("是否保存更改？"),
    "schedule": MessageLookupByLibrary.simpleMessage("按时间"),
    "scheduleDesc": m31,
    "script": MessageLookupByLibrary.simpleMessage("脚本"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "脚本模式，使用外部扩展脚本，提供一键覆写配置的能力",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage("滚动到已选"),
    "search": MessageLookupByLibrary.simpleMessage("搜索"),
    "seconds": MessageLookupByLibrary.simpleMessage("秒"),
    "secondsCount": m32,
    "selectAll": MessageLookupByLibrary.simpleMessage("全选"),
    "selectMatchTarget": MessageLookupByLibrary.simpleMessage(
      "选择 MATCH-TARGET",
    ),
    "selectProxies": MessageLookupByLibrary.simpleMessage("选择代理"),
    "selectProxyProviders": MessageLookupByLibrary.simpleMessage("选择代理集"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage("请选择规则集"),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage("请选择分流策略"),
    "selectSubRule": MessageLookupByLibrary.simpleMessage("请选择子规则"),
    "selected": MessageLookupByLibrary.simpleMessage("已选择"),
    "selectedCountTitle": m33,
    "sendDeviceIdentity": MessageLookupByLibrary.simpleMessage("发送 HWID"),
    "sendDeviceIdentityDesc": MessageLookupByLibrary.simpleMessage(
      "将设备标识符、应用版本和设备名称发送到订阅服务器",
    ),
    "serviceInfo": MessageLookupByLibrary.simpleMessage("服务"),
    "settings": MessageLookupByLibrary.simpleMessage("设置"),
    "setupAutoRun": MessageLookupByLibrary.simpleMessage("启动时连接"),
    "setupAutoRunDesc": MessageLookupByLibrary.simpleMessage("打开应用后立即建立隧道"),
    "setupDataCollection": MessageLookupByLibrary.simpleMessage("发送崩溃报告"),
    "setupDone": MessageLookupByLibrary.simpleMessage("完成"),
    "setupFinishTitle": MessageLookupByLibrary.simpleMessage("就快好了"),
    "setupLanguageDesc": MessageLookupByLibrary.simpleMessage("之后可以在设置中更改"),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage("选择语言"),
    "setupLegalTitle": MessageLookupByLibrary.simpleMessage("开始之前"),
    "setupNext": MessageLookupByLibrary.simpleMessage("下一步"),
    "setupPermissionNotifications": MessageLookupByLibrary.simpleMessage("通知"),
    "setupPermissionNotificationsDesc": MessageLookupByLibrary.simpleMessage(
      "运行时显示连接状态",
    ),
    "setupPermissionVpn": MessageLookupByLibrary.simpleMessage("VPN 权限"),
    "setupPermissionVpnDesc": MessageLookupByLibrary.simpleMessage(
      "首次连接时系统会询问",
    ),
    "setupRegionDesc": MessageLookupByLibrary.simpleMessage("决定选择服务器时的初始设置"),
    "setupRegionNone": MessageLookupByLibrary.simpleMessage("不选择"),
    "setupRestore": MessageLookupByLibrary.simpleMessage("从备份恢复"),
    "setupRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "从 ReClash、FlClashX 或 FlClash 的备份迁移数据",
    ),
    "setupSkip": MessageLookupByLibrary.simpleMessage("跳过"),
    "setupSubscriptionDesc": MessageLookupByLibrary.simpleMessage(
      "机场提供的链接、二维码或配置文件",
    ),
    "setupSubscriptionReady": MessageLookupByLibrary.simpleMessage("订阅已添加"),
    "setupSubscriptionTitle": MessageLookupByLibrary.simpleMessage("添加订阅"),
    "setupWelcome": MessageLookupByLibrary.simpleMessage("一分钟完成设置"),
    "show": MessageLookupByLibrary.simpleMessage("显示"),
    "showLabels": MessageLookupByLibrary.simpleMessage("侧栏标签"),
    "showLess": MessageLookupByLibrary.simpleMessage("收起"),
    "showMore": MessageLookupByLibrary.simpleMessage("展开"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "通知栏显示停止按钮",
    ),
    "showNotificationStopActionDesc": MessageLookupByLibrary.simpleMessage(
      "在常驻通知上显示停止按钮。若系统因此总是展开通知，可关闭",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("显示密码"),
    "shrink": MessageLookupByLibrary.simpleMessage("紧凑"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("静默启动"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage("后台启动"),
    "size": MessageLookupByLibrary.simpleMessage("尺寸"),
    "smartPause": MessageLookupByLibrary.simpleMessage("智能暂停"),
    "smartPauseCloseConnections": MessageLookupByLibrary.simpleMessage("断开连接"),
    "smartPauseDesc": MessageLookupByLibrary.simpleMessage("在受信任的网络中自动暂停 VPN"),
    "smartRouting": MessageLookupByLibrary.simpleMessage("智能路由"),
    "smartRoutingAliveCount": m34,
    "smartRoutingAllServers": MessageLookupByLibrary.simpleMessage("所有服务器"),
    "smartRoutingBackToAuto": MessageLookupByLibrary.simpleMessage("恢复自动选择"),
    "smartRoutingBandLabel": m35,
    "smartRoutingBands": m36,
    "smartRoutingBehaviour": MessageLookupByLibrary.simpleMessage("行为"),
    "smartRoutingBlockAbsent": MessageLookupByLibrary.simpleMessage(
      "不在当前服务器列表中",
    ),
    "smartRoutingBlockCooling": m37,
    "smartRoutingBlockDisproven": MessageLookupByLibrary.simpleMessage(
      "在这里未通过检查",
    ),
    "smartRoutingBlockLastResort": MessageLookupByLibrary.simpleMessage(
      "本地服务器，在此网络被禁用",
    ),
    "smartRoutingBlockNoUdp": MessageLookupByLibrary.simpleMessage("不支持 UDP"),
    "smartRoutingBlockTerrainUnfit": MessageLookupByLibrary.simpleMessage(
      "此网络上暂时无法路由",
    ),
    "smartRoutingBreaker": MessageLookupByLibrary.simpleMessage("白名单专用"),
    "smartRoutingBreakerDesc": MessageLookupByLibrary.simpleMessage(
      "为受限网络保留，不在开放网络上消耗",
    ),
    "smartRoutingBreakerPatterns": MessageLookupByLibrary.simpleMessage(
      "白名单专用服务器名称",
    ),
    "smartRoutingBreakerPatternsDesc": MessageLookupByLibrary.simpleMessage(
      "标记为受限网络专用服务器的名称片段",
    ),
    "smartRoutingCanaries": MessageLookupByLibrary.simpleMessage("探测地址"),
    "smartRoutingCanariesAnswered": m38,
    "smartRoutingCanariesDomestic": MessageLookupByLibrary.simpleMessage(
      "本地探测地址",
    ),
    "smartRoutingCanariesDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "直连，用来区分白名单网络与完全断网",
    ),
    "smartRoutingCanariesForeign": MessageLookupByLibrary.simpleMessage(
      "境外探测地址",
    ),
    "smartRoutingCanariesForeignDesc": MessageLookupByLibrary.simpleMessage(
      "直连 IP:端口，用来区分开放网络与断网封锁",
    ),
    "smartRoutingCanaryDomestic": MessageLookupByLibrary.simpleMessage("本地"),
    "smartRoutingCanaryForeign": MessageLookupByLibrary.simpleMessage("境外"),
    "smartRoutingCensor": MessageLookupByLibrary.simpleMessage("审查国家/地区"),
    "smartRoutingCensorDesc": MessageLookupByLibrary.simpleMessage(
      "这些地区的服务器算作本地，因此会保留到断网封锁时再用",
    ),
    "smartRoutingChosen": MessageLookupByLibrary.simpleMessage("已选服务器"),
    "smartRoutingChosenNone": MessageLookupByLibrary.simpleMessage("尚未选择服务器"),
    "smartRoutingCoolFor": m39,
    "smartRoutingDeepScan": MessageLookupByLibrary.simpleMessage("检查所有服务器"),
    "smartRoutingDeepScanHint": MessageLookupByLibrary.simpleMessage(
      "会忽略探测额度，因此消耗流量",
    ),
    "smartRoutingDeepScanRunning": MessageLookupByLibrary.simpleMessage(
      "正在检查所有服务器…",
    ),
    "smartRoutingDegraded": MessageLookupByLibrary.simpleMessage("被限速"),
    "smartRoutingDesc": MessageLookupByLibrary.simpleMessage(
      "无需打开应用，为每个网络自动保持可用的服务器",
    ),
    "smartRoutingDetection": MessageLookupByLibrary.simpleMessage("网络判定"),
    "smartRoutingDomestic": MessageLookupByLibrary.simpleMessage("断网期间使用本地服务器"),
    "smartRoutingDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "白名单网络下的最后手段，让本地服务仍可使用",
    ),
    "smartRoutingDomesticViaDirect": MessageLookupByLibrary.simpleMessage(
      "国内服务直连",
    ),
    "smartRoutingDomesticViaNode": MessageLookupByLibrary.simpleMessage(
      "国内服务经由所选服务器",
    ),
    "smartRoutingDwell": MessageLookupByLibrary.simpleMessage("稳定时间"),
    "smartRoutingDwellDesc": MessageLookupByLibrary.simpleMessage(
      "在更快的服务器胜出前，可用服务器保持多久",
    ),
    "smartRoutingEmpty": MessageLookupByLibrary.simpleMessage("暂无测量结果"),
    "smartRoutingEnvKey": MessageLookupByLibrary.simpleMessage("网络记忆键"),
    "smartRoutingEvidenceDomesticFail": MessageLookupByLibrary.simpleMessage(
      "没有本地地址响应",
    ),
    "smartRoutingEvidenceDomesticOk": MessageLookupByLibrary.simpleMessage(
      "本地地址有响应",
    ),
    "smartRoutingEvidenceForeignFail": MessageLookupByLibrary.simpleMessage(
      "没有境外地址响应",
    ),
    "smartRoutingEvidenceForeignOk": MessageLookupByLibrary.simpleMessage(
      "境外地址有响应",
    ),
    "smartRoutingEvidenceFresh": MessageLookupByLibrary.simpleMessage(
      "由最近一次检查确认",
    ),
    "smartRoutingEvidenceLive": MessageLookupByLibrary.simpleMessage(
      "由你自己的流量确认",
    ),
    "smartRoutingEvidenceNone": MessageLookupByLibrary.simpleMessage("从未确认"),
    "smartRoutingEvidencePortal": MessageLookupByLibrary.simpleMessage(
      "系统检测到登录页",
    ),
    "smartRoutingEvidenceStale": MessageLookupByLibrary.simpleMessage(
      "上次确认已有一段时间",
    ),
    "smartRoutingEvidenceUnvalidated": MessageLookupByLibrary.simpleMessage(
      "系统报告无法上网",
    ),
    "smartRoutingEvidenceValidated": MessageLookupByLibrary.simpleMessage(
      "系统确认可以上网",
    ),
    "smartRoutingFails": m40,
    "smartRoutingFormatOffline": MessageLookupByLibrary.simpleMessage("无法连接"),
    "smartRoutingFormatOfflineDesc": MessageLookupByLibrary.simpleMessage(
      "本地和境外都没有响应",
    ),
    "smartRoutingFormatOpen": MessageLookupByLibrary.simpleMessage("完全开放"),
    "smartRoutingFormatOpenDesc": MessageLookupByLibrary.simpleMessage(
      "你与开放互联网之间没有阻断",
    ),
    "smartRoutingFormatPortal": MessageLookupByLibrary.simpleMessage("需要登录"),
    "smartRoutingFormatPortalDesc": MessageLookupByLibrary.simpleMessage(
      "网络要求先登录才放行流量",
    ),
    "smartRoutingFormatRestricted": MessageLookupByLibrary.simpleMessage("受限"),
    "smartRoutingFormatRestrictedDesc": MessageLookupByLibrary.simpleMessage(
      "只有本地服务响应，境外服务不通",
    ),
    "smartRoutingFormatUnknown": MessageLookupByLibrary.simpleMessage("仍在测量"),
    "smartRoutingFormatUnknownDesc": MessageLookupByLibrary.simpleMessage(
      "回应还不足以判断",
    ),
    "smartRoutingHealthBlocked": MessageLookupByLibrary.simpleMessage("已排除"),
    "smartRoutingHealthUnknown": MessageLookupByLibrary.simpleMessage("未检查"),
    "smartRoutingHealthUsable": MessageLookupByLibrary.simpleMessage("可用"),
    "smartRoutingHistory": MessageLookupByLibrary.simpleMessage("最近的切换"),
    "smartRoutingHistoryEmpty": MessageLookupByLibrary.simpleMessage("还没有切换过"),
    "smartRoutingHostDelay": MessageLookupByLibrary.simpleMessage("来自延迟测试"),
    "smartRoutingKept": MessageLookupByLibrary.simpleMessage("保持"),
    "smartRoutingKeyBand": MessageLookupByLibrary.simpleMessage("延迟档"),
    "smartRoutingKeyEvidence": MessageLookupByLibrary.simpleMessage("证据"),
    "smartRoutingKeyHistory": MessageLookupByLibrary.simpleMessage("本网络的历史"),
    "smartRoutingKeyMisfit": MessageLookupByLibrary.simpleMessage("对本网络的适配"),
    "smartRoutingKeyVerdict": MessageLookupByLibrary.simpleMessage("结论"),
    "smartRoutingManualHold": MessageLookupByLibrary.simpleMessage("尊重手动选择"),
    "smartRoutingManualHoldDesc": MessageLookupByLibrary.simpleMessage(
      "保留你手动选择的服务器，直到它失效",
    ),
    "smartRoutingManualPinned": MessageLookupByLibrary.simpleMessage("保持到失效为止"),
    "smartRoutingMarkerStatuses": MessageLookupByLibrary.simpleMessage(
      "可接受状态码",
    ),
    "smartRoutingMarkerStatusesHint": MessageLookupByLibrary.simpleMessage(
      "用逗号分隔，例如 200, 204, 404",
    ),
    "smartRoutingMarkerStatusesTip": MessageLookupByLibrary.simpleMessage(
      "请用逗号分隔 HTTP 状态码",
    ),
    "smartRoutingMarkerUrl": MessageLookupByLibrary.simpleMessage("URL"),
    "smartRoutingMarkers": MessageLookupByLibrary.simpleMessage("服务检查"),
    "smartRoutingMarkersDomestic": MessageLookupByLibrary.simpleMessage("本地检查"),
    "smartRoutingMarkersDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "断网封锁期间用于本地服务器",
    ),
    "smartRoutingMarkersEmpty": MessageLookupByLibrary.simpleMessage("尚未配置检查"),
    "smartRoutingMarkersOpen": MessageLookupByLibrary.simpleMessage("开放互联网检查"),
    "smartRoutingMarkersOpenDesc": MessageLookupByLibrary.simpleMessage(
      "只有返回其中一个状态码，服务器才算通过",
    ),
    "smartRoutingMetered": MessageLookupByLibrary.simpleMessage("计费网络"),
    "smartRoutingNetworkFormat": MessageLookupByLibrary.simpleMessage("网络"),
    "smartRoutingNeverSwitched": MessageLookupByLibrary.simpleMessage(
      "此网络尚未切换过",
    ),
    "smartRoutingNoAnswer": MessageLookupByLibrary.simpleMessage("无响应"),
    "smartRoutingNoServers": MessageLookupByLibrary.simpleMessage("没有可用的服务器"),
    "smartRoutingNodeChecks": MessageLookupByLibrary.simpleMessage("服务器检查"),
    "smartRoutingNodeNoUdp": MessageLookupByLibrary.simpleMessage("无 UDP"),
    "smartRoutingNodeUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "smartRoutingNodesMeasured": m41,
    "smartRoutingNotBreaker": MessageLookupByLibrary.simpleMessage("通用"),
    "smartRoutingOffHint": MessageLookupByLibrary.simpleMessage(
      "开启智能路由，让它替你挑选服务器",
    ),
    "smartRoutingOn": MessageLookupByLibrary.simpleMessage("智能路由已开启"),
    "smartRoutingOverview": MessageLookupByLibrary.simpleMessage("路由概览"),
    "smartRoutingPortal": MessageLookupByLibrary.simpleMessage("需要登录 Wi-Fi"),
    "smartRoutingPreset": MessageLookupByLibrary.simpleMessage("预设"),
    "smartRoutingPresetChina": MessageLookupByLibrary.simpleMessage("中国"),
    "smartRoutingPresetEdited": m42,
    "smartRoutingPresetIran": MessageLookupByLibrary.simpleMessage("伊朗"),
    "smartRoutingPresetOff": MessageLookupByLibrary.simpleMessage("关闭"),
    "smartRoutingPresetRussia": MessageLookupByLibrary.simpleMessage("俄罗斯"),
    "smartRoutingProbeBudget": m43,
    "smartRoutingProbing": MessageLookupByLibrary.simpleMessage("探测"),
    "smartRoutingRankOrder": MessageLookupByLibrary.simpleMessage("排序顺序"),
    "smartRoutingRanking": MessageLookupByLibrary.simpleMessage("排序"),
    "smartRoutingRankingDesc": MessageLookupByLibrary.simpleMessage(
      "延迟档固定不可调：这里加开关会让毫秒盖过服务器是否可用",
    ),
    "smartRoutingReasonColdStart": MessageLookupByLibrary.simpleMessage(
      "此网络上的首次选择",
    ),
    "smartRoutingReasonDegraded": MessageLookupByLibrary.simpleMessage(
      "上一台服务器不再传输流量",
    ),
    "smartRoutingReasonDwellHold": MessageLookupByLibrary.simpleMessage(
      "切换前先等过稳定时间",
    ),
    "smartRoutingReasonHold": MessageLookupByLibrary.simpleMessage(
      "运行正常，没有更好的选择",
    ),
    "smartRoutingReasonIncumbentDead": MessageLookupByLibrary.simpleMessage(
      "上一台服务器不再响应",
    ),
    "smartRoutingReasonLatencyGain": MessageLookupByLibrary.simpleMessage(
      "这台快了一个延迟档",
    ),
    "smartRoutingReasonManualHold": MessageLookupByLibrary.simpleMessage(
      "尊重你选择的服务器",
    ),
    "smartRoutingReasonMeasuring": MessageLookupByLibrary.simpleMessage(
      "切换前正在核实候选服务器",
    ),
    "smartRoutingReasonNoCandidate": MessageLookupByLibrary.simpleMessage(
      "没有服务器通过检查",
    ),
    "smartRoutingReasonPinReturn": MessageLookupByLibrary.simpleMessage(
      "你选择的服务器又能用了",
    ),
    "smartRoutingReasonStranded": MessageLookupByLibrary.simpleMessage(
      "没有可用目标，保持当前服务器",
    ),
    "smartRoutingReasonTerrainChanged": MessageLookupByLibrary.simpleMessage(
      "网络发生了变化",
    ),
    "smartRoutingReasonVerdictGain": MessageLookupByLibrary.simpleMessage(
      "这台已证实可通往开放互联网",
    ),
    "smartRoutingRecheck": MessageLookupByLibrary.simpleMessage("立即检查"),
    "smartRoutingRegion": MessageLookupByLibrary.simpleMessage("地区"),
    "smartRoutingRequireUdp": MessageLookupByLibrary.simpleMessage("要求支持 UDP"),
    "smartRoutingRequireUdpDesc": MessageLookupByLibrary.simpleMessage(
      "跳过无法承载通话和游戏的服务器",
    ),
    "smartRoutingResetSection": MessageLookupByLibrary.simpleMessage("恢复为预设"),
    "smartRoutingResetSectionDesc": MessageLookupByLibrary.simpleMessage(
      "恢复该地区默认值，并保持智能路由开启",
    ),
    "smartRoutingRestricted": MessageLookupByLibrary.simpleMessage(
      "受限网络 · 本地服务直连",
    ),
    "smartRoutingRetrying": MessageLookupByLibrary.simpleMessage(
      "服务器无响应，正在寻找替代",
    ),
    "smartRoutingRuleOnly": MessageLookupByLibrary.simpleMessage("仅在规则模式下可用"),
    "smartRoutingSearching": MessageLookupByLibrary.simpleMessage("正在挑选服务器…"),
    "smartRoutingSeconds": m44,
    "smartRoutingSectionHealth": MessageLookupByLibrary.simpleMessage("服务器"),
    "smartRoutingSectionHistory": MessageLookupByLibrary.simpleMessage("早前的切换"),
    "smartRoutingSectionNetwork": MessageLookupByLibrary.simpleMessage("网络"),
    "smartRoutingSectionRound": MessageLookupByLibrary.simpleMessage("决策"),
    "smartRoutingServers": MessageLookupByLibrary.simpleMessage("服务器"),
    "smartRoutingServersCount": m45,
    "smartRoutingStepAdmit": MessageLookupByLibrary.simpleMessage("决定谁可参选"),
    "smartRoutingStepAdmitBody": m46,
    "smartRoutingStepDecision": MessageLookupByLibrary.simpleMessage("最终选择"),
    "smartRoutingStepNetwork": MessageLookupByLibrary.simpleMessage("读取网络"),
    "smartRoutingStepRank": MessageLookupByLibrary.simpleMessage("对余下的排序"),
    "smartRoutingStepRankBody": MessageLookupByLibrary.simpleMessage(
      "先看结论，再看是否适配本网络，然后是证据，接着是延迟档，最后才是历史",
    ),
    "smartRoutingStrategy": MessageLookupByLibrary.simpleMessage("策略"),
    "smartRoutingStrategyBalanced": MessageLookupByLibrary.simpleMessage("均衡"),
    "smartRoutingStrategyDesc": MessageLookupByLibrary.simpleMessage(
      "引擎如何在延迟与稳定之间取舍",
    ),
    "smartRoutingStrategyLowestLatency": MessageLookupByLibrary.simpleMessage(
      "最低延迟",
    ),
    "smartRoutingSwitchLine": m47,
    "smartRoutingSwitched": MessageLookupByLibrary.simpleMessage("已切换"),
    "smartRoutingSwitchedAgo": m48,
    "smartRoutingTechnical": MessageLookupByLibrary.simpleMessage("技术细节"),
    "smartRoutingUntested": MessageLookupByLibrary.simpleMessage("未测试"),
    "smartRoutingVerdictLastResort": MessageLookupByLibrary.simpleMessage(
      "最后手段",
    ),
    "smartRoutingVerdictPreferred": MessageLookupByLibrary.simpleMessage(
      "可通往开放互联网",
    ),
    "smartRoutingVerdictReject": MessageLookupByLibrary.simpleMessage("不可用"),
    "smartRoutingVerdictViable": MessageLookupByLibrary.simpleMessage("可用"),
    "smartRoutingWave": MessageLookupByLibrary.simpleMessage("每次检查的服务器数"),
    "smartRoutingWaveDesc": MessageLookupByLibrary.simpleMessage(
      "一次后台检查测量多少台服务器",
    ),
    "smartRoutingWaveNodes": m49,
    "smartRoutingWhatWasTested": MessageLookupByLibrary.simpleMessage("链路检查"),
    "smartRoutingWhy": MessageLookupByLibrary.simpleMessage("原因"),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socks端口"),
    "sort": MessageLookupByLibrary.simpleMessage("排序"),
    "source": MessageLookupByLibrary.simpleMessage("来源"),
    "sourceCode": MessageLookupByLibrary.simpleMessage("源代码"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("源IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("特殊代理"),
    "specialRules": MessageLookupByLibrary.simpleMessage("特殊规则"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("网速统计"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("分流策略"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage("分流策略不能为空"),
    "stackMode": MessageLookupByLibrary.simpleMessage("栈模式"),
    "standard": MessageLookupByLibrary.simpleMessage("标准"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "标准模式，覆写基础配置，提供简单追加规则能力",
    ),
    "start": MessageLookupByLibrary.simpleMessage("启动"),
    "startVpn": MessageLookupByLibrary.simpleMessage("正在启动VPN..."),
    "status": MessageLookupByLibrary.simpleMessage("状态"),
    "statusDesc": MessageLookupByLibrary.simpleMessage("关闭后将使用系统DNS"),
    "stop": MessageLookupByLibrary.simpleMessage("暂停"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("正在停止VPN..."),
    "style": MessageLookupByLibrary.simpleMessage("风格"),
    "subRule": MessageLookupByLibrary.simpleMessage("子规则"),
    "subRuleEmpty": MessageLookupByLibrary.simpleMessage("子规则为空"),
    "subRuleNotEmpty": MessageLookupByLibrary.simpleMessage("子规则不能为空"),
    "submit": MessageLookupByLibrary.simpleMessage("提交"),
    "subscriptionCaption": MessageLookupByLibrary.simpleMessage("订阅"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage("自动"),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage("自定义"),
    "subscriptionClientDesc": MessageLookupByLibrary.simpleMessage(
      "应用会模拟此客户端来获取订阅",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientLabel": MessageLookupByLibrary.simpleMessage("客户端格式"),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "Sing-box",
    ),
    "subscriptionClientV2rayNG": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionDomainMoved": m50,
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage("订阅已过期"),
    "subscriptionExpiresInDays": m51,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage("订阅今天到期"),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage("订阅信息"),
    "subscriptionNoQuota": MessageLookupByLibrary.simpleMessage(
      "此订阅未提供流量额度或到期时间",
    ),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage("订阅提醒"),
    "subscriptionProviderInterval": m52,
    "subscriptionUpdated": MessageLookupByLibrary.simpleMessage("更新于"),
    "support": MessageLookupByLibrary.simpleMessage("支持"),
    "sync": MessageLookupByLibrary.simpleMessage("同步"),
    "system": MessageLookupByLibrary.simpleMessage("系统"),
    "systemApp": MessageLookupByLibrary.simpleMessage("系统应用"),
    "systemColor": MessageLookupByLibrary.simpleMessage("跟随系统颜色"),
    "systemColorDesc": MessageLookupByLibrary.simpleMessage(
      "使用系统强调色（Material You）",
    ),
    "systemProxy": MessageLookupByLibrary.simpleMessage("系统代理"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage("设置系统代理"),
    "systemSeed": MessageLookupByLibrary.simpleMessage("系统颜色"),
    "tab": MessageLookupByLibrary.simpleMessage("标签页"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("选项卡动画"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage("仅在移动视图中有效"),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("点击授权"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP并发"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage("开启后允许TCP并发"),
    "testInterval": MessageLookupByLibrary.simpleMessage("测试间隔"),
    "testUrl": MessageLookupByLibrary.simpleMessage("测速链接"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("使用时测试"),
    "textScale": MessageLookupByLibrary.simpleMessage("文本缩放"),
    "theme": MessageLookupByLibrary.simpleMessage("主题"),
    "themeColor": MessageLookupByLibrary.simpleMessage("主题色彩"),
    "themeDesc": MessageLookupByLibrary.simpleMessage("设置深色模式，调整色彩"),
    "themeMode": MessageLookupByLibrary.simpleMessage("主题模式"),
    "tight": MessageLookupByLibrary.simpleMessage("紧凑"),
    "time": MessageLookupByLibrary.simpleMessage("时间"),
    "timeout": MessageLookupByLibrary.simpleMessage("超时"),
    "tip": MessageLookupByLibrary.simpleMessage("提示"),
    "toggle": MessageLookupByLibrary.simpleMessage("切换"),
    "toggleLabel": MessageLookupByLibrary.simpleMessage("切换标签"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("调性点缀"),
    "tools": MessageLookupByLibrary.simpleMessage("工具"),
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("购买流量"),
    "torch": MessageLookupByLibrary.simpleMessage("手电筒"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("总流量"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxy端口"),
    "trafficFreeOfTotal": m53,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("流量统计"),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage("受信任的网络"),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "连接这些网络时 VPN 会自动暂停",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "当前网络受信任 — 在此网络中会暂停 VPN",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("虚拟网卡"),
    "tunDesc": MessageLookupByLibrary.simpleMessage("仅在管理员模式生效"),
    "turnOff": MessageLookupByLibrary.simpleMessage("关闭"),
    "turnOn": MessageLookupByLibrary.simpleMessage("开启"),
    "undo": MessageLookupByLibrary.simpleMessage("撤销"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("统一延迟"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage("去除握手等额外延迟"),
    "unknown": MessageLookupByLibrary.simpleMessage("未知"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage("未知网络错误"),
    "unmaximize": MessageLookupByLibrary.simpleMessage("向下还原"),
    "unnamed": MessageLookupByLibrary.simpleMessage("未命名"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("取消置顶"),
    "update": MessageLookupByLibrary.simpleMessage("更新"),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage("下载更新失败"),
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage("下载的文件已损坏"),
    "upload": MessageLookupByLibrary.simpleMessage("上传"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("通过URL获取配置文件"),
    "urlTip": m54,
    "useHosts": MessageLookupByLibrary.simpleMessage("使用Hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("使用系统Hosts"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("已用流量"),
    "userAgent": MessageLookupByLibrary.simpleMessage("用户代理"),
    "value": MessageLookupByLibrary.simpleMessage("值"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("活力"),
    "view": MessageLookupByLibrary.simpleMessage("查看"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "检测到VPN相关配置改动",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "通过VpnService自动路由系统所有流量",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage("重启VPN后改变生效"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage("WebDAV配置"),
    "webDashboard": MessageLookupByLibrary.simpleMessage("网页面板"),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "由内核自身提供的 zashboard",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "首次打开时下载 zashboard",
    ),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage("打开面板"),
    "webDashboardSessionTip": MessageLookupByLibrary.simpleMessage(
      "面板打开期间外部控制器保持开启",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage("内核尚未提供面板"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("白名单模式"),
    "yearsAgo": m55,
    "zhCN": MessageLookupByLibrary.simpleMessage("中文简体"),
  };
}
