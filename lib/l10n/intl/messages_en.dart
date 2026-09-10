// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(time) => "Bypassing DPI ${time}";

  static String m1(time) => "Connected ${time}";

  static String m2(code) =>
      "Windows refused to run ReClashCore.exe (error ${code}). An app control policy such as Smart App Control or AppLocker blocks unsigned programs; allow ReClash in that policy or turn it off, then try again.";

  static String m3(name) =>
      "The app failed to finish launching twice in a row. To break the loop, the profile ${name} has been deselected and automatic setup was skipped. You can select it again at any time.";

  static String m4(url) => "Do you want to create a profile from ${url}?";

  static String m5(count) =>
      "${Intl.plural(count, one: '1 day ago', other: '${count} days ago')}";

  static String m6(count) =>
      "${Intl.plural(count, one: '1 day left', other: '${count} days left')}";

  static String m7(label) =>
      "Are you sure you want to delete the selected ${label}?";

  static String m8(label) => "Are you sure you want to delete this ${label}?";

  static String m9(token) => "${token} is set by the app and will be dropped";

  static String m10(count) =>
      "${Intl.plural(count, zero: 'no arguments', one: '1 argument', other: '${count} arguments')}";

  static String m11(token) => "${token} needs a value";

  static String m12(token) => "${token} is not an option";

  static String m13(token) => "Unknown option ${token}";

  static String m14(count) =>
      "${count} routing categories use the ByeDPI engine";

  static String m15(presets, groups, domains) =>
      "${presets} presets · ${groups} groups · ${domains} hosts";

  static String m16(count) =>
      "${Intl.plural(count, one: '1 domain', other: '${count} domains')}";

  static String m17(count) => "Finished: ${count} strategies tested";

  static String m18(count) =>
      "Tries every known strategy against ${count} hosts through the engine; the current strategy is restored afterwards";

  static String m19(index, total) => "Testing ${index} of ${total}";

  static String m20(passed, total) => "${passed} of ${total} hosts up";

  static String m21(label) => "${label} details";

  static String m22(name) => "${name} installed";

  static String m23(count) =>
      "${count} evidence events were dropped under load; confidence was not increased.";

  static String m24(completed, total) =>
      "Checking connection: ${completed}/${total}";

  static String m25(layer) => "Connection issue: ${layer}";

  static String m26(completed, total) => "Step ${completed} of ${total}";

  static String m27(label) => "${label} cannot be empty";

  static String m28(count) =>
      "${Intl.plural(count, one: '1 entry', other: '${count} entries')}";

  static String m29(label) => "${label} already exists";

  static String m30(name) => "${name} is already up to date";

  static String m31(name) => "${name} updated";

  static String m32(time) => "${time} ago";

  static String m33(count) =>
      "${Intl.plural(count, one: '1 hour ago', other: '${count} hours ago')}";

  static String m34(count) =>
      "${Intl.plural(count, one: '1 hour', other: '${count} hours')}";

  static String m35(target) => "${target} is an invalid policy";

  static String m36(proxyName) => "${proxyName} is an invalid proxy";

  static String m37(providerName) =>
      "${providerName} is an invalid proxy provider";

  static String m38(subRule) => "${subRule} is an invalid SUB_RULE";

  static String m39(address) => "Or send JSON to ${address}";

  static String m40(appName) =>
      "1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check ${appName} in the list\n\nWhen you are done, return to the app to continue. Thank you for your cooperation.";

  static String m41(label, max) => "${label} must be at most ${max} characters";

  static String m42(count) =>
      "${Intl.plural(count, one: '1 minute ago', other: '${count} minutes ago')}";

  static String m43(count) =>
      "${Intl.plural(count, one: '1 month ago', other: '${count} months ago')}";

  static String m44(label) => "No ${label} yet";

  static String m45(label) => "${label} must be a number";

  static String m46(label) => "${label} must be between 1024 and 49151";

  static String m47(count) =>
      "Profile imported with ${count} unsupported nodes skipped";

  static String m48(format, client, nodes, groups) =>
      "Imported ${format} · ${client} · ${nodes} nodes · ${groups} groups";

  static String m49(count) =>
      "${Intl.plural(count, one: '1 proxy', other: '${count} proxies')}";

  static String m50(count) => "Profiles: ${count}";

  static String m51(count) => "Proxy groups: ${count}";

  static String m52(count) => "Rules: ${count}";

  static String m53(count) => "Scripts: ${count}";

  static String m54(count) =>
      "${Intl.plural(count, one: '1 rule', other: '${count} rules')}";

  static String m55(darkAt, lightAt) => "Dark from ${darkAt} to ${lightAt}";

  static String m56(count) =>
      "${Intl.plural(count, one: '1 second', other: '${count} seconds')}";

  static String m57(count) => "${count} selected";

  static String m58(count) =>
      "${Intl.plural(count, one: '1 profile ready', other: '${count} profiles ready')}";

  static String m59(step, count) => "Step ${step} of ${count}";

  static String m60(name) => "Profile: ${name}";

  static String m61(value) => "Smart Routing: ${value}";

  static String m62(alive, total) =>
      "${alive} of ${total} servers can be used right now";

  static String m63(percent, duration) => "${percent}% over ${duration}";

  static String m64(band) => "band ${band}";

  static String m65(bands) => "Bands: ${bands}";

  static String m66(count) => "Cooling down after ${count} failures";

  static String m67(answered, total) => "${answered} of ${total} answered";

  static String m68(seconds) => "${seconds} s left";

  static String m69(count) => "${count} failures in a row";

  static String m70(step) => "Lost at: ${step}";

  static String m71(duration) => "Measured over ${duration}";

  static String m72(measured, total) => "measured ${measured} of ${total}";

  static String m73(preset) => "${preset} · adjusted";

  static String m74(left, cap) => "${left} of ${cap} probes left this hour";

  static String m75(value, against) => "${value} vs ${against}";

  static String m76(seconds) => "${seconds} s";

  static String m77(eligible, total) => "${eligible} of ${total} usable";

  static String m78(count) => "${count} specialist selectors";

  static String m79(provider) => "Provider: ${provider}";

  static String m80(count) => "${count} selectors supplied by the provider";

  static String m81(eligible, total) => "${eligible} of ${total} servers ready";

  static String m82(label) => "${label} must be at most 64 UTF-8 bytes";

  static String m83(node) => "Through ${node}";

  static String m84(eligible, total, blocked) =>
      "${eligible} of ${total} servers passed, ${blocked} were held back";

  static String m85(from, to) => "${from} → ${to}";

  static String m86(time) => "Switched ${time} ago";

  static String m87(count) => "${count} servers";

  static String m88(step) => "Ranks higher at: ${step}";

  static String m89(host) => "The provider moved to ${host}";

  static String m90(count) =>
      "${Intl.plural(count, one: 'Your subscription expires tomorrow', other: 'Your subscription expires in ${count} days')}";

  static String m91(value) => "The provider suggests ${value}";

  static String m92(total) => "free of ${total}";

  static String m93(label) => "${label} must be a URL";

  static String m94(count) =>
      "${Intl.plural(count, one: '1 year ago', other: '${count} years ago')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Access control"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Only selected apps go through the VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Control which apps use the proxy",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "App access control is disabled",
    ),
    "accessControlExcludeFromVpn": MessageLookupByLibrary.simpleMessage(
      "Exclude from VPN",
    ),
    "accessControlIncludeInVpn": MessageLookupByLibrary.simpleMessage(
      "Include in VPN",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Selected apps are excluded from the VPN",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Access control settings",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "action": MessageLookupByLibrary.simpleMessage("Action"),
    "actionMode": MessageLookupByLibrary.simpleMessage("Switch mode"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Start/Stop"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionView": MessageLookupByLibrary.simpleMessage("Show/Hide"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addNetwork": MessageLookupByLibrary.simpleMessage("Add network"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Add profile"),
    "addProxies": MessageLookupByLibrary.simpleMessage("Add proxies"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("Add proxy group"),
    "addProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Add proxy providers",
    ),
    "addRule": MessageLookupByLibrary.simpleMessage("Add rule"),
    "addWidget": MessageLookupByLibrary.simpleMessage("Add widget"),
    "addedRules": MessageLookupByLibrary.simpleMessage("Added rules"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Additional parameters",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV server address",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid WebDAV address",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Advanced configuration",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Provides diverse configuration options",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Agree"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Allow apps to bypass VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, some apps can bypass the VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("Allow LAN"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "Allow proxy access over the LAN",
    ),
    "animations": MessageLookupByLibrary.simpleMessage("Animations"),
    "announce": MessageLookupByLibrary.simpleMessage("Announcements"),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "App access control",
    ),
    "appIconBlueprint": MessageLookupByLibrary.simpleMessage("Blueprint"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "The launcher redraws the icon in a few seconds. A pinned shortcut may disappear on some launchers.",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("Circuit"),
    "appIconEcho": MessageLookupByLibrary.simpleMessage("Echo"),
    "appIconGlacier": MessageLookupByLibrary.simpleMessage("Glacier"),
    "appIconGlass": MessageLookupByLibrary.simpleMessage("Glass"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("Ink"),
    "appIconInstall": MessageLookupByLibrary.simpleMessage("Install"),
    "appIconPorcelain": MessageLookupByLibrary.simpleMessage("Porcelain"),
    "appIconPreview": MessageLookupByLibrary.simpleMessage("Icon preview"),
    "appIconPulse": MessageLookupByLibrary.simpleMessage("Pulse"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("Solar"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("Velvet"),
    "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
    "appearanceDesc": MessageLookupByLibrary.simpleMessage(
      "Theme, colors, icons and dashboard look",
    ),
    "appearanceIcon": MessageLookupByLibrary.simpleMessage("Icon"),
    "appearanceLayout": MessageLookupByLibrary.simpleMessage("Layout"),
    "appearanceMotion": MessageLookupByLibrary.simpleMessage("Motion"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("Theme"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Append system DNS",
    ),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "Force-append the system DNS to the configuration",
    ),
    "application": MessageLookupByLibrary.simpleMessage("Application"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Adjust application settings",
    ),
    "authentication": MessageLookupByLibrary.simpleMessage("Authentication"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "Require credentials on the local proxy port to keep other local apps from using it",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Not applied while authentication is enabled",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Authorize"),
    "authorized": MessageLookupByLibrary.simpleMessage("Authorized"),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Auto check for updates",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "Check for updates automatically when the app starts",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Auto close connections",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Close connections automatically after switching nodes",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Auto launch"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Launch automatically at system startup",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Auto run"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Run automatically when the app opens",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Auto-set system DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Auto update"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto-update interval (minutes)",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "backup": MessageLookupByLibrary.simpleMessage("Backup"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Backup and restore",
    ),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Sync data via WebDAV or files",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("Backup successful"),
    "basicConfig": MessageLookupByLibrary.simpleMessage("Basic configuration"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Modify the basic configuration globally",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Basic info"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("Basic strategies"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "To keep the app running in the background, disable battery optimization for it. Tap to open settings.",
    ),
    "batteryOptimizationStatusTip": MessageLookupByLibrary.simpleMessage(
      "Due to system limitations, the battery optimization status cannot be read correctly while running",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Bind"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Blacklist mode"),
    "blockConnection": MessageLookupByLibrary.simpleMessage("Block connection"),
    "byedpiActive": MessageLookupByLibrary.simpleMessage(
      "DPI bypass is active",
    ),
    "byedpiActiveFor": m0,
    "byedpiChecking": MessageLookupByLibrary.simpleMessage(
      "Checking the DPI engine",
    ),
    "byedpiEngineError": MessageLookupByLibrary.simpleMessage(
      "DPI engine needs attention",
    ),
    "byedpiOff": MessageLookupByLibrary.simpleMessage("DPI bypass is off"),
    "byedpiPaused": MessageLookupByLibrary.simpleMessage(
      "DPI bypass is paused",
    ),
    "byedpiReconnecting": MessageLookupByLibrary.simpleMessage(
      "Restarting the DPI engine",
    ),
    "byedpiStarting": MessageLookupByLibrary.simpleMessage(
      "Starting DPI bypass",
    ),
    "byedpiTapToResume": MessageLookupByLibrary.simpleMessage(
      "Tap to resume DPI bypass",
    ),
    "byedpiTapToStart": MessageLookupByLibrary.simpleMessage(
      "Tap to start the local bypass engine",
    ),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Bypass domains"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Only takes effect while the system proxy is enabled",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "The cache is corrupted. Clear it?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("Deselect all"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Failed to switch proxy; the previous selection has been restored",
    ),
    "changeServer": MessageLookupByLibrary.simpleMessage("Change server"),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage(
      "Breaking changes",
    ),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("New features"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("Bug fixes"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("Performance"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("Reverts"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage(
      "Verify TLS certificates",
    ),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "Reject untrusted certificates. Turning this off exposes subscriptions and backups to man-in-the-middle attacks",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Check for updates"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "The app is already up to date",
    ),
    "classicDashboard": MessageLookupByLibrary.simpleMessage("Classic"),
    "classicDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "Tile grid with a start button",
    ),
    "clearData": MessageLookupByLibrary.simpleMessage("Clear data"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Clear search"),
    "clientNotSupported": MessageLookupByLibrary.simpleMessage(
      "Client not supported",
    ),
    "clientNotSupportedTip": MessageLookupByLibrary.simpleMessage(
      "The provider does not support this client.",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Export to clipboard",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Import from clipboard",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "closeConnections": MessageLookupByLibrary.simpleMessage(
      "Close connections",
    ),
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Drop every open connection when the VPN pauses",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Color"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Color schemes"),
    "columns": MessageLookupByLibrary.simpleMessage("Columns"),
    "compatible": MessageLookupByLibrary.simpleMessage("Compatibility mode"),
    "configDataDetected": MessageLookupByLibrary.simpleMessage(
      "Data detected in the configuration",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to clear all data?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete this proxy group?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to exit the current window?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force crash the core?",
    ),
    "confirmOverwriteTip": MessageLookupByLibrary.simpleMessage(
      "Confirming will overwrite existing data",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "connectedFor": m1,
    "connecting": MessageLookupByLibrary.simpleMessage("Connecting..."),
    "connection": MessageLookupByLibrary.simpleMessage("Connection"),
    "connectionDoctor": MessageLookupByLibrary.simpleMessage(
      "Connection Doctor",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("Connections"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "View current connection data",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectivity: "),
    "content": MessageLookupByLibrary.simpleMessage("Content"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Content cannot be empty",
    ),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Content"),
    "contrast": MessageLookupByLibrary.simpleMessage("Contrast"),
    "contrastAmoledHint": MessageLookupByLibrary.simpleMessage(
      "On pure black, +0.3 contrast usually reads better",
    ),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Control global added rules",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "copyDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Copy version info",
    ),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Copy environment variables",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copy link"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Copied successfully"),
    "core": MessageLookupByLibrary.simpleMessage("Core"),
    "coreBlockedByPolicyTip": m2,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows Smart App Control blocked ReClashCore.exe because it is not signed. Open Windows Security → App & browser control → Smart App Control settings, choose Off, then start ReClash again. Smart App Control cannot be turned back on without reinstalling Windows.",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Core status"),
    "country": MessageLookupByLibrary.simpleMessage("Region"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Crash detected"),
    "crashDetectedTip": m3,
    "crashTest": MessageLookupByLibrary.simpleMessage("Crash test"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("Crash analytics"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "When enabled, crash logs without sensitive information are uploaded automatically when the app crashes",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createProfile": MessageLookupByLibrary.simpleMessage("Create profile"),
    "createProfileFromUrlTip": m4,
    "creationTime": MessageLookupByLibrary.simpleMessage("Creation time"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage(
      "FlClash — the client this is built on",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "FlClashX — provider features and ideas",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage(
      "mihomo — the proxy core",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "customUserAgentLabel": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "cut": MessageLookupByLibrary.simpleMessage("Cut"),
    "dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "darkAt": MessageLookupByLibrary.simpleMessage("Dark at"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "dashboardByedpiDesc": MessageLookupByLibrary.simpleMessage(
      "Use ByeDPI-only mode to bypass DPI without a VPN profile.",
    ),
    "dashboardByedpiTitle": MessageLookupByLibrary.simpleMessage(
      "No VPN provider?",
    ),
    "dashboardNoActiveProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Profiles are saved, but none is active. Choose one to make VPN controls available.",
    ),
    "dashboardNoActiveProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Choose a VPN profile",
    ),
    "dashboardNoProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Add a VPN profile from a provider you trust. Until then, VPN stays off.",
    ),
    "dashboardNoProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Set up a connection",
    ),
    "dashboardProviderDetails": MessageLookupByLibrary.simpleMessage(
      "More details",
    ),
    "dashboardSelectProfile": MessageLookupByLibrary.simpleMessage(
      "Choose profile",
    ),
    "dashboardShowConnection": MessageLookupByLibrary.simpleMessage(
      "Return to connection",
    ),
    "dashboardShowProvider": MessageLookupByLibrary.simpleMessage(
      "Show subscription details",
    ),
    "dashboardStyle": MessageLookupByLibrary.simpleMessage("Dashboard style"),
    "dashboardSubscriptionAttention": MessageLookupByLibrary.simpleMessage(
      "Needs attention",
    ),
    "dashboardSubscriptionCurrent": MessageLookupByLibrary.simpleMessage(
      "Subscription active",
    ),
    "dashboardSubscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Subscription expired",
    ),
    "dashboardUseByedpi": MessageLookupByLibrary.simpleMessage("Use ByeDPI"),
    "dataChangedSave": MessageLookupByLibrary.simpleMessage(
      "Data changes detected. Save them?",
    ),
    "dataCollectionContent": MessageLookupByLibrary.simpleMessage(
      "This app uses Firebase Crashlytics to collect crash information to improve stability.\nThe collected data includes device information and crash details, and contains no personally sensitive data.\nYou can turn this off in settings.",
    ),
    "dataCollectionTip": MessageLookupByLibrary.simpleMessage(
      "Data collection notice",
    ),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Failed to save the change; it has been rolled back",
    ),
    "day": MessageLookupByLibrary.simpleMessage("day"),
    "days": MessageLookupByLibrary.simpleMessage("days"),
    "daysAgo": m5,
    "daysGenitive": MessageLookupByLibrary.simpleMessage("days"),
    "daysLeft": m6,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "Default nameserver",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Used to resolve DNS servers",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("Default"),
    "delay": MessageLookupByLibrary.simpleMessage("Delay"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Delay test"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteMultipTip": m7,
    "deleteTip": m8,
    "desc": MessageLookupByLibrary.simpleMessage(
      "A multi-platform mihomo client: a rebuilt dashboard, smarter routing and first-class subscription support. Open source, no ads, no telemetry.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Destination"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "Destination GeoIP",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "Destination IP ASN",
    ),
    "desync": MessageLookupByLibrary.simpleMessage("DPI bypass"),
    "desyncActiveStrategy": MessageLookupByLibrary.simpleMessage(
      "Active strategy",
    ),
    "desyncArgs": MessageLookupByLibrary.simpleMessage("Engine arguments"),
    "desyncArgsAppOwnedFlag": m9,
    "desyncArgsCount": m10,
    "desyncArgsHint": MessageLookupByLibrary.simpleMessage(
      "-A torst,conn -L s,o --split 1",
    ),
    "desyncArgsMissingValue": m11,
    "desyncArgsPositional": m12,
    "desyncArgsQuoteError": MessageLookupByLibrary.simpleMessage(
      "A quote is left unclosed",
    ),
    "desyncArgsUnknownFlag": m13,
    "desyncCache": MessageLookupByLibrary.simpleMessage("Strategy cache"),
    "desyncCacheDesc": MessageLookupByLibrary.simpleMessage(
      "Picked strategies are kept per network",
    ),
    "desyncCacheDisabled": MessageLookupByLibrary.simpleMessage(
      "Strategy cache is off",
    ),
    "desyncCacheTtl": MessageLookupByLibrary.simpleMessage("Cache lifetime"),
    "desyncDefaultName": MessageLookupByLibrary.simpleMessage("Default ladder"),
    "desyncDesc": MessageLookupByLibrary.simpleMessage(
      "ByeDPI desync strategies",
    ),
    "desyncEngine": MessageLookupByLibrary.simpleMessage("Engine"),
    "desyncEngineSummary": m14,
    "desyncForceTcp": MessageLookupByLibrary.simpleMessage("Force TCP"),
    "desyncForceTcpDesc": MessageLookupByLibrary.simpleMessage(
      "Blocks QUIC for the categories above; a desync cannot reach UDP",
    ),
    "desyncModeByedpi": MessageLookupByLibrary.simpleMessage("ByeDPI"),
    "desyncModeTitle": MessageLookupByLibrary.simpleMessage("Connection mode"),
    "desyncModeVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "desyncRouting": MessageLookupByLibrary.simpleMessage("Routing"),
    "desyncRoutingFallbackDesc": MessageLookupByLibrary.simpleMessage(
      "All traffic outside selected GEOSITE categories goes directly",
    ),
    "desyncRoutingGeositeNote": MessageLookupByLibrary.simpleMessage(
      "Category membership comes from the bundled GEOSITE database; test-domain lists are separate",
    ),
    "desyncRoutingNoCategories": MessageLookupByLibrary.simpleMessage(
      "No bypass categories selected",
    ),
    "desyncRoutingNoCategoriesDesc": MessageLookupByLibrary.simpleMessage(
      "No service is currently routed through ByeDPI",
    ),
    "desyncRoutingRules": MessageLookupByLibrary.simpleMessage(
      "Effective rules",
    ),
    "desyncSaveCurrent": MessageLookupByLibrary.simpleMessage("Save current"),
    "desyncStrategyNameHint": MessageLookupByLibrary.simpleMessage(
      "Strategy name",
    ),
    "desyncStrategySection": MessageLookupByLibrary.simpleMessage("Strategy"),
    "desyncTestAborted": MessageLookupByLibrary.simpleMessage(
      "Stopped early: strategies stopped reaching the engine",
    ),
    "desyncTestBattery": MessageLookupByLibrary.simpleMessage("Test battery"),
    "desyncTestBatterySummary": m15,
    "desyncTestDomains": MessageLookupByLibrary.simpleMessage("Test domains"),
    "desyncTestDomainsCount": m16,
    "desyncTestDone": m17,
    "desyncTestEngineCrashed": MessageLookupByLibrary.simpleMessage(
      "The engine died on this strategy",
    ),
    "desyncTestEngineDown": MessageLookupByLibrary.simpleMessage(
      "The engine is not running — connect with DPI bypass enabled first",
    ),
    "desyncTestFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Hosts this strategy failed",
    ),
    "desyncTestHint": m18,
    "desyncTestNoLists": MessageLookupByLibrary.simpleMessage(
      "Pick at least one domain list below",
    ),
    "desyncTestProgress": m19,
    "desyncTestScore": m20,
    "desyncTestSection": MessageLookupByLibrary.simpleMessage("Strategy test"),
    "desyncTestStart": MessageLookupByLibrary.simpleMessage("Start"),
    "desyncTestTitle": MessageLookupByLibrary.simpleMessage("Run every preset"),
    "desyncTtl12Hours": MessageLookupByLibrary.simpleMessage("12 hours"),
    "desyncTtl28Hours": MessageLookupByLibrary.simpleMessage("28 hours"),
    "desyncTtlHour": MessageLookupByLibrary.simpleMessage("1 hour"),
    "desyncTtlWeek": MessageLookupByLibrary.simpleMessage("7 days"),
    "details": m21,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Relies on a third-party API; for reference only",
    ),
    "determiningIp": MessageLookupByLibrary.simpleMessage("Determining IP..."),
    "developerMode": MessageLookupByLibrary.simpleMessage("Developer mode"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Developer mode is enabled.",
    ),
    "developerSubscriptionAtlasDesc": MessageLookupByLibrary.simpleMessage(
      "Provider dashboard widgets, server switching, and proxy layout",
    ),
    "developerSubscriptionInstalled": m22,
    "developerSubscriptionOrbitDesc": MessageLookupByLibrary.simpleMessage(
      "Quota, expiration, announcements, domain migration, and offers",
    ),
    "developerSubscriptionPrismDesc": MessageLookupByLibrary.simpleMessage(
      "Brand colors, a custom Hero Ring, and local logo rendering",
    ),
    "developerSubscriptions": MessageLookupByLibrary.simpleMessage(
      "Developer subscriptions",
    ),
    "deviceLimitReached": MessageLookupByLibrary.simpleMessage(
      "Device limit reached",
    ),
    "deviceLimitReachedTip": MessageLookupByLibrary.simpleMessage(
      "The provider reports the device limit for this subscription as reached. The subscription was still updated.",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Direct"),
    "disableUDP": MessageLookupByLibrary.simpleMessage("Disable UDP"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Disclaimer"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "This software is intended only for non-commercial uses such as learning and research. Using it for any commercial purpose is strictly prohibited; any commercial activity is unrelated to this software.",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Disconnected"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "New version found",
    ),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "Update DNS-related settings",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS hijacking"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS mode"),
    "doctorBrokenDesc": MessageLookupByLibrary.simpleMessage(
      "The Doctor confirmed the first failing layer.",
    ),
    "doctorBrokenTitle": MessageLookupByLibrary.simpleMessage(
      "Connection problem found",
    ),
    "doctorCancelExam": MessageLookupByLibrary.simpleMessage("Cancel check"),
    "doctorCancelledDesc": MessageLookupByLibrary.simpleMessage(
      "No diagnosis was changed. You can start another check.",
    ),
    "doctorCancelledTitle": MessageLookupByLibrary.simpleMessage(
      "Check cancelled",
    ),
    "doctorCaptureActive": MessageLookupByLibrary.simpleMessage("Active"),
    "doctorCaptureInactive": MessageLookupByLibrary.simpleMessage("Inactive"),
    "doctorCaptureNotApplicable": MessageLookupByLibrary.simpleMessage(
      "Not applicable",
    ),
    "doctorConfidence": MessageLookupByLibrary.simpleMessage("Confidence"),
    "doctorConfidenceConfirmed": MessageLookupByLibrary.simpleMessage(
      "Confirmed",
    ),
    "doctorConfidenceInsufficient": MessageLookupByLibrary.simpleMessage(
      "Insufficient",
    ),
    "doctorConfidenceProbable": MessageLookupByLibrary.simpleMessage(
      "Probable",
    ),
    "doctorDeepExam": MessageLookupByLibrary.simpleMessage("Deep check"),
    "doctorDegradedDesc": MessageLookupByLibrary.simpleMessage(
      "The Doctor found a probable problem on the network path.",
    ),
    "doctorDegradedTitle": MessageLookupByLibrary.simpleMessage(
      "Connection is degraded",
    ),
    "doctorDetails": MessageLookupByLibrary.simpleMessage("Diagnosis"),
    "doctorEndpointReachableDesc": MessageLookupByLibrary.simpleMessage(
      "Core reached the test address, but the complete protected path was not proven.",
    ),
    "doctorEndpointReachableTitle": MessageLookupByLibrary.simpleMessage(
      "Test address is reachable",
    ),
    "doctorEvidence": MessageLookupByLibrary.simpleMessage("Evidence"),
    "doctorEvidenceConsequence": MessageLookupByLibrary.simpleMessage(
      "Consequence of an earlier fault",
    ),
    "doctorEvidenceDropped": m23,
    "doctorExaminingDesc": MessageLookupByLibrary.simpleMessage(
      "The Doctor is following the network path with bounded probes.",
    ),
    "doctorExaminingTitle": MessageLookupByLibrary.simpleMessage(
      "Checking the connection",
    ),
    "doctorExportConfirm": MessageLookupByLibrary.simpleMessage(
      "The report contains diagnostic codes, timing buckets, platform details and recent redacted evidence. It never includes addresses, hostnames, profile, node or app names. Save it as JSON?",
    ),
    "doctorExportReport": MessageLookupByLibrary.simpleMessage("Export report"),
    "doctorFlushDns": MessageLookupByLibrary.simpleMessage("Flush DNS cache"),
    "doctorFresh": MessageLookupByLibrary.simpleMessage("Current"),
    "doctorHealthyDesc": MessageLookupByLibrary.simpleMessage(
      "The observed path completed successfully.",
    ),
    "doctorHealthyEasterEgg": MessageLookupByLibrary.simpleMessage(
      "The patient is suspiciously healthy.",
    ),
    "doctorHealthyTitle": MessageLookupByLibrary.simpleMessage(
      "Connection looks healthy",
    ),
    "doctorHeroExamining": m24,
    "doctorHeroIssue": m25,
    "doctorInconclusiveDesc": MessageLookupByLibrary.simpleMessage(
      "The check could not prove a fault without guessing.",
    ),
    "doctorInconclusiveTitle": MessageLookupByLibrary.simpleMessage(
      "Not enough evidence",
    ),
    "doctorIpUnavailable": MessageLookupByLibrary.simpleMessage(
      "Public IP not measured",
    ),
    "doctorLayer": MessageLookupByLibrary.simpleMessage("Causal layer"),
    "doctorLayerCapture": MessageLookupByLibrary.simpleMessage("Capture"),
    "doctorLayerDial": MessageLookupByLibrary.simpleMessage("Connection setup"),
    "doctorLayerDns": MessageLookupByLibrary.simpleMessage("DNS"),
    "doctorLayerIngress": MessageLookupByLibrary.simpleMessage("VPN ingress"),
    "doctorLayerMarker": MessageLookupByLibrary.simpleMessage(
      "Application response",
    ),
    "doctorLayerRoute": MessageLookupByLibrary.simpleMessage("Routing"),
    "doctorLayerTransport": MessageLookupByLibrary.simpleMessage("Transport"),
    "doctorLimitations": MessageLookupByLibrary.simpleMessage(
      "What this means",
    ),
    "doctorModeDeep": MessageLookupByLibrary.simpleMessage("Deep"),
    "doctorModeStandard": MessageLookupByLibrary.simpleMessage("Standard"),
    "doctorNoEvidence": MessageLookupByLibrary.simpleMessage(
      "No usable evidence yet",
    ),
    "doctorNoIncidents": MessageLookupByLibrary.simpleMessage(
      "No completed checks yet",
    ),
    "doctorObservingDesc": MessageLookupByLibrary.simpleMessage(
      "No active probes are running. Evidence appears as the app is used.",
    ),
    "doctorObservingTitle": MessageLookupByLibrary.simpleMessage(
      "Watching real traffic",
    ),
    "doctorOutcomeDropped": MessageLookupByLibrary.simpleMessage("Dropped"),
    "doctorOutcomeFailed": MessageLookupByLibrary.simpleMessage("Failed"),
    "doctorOutcomeNotApplicable": MessageLookupByLibrary.simpleMessage(
      "Not applicable",
    ),
    "doctorOutcomeSeen": MessageLookupByLibrary.simpleMessage("Observed"),
    "doctorOutcomeSucceeded": MessageLookupByLibrary.simpleMessage("Succeeded"),
    "doctorPassiveHint": MessageLookupByLibrary.simpleMessage(
      "Passive observation creates no additional network traffic. Start a check only when you want active probes.",
    ),
    "doctorPathApp": MessageLookupByLibrary.simpleMessage("App"),
    "doctorPathChecking": MessageLookupByLibrary.simpleMessage("Checking"),
    "doctorPathConsequence": MessageLookupByLibrary.simpleMessage(
      "Not checked after an earlier problem",
    ),
    "doctorPathFailed": MessageLookupByLibrary.simpleMessage("Problem here"),
    "doctorPathIngress": MessageLookupByLibrary.simpleMessage(
      "VPN / local entry",
    ),
    "doctorPathIngressByeDpi": MessageLookupByLibrary.simpleMessage("ByeDPI"),
    "doctorPathIngressDirect": MessageLookupByLibrary.simpleMessage("Direct"),
    "doctorPathIngressLocalProxy": MessageLookupByLibrary.simpleMessage(
      "Local proxy",
    ),
    "doctorPathIngressTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "doctorPathIngressVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "doctorPathInternet": MessageLookupByLibrary.simpleMessage(
      "Proxy / Internet",
    ),
    "doctorPathNotApplicable": MessageLookupByLibrary.simpleMessage(
      "Not required",
    ),
    "doctorPathPassed": MessageLookupByLibrary.simpleMessage("Working"),
    "doctorPathResponse": MessageLookupByLibrary.simpleMessage("Response"),
    "doctorPathRoute": MessageLookupByLibrary.simpleMessage("DNS / route"),
    "doctorPathTitle": MessageLookupByLibrary.simpleMessage("Connection path"),
    "doctorPathUnknown": MessageLookupByLibrary.simpleMessage("Not checked"),
    "doctorProgress": m26,
    "doctorProtection": MessageLookupByLibrary.simpleMessage("Protection"),
    "doctorRecentChecks": MessageLookupByLibrary.simpleMessage("Recent checks"),
    "doctorRefresh": MessageLookupByLibrary.simpleMessage("Refresh diagnosis"),
    "doctorScope": MessageLookupByLibrary.simpleMessage("Evidence scope"),
    "doctorScopeApp": MessageLookupByLibrary.simpleMessage("This app"),
    "doctorScopeInbound": MessageLookupByLibrary.simpleMessage("Local inbound"),
    "doctorStale": MessageLookupByLibrary.simpleMessage("Outdated"),
    "doctorStaleHint": MessageLookupByLibrary.simpleMessage(
      "The environment may have changed. Refresh or run a new check before acting on this result.",
    ),
    "doctorStandardExam": MessageLookupByLibrary.simpleMessage("Run check"),
    "doctorSupersededDesc": MessageLookupByLibrary.simpleMessage(
      "The check stopped because the network or configuration changed.",
    ),
    "doctorSupersededTitle": MessageLookupByLibrary.simpleMessage(
      "Environment changed",
    ),
    "doctorTechnicalDetails": MessageLookupByLibrary.simpleMessage(
      "Technical details",
    ),
    "doctorUnsupportedDesc": MessageLookupByLibrary.simpleMessage(
      "This Core version does not support connection diagnosis.",
    ),
    "doctorUnsupportedHint": MessageLookupByLibrary.simpleMessage(
      "Update Core to use connection diagnosis.",
    ),
    "doctorUnsupportedTitle": MessageLookupByLibrary.simpleMessage(
      "Doctor unavailable",
    ),
    "doctorVpnInactiveDesc": MessageLookupByLibrary.simpleMessage(
      "The app expected VPN protection, but the TUN path is not active.",
    ),
    "doctorVpnInactiveTitle": MessageLookupByLibrary.simpleMessage(
      "VPN is not active",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("Domain"),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage(
      "Downloading update",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Edit global rules",
    ),
    "editNetwork": MessageLookupByLibrary.simpleMessage("Edit network"),
    "editProxy": MessageLookupByLibrary.simpleMessage("Edit proxy"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("Edit proxy group"),
    "editRule": MessageLookupByLibrary.simpleMessage("Edit rule"),
    "emptyTip": m27,
    "en": MessageLookupByLibrary.simpleMessage("English"),
    "enterManually": MessageLookupByLibrary.simpleMessage("Enter manually"),
    "entries": MessageLookupByLibrary.simpleMessage(" entries"),
    "entriesCount": m28,
    "exclude": MessageLookupByLibrary.simpleMessage("Hide from recent tasks"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Hide the app from recent tasks while it is in the background",
    ),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage(
      "Exclude proxy filter",
    ),
    "excludeType": MessageLookupByLibrary.simpleMessage("Exclude type"),
    "existsTip": m29,
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("Exit full screen"),
    "expand": MessageLookupByLibrary.simpleMessage("Standard"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Expected status"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Expiration time"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Export file"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Export logs"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export successful"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Expressive"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "External controller",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, the Clash core can be controlled on port 9090",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("External fetch"),
    "externalLink": MessageLookupByLibrary.simpleMessage("External link"),
    "extra": MessageLookupByLibrary.simpleMessage("Extra"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IP filter"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP range"),
    "fallback": MessageLookupByLibrary.simpleMessage("Fallback"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Usually an overseas DNS",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Fallback filter"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Fidelity"),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "Upload a profile file directly",
    ),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "The file has been modified. Save the changes?",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Find process"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "Enabling causes some performance loss",
    ),
    "followProfile": MessageLookupByLibrary.simpleMessage("Follow profile"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Font family"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force restart the core?",
    ),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("Fruit salad"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "geoAutoUpdate": MessageLookupByLibrary.simpleMessage("Auto update"),
    "geoAutoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto-update interval",
    ),
    "geoAutoUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "The auto-update interval must be greater than 0",
    ),
    "geoOptions": MessageLookupByLibrary.simpleMessage("Geo options"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo resources"),
    "geoSkipped": m30,
    "geoUpdated": m31,
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Geo low-memory mode",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "Use the low-memory Geo loader",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("GeoIP code"),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Go"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Download"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Go to script configuration",
    ),
    "gratitude": MessageLookupByLibrary.simpleMessage("Gratitude"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash exists because of their work",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Cache the changes?",
    ),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper service unavailable; TUN mode cannot be enabled. Reinstall ReClash to restore it.",
    ),
    "heroChecking": MessageLookupByLibrary.simpleMessage(
      "Checking the network…",
    ),
    "heroCheckingHint": MessageLookupByLibrary.simpleMessage(
      "Measuring the selected node",
    ),
    "heroConnecting": MessageLookupByLibrary.simpleMessage("Connecting…"),
    "heroJustNow": MessageLookupByLibrary.simpleMessage("just now"),
    "heroLinkBroken": MessageLookupByLibrary.simpleMessage(
      "Connection is not working",
    ),
    "heroLinkDown": MessageLookupByLibrary.simpleMessage(
      "The node is not responding",
    ),
    "heroLinkPaused": MessageLookupByLibrary.simpleMessage(
      "Traffic is paused, protection is on hold",
    ),
    "heroLinkSlow": MessageLookupByLibrary.simpleMessage(
      "The node is responding slowly",
    ),
    "heroNoNetworkHint": MessageLookupByLibrary.simpleMessage(
      "Waiting for a connection",
    ),
    "heroNotProtected": MessageLookupByLibrary.simpleMessage("Not protected"),
    "heroPaused": MessageLookupByLibrary.simpleMessage(
      "Paused — trusted network",
    ),
    "heroProtected": MessageLookupByLibrary.simpleMessage("You are protected"),
    "heroReconnecting": MessageLookupByLibrary.simpleMessage("Reconnecting…"),
    "heroReconnectingHint": MessageLookupByLibrary.simpleMessage(
      "Restoring the tunnel",
    ),
    "heroRoutingAgo": m32,
    "heroRoutingStub": MessageLookupByLibrary.simpleMessage(
      "Smart routing is off",
    ),
    "heroStatusEasterEgg": MessageLookupByLibrary.simpleMessage(
      "The packets are unusually well-behaved today.",
    ),
    "heroTapToConnect": MessageLookupByLibrary.simpleMessage(
      "Tap to turn protection on",
    ),
    "heroTapToResume": MessageLookupByLibrary.simpleMessage(
      "Tap to resume protection",
    ),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Hide from list"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Hide password"),
    "host": MessageLookupByLibrary.simpleMessage("Host"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Append hosts"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("Hotkey conflict"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Hotkey management",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Control the app with the keyboard",
    ),
    "hour": MessageLookupByLibrary.simpleMessage("hour"),
    "hours": MessageLookupByLibrary.simpleMessage("hours"),
    "hoursAgo": m33,
    "hoursCount": m34,
    "hoursGenitive": MessageLookupByLibrary.simpleMessage("hours"),
    "hoursPlural": MessageLookupByLibrary.simpleMessage("hours"),
    "icon": MessageLookupByLibrary.simpleMessage("Icon"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("Icon records"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Icon style"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("Icon URL"),
    "identity": MessageLookupByLibrary.simpleMessage("Identity"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Ignore battery optimization",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importFile": MessageLookupByLibrary.simpleMessage("Import from file"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "importUrl": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "inbound": MessageLookupByLibrary.simpleMessage("Inbound"),
    "includeAllProxies": MessageLookupByLibrary.simpleMessage(
      "Include all proxies",
    ),
    "includeAllProxiesTip": MessageLookupByLibrary.simpleMessage(
      "Imports all proxies outside proxy groups; extra proxy groups can be added below",
    ),
    "includeAllProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Include all proxy providers",
    ),
    "includeAllProxyProvidersTip": MessageLookupByLibrary.simpleMessage(
      "When enabled, the imported proxy providers are overridden",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Never expires"),
    "init": MessageLookupByLibrary.simpleMessage("Init"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid hotkey",
    ),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "Enter the proxy group name",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage(
      "Enter the rule content",
    ),
    "installUpdate": MessageLookupByLibrary.simpleMessage("Install update"),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "The app list permission was denied, so installed apps cannot be listed. Please grant it manually in system settings.",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "This system hides the installed app list until the permission is granted. Authorize it to configure the per-app proxy.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "App list permission required",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Smart selection",
    ),
    "interfaceName": MessageLookupByLibrary.simpleMessage("Interface name"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "Network interface used for outbound connections",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage(
      "Outbound interface",
    ),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("Clear"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("Custom"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage(
      "Follow config",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Interval"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Intranet IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Invalid backup file",
    ),
    "invalidPolicy": m35,
    "invalidProxy": m36,
    "invalidProxyProvider": m37,
    "invalidSubRule": m38,
    "ipcidr": MessageLookupByLibrary.simpleMessage("IP/CIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "When enabled, IPv6 traffic can be received",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Allow IPv6 inbound",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("Japanese"),
    "justNow": MessageLookupByLibrary.simpleMessage("Just now"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP keep-alive interval",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Key"),
    "kk": MessageLookupByLibrary.simpleMessage("Kazakh"),
    "ko": MessageLookupByLibrary.simpleMessage("Korean"),
    "lanProfileImport": MessageLookupByLibrary.simpleMessage(
      "Receive from phone",
    ),
    "lanProfileImportAddress": m39,
    "lanProfileImportDesc": MessageLookupByLibrary.simpleMessage(
      "Show a one-time QR code to send a subscription URL over your local network",
    ),
    "lanProfileImportFailed": MessageLookupByLibrary.simpleMessage(
      "Could not import the subscription",
    ),
    "lanProfileImportImported": MessageLookupByLibrary.simpleMessage(
      "Subscription received",
    ),
    "lanProfileImportImporting": MessageLookupByLibrary.simpleMessage(
      "Importing subscription…",
    ),
    "lanProfileImportScan": MessageLookupByLibrary.simpleMessage(
      "Scan this QR code with a phone on the same network",
    ),
    "lanProfileImportStartFailed": MessageLookupByLibrary.simpleMessage(
      "Could not start local sharing",
    ),
    "lanProfileImportTimedOut": MessageLookupByLibrary.simpleMessage(
      "The one-time link has expired",
    ),
    "lanProfileImportTitle": MessageLookupByLibrary.simpleMessage(
      "Receive subscription",
    ),
    "lanProfileImportWaiting": MessageLookupByLibrary.simpleMessage(
      "Waiting for a subscription…",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Launch did not finish",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "The app exited unexpectedly while it was starting up last time. Automatic setup was skipped for this launch; you can start it manually to retry.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Layout"),
    "license": MessageLookupByLibrary.simpleMessage("License"),
    "licenses": MessageLookupByLibrary.simpleMessage("Licenses"),
    "licensesDesc": MessageLookupByLibrary.simpleMessage(
      "Packages bundled into the app",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "lightAt": MessageLookupByLibrary.simpleMessage("Light at"),
    "list": MessageLookupByLibrary.simpleMessage("List"),
    "listen": MessageLookupByLibrary.simpleMessage("Listen"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Back up data locally",
    ),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Location permission",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Location permission was denied, so the current Wi-Fi name cannot be read. Please enable location permission manually in system settings.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "The system requires location permission to read the Wi-Fi name. On Android choose \"Allow all the time\", otherwise the Wi-Fi name cannot be read while the app is in the background.",
    ),
    "locationPermissionGuide": m40,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Location permission required",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Log"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Log level"),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Disabling hides the log entry point",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Logs"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("Captured log records"),
    "logsTest": MessageLookupByLibrary.simpleMessage("Logs test"),
    "loopback": MessageLookupByLibrary.simpleMessage("Loopback unlock tool"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "Used for UWP loopback exemption",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Loose"),
    "madeBy": MessageLookupByLibrary.simpleMessage("Made by"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("Match source IP"),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "matchTargetDesc": MessageLookupByLibrary.simpleMessage(
      "Where rules targeting MATCH-TARGET go. Defaults to the target of the final MATCH rule in this profile.",
    ),
    "matchTargetTitle": MessageLookupByLibrary.simpleMessage("Match target"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("Max failures"),
    "maxLengthTip": m41,
    "maximize": MessageLookupByLibrary.simpleMessage("Maximize"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Memory info"),
    "messageTest": MessageLookupByLibrary.simpleMessage("Message test"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "This is a message.",
    ),
    "metaInfo": MessageLookupByLibrary.simpleMessage("Subscription"),
    "min": MessageLookupByLibrary.simpleMessage("Minimal"),
    "minimize": MessageLookupByLibrary.simpleMessage("Minimize"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("Minimize on exit"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Override the default system exit behavior",
    ),
    "minute": MessageLookupByLibrary.simpleMessage("minute"),
    "minutesAgo": m42,
    "minutesGenitive": MessageLookupByLibrary.simpleMessage("minutes"),
    "minutesPlural": MessageLookupByLibrary.simpleMessage("minutes"),
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixed port"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "monthsAgo": m43,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "multipleValuesTip": MessageLookupByLibrary.simpleMessage(
      "Separate multiple values with commas",
    ),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameserver": MessageLookupByLibrary.simpleMessage("Nameserver"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Used to resolve domains",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "Nameserver policy",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Specify the nameserver policy for matching domains",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Network"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "Adjust network-related settings",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "Network detection",
    ),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID (Home Wi-Fi) or subnet (192.168.1.0/24)",
    ),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "Network error, please check your connection and try again",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Network speed"),
    "networkType": MessageLookupByLibrary.simpleMessage("Network type"),
    "networksEmpty": MessageLookupByLibrary.simpleMessage(
      "No trusted networks yet",
    ),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Neutral"),
    "newDashboard": MessageLookupByLibrary.simpleMessage("New look"),
    "newDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "Connection ring with traffic below",
    ),
    "newDashboardTitle": MessageLookupByLibrary.simpleMessage("New"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Next match"),
    "noAnnouncements": MessageLookupByLibrary.simpleMessage("No announcements"),
    "noData": MessageLookupByLibrary.simpleMessage("No data"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("No hotkeys yet"),
    "noInfo": MessageLookupByLibrary.simpleMessage("No info"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Don\'t remind me again",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("No network"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("No-network apps"),
    "noRecords": MessageLookupByLibrary.simpleMessage("No records"),
    "noResolve": MessageLookupByLibrary.simpleMessage("Don\'t resolve IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "Don\'t resolve hostname",
    ),
    "none": MessageLookupByLibrary.simpleMessage("None"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "The current proxy group cannot be selected",
    ),
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "Current network is not trusted",
    ),
    "notification": MessageLookupByLibrary.simpleMessage("Notification"),
    "notificationAddComponent": MessageLookupByLibrary.simpleMessage(
      "Add component",
    ),
    "notificationAndroidOnly": MessageLookupByLibrary.simpleMessage(
      "Available on Android",
    ),
    "notificationAndroidOnlyDesc": MessageLookupByLibrary.simpleMessage(
      "Foreground notification settings apply only to the Android VPN service.",
    ),
    "notificationAutomaticGroup": MessageLookupByLibrary.simpleMessage(
      "Automatic group",
    ),
    "notificationBlockedNoServerGroup": MessageLookupByLibrary.simpleMessage(
      "No server group is resolved, so this line is hidden",
    ),
    "notificationBlockedSmartRoutingOff": MessageLookupByLibrary.simpleMessage(
      "Smart routing is off, so this line is hidden",
    ),
    "notificationCollapsedLine": MessageLookupByLibrary.simpleMessage(
      "Shown while the notification is collapsed",
    ),
    "notificationComponentBehaviour": MessageLookupByLibrary.simpleMessage(
      "Behaviour",
    ),
    "notificationComponents": MessageLookupByLibrary.simpleMessage(
      "Notification components",
    ),
    "notificationComponentsActive": MessageLookupByLibrary.simpleMessage(
      "In the notification",
    ),
    "notificationComponentsDesc": MessageLookupByLibrary.simpleMessage(
      "Build the notification from live status components.",
    ),
    "notificationComponentsEmpty": MessageLookupByLibrary.simpleMessage(
      "No components added",
    ),
    "notificationComponentsEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "Without components the notification shows only the protection status.",
    ),
    "notificationComponentsOrderHint": MessageLookupByLibrary.simpleMessage(
      "Lines follow this order. The first line that has data is shown while the notification is collapsed.",
    ),
    "notificationConnectionDoctor": MessageLookupByLibrary.simpleMessage(
      "Connection Doctor",
    ),
    "notificationConnectionDoctorDesc": MessageLookupByLibrary.simpleMessage(
      "Show the Connection Doctor verdict",
    ),
    "notificationContent": MessageLookupByLibrary.simpleMessage("Content"),
    "notificationControls": MessageLookupByLibrary.simpleMessage("Controls"),
    "notificationControlsDesc": MessageLookupByLibrary.simpleMessage(
      "Choose actions available directly from the notification.",
    ),
    "notificationCurrentServer": MessageLookupByLibrary.simpleMessage(
      "Current server",
    ),
    "notificationCurrentServerDesc": MessageLookupByLibrary.simpleMessage(
      "Show the node selected in the group",
    ),
    "notificationDelivery": MessageLookupByLibrary.simpleMessage(
      "Android delivery",
    ),
    "notificationDeliveryChecking": MessageLookupByLibrary.simpleMessage(
      "Checking Android notification access",
    ),
    "notificationDeliveryFix": MessageLookupByLibrary.simpleMessage("Fix"),
    "notificationDeliveryOff": MessageLookupByLibrary.simpleMessage(
      "The service notification is turned off in ReClash",
    ),
    "notificationDeliveryPermissionDisabled":
        MessageLookupByLibrary.simpleMessage(
          "Notifications are blocked for ReClash",
        ),
    "notificationDeliveryReady": MessageLookupByLibrary.simpleMessage(
      "Notifications can be delivered",
    ),
    "notificationDeliveryServiceDisabled": MessageLookupByLibrary.simpleMessage(
      "The ReClash service channel is disabled",
    ),
    "notificationDeliverySubscriptionDisabled":
        MessageLookupByLibrary.simpleMessage(
          "The subscription reminders channel is disabled",
        ),
    "notificationDetailedDesc": MessageLookupByLibrary.simpleMessage(
      "Live status lines, quick actions and an icon in the status bar",
    ),
    "notificationDoctorPriority": MessageLookupByLibrary.simpleMessage(
      "Connection Doctor priority",
    ),
    "notificationDoctorPriorityAlways": MessageLookupByLibrary.simpleMessage(
      "Always",
    ),
    "notificationDoctorPriorityProblems": MessageLookupByLibrary.simpleMessage(
      "Problems only",
    ),
    "notificationHideIdleSpeed": MessageLookupByLibrary.simpleMessage(
      "Hide idle speed",
    ),
    "notificationHideIdleSpeedDesc": MessageLookupByLibrary.simpleMessage(
      "Hide speed values while no traffic is flowing",
    ),
    "notificationHideSensitive": MessageLookupByLibrary.simpleMessage(
      "Hide sensitive details on lock screen",
    ),
    "notificationHideSensitiveDesc": MessageLookupByLibrary.simpleMessage(
      "Hide profile, routing and diagnostic details while the device is locked",
    ),
    "notificationMinimalDesc": MessageLookupByLibrary.simpleMessage(
      "One quiet line at the bottom of the shade, without a status bar icon",
    ),
    "notificationMoveDown": MessageLookupByLibrary.simpleMessage("Move down"),
    "notificationMoveUp": MessageLookupByLibrary.simpleMessage("Move up"),
    "notificationNetworkNormal": MessageLookupByLibrary.simpleMessage("Normal"),
    "notificationNetworkOffline": MessageLookupByLibrary.simpleMessage(
      "Offline",
    ),
    "notificationNetworkPortal": MessageLookupByLibrary.simpleMessage(
      "Captive portal",
    ),
    "notificationNetworkSpeed": MessageLookupByLibrary.simpleMessage(
      "Network speed",
    ),
    "notificationNetworkSpeedDesc": MessageLookupByLibrary.simpleMessage(
      "Show current upload and download speed",
    ),
    "notificationNetworkState": MessageLookupByLibrary.simpleMessage(
      "Network state",
    ),
    "notificationNetworkStateDesc": MessageLookupByLibrary.simpleMessage(
      "Show the current RCX network terrain",
    ),
    "notificationNetworkUnknown": MessageLookupByLibrary.simpleMessage(
      "Unknown",
    ),
    "notificationNetworkWhitelist": MessageLookupByLibrary.simpleMessage(
      "Whitelist",
    ),
    "notificationOffDesc": MessageLookupByLibrary.simpleMessage(
      "Nothing in the shade. Protection keeps running and reminders still arrive",
    ),
    "notificationPauseAction": MessageLookupByLibrary.simpleMessage(
      "Pause or resume",
    ),
    "notificationPauseActionDesc": MessageLookupByLibrary.simpleMessage(
      "Show an action that pauses or resumes the VPN",
    ),
    "notificationPreviewDoctor": MessageLookupByLibrary.simpleMessage(
      "Connection Doctor: no problems",
    ),
    "notificationPreviewHidden": MessageLookupByLibrary.simpleMessage(
      "The notification shade stays empty",
    ),
    "notificationPreviewLocked": MessageLookupByLibrary.simpleMessage(
      "ReClash · Protected details hidden",
    ),
    "notificationPreviewNetwork": MessageLookupByLibrary.simpleMessage(
      "Network · Normal",
    ),
    "notificationPreviewPaused": MessageLookupByLibrary.simpleMessage(
      "ReClash · Protection paused",
    ),
    "notificationPreviewProblem": MessageLookupByLibrary.simpleMessage(
      "Connection Doctor: problem detected",
    ),
    "notificationPreviewProfile": MessageLookupByLibrary.simpleMessage(
      "ReClash · Current profile",
    ),
    "notificationPreviewRoute": MessageLookupByLibrary.simpleMessage(
      "Smart Routing · Automatic route",
    ),
    "notificationPreviewScenario": MessageLookupByLibrary.simpleMessage(
      "Preview scenario",
    ),
    "notificationPreviewServer": MessageLookupByLibrary.simpleMessage(
      "Server · Tokyo 01",
    ),
    "notificationPreviewSession": MessageLookupByLibrary.simpleMessage(
      "Session · ↓ 1.2 GB  ↑ 184 MB",
    ),
    "notificationPreviewSpeed": MessageLookupByLibrary.simpleMessage(
      "↓ 12.4 MB/s  ↑ 1.8 MB/s",
    ),
    "notificationPrivacy": MessageLookupByLibrary.simpleMessage("Privacy"),
    "notificationProtectionDesc": MessageLookupByLibrary.simpleMessage(
      "The persistent notification shows whether your protection is active.",
    ),
    "notificationProtectionTitle": MessageLookupByLibrary.simpleMessage(
      "Protection status",
    ),
    "notificationReminders": MessageLookupByLibrary.simpleMessage("Reminders"),
    "notificationRemindersDesc": MessageLookupByLibrary.simpleMessage(
      "Reminders use their own channel and arrive at every notification level.",
    ),
    "notificationRemoveComponent": MessageLookupByLibrary.simpleMessage(
      "Remove from notification",
    ),
    "notificationReorder": MessageLookupByLibrary.simpleMessage("Reorder"),
    "notificationScenarioLockScreen": MessageLookupByLibrary.simpleMessage(
      "Lock screen",
    ),
    "notificationScenarioNormal": MessageLookupByLibrary.simpleMessage(
      "Normal",
    ),
    "notificationScenarioPaused": MessageLookupByLibrary.simpleMessage(
      "Paused",
    ),
    "notificationScenarioProblem": MessageLookupByLibrary.simpleMessage(
      "Problem",
    ),
    "notificationScenarioRouting": MessageLookupByLibrary.simpleMessage(
      "Routing",
    ),
    "notificationSelectServerGroup": MessageLookupByLibrary.simpleMessage(
      "Choose server group",
    ),
    "notificationServerGroupMissing": MessageLookupByLibrary.simpleMessage(
      "The chosen group is missing from the profile",
    ),
    "notificationServiceChannel": MessageLookupByLibrary.simpleMessage(
      "Service channel",
    ),
    "notificationSessionTraffic": MessageLookupByLibrary.simpleMessage(
      "Session traffic",
    ),
    "notificationSessionTrafficDesc": MessageLookupByLibrary.simpleMessage(
      "Show uploaded and downloaded traffic for this session",
    ),
    "notificationSmartRouting": MessageLookupByLibrary.simpleMessage(
      "Smart Routing",
    ),
    "notificationSmartRoutingDesc": MessageLookupByLibrary.simpleMessage(
      "Show the active Smart Routing decision",
    ),
    "notificationSubscriptionChannel": MessageLookupByLibrary.simpleMessage(
      "Subscription reminders channel",
    ),
    "notificationSubscriptionReminders": MessageLookupByLibrary.simpleMessage(
      "Subscription reminders",
    ),
    "notificationSubscriptionRemindersDesc":
        MessageLookupByLibrary.simpleMessage(
          "Notify when a subscription needs attention",
        ),
    "notificationVisibility": MessageLookupByLibrary.simpleMessage(
      "Notification level",
    ),
    "notificationVisibilityAlways": MessageLookupByLibrary.simpleMessage(
      "Always shown",
    ),
    "notificationVisibilityCurrentServer": MessageLookupByLibrary.simpleMessage(
      "Shown while a server group is resolved",
    ),
    "notificationVisibilityDetailed": MessageLookupByLibrary.simpleMessage(
      "Detailed",
    ),
    "notificationVisibilityDoctorProblems":
        MessageLookupByLibrary.simpleMessage(
          "Shown while a problem is detected",
        ),
    "notificationVisibilityMinimal": MessageLookupByLibrary.simpleMessage(
      "Minimal",
    ),
    "notificationVisibilityOff": MessageLookupByLibrary.simpleMessage("Off"),
    "notificationVisibilitySessionTraffic":
        MessageLookupByLibrary.simpleMessage(
          "Shown while the session has traffic",
        ),
    "notificationVisibilitySmartRoutingOn":
        MessageLookupByLibrary.simpleMessage("Shown while Smart routing is on"),
    "notificationVisibilitySpeedIdle": MessageLookupByLibrary.simpleMessage(
      "Hidden while no traffic is flowing",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "No profiles yet, please add one first",
    ),
    "nullTip": m44,
    "numberTip": m45,
    "off": MessageLookupByLibrary.simpleMessage("Off"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Icon only"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Only count proxy traffic",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, only proxy traffic is counted",
    ),
    "openInBrowser": MessageLookupByLibrary.simpleMessage("Open in browser"),
    "optional": MessageLookupByLibrary.simpleMessage("Optional"),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Other contributors",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Outbound mode"),
    "override": MessageLookupByLibrary.simpleMessage("Override"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("Override DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "When enabled, the DNS options in the profile are overridden",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage("Override mode"),
    "overrideNetworkSettings": MessageLookupByLibrary.simpleMessage(
      "Override network settings",
    ),
    "overrideNetworkSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Apply the app port, IPv6, allow-lan, find-process-mode and TUN stack instead of the subscription values",
    ),
    "overrideScript": MessageLookupByLibrary.simpleMessage("Override script"),
    "overwriteTypeCustom": MessageLookupByLibrary.simpleMessage("Custom"),
    "overwriteTypeCustomDesc": MessageLookupByLibrary.simpleMessage(
      "Custom mode: fully customize proxy groups and rules",
    ),
    "pageAnimation": MessageLookupByLibrary.simpleMessage("Page animation"),
    "pageAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Animate switching between pages",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("Palette"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "paste": MessageLookupByLibrary.simpleMessage("Paste"),
    "pasteFromClipboard": MessageLookupByLibrary.simpleMessage("Paste"),
    "pause": MessageLookupByLibrary.simpleMessage("Pause"),
    "pauseVpn": MessageLookupByLibrary.simpleMessage("Pausing VPN..."),
    "paused": MessageLookupByLibrary.simpleMessage("Paused"),
    "perpetualSubscription": MessageLookupByLibrary.simpleMessage(
      "Perpetual subscription",
    ),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("Choose from album"),
    "pickNetwork": MessageLookupByLibrary.simpleMessage("Pick a network"),
    "pickNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi networks visible around you",
    ),
    "pickNetworkEmpty": MessageLookupByLibrary.simpleMessage(
      "No Wi-Fi networks found",
    ),
    "pickNetworkGrantLocation": MessageLookupByLibrary.simpleMessage(
      "Location permission is required to list nearby Wi-Fi networks",
    ),
    "pickNetworkRefresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "pickNetworkScanning": MessageLookupByLibrary.simpleMessage(
      "Looking for nearby Wi-Fi networks…",
    ),
    "pinWindow": MessageLookupByLibrary.simpleMessage("Pin window"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Please bind WebDAV",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Please enter a script name",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Please upload a valid QR code",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a different port",
    ),
    "portTip": m46,
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Prefer HTTP/3 for DoH",
    ),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Prerequisites"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("Please press a key"),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("Previous match"),
    "process": MessageLookupByLibrary.simpleMessage("Process"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Please enter a valid interval"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Please enter the auto-update interval",
        ),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "The profile has been modified. Turn off auto update?",
    ),
    "profileImportEmptyResponse": MessageLookupByLibrary.simpleMessage(
      "The server returned an empty profile",
    ),
    "profileImportFailed": MessageLookupByLibrary.simpleMessage(
      "Could not import the profile",
    ),
    "profileImportFileReadFailed": MessageLookupByLibrary.simpleMessage(
      "Could not read the selected file",
    ),
    "profileImportFormatClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "profileImportFormatLinks": MessageLookupByLibrary.simpleMessage(
      "Share links",
    ),
    "profileImportFormatSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box",
    ),
    "profileImportFormatWireguard": MessageLookupByLibrary.simpleMessage(
      "WireGuard",
    ),
    "profileImportFormatXray": MessageLookupByLibrary.simpleMessage("Xray"),
    "profileImportInvalidConfig": MessageLookupByLibrary.simpleMessage(
      "The profile configuration is invalid",
    ),
    "profileImportSkippedNodes": m47,
    "profileImportSuccess": MessageLookupByLibrary.simpleMessage(
      "Profile imported",
    ),
    "profileImportSuccessSummary": m48,
    "profileImportUnsupportedLink": MessageLookupByLibrary.simpleMessage(
      "The import link is damaged or unsupported",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter the profile name",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid profile URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter the profile URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profiles"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Sort profiles"),
    "project": MessageLookupByLibrary.simpleMessage("Project"),
    "providerView": MessageLookupByLibrary.simpleMessage("Provider view"),
    "providerViewDesc": MessageLookupByLibrary.simpleMessage(
      "Let this subscription dress the proxies page. What you change stays yours.",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("External resources"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxiesCount": m49,
    "proxiesEmpty": MessageLookupByLibrary.simpleMessage("Proxies are empty"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Proxy chain"),
    "proxyDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "The selected proxies are abnormal",
    ),
    "proxyFilter": MessageLookupByLibrary.simpleMessage("Proxy filter"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proxy group"),
    "proxyGroupDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "The current proxy group is abnormal",
    ),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy group is empty",
    ),
    "proxyGroupNameDuplicate": MessageLookupByLibrary.simpleMessage(
      "Duplicate proxy group name",
    ),
    "proxyGroupNameEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy group name cannot be empty",
    ),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("Proxy nameserver"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Used to resolve proxy node domains",
    ),
    "proxyProviderDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "The selected proxy providers are abnormal",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Proxy providers"),
    "proxyProvidersEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy providers are empty",
    ),
    "proxyProvidersNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy providers cannot be empty",
    ),
    "proxyType": MessageLookupByLibrary.simpleMessage("Proxy type"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Prune cache"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Pure black mode"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR code"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Scan a QR code to obtain a profile",
    ),
    "quickFill": MessageLookupByLibrary.simpleMessage("Quick fill"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Rainbow"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir port"),
    "redo": MessageLookupByLibrary.simpleMessage("Redo"),
    "reduceMotion": MessageLookupByLibrary.simpleMessage("Reduce motion"),
    "reduceMotionDesc": MessageLookupByLibrary.simpleMessage(
      "Disable decorative animations",
    ),
    "reduceMotionSystemHint": MessageLookupByLibrary.simpleMessage(
      "Already enabled in system settings",
    ),
    "reload": MessageLookupByLibrary.simpleMessage("Reload"),
    "remaining": MessageLookupByLibrary.simpleMessage("Remaining"),
    "remainingTraffic": MessageLookupByLibrary.simpleMessage("Remaining"),
    "remote": MessageLookupByLibrary.simpleMessage("Remote"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Back up data to WebDAV",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Remote destination",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "renewSubscription": MessageLookupByLibrary.simpleMessage(
      "Renew subscription",
    ),
    "request": MessageLookupByLibrary.simpleMessage("Request"),
    "requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "View recent request records",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "This page has changes. Are you sure you want to reset?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to reset?",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Information about external resources",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Respect rules"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS connections follow rules; requires proxy-server-nameserver",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("Restart"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to restart the core?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restore"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("Restore all data"),
    "restoreException": MessageLookupByLibrary.simpleMessage("Restore error"),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data from a file",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data from WebDAV",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Restore profiles only",
    ),
    "restorePreviewDescription": MessageLookupByLibrary.simpleMessage(
      "Nothing will change until you confirm.",
    ),
    "restorePreviewTitle": MessageLookupByLibrary.simpleMessage(
      "Review restore",
    ),
    "restoreProfilesCount": m50,
    "restoreProxyGroupsCount": m51,
    "restoreRulesCount": m52,
    "restoreScriptsCount": m53,
    "restoreSettingsIncluded": MessageLookupByLibrary.simpleMessage(
      "Settings included",
    ),
    "restoreSettingsNotIncluded": MessageLookupByLibrary.simpleMessage(
      "This backup does not contain settings",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("Restore strategy"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage(
      "Compatible",
    ),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("Override"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Restore successful",
    ),
    "resume": MessageLookupByLibrary.simpleMessage("Resume"),
    "roleAuthor": MessageLookupByLibrary.simpleMessage("Author and maintainer"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Route addresses"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "Configure the listened route addresses",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("Route mode"),
    "routeModeBypassPrivate": MessageLookupByLibrary.simpleMessage(
      "Bypass private addresses",
    ),
    "routeModeConfig": MessageLookupByLibrary.simpleMessage("Use config"),
    "ru": MessageLookupByLibrary.simpleMessage("Russian"),
    "rule": MessageLookupByLibrary.simpleMessage("Rule"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage(
      "Logical rule AND",
    ),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Match the full domain",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "Match a domain keyword",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Match a domain regex",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match a domain suffix",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Wildcard match; only * and ? are supported",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "Match the DSCP mark (tproxy UDP inbound only)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match the destination port range",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Match the IP\'s country code",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Match domains in Geosite",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "Match the inbound name",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match the inbound port",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "Match the inbound type",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "Match the inbound username; separate multiple usernames with /",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Match the IP\'s ASN",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "Match an IP address range; IP-CIDR6 is just an alias",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Match an IP address range",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match an IP suffix range",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "Match all requests, no conditions needed",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Match TCP or UDP",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage(
      "Logical rule NOT",
    ),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("Logical rule OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process name; matches the package name on Android",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process name regex; matches the package name on Android",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process name wildcard; only * and ? are supported",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Match by the full process path",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process path regex",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process path wildcard; only * and ? are supported",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "Match the rematch name; separate multiple names with /",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Reference a rule set; requires rule-providers",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Match the source IP\'s country code",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Match the source IP\'s ASN",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Match a source IP address range",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match a source IP suffix range",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match the source port range",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Match into a sub-rule; mind the parentheses",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Match the Linux user ID",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("Rule is empty"),
    "ruleName": MessageLookupByLibrary.simpleMessage("Rule name"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Rule set"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Rule target"),
    "rules": MessageLookupByLibrary.simpleMessage("Rules"),
    "rulesCount": m54,
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save the changes?"),
    "schedule": MessageLookupByLibrary.simpleMessage("Scheduled"),
    "scheduleDesc": m55,
    "script": MessageLookupByLibrary.simpleMessage("Script"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Script mode: uses external extension scripts to override the configuration in one click",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Scroll to selected",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "searchApps": MessageLookupByLibrary.simpleMessage("Search apps"),
    "seconds": MessageLookupByLibrary.simpleMessage("seconds"),
    "secondsCount": m56,
    "selectAll": MessageLookupByLibrary.simpleMessage("Select all"),
    "selectMatchTarget": MessageLookupByLibrary.simpleMessage(
      "Select MATCH-TARGET",
    ),
    "selectProxies": MessageLookupByLibrary.simpleMessage("Select proxies"),
    "selectProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Select proxy providers",
    ),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Please select a rule set",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Please select a split strategy",
    ),
    "selectSubRule": MessageLookupByLibrary.simpleMessage(
      "Please select a sub-rule",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "selectedCountTitle": m57,
    "sendDeviceIdentity": MessageLookupByLibrary.simpleMessage("Send HWID"),
    "sendDeviceIdentityDesc": MessageLookupByLibrary.simpleMessage(
      "Send device identifier, app version and device name to proxy provider server",
    ),
    "serviceInfo": MessageLookupByLibrary.simpleMessage("Service"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "setupAddAnotherProfile": MessageLookupByLibrary.simpleMessage(
      "Add another",
    ),
    "setupAutoRun": MessageLookupByLibrary.simpleMessage(
      "Connect when ReClash opens",
    ),
    "setupAutoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Starts the VPN automatically after a valid profile is loaded",
    ),
    "setupAutoRunUnavailable": MessageLookupByLibrary.simpleMessage(
      "Add a profile to enable automatic connection",
    ),
    "setupBack": MessageLookupByLibrary.simpleMessage("Back"),
    "setupContinueWithoutProfile": MessageLookupByLibrary.simpleMessage(
      "Continue without a profile",
    ),
    "setupContinueWithoutProfileDesc": MessageLookupByLibrary.simpleMessage(
      "VPN stays off. You can add a profile later or use ByeDPI-only mode without a VPN provider.",
    ),
    "setupDataCollection": MessageLookupByLibrary.simpleMessage(
      "Send optional crash reports",
    ),
    "setupDataCollectionDesc": MessageLookupByLibrary.simpleMessage(
      "Helps find app crashes. No reports are sent unless you turn this on.",
    ),
    "setupDecline": MessageLookupByLibrary.simpleMessage(
      "Do not agree and exit",
    ),
    "setupDeleteProfile": MessageLookupByLibrary.simpleMessage("Delete"),
    "setupDone": MessageLookupByLibrary.simpleMessage("Done"),
    "setupDoneConnect": MessageLookupByLibrary.simpleMessage(
      "Done and connect",
    ),
    "setupFinishTitle": MessageLookupByLibrary.simpleMessage(
      "Review your setup",
    ),
    "setupLanguageDesc": MessageLookupByLibrary.simpleMessage(
      "You can change this later in settings",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage(
      "Choose your language",
    ),
    "setupLegalDetails": MessageLookupByLibrary.simpleMessage(
      "Read the full disclaimer",
    ),
    "setupLegalLicense": MessageLookupByLibrary.simpleMessage(
      "Open-source licenses",
    ),
    "setupLegalSummary": MessageLookupByLibrary.simpleMessage(
      "ReClash creates a local VPN connection to route traffic. You choose and are responsible for the configuration or provider you use.",
    ),
    "setupLegalTitle": MessageLookupByLibrary.simpleMessage(
      "Before you continue",
    ),
    "setupNext": MessageLookupByLibrary.simpleMessage("Next"),
    "setupPermissionBattery": MessageLookupByLibrary.simpleMessage(
      "Battery optimization",
    ),
    "setupPermissionBatteryDesc": MessageLookupByLibrary.simpleMessage(
      "Allow ReClash to keep the VPN active in the background",
    ),
    "setupPermissionChecking": MessageLookupByLibrary.simpleMessage(
      "Checking…",
    ),
    "setupPermissionDeferred": MessageLookupByLibrary.simpleMessage(
      "Requested on first connection",
    ),
    "setupPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "Not allowed",
    ),
    "setupPermissionError": MessageLookupByLibrary.simpleMessage(
      "Could not check",
    ),
    "setupPermissionGranted": MessageLookupByLibrary.simpleMessage("Allowed"),
    "setupPermissionNotifications": MessageLookupByLibrary.simpleMessage(
      "Notifications",
    ),
    "setupPermissionNotificationsDesc": MessageLookupByLibrary.simpleMessage(
      "Shows connection status while ReClash is running",
    ),
    "setupPermissionOpenSettings": MessageLookupByLibrary.simpleMessage(
      "Open settings",
    ),
    "setupPermissionRequest": MessageLookupByLibrary.simpleMessage("Allow"),
    "setupPermissionUnavailable": MessageLookupByLibrary.simpleMessage(
      "Unavailable",
    ),
    "setupPermissionVpn": MessageLookupByLibrary.simpleMessage(
      "VPN permission",
    ),
    "setupPermissionVpnDesc": MessageLookupByLibrary.simpleMessage(
      "The system will ask when you connect for the first time",
    ),
    "setupPermissionsTitle": MessageLookupByLibrary.simpleMessage(
      "Permissions",
    ),
    "setupProfileSourceNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash does not sell VPN access. Use a link, QR code, or config file from a provider you trust. Every profile is checked before it is saved.",
    ),
    "setupProfilesReady": m58,
    "setupRawConfig": MessageLookupByLibrary.simpleMessage("Raw configuration"),
    "setupRawConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Paste a Clash-compatible YAML configuration",
    ),
    "setupRegionDesc": MessageLookupByLibrary.simpleMessage(
      "Smart Routing uses this as a starting point when choosing a route. Your language only provides a suggestion.",
    ),
    "setupRegionNone": MessageLookupByLibrary.simpleMessage(
      "Other region or do not use Smart Routing",
    ),
    "setupRegionRecommended": MessageLookupByLibrary.simpleMessage(
      "Recommended for your language",
    ),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage(
      "Where is your current network?",
    ),
    "setupReplaceProfile": MessageLookupByLibrary.simpleMessage("Replace"),
    "setupReplaceProfileHint": MessageLookupByLibrary.simpleMessage(
      "Import a working replacement before the current profile is removed.",
    ),
    "setupRerun": MessageLookupByLibrary.simpleMessage("Run setup again"),
    "setupRerunDesc": MessageLookupByLibrary.simpleMessage(
      "Review language, profile, routing, and permissions without deleting your data",
    ),
    "setupRestore": MessageLookupByLibrary.simpleMessage(
      "Restore from a backup",
    ),
    "setupRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Restore settings and profiles from a ReClash, FlClashX, or FlClash backup",
    ),
    "setupSkip": MessageLookupByLibrary.simpleMessage(
      "Continue without a profile",
    ),
    "setupStepProgress": m59,
    "setupSubscriptionDesc": MessageLookupByLibrary.simpleMessage(
      "A profile contains the servers and rules ReClash needs to connect. Import one from your provider or a backup.",
    ),
    "setupSubscriptionReady": MessageLookupByLibrary.simpleMessage(
      "Profile ready",
    ),
    "setupSubscriptionTitle": MessageLookupByLibrary.simpleMessage(
      "Add a connection profile",
    ),
    "setupSummaryAutoRunOff": MessageLookupByLibrary.simpleMessage(
      "Automatic connection: off",
    ),
    "setupSummaryAutoRunOn": MessageLookupByLibrary.simpleMessage(
      "Automatic connection: on",
    ),
    "setupSummaryNoProfile": MessageLookupByLibrary.simpleMessage(
      "No VPN profile — VPN remains off; ByeDPI-only is available",
    ),
    "setupSummaryProfile": m60,
    "setupSummaryRouting": m61,
    "setupSummarySystemProxyOff": MessageLookupByLibrary.simpleMessage(
      "System proxy: off",
    ),
    "setupSummarySystemProxyOn": MessageLookupByLibrary.simpleMessage(
      "System proxy: on",
    ),
    "setupSummaryTitle": MessageLookupByLibrary.simpleMessage("Setup summary"),
    "setupSummaryTunOff": MessageLookupByLibrary.simpleMessage("TUN: off"),
    "setupSummaryTunOn": MessageLookupByLibrary.simpleMessage("TUN: on"),
    "setupSystemLanguage": MessageLookupByLibrary.simpleMessage(
      "System language",
    ),
    "setupSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Routes supported apps through ReClash without administrator access",
    ),
    "setupTunDesc": MessageLookupByLibrary.simpleMessage(
      "Routes all device traffic; your system may request administrator access when connecting",
    ),
    "setupWelcome": MessageLookupByLibrary.simpleMessage(
      "Get ready in a few clear steps",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Show"),
    "showLabels": MessageLookupByLibrary.simpleMessage("Show sidebar labels"),
    "showLess": MessageLookupByLibrary.simpleMessage("Collapse"),
    "showMore": MessageLookupByLibrary.simpleMessage("Expand"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Stop button in notification",
    ),
    "showNotificationStopActionDesc": MessageLookupByLibrary.simpleMessage(
      "Show a stop button on the persistent notification. Turn it off if your system keeps the notification expanded because of it",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Show password"),
    "shrink": MessageLookupByLibrary.simpleMessage("Compact"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Silent launch"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Start in the background",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "smartPause": MessageLookupByLibrary.simpleMessage("Smart pause"),
    "smartPauseCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Close connections",
    ),
    "smartPauseDesc": MessageLookupByLibrary.simpleMessage(
      "Pause the VPN automatically on trusted networks",
    ),
    "smartRouting": MessageLookupByLibrary.simpleMessage("Smart routing"),
    "smartRoutingActiveCircuits": MessageLookupByLibrary.simpleMessage(
      "Providers temporarily held back",
    ),
    "smartRoutingActiveMarkers": MessageLookupByLibrary.simpleMessage(
      "Checks temporarily held back",
    ),
    "smartRoutingAdmittedYes": MessageLookupByLibrary.simpleMessage("Allowed"),
    "smartRoutingAliveCount": m62,
    "smartRoutingAllServers": MessageLookupByLibrary.simpleMessage(
      "All servers",
    ),
    "smartRoutingAvailability": MessageLookupByLibrary.simpleMessage(
      "Availability",
    ),
    "smartRoutingAvailabilityValue": m63,
    "smartRoutingAverageFailover": MessageLookupByLibrary.simpleMessage(
      "Average switchover",
    ),
    "smartRoutingAverageRecovery": MessageLookupByLibrary.simpleMessage(
      "Average recovery",
    ),
    "smartRoutingBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Back to automatic",
    ),
    "smartRoutingBandLabel": m64,
    "smartRoutingBands": m65,
    "smartRoutingBehaviour": MessageLookupByLibrary.simpleMessage("Behaviour"),
    "smartRoutingBlockAbsent": MessageLookupByLibrary.simpleMessage(
      "Not in the current server list",
    ),
    "smartRoutingBlockCooling": m66,
    "smartRoutingBlockDisproven": MessageLookupByLibrary.simpleMessage(
      "Failed its checks here",
    ),
    "smartRoutingBlockLastResort": MessageLookupByLibrary.simpleMessage(
      "Local server, barred on this network",
    ),
    "smartRoutingBlockNoUdp": MessageLookupByLibrary.simpleMessage(
      "No UDP support",
    ),
    "smartRoutingBlockProviderCircuit": MessageLookupByLibrary.simpleMessage(
      "Provider temporarily held back after independent failures",
    ),
    "smartRoutingBlockTerrainUnfit": MessageLookupByLibrary.simpleMessage(
      "Nothing routes on this network yet",
    ),
    "smartRoutingBreaker": MessageLookupByLibrary.simpleMessage(
      "Whitelist specialist",
    ),
    "smartRoutingBreakerDesc": MessageLookupByLibrary.simpleMessage(
      "Kept for restricted networks, so it is not spent on an open one",
    ),
    "smartRoutingBreakerPatterns": MessageLookupByLibrary.simpleMessage(
      "Whitelist specialist names",
    ),
    "smartRoutingBreakerPatternsDesc": MessageLookupByLibrary.simpleMessage(
      "Name fragments that mark a server kept for restricted networks",
    ),
    "smartRoutingCanaries": MessageLookupByLibrary.simpleMessage(
      "Canary addresses",
    ),
    "smartRoutingCanariesAnswered": m67,
    "smartRoutingCanariesDomestic": MessageLookupByLibrary.simpleMessage(
      "Local canaries",
    ),
    "smartRoutingCanariesDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "Reached directly to tell a whitelist network from no connectivity at all",
    ),
    "smartRoutingCanariesForeign": MessageLookupByLibrary.simpleMessage(
      "Foreign canaries",
    ),
    "smartRoutingCanariesForeignDesc": MessageLookupByLibrary.simpleMessage(
      "Plain IP:port reached directly, to tell an open network from a shutdown",
    ),
    "smartRoutingCanaryDomestic": MessageLookupByLibrary.simpleMessage("local"),
    "smartRoutingCanaryForeign": MessageLookupByLibrary.simpleMessage(
      "foreign",
    ),
    "smartRoutingCensor": MessageLookupByLibrary.simpleMessage(
      "Censoring countries",
    ),
    "smartRoutingCensorDesc": MessageLookupByLibrary.simpleMessage(
      "A server here counts as local, so it is held back until a shutdown",
    ),
    "smartRoutingChosen": MessageLookupByLibrary.simpleMessage("Chosen server"),
    "smartRoutingChosenNone": MessageLookupByLibrary.simpleMessage(
      "No server chosen yet",
    ),
    "smartRoutingCoolFor": m68,
    "smartRoutingDeepScan": MessageLookupByLibrary.simpleMessage(
      "Check every server",
    ),
    "smartRoutingDeepScanHint": MessageLookupByLibrary.simpleMessage(
      "Ignores the probe budget, so it costs traffic",
    ),
    "smartRoutingDeepScanRunning": MessageLookupByLibrary.simpleMessage(
      "Checking every server…",
    ),
    "smartRoutingDegraded": MessageLookupByLibrary.simpleMessage("Throttled"),
    "smartRoutingDesc": MessageLookupByLibrary.simpleMessage(
      "Keeps a working server picked for every network, without opening the app",
    ),
    "smartRoutingDetection": MessageLookupByLibrary.simpleMessage("Detection"),
    "smartRoutingDomestic": MessageLookupByLibrary.simpleMessage(
      "Local servers during a shutdown",
    ),
    "smartRoutingDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "A last resort on a whitelist network, so local services keep working",
    ),
    "smartRoutingDomesticViaDirect": MessageLookupByLibrary.simpleMessage(
      "Domestic services go direct",
    ),
    "smartRoutingDomesticViaNode": MessageLookupByLibrary.simpleMessage(
      "Domestic services go through the chosen server",
    ),
    "smartRoutingDwell": MessageLookupByLibrary.simpleMessage("Settle time"),
    "smartRoutingDwellDesc": MessageLookupByLibrary.simpleMessage(
      "How long a working server is kept before a faster one wins",
    ),
    "smartRoutingEmpty": MessageLookupByLibrary.simpleMessage(
      "Nothing measured yet",
    ),
    "smartRoutingEngineAvailable": MessageLookupByLibrary.simpleMessage(
      "Time with a working route",
    ),
    "smartRoutingEngineDeepScan": MessageLookupByLibrary.simpleMessage(
      "Deep scan",
    ),
    "smartRoutingEngineLanes": MessageLookupByLibrary.simpleMessage(
      "Service lanes",
    ),
    "smartRoutingEngineLinkAge": MessageLookupByLibrary.simpleMessage(
      "Link age",
    ),
    "smartRoutingEngineMode": MessageLookupByLibrary.simpleMessage("Core mode"),
    "smartRoutingEnginePin": MessageLookupByLibrary.simpleMessage(
      "Pinned server",
    ),
    "smartRoutingEnginePreset": MessageLookupByLibrary.simpleMessage(
      "Region preset",
    ),
    "smartRoutingEngineReportAge": MessageLookupByLibrary.simpleMessage(
      "Report age",
    ),
    "smartRoutingEngineTerrain": MessageLookupByLibrary.simpleMessage(
      "Terrain code",
    ),
    "smartRoutingEngineTransport": MessageLookupByLibrary.simpleMessage(
      "Link transport",
    ),
    "smartRoutingEnvKey": MessageLookupByLibrary.simpleMessage(
      "Network memory key",
    ),
    "smartRoutingEvidenceDomesticFail": MessageLookupByLibrary.simpleMessage(
      "No local address answered",
    ),
    "smartRoutingEvidenceDomesticOk": MessageLookupByLibrary.simpleMessage(
      "A local address answered",
    ),
    "smartRoutingEvidenceForeignFail": MessageLookupByLibrary.simpleMessage(
      "No foreign address answered",
    ),
    "smartRoutingEvidenceForeignForged": MessageLookupByLibrary.simpleMessage(
      "A gate answered TLS with a forged certificate",
    ),
    "smartRoutingEvidenceForeignOk": MessageLookupByLibrary.simpleMessage(
      "A foreign address passed a certificate check",
    ),
    "smartRoutingEvidenceFresh": MessageLookupByLibrary.simpleMessage(
      "Confirmed by a recent check",
    ),
    "smartRoutingEvidenceLive": MessageLookupByLibrary.simpleMessage(
      "Confirmed by your own traffic",
    ),
    "smartRoutingEvidenceNone": MessageLookupByLibrary.simpleMessage(
      "Never confirmed",
    ),
    "smartRoutingEvidencePortal": MessageLookupByLibrary.simpleMessage(
      "The system flagged a sign-in page",
    ),
    "smartRoutingEvidenceStale": MessageLookupByLibrary.simpleMessage(
      "Last confirmed a while ago",
    ),
    "smartRoutingEvidenceUnvalidated": MessageLookupByLibrary.simpleMessage(
      "The system reports no internet access",
    ),
    "smartRoutingEvidenceValidated": MessageLookupByLibrary.simpleMessage(
      "The system confirmed internet access",
    ),
    "smartRoutingFails": m69,
    "smartRoutingFitNo": MessageLookupByLibrary.simpleMessage("Does not fit"),
    "smartRoutingFitYes": MessageLookupByLibrary.simpleMessage("Fits"),
    "smartRoutingFormatOffline": MessageLookupByLibrary.simpleMessage(
      "No connectivity",
    ),
    "smartRoutingFormatOfflineDesc": MessageLookupByLibrary.simpleMessage(
      "Nothing answers, local or foreign",
    ),
    "smartRoutingFormatOpen": MessageLookupByLibrary.simpleMessage(
      "Fully open",
    ),
    "smartRoutingFormatOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Nothing blocked between you and the open internet",
    ),
    "smartRoutingFormatPortal": MessageLookupByLibrary.simpleMessage(
      "Sign-in required",
    ),
    "smartRoutingFormatPortalDesc": MessageLookupByLibrary.simpleMessage(
      "The network wants you to log in before it passes traffic",
    ),
    "smartRoutingFormatRestricted": MessageLookupByLibrary.simpleMessage(
      "Restricted",
    ),
    "smartRoutingFormatRestrictedDesc": MessageLookupByLibrary.simpleMessage(
      "Only local services answer, foreign ones do not",
    ),
    "smartRoutingFormatUnknown": MessageLookupByLibrary.simpleMessage(
      "Still measuring",
    ),
    "smartRoutingFormatUnknownDesc": MessageLookupByLibrary.simpleMessage(
      "Not enough answers yet to tell",
    ),
    "smartRoutingHealthBlocked": MessageLookupByLibrary.simpleMessage(
      "blocked",
    ),
    "smartRoutingHealthUnknown": MessageLookupByLibrary.simpleMessage(
      "unchecked",
    ),
    "smartRoutingHealthUsable": MessageLookupByLibrary.simpleMessage("usable"),
    "smartRoutingHistory": MessageLookupByLibrary.simpleMessage(
      "Recent switches",
    ),
    "smartRoutingHistoryEmpty": MessageLookupByLibrary.simpleMessage(
      "No switches yet",
    ),
    "smartRoutingHostDelay": MessageLookupByLibrary.simpleMessage(
      "from the delay test",
    ),
    "smartRoutingIncidents": MessageLookupByLibrary.simpleMessage(
      "Detected outages",
    ),
    "smartRoutingIncumbentNo": MessageLookupByLibrary.simpleMessage(
      "Challenger",
    ),
    "smartRoutingIncumbentYes": MessageLookupByLibrary.simpleMessage("In use"),
    "smartRoutingIntro": MessageLookupByLibrary.simpleMessage(
      "Smart routing keeps a server that works on the current network and switches on its own when the network changes. Start from a region preset, then fine-tune strategy, checks and markers below.",
    ),
    "smartRoutingKept": MessageLookupByLibrary.simpleMessage("kept"),
    "smartRoutingKeyAdmission": MessageLookupByLibrary.simpleMessage(
      "Allowed to compete",
    ),
    "smartRoutingKeyBand": MessageLookupByLibrary.simpleMessage("Latency band"),
    "smartRoutingKeyEvidence": MessageLookupByLibrary.simpleMessage("Evidence"),
    "smartRoutingKeyIncumbent": MessageLookupByLibrary.simpleMessage(
      "Already in use",
    ),
    "smartRoutingKeyMisfit": MessageLookupByLibrary.simpleMessage(
      "Fit for this network",
    ),
    "smartRoutingKeyTiebreak": MessageLookupByLibrary.simpleMessage(
      "Stable tiebreak",
    ),
    "smartRoutingKeyUnproven": MessageLookupByLibrary.simpleMessage(
      "Has carried traffic",
    ),
    "smartRoutingKeyVerdict": MessageLookupByLibrary.simpleMessage("Verdict"),
    "smartRoutingLadderHint": MessageLookupByLibrary.simpleMessage(
      "Two servers are read line by line. The first line where they differ decides it, and nothing below that line is read at all.",
    ),
    "smartRoutingLastFailover": MessageLookupByLibrary.simpleMessage(
      "Last switchover",
    ),
    "smartRoutingLastRecovery": MessageLookupByLibrary.simpleMessage(
      "Last recovery",
    ),
    "smartRoutingLostAt": m70,
    "smartRoutingManualHold": MessageLookupByLibrary.simpleMessage(
      "Respect a manual pick",
    ),
    "smartRoutingManualHoldDesc": MessageLookupByLibrary.simpleMessage(
      "Keep the server you chose yourself until it stops working",
    ),
    "smartRoutingManualPinned": MessageLookupByLibrary.simpleMessage(
      "Held until it stops working",
    ),
    "smartRoutingMarkerIncidents": MessageLookupByLibrary.simpleMessage(
      "Service checks quarantined",
    ),
    "smartRoutingMarkerStatuses": MessageLookupByLibrary.simpleMessage(
      "Accepted statuses",
    ),
    "smartRoutingMarkerStatusesHint": MessageLookupByLibrary.simpleMessage(
      "Comma-separated, e.g. 200, 204, 404",
    ),
    "smartRoutingMarkerStatusesTip": MessageLookupByLibrary.simpleMessage(
      "Enter HTTP status codes separated by commas",
    ),
    "smartRoutingMarkerUrl": MessageLookupByLibrary.simpleMessage("URL"),
    "smartRoutingMarkers": MessageLookupByLibrary.simpleMessage(
      "Service checks",
    ),
    "smartRoutingMarkersDomestic": MessageLookupByLibrary.simpleMessage(
      "Local checks",
    ),
    "smartRoutingMarkersDomesticDesc": MessageLookupByLibrary.simpleMessage(
      "Used for local servers during a shutdown",
    ),
    "smartRoutingMarkersEmpty": MessageLookupByLibrary.simpleMessage(
      "No checks configured",
    ),
    "smartRoutingMarkersOpen": MessageLookupByLibrary.simpleMessage(
      "Open-internet checks",
    ),
    "smartRoutingMarkersOpenDesc": MessageLookupByLibrary.simpleMessage(
      "A server must return one of these statuses to count as proven",
    ),
    "smartRoutingMeasuredOver": m71,
    "smartRoutingMetered": MessageLookupByLibrary.simpleMessage("Metered link"),
    "smartRoutingNetworkFormat": MessageLookupByLibrary.simpleMessage(
      "Network",
    ),
    "smartRoutingNeverSwitched": MessageLookupByLibrary.simpleMessage(
      "No switch yet on this network",
    ),
    "smartRoutingNoAnswer": MessageLookupByLibrary.simpleMessage("no answer"),
    "smartRoutingNoRecovery": MessageLookupByLibrary.simpleMessage(
      "No recovered outage yet",
    ),
    "smartRoutingNoRivals": MessageLookupByLibrary.simpleMessage(
      "No other servers to compare with",
    ),
    "smartRoutingNoServers": MessageLookupByLibrary.simpleMessage(
      "No reachable servers",
    ),
    "smartRoutingNodeChecks": MessageLookupByLibrary.simpleMessage(
      "Server checks",
    ),
    "smartRoutingNodeNoUdp": MessageLookupByLibrary.simpleMessage("No UDP"),
    "smartRoutingNodeUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "smartRoutingNodesMeasured": m72,
    "smartRoutingNotBreaker": MessageLookupByLibrary.simpleMessage(
      "General purpose",
    ),
    "smartRoutingOffHint": MessageLookupByLibrary.simpleMessage(
      "Turn smart routing on to let it pick servers for you",
    ),
    "smartRoutingOn": MessageLookupByLibrary.simpleMessage(
      "Smart routing is on",
    ),
    "smartRoutingOverview": MessageLookupByLibrary.simpleMessage(
      "Routing overview",
    ),
    "smartRoutingPortal": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi sign-in required",
    ),
    "smartRoutingPreset": MessageLookupByLibrary.simpleMessage("Preset"),
    "smartRoutingPresetChina": MessageLookupByLibrary.simpleMessage("China"),
    "smartRoutingPresetEdited": m73,
    "smartRoutingPresetIran": MessageLookupByLibrary.simpleMessage("Iran"),
    "smartRoutingPresetOff": MessageLookupByLibrary.simpleMessage("Off"),
    "smartRoutingPresetRussia": MessageLookupByLibrary.simpleMessage("Russia"),
    "smartRoutingProbeBudget": m74,
    "smartRoutingProbing": MessageLookupByLibrary.simpleMessage("Probing"),
    "smartRoutingProvenNo": MessageLookupByLibrary.simpleMessage("Not yet"),
    "smartRoutingProvenYes": MessageLookupByLibrary.simpleMessage("Yes"),
    "smartRoutingProviderIncidents": MessageLookupByLibrary.simpleMessage(
      "Provider circuits opened",
    ),
    "smartRoutingRankOrder": MessageLookupByLibrary.simpleMessage(
      "Ranking order",
    ),
    "smartRoutingRanking": MessageLookupByLibrary.simpleMessage("Ranking"),
    "smartRoutingRankingDesc": MessageLookupByLibrary.simpleMessage(
      "Latency bands are fixed: a knob here would let milliseconds outrank whether a server works",
    ),
    "smartRoutingReasonColdStart": MessageLookupByLibrary.simpleMessage(
      "First pick on this network",
    ),
    "smartRoutingReasonDegraded": MessageLookupByLibrary.simpleMessage(
      "Previous server stopped passing traffic",
    ),
    "smartRoutingReasonDwellHold": MessageLookupByLibrary.simpleMessage(
      "Waiting out the settle time before switching",
    ),
    "smartRoutingReasonHold": MessageLookupByLibrary.simpleMessage(
      "Working, nothing better found",
    ),
    "smartRoutingReasonIncumbentDead": MessageLookupByLibrary.simpleMessage(
      "Previous server stopped answering",
    ),
    "smartRoutingReasonLatencyGain": MessageLookupByLibrary.simpleMessage(
      "This one is a latency band faster",
    ),
    "smartRoutingReasonManualHold": MessageLookupByLibrary.simpleMessage(
      "Respecting the server you picked",
    ),
    "smartRoutingReasonMeasuring": MessageLookupByLibrary.simpleMessage(
      "Checking the candidate before switching",
    ),
    "smartRoutingReasonNoCandidate": MessageLookupByLibrary.simpleMessage(
      "No server passed the checks",
    ),
    "smartRoutingReasonPinReturn": MessageLookupByLibrary.simpleMessage(
      "The server you picked works again",
    ),
    "smartRoutingReasonStranded": MessageLookupByLibrary.simpleMessage(
      "Nothing reachable, keeping the current server",
    ),
    "smartRoutingReasonTerrainChanged": MessageLookupByLibrary.simpleMessage(
      "The network changed",
    ),
    "smartRoutingReasonVerdictGain": MessageLookupByLibrary.simpleMessage(
      "This one is proven to reach the open internet",
    ),
    "smartRoutingRecheck": MessageLookupByLibrary.simpleMessage("Check now"),
    "smartRoutingRegion": MessageLookupByLibrary.simpleMessage("Region"),
    "smartRoutingRequireUdp": MessageLookupByLibrary.simpleMessage(
      "Require UDP support",
    ),
    "smartRoutingRequireUdpDesc": MessageLookupByLibrary.simpleMessage(
      "Skip servers that cannot carry calls and games",
    ),
    "smartRoutingResetSection": MessageLookupByLibrary.simpleMessage(
      "Reset to preset",
    ),
    "smartRoutingResetSectionDesc": MessageLookupByLibrary.simpleMessage(
      "Restores the region defaults and keeps smart routing on",
    ),
    "smartRoutingRestricted": MessageLookupByLibrary.simpleMessage(
      "Restricted network · local services stay direct",
    ),
    "smartRoutingRetrying": MessageLookupByLibrary.simpleMessage(
      "Server is not answering, looking for another",
    ),
    "smartRoutingRuleOnly": MessageLookupByLibrary.simpleMessage(
      "Available in Rule mode only",
    ),
    "smartRoutingRungVersus": m75,
    "smartRoutingSearching": MessageLookupByLibrary.simpleMessage(
      "Picking a server…",
    ),
    "smartRoutingSeconds": m76,
    "smartRoutingSectionEngine": MessageLookupByLibrary.simpleMessage("Engine"),
    "smartRoutingSectionHealth": MessageLookupByLibrary.simpleMessage(
      "Servers",
    ),
    "smartRoutingSectionHistory": MessageLookupByLibrary.simpleMessage(
      "Earlier switches",
    ),
    "smartRoutingSectionLadder": MessageLookupByLibrary.simpleMessage(
      "How servers are compared",
    ),
    "smartRoutingSectionNetwork": MessageLookupByLibrary.simpleMessage(
      "Network",
    ),
    "smartRoutingSectionReliability": MessageLookupByLibrary.simpleMessage(
      "Reliability",
    ),
    "smartRoutingSectionRivals": MessageLookupByLibrary.simpleMessage(
      "Against the chosen server",
    ),
    "smartRoutingSectionRound": MessageLookupByLibrary.simpleMessage(
      "Decision",
    ),
    "smartRoutingServers": MessageLookupByLibrary.simpleMessage("Servers"),
    "smartRoutingServersCount": m77,
    "smartRoutingServiceAnyProvider": MessageLookupByLibrary.simpleMessage(
      "Any provider",
    ),
    "smartRoutingServiceCandidates": m78,
    "smartRoutingServiceEnabled": MessageLookupByLibrary.simpleMessage(
      "Use service route",
    ),
    "smartRoutingServiceEnabledDesc": MessageLookupByLibrary.simpleMessage(
      "Send this service through a matching specialist node",
    ),
    "smartRoutingServiceFallback": MessageLookupByLibrary.simpleMessage(
      "When no specialist works",
    ),
    "smartRoutingServiceFallbackActiveMain":
        MessageLookupByLibrary.simpleMessage(
          "No specialist ready · using the main route",
        ),
    "smartRoutingServiceFallbackActiveReject":
        MessageLookupByLibrary.simpleMessage(
          "No specialist ready · service blocked",
        ),
    "smartRoutingServiceFallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Choose what the hidden service selector uses while specialists are unavailable",
    ),
    "smartRoutingServiceFallbackMain": MessageLookupByLibrary.simpleMessage(
      "Use the main Smart Routing node",
    ),
    "smartRoutingServiceFallbackReject": MessageLookupByLibrary.simpleMessage(
      "Block the service",
    ),
    "smartRoutingServiceGemini": MessageLookupByLibrary.simpleMessage(
      "Gemini access",
    ),
    "smartRoutingServiceManual": MessageLookupByLibrary.simpleMessage(
      "Manual selectors",
    ),
    "smartRoutingServiceManualEmpty": MessageLookupByLibrary.simpleMessage(
      "No manual selectors",
    ),
    "smartRoutingServiceManualEmptyDesc": MessageLookupByLibrary.simpleMessage(
      "Add a name fragment and, optionally, its provider",
    ),
    "smartRoutingServiceManualSelector": MessageLookupByLibrary.simpleMessage(
      "Manual specialist selector",
    ),
    "smartRoutingServiceMatchedNone": MessageLookupByLibrary.simpleMessage(
      "No servers match yet",
    ),
    "smartRoutingServiceNameContains": MessageLookupByLibrary.simpleMessage(
      "Name contains",
    ),
    "smartRoutingServiceNameContainsDesc": MessageLookupByLibrary.simpleMessage(
      "Case-sensitive fragment of the node name",
    ),
    "smartRoutingServiceNoCandidates": MessageLookupByLibrary.simpleMessage(
      "No specialist selectors",
    ),
    "smartRoutingServicePending": MessageLookupByLibrary.simpleMessage(
      "Waiting for the engine",
    ),
    "smartRoutingServiceProvider": m79,
    "smartRoutingServiceProviderCandidates": m80,
    "smartRoutingServiceProviderDesc": MessageLookupByLibrary.simpleMessage(
      "Exact provider name; leave empty to match any provider",
    ),
    "smartRoutingServiceProviderOptional": MessageLookupByLibrary.simpleMessage(
      "Provider (optional)",
    ),
    "smartRoutingServiceProviderSource": MessageLookupByLibrary.simpleMessage(
      "Subscription manifest",
    ),
    "smartRoutingServiceReady": m81,
    "smartRoutingServiceRoute": MessageLookupByLibrary.simpleMessage("Route"),
    "smartRoutingServiceRoutes": MessageLookupByLibrary.simpleMessage(
      "Service routes",
    ),
    "smartRoutingServiceRoutesEmpty": MessageLookupByLibrary.simpleMessage(
      "No service routes are set up",
    ),
    "smartRoutingServiceSources": MessageLookupByLibrary.simpleMessage(
      "Specialist sources",
    ),
    "smartRoutingServiceStatus": MessageLookupByLibrary.simpleMessage("Status"),
    "smartRoutingServiceTokenTooLong": m82,
    "smartRoutingServiceVia": m83,
    "smartRoutingServiceYouTube": MessageLookupByLibrary.simpleMessage(
      "YouTube without ads",
    ),
    "smartRoutingStandbyHits": MessageLookupByLibrary.simpleMessage(
      "Recovered through a warm standby",
    ),
    "smartRoutingStepAdmit": MessageLookupByLibrary.simpleMessage(
      "Decided who is allowed",
    ),
    "smartRoutingStepAdmitBody": m84,
    "smartRoutingStepDecision": MessageLookupByLibrary.simpleMessage(
      "Landed here",
    ),
    "smartRoutingStepNetwork": MessageLookupByLibrary.simpleMessage(
      "Read the network",
    ),
    "smartRoutingStepRank": MessageLookupByLibrary.simpleMessage(
      "Ranked what was left",
    ),
    "smartRoutingStepRankBody": MessageLookupByLibrary.simpleMessage(
      "The first line where two servers differ is the one that decides",
    ),
    "smartRoutingStrategy": MessageLookupByLibrary.simpleMessage("Strategy"),
    "smartRoutingStrategyBalanced": MessageLookupByLibrary.simpleMessage(
      "Balanced",
    ),
    "smartRoutingStrategyDesc": MessageLookupByLibrary.simpleMessage(
      "How the engine trades latency for stability",
    ),
    "smartRoutingStrategyLowestLatency": MessageLookupByLibrary.simpleMessage(
      "Lowest latency",
    ),
    "smartRoutingSwitchLine": m85,
    "smartRoutingSwitched": MessageLookupByLibrary.simpleMessage("switched"),
    "smartRoutingSwitchedAgo": m86,
    "smartRoutingTabDetails": MessageLookupByLibrary.simpleMessage("Details"),
    "smartRoutingTabOverview": MessageLookupByLibrary.simpleMessage("Overview"),
    "smartRoutingTabRanking": MessageLookupByLibrary.simpleMessage("Ranking"),
    "smartRoutingTechnical": MessageLookupByLibrary.simpleMessage(
      "Technical detail",
    ),
    "smartRoutingTiedAll": MessageLookupByLibrary.simpleMessage(
      "Identical on every line",
    ),
    "smartRoutingUntested": MessageLookupByLibrary.simpleMessage("untested"),
    "smartRoutingVerdictLastResort": MessageLookupByLibrary.simpleMessage(
      "Last resort",
    ),
    "smartRoutingVerdictPreferred": MessageLookupByLibrary.simpleMessage(
      "Reaches the open internet",
    ),
    "smartRoutingVerdictReject": MessageLookupByLibrary.simpleMessage(
      "Not usable",
    ),
    "smartRoutingVerdictViable": MessageLookupByLibrary.simpleMessage("Usable"),
    "smartRoutingWaitingNetwork": MessageLookupByLibrary.simpleMessage(
      "Smart routing is waiting for a network",
    ),
    "smartRoutingWaitingTunnel": MessageLookupByLibrary.simpleMessage(
      "Smart routing is on · waiting for the tunnel",
    ),
    "smartRoutingWave": MessageLookupByLibrary.simpleMessage(
      "Servers per check",
    ),
    "smartRoutingWaveDesc": MessageLookupByLibrary.simpleMessage(
      "How many servers one background check measures",
    ),
    "smartRoutingWaveNodes": m87,
    "smartRoutingWhatWasTested": MessageLookupByLibrary.simpleMessage(
      "Link check",
    ),
    "smartRoutingWhy": MessageLookupByLibrary.simpleMessage("Why"),
    "smartRoutingWinsAt": m88,
    "socksPort": MessageLookupByLibrary.simpleMessage("SOCKS port"),
    "sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "source": MessageLookupByLibrary.simpleMessage("Source"),
    "sourceCode": MessageLookupByLibrary.simpleMessage("Source code"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Source IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Special proxy"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Special rules"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("Speed statistics"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("Split strategy"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Split strategy cannot be empty",
    ),
    "stackMode": MessageLookupByLibrary.simpleMessage("Stack mode"),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Standard mode: overrides the basic configuration and offers simple rule additions",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Starting VPN..."),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "When disabled, the system DNS is used",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Stopping VPN..."),
    "style": MessageLookupByLibrary.simpleMessage("Style"),
    "subRule": MessageLookupByLibrary.simpleMessage("Sub-rule"),
    "subRuleEmpty": MessageLookupByLibrary.simpleMessage("Sub-rule is empty"),
    "subRuleNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Sub-rule cannot be empty",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "subscriptionCaption": MessageLookupByLibrary.simpleMessage("Subscription"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage("Auto"),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage("Custom"),
    "subscriptionClientDesc": MessageLookupByLibrary.simpleMessage(
      "The app requests the subscription in this client\'s format",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientLabel": MessageLookupByLibrary.simpleMessage(
      "Client format",
    ),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "Sing-box",
    ),
    "subscriptionClientV2rayNG": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionConfigurationSource": MessageLookupByLibrary.simpleMessage(
      "the supplied configuration",
    ),
    "subscriptionDomainMoved": m89,
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Your subscription has expired",
    ),
    "subscriptionExpiresInDays": m90,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "Your subscription expires today",
    ),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Subscription info",
    ),
    "subscriptionNoQuota": MessageLookupByLibrary.simpleMessage(
      "This subscription reports no traffic quota or end date",
    ),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage(
      "Subscription reminders",
    ),
    "subscriptionProviderInterval": m91,
    "subscriptionUndialable": MessageLookupByLibrary.simpleMessage(
      "None of the nodes in this subscription can be reached — try another client format",
    ),
    "subscriptionUpdated": MessageLookupByLibrary.simpleMessage("Updated"),
    "support": MessageLookupByLibrary.simpleMessage("Support"),
    "sync": MessageLookupByLibrary.simpleMessage("Sync"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "systemApp": MessageLookupByLibrary.simpleMessage("System apps"),
    "systemColor": MessageLookupByLibrary.simpleMessage("Use system color"),
    "systemColorDesc": MessageLookupByLibrary.simpleMessage(
      "Take the accent color from the OS (Material You)",
    ),
    "systemProxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Set the system proxy",
    ),
    "systemSeed": MessageLookupByLibrary.simpleMessage("System seed"),
    "tab": MessageLookupByLibrary.simpleMessage("Tab"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Tab animation"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Only effective in mobile view",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("Tap to authorize"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP concurrent"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "Allow concurrent TCP connections",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage("Test interval"),
    "testUrl": MessageLookupByLibrary.simpleMessage("Test URL"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("Test when used"),
    "textScale": MessageLookupByLibrary.simpleMessage("Text scaling"),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Theme color"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Set dark mode and adjust colors",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Theme mode"),
    "tight": MessageLookupByLibrary.simpleMessage("Tight"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "timeout": MessageLookupByLibrary.simpleMessage("Timeout"),
    "tip": MessageLookupByLibrary.simpleMessage("Tip"),
    "tk": MessageLookupByLibrary.simpleMessage("Turkmen"),
    "toggle": MessageLookupByLibrary.simpleMessage("Toggle"),
    "toggleLabel": MessageLookupByLibrary.simpleMessage("Toggle labels"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("Tonal spot"),
    "tools": MessageLookupByLibrary.simpleMessage("Tools"),
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("Top up traffic"),
    "torch": MessageLookupByLibrary.simpleMessage("Flashlight"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Total traffic"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy port"),
    "trafficFreeOfTotal": m92,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Traffic usage"),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage("Trusted networks"),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "The VPN pauses while connected to any of these networks",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "Current network is trusted — VPN paused here",
    ),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "Only effective in administrator mode",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Turn off"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Turn on"),
    "undo": MessageLookupByLibrary.simpleMessage("Undo"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Unified delay"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "Remove extra delays such as handshakes",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Unknown network error",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("Restore down"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Unnamed"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("Unpin window"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Could not download the update",
    ),
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "The downloaded file is damaged",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("Upload"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "Obtain a profile from a URL",
    ),
    "urlScheme": MessageLookupByLibrary.simpleMessage("URL Scheme"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("Add subscription"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "A subscription URL, added after confirmation",
    ),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("Close"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Hide to tray, or exit when configured",
    ),
    "urlSchemeCommands": MessageLookupByLibrary.simpleMessage(
      "Automation commands",
    ),
    "urlSchemeCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "For tasker, scripts, shortcuts, and automation",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Connect"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Start the tunnel and connect",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "Stop the tunnel",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage("Import config"),
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "A base64-encoded config file, imported as a profile",
    ),
    "urlSchemeImportInvalid": MessageLookupByLibrary.simpleMessage(
      "The import payload is not valid base64",
    ),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage(
      "Install a profile",
    ),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "The compat link Clash and FlClash buttons already use",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage("Open"),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Bring the window to the front",
    ),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("Profiles"),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage("Toggle"),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "Connect if stopped, disconnect if running",
    ),
    "urlTip": m93,
    "useHosts": MessageLookupByLibrary.simpleMessage("Use hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("Use system hosts"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("Used traffic"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "uz": MessageLookupByLibrary.simpleMessage("Uzbek"),
    "value": MessageLookupByLibrary.simpleMessage("Value"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Vibrant"),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN-related configuration change detected",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Route all system traffic through VpnService automatically",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Changes take effect after restarting the VPN",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV configuration",
    ),
    "webDashboard": MessageLookupByLibrary.simpleMessage("Web dashboard"),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "zashboard, served by the core itself",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "zashboard is downloaded on first open",
    ),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage("Open dashboard"),
    "webDashboardSessionTip": MessageLookupByLibrary.simpleMessage(
      "The external controller stays on while the dashboard is open",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "The core is not serving the dashboard yet",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Whitelist mode"),
    "yearsAgo": m94,
    "zhCN": MessageLookupByLibrary.simpleMessage("Simplified Chinese"),
  };
}
