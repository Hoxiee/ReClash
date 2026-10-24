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

  static String m0(count) => "已选 ${count}";

  static String m1(count) => "服务商让 ${count} 个应用绕过 VPN。打开访问控制即可修改列表。";

  static String m2(name) => "已将 ${name} 添加到本地代理";

  static String m3(name) => "本地代理中已有 ${name}";

  static String m4(count, skipped) => "将添加 ${count} 项，跳过 ${skipped} 项已存在";

  static String m5(detail) => "清除数据失败：${detail}";

  static String m6(code) =>
      "Windows 拒绝运行 ReClashCore.exe（错误 ${code}）。智能应用控制、AppLocker 等应用控制策略会拦截未签名程序，请在该策略中放行 ReClash 或关闭策略后重试。";

  static String m7(name) =>
      "应用连续两次未能完成启动。为打断崩溃循环，已取消选中配置 ${name}，并跳过本次自动配置，你可以随时重新选中它。";

  static String m8(url) => "是否要通过 ${url} 创建配置？";

  static String m9(groups) => "已丢弃策略组 ${groups} 的 include-all，请为这些策略组添加代理或代理集";

  static String m10(count, label) =>
      "${Intl.plural(count, other: '自定义配置不支持子规则，已丢弃 ${label} 条 SUB-RULE 规则')}";

  static String m11(message) => "内核无法解析该代理：${message}";

  static String m12(proxy, target) =>
      "${proxy} 经 ${target} 拨号，而 ${target} 又会回到 ${proxy}，形成环路";

  static String m13(name) => "名称 ${name} 已被其他代理或策略组使用";

  static String m14(path) => "策略组之间存在循环引用：${path}";

  static String m15(name) => "空组兜底只能是代理，${name} 不存在或是策略组";

  static String m16(name, message) => "${name}不是有效的正则：${message}";

  static String m17(name) => "拨号代理 ${name} 不存在";

  static String m18(names) => "以下代理集不存在：${names}";

  static String m19(names) => "以下代理或策略不存在：${names}";

  static String m20(name) => "${name} 是内置策略名，不能在此使用";

  static String m21(count) => "${count} 项存在问题，应用配置可能失败";

  static String m22(count) => "${count} 天前";

  static String m23(count) => "${count} 天前";

  static String m24(label) => "确定删除选中的${label}吗？";

  static String m25(label) => "确定删除当前${label}吗？";

  static String m26(label) => "${label}详情";

  static String m27(name) => "经 ${name} 拨号会绕回使用它的代理，连接已中止";

  static String m28(label) => "${label}不能为空";

  static String m29(label) => "${label}当前已存在";

  static String m30(count) => "${count} 项失败";

  static String m31(label, message) => "${label}：${message}";

  static String m32(name) => "${name} 已是最新版本";

  static String m33(name) => "${name} 已更新";

  static String m34(count) => "${count} 个";

  static String m35(count) => "${count} 超时";

  static String m36(action) => "已被“${action}”使用，保存后将移到这里";

  static String m37(actions) => "未导出：${actions}";

  static String m38(modifiers) => "至少包含 ${modifiers} 中的一个";

  static String m39(count) => "${count} 小时前";

  static String m40(count) => "${count} 小时前";

  static String m41(target) => "${target} 是一个无效的策略";

  static String m42(proxyName) => "${proxyName} 是一个无效的代理";

  static String m43(providerName) => "${providerName} 是一个无效的代理集";

  static String m44(ruleSet) => "${ruleSet} 不是有效的规则集";

  static String m45(subRule) => "${subRule} 是一个无效的SUB_RULE";

  static String m46(count) => "${count} 项";

  static String m47(line, message) => "第 ${line} 行：${message}";

  static String m48(appName) =>
      "1. 打开 系统设置 > 隐私与安全性\n2. 选择 定位服务\n3. 在右侧列表中找到并勾选 ${appName}\n\n完成设置后，返回应用即可正常使用。感谢您的配合。";

  static String m49(label, max) => "${label}最多${max}个字符";

  static String m50(size) => "已释放 ${size}";

  static String m51(count) => "${count} 分钟前";

  static String m52(count) => "${count} 分钟前";

  static String m53(count) => "${count} 个月前";

  static String m54(count) => "${count} 个月前";

  static String m55(code) => "服务器拒绝访问（HTTP ${code}），链接可能已过期或凭据有误";

  static String m56(code) => "服务器拒绝了请求（HTTP ${code}）";

  static String m57(code) => "该地址下没有内容（HTTP ${code}），请确认链接是否正确";

  static String m58(detail) => "网络请求失败：${detail}";

  static String m59(code) => "服务器出现问题（HTTP ${code}），请稍后再试";

  static String m60(label) => "暂无${label}";

  static String m61(label, min, max) => "${label}必须在 ${min} 到 ${max} 之间";

  static String m62(label) => "${label}必须为数字";

  static String m63(label) => "${label} 必须在 1024 到 49151 之间";

  static String m64(port) => "端口 ${port}";

  static String m65(added, skipped, failed) =>
      "已添加：${added}；已跳过：${skipped}；失败：${failed}。";

  static String m66(days) => "剩余 ${days} 天";

  static String m67(date, days) => "${date} 到期，剩余 ${days} 天";

  static String m68(name) => "已作为“${name}”添加";

  static String m69(client) => "与 ${client} 应用收到的一致";

  static String m70(count) => "${Intl.plural(count, other: '${count} 个服务器')}";

  static String m71(time) => "更新于 ${time}";

  static String m72(label, profiles) =>
      "${label} 仍被 ${profiles} 使用，删除后这些配置会异常。确定删除吗？";

  static String m73(count, label) =>
      "${Intl.plural(count, other: '${label} 个代理')}";

  static String m74(name, count) => "${name} 等 ${count} 个代理";

  static String m75(removed) =>
      "以下代理将被删除：${removed}。改了名字的行按新代理处理，自定义配置中对被删除代理的引用会标为缺失。确定应用吗？";

  static String m76(removed, added) =>
      "以下代理将被删除：${removed}。以下代理将新增：${added}。改了名字的行按新代理处理，自定义配置中对被删除代理的引用会标为缺失。确定应用吗？";

  static String m77(label) =>
      "${label} 仍被当前配置的规则、策略组、拨号代理、DNS 或 NTP 引用，删除后这些引用会失效。确定删除吗？";

  static String m78(count, label) =>
      "${Intl.plural(count, other: '${label} 个策略组')}";

  static String m79(pick, now) => "会选择 ${pick} 而不是 ${now}";

  static String m80(group) => "在 ${group} 上检测";

  static String m81(pick) => "会保持 ${pick}";

  static String m82(number) => "条件 ${number}";

  static String m83(profile) => "“${profile}”想要检测这些网站";

  static String m84(profile) => "删除“${profile}”？";

  static String m85(requests, used, cap) =>
      "今日检测：${requests} · 已用 ${used}／${cap}";

  static String m86(condition) => "${condition} 除外";

  static String m87(country) => "出口 ${country}";

  static String m88(member) => "经由 ${member}";

  static String m89(profile) => "已添加“${profile}”";

  static String m90(node) => "${node} 已失效";

  static String m91(from, to) => "模式 ${from} → ${to}";

  static String m92(line, text) => "第 ${line} 行：${text}";

  static String m93(check) => "检测 ${check} 从未被使用，因此不会运行";

  static String m94(hosts) => "会访问第三方网站：${hosts}";

  static String m95(group) => "此配置中没有分组 ${group}";

  static String m96(group) => "${group} 中没有服务器通过筛选";

  static String m97(tag) => "标签 ${tag} 从未被使用";

  static String m98(tier, group) => "当前 ${group} 中没有服务器属于“${tier}”";

  static String m99(tier, after) => "“${tier}”与“${after}”的条件相同，因此不会有任何服务器归入其中";

  static String m100(keys) => "已合并；以下项目你也修改过，因此保留了你的修改：${keys}";

  static String m101(mode) => "模式：${mode}";

  static String m102(kind) => "网络：${kind}";

  static String m103(tier) => "检测后可能进入“${tier}”";

  static String m104(node) => "已固定：${node}";

  static String m105(error) => "配置错误：${error}";

  static String m106(profile) => "未找到配置 ${profile}，已使用默认配置";

  static String m107(error) => "无法保存路由状态：${error}";

  static String m108(tier) => "已切换到“${tier}”中的服务器";

  static String m109(from) => "已更换服务器，${from} 在 15 分钟内被跳过";

  static String m110(from) => "${from} 已失效，已切换到最佳备用服务器";

  static String m111(from, gain) => "已从 ${from} 切换：快 ${gain} ms";

  static String m112(node) => "场景正固定使用 ${node}";

  static String m113(node) => "${node} 不在此分组中";

  static String m114(limit) => "已达到切换上限（每小时 ${limit} 次）";

  static String m115(mode) => "未使用：${mode} 模式";

  static String m116(from) => "${from} 已不在候选范围内";

  static String m117(kind) => "网络为“${kind}”时暂停：不检测也不切换";

  static String m118(node) => "场景将切换到 ${node}";

  static String m119(node) => "已切换到固定的服务器 ${node}";

  static String m120(node) => "没有可用服务器，已回退到 ${node}";

  static String m121(scenario) => "当前由场景“${scenario}”控制此分组。";

  static String m122(count, total) => "${total} 个中匹配 ${count} 个";

  static String m123(node) => "检测确认后将切换到 ${node}";

  static String m124(node, gain) => "如果 ${node} 持续快 ${gain} ms 将切换";

  static String m125(node, minutes) => "${minutes} 分钟后可能切换到 ${node}";

  static String m126(name) => "检测 ${name}";

  static String m127(name) => "网络诊断 ${name}";

  static String m128(region, bypassed, proxied) =>
      "${region}：VPN 绕过列表将有 ${bypassed} 个应用，VPN 列表将有 ${proxied} 个应用。两个列表都会被替换，模式及其他设置保持不变。软件包和 SDK 匹配仅为建议，请在应用后检查结果。";

  static String m129(seconds) => "${seconds} 秒后可确认";

  static String m130(count, label) =>
      "${Intl.plural(count, other: '${label} 条规则')}";

  static String m131(appName) => "${appName}（安全模式）";

  static String m132(count) => "${count} 秒";

  static String m133(count) => "${count} 项生效";

  static String m134(count) => "${count} 项异常";

  static String m135(count) => "${count} 项设置";

  static String m136(count) => "绕过 VPN 的应用：${count}";

  static String m137(count) => "可用配置：${count} 个";

  static String m138(step, total) => "第 ${step} 步，共 ${total} 步";

  static String m139(server) => "尝试 ${server}";

  static String m140(link) => "无法从 ${link} 中读取代理";

  static String m141(label) => "${label}只能是一项";

  static String m142(client, format, count) =>
      "以 ${client} 获取：${format}，代理节点 ${count} 个。";

  static String m143(count) => "订阅将在 ${count} 天后到期";

  static String m144(count) => "添加 ${count} 台服务器";

  static String m145(count) => "将添加全部 ${count} 台服务器";

  static String m146(count, total) => "将添加 ${total} 台服务器中的 ${count} 台";

  static String m147(count) => "显示全部（${count}）";

  static String m148(format) => "格式：${format}";

  static String m149(percent) => "已使用 ${percent}% 的流量";

  static String m150(count) => "${count} 个结果";

  static String m151(value) => "峰值 ${value}";

  static String m152(value) => "累计 ${value}";

  static String m153(transport) => "${transport} 请求头";

  static String m154(version) => "已安装版本：${version}";

  static String m155(count) => "${count} 分钟";

  static String m156(time) => "剩余 ${time}";

  static String m157(count) => "${count} 秒";

  static String m158(speed) => "${speed}/秒";

  static String m159(nodes, groups, providers) =>
      "代理：${nodes}，组：${groups}，远程提供者：${providers}";

  static String m160(action) => "此链接请求“${action}”。允许 ReClash 执行此操作吗？";

  static String m161(name, source) =>
      "从 ${source} 导入“${name}”吗？确认后将验证配置文件并检查转换内容。";

  static String m162(label) => "${label}必须为URL";

  static String m163(index) => "背景 ${index}";

  static String m164(count) => "最多可保存 ${count} 张背景。删除一张后才能添加新背景。";

  static String m165(count) => "${count} 年前";

  static String m166(count) => "${count} 年前";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("关于"),
    "accessControl": MessageLookupByLibrary.simpleMessage("访问控制"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "只允许选中应用进入VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "访问控制决定哪些应用使用代理。",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "应用访问控制已关闭",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "选中应用将会被排除在VPN之外",
    ),
    "accessControlSelectedCount": m0,
    "accessControlSettings": MessageLookupByLibrary.simpleMessage("访问控制设置"),
    "accessProviderDisabledDesc": m1,
    "accessReturnToProvider": MessageLookupByLibrary.simpleMessage("将应用交还给服务商"),
    "account": MessageLookupByLibrary.simpleMessage("账号"),
    "action": MessageLookupByLibrary.simpleMessage("操作"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage("测试全部延迟"),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("直连模式"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("全局模式"),
    "actionMode": MessageLookupByLibrary.simpleMessage("切换模式"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("系统代理"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("规则模式"),
    "actionStart": MessageLookupByLibrary.simpleMessage("启动/停止"),
    "actionTun": MessageLookupByLibrary.simpleMessage("虚拟网卡"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage("更新全部配置"),
    "actionView": MessageLookupByLibrary.simpleMessage("显示/隐藏"),
    "add": MessageLookupByLibrary.simpleMessage("添加"),
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("添加代理"),
    "addFilters": MessageLookupByLibrary.simpleMessage("添加筛选"),
    "addNetwork": MessageLookupByLibrary.simpleMessage("添加网络"),
    "addNodes": MessageLookupByLibrary.simpleMessage("添加节点"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage("添加覆写项"),
    "addProfile": MessageLookupByLibrary.simpleMessage("添加配置"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("添加策略组"),
    "addRule": MessageLookupByLibrary.simpleMessage("添加规则"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage("添加设置项"),
    "addSsid": MessageLookupByLibrary.simpleMessage("添加SSID"),
    "addToLocalProxies": MessageLookupByLibrary.simpleMessage("添加到本地代理"),
    "addedRules": MessageLookupByLibrary.simpleMessage("附加规则"),
    "addedToLocalProxies": m2,
    "additionalParameters": MessageLookupByLibrary.simpleMessage("附加参数"),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage("名称前缀"),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage("名称后缀"),
    "address": MessageLookupByLibrary.simpleMessage("地址"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("WebDAV服务器地址"),
    "addressTip": MessageLookupByLibrary.simpleMessage("请输入有效的WebDAV地址"),
    "advancedConfig": MessageLookupByLibrary.simpleMessage("进阶配置"),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "进阶配置包含网络、DNS、附加规则与脚本。",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage("配置已加密"),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage("age 私钥"),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "该配置已用 age 加密，需要 age 私钥才能解密",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("同意"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage("全部被引用的代理"),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "全部被引用的代理集",
    ),
    "allowBypass": MessageLookupByLibrary.simpleMessage("允许应用绕过VPN"),
    "allowLan": MessageLookupByLibrary.simpleMessage("局域网代理"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("允许的 IP"),
    "alreadyInLocalProxies": m3,
    "answers": MessageLookupByLibrary.simpleMessage("应答"),
    "app": MessageLookupByLibrary.simpleMessage("应用"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage("应用访问控制"),
    "appIcon": MessageLookupByLibrary.simpleMessage("应用图标"),
    "appIconApply": MessageLookupByLibrary.simpleMessage("使用此图标"),
    "appIconBlueprint": MessageLookupByLibrary.simpleMessage("蓝图"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "新图标可能需要几秒钟才会显示在桌面上，部分桌面启动器会移除快捷方式，请从应用列表中重新添加。",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("电路"),
    "appIconDesign": MessageLookupByLibrary.simpleMessage("应用图标设计"),
    "appIconEcho": MessageLookupByLibrary.simpleMessage("回声"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("墨"),
    "appIconShatter": MessageLookupByLibrary.simpleMessage("碎片"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("太阳"),
    "appIconSpark": MessageLookupByLibrary.simpleMessage("火花"),
    "appIconStandard": MessageLookupByLibrary.simpleMessage("标准"),
    "appIconStrata": MessageLookupByLibrary.simpleMessage("地层"),
    "appIconTopo": MessageLookupByLibrary.simpleMessage("地形"),
    "appIconTrace": MessageLookupByLibrary.simpleMessage("轨迹"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("天鹅绒"),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage("暂无本地代理"),
    "appRegion": MessageLookupByLibrary.simpleMessage("应用地区"),
    "appearanceBackground": MessageLookupByLibrary.simpleMessage("背景"),
    "appearanceInterface": MessageLookupByLibrary.simpleMessage("界面"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("主题"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage("追加系统DNS"),
    "applicationSettings": MessageLookupByLibrary.simpleMessage("应用设置"),
    "applied": MessageLookupByLibrary.simpleMessage("已应用"),
    "applyNow": MessageLookupByLibrary.simpleMessage("立即应用"),
    "authentication": MessageLookupByLibrary.simpleMessage("认证"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "认证开启后，使用本地代理端口需要账号密码。",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "认证启用时，系统代理不生效。",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("授权"),
    "authorized": MessageLookupByLibrary.simpleMessage("已授权"),
    "auto": MessageLookupByLibrary.simpleMessage("自动"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage("自动检查更新"),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage("自动关闭连接"),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "自动关闭连接会在切换代理后断开已有连接。",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage("自动包含"),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("自启动"),
    "autoRun": MessageLookupByLibrary.simpleMessage("自动运行"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage("自动运行会在打开应用时启动代理。"),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage("自动设置系统DNS"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("自动更新"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage("自动更新间隔"),
    "back": MessageLookupByLibrary.simpleMessage("返回"),
    "backgroundBlur": MessageLookupByLibrary.simpleMessage("背景模糊"),
    "backup": MessageLookupByLibrary.simpleMessage("备份"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage("备份与恢复"),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "该备份来自更高版本的应用，请先更新应用再恢复",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("备份成功"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("基础信息"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("基础策略"),
    "batchAdd": MessageLookupByLibrary.simpleMessage("批量添加"),
    "batchImport": MessageLookupByLibrary.simpleMessage("批量导入"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage("每行一个链接"),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage("每行一项，也可用逗号分隔"),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage("每行一条，键和值之间用空格分隔"),
    "batchPreviewTip": m4,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage("每行一个URL"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "忽略电池优化可保证应用在后台运行。",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("绑定"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("黑名单模式"),
    "blockConnection": MessageLookupByLibrary.simpleMessage("阻止连接"),
    "brightness": MessageLookupByLibrary.simpleMessage("亮度"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("排除域名"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "排除域名仅在系统代理启用时生效。",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage("绕过私有路由地址"),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "开启绕过私有路由地址后，局域网、回环和组播地址不经过虚拟网卡。",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("缓存"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("缓存算法"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage("缓存已损坏，是否清空？"),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("缓存大小"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "请在系统设置中允许访问相机以扫描二维码，或从相册选择二维码图片。",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage("需要相机权限"),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage("相机不可用"),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("取消全选"),
    "cannotSave": MessageLookupByLibrary.simpleMessage("无法保存"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "切换代理失败，已恢复上一次的选择",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage("重大变更"),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("新功能"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("问题修复"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("性能优化"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("已回滚"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage("校验 TLS 证书"),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "关闭证书校验后，订阅和备份可能遭中间人攻击。",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("检查更新"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage("当前应用已经是最新版了"),
    "cipher": MessageLookupByLibrary.simpleMessage("加密方式"),
    "clearData": MessageLookupByLibrary.simpleMessage("清除数据"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "将删除所有配置、设置和本地数据，随后关闭应用。重新打开即可从头开始。",
    ),
    "clearDataFailed": m5,
    "clearDnsCache": MessageLookupByLibrary.simpleMessage("清除DNS缓存"),
    "clearDnsCacheFailed": MessageLookupByLibrary.simpleMessage("清除DNS缓存失败"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("清除搜索"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage("客户端指纹"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("导出剪贴板"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("剪贴板导入"),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "无法复制到剪贴板，所选内容可能过大",
    ),
    "close": MessageLookupByLibrary.simpleMessage("关闭"),
    "closeConnections": MessageLookupByLibrary.simpleMessage("关闭连接"),
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "暂停 VPN 时断开所有现有连接",
    ),
    "color": MessageLookupByLibrary.simpleMessage("颜色"),
    "colorContrast": MessageLookupByLibrary.simpleMessage("对比度"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("配色风格"),
    "columns": MessageLookupByLibrary.simpleMessage("列数"),
    "compact": MessageLookupByLibrary.simpleMessage("紧凑"),
    "compatible": MessageLookupByLibrary.simpleMessage("兼容模式"),
    "confirm": MessageLookupByLibrary.simpleMessage("确定"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage("确定要清除所有数据？"),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "确定要删除当前策略组吗？",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage("确定要退出当前窗口吗？"),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage("确定要强制崩溃核心？"),
    "congestionControl": MessageLookupByLibrary.simpleMessage("拥塞控制"),
    "congestionController": MessageLookupByLibrary.simpleMessage("TCP 拥塞控制"),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 拥塞控制仅在 mips 栈生效。",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("已连接"),
    "connecting": MessageLookupByLibrary.simpleMessage("连接中…"),
    "connection": MessageLookupByLibrary.simpleMessage("连接"),
    "connectionStats": MessageLookupByLibrary.simpleMessage("连接统计"),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "实时连接、最近请求、DNS查询",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("连接"),
    "connectivity": MessageLookupByLibrary.simpleMessage("连通性："),
    "content": MessageLookupByLibrary.simpleMessage("内容"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage("内容不能为空"),
    "contrastHigh": MessageLookupByLibrary.simpleMessage("高"),
    "contrastMedium": MessageLookupByLibrary.simpleMessage("中"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage("控制全局附加规则"),
    "copy": MessageLookupByLibrary.simpleMessage("复制"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("复制环境变量"),
    "copyLink": MessageLookupByLibrary.simpleMessage("复制链接"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("复制成功"),
    "core": MessageLookupByLibrary.simpleMessage("内核"),
    "coreArchitecture": MessageLookupByLibrary.simpleMessage("架构"),
    "coreBlockedByPolicyTip": m6,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows 智能应用控制拦截了未签名的 ReClashCore.exe。请打开 Windows 安全中心 → 应用和浏览器控制 → 智能应用控制设置，选择「关闭」后重新启动 ReClash。智能应用控制关闭后无法再开启，除非重装 Windows。",
    ),
    "coreBuildTags": MessageLookupByLibrary.simpleMessage("构建标志"),
    "coreBuildTime": MessageLookupByLibrary.simpleMessage("构建时间"),
    "coreEnvironment": MessageLookupByLibrary.simpleMessage("环境"),
    "coreExecutable": MessageLookupByLibrary.simpleMessage("内核可执行文件"),
    "coreInfoUnavailable": MessageLookupByLibrary.simpleMessage("无法读取内核信息"),
    "coreLaunchMode": MessageLookupByLibrary.simpleMessage("运行方式"),
    "coreLocation": MessageLookupByLibrary.simpleMessage("位置"),
    "coreModeElevated": MessageLookupByLibrary.simpleMessage("受管理的提权进程"),
    "coreModeHelper": MessageLookupByLibrary.simpleMessage("通过 Helper 运行"),
    "coreModeLibrary": MessageLookupByLibrary.simpleMessage("进程内动态库"),
    "coreModePrivilegedHelper": MessageLookupByLibrary.simpleMessage(
      "通过已签名Helper管理的进程",
    ),
    "coreModeProcess": MessageLookupByLibrary.simpleMessage("独立进程"),
    "coreOpenRuntimeConfig": MessageLookupByLibrary.simpleMessage("打开运行时配置"),
    "corePlatform": MessageLookupByLibrary.simpleMessage("平台"),
    "coreRunning": MessageLookupByLibrary.simpleMessage("运行中"),
    "coreRuntimeConfig": MessageLookupByLibrary.simpleMessage("运行时配置"),
    "coreRuntimeConfigDescription": MessageLookupByLibrary.simpleMessage(
      "应用设置和脚本后生成的配置。只读。",
    ),
    "coreRuntimeConfigReadFailed": MessageLookupByLibrary.simpleMessage(
      "无法读取运行时配置",
    ),
    "coreStarting": MessageLookupByLibrary.simpleMessage("启动中…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("核心状态"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("已停止"),
    "coreWorkingDirectory": MessageLookupByLibrary.simpleMessage("数据目录"),
    "country": MessageLookupByLibrary.simpleMessage("区域"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("检测到崩溃"),
    "crashDetectedTip": m7,
    "crashTest": MessageLookupByLibrary.simpleMessage("崩溃测试"),
    "create": MessageLookupByLibrary.simpleMessage("创建"),
    "createProfileFromUrlTip": m8,
    "creationTime": MessageLookupByLibrary.simpleMessage("创建时间"),
    "creditByeDpi": MessageLookupByLibrary.simpleMessage("DPI 绕过"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage("应用基础"),
    "creditFlClashPatched": MessageLookupByLibrary.simpleMessage("额外功能"),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage("机场功能与思路"),
    "creditMihomo": MessageLookupByLibrary.simpleMessage("代理内核"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage("含启动键，不可移除"),
    "custom": MessageLookupByLibrary.simpleMessage("自定义"),
    "customColor": MessageLookupByLibrary.simpleMessage("自定义颜色"),
    "customImportDroppedIncludeAll": m9,
    "customImportDroppedSubRules": m10,
    "customIssueCoreRejected": m11,
    "customIssueDialerLoop": m12,
    "customIssueDuplicateName": m13,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage("名称为空"),
    "customIssueGroupLoop": m14,
    "customIssueInvalidEmptyFallback": m15,
    "customIssueInvalidFilter": m16,
    "customIssueMissingDialer": m17,
    "customIssueMissingProviders": m18,
    "customIssueMissingProxies": m19,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "未选择任何代理或代理集，内核会拒绝该策略组",
    ),
    "customIssueReservedName": m20,
    "customIssuesSummary": m21,
    "customProfile": MessageLookupByLibrary.simpleMessage("自定义"),
    "customProfileResources": MessageLookupByLibrary.simpleMessage("自定义配置资源"),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "自定义配置资源是你自行添加的代理、规则集、筛选与图标集，供自定义配置引用。",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("剪切"),
    "dark": MessageLookupByLibrary.simpleMessage("深色"),
    "dashboard": MessageLookupByLibrary.simpleMessage("仪表盘"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage("可添加"),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "保存更改失败，已回滚",
    ),
    "daysAgo": m22,
    "daysAgoShort": m23,
    "defaultSelected": MessageLookupByLibrary.simpleMessage("默认选中"),
    "defaultText": MessageLookupByLibrary.simpleMessage("默认"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "配置必须是包含 name 和 type 的 YAML 映射",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("延迟"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("失败"),
    "delayTest": MessageLookupByLibrary.simpleMessage("延迟测试"),
    "delayTestTimeout": MessageLookupByLibrary.simpleMessage("延迟测试超时"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "deleteMultipTip": m24,
    "deleteTip": m25,
    "desc": MessageLookupByLibrary.simpleMessage(
      "基于ClashMeta的多平台代理客户端，简单易用，开源无广告。",
    ),
    "desktopAuthorizationAgentUnavailable":
        MessageLookupByLibrary.simpleMessage("图形授权代理不可用。请在当前桌面会话中启动代理后重试。"),
    "desktopAuthorizationCancelled": MessageLookupByLibrary.simpleMessage(
      "授权已取消。TUN未启动。",
    ),
    "desktopAuthorizationDenied": MessageLookupByLibrary.simpleMessage(
      "授权未获批准。TUN未启动。",
    ),
    "desktopAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "TUN需要授权。请启动连接或启用TUN以进行授权。",
    ),
    "desktopAuthorizationTimeout": MessageLookupByLibrary.simpleMessage(
      "授权超时。请使用连接按钮重试。",
    ),
    "desktopBootstrapFailed": MessageLookupByLibrary.simpleMessage(
      "已授权的Core未能完成经过验证的启动。请检查软件包和系统日志。",
    ),
    "desktopBundleInvalid": MessageLookupByLibrary.simpleMessage(
      "Core或Helper未通过完整性验证。请重新安装完整的ReClash软件包。",
    ),
    "desktopHelperApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "请在系统设置 → 通用 → 登录项与扩展中允许ReClash Helper，然后重试。",
    ),
    "desktopHelperProtocolMismatch": MessageLookupByLibrary.simpleMessage(
      "已安装的 Helper 使用不同的协议。请检查是否存在其他安装或服务覆盖配置，然后重新安装完整的软件包。",
    ),
    "desktopHelperRegistrationConflict": MessageLookupByLibrary.simpleMessage(
      "无法安全替换现有的 Linux Helper 注册。请检查服务归属及注册信息；重复授权无法解决此冲突。",
    ),
    "desktopHelperSystemdFailed": MessageLookupByLibrary.simpleMessage(
      "systemd 无法启动 TUN Helper。请查看服务日志；安装程序已尝试恢复先前的安装。",
    ),
    "desktopHelperSystemdRequired": MessageLookupByLibrary.simpleMessage(
      "TUN 需要由 systemd 管理的 Linux 会话。此系统无法运行网络 Helper。",
    ),
    "desktopHelperUnavailable": MessageLookupByLibrary.simpleMessage(
      "TUN Helper不可用。请检查已安装的软件包和服务后重试。",
    ),
    "desktopLaunchPending": MessageLookupByLibrary.simpleMessage(
      "上一次授权或Core关闭尚未完成。请等待完成后重试。",
    ),
    "desktopSigningRequired": MessageLookupByLibrary.simpleMessage(
      "TUN需要正确签名的ReClash应用和Helper。未签名或ad-hoc签名的构建无法授权。",
    ),
    "desktopTunNotReady": MessageLookupByLibrary.simpleMessage(
      "Core已启动，但TUN适配器尚未就绪。使用TUN前请检查Core日志。",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("目标地址"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("目标地理定位"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("目标IP ASN"),
    "details": m26,
    "detectionTip": MessageLookupByLibrary.simpleMessage("依赖第三方api，仅供参考"),
    "developerMode": MessageLookupByLibrary.simpleMessage("开发者模式"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage("开发者模式已启用。"),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("拨号代理"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "拨号代理为连接 NTP 服务器使用的出站。",
    ),
    "dialerProxyLoopStopped": m27,
    "direct": MessageLookupByLibrary.simpleMessage("直连"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage("禁用ICMP转发"),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "禁用 ICMP 转发后由虚拟网卡直接应答 ping，ping 将不再显示真实延迟。",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage("禁用 TCP 保持活动"),
    "disableUDP": MessageLookupByLibrary.simpleMessage("禁用UDP"),
    "disabled": MessageLookupByLibrary.simpleMessage("已关闭"),
    "discardChanges": MessageLookupByLibrary.simpleMessage("是否放弃更改？"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("免责声明"),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "一旦你安装、复制或使用本软件，即视为你已阅读并同意本声明的全部内容。如你不同意本声明的任何条款，请立即停止使用并卸载本软件。",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage("接受声明"),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "我已阅读并理解此声明",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "为确认你已知悉，请阅读以下声明并勾选下方选项：",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage("确认声明"),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "开发者有权随版本更新修改本声明，修改后的内容随新版本发布即生效。你在更新后继续使用本软件，即视为接受修改后的声明。",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage("声明变更"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "在使用 ReClash（以下简称“本软件”）前，请仔细阅读并充分理解本声明的全部内容。点击“同意”即表示你已阅读、理解并接受以下全部条款；如不同意，请点击“退出”并停止使用本软件。",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "在适用法律允许的最大范围内，开发者及所有贡献者均不对因使用或无法使用本软件而产生的任何直接、间接、偶然、特殊、惩罚性或后果性损害承担责任，包括但不限于数据丢失、设备损坏、网络异常、业务中断、利润损失或因此引起的任何法律纠纷，即使已被告知发生此类损害的可能性。",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage("责任限制"),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "本软件以 GPL-3.0 协议开源。你可以在遵守该协议的前提下自由使用、修改和分发本软件，但须同样以 GPL-3.0 协议开源并保留原作者的版权声明。\n\n本软件包含的第三方组件（包括 Clash.Meta 内核）分别遵循其各自的开源协议。基于本软件修改或分发的版本所产生的任何问题，与原作者无关。",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage("开源协议"),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "本软件自身不提供任何代理服务器、节点、订阅、机场或网络接入服务，也不与任何此类服务的提供者存在合作、代理或担保关系。",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "本软件不会收集或上传你的订阅地址、节点信息、配置内容、访问的网站、连接记录、流量内容和日志，这些数据仅保存在你的设备本地，开发者无法获取。\n\n本软件只会在你使用相应功能时访问外部网络，例如更新订阅时访问你提供的订阅地址、检查更新时访问 GitHub。\n\n本软件在所有平台上均未集成任何数据统计或崩溃上报服务。",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage("数据收集与隐私"),
    "disclaimerReadToEnd": MessageLookupByLibrary.simpleMessage("请阅读至底部"),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "你应自行确认使用本软件在你所在国家或地区是合法的，并对使用本软件的全部行为及其后果独立承担法律责任。\n\n你导入的订阅、节点与配置由你自行选择和判断，其来源是否合法、内容是否安全、服务是否稳定，均由你与相关提供者自行负责。",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "用户责任",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage("在此输入上述声明"),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "与声明内容不一致",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "为确认你已知悉，请在下方输入框中完整复述以下声明：",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage("复述声明"),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "本软件是基于 Clash.Meta（mihomo）内核的开源网络代理客户端，仅提供配置管理、规则分流与流量转发等本地工具功能。",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage("软件性质"),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "订阅链接、配置文件、规则集、脚本、外部资源及外部链接均由第三方提供，开发者无法也不会对其合法性、准确性、安全性和可用性进行审查或担保。\n\n因使用第三方内容导致的数据泄露、财产损失、账号封禁或其他任何损失，由你与第三方自行解决，开发者不承担任何责任。",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage("第三方内容"),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "本软件仅供学习交流、技术研究等非商业用途。严禁将本软件用于任何商业目的，包括但不限于付费分发、捆绑销售、作为商业服务的组成部分或以本软件名义开展经营活动；任何商业行为均与本软件及其开发者无关。\n\n严禁将本软件用于违反你所在国家或地区法律法规的活动，包括但不限于绕过依法设置的网络访问限制、传播违法信息、实施网络攻击或侵犯他人合法权益。",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage("使用限制"),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "本软件按“现状”和“可用”的原则提供，不附带任何明示或默示的担保，包括但不限于适销性、特定用途适用性、不侵权以及持续可用、无错误、无安全漏洞的担保。\n\n开发者不保证本软件能满足你的需求，也不保证本软件的运行不会中断或不会出现错误。",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage("无担保声明"),
    "disconnected": MessageLookupByLibrary.simpleMessage("已断开"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage("发现新版本"),
    "dnsCacheCleared": MessageLookupByLibrary.simpleMessage("DNS缓存已清除"),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "未添加时劫持所有发往 53 端口的 DNS 请求（any:53）。",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS劫持"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS模式"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "添加的项会覆写所有 URL 和文件配置的 DNS，未添加的项沿用配置自身的设置。自定义配置的 DNS 在其内容中设置。",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS查询"),
    "dnsRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "将删除所有 DNS 覆写，并重新设置所选地区的 DNS 服务器。",
    ),
    "docked": MessageLookupByLibrary.simpleMessage("固定"),
    "domain": MessageLookupByLibrary.simpleMessage("域名"),
    "done": MessageLookupByLibrary.simpleMessage("完成"),
    "download": MessageLookupByLibrary.simpleMessage("下载"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage("下行带宽"),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage("正在下载更新"),
    "duration": MessageLookupByLibrary.simpleMessage("时长"),
    "edit": MessageLookupByLibrary.simpleMessage("编辑"),
    "editDashboard": MessageLookupByLibrary.simpleMessage("编辑仪表盘"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage("编辑全局规则"),
    "editNetwork": MessageLookupByLibrary.simpleMessage("编辑网络"),
    "editProxy": MessageLookupByLibrary.simpleMessage("编辑代理"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("编辑策略组"),
    "editRule": MessageLookupByLibrary.simpleMessage("编辑规则"),
    "editSsid": MessageLookupByLibrary.simpleMessage("编辑SSID"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage("编辑器不可用"),
    "elapsed": MessageLookupByLibrary.simpleMessage("耗时"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage("空组兜底"),
    "emptyTip": m28,
    "en": MessageLookupByLibrary.simpleMessage("英语"),
    "enabled": MessageLookupByLibrary.simpleMessage("已开启"),
    "enterManually": MessageLookupByLibrary.simpleMessage("手动输入"),
    "entries": MessageLookupByLibrary.simpleMessage("个条目"),
    "error": MessageLookupByLibrary.simpleMessage("错误"),
    "errorDetails": MessageLookupByLibrary.simpleMessage("错误详情"),
    "es": MessageLookupByLibrary.simpleMessage("西班牙语"),
    "exclude": MessageLookupByLibrary.simpleMessage("从最近任务中隐藏"),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage("排除目标端口"),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "发往这些目标端口的流量不经过虚拟网卡。",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage("排除筛选"),
    "excludeInterface": MessageLookupByLibrary.simpleMessage("排除网卡"),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "从这些网卡（如 docker0）进入的流量不经过虚拟网卡。",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage("排除源端口"),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "源端口为这些端口的流量不经过虚拟网卡。",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("排除SSIDs"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "连接到被排除 SSID 的 Wi-Fi 时，将会自动切换应用运行状态。",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage("排除用户 ID"),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "这些用户 ID 的进程产生的流量不经过虚拟网卡。",
    ),
    "existsTip": m29,
    "exit": MessageLookupByLibrary.simpleMessage("退出"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("退出全屏"),
    "exitNodes": MessageLookupByLibrary.simpleMessage("出口节点"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("预期状态"),
    "expireTime": MessageLookupByLibrary.simpleMessage("到期时间"),
    "exportFile": MessageLookupByLibrary.simpleMessage("导出文件"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("导出日志"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("导出成功"),
    "extend": MessageLookupByLibrary.simpleMessage("扩展"),
    "extendMode": MessageLookupByLibrary.simpleMessage("扩展模式"),
    "extendScript": MessageLookupByLibrary.simpleMessage("扩展脚本"),
    "externalController": MessageLookupByLibrary.simpleMessage("外部控制器"),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "外部控制器开启后，可通过 9090 端口控制内核。",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage("外部控制器密钥"),
    "externalLink": MessageLookupByLibrary.simpleMessage("外部链接"),
    "extra": MessageLookupByLibrary.simpleMessage("其他"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("超大"),
    "fade": MessageLookupByLibrary.simpleMessage("淡入"),
    "failedCount": m30,
    "failedItem": m31,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IP过滤"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage("Fake-IP过滤模式"),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "Fake-IP 过滤模式中，blacklist 排除匹配项，whitelist 仅用于匹配项，rule 按规则匹配。",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP范围"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage("Fake-IP范围（IPv6）"),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("Fake-IP TTL"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Fallback过滤"),
    "file": MessageLookupByLibrary.simpleMessage("文件"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage("文件有修改，是否保存修改"),
    "filter": MessageLookupByLibrary.simpleMessage("筛选"),
    "filters": MessageLookupByLibrary.simpleMessage("筛选"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("查找进程"),
    "floating": MessageLookupByLibrary.simpleMessage("悬浮"),
    "followProfile": MessageLookupByLibrary.simpleMessage("跟随配置"),
    "followSystem": MessageLookupByLibrary.simpleMessage("跟随系统"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("字体"),
    "fontSize": MessageLookupByLibrary.simpleMessage("大小"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage("强制DNS映射"),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "强制 DNS 映射对通过 DNS 映射得到域名的连接也进行嗅探。",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("强制嗅探域名"),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "强制嗅探域名中的域名同样会被嗅探，其余已有域名的连接不嗅探。",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage("您确定要强制重启核心吗？"),
    "fr": MessageLookupByLibrary.simpleMessage("法语"),
    "general": MessageLookupByLibrary.simpleMessage("常规"),
    "generalOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "添加的项会覆写所有配置的对应设置，未添加的项沿用配置自身的设置，配置未设置时使用内核默认值。",
    ),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m32,
    "geoUpdated": m33,
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo低内存模式"),
    "global": MessageLookupByLibrary.simpleMessage("全局"),
    "go": MessageLookupByLibrary.simpleMessage("前往"),
    "goDownload": MessageLookupByLibrary.simpleMessage("前往下载"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage("前往配置附加规则"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage("前往配置脚本"),
    "gratitude": MessageLookupByLibrary.simpleMessage("致谢"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage("ReClash 建立在他们的工作之上"),
    "grid": MessageLookupByLibrary.simpleMessage("网格"),
    "groupCount": m34,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("个"),
    "groupTimeoutCount": m35,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage("是否缓存修改"),
    "hashByInUser": MessageLookupByLibrary.simpleMessage("按入站用户哈希"),
    "healthCheck": MessageLookupByLibrary.simpleMessage("健康检查"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper 服务不可用，无法启用 TUN 模式，请重新安装 ReClash。",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("十六进制"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("从列表中隐藏"),
    "hideIp": MessageLookupByLibrary.simpleMessage("隐藏 IP"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("隐藏密码"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage("隐藏超时代理"),
    "hideTimeoutProxiesDesc": MessageLookupByLibrary.simpleMessage(
      "不显示上次延迟测试超时的代理",
    ),
    "hopInterval": MessageLookupByLibrary.simpleMessage("跳跃间隔"),
    "host": MessageLookupByLibrary.simpleMessage("主机"),
    "hostname": MessageLookupByLibrary.simpleMessage("主机名"),
    "hotkeyClearAll": MessageLookupByLibrary.simpleMessage("全部清除"),
    "hotkeyClearAllTip": MessageLookupByLibrary.simpleMessage("移除所有快捷键组合？"),
    "hotkeyCompositorConfig": MessageLookupByLibrary.simpleMessage("合成器配置"),
    "hotkeyCompositorConfigDesc": MessageLookupByLibrary.simpleMessage(
      "也可以在合成器配置中添加包含语句。这些文件会随 ReClash 的组合键设置更新，并在录制按键时暂时清空。桌面配置不会被自动修改；如有绑定冲突，请在桌面配置中解决。",
    ),
    "hotkeyConflictWith": m36,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "全局快捷键在窗口隐藏时依然生效，点击操作即可录制组合键。",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage("桌面快捷键"),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "在桌面设置中将命令分配给自定义快捷键。ReClash 必须处于运行状态，但窗口可以隐藏。这些全局绑定由桌面设置管理。",
    ),
    "hotkeyExportSkipped": m37,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "合成器配置文件不可用。仍可使用上方的桌面命令。",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "这些组合键仅在应用窗口获得焦点时生效。要使用全局快捷键，请在下方设置桌面命令。",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("快捷键管理"),
    "hotkeyNeedsModifier": m38,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("未设置"),
    "hotkeyRestoreDefaults": MessageLookupByLibrary.simpleMessage("恢复默认"),
    "hotkeyRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "用默认值替换所有组合？",
    ),
    "hotkeySafeModeDesc": MessageLookupByLibrary.simpleMessage(
      "安全模式会停用快捷键操作，但仍可编辑快捷键绑定。",
    ),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "未能注册，可能已被其他应用占用",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("小时"),
    "hoursAgo": m39,
    "hoursAgoShort": m40,
    "hue": MessageLookupByLibrary.simpleMessage("色相"),
    "icon": MessageLookupByLibrary.simpleMessage("图标"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("图标记录"),
    "iconSets": MessageLookupByLibrary.simpleMessage("图标集"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "暂无图标集，可在「自定义配置资源 → 图标集」中添加",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("图标样式"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("色块"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("隐藏"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("纯图标"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("图标链接"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage("忽略电池优化"),
    "import": MessageLookupByLibrary.simpleMessage("导入"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage("此文件不是可导入的配置"),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "导入会替换此配置现有的策略组、规则和设置",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage("通过文件导入"),
    "importFromLink": MessageLookupByLibrary.simpleMessage("从链接导入"),
    "importUrl": MessageLookupByLibrary.simpleMessage("通过URL导入"),
    "inbound": MessageLookupByLibrary.simpleMessage("入站"),
    "includeInterface": MessageLookupByLibrary.simpleMessage("包含网卡"),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "只有从包含网卡进入的流量经过虚拟网卡，设置后排除网卡不再生效。",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage("包含用户 ID"),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "只有这些用户 ID 的进程产生的流量经过虚拟网卡。",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("长期有效"),
    "init": MessageLookupByLibrary.simpleMessage("初始化"),
    "initFailed": MessageLookupByLibrary.simpleMessage("启动失败"),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "ReClash 启动时出错，无法继续运行。可以复制错误详情用于反馈；如果问题反复出现，清除数据后通常可以重新启动。",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("发起方"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("发起"),
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
    "installedFonts": MessageLookupByLibrary.simpleMessage("已安装字体"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("智能选择"),
    "interfaceName": MessageLookupByLibrary.simpleMessage("网卡名称"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "网卡名称为出站连接使用的网卡。",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage("出站网卡"),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("清空"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("自定义"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage("跟随配置"),
    "internet": MessageLookupByLibrary.simpleMessage("互联网"),
    "interval": MessageLookupByLibrary.simpleMessage("间隔"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("内网 IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage("无效备份文件"),
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "请输入 CIDR 格式的 IP 段，如 192.168.0.0/16",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "DSCP 标记不能超过 63",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage("请输入域名或 IP 地址"),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage("不是有效的图标集"),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage("不是有效的订阅链接或代理分享链接"),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "请输入地址和端口，如 0.0.0.0:1053",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "仅支持 tcp 或 udp",
    ),
    "invalidPolicy": m41,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "请输入端口或范围，如 443 或 8000-9000",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "该二维码不包含配置文件链接",
    ),
    "invalidProxy": m42,
    "invalidProxyProvider": m43,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "请输入数字或范围，如 80 或 8000-9000，多个用 / 分隔",
    ),
    "invalidRuleSet": m44,
    "invalidSsid": MessageLookupByLibrary.simpleMessage(
      "SSID 不能超过 32 个 UTF-8 字节",
    ),
    "invalidSubRule": m45,
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP 地址"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("滥用记录"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("代理"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("命中标记"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("组织"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage("类型查询失败"),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("优"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("等级"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("普通"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("重新查询"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("风险"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("质量"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("采用来源"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("各来源"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage("出站 IP 不一致"),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("无法判定类型"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage("限流"),
    "ipType": MessageLookupByLibrary.simpleMessage("类型"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("商业"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("机房"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("移动网络"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("住宅"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("类型未知"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("IP 版本"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage("开启 IPv6 后才会接收 IPv6 流量。"),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "开启 IPv6 后，VPN 允许 IPv6 入站。",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage("IPv6超时（毫秒）"),
    "itemsCount": m46,
    "ja": MessageLookupByLibrary.simpleMessage("日语"),
    "justNow": MessageLookupByLibrary.simpleMessage("刚刚"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage("TCP 保持活动空闲时间"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage("TCP保持活动间隔"),
    "key": MessageLookupByLibrary.simpleMessage("键"),
    "kk": MessageLookupByLibrary.simpleMessage("哈萨克语"),
    "ko": MessageLookupByLibrary.simpleMessage("韩语"),
    "label": MessageLookupByLibrary.simpleMessage("标签"),
    "language": MessageLookupByLibrary.simpleMessage("语言"),
    "large": MessageLookupByLibrary.simpleMessage("大"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("上次更新"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage("启动未完成"),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "应用上次在启动过程中意外退出。已跳过本次自动配置，你可以手动启动重试。",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("布局"),
    "license": MessageLookupByLibrary.simpleMessage("许可证"),
    "licenses": MessageLookupByLibrary.simpleMessage("开源许可"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage("应用内置的软件包"),
    "light": MessageLookupByLibrary.simpleMessage("浅色"),
    "lineIssueTip": m47,
    "lineWrap": MessageLookupByLibrary.simpleMessage("自动换行"),
    "link": MessageLookupByLibrary.simpleMessage("链接"),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("液态玻璃"),
    "list": MessageLookupByLibrary.simpleMessage("列表"),
    "listen": MessageLookupByLibrary.simpleMessage("监听"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage("监听路由标记"),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "监听路由标记仅在 Linux 生效。",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage("实时连接"),
    "loading": MessageLookupByLibrary.simpleMessage("加载中…"),
    "local": MessageLookupByLibrary.simpleMessage("本地"),
    "localImage": MessageLookupByLibrary.simpleMessage("本地图片"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "本地网络权限被拒绝：已改用 gvisor 栈，局域网无法访问。",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage("本地代理"),
    "locationPermission": MessageLookupByLibrary.simpleMessage("位置权限"),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "位置权限已被拒绝，无法获取当前 Wi-Fi 名称。请前往系统设置手动开启位置权限。",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "根据系统要求，获取Wi-Fi名称需要您授予位置权限。Android 上请选择“始终允许”，否则应用在后台时无法获取 Wi-Fi 名称。",
    ),
    "locationPermissionGuide": m48,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "需要位置权限",
    ),
    "log": MessageLookupByLibrary.simpleMessage("日志"),
    "logLevel": MessageLookupByLibrary.simpleMessage("日志等级"),
    "logcat": MessageLookupByLibrary.simpleMessage("日志捕获"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage("关闭日志捕获会隐藏日志入口。"),
    "logs": MessageLookupByLibrary.simpleMessage("日志"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage("日志与诊断"),
    "logsTest": MessageLookupByLibrary.simpleMessage("日志测试"),
    "loopback": MessageLookupByLibrary.simpleMessage("UWP 回环解锁"),
    "loose": MessageLookupByLibrary.simpleMessage("宽松"),
    "maintainer": MessageLookupByLibrary.simpleMessage("维护者"),
    "matchCase": MessageLookupByLibrary.simpleMessage("区分大小写"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("匹配来源IP"),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("最大失败次数"),
    "maxLengthTip": m49,
    "maximize": MessageLookupByLibrary.simpleMessage("最大化"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage("常驻内存"),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage("应用及共享"),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("堆内存空闲"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage("堆内存使用中"),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage("内核未运行"),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage("运行时开销"),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage("协程栈"),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "基于进程常驻内存估算，可能与系统显示的数值不同。",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "内核与应用运行在同一进程，内核部分按运行时统计估算，其余计入应用及共享内存。",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("内存信息"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage("应用与内核占用的内存"),
    "memoryReleased": MessageLookupByLibrary.simpleMessage("内存已释放"),
    "memoryReleasedSize": m50,
    "messageTest": MessageLookupByLibrary.simpleMessage("消息测试"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("这是一条消息。"),
    "minimize": MessageLookupByLibrary.simpleMessage("最小化"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("退出时最小化"),
    "minutes": MessageLookupByLibrary.simpleMessage("分钟"),
    "minutesAgo": m51,
    "minutesAgoShort": m52,
    "mixedPort": MessageLookupByLibrary.simpleMessage("混合端口"),
    "mode": MessageLookupByLibrary.simpleMessage("模式"),
    "monochromeIcon": MessageLookupByLibrary.simpleMessage("单色图标"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("单色"),
    "monthsAgo": m53,
    "monthsAgoShort": m54,
    "more": MessageLookupByLibrary.simpleMessage("更多"),
    "name": MessageLookupByLibrary.simpleMessage("名称"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("底栏"),
    "navigationLabels": MessageLookupByLibrary.simpleMessage("标签文字"),
    "navigationLabelsAlways": MessageLookupByLibrary.simpleMessage("始终"),
    "navigationLabelsNever": MessageLookupByLibrary.simpleMessage("从不"),
    "navigationLabelsSelected": MessageLookupByLibrary.simpleMessage("选中时"),
    "navigationLayout": MessageLookupByLibrary.simpleMessage("导航"),
    "navigationLayoutBar": MessageLookupByLibrary.simpleMessage("标签栏"),
    "navigationLayoutSidebar": MessageLookupByLibrary.simpleMessage("侧边栏"),
    "network": MessageLookupByLibrary.simpleMessage("网络"),
    "networkAccessDeniedError": m55,
    "networkBadResponseError": m56,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage("请求已取消"),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "无法连接到服务器，请检查网络连接或代理设置",
    ),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID（家庭 Wi-Fi）或网段（192.168.1.0/24）",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "无法解析服务器地址，请确认链接正确且 DNS 可用",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("网络名称"),
    "networkNotFoundError": m57,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "请求过于频繁（HTTP 429），请稍后再试",
    ),
    "networkRequestFailed": m58,
    "networkRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "绕过列表和 TUN MTU 将恢复为所选地区的默认值。",
    ),
    "networkSecret": MessageLookupByLibrary.simpleMessage("网络密码"),
    "networkServerError": m59,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("网络速度"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage("网络接管"),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "请求超时，请检查网络或代理后重试",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "安全连接失败，服务器证书可能无效，或连接被拦截",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("网络类型"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("下一个匹配"),
    "no": MessageLookupByLibrary.simpleMessage("否"),
    "noData": MessageLookupByLibrary.simpleMessage("暂无数据"),
    "noInfo": MessageLookupByLibrary.simpleMessage("暂无信息"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage("不再提示"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("无网络"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("无网络应用"),
    "noResolve": MessageLookupByLibrary.simpleMessage("不解析IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage("不解析主机名"),
    "noSearchResults": MessageLookupByLibrary.simpleMessage("没有匹配的结果"),
    "nodes": MessageLookupByLibrary.simpleMessage("节点"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage("该外部资源不是文本文件"),
    "none": MessageLookupByLibrary.simpleMessage("无"),
    "notRunning": MessageLookupByLibrary.simpleMessage("未运行"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage("当前代理组无法选中"),
    "notTrustedNow": MessageLookupByLibrary.simpleMessage("当前网络不受信任"),
    "notification": MessageLookupByLibrary.simpleMessage("通知"),
    "notificationActive": MessageLookupByLibrary.simpleMessage("保护已启用"),
    "notificationAddComponent": MessageLookupByLibrary.simpleMessage("添加组件"),
    "notificationAutomaticGroup": MessageLookupByLibrary.simpleMessage("自动策略组"),
    "notificationBlockedNoServerGroup": MessageLookupByLibrary.simpleMessage(
      "未解析到服务器策略组，该行不会显示",
    ),
    "notificationComponents": MessageLookupByLibrary.simpleMessage("通知组件"),
    "notificationComponentsDesc": MessageLookupByLibrary.simpleMessage(
      "使用实时状态组件构建通知。",
    ),
    "notificationComponentsEmpty": MessageLookupByLibrary.simpleMessage(
      "尚未添加组件",
    ),
    "notificationComponentsEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "没有组件时，通知仅显示保护状态。",
    ),
    "notificationContent": MessageLookupByLibrary.simpleMessage("内容"),
    "notificationCurrentServer": MessageLookupByLibrary.simpleMessage("当前服务器"),
    "notificationDelivery": MessageLookupByLibrary.simpleMessage(
      "Android 通知投递",
    ),
    "notificationDeliveryChecking": MessageLookupByLibrary.simpleMessage(
      "正在检查 Android 通知权限",
    ),
    "notificationDeliveryPermissionDisabled":
        MessageLookupByLibrary.simpleMessage("ReClash 的通知已被阻止"),
    "notificationDeliveryReady": MessageLookupByLibrary.simpleMessage("可以投递通知"),
    "notificationDeliveryServiceDisabled": MessageLookupByLibrary.simpleMessage(
      "ReClash 服务渠道已被停用",
    ),
    "notificationDeliverySubscriptionDisabled":
        MessageLookupByLibrary.simpleMessage("订阅提醒渠道已被停用"),
    "notificationHideIdleSpeed": MessageLookupByLibrary.simpleMessage(
      "空闲时隐藏速度",
    ),
    "notificationHideSensitive": MessageLookupByLibrary.simpleMessage(
      "在锁屏上隐藏敏感信息",
    ),
    "notificationHideSensitiveDesc": MessageLookupByLibrary.simpleMessage(
      "服务通知和提醒遵循 Android 的锁屏隐私设置。解锁后仍会显示详细信息。",
    ),
    "notificationLevelDescription": MessageLookupByLibrary.simpleMessage(
      "详细模式显示实时信息和停止按钮。最简模式仅显示保护状态。",
    ),
    "notificationNetworkSpeed": MessageLookupByLibrary.simpleMessage("网络速度"),
    "notificationPrivacy": MessageLookupByLibrary.simpleMessage("隐私"),
    "notificationReminders": MessageLookupByLibrary.simpleMessage("提醒"),
    "notificationServerGroupMissing": MessageLookupByLibrary.simpleMessage(
      "所选策略组不在当前配置中",
    ),
    "notificationServiceChannel": MessageLookupByLibrary.simpleMessage("服务渠道"),
    "notificationSessionTraffic": MessageLookupByLibrary.simpleMessage(
      "本次会话流量",
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
    "notificationVisibilityDetailed": MessageLookupByLibrary.simpleMessage(
      "详细",
    ),
    "notificationVisibilityMinimal": MessageLookupByLibrary.simpleMessage("精简"),
    "ntpInterval": MessageLookupByLibrary.simpleMessage("同步间隔（分钟）"),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "开启 NTP 后从 NTP 服务器获取时间，而非系统时钟。",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage("添加一个配置文件后即可开始使用"),
    "nullTip": m60,
    "numberRangeTip": m61,
    "numberTip": m62,
    "obfs": MessageLookupByLibrary.simpleMessage("混淆"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("混淆主机"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("混淆模式"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("混淆参数"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage("混淆密码"),
    "onDemand": MessageLookupByLibrary.simpleMessage("按需运行"),
    "onDemandBroadNetwork": MessageLookupByLibrary.simpleMessage(
      "此子网会信任大范围的网络",
    ),
    "onDemandCloseConnections": MessageLookupByLibrary.simpleMessage("断开连接"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "按需运行会在连上排除的 Wi-Fi 时暂停代理。",
    ),
    "onDemandFullStop": MessageLookupByLibrary.simpleMessage("完全停止"),
    "onDemandFullStopDesc": MessageLookupByLibrary.simpleMessage(
      "暂停时移除 TUN 并关闭本地代理端口。继续监测网络以便自动恢复。",
    ),
    "onDemandPause": MessageLookupByLibrary.simpleMessage("暂停"),
    "onDemandResume": MessageLookupByLibrary.simpleMessage("恢复"),
    "onDemandScanFailed": MessageLookupByLibrary.simpleMessage(
      "无法读取 Wi-Fi 网络。请重试或手动输入网络。",
    ),
    "onDemandStrict": MessageLookupByLibrary.simpleMessage("同时要求 SSID 与网段匹配"),
    "onDemandStrictDesc": MessageLookupByLibrary.simpleMessage(
      "同时存在两种规则时，仅当 SSID 与网段都匹配才暂停",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage("仅统计代理流量"),
    "optional": MessageLookupByLibrary.simpleMessage("可选"),
    "options": MessageLookupByLibrary.simpleMessage("选项"),
    "other": MessageLookupByLibrary.simpleMessage("其他"),
    "otherContributors": MessageLookupByLibrary.simpleMessage("其他贡献者"),
    "outbound": MessageLookupByLibrary.simpleMessage("出站"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("出口"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("出站 IP"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("出站模式"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage("覆盖目标地址"),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "覆盖目标地址使用嗅探到的域名替换原目标地址发起连接。",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage("覆写项"),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("解析纯IP"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "解析纯 IP 会嗅探只有 IP 地址的连接。",
    ),
    "password": MessageLookupByLibrary.simpleMessage("密码"),
    "paste": MessageLookupByLibrary.simpleMessage("粘贴"),
    "peers": MessageLookupByLibrary.simpleMessage("初始节点"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("从相册选择"),
    "pickNetwork": MessageLookupByLibrary.simpleMessage("选择网络"),
    "pickNetworkDesc": MessageLookupByLibrary.simpleMessage("周围可见的 Wi-Fi 网络"),
    "pickNetworkEmpty": MessageLookupByLibrary.simpleMessage("未找到 Wi-Fi 网络"),
    "pickNetworkGrantLocation": MessageLookupByLibrary.simpleMessage(
      "列出附近的 Wi-Fi 网络需要位置权限",
    ),
    "pickNetworkPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "允许访问位置信息以查看附近的 Wi-Fi 网络，或手动输入网络。",
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
    "plugin": MessageLookupByLibrary.simpleMessage("插件"),
    "pluginCipher": MessageLookupByLibrary.simpleMessage("插件加密方式"),
    "pluginHost": MessageLookupByLibrary.simpleMessage("插件主机"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("插件模式"),
    "pluginPassword": MessageLookupByLibrary.simpleMessage("插件密码"),
    "pluginPath": MessageLookupByLibrary.simpleMessage("插件路径"),
    "pluginUsername": MessageLookupByLibrary.simpleMessage("插件用户名"),
    "port": MessageLookupByLibrary.simpleMessage("端口"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage("请输入不同的端口"),
    "portHopping": MessageLookupByLibrary.simpleMessage("端口跳跃"),
    "portTip": m63,
    "portValue": m64,
    "ports": MessageLookupByLibrary.simpleMessage("端口"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("预共享密钥"),
    "preferred": MessageLookupByLibrary.simpleMessage("首选"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("前置条件"),
    "pressBackAgainToExit": MessageLookupByLibrary.simpleMessage("再按一次返回键退出"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("请按下组合键"),
    "preventDuplicateProfiles": MessageLookupByLibrary.simpleMessage("防止重复订阅"),
    "preventDuplicateProfilesDesc": MessageLookupByLibrary.simpleMessage(
      "拒绝已有配置使用的订阅链接",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("预览"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("上一个匹配"),
    "privateKey": MessageLookupByLibrary.simpleMessage("私钥"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage("私钥密码"),
    "process": MessageLookupByLibrary.simpleMessage("进程"),
    "profile": MessageLookupByLibrary.simpleMessage("配置"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("请输入有效间隔时间格式"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("请输入自动更新间隔时间"),
    "profileBatchResult": m65,
    "profileDaysLeft": m66,
    "profileExpiresIn": m67,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "配置文件已经修改，是否关闭自动更新？",
    ),
    "profileImportAlreadyAdded": m68,
    "profileImportChecking": MessageLookupByLibrary.simpleMessage("正在加载订阅页面…"),
    "profileImportDownloading": MessageLookupByLibrary.simpleMessage("正在下载订阅…"),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "已存在使用该订阅链接的配置",
    ),
    "profileImportEncrypted": MessageLookupByLibrary.simpleMessage(
      "订阅已加密，添加时会要求输入密钥。",
    ),
    "profileImportExpired": MessageLookupByLibrary.simpleMessage("已过期"),
    "profileImportFormat": MessageLookupByLibrary.simpleMessage("订阅格式"),
    "profileImportFormatClient": m69,
    "profileImportFormatReclash": MessageLookupByLibrary.simpleMessage(
      "为 ReClash 自动选择最佳格式",
    ),
    "profileImportFromProvider": MessageLookupByLibrary.simpleMessage("来自服务商"),
    "profileImportLosses": MessageLookupByLibrary.simpleMessage(
      "部分内容不受支持，添加前会让你查看。",
    ),
    "profileImportPreviewFailed": MessageLookupByLibrary.simpleMessage(
      "无法加载订阅页面，仍可添加此订阅。",
    ),
    "profileImportServerCount": m70,
    "profileImportServers": MessageLookupByLibrary.simpleMessage("服务器"),
    "profileImportSingleServer": MessageLookupByLibrary.simpleMessage("单个服务器"),
    "profileImportTitle": MessageLookupByLibrary.simpleMessage("新订阅"),
    "profileImportTryOtherFormat": MessageLookupByLibrary.simpleMessage(
      "未添加任何内容。可以选择其他格式后重试。",
    ),
    "profileImportUnlimited": MessageLookupByLibrary.simpleMessage("不限"),
    "profileImportValidUntil": MessageLookupByLibrary.simpleMessage("有效期至"),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入配置名称",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "仅作用于当前配置，未添加的项使用默认值。",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "仅作用于当前配置，并优先于网络设置中的虚拟网卡覆写项。",
    ),
    "profileUpdatedAt": m71,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入有效配置URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "请输入配置URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("配置"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("配置排序"),
    "project": MessageLookupByLibrary.simpleMessage("项目"),
    "protocol": MessageLookupByLibrary.simpleMessage("协议"),
    "protocolParam": MessageLookupByLibrary.simpleMessage("协议参数"),
    "protocolVersion": MessageLookupByLibrary.simpleMessage("协议版本"),
    "providerAnnouncement": MessageLookupByLibrary.simpleMessage("公告"),
    "providerAnnouncementOpen": MessageLookupByLibrary.simpleMessage("了解详情"),
    "providerAnnouncementRead": MessageLookupByLibrary.simpleMessage("阅读"),
    "providerInUse": m72,
    "providerNotice": MessageLookupByLibrary.simpleMessage("通知"),
    "providerSettingManaged": MessageLookupByLibrary.simpleMessage("来自服务商"),
    "providerSettingReturn": MessageLookupByLibrary.simpleMessage("交还给服务商"),
    "providerSettingsReturnAll": MessageLookupByLibrary.simpleMessage(
      "将设置交还给服务商",
    ),
    "providerSettingsReturnAllDesc": MessageLookupByLibrary.simpleMessage(
      "你更改过的设置将重新跟随订阅",
    ),
    "providerUrlTip": MessageLookupByLibrary.simpleMessage("仅支持远程资源"),
    "providers": MessageLookupByLibrary.simpleMessage("外部资源"),
    "proxies": MessageLookupByLibrary.simpleMessage("代理"),
    "proxiesCount": m73,
    "proxiesProfileLabel": m74,
    "proxiesRemovedTip": m75,
    "proxiesReplacedTip": m76,
    "proxyChains": MessageLookupByLibrary.simpleMessage("代理链"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("策略组"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage("策略组为空"),
    "proxyGroupInUse": m77,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "启动后在这里显示策略组",
    ),
    "proxyGroupsCount": m78,
    "proxyProviders": MessageLookupByLibrary.simpleMessage("代理集"),
    "proxyType": MessageLookupByLibrary.simpleMessage("代理类型"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("修剪缓存"),
    "publicKey": MessageLookupByLibrary.simpleMessage("公钥"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("纯黑"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("纯黑模式"),
    "qrcode": MessageLookupByLibrary.simpleMessage("二维码"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage("扫描二维码获取配置文件"),
    "qrcodeTooLongTip": MessageLookupByLibrary.simpleMessage(
      "链接过长，无法生成二维码，请改用“复制链接”。",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("快捷操作"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("快速编辑"),
    "rcxAddGroup": MessageLookupByLibrary.simpleMessage("添加分组"),
    "rcxAddKind": MessageLookupByLibrary.simpleMessage("添加网络类型"),
    "rcxAddPool": MessageLookupByLibrary.simpleMessage("添加匹配规则"),
    "rcxAddTag": MessageLookupByLibrary.simpleMessage("添加标签"),
    "rcxAddTier": MessageLookupByLibrary.simpleMessage("添加偏好"),
    "rcxAdvanced": MessageLookupByLibrary.simpleMessage("高级"),
    "rcxAdvancedHint": MessageLookupByLibrary.simpleMessage("这些部分以 YAML 编辑。"),
    "rcxAllGroups": MessageLookupByLibrary.simpleMessage("所有分组"),
    "rcxAnyServer": MessageLookupByLibrary.simpleMessage("任意"),
    "rcxAutoControl": MessageLookupByLibrary.simpleMessage("自动控制"),
    "rcxAutoControlHint": MessageLookupByLibrary.simpleMessage(
      "场景控制整个连接：每种网络下的模式以及每个分组的行为。未指定的分组沿用各自的配置。",
    ),
    "rcxBackToAuto": MessageLookupByLibrary.simpleMessage("恢复自动"),
    "rcxBalanced": MessageLookupByLibrary.simpleMessage("均衡"),
    "rcxBasedOn": MessageLookupByLibrary.simpleMessage("基于"),
    "rcxBehaviour": MessageLookupByLibrary.simpleMessage("行为"),
    "rcxBringChanges": MessageLookupByLibrary.simpleMessage("合并更改"),
    "rcxBringChangesHint": MessageLookupByLibrary.simpleMessage("你的修改将保持不变"),
    "rcxChangeServer": MessageLookupByLibrary.simpleMessage("更换服务器"),
    "rcxChangeTo": MessageLookupByLibrary.simpleMessage("切换到"),
    "rcxCheck": MessageLookupByLibrary.simpleMessage("检查"),
    "rcxCheckDifferent": m79,
    "rcxCheckGroup": MessageLookupByLibrary.simpleMessage("针对分组"),
    "rcxCheckNone": MessageLookupByLibrary.simpleMessage("找不到服务器"),
    "rcxCheckOn": m80,
    "rcxCheckOpen": MessageLookupByLibrary.simpleMessage("可打开被封锁的网站"),
    "rcxCheckSame": m81,
    "rcxChecks": MessageLookupByLibrary.simpleMessage("检测"),
    "rcxChecksDeclared": MessageLookupByLibrary.simpleMessage("可用性检测"),
    "rcxCondAdd": MessageLookupByLibrary.simpleMessage("添加条件"),
    "rcxCondAll": MessageLookupByLibrary.simpleMessage("所有条件"),
    "rcxCondAlways": MessageLookupByLibrary.simpleMessage("始终"),
    "rcxCondAny": MessageLookupByLibrary.simpleMessage("任一条件"),
    "rcxCondAnyServer": MessageLookupByLibrary.simpleMessage("任意服务器"),
    "rcxCondClause": m82,
    "rcxCondField": MessageLookupByLibrary.simpleMessage("字段"),
    "rcxCondIgnoreCase": MessageLookupByLibrary.simpleMessage("忽略大小写"),
    "rcxCondMatch": MessageLookupByLibrary.simpleMessage("匹配"),
    "rcxCondNoNames": MessageLookupByLibrary.simpleMessage("未声明"),
    "rcxCondNotPrefix": MessageLookupByLibrary.simpleMessage("非"),
    "rcxCondOp": MessageLookupByLibrary.simpleMessage("运算符"),
    "rcxCondPattern": MessageLookupByLibrary.simpleMessage("模式"),
    "rcxCondText": MessageLookupByLibrary.simpleMessage("文本形式"),
    "rcxCondTooComplex": MessageLookupByLibrary.simpleMessage(
      "此条件嵌套了分组，因此以文本编辑。",
    ),
    "rcxCondValue": MessageLookupByLibrary.simpleMessage("值"),
    "rcxCondValues": MessageLookupByLibrary.simpleMessage("值，以逗号分隔"),
    "rcxConsentAllow": MessageLookupByLibrary.simpleMessage("允许"),
    "rcxConsentAsk": m83,
    "rcxConsentHint": MessageLookupByLibrary.simpleMessage(
      "在你允许之前，该组将使用“简单”配置。仅会通过你的服务器或为测试网络而访问这些网站。",
    ),
    "rcxConsentTitle": MessageLookupByLibrary.simpleMessage("需要权限"),
    "rcxContacts": MessageLookupByLibrary.simpleMessage("会访问的网站"),
    "rcxContactsHint": MessageLookupByLibrary.simpleMessage(
      "第三方网站既不属于你的提供商，也不属于内置配置。",
    ),
    "rcxControl": MessageLookupByLibrary.simpleMessage("控制"),
    "rcxDeleteProfile": m84,
    "rcxDiagnostics": MessageLookupByLibrary.simpleMessage("网络诊断"),
    "rcxDirectSplit": MessageLookupByLibrary.simpleMessage("直连网站经由此组"),
    "rcxDirectSplitActive": MessageLookupByLibrary.simpleMessage("当前已开启"),
    "rcxDirectSplitHint": MessageLookupByLibrary.simpleMessage(
      "规则设为直连的网站无法打开时，改为经由此组。本地地址始终直连。",
    ),
    "rcxDirectSplitStandby": MessageLookupByLibrary.simpleMessage(
      "待命：直连网站仍可打开",
    ),
    "rcxDuplicate": MessageLookupByLibrary.simpleMessage("复制并编辑"),
    "rcxEnergyEco": MessageLookupByLibrary.simpleMessage("节省"),
    "rcxEnergyPrecise": MessageLookupByLibrary.simpleMessage("精确"),
    "rcxEnergyToday": m85,
    "rcxExcept": m86,
    "rcxExcludedByProfile": MessageLookupByLibrary.simpleMessage("被配置排除"),
    "rcxExcludedCooldown": MessageLookupByLibrary.simpleMessage("因“更换服务器”而跳过"),
    "rcxExcludedNoMatch": MessageLookupByLibrary.simpleMessage("不在候选范围内"),
    "rcxExcludedNoTier": MessageLookupByLibrary.simpleMessage("不符合任何偏好"),
    "rcxExcludedPending": MessageLookupByLibrary.simpleMessage("尚未检测"),
    "rcxExcludedUnroutable": MessageLookupByLibrary.simpleMessage("不是服务器"),
    "rcxExit": m87,
    "rcxExitCheck": MessageLookupByLibrary.simpleMessage("出口国家检测"),
    "rcxExport": MessageLookupByLibrary.simpleMessage("导出"),
    "rcxFeelCalm": MessageLookupByLibrary.simpleMessage("较少"),
    "rcxFeelEager": MessageLookupByLibrary.simpleMessage("频繁"),
    "rcxFieldAlive": MessageLookupByLibrary.simpleMessage("可用"),
    "rcxFieldCurrent": MessageLookupByLibrary.simpleMessage("使用中"),
    "rcxFieldDead": MessageLookupByLibrary.simpleMessage("不可用"),
    "rcxFieldDiag": MessageLookupByLibrary.simpleMessage("网络诊断"),
    "rcxFieldEntry": MessageLookupByLibrary.simpleMessage("入口国家"),
    "rcxFieldExit": MessageLookupByLibrary.simpleMessage("出口国家"),
    "rcxFieldFails": MessageLookupByLibrary.simpleMessage("检测失败"),
    "rcxFieldKind": MessageLookupByLibrary.simpleMessage("网络类型"),
    "rcxFieldLatency": MessageLookupByLibrary.simpleMessage("延迟（毫秒）"),
    "rcxFieldMeasured": MessageLookupByLibrary.simpleMessage("已测量"),
    "rcxFieldMetered": MessageLookupByLibrary.simpleMessage("计费网络"),
    "rcxFieldName": MessageLookupByLibrary.simpleMessage("名称"),
    "rcxFieldPasses": MessageLookupByLibrary.simpleMessage("检测通过"),
    "rcxFieldPortal": MessageLookupByLibrary.simpleMessage("登录页面"),
    "rcxFieldProvider": MessageLookupByLibrary.simpleMessage("提供商"),
    "rcxFieldServer": MessageLookupByLibrary.simpleMessage("服务器地址"),
    "rcxFieldTag": MessageLookupByLibrary.simpleMessage("标签"),
    "rcxFieldTransport": MessageLookupByLibrary.simpleMessage("连接类型"),
    "rcxFieldType": MessageLookupByLibrary.simpleMessage("协议"),
    "rcxFieldUdp": MessageLookupByLibrary.simpleMessage("支持 UDP"),
    "rcxFixedHint": MessageLookupByLibrary.simpleMessage(
      "整个分组经由该成员，不再搜索服务器；选择负载均衡器或嵌套分组即可将全部流量交给它。",
    ),
    "rcxFixedOn": m88,
    "rcxGeneral": MessageLookupByLibrary.simpleMessage("常规"),
    "rcxGroupProfiles": MessageLookupByLibrary.simpleMessage("分组配置"),
    "rcxGroupProfilesHint": MessageLookupByLibrary.simpleMessage(
      "智能分组如何选择服务器。点按自己的配置可编辑，点按其他配置则编辑其副本。",
    ),
    "rcxHealthAlive": MessageLookupByLibrary.simpleMessage("可用"),
    "rcxHealthDead": MessageLookupByLibrary.simpleMessage("不可用"),
    "rcxHealthStale": MessageLookupByLibrary.simpleMessage("之前可用"),
    "rcxHealthUnknown": MessageLookupByLibrary.simpleMessage("未检测"),
    "rcxHistory": MessageLookupByLibrary.simpleMessage("历史"),
    "rcxHistoryVersions": MessageLookupByLibrary.simpleMessage("历史版本"),
    "rcxImportAdd": MessageLookupByLibrary.simpleMessage("添加到我的配置"),
    "rcxImportNeedsCore": MessageLookupByLibrary.simpleMessage(
      "请启动应用核心以检查此配置。",
    ),
    "rcxImportTitle": MessageLookupByLibrary.simpleMessage("导入路由配置"),
    "rcxImported": m89,
    "rcxJournalFailure": m90,
    "rcxJournalMode": m91,
    "rcxKindChecking": MessageLookupByLibrary.simpleMessage("检测中"),
    "rcxKindGroupsHint": MessageLookupByLibrary.simpleMessage(
      "在此网络下，它们会替换场景中的同名分组；其余分组与其他网络下一致。",
    ),
    "rcxKindName": MessageLookupByLibrary.simpleMessage("名称"),
    "rcxKindNameInvalid": MessageLookupByLibrary.simpleMessage(
      "小写拉丁字母、数字和连字符，最多 24 个字符",
    ),
    "rcxKindOpen": MessageLookupByLibrary.simpleMessage("开放互联网"),
    "rcxKindPortal": MessageLookupByLibrary.simpleMessage("登录页面"),
    "rcxKindWhen": MessageLookupByLibrary.simpleMessage("识别条件"),
    "rcxKindWhenHint": MessageLookupByLibrary.simpleMessage(
      "类型按从上到下的顺序检查，网络采用第一个符合的类型。",
    ),
    "rcxKindWhitelist": MessageLookupByLibrary.simpleMessage("仅白名单"),
    "rcxLastResort": MessageLookupByLibrary.simpleMessage("最后手段"),
    "rcxLastResortHint": MessageLookupByLibrary.simpleMessage(
      "仅当没有更优先的偏好包含服务器时，才会使用最后手段偏好。",
    ),
    "rcxLevel": MessageLookupByLibrary.simpleMessage("级别"),
    "rcxLevelAdvanced": MessageLookupByLibrary.simpleMessage("高级"),
    "rcxLevelSimple": MessageLookupByLibrary.simpleMessage("简单"),
    "rcxLine": m92,
    "rcxLintCheckUnused": m93,
    "rcxLintConsent": m94,
    "rcxLintGroupMissing": m95,
    "rcxLintPoolEmpty": m96,
    "rcxLintTagUnused": m97,
    "rcxLintTierEmpty": m98,
    "rcxLintTierUnreachable": m99,
    "rcxMainGroup": MessageLookupByLibrary.simpleMessage("主分组"),
    "rcxMakeSmart": MessageLookupByLibrary.simpleMessage("将此组设为智能"),
    "rcxMakeSmartHint": MessageLookupByLibrary.simpleMessage(
      "ReClash 会在此组中保持选中可用的服务器，并在其失效时切换。仅在你使用网络时才会进行检测。",
    ),
    "rcxManageHint": MessageLookupByLibrary.simpleMessage(
      "配置和场景在 “进阶配置” → “自动路由” 中创建和编辑。",
    ),
    "rcxMergeFailed": MessageLookupByLibrary.simpleMessage("无法合并更改"),
    "rcxMerged": MessageLookupByLibrary.simpleMessage("已合并更改"),
    "rcxMergedConflicts": m100,
    "rcxModeAuto": MessageLookupByLibrary.simpleMessage("自动"),
    "rcxModeAutoHint": MessageLookupByLibrary.simpleMessage("按配置选择并切换服务器"),
    "rcxModeBackToAuto": MessageLookupByLibrary.simpleMessage("将模式交还给场景"),
    "rcxModeByScenario": MessageLookupByLibrary.simpleMessage("此网络下的模式由场景决定"),
    "rcxModeIs": m101,
    "rcxModeKeep": MessageLookupByLibrary.simpleMessage("不更改"),
    "rcxModeManual": MessageLookupByLibrary.simpleMessage("手动"),
    "rcxModeManualHint": MessageLookupByLibrary.simpleMessage("由你选择，自动路由不会切换"),
    "rcxModeManualNow": MessageLookupByLibrary.simpleMessage(
      "你已手动选择模式；场景会等待，直到你选择 “自动”",
    ),
    "rcxModeYours": MessageLookupByLibrary.simpleMessage("此网络下的模式由你决定"),
    "rcxMoveDown": MessageLookupByLibrary.simpleMessage("下移"),
    "rcxMoveUp": MessageLookupByLibrary.simpleMessage("上移"),
    "rcxNeedsConsent": MessageLookupByLibrary.simpleMessage("需要你的许可"),
    "rcxNetwork": m102,
    "rcxNetworkKinds": MessageLookupByLibrary.simpleMessage("网络类型"),
    "rcxNewProfile": MessageLookupByLibrary.simpleMessage("新建配置"),
    "rcxNewScenario": MessageLookupByLibrary.simpleMessage("新建场景"),
    "rcxOnThisNetwork": MessageLookupByLibrary.simpleMessage("在此网络下"),
    "rcxOpFail": MessageLookupByLibrary.simpleMessage("失败"),
    "rcxOpIn": MessageLookupByLibrary.simpleMessage("属于"),
    "rcxOpIs": MessageLookupByLibrary.simpleMessage("是"),
    "rcxOpIsNot": MessageLookupByLibrary.simpleMessage("不是"),
    "rcxOpMatches": MessageLookupByLibrary.simpleMessage("匹配"),
    "rcxOpOk": MessageLookupByLibrary.simpleMessage("成功"),
    "rcxOverrides": MessageLookupByLibrary.simpleMessage("按网络的更改"),
    "rcxOwnProfile": MessageLookupByLibrary.simpleMessage("分组自身配置"),
    "rcxPatternInvalid": MessageLookupByLibrary.simpleMessage("该模式不是有效的正则表达式"),
    "rcxPendingTier": m103,
    "rcxPinned": m104,
    "rcxPinnedHint": MessageLookupByLibrary.simpleMessage("仅在失效时离开，恢复后返回"),
    "rcxPinnedLabel": MessageLookupByLibrary.simpleMessage("已固定"),
    "rcxPoolExclude": MessageLookupByLibrary.simpleMessage("排除"),
    "rcxPoolInclude": MessageLookupByLibrary.simpleMessage("使用"),
    "rcxProblemGroupEmpty": MessageLookupByLibrary.simpleMessage("该组没有服务器"),
    "rcxProblemGroupUnavailable": MessageLookupByLibrary.simpleMessage(
      "当前配置中此组不是选择器",
    ),
    "rcxProblemProfileInvalid": m105,
    "rcxProblemProfileMissing": m106,
    "rcxProblemStoreFailed": m107,
    "rcxProfile": MessageLookupByLibrary.simpleMessage("配置"),
    "rcxProfileName": MessageLookupByLibrary.simpleMessage("名称"),
    "rcxProfileProgramHint": MessageLookupByLibrary.simpleMessage(
      "分组按此配置，在资源池保留的服务器中选择服务器。",
    ),
    "rcxProgramAction": MessageLookupByLibrary.simpleMessage("操作"),
    "rcxProgramFixed": MessageLookupByLibrary.simpleMessage("交给单个成员"),
    "rcxProgramMember": MessageLookupByLibrary.simpleMessage("成员"),
    "rcxProgramPick": MessageLookupByLibrary.simpleMessage("选择服务器"),
    "rcxReasonBest": MessageLookupByLibrary.simpleMessage("这是最佳服务器"),
    "rcxReasonBetterTier": m108,
    "rcxReasonChangeServer": m109,
    "rcxReasonChecking": MessageLookupByLibrary.simpleMessage("正在检测更优的候选"),
    "rcxReasonConfirming": MessageLookupByLibrary.simpleMessage(
      "更快的服务器需要再测量一次",
    ),
    "rcxReasonDwell": MessageLookupByLibrary.simpleMessage("刚刚切换过，下次切换前保持"),
    "rcxReasonFailover": m110,
    "rcxReasonFaster": m111,
    "rcxReasonFixed": m112,
    "rcxReasonFixedMissing": m113,
    "rcxReasonFlapLimit": m114,
    "rcxReasonHoldPinned": MessageLookupByLibrary.simpleMessage("保持已固定的服务器"),
    "rcxReasonIdle": m115,
    "rcxReasonInitial": MessageLookupByLibrary.simpleMessage("已选择最佳可用服务器"),
    "rcxReasonManual": MessageLookupByLibrary.simpleMessage("手动控制"),
    "rcxReasonNetworkChanged": MessageLookupByLibrary.simpleMessage("网络已变化"),
    "rcxReasonNetworkSuspect": MessageLookupByLibrary.simpleMessage(
      "网络似乎中断，不归咎于服务器",
    ),
    "rcxReasonNoAlternative": MessageLookupByLibrary.simpleMessage(
      "没有其他可切换的可用服务器",
    ),
    "rcxReasonOutOfPool": m116,
    "rcxReasonPaused": m117,
    "rcxReasonSelectFailed": MessageLookupByLibrary.simpleMessage("无法选择该服务器"),
    "rcxReasonSplitOff": MessageLookupByLibrary.simpleMessage("直连网站恢复直连"),
    "rcxReasonSplitOn": MessageLookupByLibrary.simpleMessage("直连网站现在经由此组"),
    "rcxReasonStranded": MessageLookupByLibrary.simpleMessage(
      "没有可用服务器，保持当前服务器",
    ),
    "rcxReasonSwitchFixed": m118,
    "rcxReasonSwitchPinned": m119,
    "rcxReasonSwitchStranded": m120,
    "rcxReasonWorking": MessageLookupByLibrary.simpleMessage("可用，失效前保持"),
    "rcxScenario": MessageLookupByLibrary.simpleMessage("场景"),
    "rcxScenarioDrives": m121,
    "rcxScenarioGroups": MessageLookupByLibrary.simpleMessage("分组"),
    "rcxScenarioGroupsHint": MessageLookupByLibrary.simpleMessage(
      "主分组是最终规则发送流量的目标；“所有分组”涵盖此处未列出的选择类分组。",
    ),
    "rcxScenarioKindsHint": MessageLookupByLibrary.simpleMessage(
      "通过直接诊断识别网络，然后为每种网络更改模式和分组。",
    ),
    "rcxScenarioMode": MessageLookupByLibrary.simpleMessage("连接模式"),
    "rcxScenarioOff": MessageLookupByLibrary.simpleMessage("关闭"),
    "rcxScenarios": MessageLookupByLibrary.simpleMessage("场景"),
    "rcxScenariosHint": MessageLookupByLibrary.simpleMessage(
      "场景控制整个连接。点按自己的场景可编辑，点按其他场景则编辑其副本。",
    ),
    "rcxServers": MessageLookupByLibrary.simpleMessage("服务器"),
    "rcxServersMatch": m122,
    "rcxServersPattern": MessageLookupByLibrary.simpleMessage("名称模式"),
    "rcxSmartGroups": MessageLookupByLibrary.simpleMessage("智能分组"),
    "rcxSourceBuiltin": MessageLookupByLibrary.simpleMessage("内置"),
    "rcxSourceChanged": MessageLookupByLibrary.simpleMessage("原始配置已更改"),
    "rcxSourceChanges": MessageLookupByLibrary.simpleMessage("更改内容"),
    "rcxSourceProvider": MessageLookupByLibrary.simpleMessage("来自服务商"),
    "rcxSourceUser": MessageLookupByLibrary.simpleMessage("我的"),
    "rcxStranded": MessageLookupByLibrary.simpleMessage("没有合适的服务器时"),
    "rcxStrandedDirect": MessageLookupByLibrary.simpleMessage("直连"),
    "rcxStrandedHold": MessageLookupByLibrary.simpleMessage("保持当前服务器"),
    "rcxSwitching": MessageLookupByLibrary.simpleMessage("切换"),
    "rcxTagName": MessageLookupByLibrary.simpleMessage("标签名称"),
    "rcxTagNameInvalid": MessageLookupByLibrary.simpleMessage(
      "仅限拉丁字母、数字、- 和 _，最多 24 个字符",
    ),
    "rcxTags": MessageLookupByLibrary.simpleMessage("标签"),
    "rcxTagsHint": MessageLookupByLibrary.simpleMessage(
      "标签为一组服务器命名一次，即可在偏好中以 tag(name) 的形式使用。",
    ),
    "rcxThirdParty": MessageLookupByLibrary.simpleMessage("第三方"),
    "rcxTier": MessageLookupByLibrary.simpleMessage("偏好"),
    "rcxTierLabel": MessageLookupByLibrary.simpleMessage("标签"),
    "rcxTierWhen": MessageLookupByLibrary.simpleMessage("此偏好中的服务器"),
    "rcxTiers": MessageLookupByLibrary.simpleMessage("偏好顺序"),
    "rcxTiersHint": MessageLookupByLibrary.simpleMessage(
      "服务器会归入第一个符合的偏好；有服务器的最优偏好胜出。长按可调整顺序。",
    ),
    "rcxTitle": MessageLookupByLibrary.simpleMessage("自动路由"),
    "rcxTranslations": MessageLookupByLibrary.simpleMessage("翻译"),
    "rcxTurnOff": MessageLookupByLibrary.simpleMessage("关闭自动路由"),
    "rcxUntilCheck": m123,
    "rcxUntilConfirm": m124,
    "rcxUntilDwell": m125,
    "rcxUseCheck": m126,
    "rcxUseDiagnostic": m127,
    "rcxUseEcho": MessageLookupByLibrary.simpleMessage("出口国家检测"),
    "rcxWarnings": MessageLookupByLibrary.simpleMessage("警告"),
    "rcxWhy": MessageLookupByLibrary.simpleMessage("为何选择此服务器"),
    "rcxYaml": MessageLookupByLibrary.simpleMessage("YAML"),
    "recentRequests": MessageLookupByLibrary.simpleMessage("最近请求"),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("推荐"),
    "recordType": MessageLookupByLibrary.simpleMessage("记录类型"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir端口"),
    "redo": MessageLookupByLibrary.simpleMessage("重做"),
    "regex": MessageLookupByLibrary.simpleMessage("正则"),
    "regionApply": MessageLookupByLibrary.simpleMessage("应用地区配置"),
    "regionAppsChanged": MessageLookupByLibrary.simpleMessage(
      "地区或应用列表已更改。请根据当前设置重新选择。",
    ),
    "regionAppsEmpty": MessageLookupByLibrary.simpleMessage(
      "没有应用匹配此地区。列表保持不变。",
    ),
    "regionAppsPreview": m128,
    "regionAppsPreviewTitle": MessageLookupByLibrary.simpleMessage("应用选择预览"),
    "regionChangeDns": MessageLookupByLibrary.simpleMessage("DNS 服务器"),
    "regionChangeMtu": MessageLookupByLibrary.simpleMessage("TUN MTU"),
    "regionChangeServices": MessageLookupByLibrary.simpleMessage("服务检查"),
    "regionChangesTitle": MessageLookupByLibrary.simpleMessage("将要更改"),
    "regionChina": MessageLookupByLibrary.simpleMessage("中国"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "你自己修改过的值会保持不变。",
    ),
    "regionEgypt": MessageLookupByLibrary.simpleMessage("埃及"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "根据你所在的国家选择 DNS 服务器、TUN MTU、绕过列表和服务检查。界面语言不会改变。",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("伊朗"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage("设置不会改变。"),
    "regionNoServices": MessageLookupByLibrary.simpleMessage("服务检查已关闭"),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("未选择"),
    "regionOther": MessageLookupByLibrary.simpleMessage("其他国家"),
    "regionRecommended": MessageLookupByLibrary.simpleMessage("推荐用于此设备"),
    "regionRussia": MessageLookupByLibrary.simpleMessage("俄罗斯"),
    "regionSelectApps": MessageLookupByLibrary.simpleMessage("按地区选择应用"),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "请先选择受支持的地区，再使用地区应用建议。",
    ),
    "regionTitle": MessageLookupByLibrary.simpleMessage("地区配置"),
    "regionalAdaptation": MessageLookupByLibrary.simpleMessage("地区适配"),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("释放内存"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage("释放内存失败"),
    "remote": MessageLookupByLibrary.simpleMessage("远程"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("远程目标"),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage("远程 DNS 解析"),
    "remove": MessageLookupByLibrary.simpleMessage("移除"),
    "rename": MessageLookupByLibrary.simpleMessage("重命名"),
    "renewSubscription": MessageLookupByLibrary.simpleMessage("续订订阅"),
    "replace": MessageLookupByLibrary.simpleMessage("替换"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("全部替换"),
    "request": MessageLookupByLibrary.simpleMessage("请求"),
    "requestHeaders": MessageLookupByLibrary.simpleMessage("请求头"),
    "requests": MessageLookupByLibrary.simpleMessage("请求"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage("请求与更新"),
    "required": MessageLookupByLibrary.simpleMessage("必填"),
    "reset": MessageLookupByLibrary.simpleMessage("重置"),
    "resetAllData": MessageLookupByLibrary.simpleMessage("重置所有数据"),
    "resetAllDataConfirm": MessageLookupByLibrary.simpleMessage("全部删除"),
    "resetAllDataDescription": MessageLookupByLibrary.simpleMessage(
      "所有配置、设置、脚本、壁纸和缓存数据将被永久删除。备份归档将保留。随后应用将关闭。此操作无法撤销。",
    ),
    "resetAllDataWait": m129,
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "当前页面存在更改，确定重置吗？",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("确定要重置吗？"),
    "resettingAllData": MessageLookupByLibrary.simpleMessage("正在删除数据…"),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage("自动更新间隔"),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "自动更新间隔必须大于0",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("资源"),
    "respectRules": MessageLookupByLibrary.simpleMessage("遵守规则"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "遵守规则使 DNS 连接遵守规则，需配置 Proxy Server Nameserver。",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("响应码"),
    "restart": MessageLookupByLibrary.simpleMessage("重启"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage("您确定要重启核心吗？"),
    "restore": MessageLookupByLibrary.simpleMessage("恢复"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("恢复所有数据"),
    "restoreDefaults": MessageLookupByLibrary.simpleMessage("恢复默认"),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage("仅恢复配置文件"),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("恢复策略"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage("兼容"),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("覆盖"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("恢复成功"),
    "result": MessageLookupByLibrary.simpleMessage("结果"),
    "retry": MessageLookupByLibrary.simpleMessage("重试"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("路由地址"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage("排除路由地址"),
    "routingMark": MessageLookupByLibrary.simpleMessage("路由标记"),
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
      "匹配DSCP标记（仅限 tproxy udp 入站）",
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
      "匹配 IP 地址范围，IP-CIDR6 只是一个别名",
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
      "匹配至子规则，需要注意括号的使用",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "匹配 Linux USER ID",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("规则为空"),
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "规则必须是 YAML 列表，每项一条规则，例如 - DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BT 下载直连",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "屏蔽 DNS over TLS",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage("防止代理回环"),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage("屏蔽 QUIC"),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage("屏蔽 STUN"),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage("局域网直连"),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple 与 Microsoft 直连",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("规则集"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("规则集"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage("规则集中没有可用的条目"),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage("无法读取该 mrs 文件"),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "规则集同时包含域名和 IP 段，无法判断类型",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("规则目标"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "规则必须以受支持的类型开头，例如 DOMAIN,example.com,DIRECT",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("规则"),
    "rulesCount": m130,
    "runTime": MessageLookupByLibrary.simpleMessage("运行时长"),
    "running": MessageLookupByLibrary.simpleMessage("运行中"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("运行时配置"),
    "safeMode": MessageLookupByLibrary.simpleMessage("安全模式"),
    "safeModeAppTitle": m131,
    "saturation": MessageLookupByLibrary.simpleMessage("饱和度"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("是否保存更改？"),
    "script": MessageLookupByLibrary.simpleMessage("脚本"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage("脚本模式，使用扩展脚本改写整个配置"),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage("滚动到已选"),
    "search": MessageLookupByLibrary.simpleMessage("搜索"),
    "seconds": MessageLookupByLibrary.simpleMessage("秒"),
    "secondsCount": m132,
    "secretKey": MessageLookupByLibrary.simpleMessage("密钥"),
    "sectionsInEffect": m133,
    "select": MessageLookupByLibrary.simpleMessage("选中"),
    "selectAll": MessageLookupByLibrary.simpleMessage("全选"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage("请选择规则集"),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage("请选择分流策略"),
    "selected": MessageLookupByLibrary.simpleMessage("已选择"),
    "send": MessageLookupByLibrary.simpleMessage("发送"),
    "sendFromPhone": MessageLookupByLibrary.simpleMessage("从手机发送"),
    "sendFromPhoneConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "导入手机发来的链接？",
    ),
    "sendFromPhoneNoNetwork": MessageLookupByLibrary.simpleMessage(
      "这台设备没有连接局域网",
    ),
    "sendFromPhonePageHint": MessageLookupByLibrary.simpleMessage(
      "订阅链接或代理分享链接",
    ),
    "sendFromPhonePageSent": MessageLookupByLibrary.simpleMessage(
      "已发送，请在另一台设备上确认导入。",
    ),
    "sendFromPhonePageTitle": MessageLookupByLibrary.simpleMessage(
      "把链接发送到 ReClash",
    ),
    "sendFromPhonePermissionDenied": MessageLookupByLibrary.simpleMessage(
      "从手机接收链接需要「附近的设备」权限，ReClash 才能访问局域网。请在应用设置中开启。",
    ),
    "sendFromPhoneTip": MessageLookupByLibrary.simpleMessage(
      "用手机相机扫描二维码，在打开的页面里粘贴链接。两台设备需要连在同一个网络。",
    ),
    "server": MessageLookupByLibrary.simpleMessage("服务器"),
    "serviceAbnormalCount": m134,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage("全部可用"),
    "serviceAutoCheckActive": MessageLookupByLibrary.simpleMessage(
      "自动检查已启用的服务",
    ),
    "serviceAutoCheckAll": MessageLookupByLibrary.simpleMessage("检查所有服务"),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("可用"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("已被封禁"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("全部检测"),
    "serviceCheckOnlyWhenConnected": MessageLookupByLibrary.simpleMessage(
      "仅在连接时检查",
    ),
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("即将上线"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage("不允许的 ISP"),
    "serviceFailed": MessageLookupByLibrary.simpleMessage("检测失败"),
    "serviceManage": MessageLookupByLibrary.simpleMessage("管理服务"),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage("仅限自制内容"),
    "servicePending": MessageLookupByLibrary.simpleMessage("待检测"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage("访问受限"),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage("显示在仪表盘"),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("服务状态"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("不可用"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage("地区不支持"),
    "settingEntries": MessageLookupByLibrary.simpleMessage("设置项"),
    "settings": MessageLookupByLibrary.simpleMessage("设置"),
    "settingsCount": m135,
    "setupAgeKeyDescription": MessageLookupByLibrary.simpleMessage(
      "此配置已加密。请输入 age 密钥以继续。",
    ),
    "setupAlternativeDescription": MessageLookupByLibrary.simpleMessage(
      "此服务器通过了单独探测。切换后重新检查完整路由。",
    ),
    "setupAutoConnect": MessageLookupByLibrary.simpleMessage("打开 ReClash 时连接"),
    "setupAutoConnectDescription": MessageLookupByLibrary.simpleMessage(
      "随应用一起启动此连接。",
    ),
    "setupChangeSettings": MessageLookupByLibrary.simpleMessage("更改设置"),
    "setupCheckAction": MessageLookupByLibrary.simpleMessage("检查连接"),
    "setupCheckLimit": MessageLookupByLibrary.simpleMessage(
      "结果仅适用于此路由，并不代表所有应用或网站。",
    ),
    "setupCheckingDescription": MessageLookupByLibrary.simpleMessage(
      "我们会检查一条选定路由。系统权限请求会单独显示。",
    ),
    "setupCheckingTitle": MessageLookupByLibrary.simpleMessage("正在连接并检查"),
    "setupConfirmed": MessageLookupByLibrary.simpleMessage("已确认"),
    "setupConnectedDescription": MessageLookupByLibrary.simpleMessage(
      "选定路由已响应。流量将遵循配置规则。",
    ),
    "setupConnectedTitle": MessageLookupByLibrary.simpleMessage("连接正常"),
    "setupCopyProxy": MessageLookupByLibrary.simpleMessage("复制代理地址"),
    "setupCoverageAll": MessageLookupByLibrary.simpleMessage("所有应用"),
    "setupCoverageAllDescription": MessageLookupByLibrary.simpleMessage(
      "TUN 会接管设备流量。系统可能会请求权限。",
    ),
    "setupCoverageAndroidDescription": MessageLookupByLibrary.simpleMessage(
      "Android 将请求创建 VPN 连接。应用选择可在访问设置中进行。",
    ),
    "setupCoverageDescription": MessageLookupByLibrary.simpleMessage(
      "选择使用 ReClash 的应用。哪些连接使用服务器由配置规则决定。",
    ),
    "setupCoverageLocal": MessageLookupByLibrary.simpleMessage("我将手动配置应用"),
    "setupCoverageLocalDescription": MessageLookupByLibrary.simpleMessage(
      "在每个需要连接的应用中设置本地代理地址。",
    ),
    "setupCoverageNote": MessageLookupByLibrary.simpleMessage(
      "接管所有流量不代表将所有流量发送到服务器。直连路由仍会保留。",
    ),
    "setupCoverageSystem": MessageLookupByLibrary.simpleMessage("系统代理"),
    "setupCoverageSystemDescription": MessageLookupByLibrary.simpleMessage(
      "不支持系统代理的应用将直接连接。",
    ),
    "setupCoverageTitle": MessageLookupByLibrary.simpleMessage("要连接哪些应用？"),
    "setupDirectApps": m136,
    "setupDirectAppsNone": MessageLookupByLibrary.simpleMessage(
      "未找到本地应用。网站仍会直连。",
    ),
    "setupDirectAppsReview": MessageLookupByLibrary.simpleMessage(
      "这些应用将不经过 VPN。之后可在访问控制中更改列表。",
    ),
    "setupDirectAppsScanning": MessageLookupByLibrary.simpleMessage(
      "正在查找本地应用…",
    ),
    "setupDirectDescription": MessageLookupByLibrary.simpleMessage(
      "本国服务不经服务器直接打开：速度更快，银行和政务网站也不会拦截你。以下规则将加入全局规则：",
    ),
    "setupDirectTitle": MessageLookupByLibrary.simpleMessage("本地网站和应用直连"),
    "setupErrorDetails": MessageLookupByLibrary.simpleMessage("详情"),
    "setupFailedTitle": MessageLookupByLibrary.simpleMessage("连接需要处理"),
    "setupFinishDescription": MessageLookupByLibrary.simpleMessage(
      "您可以在设置中更改任何选择。",
    ),
    "setupLanguageContinue": MessageLookupByLibrary.simpleMessage("继续"),
    "setupLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "阅读条款前，请先选择语言。之后可以更改。",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage("选择语言"),
    "setupLaterNote": MessageLookupByLibrary.simpleMessage("设置未完成；连接尚未检查。"),
    "setupLeaveMessage": MessageLookupByLibrary.simpleMessage(
      "ReClash 将关闭。你的选择已保存，下次打开应用时将继续设置。",
    ),
    "setupLeaveTitle": MessageLookupByLibrary.simpleMessage("退出设置？"),
    "setupLocalDescription": MessageLookupByLibrary.simpleMessage(
      "在要连接的应用中设置此地址。此检查无法证明这些应用已完成配置。",
    ),
    "setupLocalTitle": MessageLookupByLibrary.simpleMessage("本地代理已就绪"),
    "setupNotChecked": MessageLookupByLibrary.simpleMessage("未检查"),
    "setupPartialDescription": MessageLookupByLibrary.simpleMessage(
      "路由已响应，但部分检查无法确认。",
    ),
    "setupPartialTitle": MessageLookupByLibrary.simpleMessage("已连接，但有限制"),
    "setupPermissionDescription": MessageLookupByLibrary.simpleMessage(
      "请在系统提示中允许连接后重试，或选择其他范围。",
    ),
    "setupPermissionTitle": MessageLookupByLibrary.simpleMessage("需要权限"),
    "setupPhaseAlternatives": MessageLookupByLibrary.simpleMessage("正在查找其他服务器"),
    "setupPhaseConnection": MessageLookupByLibrary.simpleMessage("正在启动连接"),
    "setupPhaseCore": MessageLookupByLibrary.simpleMessage("正在启动核心"),
    "setupPhaseExit": MessageLookupByLibrary.simpleMessage("正在确认出口"),
    "setupPhaseProfile": MessageLookupByLibrary.simpleMessage("正在应用配置"),
    "setupPhaseRoute": MessageLookupByLibrary.simpleMessage("正在检查路由"),
    "setupPhaseServices": MessageLookupByLibrary.simpleMessage("正在检查服务"),
    "setupProfileContinueHint": MessageLookupByLibrary.simpleMessage(
      "添加或选择一个配置文件以继续。",
    ),
    "setupProfileCount": m137,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash 不提供服务器。请导入服务提供商的订阅或配置。",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage("导入配置"),
    "setupProfileImportAnother": MessageLookupByLibrary.simpleMessage(
      "添加其他配置文件",
    ),
    "setupProfileImportHint": MessageLookupByLibrary.simpleMessage(
      "粘贴服务商邮件、机器人或账户页面中的链接，或选择文件或二维码。",
    ),
    "setupProfileLinkHint": MessageLookupByLibrary.simpleMessage("订阅或分享链接"),
    "setupProfileReady": MessageLookupByLibrary.simpleMessage("配置已就绪"),
    "setupProfileSkip": MessageLookupByLibrary.simpleMessage("稍后设置"),
    "setupProfileTitle": MessageLookupByLibrary.simpleMessage("添加连接配置"),
    "setupReceipt": MessageLookupByLibrary.simpleMessage("您的连接"),
    "setupReceiptCheck": MessageLookupByLibrary.simpleMessage("检查"),
    "setupReceiptCoverage": MessageLookupByLibrary.simpleMessage("范围"),
    "setupReceiptProfile": MessageLookupByLibrary.simpleMessage("配置"),
    "setupReceiptRegion": MessageLookupByLibrary.simpleMessage("地区"),
    "setupRecommended": MessageLookupByLibrary.simpleMessage("推荐"),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage("保留配置默认值"),
    "setupRegionNeutralDescription": MessageLookupByLibrary.simpleMessage(
      "不更改地区设置。",
    ),
    "setupRegionStepDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash 会根据你所在国家的网络调整 DNS、MTU 和直连路由。界面语言保持不变。",
    ),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage("你在哪里连接？"),
    "setupRegionUnchosen": MessageLookupByLibrary.simpleMessage(
      "如果不选择，当前的地区设置保持不变。",
    ),
    "setupRepeat": MessageLookupByLibrary.simpleMessage("重新检查"),
    "setupReport": MessageLookupByLibrary.simpleMessage("检查报告"),
    "setupRequestPermission": MessageLookupByLibrary.simpleMessage("允许连接"),
    "setupRestart": MessageLookupByLibrary.simpleMessage("设置连接"),
    "setupResume": MessageLookupByLibrary.simpleMessage("继续设置"),
    "setupRouteChanged": MessageLookupByLibrary.simpleMessage(
      "检查期间路由已更改。请重新检查当前连接。",
    ),
    "setupSafeMode": MessageLookupByLibrary.simpleMessage(
      "安全模式不会启动真实连接。请保存设置，或在普通构建中测试。",
    ),
    "setupSaveError": MessageLookupByLibrary.simpleMessage("无法保存您的选择，请重试。"),
    "setupSaveWithoutConnection": MessageLookupByLibrary.simpleMessage(
      "保存但不连接",
    ),
    "setupSavedDescription": MessageLookupByLibrary.simpleMessage(
      "已保存您的选择。准备好后可从控制面板连接。",
    ),
    "setupSavedTitle": MessageLookupByLibrary.simpleMessage("稍后连接"),
    "setupStepStatus": m138,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "已保存您的选择。之前的连接未停止。",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage("检查已停止"),
    "setupTipCoverage": MessageLookupByLibrary.simpleMessage(
      "选择其他接管范围：有些网络会拦截 VPN 连接。",
    ),
    "setupTipNetwork": MessageLookupByLibrary.simpleMessage(
      "确认不使用 ReClash 时网络正常。",
    ),
    "setupTipProfile": MessageLookupByLibrary.simpleMessage(
      "更新配置文件，或在设置完成后选择其他服务器。",
    ),
    "setupTipsTitle": MessageLookupByLibrary.simpleMessage("可以尝试"),
    "setupTitle": MessageLookupByLibrary.simpleMessage("首次连接"),
    "setupTryServer": m139,
    "setupUnavailable": MessageLookupByLibrary.simpleMessage("无响应"),
    "setupUnconfirmedDescription": MessageLookupByLibrary.simpleMessage(
      "连接已启动，但选定路由未提供足够结果。",
    ),
    "setupUnconfirmedTitle": MessageLookupByLibrary.simpleMessage("未能确认连接"),
    "setupUnknownError": MessageLookupByLibrary.simpleMessage(
      "操作未完成。请重试或查看详情。",
    ),
    "shareLinkUnreadable": m140,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage("无法从链接中读取代理"),
    "shareQrcodeTip": MessageLookupByLibrary.simpleMessage(
      "在另一台设备上用 ReClash 扫码即可导入此配置。",
    ),
    "show": MessageLookupByLibrary.simpleMessage("显示"),
    "showLess": MessageLookupByLibrary.simpleMessage("收起"),
    "showMore": MessageLookupByLibrary.simpleMessage("展开"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "通知栏显示停止按钮",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("显示密码"),
    "sidebar": MessageLookupByLibrary.simpleMessage("侧边栏"),
    "sidebarBlur": MessageLookupByLibrary.simpleMessage("侧边栏背景模糊"),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "背景模糊会让侧边栏透出窗口后方的桌面。",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("静默启动"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage("静默启动时不显示窗口。"),
    "singleAdd": MessageLookupByLibrary.simpleMessage("单条添加"),
    "singleImport": MessageLookupByLibrary.simpleMessage("单条导入"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "这里只能填写一条链接，多条请在列表的快速编辑中填写",
    ),
    "singleValueTip": m141,
    "size": MessageLookupByLibrary.simpleMessage("尺寸"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage("跳过证书验证"),
    "skipDomain": MessageLookupByLibrary.simpleMessage("跳过域名"),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage("嗅探到跳过域名中的域名时不予采用。"),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage("跳过目标地址"),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage("跳过来源地址"),
    "slide": MessageLookupByLibrary.simpleMessage("滑动"),
    "sliders": MessageLookupByLibrary.simpleMessage("滑块"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("协议"),
    "sniffer": MessageLookupByLibrary.simpleMessage("域名嗅探"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "域名嗅探从 TLS、HTTP、QUIC 流量中识别域名，供规则匹配。",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socks端口"),
    "softStyle": MessageLookupByLibrary.simpleMessage("柔和"),
    "sort": MessageLookupByLibrary.simpleMessage("排序"),
    "source": MessageLookupByLibrary.simpleMessage("来源"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("源IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("特殊代理"),
    "specialRules": MessageLookupByLibrary.simpleMessage("特殊规则"),
    "spectrum": MessageLookupByLibrary.simpleMessage("光谱"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("网速统计"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("分流策略"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage("分流策略不能为空"),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSIDs为空"),
    "stackMode": MessageLookupByLibrary.simpleMessage("栈模式"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("堆栈信息"),
    "standard": MessageLookupByLibrary.simpleMessage("标准"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "标准模式，在配置的基础上附加规则",
    ),
    "start": MessageLookupByLibrary.simpleMessage("启动"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage("从零开始"),
    "startVpn": MessageLookupByLibrary.simpleMessage("正在启动VPN…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage("启动与后台"),
    "status": MessageLookupByLibrary.simpleMessage("状态"),
    "statusDesc": MessageLookupByLibrary.simpleMessage("关闭 DNS 后将使用系统 DNS。"),
    "stop": MessageLookupByLibrary.simpleMessage("暂停"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("正在停止VPN…"),
    "strategy": MessageLookupByLibrary.simpleMessage("策略"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("严格路由"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "严格路由防止 DNS 等流量绕过虚拟网卡，关闭 IPv6 时会阻断本机的 IPv6 连接。",
    ),
    "style": MessageLookupByLibrary.simpleMessage("风格"),
    "submit": MessageLookupByLibrary.simpleMessage("提交"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage("自动"),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientClashMeta": MessageLookupByLibrary.simpleMessage(
      "Clash Meta",
    ),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage(
      "自定义 User-Agent",
    ),
    "subscriptionClientCustomUserAgent": MessageLookupByLibrary.simpleMessage(
      "User-Agent",
    ),
    "subscriptionClientCustomUserAgentInvalid":
        MessageLookupByLibrary.simpleMessage("请输入不含控制字符的有效 User-Agent。"),
    "subscriptionClientDeviceDataHint": MessageLookupByLibrary.simpleMessage(
      "选择客户端不会发送设备身份信息。",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientReclash": MessageLookupByLibrary.simpleMessage(
      "ReClash",
    ),
    "subscriptionClientRequestAs": MessageLookupByLibrary.simpleMessage(
      "请求客户端",
    ),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box / Karing",
    ),
    "subscriptionClientUrlOnly": MessageLookupByLibrary.simpleMessage(
      "这些设置适用于订阅 URL。代理链接将在本地导入。",
    ),
    "subscriptionClientV2rayng": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionCompatibilityAgeKey": MessageLookupByLibrary.simpleMessage(
      "请输入 AGE 密钥以检查此订阅。",
    ),
    "subscriptionCompatibilityApplyPrepared":
        MessageLookupByLibrary.simpleMessage("应用已检查的结果"),
    "subscriptionCompatibilityAuthorization":
        MessageLookupByLibrary.simpleMessage("服务器拒绝授权，已停止客户端选择。"),
    "subscriptionCompatibilityCheck": MessageLookupByLibrary.simpleMessage(
      "检查",
    ),
    "subscriptionCompatibilityCheckFailed":
        MessageLookupByLibrary.simpleMessage("无法获取兼容的订阅。原有配置未更改。"),
    "subscriptionCompatibilityCheckHint": MessageLookupByLibrary.simpleMessage(
      "使用当前表单值检查，不保存或重启 VPN。检查的是配置解析，而不是节点可用性。",
    ),
    "subscriptionCompatibilityForgetConsent":
        MessageLookupByLibrary.simpleMessage("重新询问导入损失"),
    "subscriptionCompatibilityHideUrl": MessageLookupByLibrary.simpleMessage(
      "隐藏订阅URL",
    ),
    "subscriptionCompatibilityLastSuccessful":
        MessageLookupByLibrary.simpleMessage("上次成功的客户端"),
    "subscriptionCompatibilityNeedsReview":
        MessageLookupByLibrary.simpleMessage("导入会忽略部分源数据。应用前请检查损失内容。"),
    "subscriptionCompatibilityPinSuccessful":
        MessageLookupByLibrary.simpleMessage("使用此客户端"),
    "subscriptionCompatibilityPrepared": m142,
    "subscriptionCompatibilityPreparedHint":
        MessageLookupByLibrary.simpleMessage("Core 已解析此结果，但尚未保存或应用。"),
    "subscriptionCompatibilityRateLimited":
        MessageLookupByLibrary.simpleMessage("服务器限制了请求，请稍后重试。"),
    "subscriptionCompatibilityShowUrl": MessageLookupByLibrary.simpleMessage(
      "显示订阅URL",
    ),
    "subscriptionCompatibilitySuperseded": MessageLookupByLibrary.simpleMessage(
      "表单或配置已更改，请重新检查订阅。",
    ),
    "subscriptionCompatibilityTimeout": MessageLookupByLibrary.simpleMessage(
      "订阅检查超时。",
    ),
    "subscriptionCompatibilityTitle": MessageLookupByLibrary.simpleMessage(
      "兼容性",
    ),
    "subscriptionCompatibilityTransport": MessageLookupByLibrary.simpleMessage(
      "连接失败，已停止客户端选择。",
    ),
    "subscriptionDeviceLimit": MessageLookupByLibrary.simpleMessage(
      "此订阅没有可用的设备名额。请在服务提供商账户中移除一台设备后重试。",
    ),
    "subscriptionDeviceRequired": MessageLookupByLibrary.simpleMessage(
      "此订阅需要注册设备，请按照服务提供商的说明操作。",
    ),
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage("订阅已过期"),
    "subscriptionExpiresInDays": m143,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage("订阅今天到期"),
    "subscriptionIdentityDetails": MessageLookupByLibrary.simpleMessage(
      "同时发送操作系统和设备型号",
    ),
    "subscriptionIdentityDetailsDisclosure":
        MessageLookupByLibrary.simpleMessage("设备标识符还会附带操作系统版本和设备型号。"),
    "subscriptionIdentityDisclosure": MessageLookupByLibrary.simpleMessage(
      "会向此订阅源发送稳定的假名设备 ID。这不是硬件证明，且同意仅保存在此设备上。",
    ),
    "subscriptionIdentityRegionWarning": MessageLookupByLibrary.simpleMessage(
      "关闭 HWID 发送后，许多订阅将无法使用。",
    ),
    "subscriptionIdentitySettingsTitle": MessageLookupByLibrary.simpleMessage(
      "订阅身份信息",
    ),
    "subscriptionIdentityTitle": MessageLookupByLibrary.simpleMessage(
      "发送 HWID",
    ),
    "subscriptionIdentityUseGlobal": MessageLookupByLibrary.simpleMessage(
      "使用全局设置",
    ),
    "subscriptionImportAdd": m144,
    "subscriptionImportAllAdded": m145,
    "subscriptionImportFormatClash": MessageLookupByLibrary.simpleMessage(
      "Clash 配置",
    ),
    "subscriptionImportFormatEncrypted": MessageLookupByLibrary.simpleMessage(
      "加密订阅",
    ),
    "subscriptionImportFormatShareLinks": MessageLookupByLibrary.simpleMessage(
      "代理链接",
    ),
    "subscriptionImportFormatUnknown": MessageLookupByLibrary.simpleMessage(
      "未知格式",
    ),
    "subscriptionImportIgnoredSections": MessageLookupByLibrary.simpleMessage(
      "配置段落",
    ),
    "subscriptionImportLeftOutHint": MessageLookupByLibrary.simpleMessage(
      "ReClash 会以自身设置代替来源中的这些部分。",
    ),
    "subscriptionImportLeftOutTitle": MessageLookupByLibrary.simpleMessage(
      "不会保留",
    ),
    "subscriptionImportNoNodes": MessageLookupByLibrary.simpleMessage(
      "没有受支持的服务器",
    ),
    "subscriptionImportOtherLosses": MessageLookupByLibrary.simpleMessage(
      "部分服务器选项不受支持，将被忽略",
    ),
    "subscriptionImportPartial": m146,
    "subscriptionImportReasonBandwidth": MessageLookupByLibrary.simpleMessage(
      "缺少上传和下载速度",
    ),
    "subscriptionImportReasonProtocol": MessageLookupByLibrary.simpleMessage(
      "不支持该协议",
    ),
    "subscriptionImportReasonTransport": MessageLookupByLibrary.simpleMessage(
      "不支持该传输方式",
    ),
    "subscriptionImportRememberConsent": MessageLookupByLibrary.simpleMessage(
      "此订阅不再询问",
    ),
    "subscriptionImportRememberConsentHint":
        MessageLookupByLibrary.simpleMessage("如果还有其他内容无法导入，将再次询问。"),
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "部分内容无法导入",
    ),
    "subscriptionImportShowAll": m147,
    "subscriptionImportSkippedTitle": MessageLookupByLibrary.simpleMessage(
      "不会添加",
    ),
    "subscriptionImportSourceFormat": m148,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage("订阅信息"),
    "subscriptionKindDev": MessageLookupByLibrary.simpleMessage("开发"),
    "subscriptionKindPromo": MessageLookupByLibrary.simpleMessage("推广"),
    "subscriptionKindTest": MessageLookupByLibrary.simpleMessage("测试"),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage("订阅提醒"),
    "subscriptionProvider": MessageLookupByLibrary.simpleMessage("订阅"),
    "subscriptionProviderAccount": MessageLookupByLibrary.simpleMessage("账户"),
    "subscriptionProviderBuyPlan": MessageLookupByLibrary.simpleMessage("购买套餐"),
    "subscriptionProviderBuyTraffic": MessageLookupByLibrary.simpleMessage(
      "购买流量",
    ),
    "subscriptionProviderLogo": MessageLookupByLibrary.simpleMessage("徽标链接"),
    "subscriptionProviderSupport": MessageLookupByLibrary.simpleMessage("支持"),
    "subscriptionProviderWebsite": MessageLookupByLibrary.simpleMessage("网站"),
    "subscriptionTrafficLow": m149,
    "subscriptionUseProviderInterval": MessageLookupByLibrary.simpleMessage(
      "使用服务提供方的更新间隔",
    ),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage("输入 sudo 密码"),
    "suspended": MessageLookupByLibrary.simpleMessage("挂起中…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("切换配置"),
    "sync": MessageLookupByLibrary.simpleMessage("同步"),
    "system": MessageLookupByLibrary.simpleMessage("系统"),
    "systemApp": MessageLookupByLibrary.simpleMessage("系统应用"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("系统代理"),
    "tab": MessageLookupByLibrary.simpleMessage("标签页"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("选项卡动画"),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage("点击图标重试"),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("点击授权"),
    "target": MessageLookupByLibrary.simpleMessage("目标"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP并发"),
    "telegramAppUnavailable": MessageLookupByLibrary.simpleMessage(
      "无法在此设备上打开 Telegram。",
    ),
    "telegramLinkTitle": MessageLookupByLibrary.simpleMessage("Telegram"),
    "telegramOpen": MessageLookupByLibrary.simpleMessage("打开 Telegram"),
    "telegramWebFallback": MessageLookupByLibrary.simpleMessage("在浏览器中打开"),
    "testInterval": MessageLookupByLibrary.simpleMessage("测试间隔"),
    "testUrl": MessageLookupByLibrary.simpleMessage("测速链接"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("使用时测试"),
    "textScale": MessageLookupByLibrary.simpleMessage("文本缩放"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage("应用内的文字将以这个大小显示"),
    "theme": MessageLookupByLibrary.simpleMessage("主题"),
    "themeColor": MessageLookupByLibrary.simpleMessage("主题色彩"),
    "themeMode": MessageLookupByLibrary.simpleMessage("主题模式"),
    "tight": MessageLookupByLibrary.simpleMessage("紧凑"),
    "time": MessageLookupByLibrary.simpleMessage("时间"),
    "timeout": MessageLookupByLibrary.simpleMessage("超时"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("氛围"),
    "tip": MessageLookupByLibrary.simpleMessage("提示"),
    "tk": MessageLookupByLibrary.simpleMessage("土库曼语"),
    "toggle": MessageLookupByLibrary.simpleMessage("切换"),
    "tolerance": MessageLookupByLibrary.simpleMessage("容差"),
    "tools": MessageLookupByLibrary.simpleMessage("工具"),
    "toolsAction": MessageLookupByLibrary.simpleMessage("操作"),
    "toolsChoose": MessageLookupByLibrary.simpleMessage("选择分区或搜索设置"),
    "toolsCloseConnectionsConfirm": MessageLookupByLibrary.simpleMessage(
      "这将关闭所有活动连接。是否继续？",
    ),
    "toolsCompleted": MessageLookupByLibrary.simpleMessage("操作已完成"),
    "toolsConfiguration": MessageLookupByLibrary.simpleMessage("配置"),
    "toolsData": MessageLookupByLibrary.simpleMessage("资源与数据"),
    "toolsEmpty": MessageLookupByLibrary.simpleMessage("未找到匹配的设置或操作"),
    "toolsInformation": MessageLookupByLibrary.simpleMessage("信息与调试"),
    "toolsLastUsed": MessageLookupByLibrary.simpleMessage("最近使用"),
    "toolsNeedsAuthentication": MessageLookupByLibrary.simpleMessage(
      "请先启用身份验证",
    ),
    "toolsNeedsController": MessageLookupByLibrary.simpleMessage("请先启用外部控制器"),
    "toolsNeedsCore": MessageLookupByLibrary.simpleMessage("请先启动内核"),
    "toolsNeedsCustomInterface": MessageLookupByLibrary.simpleMessage(
      "请先选择自定义网络接口",
    ),
    "toolsNeedsMipsStack": MessageLookupByLibrary.simpleMessage(
      "请先选择 MIPS 网络栈",
    ),
    "toolsNeedsOverride": MessageLookupByLibrary.simpleMessage(
      "请先在 DNS 页面添加此覆盖项",
    ),
    "toolsNeedsWebdav": MessageLookupByLibrary.simpleMessage("请先配置 WebDAV"),
    "toolsObservation": MessageLookupByLibrary.simpleMessage("诊断"),
    "toolsPin": MessageLookupByLibrary.simpleMessage("固定"),
    "toolsPinned": MessageLookupByLibrary.simpleMessage("已固定"),
    "toolsRestartCore": MessageLookupByLibrary.simpleMessage("重启内核"),
    "toolsResults": m150,
    "toolsRun": MessageLookupByLibrary.simpleMessage("执行"),
    "toolsSection": MessageLookupByLibrary.simpleMessage("分区"),
    "toolsSetting": MessageLookupByLibrary.simpleMessage("设置"),
    "toolsUnpin": MessageLookupByLibrary.simpleMessage("取消固定"),
    "toolsUpdateResources": MessageLookupByLibrary.simpleMessage("更新资源"),
    "toolsUpdateResourcesConfirm": MessageLookupByLibrary.simpleMessage(
      "更新规则和脚本可能重新应用配置并影响连接。是否继续？",
    ),
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("购买流量"),
    "torch": MessageLookupByLibrary.simpleMessage("手电筒"),
    "total": MessageLookupByLibrary.simpleMessage("总计"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("下载总量"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("总流量"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("上传总量"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxy端口"),
    "traffic": MessageLookupByLibrary.simpleMessage("流量"),
    "trafficPeak": m151,
    "trafficTotal": m152,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("流量统计"),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage("提交翻译修改建议"),
    "transport": MessageLookupByLibrary.simpleMessage("传输协议"),
    "transportHeaders": m153,
    "trayIcon": MessageLookupByLibrary.simpleMessage("托盘图标"),
    "trayIconColor": MessageLookupByLibrary.simpleMessage("彩色"),
    "trayIconDark": MessageLookupByLibrary.simpleMessage("黑色"),
    "trayIconLight": MessageLookupByLibrary.simpleMessage("白色"),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage("受信任的网络"),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "连接这些网络时 VPN 会自动暂停",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "当前网络受信任 — 在此网络中会暂停 VPN",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("虚拟网卡"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "虚拟网卡授权失败，已关闭。",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage("虚拟网卡仅在管理员模式生效。"),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "添加的项会覆写所有配置的虚拟网卡设置，未添加的项沿用配置自身的设置。自定义配置自己添加的项优先。",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("关闭"),
    "turnOn": MessageLookupByLibrary.simpleMessage("开启"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage("UDP 中继模式"),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("UDP 超时"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "UDP 超时以秒为单位，仅在 gvisor、system 和 mixed 栈生效。",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("极致"),
    "undo": MessageLookupByLibrary.simpleMessage("撤销"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("统一延迟"),
    "unknown": MessageLookupByLibrary.simpleMessage("未知"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage("未知网络错误"),
    "unmaximize": MessageLookupByLibrary.simpleMessage("向下还原"),
    "unnamed": MessageLookupByLibrary.simpleMessage("未命名"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("取消置顶"),
    "update": MessageLookupByLibrary.simpleMessage("更新"),
    "updateAllowAutomatic": MessageLookupByLibrary.simpleMessage("允许自动安装"),
    "updateAutoConsentDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash 可以安装已验证且符合条件的稳定更新，无需每次询问。它绝不会断开你的 VPN。Android 仍可能要求确认安装。",
    ),
    "updateAutoConsentTitle": MessageLookupByLibrary.simpleMessage("允许自动安装吗？"),
    "updateAutoInstall": MessageLookupByLibrary.simpleMessage("自动安装"),
    "updateCancelDownload": MessageLookupByLibrary.simpleMessage("取消下载"),
    "updateChannel": MessageLookupByLibrary.simpleMessage("更新通道"),
    "updateChannelPre": MessageLookupByLibrary.simpleMessage("预发布版"),
    "updateChannelRelease": MessageLookupByLibrary.simpleMessage("正式版"),
    "updateCheckAutomatically": MessageLookupByLibrary.simpleMessage("自动检查"),
    "updateCheckFailed": MessageLookupByLibrary.simpleMessage("无法检查更新"),
    "updateCheckFailedDescription": MessageLookupByLibrary.simpleMessage(
      "请检查连接后重试。",
    ),
    "updateCheckingTitle": MessageLookupByLibrary.simpleMessage("正在检查更新…"),
    "updateCloseWindow": MessageLookupByLibrary.simpleMessage("关闭窗口"),
    "updateConfirmationDescription": MessageLookupByLibrary.simpleMessage(
      "Android 需要你的批准。继续以打开系统确认界面。",
    ),
    "updateConfirmationTitle": MessageLookupByLibrary.simpleMessage(
      "请在 Android 中确认",
    ),
    "updateContinueBackground": MessageLookupByLibrary.simpleMessage("在后台继续"),
    "updateContinueInstall": MessageLookupByLibrary.simpleMessage("继续安装"),
    "updateCurrentTitle": MessageLookupByLibrary.simpleMessage("已是最新版本"),
    "updateDesktopDescription": MessageLookupByLibrary.simpleMessage(
      "在此平台上，ReClash 会打开版本页面。请自行下载并安装更新。",
    ),
    "updateDirectUnavailable": MessageLookupByLibrary.simpleMessage(
      "此设备没有可验证的下载。请打开版本页面选择安装包。",
    ),
    "updateDisconnectInstall": MessageLookupByLibrary.simpleMessage("断开并安装"),
    "updateDoNotEnable": MessageLookupByLibrary.simpleMessage("保持手动安装"),
    "updateDownloadAction": MessageLookupByLibrary.simpleMessage("下载更新"),
    "updateDownloadAgain": MessageLookupByLibrary.simpleMessage("重新下载"),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage("无法下载更新"),
    "updateDownloadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "已下载的部分已保存。请检查连接，然后继续下载。",
    ),
    "updateGotIt": MessageLookupByLibrary.simpleMessage("知道了"),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage("无法启动软件包安装程序"),
    "updateInstallFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Android 未完成安装。准备好后请重试。",
    ),
    "updateInstallNow": MessageLookupByLibrary.simpleMessage("立即安装"),
    "updateInstalledTitle": MessageLookupByLibrary.simpleMessage("更新已安装"),
    "updateInstalledVersion": m154,
    "updateInstallingDescription": MessageLookupByLibrary.simpleMessage(
      "Android 正在完成安装。此时 ReClash 可能会关闭。",
    ),
    "updateInstallingTitle": MessageLookupByLibrary.simpleMessage("正在安装更新"),
    "updateMinutes": m155,
    "updateNotNow": MessageLookupByLibrary.simpleMessage("暂不"),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage("暂无发布说明。"),
    "updateOfferTitle": MessageLookupByLibrary.simpleMessage("有可用更新"),
    "updateOpenAndroidSettings": MessageLookupByLibrary.simpleMessage(
      "打开 Android 设置",
    ),
    "updatePackageDevice": MessageLookupByLibrary.simpleMessage("适用设备的构建"),
    "updatePackageSize": MessageLookupByLibrary.simpleMessage("下载大小"),
    "updatePackageVerification": MessageLookupByLibrary.simpleMessage("安装包检查"),
    "updatePackageVerificationPending": MessageLookupByLibrary.simpleMessage(
      "下载后、安装前进行检查",
    ),
    "updatePackageVerified": MessageLookupByLibrary.simpleMessage(
      "完整性、应用身份和签名已验证",
    ),
    "updatePauseAction": MessageLookupByLibrary.simpleMessage("暂停"),
    "updatePausedTitle": MessageLookupByLibrary.simpleMessage("下载已暂停"),
    "updatePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "请允许 ReClash 安装来自此来源的应用，然后返回继续。",
    ),
    "updatePermissionTitle": MessageLookupByLibrary.simpleMessage(
      "需要 Android 权限",
    ),
    "updatePreferencesDescription": MessageLookupByLibrary.simpleMessage(
      "分别设置检查、下载和安装。",
    ),
    "updatePreferencesSaveFailed": MessageLookupByLibrary.simpleMessage(
      "偏好未保存。请重试；自动安装尚未启用。",
    ),
    "updatePreferencesTitle": MessageLookupByLibrary.simpleMessage("更新偏好"),
    "updatePreload": MessageLookupByLibrary.simpleMessage("通过 Wi-Fi 预下载"),
    "updateReadyTitle": MessageLookupByLibrary.simpleMessage("可以安装了"),
    "updateReleaseDetails": MessageLookupByLibrary.simpleMessage("版本详情"),
    "updateRemainingTime": m156,
    "updateResumeAction": MessageLookupByLibrary.simpleMessage("继续下载"),
    "updateResumeShort": MessageLookupByLibrary.simpleMessage("继续"),
    "updateRetryCheck": MessageLookupByLibrary.simpleMessage("再次检查"),
    "updateRetryInstall": MessageLookupByLibrary.simpleMessage("重试安装"),
    "updateSeconds": m157,
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "查看完整发布说明",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage("显示所有更改"),
    "updateTitle": MessageLookupByLibrary.simpleMessage("更新"),
    "updateTransferSpeed": m158,
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage("无法验证下载更新的完整性。"),
    "updateVerifyFailedDescription": MessageLookupByLibrary.simpleMessage(
      "文件、版本或签名未通过检查。请重新下载后再试。",
    ),
    "updateVerifyFailedTitle": MessageLookupByLibrary.simpleMessage("无法安装此安装包"),
    "updateVerifyingTitle": MessageLookupByLibrary.simpleMessage("正在检查更新"),
    "updateVpnDescription": MessageLookupByLibrary.simpleMessage(
      "安装会短暂关闭 ReClash。只有在可以中断连接时才断开。",
    ),
    "updateVpnTitle": MessageLookupByLibrary.simpleMessage("VPN 仍在运行"),
    "upload": MessageLookupByLibrary.simpleMessage("上传"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage("上行带宽"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("URL 方案"),
    "urlSchemeAction": MessageLookupByLibrary.simpleMessage("操作"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("添加订阅"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage("添加订阅 URL，可选名称。"),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "无法验证加密链接。它可能已损坏或使用了其他密钥。",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("生成链接"),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("关闭应用"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage("按设置的关闭行为操作。"),
    "urlSchemeConfigCounts": m159,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "粘贴 YAML 或 JSON 配置",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage("配置内容"),
    "urlSchemeConfirmMessage": m160,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage("外部应用命令"),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "外部链接的连接和关闭命令需要确认。",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("连接"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage("使用所选配置连接。"),
    "urlSchemeConnection": MessageLookupByLibrary.simpleMessage("连接"),
    "urlSchemeContentFormat": MessageLookupByLibrary.simpleMessage("内容格式"),
    "urlSchemeConversionWarning": MessageLookupByLibrary.simpleMessage(
      "转换会省略部分内容。请在导入时审阅并确认这些更改。",
    ),
    "urlSchemeCopyFailed": MessageLookupByLibrary.simpleMessage("无法复制链接。请重试。"),
    "urlSchemeCopyLink": MessageLookupByLibrary.simpleMessage("复制链接"),
    "urlSchemeDeliveryError": MessageLookupByLibrary.simpleMessage(
      "无法传递链接，或待处理队列已满。请在当前操作完成后重试。",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("断开连接"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "停止连接，保留所选配置。",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage("内嵌配置"),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage("示例配置文件"),
    "urlSchemeFormats": MessageLookupByLibrary.simpleMessage("格式"),
    "urlSchemeFormatsTip": MessageLookupByLibrary.simpleMessage(
      "链接格式。请将占位符替换为你的 URL 或数据。",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage("导入配置"),
    "urlSchemeImportConfirm": m161,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "将 YAML 或 JSON 配置嵌入链接。",
    ),
    "urlSchemeInspect": MessageLookupByLibrary.simpleMessage("检查链接"),
    "urlSchemeInspectHint": MessageLookupByLibrary.simpleMessage("粘贴应用或配置文件链接"),
    "urlSchemeInspectTip": MessageLookupByLibrary.simpleMessage(
      "检查仅在此设备上进行。不会打开链接、下载订阅或导入配置文件。",
    ),
    "urlSchemeInspectionLimit": MessageLookupByLibrary.simpleMessage(
      "链接结构有效。订阅可用性和内核验证仅在导入时检查。",
    ),
    "urlSchemeInspectionResult": MessageLookupByLibrary.simpleMessage("检查结果"),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage("安装配置"),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "使用 Clash 客户端通用的订阅链接格式。",
    ),
    "urlSchemeInvalidBase64": MessageLookupByLibrary.simpleMessage(
      "内嵌配置不是有效的 UTF-8 Base64 数据。",
    ),
    "urlSchemeInvalidLink": MessageLookupByLibrary.simpleMessage(
      "链接格式错误。请检查结构和百分号编码。",
    ),
    "urlSchemeInvalidName": MessageLookupByLibrary.simpleMessage(
      "配置文件名称不能超过 64 个字符，且不能包含控制字符。",
    ),
    "urlSchemeInvalidUrl": MessageLookupByLibrary.simpleMessage(
      "请输入有效的 HTTP 或 HTTPS 订阅 URL。",
    ),
    "urlSchemeMissingPayload": MessageLookupByLibrary.simpleMessage(
      "链接缺少订阅 URL 或配置。",
    ),
    "urlSchemeNoExecution": MessageLookupByLibrary.simpleMessage("未执行任何操作。"),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage("显示应用"),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage(
      "将 ReClash 显示在前台。",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("参数"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "无法读取剪贴板。请手动粘贴链接。",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage("链接"),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "输入 URL 或配置以生成链接。",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "链接可能包含令牌或凭据，请谨慎分享。",
    ),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("配置文件"),
    "urlSchemeProxyLinks": MessageLookupByLibrary.simpleMessage("代理分享链接"),
    "urlSchemeRecognized": MessageLookupByLibrary.simpleMessage("已识别链接"),
    "urlSchemeSetupRequired": MessageLookupByLibrary.simpleMessage(
      "使用外部连接命令前，请先完成连接设置。",
    ),
    "urlSchemeSupportedLinks": MessageLookupByLibrary.simpleMessage("支持的导入链接"),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage("切换连接"),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "未连接时连接，已连接时断开。",
    ),
    "urlSchemeTooDeep": MessageLookupByLibrary.simpleMessage("链接的嵌套封装层数过多。"),
    "urlSchemeTooLarge": MessageLookupByLibrary.simpleMessage(
      "链接超过 4 MB，或内嵌配置超过 2 MB。",
    ),
    "urlSchemeUnknownCommand": MessageLookupByLibrary.simpleMessage(
      "不支持此链接命令。",
    ),
    "urlSchemeUnsupportedEncryption": MessageLookupByLibrary.simpleMessage(
      "不支持此加密版本。请索取普通订阅链接。",
    ),
    "urlSchemeUseExample": MessageLookupByLibrary.simpleMessage("使用示例"),
    "urlTip": m162,
    "useHosts": MessageLookupByLibrary.simpleMessage("使用Hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("使用系统Hosts"),
    "usedShort": MessageLookupByLibrary.simpleMessage("已用"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("已用流量"),
    "userAgent": MessageLookupByLibrary.simpleMessage("用户代理"),
    "username": MessageLookupByLibrary.simpleMessage("用户名"),
    "uz": MessageLookupByLibrary.simpleMessage("乌兹别克语"),
    "value": MessageLookupByLibrary.simpleMessage("值"),
    "view": MessageLookupByLibrary.simpleMessage("查看"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("虚拟 IPv4"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("鲜明"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "检测到VPN相关配置改动",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VPN 通过 VpnService 自动路由系统所有流量。",
    ),
    "wallpaperBlur": MessageLookupByLibrary.simpleMessage("模糊"),
    "wallpaperCardOpacity": MessageLookupByLibrary.simpleMessage("卡片不透明度"),
    "wallpaperDimming": MessageLookupByLibrary.simpleMessage("调暗"),
    "wallpaperEffects": MessageLookupByLibrary.simpleMessage("图片调整"),
    "wallpaperEnabled": MessageLookupByLibrary.simpleMessage("使用自定义背景"),
    "wallpaperFit": MessageLookupByLibrary.simpleMessage("图片适配方式"),
    "wallpaperFitContain": MessageLookupByLibrary.simpleMessage("适应"),
    "wallpaperFitCover": MessageLookupByLibrary.simpleMessage("填充"),
    "wallpaperFitFill": MessageLookupByLibrary.simpleMessage("拉伸"),
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage("水平位置"),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "请选择有效的 PNG、JPEG 或 WebP 图片。",
    ),
    "wallpaperImageLabel": m163,
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("构图"),
    "wallpaperLibraryFull": m164,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage("图片不透明度"),
    "wallpaperReadability": MessageLookupByLibrary.simpleMessage("可读性"),
    "wallpaperRemove": MessageLookupByLibrary.simpleMessage("移除图片"),
    "wallpaperReset": MessageLookupByLibrary.simpleMessage("重置效果"),
    "wallpaperResetLayout": MessageLookupByLibrary.simpleMessage("重置构图"),
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
    "wallpaperUnavailable": MessageLookupByLibrary.simpleMessage("图片不可用"),
    "wallpaperVerticalPosition": MessageLookupByLibrary.simpleMessage("垂直位置"),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage("WebDAV配置"),
    "webDashboard": MessageLookupByLibrary.simpleMessage("网页面板"),
    "webDashboardAccess": MessageLookupByLibrary.simpleMessage("访问"),
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage("面板访问已终止"),
    "webDashboardAccessInApp": MessageLookupByLibrary.simpleMessage("在应用内"),
    "webDashboardAccessInBrowser": MessageLookupByLibrary.simpleMessage(
      "在浏览器中",
    ),
    "webDashboardAccessOff": MessageLookupByLibrary.simpleMessage("关闭"),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "访问仅限本机，并受密钥保护。打开面板不会更改已保存的外部控制器设置。",
    ),
    "webDashboardApplyFailed": MessageLookupByLibrary.simpleMessage(
      "无法应用面板配置。",
    ),
    "webDashboardArchiveFailed": MessageLookupByLibrary.simpleMessage(
      "下载文件不是有效的面板压缩包。",
    ),
    "webDashboardAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "核心拒绝了凭据，请重新打开面板。",
    ),
    "webDashboardBrowserAccess": MessageLookupByLibrary.simpleMessage(
      "浏览器访问持续到手动终止或退出 ReClash",
    ),
    "webDashboardBusy": MessageLookupByLibrary.simpleMessage("另一项面板操作正在进行。"),
    "webDashboardCancelled": MessageLookupByLibrary.simpleMessage("面板操作已取消。"),
    "webDashboardChecksumFailed": MessageLookupByLibrary.simpleMessage(
      "面板校验和与固定版本不一致。",
    ),
    "webDashboardCoreUnavailable": MessageLookupByLibrary.simpleMessage(
      "核心尚未就绪。",
    ),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage("管理核心的本地网页面板"),
    "webDashboardDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "无法下载面板，请重试。",
    ),
    "webDashboardDownloading": MessageLookupByLibrary.simpleMessage("正在下载面板"),
    "webDashboardEmbeddedAccess": MessageLookupByLibrary.simpleMessage(
      "关闭面板后终止访问",
    ),
    "webDashboardEndAccess": MessageLookupByLibrary.simpleMessage("终止面板访问"),
    "webDashboardExtracting": MessageLookupByLibrary.simpleMessage("正在解压面板"),
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("面板"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage("安装面板"),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "首次打开时下载所选面板。使用固定版本并进行 SHA-256 校验。",
    ),
    "webDashboardLaunchFailed": MessageLookupByLibrary.simpleMessage(
      "无法打开浏览器。",
    ),
    "webDashboardNoAccess": MessageLookupByLibrary.simpleMessage("无面板会话"),
    "webDashboardNoProfile": MessageLookupByLibrary.simpleMessage(
      "打开面板前请选择配置。",
    ),
    "webDashboardNotInstalled": MessageLookupByLibrary.simpleMessage("未安装"),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage("打开面板"),
    "webDashboardOpenInBrowser": MessageLookupByLibrary.simpleMessage(
      "在浏览器中打开",
    ),
    "webDashboardReload": MessageLookupByLibrary.simpleMessage("重新加载"),
    "webDashboardRestricted": MessageLookupByLibrary.simpleMessage(
      "控制面板访问已被您的服务商禁用。",
    ),
    "webDashboardSafeMode": MessageLookupByLibrary.simpleMessage(
      "安全模式下禁用面板访问。",
    ),
    "webDashboardStorageFailed": MessageLookupByLibrary.simpleMessage(
      "无法安全读取或替换面板文件。",
    ),
    "webDashboardTooLarge": MessageLookupByLibrary.simpleMessage(
      "面板压缩包超过允许的大小。",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "核心未提供此面板。",
    ),
    "webDashboardVerifying": MessageLookupByLibrary.simpleMessage("正在校验下载"),
    "webDashboardVersion": MessageLookupByLibrary.simpleMessage("版本"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("白名单模式"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("写入系统"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "写入系统会同时设置系统时钟，Android 上不生效。",
    ),
    "yearsAgo": m165,
    "yearsAgoShort": m166,
    "yes": MessageLookupByLibrary.simpleMessage("是"),
    "zhCN": MessageLookupByLibrary.simpleMessage("中文简体"),
  };
}
