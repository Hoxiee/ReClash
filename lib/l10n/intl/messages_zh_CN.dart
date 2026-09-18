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

  static String m0(time) => "DPI 绕过已运行 ${time}";

  static String m1(time) => "已连接 ${time}";

  static String m2(code) =>
      "Windows 拒绝运行 ReClashCore.exe（错误 ${code}）。智能应用控制、AppLocker 等应用控制策略会拦截未签名程序，请在该策略中放行 ReClash 或关闭策略后重试。";

  static String m3(name) =>
      "应用连续两次未能完成启动。为打断崩溃循环，已取消选中配置 ${name}，并跳过本次自动配置，你可以随时重新选中它。";

  static String m4(url) => "是否要通过 ${url} 创建配置？";

  static String m5(date, days) => "始于 ${date} · 已覆盖 ${days} 天";

  static String m6(count) => "${count} 天前";

  static String m7(count) => "${count} 天";

  static String m8(label) => "确定删除选中的${label}吗？";

  static String m9(label) => "确定删除当前${label}吗？";

  static String m10(token) => "${token} 由应用设定，将被忽略";

  static String m11(count) => "${Intl.plural(count, other: '${count} 个参数')}";

  static String m12(token) => "${token} 需要一个值";

  static String m13(token) => "${token} 不是选项";

  static String m14(token) => "未知选项 ${token}";

  static String m15(count) => "${count} 个路由分类使用 ByeDPI 引擎";

  static String m16(passed, total) => "阶梯结果：${passed}/${total}";

  static String m17(presets, groups, domains) =>
      "${presets} 个预设 · ${groups} 个分组 · ${domains} 个主机";

  static String m18(count) => "${Intl.plural(count, other: '${count} 个域名')}";

  static String m19(count) => "完成：已测试 ${count} 个策略";

  static String m20(count) => "通过引擎对 ${count} 个主机逐个测试所有已知策略；结束后会恢复当前策略";

  static String m21(index, total) => "正在测试第 ${index} 个，共 ${total} 个";

  static String m22(passed, total) => "${passed} / ${total} 个主机可达";

  static String m23(label) => "${label}详情";

  static String m24(days) => "${days} 天";

  static String m25(name) => "已安装 ${name}";

  static String m26(count) => "高负载时丢弃了 ${count} 个证据事件，可信度未提高。";

  static String m27(completed, total) => "正在检查连接：${completed}/${total}";

  static String m28(layer) => "连接问题：${layer}";

  static String m29(completed, total) => "第 ${completed} 步，共 ${total} 步";

  static String m30(label) => "${label}不能为空";

  static String m31(count) => "${count} 个条目";

  static String m32(label) => "${label}当前已存在";

  static String m33(action) => "允许此外部链接执行“${action}”吗？";

  static String m34(date) => "发现于 ${date}";

  static String m35(found, total) => "已发现 ${found}/${total}";

  static String m36(name) => "${name} 已是最新版本";

  static String m37(name) => "${name} 已更新";

  static String m38(time) => "${time}前";

  static String m39(count) => "${count} 小时前";

  static String m40(count) => "${count} 小时";

  static String m41(target) => "${target} 是一个无效的策略";

  static String m42(proxyName) => "${proxyName} 是一个无效的代理";

  static String m43(providerName) => "${providerName} 是一个无效的代理集";

  static String m44(subRule) => "${subRule} 是一个无效的SUB_RULE";

  static String m45(address) => "或在手机浏览器中打开 ${address}";

  static String m46(appName) =>
      "1. 打开 系统设置 > 隐私与安全性\n2. 选择 定位服务\n3. 在右侧列表中找到并勾选 ${appName}\n\n完成设置后，返回应用即可正常使用。感谢您的配合。";

  static String m47(label, max) => "${label}最多${max}个字符";

  static String m48(count) => "${count} 分钟前";

  static String m49(count) => "${count} 个月前";

  static String m50(label) => "暂无${label}";

  static String m51(label) => "${label}必须为数字";

  static String m52(settings) => "此订阅请求以下全局应用设置：\n${settings}";

  static String m53(label) => "${label} 必须在 1024 到 49151 之间";

  static String m54(count) => "配置已导入，已跳过 ${count} 个不受支持的节点";

  static String m55(format, client, nodes, groups) =>
      "已导入：${format} · ${client} · ${nodes} 个节点 · ${groups} 个组";

  static String m56(days) => "已有 ${days} 天未使用";

  static String m57(months) => "已有 ${months} 个月未使用";

  static String m58(count) => "${count} 个代理";

  static String m59(count) => "配置：${count}";

  static String m60(count) => "代理组：${count}";

  static String m61(count) => "规则：${count}";

  static String m62(count) => "脚本：${count}";

  static String m63(count) => "${count} 条规则";

  static String m64(darkAt, lightAt) => "${darkAt} 至 ${lightAt} 使用深色";

  static String m65(count) => "${count} 秒";

  static String m66(count) => "已选择 ${count} 项";

  static String m67(count) => "已有 ${count} 个配置就绪";

  static String m68(step, count) => "第 ${step} 步，共 ${count} 步";

  static String m69(name) => "配置：${name}";

  static String m70(value) => "智能路由：${value}";

  static String m71(alive, total) => "当前可用 ${alive} / ${total} 个服务器";

  static String m72(percent, duration) => "${duration}内为 ${percent}%";

  static String m73(band) => "第 ${band} 档";

  static String m74(bands) => "延迟档：${bands}";

  static String m75(count) => "${count} 次失败后正在冷却";

  static String m76(answered, total) => "${total} 个中有 ${answered} 个响应";

  static String m77(seconds) => "还剩 ${seconds} 秒";

  static String m78(count) => "连续失败 ${count} 次";

  static String m79(step) => "落败于：${step}";

  static String m80(duration) => "统计时长 ${duration}";

  static String m81(measured, total) => "已测量 ${measured} / ${total}";

  static String m82(preset) => "${preset} · 已调整";

  static String m83(left, cap) => "本小时还剩 ${left}/${cap} 次探测";

  static String m84(value, against) => "${value} 对 ${against}";

  static String m85(seconds) => "${seconds} 秒";

  static String m86(eligible, total) => "${total} 台中 ${eligible} 台可用";

  static String m87(count) => "${count} 个专用节点选择器";

  static String m88(provider) => "提供商：${provider}";

  static String m89(count) => "提供商提供了 ${count} 个选择器";

  static String m90(eligible, total) => "${total} 个服务器中 ${eligible} 个就绪";

  static String m91(label) => "${label} 最多允许 64 个 UTF-8 字节";

  static String m92(node) => "通过 ${node}";

  static String m93(eligible, total, blocked) =>
      "${total} 个中 ${eligible} 个通过，${blocked} 个被拦下";

  static String m94(strategy) => "${strategy} · 已调整";

  static String m95(from, to) => "${from} → ${to}";

  static String m96(time) => "${time}前切换";

  static String m97(count) => "${count} 台";

  static String m98(step) => "排名更高于：${step}";

  static String m99(host) => "提供方已迁移至 ${host}";

  static String m100(count) => "订阅将在 ${count} 天后到期";

  static String m101(value) => "提供方建议 ${value}";

  static String m102(total) => "剩余（共 ${total}）";

  static String m103(label) => "${label}必须为URL";

  static String m104(count) => "最多可保存 ${count} 张背景。删除一张后才能添加新背景。";

  static String m105(count) => "${count} 年前";

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
    "accessControlExcludeFromVpn": MessageLookupByLibrary.simpleMessage(
      "从 VPN 中排除",
    ),
    "accessControlIncludeInVpn": MessageLookupByLibrary.simpleMessage(
      "包含在 VPN 中",
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
    "animations": MessageLookupByLibrary.simpleMessage("动画"),
    "announce": MessageLookupByLibrary.simpleMessage("公告"),
    "app": MessageLookupByLibrary.simpleMessage("应用"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage("应用访问控制"),
    "appIconBlueprint": MessageLookupByLibrary.simpleMessage("蓝图"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "启动器会在几秒后重绘图标。部分启动器上固定的快捷方式可能消失。",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("电路"),
    "appIconEcho": MessageLookupByLibrary.simpleMessage("回响"),
    "appIconFacet": MessageLookupByLibrary.simpleMessage("切面"),
    "appIconFractal": MessageLookupByLibrary.simpleMessage("分形"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("墨迹"),
    "appIconInstall": MessageLookupByLibrary.simpleMessage("安装"),
    "appIconMesh": MessageLookupByLibrary.simpleMessage("网格"),
    "appIconPreview": MessageLookupByLibrary.simpleMessage("图标预览"),
    "appIconShatter": MessageLookupByLibrary.simpleMessage("碎裂"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("日耀"),
    "appIconSpark": MessageLookupByLibrary.simpleMessage("火花"),
    "appIconStrata": MessageLookupByLibrary.simpleMessage("层叠"),
    "appIconTopo": MessageLookupByLibrary.simpleMessage("地形"),
    "appIconTrace": MessageLookupByLibrary.simpleMessage("轨迹"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("天鹅绒"),
    "appIconVigil": MessageLookupByLibrary.simpleMessage("守望"),
    "appRegion": MessageLookupByLibrary.simpleMessage("应用地区"),
    "appRegionDesc": MessageLookupByLibrary.simpleMessage(
      "选择网络所在地区。选择俄罗斯会启用 HWID，您可以在下方关闭。智能路由单独设置。",
    ),
    "appRegionOther": MessageLookupByLibrary.simpleMessage("其他"),
    "appearance": MessageLookupByLibrary.simpleMessage("外观"),
    "appearanceBackground": MessageLookupByLibrary.simpleMessage("背景"),
    "appearanceDesc": MessageLookupByLibrary.simpleMessage("主题、颜色、图标与面板外观"),
    "appearanceIcon": MessageLookupByLibrary.simpleMessage("图标"),
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
    "byedpiActive": MessageLookupByLibrary.simpleMessage("DPI 绕过已启用"),
    "byedpiActiveFor": m0,
    "byedpiChecking": MessageLookupByLibrary.simpleMessage("正在检查 DPI 引擎"),
    "byedpiEngineError": MessageLookupByLibrary.simpleMessage("DPI 引擎需要检查"),
    "byedpiOff": MessageLookupByLibrary.simpleMessage("DPI 绕过已关闭"),
    "byedpiPaused": MessageLookupByLibrary.simpleMessage("DPI 绕过已暂停"),
    "byedpiReconnecting": MessageLookupByLibrary.simpleMessage("正在重启 DPI 引擎"),
    "byedpiStarting": MessageLookupByLibrary.simpleMessage("正在启动 DPI 绕过"),
    "byedpiTapToResume": MessageLookupByLibrary.simpleMessage("点按以恢复 DPI 绕过"),
    "byedpiTapToStart": MessageLookupByLibrary.simpleMessage("点按以启动本地绕过引擎"),
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
    "connectedFor": m1,
    "connecting": MessageLookupByLibrary.simpleMessage("连接中..."),
    "connection": MessageLookupByLibrary.simpleMessage("连接"),
    "connectionDoctor": MessageLookupByLibrary.simpleMessage("连接诊断"),
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
    "coreBlockedByPolicyTip": m2,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows 智能应用控制拦截了未签名的 ReClashCore.exe。请打开 Windows 安全中心 → 应用和浏览器控制 → 智能应用控制设置，选择「关闭」后重新启动 ReClash。智能应用控制关闭后无法再开启，除非重装 Windows。",
    ),
    "coreRunning": MessageLookupByLibrary.simpleMessage("运行中"),
    "coreStarting": MessageLookupByLibrary.simpleMessage("启动中…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("核心状态"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("已停止"),
    "country": MessageLookupByLibrary.simpleMessage("区域"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("检测到崩溃"),
    "crashDetectedTip": m3,
    "crashTest": MessageLookupByLibrary.simpleMessage("崩溃测试"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("崩溃分析"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "开启后，应用崩溃时自动上传不包含敏感信息的崩溃日志",
    ),
    "create": MessageLookupByLibrary.simpleMessage("创建"),
    "createProfile": MessageLookupByLibrary.simpleMessage("创建配置"),
    "createProfileFromUrlTip": m4,
    "creationTime": MessageLookupByLibrary.simpleMessage("创建时间"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage(
      "FlClash — 本应用的基础客户端",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "FlClashX — 机场功能与思路",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage("mihomo — 代理内核"),
    "crownHistory": m5,
    "custom": MessageLookupByLibrary.simpleMessage("自定义"),
    "customUserAgentLabel": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "cut": MessageLookupByLibrary.simpleMessage("剪切"),
    "dark": MessageLookupByLibrary.simpleMessage("深色"),
    "darkAt": MessageLookupByLibrary.simpleMessage("深色开始"),
    "dashboard": MessageLookupByLibrary.simpleMessage("仪表盘"),
    "dashboardByedpiDesc": MessageLookupByLibrary.simpleMessage(
      "使用“仅 ByeDPI”模式，无需 VPN 配置即可绕过 DPI。",
    ),
    "dashboardByedpiTitle": MessageLookupByLibrary.simpleMessage("没有 VPN 服务商？"),
    "dashboardNoActiveProfileDesc": MessageLookupByLibrary.simpleMessage(
      "已有保存的配置，但当前未选中任何配置。请选择一个配置以使用 VPN 控件。",
    ),
    "dashboardNoActiveProfileTitle": MessageLookupByLibrary.simpleMessage(
      "选择 VPN 配置",
    ),
    "dashboardNoProfileDesc": MessageLookupByLibrary.simpleMessage(
      "请添加来自可信服务提供商的 VPN 配置。在此之前，VPN 将保持关闭。",
    ),
    "dashboardNoProfileTitle": MessageLookupByLibrary.simpleMessage("设置连接"),
    "dashboardProviderDetails": MessageLookupByLibrary.simpleMessage("更多详情"),
    "dashboardSelectProfile": MessageLookupByLibrary.simpleMessage("选择配置"),
    "dashboardShowConnection": MessageLookupByLibrary.simpleMessage("返回连接"),
    "dashboardShowProvider": MessageLookupByLibrary.simpleMessage("显示订阅详情"),
    "dashboardStyle": MessageLookupByLibrary.simpleMessage("面板样式"),
    "dashboardSubscriptionAttention": MessageLookupByLibrary.simpleMessage(
      "需要注意",
    ),
    "dashboardSubscriptionCurrent": MessageLookupByLibrary.simpleMessage(
      "订阅有效",
    ),
    "dashboardSubscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "订阅已过期",
    ),
    "dashboardUseByedpi": MessageLookupByLibrary.simpleMessage("使用 ByeDPI"),
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
    "daysAgo": m6,
    "daysGenitive": MessageLookupByLibrary.simpleMessage("天"),
    "daysLeft": m7,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage("默认域名服务器"),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage("用于解析DNS服务器"),
    "defaultText": MessageLookupByLibrary.simpleMessage("默认"),
    "delay": MessageLookupByLibrary.simpleMessage("延迟"),
    "delayTest": MessageLookupByLibrary.simpleMessage("延迟测试"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "deleteMultipTip": m8,
    "deleteTip": m9,
    "desc": MessageLookupByLibrary.simpleMessage(
      "多平台 mihomo 客户端：重构的仪表盘、更聪明的分流以及完善的订阅支持。开源，无广告，无遥测。",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("目标地址"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("目标地理定位"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("目标IP ASN"),
    "desync": MessageLookupByLibrary.simpleMessage("DPI 绕过"),
    "desyncActiveStrategy": MessageLookupByLibrary.simpleMessage("当前策略"),
    "desyncArgs": MessageLookupByLibrary.simpleMessage("引擎参数"),
    "desyncArgsAppOwnedFlag": m10,
    "desyncArgsCount": m11,
    "desyncArgsHint": MessageLookupByLibrary.simpleMessage(
      "-A torst,conn -L s,o --split 1",
    ),
    "desyncArgsMissingValue": m12,
    "desyncArgsPositional": m13,
    "desyncArgsQuoteError": MessageLookupByLibrary.simpleMessage("引号未闭合"),
    "desyncArgsUnknownFlag": m14,
    "desyncCache": MessageLookupByLibrary.simpleMessage("策略缓存"),
    "desyncCacheDesc": MessageLookupByLibrary.simpleMessage("所选策略按网络分别保存"),
    "desyncCacheDisabled": MessageLookupByLibrary.simpleMessage("策略缓存已关闭"),
    "desyncCacheTtl": MessageLookupByLibrary.simpleMessage("缓存有效期"),
    "desyncDefaultName": MessageLookupByLibrary.simpleMessage("默认阶梯"),
    "desyncDesc": MessageLookupByLibrary.simpleMessage("ByeDPI 失同步策略"),
    "desyncEngine": MessageLookupByLibrary.simpleMessage("引擎"),
    "desyncEngineSummary": m15,
    "desyncForceTcp": MessageLookupByLibrary.simpleMessage("强制 TCP"),
    "desyncForceTcpDesc": MessageLookupByLibrary.simpleMessage(
      "阻止上述分类的 QUIC；失同步无法作用于 UDP",
    ),
    "desyncLadderResult": m16,
    "desyncModeByedpi": MessageLookupByLibrary.simpleMessage("ByeDPI"),
    "desyncModeTitle": MessageLookupByLibrary.simpleMessage("连接模式"),
    "desyncModeVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "desyncRouting": MessageLookupByLibrary.simpleMessage("路由"),
    "desyncRoutingFallbackDesc": MessageLookupByLibrary.simpleMessage(
      "所选 GEOSITE 分类之外的所有流量均直接连接",
    ),
    "desyncRoutingGeositeNote": MessageLookupByLibrary.simpleMessage(
      "分类成员来自内置 GEOSITE 数据库；测试域名列表与其相互独立",
    ),
    "desyncRoutingNoCategories": MessageLookupByLibrary.simpleMessage(
      "未选择绕过分类",
    ),
    "desyncRoutingNoCategoriesDesc": MessageLookupByLibrary.simpleMessage(
      "当前没有服务通过 ByeDPI 路由",
    ),
    "desyncRoutingRules": MessageLookupByLibrary.simpleMessage("生效规则"),
    "desyncSaveCurrent": MessageLookupByLibrary.simpleMessage("保存当前"),
    "desyncStrategyNameHint": MessageLookupByLibrary.simpleMessage("策略名称"),
    "desyncStrategySection": MessageLookupByLibrary.simpleMessage("策略"),
    "desyncTestAborted": MessageLookupByLibrary.simpleMessage("已中止：策略无法送达引擎"),
    "desyncTestBattery": MessageLookupByLibrary.simpleMessage("测试组合"),
    "desyncTestBatterySummary": m17,
    "desyncTestDomains": MessageLookupByLibrary.simpleMessage("测试域名"),
    "desyncTestDomainsCount": m18,
    "desyncTestDone": m19,
    "desyncTestEngineCrashed": MessageLookupByLibrary.simpleMessage(
      "引擎在该策略下崩溃",
    ),
    "desyncTestEngineDown": MessageLookupByLibrary.simpleMessage(
      "引擎未运行 — 请先在启用 DPI 绕过的情况下连接",
    ),
    "desyncTestFailedTitle": MessageLookupByLibrary.simpleMessage("该策略未通过的主机"),
    "desyncTestHint": m20,
    "desyncTestNoLists": MessageLookupByLibrary.simpleMessage("请在下方至少选择一个域名列表"),
    "desyncTestProgress": m21,
    "desyncTestScore": m22,
    "desyncTestSection": MessageLookupByLibrary.simpleMessage("策略测试"),
    "desyncTestStart": MessageLookupByLibrary.simpleMessage("开始"),
    "desyncTestTitle": MessageLookupByLibrary.simpleMessage("运行全部预设"),
    "desyncTtl12Hours": MessageLookupByLibrary.simpleMessage("12 小时"),
    "desyncTtl28Hours": MessageLookupByLibrary.simpleMessage("28 小时"),
    "desyncTtlHour": MessageLookupByLibrary.simpleMessage("1 小时"),
    "desyncTtlWeek": MessageLookupByLibrary.simpleMessage("7 天"),
    "details": m23,
    "detectionTip": MessageLookupByLibrary.simpleMessage("依赖第三方api，仅供参考"),
    "determiningIp": MessageLookupByLibrary.simpleMessage("正在获取 IP..."),
    "developerAllRewards": MessageLookupByLibrary.simpleMessage("预览所有奖励"),
    "developerFindingEvents": MessageLookupByLibrary.simpleMessage("重放发现"),
    "developerFindingQueued": MessageLookupByLibrary.simpleMessage(
      "已排队，等待主页可见且连接正常。可再次重放此发现。",
    ),
    "developerFindings": MessageLookupByLibrary.simpleMessage("发现预览"),
    "developerFindingsDesc": MessageLookupByLibrary.simpleMessage(
      "仅临时预览：不会更改计数、已获得的发现或网络设置。重置或关闭开发者模式即可退出。效果会等待主页可见且连接正常，并遵循外观设置。在外观中选择的图标或主题仍会保存。",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("开发者模式"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage("开发者模式已启用。"),
    "developerPatina": MessageLookupByLibrary.simpleMessage("配置积尘"),
    "developerPatinaDays": m24,
    "developerPreviewAutomatic": MessageLookupByLibrary.simpleMessage("自动"),
    "developerPreviewReset": MessageLookupByLibrary.simpleMessage("清除预览"),
    "developerSeasonAnniversary": MessageLookupByLibrary.simpleMessage(
      "首次启动周年",
    ),
    "developerSeasonBirthday": MessageLookupByLibrary.simpleMessage(
      "ReClash 生日",
    ),
    "developerSeasonDrift": MessageLookupByLibrary.simpleMessage("季节色调"),
    "developerSeasonNewYear": MessageLookupByLibrary.simpleMessage("新年"),
    "developerSubscriptionAtlasDesc": MessageLookupByLibrary.simpleMessage(
      "服务商组件、服务器切换和代理布局",
    ),
    "developerSubscriptionEmberDesc": MessageLookupByLibrary.simpleMessage(
      "一次覆盖所有面板：配额、组件、主题和本地背景",
    ),
    "developerSubscriptionInstalled": m25,
    "developerSubscriptionOrbitDesc": MessageLookupByLibrary.simpleMessage(
      "流量、到期时间、公告、域名迁移和套餐入口",
    ),
    "developerSubscriptionPrismDesc": MessageLookupByLibrary.simpleMessage(
      "品牌颜色、自定义 Hero Ring 和本地徽标",
    ),
    "developerSubscriptions": MessageLookupByLibrary.simpleMessage("测试订阅"),
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
    "discoveredFindings": MessageLookupByLibrary.simpleMessage("已发现"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage("更新DNS相关设置"),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS劫持"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS模式"),
    "doctorBrokenDesc": MessageLookupByLibrary.simpleMessage("已确认第一个故障层。"),
    "doctorBrokenTitle": MessageLookupByLibrary.simpleMessage("发现连接问题"),
    "doctorByeDpiFailedDesc": MessageLookupByLibrary.simpleMessage(
      "本地 ByeDPI 代理不可用，流量无法通过。",
    ),
    "doctorByeDpiFailedTitle": MessageLookupByLibrary.simpleMessage(
      "ByeDPI 未启动",
    ),
    "doctorCancelExam": MessageLookupByLibrary.simpleMessage("取消检查"),
    "doctorCancelledDesc": MessageLookupByLibrary.simpleMessage(
      "诊断结果未改变，可重新检查。",
    ),
    "doctorCancelledTitle": MessageLookupByLibrary.simpleMessage("检查已取消"),
    "doctorCaptureActive": MessageLookupByLibrary.simpleMessage("已启用"),
    "doctorCaptureInactive": MessageLookupByLibrary.simpleMessage("未启用"),
    "doctorCaptureNotApplicable": MessageLookupByLibrary.simpleMessage("不适用"),
    "doctorConfidence": MessageLookupByLibrary.simpleMessage("可信度"),
    "doctorConfidenceConfirmed": MessageLookupByLibrary.simpleMessage("已确认"),
    "doctorConfidenceInsufficient": MessageLookupByLibrary.simpleMessage("不足"),
    "doctorConfidenceProbable": MessageLookupByLibrary.simpleMessage("可能"),
    "doctorDeepExam": MessageLookupByLibrary.simpleMessage("深度检查"),
    "doctorDegradedDesc": MessageLookupByLibrary.simpleMessage(
      "在网络路径上发现可能的问题。",
    ),
    "doctorDegradedTitle": MessageLookupByLibrary.simpleMessage("连接质量下降"),
    "doctorDetails": MessageLookupByLibrary.simpleMessage("诊断"),
    "doctorDnsFailedDesc": MessageLookupByLibrary.simpleMessage("应用无法解析测试地址。"),
    "doctorDnsFailedTitle": MessageLookupByLibrary.simpleMessage("DNS 无法工作"),
    "doctorDnsStaleDesc": MessageLookupByLibrary.simpleMessage(
      "缓存的地址已不再与当前网络匹配。",
    ),
    "doctorDnsStaleTitle": MessageLookupByLibrary.simpleMessage("DNS 数据已过期"),
    "doctorEndpointReachableDesc": MessageLookupByLibrary.simpleMessage(
      "Core 已访问测试地址，但尚未证实完整的受保护路径。",
    ),
    "doctorEndpointReachableTitle": MessageLookupByLibrary.simpleMessage(
      "测试地址可访问",
    ),
    "doctorEvidence": MessageLookupByLibrary.simpleMessage("证据"),
    "doctorEvidenceConsequence": MessageLookupByLibrary.simpleMessage(
      "更早故障导致的结果",
    ),
    "doctorEvidenceDropped": m26,
    "doctorExaminingDesc": MessageLookupByLibrary.simpleMessage(
      "诊断工具正使用有限探测跟踪网络路径。",
    ),
    "doctorExaminingTitle": MessageLookupByLibrary.simpleMessage("正在检查连接"),
    "doctorExportConfirm": MessageLookupByLibrary.simpleMessage(
      "报告包含诊断代码、时间区间、平台信息和近期脱敏证据，绝不包含地址、主机名、配置、节点或应用名称。保存为 JSON？",
    ),
    "doctorExportReport": MessageLookupByLibrary.simpleMessage("导出报告"),
    "doctorFlushDns": MessageLookupByLibrary.simpleMessage("清除 DNS 缓存"),
    "doctorFresh": MessageLookupByLibrary.simpleMessage("当前"),
    "doctorGenericDesc": MessageLookupByLibrary.simpleMessage(
      "检查发现了连接问题，但无法确定更具体的原因。",
    ),
    "doctorHealthyDesc": MessageLookupByLibrary.simpleMessage("观察到的网络路径已成功完成。"),
    "doctorHealthyEasterEgg": MessageLookupByLibrary.simpleMessage(
      "患者健康得有些可疑。",
    ),
    "doctorHealthyTitle": MessageLookupByLibrary.simpleMessage("连接正常"),
    "doctorHeroExamining": m27,
    "doctorHeroIssue": m28,
    "doctorInconclusiveDesc": MessageLookupByLibrary.simpleMessage(
      "检查无法在不猜测的情况下确认故障。",
    ),
    "doctorInconclusiveTitle": MessageLookupByLibrary.simpleMessage("证据不足"),
    "doctorIngressDesc": MessageLookupByLibrary.simpleMessage(
      "应用已发送流量，但流量未到达预期的 VPN 或本地代理入口。",
    ),
    "doctorIngressTitle": MessageLookupByLibrary.simpleMessage("流量未进入隧道"),
    "doctorIpUnavailable": MessageLookupByLibrary.simpleMessage("未测量公网 IP"),
    "doctorLayer": MessageLookupByLibrary.simpleMessage("故障层"),
    "doctorLayerCapture": MessageLookupByLibrary.simpleMessage("流量捕获"),
    "doctorLayerDial": MessageLookupByLibrary.simpleMessage("连接建立"),
    "doctorLayerDns": MessageLookupByLibrary.simpleMessage("DNS"),
    "doctorLayerIngress": MessageLookupByLibrary.simpleMessage("VPN 入口"),
    "doctorLayerMarker": MessageLookupByLibrary.simpleMessage("应用响应"),
    "doctorLayerRoute": MessageLookupByLibrary.simpleMessage("路由"),
    "doctorLayerTransport": MessageLookupByLibrary.simpleMessage("传输"),
    "doctorLimitations": MessageLookupByLibrary.simpleMessage("说明"),
    "doctorModeDeep": MessageLookupByLibrary.simpleMessage("深度"),
    "doctorModeStandard": MessageLookupByLibrary.simpleMessage("标准"),
    "doctorNoEvidence": MessageLookupByLibrary.simpleMessage("暂无可用证据"),
    "doctorNoIncidents": MessageLookupByLibrary.simpleMessage("暂无已完成的检查"),
    "doctorNoNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "设备未连接到 Wi-Fi 或移动数据网络。",
    ),
    "doctorNoNetworkTitle": MessageLookupByLibrary.simpleMessage("无互联网连接"),
    "doctorNoNodeDesc": MessageLookupByLibrary.simpleMessage(
      "没有活动的代理服务器来承载此连接。",
    ),
    "doctorNoNodeTitle": MessageLookupByLibrary.simpleMessage("未选择代理服务器"),
    "doctorNodeDownDesc": MessageLookupByLibrary.simpleMessage(
      "所选代理服务器未接受连接或未响应。",
    ),
    "doctorNodeDownTitle": MessageLookupByLibrary.simpleMessage("代理服务器不可用"),
    "doctorNodeRefusedDesc": MessageLookupByLibrary.simpleMessage(
      "代理已连接，但测试地址未返回预期响应。",
    ),
    "doctorNodeRefusedTitle": MessageLookupByLibrary.simpleMessage("测试地址拒绝了请求"),
    "doctorObservingDesc": MessageLookupByLibrary.simpleMessage(
      "未运行主动探测；使用应用时会收集证据。",
    ),
    "doctorObservingTitle": MessageLookupByLibrary.simpleMessage("正在观察实际流量"),
    "doctorOutcomeDropped": MessageLookupByLibrary.simpleMessage("已丢弃"),
    "doctorOutcomeFailed": MessageLookupByLibrary.simpleMessage("失败"),
    "doctorOutcomeNotApplicable": MessageLookupByLibrary.simpleMessage("不适用"),
    "doctorOutcomeSeen": MessageLookupByLibrary.simpleMessage("已观察"),
    "doctorOutcomeSucceeded": MessageLookupByLibrary.simpleMessage("成功"),
    "doctorPassiveHint": MessageLookupByLibrary.simpleMessage(
      "打开此页面时会运行一次检查。其余时间医生仅观察真实流量，不会产生额外的网络活动。",
    ),
    "doctorPathApp": MessageLookupByLibrary.simpleMessage("应用"),
    "doctorPathChecking": MessageLookupByLibrary.simpleMessage("正在检查"),
    "doctorPathConsequence": MessageLookupByLibrary.simpleMessage("因前序问题未检查"),
    "doctorPathFailed": MessageLookupByLibrary.simpleMessage("问题在此"),
    "doctorPathIngress": MessageLookupByLibrary.simpleMessage("VPN / 本地入口"),
    "doctorPathIngressByeDpi": MessageLookupByLibrary.simpleMessage("ByeDPI"),
    "doctorPathIngressDirect": MessageLookupByLibrary.simpleMessage("直连"),
    "doctorPathIngressLocalProxy": MessageLookupByLibrary.simpleMessage("本地代理"),
    "doctorPathIngressTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "doctorPathIngressVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "doctorPathInternet": MessageLookupByLibrary.simpleMessage("代理 / 互联网"),
    "doctorPathNotApplicable": MessageLookupByLibrary.simpleMessage("不需要"),
    "doctorPathPassed": MessageLookupByLibrary.simpleMessage("正常"),
    "doctorPathResponse": MessageLookupByLibrary.simpleMessage("响应"),
    "doctorPathRoute": MessageLookupByLibrary.simpleMessage("DNS / 路由"),
    "doctorPathTitle": MessageLookupByLibrary.simpleMessage("连接路径"),
    "doctorPathUnknown": MessageLookupByLibrary.simpleMessage("未检查"),
    "doctorPortalDesc": MessageLookupByLibrary.simpleMessage(
      "登录网络之前，网络会阻止互联网访问。",
    ),
    "doctorPortalTitle": MessageLookupByLibrary.simpleMessage("Wi-Fi 需要登录"),
    "doctorProgress": m29,
    "doctorProtection": MessageLookupByLibrary.simpleMessage("保护"),
    "doctorRecentChecks": MessageLookupByLibrary.simpleMessage("最近检查"),
    "doctorRefresh": MessageLookupByLibrary.simpleMessage("刷新诊断"),
    "doctorRemedyOpenDns": MessageLookupByLibrary.simpleMessage("DNS 设置"),
    "doctorRemedyStartVpn": MessageLookupByLibrary.simpleMessage("启动 VPN"),
    "doctorRouteDesc": MessageLookupByLibrary.simpleMessage(
      "当前配置无法为此连接选择可用路由。",
    ),
    "doctorRouteTitle": MessageLookupByLibrary.simpleMessage("流量路由错误"),
    "doctorScope": MessageLookupByLibrary.simpleMessage("证据范围"),
    "doctorScopeApp": MessageLookupByLibrary.simpleMessage("此应用"),
    "doctorScopeInbound": MessageLookupByLibrary.simpleMessage("本地入口"),
    "doctorSlowDesc": MessageLookupByLibrary.simpleMessage("测试未能在时限内完成。"),
    "doctorSlowTitle": MessageLookupByLibrary.simpleMessage("连接速度太慢"),
    "doctorStale": MessageLookupByLibrary.simpleMessage("已过期"),
    "doctorStaleHint": MessageLookupByLibrary.simpleMessage(
      "环境可能已变化，请刷新或重新检查后再操作。",
    ),
    "doctorStaleTitle": MessageLookupByLibrary.simpleMessage("结果已过期"),
    "doctorStandardExam": MessageLookupByLibrary.simpleMessage("运行检查"),
    "doctorStepChangeDns": MessageLookupByLibrary.simpleMessage(
      "在配置设置中尝试其他 DNS 服务器。",
    ),
    "doctorStepCheckRules": MessageLookupByLibrary.simpleMessage(
      "检查配置规则和路由模式。",
    ),
    "doctorStepCheckWifi": MessageLookupByLibrary.simpleMessage(
      "连接 Wi-Fi 或移动数据网络，然后重新检查。",
    ),
    "doctorStepDeepCheck": MessageLookupByLibrary.simpleMessage(
      "运行深度检查以比较 DNS 路径。",
    ),
    "doctorStepFlushDns": MessageLookupByLibrary.simpleMessage(
      "清除 DNS 缓存，然后重新检查。",
    ),
    "doctorStepPickNode": MessageLookupByLibrary.simpleMessage("选择其他代理服务器。"),
    "doctorStepRecheckLater": MessageLookupByLibrary.simpleMessage(
      "稍后或在其他网络上重新检查。",
    ),
    "doctorStepRestartByeDpi": MessageLookupByLibrary.simpleMessage(
      "在高级设置中重新启动 ByeDPI。",
    ),
    "doctorStepRestartTunnel": MessageLookupByLibrary.simpleMessage(
      "重新启动连接，然后重新检查。",
    ),
    "doctorStepSignInPortal": MessageLookupByLibrary.simpleMessage(
      "打开网络登录页面，然后重新检查。",
    ),
    "doctorStepStartVpn": MessageLookupByLibrary.simpleMessage(
      "启动 VPN，然后重新检查。",
    ),
    "doctorStepSwitchNetwork": MessageLookupByLibrary.simpleMessage(
      "切换到其他网络或恢复互联网访问。",
    ),
    "doctorStepUpdateSubscription": MessageLookupByLibrary.simpleMessage(
      "如果其他服务器也失败，请更新订阅。",
    ),
    "doctorStepUseAppThenRecheck": MessageLookupByLibrary.simpleMessage(
      "使用出现问题的应用，然后返回并重新检查。",
    ),
    "doctorSupersededDesc": MessageLookupByLibrary.simpleMessage(
      "网络或配置变化导致检查停止。",
    ),
    "doctorSupersededTitle": MessageLookupByLibrary.simpleMessage("网络环境已变化"),
    "doctorTechnicalDetails": MessageLookupByLibrary.simpleMessage("技术详情"),
    "doctorUnsupportedDesc": MessageLookupByLibrary.simpleMessage(
      "此 Core 版本不支持连接诊断。",
    ),
    "doctorUnsupportedHint": MessageLookupByLibrary.simpleMessage(
      "请更新 Core 以使用连接诊断。",
    ),
    "doctorUnsupportedTitle": MessageLookupByLibrary.simpleMessage("诊断不可用"),
    "doctorUnvalidatedDesc": MessageLookupByLibrary.simpleMessage(
      "设备已连接到网络，但 Android 无法通过该网络访问互联网。",
    ),
    "doctorUnvalidatedTitle": MessageLookupByLibrary.simpleMessage("网络无法访问互联网"),
    "doctorVpnInactiveDesc": MessageLookupByLibrary.simpleMessage(
      "应用需要 VPN 保护，但 TUN 路径未启用。",
    ),
    "doctorVpnInactiveTitle": MessageLookupByLibrary.simpleMessage("VPN 未启用"),
    "doctorWhatToTry": MessageLookupByLibrary.simpleMessage("可以尝试"),
    "domain": MessageLookupByLibrary.simpleMessage("域名"),
    "download": MessageLookupByLibrary.simpleMessage("下载"),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage("正在下载更新"),
    "edit": MessageLookupByLibrary.simpleMessage("编辑"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage("编辑全局规则"),
    "editNetwork": MessageLookupByLibrary.simpleMessage("编辑网络"),
    "editProxy": MessageLookupByLibrary.simpleMessage("编辑代理"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("编辑策略组"),
    "editRule": MessageLookupByLibrary.simpleMessage("编辑规则"),
    "emptyTip": m30,
    "en": MessageLookupByLibrary.simpleMessage("英语"),
    "enterManually": MessageLookupByLibrary.simpleMessage("手动输入"),
    "entries": MessageLookupByLibrary.simpleMessage("个条目"),
    "entriesCount": m31,
    "exclude": MessageLookupByLibrary.simpleMessage("从最近任务中隐藏"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage("应用在后台时,从最近任务中隐藏应用"),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage("排除节点过滤器"),
    "excludeType": MessageLookupByLibrary.simpleMessage("排除类型"),
    "existsTip": m32,
    "exit": MessageLookupByLibrary.simpleMessage("退出"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("退出全屏"),
    "expand": MessageLookupByLibrary.simpleMessage("标准"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("预期状态"),
    "expireTime": MessageLookupByLibrary.simpleMessage("到期时间"),
    "exportFile": MessageLookupByLibrary.simpleMessage("导出文件"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("导出日志"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("导出成功"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("表现力"),
    "externalActionConfirmMessage": m33,
    "externalActionConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "确认外部操作",
    ),
    "externalController": MessageLookupByLibrary.simpleMessage("外部控制器"),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "开启后将可以通过9090端口控制Clash内核",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("外部获取"),
    "externalLink": MessageLookupByLibrary.simpleMessage("外部链接"),
    "extra": MessageLookupByLibrary.simpleMessage("附加"),
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
    "findingAuscultation": MessageLookupByLibrary.simpleMessage("听诊"),
    "findingCrown": MessageLookupByLibrary.simpleMessage("冠冕"),
    "findingDiscoveredOn": m34,
    "findingFullLadder": MessageLookupByLibrary.simpleMessage("完整阶梯"),
    "findingLoopback": MessageLookupByLibrary.simpleMessage("回环"),
    "findingLoopbackDesc": MessageLookupByLibrary.simpleMessage(
      "配置文件指回了本地监听端口。",
    ),
    "findingLoopbackWarning": MessageLookupByLibrary.simpleMessage(
      "此配置地址指向 ReClash 自身的代理端口。请检查订阅链接。",
    ),
    "findingMarks": MessageLookupByLibrary.simpleMessage("标记"),
    "findingMarksDesc": MessageLookupByLibrary.simpleMessage(
      "发现了 ReClash 标记集。",
    ),
    "findingMeridian": MessageLookupByLibrary.simpleMessage("五条经线"),
    "findingOdometer": MessageLookupByLibrary.simpleMessage("里程计"),
    "findingOscilloscope": MessageLookupByLibrary.simpleMessage("示波器"),
    "findingOscilloscopeDesc": MessageLookupByLibrary.simpleMessage(
      "圆环聆听了六秒实时流量。",
    ),
    "findingPi": MessageLookupByLibrary.simpleMessage("圆周率"),
    "findingPiDesc": MessageLookupByLibrary.simpleMessage(
      "仪表板打开时，会话越过了 3:14:15。",
    ),
    "findingPorcelain": MessageLookupByLibrary.simpleMessage("瓷白"),
    "findingSilentAutopilot": MessageLookupByLibrary.simpleMessage("静默自动驾驶"),
    "findingStorm": MessageLookupByLibrary.simpleMessage("风暴"),
    "findingStormDesc": MessageLookupByLibrary.simpleMessage("所有诊断层同时失效。"),
    "findingStormTitle": MessageLookupByLibrary.simpleMessage("连接的所有阶段均不可用"),
    "findingStormVerdict": MessageLookupByLibrary.simpleMessage(
      "检查未找到可用路径。后续阶段的失败可能由最初的故障引起。",
    ),
    "findingTurn": MessageLookupByLibrary.simpleMessage("跨年"),
    "findingTurnDesc": MessageLookupByLibrary.simpleMessage("会话跨过了新年午夜。"),
    "findingVigil": MessageLookupByLibrary.simpleMessage("守望"),
    "findings": MessageLookupByLibrary.simpleMessage("发现"),
    "findingsCount": m35,
    "findingsDesc": MessageLookupByLibrary.simpleMessage("使用 ReClash 时悄然发现的细节"),
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
    "geoSkipped": m36,
    "geoUpdated": m37,
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
    "helperAgentUnavailable": MessageLookupByLibrary.simpleMessage(
      "系统授权代理不可用。请在桌面会话中启动 polkit 身份验证代理，然后重试。",
    ),
    "helperAuthorizationContinue": MessageLookupByLibrary.simpleMessage("继续"),
    "helperAuthorizationLater": MessageLookupByLibrary.simpleMessage("稍后"),
    "helperAuthorizationMessage": MessageLookupByLibrary.simpleMessage(
      "TUN 模式需要安装或更新 ReClash Helper 服务。点击「继续」以打开系统授权对话框。请仅在系统对话框中输入密码，ReClash 不会收集密码。",
    ),
    "helperAuthorizationTitle": MessageLookupByLibrary.simpleMessage(
      "允许设置 Helper？",
    ),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper 服务不可用，无法启用 TUN 模式，请重新安装 ReClash。",
    ),
    "helperInstallFailed": MessageLookupByLibrary.simpleMessage(
      "无法安装或更新 Helper 服务。请检查日志后重试。",
    ),
    "helperInstallNotReady": MessageLookupByLibrary.simpleMessage(
      "Helper 设置已完成，但服务尚未就绪。请检查日志后重试。",
    ),
    "helperPkexecUnavailable": MessageLookupByLibrary.simpleMessage(
      "pkexec 不可用。请安装适用于当前发行版的 polkit 软件包，然后重试。",
    ),
    "helperSystemdUnavailable": MessageLookupByLibrary.simpleMessage(
      "TUN 模式需要 systemd，但当前系统无法使用 systemd。",
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
    "heroRoutingAgo": m38,
    "heroRoutingStub": MessageLookupByLibrary.simpleMessage("智能路由已关闭"),
    "heroStatusEasterEgg": MessageLookupByLibrary.simpleMessage("今天的数据包格外听话。"),
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
    "hoursAgo": m39,
    "hoursCount": m40,
    "hoursGenitive": MessageLookupByLibrary.simpleMessage("小时"),
    "hoursPlural": MessageLookupByLibrary.simpleMessage("小时"),
    "icon": MessageLookupByLibrary.simpleMessage("图片"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("图标记录"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("图标样式"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("图标链接"),
    "identity": MessageLookupByLibrary.simpleMessage("身份标识"),
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
    "invalidPolicy": m41,
    "invalidProxy": m42,
    "invalidProxyProvider": m43,
    "invalidSubRule": m44,
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/掩码"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage("开启后将可以接收IPv6流量"),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage("允许IPv6入站"),
    "ja": MessageLookupByLibrary.simpleMessage("日语"),
    "justNow": MessageLookupByLibrary.simpleMessage("刚刚"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage("TCP保持活动间隔"),
    "key": MessageLookupByLibrary.simpleMessage("键"),
    "kk": MessageLookupByLibrary.simpleMessage("哈萨克语"),
    "ko": MessageLookupByLibrary.simpleMessage("韩语"),
    "lanProfileImport": MessageLookupByLibrary.simpleMessage("从手机接收"),
    "lanProfileImportAddress": m45,
    "lanProfileImportDesc": MessageLookupByLibrary.simpleMessage(
      "显示一次性网页，通过局域网从手机发送订阅",
    ),
    "lanProfileImportFailed": MessageLookupByLibrary.simpleMessage("无法导入订阅"),
    "lanProfileImportImported": MessageLookupByLibrary.simpleMessage("已接收订阅"),
    "lanProfileImportImporting": MessageLookupByLibrary.simpleMessage(
      "正在导入订阅…",
    ),
    "lanProfileImportPhoneFailed": MessageLookupByLibrary.simpleMessage(
      "无法导入订阅。请检查链接后重试。",
    ),
    "lanProfileImportPhoneHint": MessageLookupByLibrary.simpleMessage(
      "粘贴订阅链接，将其导入电视。",
    ),
    "lanProfileImportPhoneSuccess": MessageLookupByLibrary.simpleMessage(
      "订阅已导入。您可以返回电视并关闭此页面。",
    ),
    "lanProfileImportPhoneUnreachable": MessageLookupByLibrary.simpleMessage(
      "无法连接电视。请检查网络连接，并在此页面重试以确认结果。",
    ),
    "lanProfileImportScan": MessageLookupByLibrary.simpleMessage(
      "请使用同一网络中的手机扫描此二维码，然后粘贴订阅网址",
    ),
    "lanProfileImportSend": MessageLookupByLibrary.simpleMessage("导入电视"),
    "lanProfileImportStartFailed": MessageLookupByLibrary.simpleMessage(
      "无法启动局域网共享",
    ),
    "lanProfileImportTimedOut": MessageLookupByLibrary.simpleMessage(
      "一次性链接已过期",
    ),
    "lanProfileImportTitle": MessageLookupByLibrary.simpleMessage("接收订阅"),
    "lanProfileImportWaiting": MessageLookupByLibrary.simpleMessage("正在等待订阅…"),
    "language": MessageLookupByLibrary.simpleMessage("语言"),
    "lastUsed": MessageLookupByLibrary.simpleMessage("上次使用"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage("启动未完成"),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "应用上次在启动过程中意外退出。已跳过本次自动配置，你可以手动启动重试。",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("布局"),
    "license": MessageLookupByLibrary.simpleMessage("许可证"),
    "licenses": MessageLookupByLibrary.simpleMessage("开源许可"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage("应用内置的软件包"),
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
    "locationPermissionGuide": m46,
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
    "maxLengthTip": m47,
    "maximize": MessageLookupByLibrary.simpleMessage("最大化"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("内存信息"),
    "messageTest": MessageLookupByLibrary.simpleMessage("消息测试"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("这是一条消息。"),
    "metaInfo": MessageLookupByLibrary.simpleMessage("订阅"),
    "milestoneDecorations": MessageLookupByLibrary.simpleMessage("隐藏发现"),
    "milestoneDecorationsDesc": MessageLookupByLibrary.simpleMessage(
      "显示使用 ReClash 时获得的发现",
    ),
    "milestoneRevealAuscultation": MessageLookupByLibrary.simpleMessage(
      "一百次检查。网络脉搏依然清晰。",
    ),
    "milestoneRevealCrown": MessageLookupByLibrary.simpleMessage("整整一年的覆盖时间。"),
    "milestoneRevealFullLadder": MessageLookupByLibrary.simpleMessage(
      "走过每一级，又回到第一级。",
    ),
    "milestoneRevealMeridian": MessageLookupByLibrary.simpleMessage("跨越了五条经线。"),
    "milestoneRevealOdometer": MessageLookupByLibrary.simpleMessage(
      "已有一太字节流量经过。",
    ),
    "milestoneRevealPorcelain": MessageLookupByLibrary.simpleMessage("安静的七天。"),
    "milestoneRevealSilentAutopilot": MessageLookupByLibrary.simpleMessage(
      "一千次决策，无需干预。",
    ),
    "milestoneRevealVigil": MessageLookupByLibrary.simpleMessage("九十天，从未中断。"),
    "min": MessageLookupByLibrary.simpleMessage("最小"),
    "minimize": MessageLookupByLibrary.simpleMessage("最小化"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("退出时最小化"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage("修改系统默认退出事件"),
    "minute": MessageLookupByLibrary.simpleMessage("分钟"),
    "minutesAgo": m48,
    "minutesGenitive": MessageLookupByLibrary.simpleMessage("分钟"),
    "minutesPlural": MessageLookupByLibrary.simpleMessage("分钟"),
    "mixedPort": MessageLookupByLibrary.simpleMessage("混合端口"),
    "mode": MessageLookupByLibrary.simpleMessage("模式"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("单色"),
    "monthsAgo": m49,
    "more": MessageLookupByLibrary.simpleMessage("更多"),
    "moveDown": MessageLookupByLibrary.simpleMessage("下移"),
    "moveToBottom": MessageLookupByLibrary.simpleMessage("移到底部"),
    "moveToTop": MessageLookupByLibrary.simpleMessage("移到顶部"),
    "moveUp": MessageLookupByLibrary.simpleMessage("上移"),
    "multipleValuesTip": MessageLookupByLibrary.simpleMessage("多个值使用逗号分隔"),
    "name": MessageLookupByLibrary.simpleMessage("名称"),
    "nameserver": MessageLookupByLibrary.simpleMessage("域名服务器"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage("用于解析域名"),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage("域名服务器策略"),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage("指定对应域名服务器策略"),
    "network": MessageLookupByLibrary.simpleMessage("网络"),
    "networkDefaultLanBypass": MessageLookupByLibrary.simpleMessage(
      "未设置自定义路由时，局域网绕过 VPN。若要让其经过 VPN，请显式设置路由。",
    ),
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
    "neverUsed": MessageLookupByLibrary.simpleMessage("尚未使用"),
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
    "notification": MessageLookupByLibrary.simpleMessage("通知"),
    "notificationAddComponent": MessageLookupByLibrary.simpleMessage("添加组件"),
    "notificationAndroidOnly": MessageLookupByLibrary.simpleMessage(
      "仅适用于 Android",
    ),
    "notificationAndroidOnlyDesc": MessageLookupByLibrary.simpleMessage(
      "前台通知设置仅适用于 Android VPN 服务。",
    ),
    "notificationAutomaticGroup": MessageLookupByLibrary.simpleMessage("自动策略组"),
    "notificationBlockedNoServerGroup": MessageLookupByLibrary.simpleMessage(
      "未解析到服务器策略组，该行不会显示",
    ),
    "notificationBlockedSmartRoutingOff": MessageLookupByLibrary.simpleMessage(
      "智能路由已关闭，该行不会显示",
    ),
    "notificationCollapsedLine": MessageLookupByLibrary.simpleMessage(
      "折叠通知时显示",
    ),
    "notificationComponentBehaviour": MessageLookupByLibrary.simpleMessage(
      "行为",
    ),
    "notificationComponents": MessageLookupByLibrary.simpleMessage("通知组件"),
    "notificationComponentsActive": MessageLookupByLibrary.simpleMessage(
      "通知中显示",
    ),
    "notificationComponentsDesc": MessageLookupByLibrary.simpleMessage(
      "使用实时状态组件构建通知。",
    ),
    "notificationComponentsEmpty": MessageLookupByLibrary.simpleMessage(
      "尚未添加组件",
    ),
    "notificationComponentsEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "没有组件时，通知仅显示保护状态。",
    ),
    "notificationComponentsOrderHint": MessageLookupByLibrary.simpleMessage(
      "各行按此顺序排列。折叠通知时显示第一条有数据的行。",
    ),
    "notificationConnectionDoctor": MessageLookupByLibrary.simpleMessage(
      "连接诊断",
    ),
    "notificationConnectionDoctorDesc": MessageLookupByLibrary.simpleMessage(
      "显示连接诊断的结论",
    ),
    "notificationContent": MessageLookupByLibrary.simpleMessage("内容"),
    "notificationControls": MessageLookupByLibrary.simpleMessage("控制"),
    "notificationControlsDesc": MessageLookupByLibrary.simpleMessage(
      "选择可直接从通知执行的操作。",
    ),
    "notificationCurrentServer": MessageLookupByLibrary.simpleMessage("当前服务器"),
    "notificationCurrentServerDesc": MessageLookupByLibrary.simpleMessage(
      "显示该策略组中选中的节点",
    ),
    "notificationDelivery": MessageLookupByLibrary.simpleMessage(
      "Android 通知投递",
    ),
    "notificationDeliveryChecking": MessageLookupByLibrary.simpleMessage(
      "正在检查 Android 通知权限",
    ),
    "notificationDeliveryFix": MessageLookupByLibrary.simpleMessage("修复"),
    "notificationDeliveryOff": MessageLookupByLibrary.simpleMessage(
      "服务通知已在 ReClash 中关闭",
    ),
    "notificationDeliveryPermissionDisabled":
        MessageLookupByLibrary.simpleMessage("ReClash 的通知已被阻止"),
    "notificationDeliveryReady": MessageLookupByLibrary.simpleMessage("可以投递通知"),
    "notificationDeliveryServiceDisabled": MessageLookupByLibrary.simpleMessage(
      "ReClash 服务渠道已被停用",
    ),
    "notificationDeliverySubscriptionDisabled":
        MessageLookupByLibrary.simpleMessage("订阅提醒渠道已被停用"),
    "notificationDetailedDesc": MessageLookupByLibrary.simpleMessage(
      "显示实时状态行、快捷操作和状态栏图标",
    ),
    "notificationDoctorPriority": MessageLookupByLibrary.simpleMessage(
      "连接诊断优先级",
    ),
    "notificationDoctorPriorityAlways": MessageLookupByLibrary.simpleMessage(
      "始终",
    ),
    "notificationDoctorPriorityProblems": MessageLookupByLibrary.simpleMessage(
      "仅有问题时",
    ),
    "notificationHideIdleSpeed": MessageLookupByLibrary.simpleMessage(
      "空闲时隐藏速度",
    ),
    "notificationHideIdleSpeedDesc": MessageLookupByLibrary.simpleMessage(
      "没有流量时隐藏速度数值",
    ),
    "notificationHideSensitive": MessageLookupByLibrary.simpleMessage(
      "在锁屏上隐藏敏感信息",
    ),
    "notificationHideSensitiveDesc": MessageLookupByLibrary.simpleMessage(
      "设备锁定时隐藏配置、路由和诊断详情",
    ),
    "notificationMinimalDesc": MessageLookupByLibrary.simpleMessage(
      "仅在通知栏底部保留一行安静通知，不显示状态栏图标",
    ),
    "notificationMoveDown": MessageLookupByLibrary.simpleMessage("下移"),
    "notificationMoveUp": MessageLookupByLibrary.simpleMessage("上移"),
    "notificationNetworkNormal": MessageLookupByLibrary.simpleMessage("正常"),
    "notificationNetworkOffline": MessageLookupByLibrary.simpleMessage("离线"),
    "notificationNetworkPortal": MessageLookupByLibrary.simpleMessage("认证门户"),
    "notificationNetworkSpeed": MessageLookupByLibrary.simpleMessage("网络速度"),
    "notificationNetworkSpeedDesc": MessageLookupByLibrary.simpleMessage(
      "显示当前上传和下载速度",
    ),
    "notificationNetworkState": MessageLookupByLibrary.simpleMessage("网络状态"),
    "notificationNetworkStateDesc": MessageLookupByLibrary.simpleMessage(
      "显示当前 RCX 网络态势",
    ),
    "notificationNetworkUnknown": MessageLookupByLibrary.simpleMessage("未知"),
    "notificationNetworkWhitelist": MessageLookupByLibrary.simpleMessage("白名单"),
    "notificationOffDesc": MessageLookupByLibrary.simpleMessage(
      "通知栏中什么都不显示。保护继续运行，提醒照常送达",
    ),
    "notificationPauseAction": MessageLookupByLibrary.simpleMessage("暂停或继续"),
    "notificationPauseActionDesc": MessageLookupByLibrary.simpleMessage(
      "显示暂停或继续 VPN 的操作",
    ),
    "notificationPreviewDoctor": MessageLookupByLibrary.simpleMessage(
      "连接诊断：未发现问题",
    ),
    "notificationPreviewHidden": MessageLookupByLibrary.simpleMessage(
      "通知栏中不会出现任何内容",
    ),
    "notificationPreviewLocked": MessageLookupByLibrary.simpleMessage(
      "ReClash · 已隐藏受保护详情",
    ),
    "notificationPreviewNetwork": MessageLookupByLibrary.simpleMessage(
      "网络 · 正常",
    ),
    "notificationPreviewPaused": MessageLookupByLibrary.simpleMessage(
      "ReClash · 保护已暂停",
    ),
    "notificationPreviewProblem": MessageLookupByLibrary.simpleMessage(
      "连接诊断：检测到问题",
    ),
    "notificationPreviewProfile": MessageLookupByLibrary.simpleMessage(
      "ReClash · 当前配置",
    ),
    "notificationPreviewRoute": MessageLookupByLibrary.simpleMessage(
      "智能路由 · 自动路由",
    ),
    "notificationPreviewScenario": MessageLookupByLibrary.simpleMessage("预览场景"),
    "notificationPreviewServer": MessageLookupByLibrary.simpleMessage(
      "服务器 · 东京 01",
    ),
    "notificationPreviewSession": MessageLookupByLibrary.simpleMessage(
      "会话 · ↓ 1.2 GB  ↑ 184 MB",
    ),
    "notificationPreviewSpeed": MessageLookupByLibrary.simpleMessage(
      "↓ 12.4 MB/s  ↑ 1.8 MB/s",
    ),
    "notificationPrivacy": MessageLookupByLibrary.simpleMessage("隐私"),
    "notificationProtectionDesc": MessageLookupByLibrary.simpleMessage(
      "常驻通知会显示保护是否处于活动状态。",
    ),
    "notificationProtectionTitle": MessageLookupByLibrary.simpleMessage("保护状态"),
    "notificationReminders": MessageLookupByLibrary.simpleMessage("提醒"),
    "notificationRemindersDesc": MessageLookupByLibrary.simpleMessage(
      "提醒使用独立渠道，在任何通知级别下都会送达。",
    ),
    "notificationRemoveComponent": MessageLookupByLibrary.simpleMessage(
      "从通知中移除",
    ),
    "notificationReorder": MessageLookupByLibrary.simpleMessage("重新排序"),
    "notificationScenarioLockScreen": MessageLookupByLibrary.simpleMessage(
      "锁屏",
    ),
    "notificationScenarioNormal": MessageLookupByLibrary.simpleMessage("正常"),
    "notificationScenarioPaused": MessageLookupByLibrary.simpleMessage("已暂停"),
    "notificationScenarioProblem": MessageLookupByLibrary.simpleMessage("出现问题"),
    "notificationScenarioRouting": MessageLookupByLibrary.simpleMessage("路由中"),
    "notificationSelectServerGroup": MessageLookupByLibrary.simpleMessage(
      "选择服务器策略组",
    ),
    "notificationServerGroupMissing": MessageLookupByLibrary.simpleMessage(
      "所选策略组不在当前配置中",
    ),
    "notificationServiceChannel": MessageLookupByLibrary.simpleMessage("服务渠道"),
    "notificationSessionTraffic": MessageLookupByLibrary.simpleMessage(
      "本次会话流量",
    ),
    "notificationSessionTrafficDesc": MessageLookupByLibrary.simpleMessage(
      "显示本次会话的上传和下载流量",
    ),
    "notificationSmartRouting": MessageLookupByLibrary.simpleMessage("智能路由"),
    "notificationSmartRoutingDesc": MessageLookupByLibrary.simpleMessage(
      "显示当前的智能路由决策",
    ),
    "notificationSubscriptionChannel": MessageLookupByLibrary.simpleMessage(
      "订阅提醒渠道",
    ),
    "notificationSubscriptionReminders": MessageLookupByLibrary.simpleMessage(
      "订阅提醒",
    ),
    "notificationSubscriptionRemindersDesc":
        MessageLookupByLibrary.simpleMessage("订阅需要处理时发送通知"),
    "notificationVisibility": MessageLookupByLibrary.simpleMessage("通知级别"),
    "notificationVisibilityAlways": MessageLookupByLibrary.simpleMessage(
      "始终显示",
    ),
    "notificationVisibilityCurrentServer": MessageLookupByLibrary.simpleMessage(
      "解析到服务器策略组时显示",
    ),
    "notificationVisibilityDetailed": MessageLookupByLibrary.simpleMessage(
      "详细",
    ),
    "notificationVisibilityDoctorProblems":
        MessageLookupByLibrary.simpleMessage("检测到问题时显示"),
    "notificationVisibilityMinimal": MessageLookupByLibrary.simpleMessage("精简"),
    "notificationVisibilityOff": MessageLookupByLibrary.simpleMessage("关闭"),
    "notificationVisibilitySessionTraffic":
        MessageLookupByLibrary.simpleMessage("本次会话有流量时显示"),
    "notificationVisibilitySmartRoutingOn":
        MessageLookupByLibrary.simpleMessage("智能路由开启时显示"),
    "notificationVisibilitySpeedIdle": MessageLookupByLibrary.simpleMessage(
      "没有流量时隐藏",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage("没有配置文件,请先添加配置文件"),
    "nullTip": m50,
    "numberTip": m51,
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
    "panelHwidIdentityDisabled": MessageLookupByLibrary.simpleMessage(
      "HWID 发送已关闭。仅在信任面板时启用。",
    ),
    "panelHwidNotSupported": MessageLookupByLibrary.simpleMessage(
      "面板报告了 HWID 限制",
    ),
    "panelHwidNotSupportedTip": MessageLookupByLibrary.simpleMessage(
      "面板返回了 x-hwid-not-supported。这并不能证明客户端不兼容。请检查 HWID 设置和订阅要求。",
    ),
    "panelSettingsConfirmMessage": m52,
    "panelSettingsConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "应用服务商设置",
    ),
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
    "porcelainThemeDesc": MessageLookupByLibrary.simpleMessage("应用冷色、近乎单色的配色"),
    "port": MessageLookupByLibrary.simpleMessage("端口"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage("请输入不同的端口"),
    "portTip": m53,
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
    "profileImportEmptyResponse": MessageLookupByLibrary.simpleMessage(
      "服务器返回了空配置",
    ),
    "profileImportFailed": MessageLookupByLibrary.simpleMessage("无法导入配置"),
    "profileImportFileReadFailed": MessageLookupByLibrary.simpleMessage(
      "无法读取所选文件",
    ),
    "profileImportFormatClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "profileImportFormatLinks": MessageLookupByLibrary.simpleMessage("分享链接"),
    "profileImportFormatSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box",
    ),
    "profileImportFormatWireguard": MessageLookupByLibrary.simpleMessage(
      "WireGuard",
    ),
    "profileImportFormatXray": MessageLookupByLibrary.simpleMessage("Xray"),
    "profileImportInvalidConfig": MessageLookupByLibrary.simpleMessage(
      "配置文件内容无效",
    ),
    "profileImportSkippedNodes": m54,
    "profileImportSuccess": MessageLookupByLibrary.simpleMessage("配置已导入"),
    "profileImportSuccessSummary": m55,
    "profileImportUnsupportedLink": MessageLookupByLibrary.simpleMessage(
      "导入链接已损坏或不受支持",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入配置名称",
    ),
    "profileUnusedForDays": m56,
    "profileUnusedForMonths": m57,
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
    "proxiesCount": m58,
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
    "resetFindings": MessageLookupByLibrary.simpleMessage("重置发现"),
    "resetFindingsConfirm": MessageLookupByLibrary.simpleMessage(
      "已发现的条目将隐藏，并可再次出现。使用记录不会改变。",
    ),
    "resetFindingsDesc": MessageLookupByLibrary.simpleMessage(
      "再次显示发现时刻，但不重置使用记录",
    ),
    "resetFindingsTitle": MessageLookupByLibrary.simpleMessage("重置发现？"),
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
    "restorePreviewDescription": MessageLookupByLibrary.simpleMessage(
      "确认前不会更改任何内容。",
    ),
    "restorePreviewTitle": MessageLookupByLibrary.simpleMessage("检查恢复内容"),
    "restoreProfilesCount": m59,
    "restoreProxyGroupsCount": m60,
    "restoreRulesCount": m61,
    "restoreScriptsCount": m62,
    "restoreSettingsIncluded": MessageLookupByLibrary.simpleMessage("包含设置"),
    "restoreSettingsNotIncluded": MessageLookupByLibrary.simpleMessage(
      "此备份不包含设置",
    ),
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
      "使用域名正则表达式匹配",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "匹配域名后缀",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "通配符匹配，仅支持*和?通配符",
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
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "使用进程名称通配符匹配，仅支持*和?通配符",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "使用完整进程路径匹配",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "使用进程路径正则表达式匹配",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "使用进程路径通配符匹配，仅支持*和?通配符",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "匹配重匹配名称，多个名称用/分隔",
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
    "rulesCount": m63,
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("是否保存更改？"),
    "schedule": MessageLookupByLibrary.simpleMessage("按时间"),
    "scheduleDesc": m64,
    "script": MessageLookupByLibrary.simpleMessage("脚本"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "脚本模式，使用外部扩展脚本，提供一键覆写配置的能力",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage("滚动到已选"),
    "search": MessageLookupByLibrary.simpleMessage("搜索"),
    "searchApps": MessageLookupByLibrary.simpleMessage("搜索应用"),
    "seasonBirthdayNote": MessageLookupByLibrary.simpleMessage(
      "今天是 ReClash 的生日。",
    ),
    "seasonFirstRunNote": MessageLookupByLibrary.simpleMessage(
      "今天是您首次启动的周年纪念日。",
    ),
    "seasonalDecorations": MessageLookupByLibrary.simpleMessage("季节外观"),
    "seasonalDecorationsDesc": MessageLookupByLibrary.simpleMessage(
      "在主界面显示轻微的季节装饰",
    ),
    "seconds": MessageLookupByLibrary.simpleMessage("秒"),
    "secondsCount": m65,
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
    "selectedCountTitle": m66,
    "sendDeviceIdentity": MessageLookupByLibrary.simpleMessage("发送 HWID"),
    "sendDeviceIdentityDesc": MessageLookupByLibrary.simpleMessage(
      "将设备标识符、应用版本和设备名称发送到订阅服务器",
    ),
    "sendDeviceIdentityDisableWarning": MessageLookupByLibrary.simpleMessage(
      "关闭 HWID 后，大多数订阅将无法使用。要继续吗？",
    ),
    "serviceInfo": MessageLookupByLibrary.simpleMessage("服务"),
    "settings": MessageLookupByLibrary.simpleMessage("设置"),
    "setupAddAnotherProfile": MessageLookupByLibrary.simpleMessage("继续添加"),
    "setupAutoRun": MessageLookupByLibrary.simpleMessage("打开 ReClash 时连接"),
    "setupAutoRunDesc": MessageLookupByLibrary.simpleMessage("载入有效配置后自动启动 VPN"),
    "setupAutoRunUnavailable": MessageLookupByLibrary.simpleMessage(
      "添加配置后才能启用自动连接",
    ),
    "setupBack": MessageLookupByLibrary.simpleMessage("返回"),
    "setupContinueWithoutProfile": MessageLookupByLibrary.simpleMessage(
      "不添加配置，继续",
    ),
    "setupContinueWithoutProfileDesc": MessageLookupByLibrary.simpleMessage(
      "VPN 将保持关闭。你可以稍后添加配置，也可以在没有 VPN 服务商的情况下使用“仅 ByeDPI”模式。",
    ),
    "setupDataCollection": MessageLookupByLibrary.simpleMessage("发送可选的崩溃报告"),
    "setupDataCollectionDesc": MessageLookupByLibrary.simpleMessage(
      "用于排查应用崩溃。除非你主动开启，否则不会发送。",
    ),
    "setupDecline": MessageLookupByLibrary.simpleMessage("不同意并退出"),
    "setupDeleteProfile": MessageLookupByLibrary.simpleMessage("删除"),
    "setupDone": MessageLookupByLibrary.simpleMessage("完成"),
    "setupDoneConnect": MessageLookupByLibrary.simpleMessage("完成并连接"),
    "setupFinishTitle": MessageLookupByLibrary.simpleMessage("检查设置"),
    "setupLanguageDesc": MessageLookupByLibrary.simpleMessage("之后可在设置中更改"),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage("选择语言"),
    "setupLegalDetails": MessageLookupByLibrary.simpleMessage("阅读完整免责声明"),
    "setupLegalLicense": MessageLookupByLibrary.simpleMessage("开源许可证"),
    "setupLegalSummary": MessageLookupByLibrary.simpleMessage(
      "ReClash 会在本机创建 VPN 连接来路由流量。配置或服务提供商由你选择，你也需要对其使用负责。",
    ),
    "setupLegalTitle": MessageLookupByLibrary.simpleMessage("继续之前"),
    "setupNext": MessageLookupByLibrary.simpleMessage("下一步"),
    "setupPermissionBattery": MessageLookupByLibrary.simpleMessage("电池优化"),
    "setupPermissionBatteryDesc": MessageLookupByLibrary.simpleMessage(
      "允许 ReClash 在后台保持 VPN 连接",
    ),
    "setupPermissionChecking": MessageLookupByLibrary.simpleMessage("正在检查…"),
    "setupPermissionDeferred": MessageLookupByLibrary.simpleMessage("首次连接时询问"),
    "setupPermissionDenied": MessageLookupByLibrary.simpleMessage("未允许"),
    "setupPermissionError": MessageLookupByLibrary.simpleMessage("无法检查"),
    "setupPermissionGranted": MessageLookupByLibrary.simpleMessage("已允许"),
    "setupPermissionNotifications": MessageLookupByLibrary.simpleMessage("通知"),
    "setupPermissionNotificationsDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash 运行时显示连接状态",
    ),
    "setupPermissionOpenSettings": MessageLookupByLibrary.simpleMessage("打开设置"),
    "setupPermissionRequest": MessageLookupByLibrary.simpleMessage("允许"),
    "setupPermissionUnavailable": MessageLookupByLibrary.simpleMessage("不可用"),
    "setupPermissionVpn": MessageLookupByLibrary.simpleMessage("VPN 权限"),
    "setupPermissionVpnDesc": MessageLookupByLibrary.simpleMessage(
      "首次连接时由系统询问",
    ),
    "setupPermissionsTitle": MessageLookupByLibrary.simpleMessage("权限"),
    "setupProfileSourceNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash 不销售 VPN 服务。请使用可信服务提供商提供的链接、二维码或配置文件。保存前会先验证配置。",
    ),
    "setupProfilesReady": m67,
    "setupRawConfig": MessageLookupByLibrary.simpleMessage("配置文本"),
    "setupRawConfigDesc": MessageLookupByLibrary.simpleMessage(
      "粘贴与 Clash 兼容的 YAML 配置",
    ),
    "setupRegionDesc": MessageLookupByLibrary.simpleMessage(
      "选择网络所在地区。选择俄罗斯会启用 HWID，您可以在下方关闭。智能路由单独设置。",
    ),
    "setupRegionNone": MessageLookupByLibrary.simpleMessage("其他"),
    "setupRegionRecommended": MessageLookupByLibrary.simpleMessage("根据你的语言推荐"),
    "setupRegionSettings": MessageLookupByLibrary.simpleMessage("地区快捷设置"),
    "setupRegionSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "查看地理数据、路由预设和应用访问设置。不会自动添加任何内容。",
    ),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage("当前网络位于哪个地区？"),
    "setupReplaceProfile": MessageLookupByLibrary.simpleMessage("替换"),
    "setupReplaceProfileHint": MessageLookupByLibrary.simpleMessage(
      "新配置成功导入并通过验证后，才会删除当前配置。",
    ),
    "setupRerun": MessageLookupByLibrary.simpleMessage("重新运行初始设置"),
    "setupRerunDesc": MessageLookupByLibrary.simpleMessage(
      "在不删除数据的情况下检查语言、配置、路由和权限",
    ),
    "setupRestore": MessageLookupByLibrary.simpleMessage("从备份恢复"),
    "setupRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "从 ReClash、FlClashX 或 FlClash 备份恢复设置和配置",
    ),
    "setupSkip": MessageLookupByLibrary.simpleMessage("不添加配置，继续"),
    "setupStepProgress": m68,
    "setupSubscriptionDesc": MessageLookupByLibrary.simpleMessage(
      "配置包含 ReClash 连接所需的服务器和规则。请从服务提供商或备份中导入。",
    ),
    "setupSubscriptionReady": MessageLookupByLibrary.simpleMessage("配置已就绪"),
    "setupSubscriptionTitle": MessageLookupByLibrary.simpleMessage("添加连接配置"),
    "setupSummaryAutoRunOff": MessageLookupByLibrary.simpleMessage("自动连接：关闭"),
    "setupSummaryAutoRunOn": MessageLookupByLibrary.simpleMessage("自动连接：开启"),
    "setupSummaryNoProfile": MessageLookupByLibrary.simpleMessage(
      "没有 VPN 配置 — VPN 将保持关闭；可使用“仅 ByeDPI”模式",
    ),
    "setupSummaryProfile": m69,
    "setupSummaryRouting": m70,
    "setupSummarySystemProxyOff": MessageLookupByLibrary.simpleMessage(
      "系统代理：关闭",
    ),
    "setupSummarySystemProxyOn": MessageLookupByLibrary.simpleMessage(
      "系统代理：开启",
    ),
    "setupSummaryTitle": MessageLookupByLibrary.simpleMessage("设置摘要"),
    "setupSummaryTunOff": MessageLookupByLibrary.simpleMessage("TUN：关闭"),
    "setupSummaryTunOn": MessageLookupByLibrary.simpleMessage("TUN：开启"),
    "setupSystemLanguage": MessageLookupByLibrary.simpleMessage("跟随系统语言"),
    "setupSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "无需管理员权限，将支持的应用流量通过 ReClash 转发",
    ),
    "setupTunDesc": MessageLookupByLibrary.simpleMessage(
      "转发设备的全部流量；连接时系统可能会请求管理员权限",
    ),
    "setupWelcome": MessageLookupByLibrary.simpleMessage("几个简单步骤即可准备就绪"),
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
    "smartRoutingActiveCircuits": MessageLookupByLibrary.simpleMessage(
      "暂时停用的提供商",
    ),
    "smartRoutingActiveMarkers": MessageLookupByLibrary.simpleMessage(
      "暂时停用的检查",
    ),
    "smartRoutingAdmittedYes": MessageLookupByLibrary.simpleMessage("允许"),
    "smartRoutingAliveCount": m71,
    "smartRoutingAllServers": MessageLookupByLibrary.simpleMessage("所有服务器"),
    "smartRoutingAvailability": MessageLookupByLibrary.simpleMessage("可用性"),
    "smartRoutingAvailabilityValue": m72,
    "smartRoutingAverageFailover": MessageLookupByLibrary.simpleMessage(
      "平均切换耗时",
    ),
    "smartRoutingAverageRecovery": MessageLookupByLibrary.simpleMessage(
      "平均恢复耗时",
    ),
    "smartRoutingBackToAuto": MessageLookupByLibrary.simpleMessage("恢复自动选择"),
    "smartRoutingBandLabel": m73,
    "smartRoutingBands": m74,
    "smartRoutingBehaviour": MessageLookupByLibrary.simpleMessage("行为"),
    "smartRoutingBlockAbsent": MessageLookupByLibrary.simpleMessage(
      "不在当前服务器列表中",
    ),
    "smartRoutingBlockCooling": m75,
    "smartRoutingBlockDisproven": MessageLookupByLibrary.simpleMessage(
      "在这里未通过检查",
    ),
    "smartRoutingBlockLastResort": MessageLookupByLibrary.simpleMessage(
      "本地服务器，在此网络被禁用",
    ),
    "smartRoutingBlockNoUdp": MessageLookupByLibrary.simpleMessage("不支持 UDP"),
    "smartRoutingBlockProviderCircuit": MessageLookupByLibrary.simpleMessage(
      "因多个独立故障而暂时停用提供商",
    ),
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
    "smartRoutingCanariesAnswered": m76,
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
    "smartRoutingCoolFor": m77,
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
    "smartRoutingEngineAvailable": MessageLookupByLibrary.simpleMessage(
      "线路可用时长",
    ),
    "smartRoutingEngineDeepScan": MessageLookupByLibrary.simpleMessage("全量检查"),
    "smartRoutingEngineLanes": MessageLookupByLibrary.simpleMessage("服务通道"),
    "smartRoutingEngineLinkAge": MessageLookupByLibrary.simpleMessage("链路存续时长"),
    "smartRoutingEngineMode": MessageLookupByLibrary.simpleMessage("内核模式"),
    "smartRoutingEnginePin": MessageLookupByLibrary.simpleMessage("已固定的服务器"),
    "smartRoutingEnginePreset": MessageLookupByLibrary.simpleMessage("地区预设"),
    "smartRoutingEngineReportAge": MessageLookupByLibrary.simpleMessage(
      "报告生成于",
    ),
    "smartRoutingEngineTerrain": MessageLookupByLibrary.simpleMessage("网络类型代码"),
    "smartRoutingEngineTransport": MessageLookupByLibrary.simpleMessage("链路类型"),
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
    "smartRoutingEvidenceForeignForged": MessageLookupByLibrary.simpleMessage(
      "网关返回了伪造的证书",
    ),
    "smartRoutingEvidenceForeignOk": MessageLookupByLibrary.simpleMessage(
      "境外地址通过了证书验证",
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
    "smartRoutingFails": m78,
    "smartRoutingFitNo": MessageLookupByLibrary.simpleMessage("不契合"),
    "smartRoutingFitYes": MessageLookupByLibrary.simpleMessage("契合"),
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
    "smartRoutingIncidents": MessageLookupByLibrary.simpleMessage("检测到的中断"),
    "smartRoutingIncumbentNo": MessageLookupByLibrary.simpleMessage("挑战者"),
    "smartRoutingIncumbentYes": MessageLookupByLibrary.simpleMessage("使用中"),
    "smartRoutingIntro": MessageLookupByLibrary.simpleMessage(
      "智能路由为当前网络保持可用的服务器，并在网络变化时自动切换。先选择区域预设，再在下方微调策略、探测与标记。",
    ),
    "smartRoutingKept": MessageLookupByLibrary.simpleMessage("保持"),
    "smartRoutingKeyAdmission": MessageLookupByLibrary.simpleMessage("允许参与比较"),
    "smartRoutingKeyBand": MessageLookupByLibrary.simpleMessage("延迟档"),
    "smartRoutingKeyEvidence": MessageLookupByLibrary.simpleMessage("证据"),
    "smartRoutingKeyIncumbent": MessageLookupByLibrary.simpleMessage("正在使用"),
    "smartRoutingKeyMisfit": MessageLookupByLibrary.simpleMessage("对本网络的适配"),
    "smartRoutingKeyTiebreak": MessageLookupByLibrary.simpleMessage("稳定的平局处理"),
    "smartRoutingKeyUnproven": MessageLookupByLibrary.simpleMessage("承载过流量"),
    "smartRoutingKeyVerdict": MessageLookupByLibrary.simpleMessage("结论"),
    "smartRoutingLadderHint": MessageLookupByLibrary.simpleMessage(
      "两台服务器逐行比对。第一处不同的行即为结果，该行以下的内容完全不再读取。",
    ),
    "smartRoutingLastFailover": MessageLookupByLibrary.simpleMessage("最近一次切换"),
    "smartRoutingLastRecovery": MessageLookupByLibrary.simpleMessage("最近恢复耗时"),
    "smartRoutingLostAt": m79,
    "smartRoutingManualHold": MessageLookupByLibrary.simpleMessage("尊重手动选择"),
    "smartRoutingManualHoldDesc": MessageLookupByLibrary.simpleMessage(
      "保留你手动选择的服务器，直到它失效",
    ),
    "smartRoutingManualPinned": MessageLookupByLibrary.simpleMessage("保持到失效为止"),
    "smartRoutingMarkerIncidents": MessageLookupByLibrary.simpleMessage(
      "已隔离的服务检查",
    ),
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
    "smartRoutingMeasuredOver": m80,
    "smartRoutingMetered": MessageLookupByLibrary.simpleMessage("计费网络"),
    "smartRoutingNetworkFormat": MessageLookupByLibrary.simpleMessage("网络"),
    "smartRoutingNeverSwitched": MessageLookupByLibrary.simpleMessage(
      "此网络尚未切换过",
    ),
    "smartRoutingNoAnswer": MessageLookupByLibrary.simpleMessage("无响应"),
    "smartRoutingNoRecovery": MessageLookupByLibrary.simpleMessage("尚无已恢复的中断"),
    "smartRoutingNoRivals": MessageLookupByLibrary.simpleMessage("没有其他服务器可比较"),
    "smartRoutingNoServers": MessageLookupByLibrary.simpleMessage("没有可用的服务器"),
    "smartRoutingNodeChecks": MessageLookupByLibrary.simpleMessage("服务器检查"),
    "smartRoutingNodeNoUdp": MessageLookupByLibrary.simpleMessage("无 UDP"),
    "smartRoutingNodeUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "smartRoutingNodesMeasured": m81,
    "smartRoutingNotBreaker": MessageLookupByLibrary.simpleMessage("通用"),
    "smartRoutingOffHint": MessageLookupByLibrary.simpleMessage(
      "开启智能路由，让它替你挑选服务器",
    ),
    "smartRoutingOn": MessageLookupByLibrary.simpleMessage("智能路由已开启"),
    "smartRoutingOverview": MessageLookupByLibrary.simpleMessage("路由概览"),
    "smartRoutingPortal": MessageLookupByLibrary.simpleMessage("需要登录 Wi-Fi"),
    "smartRoutingPreset": MessageLookupByLibrary.simpleMessage("预设"),
    "smartRoutingPresetChina": MessageLookupByLibrary.simpleMessage("中国"),
    "smartRoutingPresetEdited": m82,
    "smartRoutingPresetIran": MessageLookupByLibrary.simpleMessage("伊朗"),
    "smartRoutingPresetOff": MessageLookupByLibrary.simpleMessage("其他"),
    "smartRoutingPresetRussia": MessageLookupByLibrary.simpleMessage("俄罗斯"),
    "smartRoutingProbeBudget": m83,
    "smartRoutingProbing": MessageLookupByLibrary.simpleMessage("探测"),
    "smartRoutingProvenNo": MessageLookupByLibrary.simpleMessage("尚无"),
    "smartRoutingProvenYes": MessageLookupByLibrary.simpleMessage("有"),
    "smartRoutingProviderIncidents": MessageLookupByLibrary.simpleMessage(
      "提供商熔断次数",
    ),
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
    "smartRoutingReasonHandoffRecovery": MessageLookupByLibrary.simpleMessage(
      "网络切换后连接已恢复",
    ),
    "smartRoutingReasonHold": MessageLookupByLibrary.simpleMessage(
      "运行正常，没有更好的选择",
    ),
    "smartRoutingReasonIncumbentDead": MessageLookupByLibrary.simpleMessage(
      "上一台服务器不再响应",
    ),
    "smartRoutingReasonLatencyGain": MessageLookupByLibrary.simpleMessage(
      "多次检查确认延迟更低",
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
    "smartRoutingReasonQualityConfirming": MessageLookupByLibrary.simpleMessage(
      "正在通过多次比较确认改善",
    ),
    "smartRoutingReasonReliabilityGain": MessageLookupByLibrary.simpleMessage(
      "多次检查确认有更稳定的替代服务器",
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
    "smartRoutingRungVersus": m84,
    "smartRoutingSearching": MessageLookupByLibrary.simpleMessage("正在挑选服务器…"),
    "smartRoutingSeconds": m85,
    "smartRoutingSectionEngine": MessageLookupByLibrary.simpleMessage("引擎"),
    "smartRoutingSectionHealth": MessageLookupByLibrary.simpleMessage("服务器"),
    "smartRoutingSectionHistory": MessageLookupByLibrary.simpleMessage("早前的切换"),
    "smartRoutingSectionLadder": MessageLookupByLibrary.simpleMessage(
      "服务器如何比较",
    ),
    "smartRoutingSectionNetwork": MessageLookupByLibrary.simpleMessage("网络"),
    "smartRoutingSectionReliability": MessageLookupByLibrary.simpleMessage(
      "可靠性",
    ),
    "smartRoutingSectionRivals": MessageLookupByLibrary.simpleMessage(
      "与所选服务器对比",
    ),
    "smartRoutingSectionRound": MessageLookupByLibrary.simpleMessage("决策"),
    "smartRoutingServers": MessageLookupByLibrary.simpleMessage("服务器"),
    "smartRoutingServersCount": m86,
    "smartRoutingServiceAnyProvider": MessageLookupByLibrary.simpleMessage(
      "任意提供商",
    ),
    "smartRoutingServiceCandidates": m87,
    "smartRoutingServiceEnabled": MessageLookupByLibrary.simpleMessage(
      "使用服务路由",
    ),
    "smartRoutingServiceEnabledDesc": MessageLookupByLibrary.simpleMessage(
      "通过匹配的专用节点发送此服务流量",
    ),
    "smartRoutingServiceFallback": MessageLookupByLibrary.simpleMessage(
      "专用节点不可用时",
    ),
    "smartRoutingServiceFallbackActiveMain":
        MessageLookupByLibrary.simpleMessage("没有可用的专用节点 · 使用主节点"),
    "smartRoutingServiceFallbackActiveReject":
        MessageLookupByLibrary.simpleMessage("没有可用的专用节点 · 服务已阻止"),
    "smartRoutingServiceFallbackDesc": MessageLookupByLibrary.simpleMessage(
      "专用节点不可用时隐藏服务组的处理方式",
    ),
    "smartRoutingServiceFallbackMain": MessageLookupByLibrary.simpleMessage(
      "使用 Smart Routing 主节点",
    ),
    "smartRoutingServiceFallbackReject": MessageLookupByLibrary.simpleMessage(
      "阻止此服务",
    ),
    "smartRoutingServiceGemini": MessageLookupByLibrary.simpleMessage(
      "Gemini 访问",
    ),
    "smartRoutingServiceManual": MessageLookupByLibrary.simpleMessage("手动选择器"),
    "smartRoutingServiceManualEmpty": MessageLookupByLibrary.simpleMessage(
      "没有手动选择器",
    ),
    "smartRoutingServiceManualEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "添加名称片段，并可选择指定提供商",
    ),
    "smartRoutingServiceManualSelector": MessageLookupByLibrary.simpleMessage(
      "手动专用节点选择器",
    ),
    "smartRoutingServiceMatchedNone": MessageLookupByLibrary.simpleMessage(
      "尚无匹配的服务器",
    ),
    "smartRoutingServiceNameContains": MessageLookupByLibrary.simpleMessage(
      "名称包含",
    ),
    "smartRoutingServiceNameContainsDesc": MessageLookupByLibrary.simpleMessage(
      "区分大小写的节点名称片段",
    ),
    "smartRoutingServiceNoCandidates": MessageLookupByLibrary.simpleMessage(
      "没有专用节点选择器",
    ),
    "smartRoutingServicePending": MessageLookupByLibrary.simpleMessage(
      "正在等待引擎",
    ),
    "smartRoutingServiceProvider": m88,
    "smartRoutingServiceProviderCandidates": m89,
    "smartRoutingServiceProviderDesc": MessageLookupByLibrary.simpleMessage(
      "提供商精确名称；留空则匹配任意提供商",
    ),
    "smartRoutingServiceProviderOptional": MessageLookupByLibrary.simpleMessage(
      "提供商（可选）",
    ),
    "smartRoutingServiceProviderSource": MessageLookupByLibrary.simpleMessage(
      "订阅清单",
    ),
    "smartRoutingServiceReady": m90,
    "smartRoutingServiceRoute": MessageLookupByLibrary.simpleMessage("路由"),
    "smartRoutingServiceRoutes": MessageLookupByLibrary.simpleMessage("服务路由"),
    "smartRoutingServiceRoutesEmpty": MessageLookupByLibrary.simpleMessage(
      "尚未配置服务路由",
    ),
    "smartRoutingServiceSources": MessageLookupByLibrary.simpleMessage("选择器来源"),
    "smartRoutingServiceStatus": MessageLookupByLibrary.simpleMessage("状态"),
    "smartRoutingServiceTokenTooLong": m91,
    "smartRoutingServiceVia": m92,
    "smartRoutingServiceYouTube": MessageLookupByLibrary.simpleMessage(
      "无广告 YouTube",
    ),
    "smartRoutingStandbyHits": MessageLookupByLibrary.simpleMessage("通过热备用恢复"),
    "smartRoutingStepAdmit": MessageLookupByLibrary.simpleMessage("决定谁可参选"),
    "smartRoutingStepAdmitBody": m93,
    "smartRoutingStepDecision": MessageLookupByLibrary.simpleMessage("最终选择"),
    "smartRoutingStepNetwork": MessageLookupByLibrary.simpleMessage("读取网络"),
    "smartRoutingStepRank": MessageLookupByLibrary.simpleMessage("对余下的排序"),
    "smartRoutingStepRankBody": MessageLookupByLibrary.simpleMessage(
      "两台服务器第一处不同的行决定结果",
    ),
    "smartRoutingStrategy": MessageLookupByLibrary.simpleMessage("策略"),
    "smartRoutingStrategyBalanced": MessageLookupByLibrary.simpleMessage("通用"),
    "smartRoutingStrategyBalancedDesc": MessageLookupByLibrary.simpleMessage(
      "适合各种情况，拿不准就选这个",
    ),
    "smartRoutingStrategyEdited": m94,
    "smartRoutingStrategyLowestLatency": MessageLookupByLibrary.simpleMessage(
      "速度优先",
    ),
    "smartRoutingStrategyLowestLatencyDesc":
        MessageLookupByLibrary.simpleMessage("在可用的服务器中选择最快的"),
    "smartRoutingStrategySaver": MessageLookupByLibrary.simpleMessage("省流量"),
    "smartRoutingStrategySaverDesc": MessageLookupByLibrary.simpleMessage(
      "更少检测服务器，节省流量和电量",
    ),
    "smartRoutingStrategyStable": MessageLookupByLibrary.simpleMessage("稳定优先"),
    "smartRoutingStrategyStableDesc": MessageLookupByLibrary.simpleMessage(
      "保持可用的服务器，尽量少切换",
    ),
    "smartRoutingSwitchLine": m95,
    "smartRoutingSwitched": MessageLookupByLibrary.simpleMessage("已切换"),
    "smartRoutingSwitchedAgo": m96,
    "smartRoutingTabDetails": MessageLookupByLibrary.simpleMessage("详情"),
    "smartRoutingTabOverview": MessageLookupByLibrary.simpleMessage("概览"),
    "smartRoutingTabRanking": MessageLookupByLibrary.simpleMessage("选取"),
    "smartRoutingTechnical": MessageLookupByLibrary.simpleMessage("技术细节"),
    "smartRoutingTiedAll": MessageLookupByLibrary.simpleMessage("每一行都相同"),
    "smartRoutingUntested": MessageLookupByLibrary.simpleMessage("未测试"),
    "smartRoutingVerdictLastResort": MessageLookupByLibrary.simpleMessage(
      "最后手段",
    ),
    "smartRoutingVerdictPreferred": MessageLookupByLibrary.simpleMessage(
      "可通往开放互联网",
    ),
    "smartRoutingVerdictReject": MessageLookupByLibrary.simpleMessage("不可用"),
    "smartRoutingVerdictViable": MessageLookupByLibrary.simpleMessage("可用"),
    "smartRoutingWaitingNetwork": MessageLookupByLibrary.simpleMessage(
      "智能路由正在等待网络",
    ),
    "smartRoutingWaitingTunnel": MessageLookupByLibrary.simpleMessage(
      "智能路由已开启 · 正在等待隧道",
    ),
    "smartRoutingWave": MessageLookupByLibrary.simpleMessage("每次检查的服务器数"),
    "smartRoutingWaveDesc": MessageLookupByLibrary.simpleMessage(
      "一次后台检查测量多少台服务器",
    ),
    "smartRoutingWaveNodes": m97,
    "smartRoutingWhatWasTested": MessageLookupByLibrary.simpleMessage("链路检查"),
    "smartRoutingWhy": MessageLookupByLibrary.simpleMessage("原因"),
    "smartRoutingWinsAt": m98,
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
    "subscriptionClientClashMeta": MessageLookupByLibrary.simpleMessage(
      "Clash Meta",
    ),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage("自定义"),
    "subscriptionClientDesc": MessageLookupByLibrary.simpleMessage(
      "应用会以此客户端的格式获取订阅",
    ),
    "subscriptionClientExperimentalLabel": MessageLookupByLibrary.simpleMessage(
      "实验性",
    ),
    "subscriptionClientExperimentalTip": MessageLookupByLibrary.simpleMessage(
      "客户端兼容性为实验性功能：提供方下发所选客户端的格式，由 ReClash 转换。",
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
    "subscriptionConfigurationSource": MessageLookupByLibrary.simpleMessage(
      "提供的配置",
    ),
    "subscriptionDirectRetryConfirm": MessageLookupByLibrary.simpleMessage(
      "直接重试",
    ),
    "subscriptionDirectRetryMessage": MessageLookupByLibrary.simpleMessage(
      "无法通过当前连接访问订阅。是否在不关闭 VPN 的情况下直接重试此次下载？面板将看到您所在网络的 IP 地址。其他流量的路由不会改变。",
    ),
    "subscriptionDirectRetryTitle": MessageLookupByLibrary.simpleMessage(
      "绕过 VPN 重试？",
    ),
    "subscriptionDomainMoved": m99,
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage("订阅已过期"),
    "subscriptionExpiresInDays": m100,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage("订阅今天到期"),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage("订阅信息"),
    "subscriptionNoQuota": MessageLookupByLibrary.simpleMessage(
      "此订阅未提供流量额度或到期时间",
    ),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage("订阅提醒"),
    "subscriptionProviderInterval": m101,
    "subscriptionUndialable": MessageLookupByLibrary.simpleMessage(
      "订阅中未找到常规节点地址。面板可能返回了占位配置。尚未测试服务器连接。",
    ),
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
    "tk": MessageLookupByLibrary.simpleMessage("土库曼语"),
    "toggle": MessageLookupByLibrary.simpleMessage("切换"),
    "toggleLabel": MessageLookupByLibrary.simpleMessage("切换标签"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("调性点缀"),
    "tools": MessageLookupByLibrary.simpleMessage("工具"),
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("购买流量"),
    "torch": MessageLookupByLibrary.simpleMessage("手电筒"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("总流量"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxy端口"),
    "trafficFreeOfTotal": m102,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("流量统计"),
    "translationNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash 支持你的语言，让来自不同国家的人都能使用。如果某处措辞别扭，欢迎告诉我们，我们会尽快修正。",
    ),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage("提交翻译修改建议"),
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
    "urlScheme": MessageLookupByLibrary.simpleMessage("URL 方案"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("添加订阅"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage("确认后添加订阅 URL"),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("关闭"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage("收进托盘，或按设置退出"),
    "urlSchemeCommands": MessageLookupByLibrary.simpleMessage("自动化命令"),
    "urlSchemeCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "用于任务、脚本、快捷方式与自动化",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("连接"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage("启动隧道并连接"),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("断开"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage("停止隧道"),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage("导入配置"),
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "base64 编码的配置文件，作为配置导入",
    ),
    "urlSchemeImportInvalid": MessageLookupByLibrary.simpleMessage(
      "导入内容不是有效的 base64",
    ),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage("安装配置"),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Clash 和 FlClash 按钮已在使用的兼容链接",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage("打开"),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage("将窗口置前"),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("配置文件"),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage("切换"),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage("停止时连接，运行时断开"),
    "urlTip": m103,
    "useHosts": MessageLookupByLibrary.simpleMessage("使用Hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("使用系统Hosts"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("已用流量"),
    "userAgent": MessageLookupByLibrary.simpleMessage("用户代理"),
    "uz": MessageLookupByLibrary.simpleMessage("乌兹别克语"),
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
    "wallpaperBlur": MessageLookupByLibrary.simpleMessage("模糊"),
    "wallpaperCardOpacity": MessageLookupByLibrary.simpleMessage("卡片不透明度"),
    "wallpaperChoose": MessageLookupByLibrary.simpleMessage("选择图片"),
    "wallpaperDescription": MessageLookupByLibrary.simpleMessage(
      "您选择的图片会优先于订阅背景显示。关闭自定义背景即可恢复订阅背景。",
    ),
    "wallpaperDimming": MessageLookupByLibrary.simpleMessage("调暗"),
    "wallpaperEffects": MessageLookupByLibrary.simpleMessage("图片调整"),
    "wallpaperEnabled": MessageLookupByLibrary.simpleMessage("使用自定义背景"),
    "wallpaperFit": MessageLookupByLibrary.simpleMessage("图片适配方式"),
    "wallpaperFitContain": MessageLookupByLibrary.simpleMessage("适应"),
    "wallpaperFitCover": MessageLookupByLibrary.simpleMessage("填充"),
    "wallpaperFitFill": MessageLookupByLibrary.simpleMessage("拉伸"),
    "wallpaperGalleryHint": MessageLookupByLibrary.simpleMessage(
      "点按已保存的背景即可应用，或添加新背景。",
    ),
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage("水平位置"),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "请选择有效的 PNG、JPEG 或 WebP 图片。",
    ),
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("构图"),
    "wallpaperLibraryFull": m104,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage("图片不透明度"),
    "wallpaperReadability": MessageLookupByLibrary.simpleMessage("可读性"),
    "wallpaperRemove": MessageLookupByLibrary.simpleMessage("移除图片"),
    "wallpaperReset": MessageLookupByLibrary.simpleMessage("重置调整"),
    "wallpaperSaveError": MessageLookupByLibrary.simpleMessage(
      "无法保存背景。已保留原有背景。",
    ),
    "wallpaperScale": MessageLookupByLibrary.simpleMessage("缩放"),
    "wallpaperSelectHint": MessageLookupByLibrary.simpleMessage(
      "PNG、JPEG 或 WebP · 不超过 20 MB",
    ),
    "wallpaperTitle": MessageLookupByLibrary.simpleMessage("自定义背景"),
    "wallpaperTooLarge": MessageLookupByLibrary.simpleMessage(
      "请选择大小不超过 20 MB、像素总数不超过 5000 万的图片。",
    ),
    "wallpaperVerticalPosition": MessageLookupByLibrary.simpleMessage("垂直位置"),
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
    "yearsAgo": m105,
    "zhCN": MessageLookupByLibrary.simpleMessage("中文简体"),
  };
}
