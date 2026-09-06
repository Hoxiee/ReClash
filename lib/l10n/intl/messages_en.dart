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

  static String m0(time) => "Connected ${time}";

  static String m1(code) =>
      "Windows refused to run ReClashCore.exe (error ${code}). An app control policy such as Smart App Control or AppLocker blocks unsigned programs; allow ReClash in that policy or turn it off, then try again.";

  static String m2(name) =>
      "The app failed to finish launching twice in a row. To break the loop, the profile ${name} has been deselected and automatic setup was skipped. You can select it again at any time.";

  static String m3(url) => "Do you want to create a profile from ${url}?";

  static String m4(count) =>
      "${Intl.plural(count, one: '1 day ago', other: '${count} days ago')}";

  static String m5(count) =>
      "${Intl.plural(count, one: '1 day left', other: '${count} days left')}";

  static String m6(label) =>
      "Are you sure you want to delete the selected ${label}?";

  static String m7(label) => "Are you sure you want to delete this ${label}?";

  static String m8(token) => "${token} is set by the app and will be dropped";

  static String m9(count) =>
      "${Intl.plural(count, zero: 'no arguments', one: '1 argument', other: '${count} arguments')}";

  static String m10(token) => "${token} needs a value";

  static String m11(token) => "${token} is not an option";

  static String m12(token) => "Unknown option ${token}";

  static String m13(count) =>
      "${Intl.plural(count, one: '1 domain', other: '${count} domains')}";

  static String m14(count) => "Finished: ${count} strategies tested";

  static String m15(count) =>
      "Tries every known strategy against ${count} hosts through the engine; the current strategy is restored afterwards";

  static String m16(index, total) => "Testing ${index} of ${total}";

  static String m17(passed, total) => "${passed} of ${total} hosts up";

  static String m18(label) => "${label} details";

  static String m19(label) => "${label} cannot be empty";

  static String m20(count) =>
      "${Intl.plural(count, one: '1 entry', other: '${count} entries')}";

  static String m21(label) => "${label} already exists";

  static String m22(name) => "${name} is already up to date";

  static String m23(name) => "${name} updated";

  static String m24(time) => "${time} ago";

  static String m25(count) =>
      "${Intl.plural(count, one: '1 hour ago', other: '${count} hours ago')}";

  static String m26(count) =>
      "${Intl.plural(count, one: '1 hour', other: '${count} hours')}";

  static String m27(target) => "${target} is an invalid policy";

  static String m28(proxyName) => "${proxyName} is an invalid proxy";

  static String m29(providerName) =>
      "${providerName} is an invalid proxy provider";

  static String m30(subRule) => "${subRule} is an invalid SUB_RULE";

  static String m31(appName) =>
      "1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check ${appName} in the list\n\nWhen you are done, return to the app to continue. Thank you for your cooperation.";

  static String m32(label, max) => "${label} must be at most ${max} characters";

  static String m33(count) =>
      "${Intl.plural(count, one: '1 minute ago', other: '${count} minutes ago')}";

  static String m34(count) =>
      "${Intl.plural(count, one: '1 month ago', other: '${count} months ago')}";

  static String m35(label) => "No ${label} yet";

  static String m36(label) => "${label} must be a number";

  static String m37(label) => "${label} must be between 1024 and 49151";

  static String m38(count) =>
      "${Intl.plural(count, one: '1 proxy', other: '${count} proxies')}";

  static String m39(count) =>
      "${Intl.plural(count, one: '1 rule', other: '${count} rules')}";

  static String m40(darkAt, lightAt) => "Dark from ${darkAt} to ${lightAt}";

  static String m41(count) =>
      "${Intl.plural(count, one: '1 second', other: '${count} seconds')}";

  static String m42(count) => "${count} selected";

  static String m43(alive, total) =>
      "${alive} of ${total} servers can be used right now";

  static String m44(band) => "band ${band}";

  static String m45(bands) => "Bands: ${bands}";

  static String m46(count) => "Cooling down after ${count} failures";

  static String m47(answered, total) => "${answered} of ${total} answered";

  static String m48(seconds) => "${seconds} s left";

  static String m49(count) => "${count} failures in a row";

  static String m50(measured, total) => "measured ${measured} of ${total}";

  static String m51(preset) => "${preset} · adjusted";

  static String m52(left, cap) => "${left} of ${cap} probes left this hour";

  static String m53(seconds) => "${seconds} s";

  static String m54(eligible, total) => "${eligible} of ${total} usable";

  static String m55(eligible, total, blocked) =>
      "${eligible} of ${total} servers passed, ${blocked} were held back";

  static String m56(from, to) => "${from} → ${to}";

  static String m57(time) => "Switched ${time} ago";

  static String m58(count) => "${count} servers";

  static String m59(host) => "The provider moved to ${host}";

  static String m60(count) =>
      "${Intl.plural(count, one: 'Your subscription expires tomorrow', other: 'Your subscription expires in ${count} days')}";

  static String m61(value) => "The provider suggests ${value}";

  static String m62(total) => "free of ${total}";

  static String m63(label) => "${label} must be a URL";

  static String m64(count) =>
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
    "announce": MessageLookupByLibrary.simpleMessage("Announcements"),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "App access control",
    ),
    "appIcon": MessageLookupByLibrary.simpleMessage("App icon"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "The launcher redraws the icon in a few seconds. A pinned shortcut may disappear on some launchers.",
    ),
    "appIconCool": MessageLookupByLibrary.simpleMessage("Cool"),
    "appIconDarkMono": MessageLookupByLibrary.simpleMessage("Dark mono"),
    "appIconInverted": MessageLookupByLibrary.simpleMessage("Inverted"),
    "appIconMono": MessageLookupByLibrary.simpleMessage("Mono"),
    "appIconSepia": MessageLookupByLibrary.simpleMessage("Sepia"),
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
    "connectedFor": m0,
    "connecting": MessageLookupByLibrary.simpleMessage("Connecting..."),
    "connection": MessageLookupByLibrary.simpleMessage("Connection"),
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
    "coreBlockedByPolicyTip": m1,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows Smart App Control blocked ReClashCore.exe because it is not signed. Open Windows Security → App & browser control → Smart App Control settings, choose Off, then start ReClash again. Smart App Control cannot be turned back on without reinstalling Windows.",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Core status"),
    "country": MessageLookupByLibrary.simpleMessage("Region"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Crash detected"),
    "crashDetectedTip": m2,
    "crashTest": MessageLookupByLibrary.simpleMessage("Crash test"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("Crash analytics"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "When enabled, crash logs without sensitive information are uploaded automatically when the app crashes",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createProfile": MessageLookupByLibrary.simpleMessage("Create profile"),
    "createProfileFromUrlTip": m3,
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
    "dashboardStyle": MessageLookupByLibrary.simpleMessage("Dashboard style"),
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
    "daysAgo": m4,
    "daysGenitive": MessageLookupByLibrary.simpleMessage("days"),
    "daysLeft": m5,
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
    "deleteMultipTip": m6,
    "deleteTip": m7,
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
    "desyncArgs": MessageLookupByLibrary.simpleMessage("Engine arguments"),
    "desyncArgsAppOwnedFlag": m8,
    "desyncArgsCount": m9,
    "desyncArgsHint": MessageLookupByLibrary.simpleMessage(
      "-A torst,conn -L s,o --split 1",
    ),
    "desyncArgsMissingValue": m10,
    "desyncArgsPositional": m11,
    "desyncArgsQuoteError": MessageLookupByLibrary.simpleMessage(
      "A quote is left unclosed",
    ),
    "desyncArgsUnknownFlag": m12,
    "desyncCache": MessageLookupByLibrary.simpleMessage("Strategy cache"),
    "desyncCacheDesc": MessageLookupByLibrary.simpleMessage(
      "Picked strategies are kept per network",
    ),
    "desyncCacheTtl": MessageLookupByLibrary.simpleMessage("Cache lifetime"),
    "desyncDefaultName": MessageLookupByLibrary.simpleMessage("Default ladder"),
    "desyncDesc": MessageLookupByLibrary.simpleMessage(
      "ByeDPI desync strategies",
    ),
    "desyncEngine": MessageLookupByLibrary.simpleMessage("Engine"),
    "desyncForceTcp": MessageLookupByLibrary.simpleMessage("Force TCP"),
    "desyncForceTcpDesc": MessageLookupByLibrary.simpleMessage(
      "Blocks QUIC for the categories above; a desync cannot reach UDP",
    ),
    "desyncModeByedpi": MessageLookupByLibrary.simpleMessage("ByeDPI"),
    "desyncModeTitle": MessageLookupByLibrary.simpleMessage("Connection mode"),
    "desyncModeVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "desyncRouting": MessageLookupByLibrary.simpleMessage("Routing"),
    "desyncSaveCurrent": MessageLookupByLibrary.simpleMessage("Save current"),
    "desyncStrategyNameHint": MessageLookupByLibrary.simpleMessage(
      "Strategy name",
    ),
    "desyncStrategySection": MessageLookupByLibrary.simpleMessage("Strategy"),
    "desyncTestAborted": MessageLookupByLibrary.simpleMessage(
      "Stopped early: strategies stopped reaching the engine",
    ),
    "desyncTestDomains": MessageLookupByLibrary.simpleMessage("Test domains"),
    "desyncTestDomainsCount": m13,
    "desyncTestDone": m14,
    "desyncTestEngineCrashed": MessageLookupByLibrary.simpleMessage(
      "The engine died on this strategy",
    ),
    "desyncTestEngineDown": MessageLookupByLibrary.simpleMessage(
      "The engine is not running — connect with DPI bypass enabled first",
    ),
    "desyncTestFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Hosts this strategy failed",
    ),
    "desyncTestHint": m15,
    "desyncTestNoLists": MessageLookupByLibrary.simpleMessage(
      "Pick at least one domain list below",
    ),
    "desyncTestProgress": m16,
    "desyncTestScore": m17,
    "desyncTestSection": MessageLookupByLibrary.simpleMessage("Strategy test"),
    "desyncTestStart": MessageLookupByLibrary.simpleMessage("Start"),
    "desyncTestTitle": MessageLookupByLibrary.simpleMessage("Run every preset"),
    "desyncTtl12Hours": MessageLookupByLibrary.simpleMessage("12 hours"),
    "desyncTtl28Hours": MessageLookupByLibrary.simpleMessage("28 hours"),
    "desyncTtlHour": MessageLookupByLibrary.simpleMessage("1 hour"),
    "desyncTtlWeek": MessageLookupByLibrary.simpleMessage("7 days"),
    "details": m18,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Relies on a third-party API; for reference only",
    ),
    "determiningIp": MessageLookupByLibrary.simpleMessage("Determining IP..."),
    "developerMode": MessageLookupByLibrary.simpleMessage("Developer mode"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Developer mode is enabled.",
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
    "emptyTip": m19,
    "en": MessageLookupByLibrary.simpleMessage("English"),
    "enterManually": MessageLookupByLibrary.simpleMessage("Enter manually"),
    "entries": MessageLookupByLibrary.simpleMessage(" entries"),
    "entriesCount": m20,
    "exclude": MessageLookupByLibrary.simpleMessage("Hide from recent tasks"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Hide the app from recent tasks while it is in the background",
    ),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage(
      "Exclude proxy filter",
    ),
    "excludeType": MessageLookupByLibrary.simpleMessage("Exclude type"),
    "existsTip": m21,
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
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
    "geoSkipped": m22,
    "geoUpdated": m23,
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
    "heroRoutingAgo": m24,
    "heroRoutingStub": MessageLookupByLibrary.simpleMessage(
      "Smart routing is off",
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
    "hoursAgo": m25,
    "hoursCount": m26,
    "hoursGenitive": MessageLookupByLibrary.simpleMessage("hours"),
    "hoursPlural": MessageLookupByLibrary.simpleMessage("hours"),
    "icon": MessageLookupByLibrary.simpleMessage("Icon"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("Icon records"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Icon style"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("Icon URL"),
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
    "invalidPolicy": m27,
    "invalidProxy": m28,
    "invalidProxyProvider": m29,
    "invalidSubRule": m30,
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
    "locationPermissionGuide": m31,
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
    "maxLengthTip": m32,
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
    "minutesAgo": m33,
    "minutesGenitive": MessageLookupByLibrary.simpleMessage("minutes"),
    "minutesPlural": MessageLookupByLibrary.simpleMessage("minutes"),
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixed port"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "monthsAgo": m34,
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
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "No profiles yet, please add one first",
    ),
    "nullTip": m35,
    "numberTip": m36,
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
    "portTip": m37,
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
    "proxiesCount": m38,
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
      "Wildcard match; only * and ? are supported",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match a domain suffix",
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
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Match by the full process path",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Match by process path regex",
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
    "rulesCount": m39,
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save the changes?"),
    "schedule": MessageLookupByLibrary.simpleMessage("Scheduled"),
    "scheduleDesc": m40,
    "script": MessageLookupByLibrary.simpleMessage("Script"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Script mode: uses external extension scripts to override the configuration in one click",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Scroll to selected",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "seconds": MessageLookupByLibrary.simpleMessage("seconds"),
    "secondsCount": m41,
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
    "selectedCountTitle": m42,
    "sendDeviceIdentity": MessageLookupByLibrary.simpleMessage("Send HWID"),
    "sendDeviceIdentityDesc": MessageLookupByLibrary.simpleMessage(
      "Send device identifier, app version and device name to proxy provider server",
    ),
    "serviceInfo": MessageLookupByLibrary.simpleMessage("Service"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "setupAutoRun": MessageLookupByLibrary.simpleMessage("Connect on launch"),
    "setupAutoRunDesc": MessageLookupByLibrary.simpleMessage(
      "The tunnel comes up as soon as the app opens",
    ),
    "setupDataCollection": MessageLookupByLibrary.simpleMessage(
      "Send crash reports",
    ),
    "setupDone": MessageLookupByLibrary.simpleMessage("Done"),
    "setupFinishTitle": MessageLookupByLibrary.simpleMessage("Almost done"),
    "setupLanguageDesc": MessageLookupByLibrary.simpleMessage(
      "You can change it later in settings",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage(
      "Choose a language",
    ),
    "setupLegalTitle": MessageLookupByLibrary.simpleMessage("Before we start"),
    "setupNext": MessageLookupByLibrary.simpleMessage("Next"),
    "setupPermissionNotifications": MessageLookupByLibrary.simpleMessage(
      "Notifications",
    ),
    "setupPermissionNotificationsDesc": MessageLookupByLibrary.simpleMessage(
      "Shows the connection status while running",
    ),
    "setupPermissionVpn": MessageLookupByLibrary.simpleMessage(
      "VPN permission",
    ),
    "setupPermissionVpnDesc": MessageLookupByLibrary.simpleMessage(
      "The system will ask on the first connection",
    ),
    "setupRegionDesc": MessageLookupByLibrary.simpleMessage(
      "Sets the starting point for server selection",
    ),
    "setupRegionNone": MessageLookupByLibrary.simpleMessage("Do not pick"),
    "setupRestore": MessageLookupByLibrary.simpleMessage(
      "Restore from a backup",
    ),
    "setupRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Move everything from a ReClash, FlClashX, or FlClash backup",
    ),
    "setupSkip": MessageLookupByLibrary.simpleMessage("Skip"),
    "setupSubscriptionDesc": MessageLookupByLibrary.simpleMessage(
      "A link from your provider, a QR code, or a config file",
    ),
    "setupSubscriptionReady": MessageLookupByLibrary.simpleMessage(
      "Subscription added",
    ),
    "setupSubscriptionTitle": MessageLookupByLibrary.simpleMessage(
      "Add a subscription",
    ),
    "setupWelcome": MessageLookupByLibrary.simpleMessage(
      "Everything set up in a minute",
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
    "smartRoutingAliveCount": m43,
    "smartRoutingAllServers": MessageLookupByLibrary.simpleMessage(
      "All servers",
    ),
    "smartRoutingBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Back to automatic",
    ),
    "smartRoutingBandLabel": m44,
    "smartRoutingBands": m45,
    "smartRoutingBehaviour": MessageLookupByLibrary.simpleMessage("Behaviour"),
    "smartRoutingBlockAbsent": MessageLookupByLibrary.simpleMessage(
      "Not in the current server list",
    ),
    "smartRoutingBlockCooling": m46,
    "smartRoutingBlockDisproven": MessageLookupByLibrary.simpleMessage(
      "Failed its checks here",
    ),
    "smartRoutingBlockLastResort": MessageLookupByLibrary.simpleMessage(
      "Local server, barred on this network",
    ),
    "smartRoutingBlockNoUdp": MessageLookupByLibrary.simpleMessage(
      "No UDP support",
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
    "smartRoutingCanariesAnswered": m47,
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
    "smartRoutingCoolFor": m48,
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
    "smartRoutingEvidenceForeignOk": MessageLookupByLibrary.simpleMessage(
      "A foreign address answered",
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
    "smartRoutingFails": m49,
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
    "smartRoutingIntro": MessageLookupByLibrary.simpleMessage(
      "Smart routing keeps a server that works on the current network and switches on its own when the network changes. Start from a region preset, then fine-tune strategy, checks and markers below.",
    ),
    "smartRoutingKept": MessageLookupByLibrary.simpleMessage("kept"),
    "smartRoutingKeyBand": MessageLookupByLibrary.simpleMessage("Latency band"),
    "smartRoutingKeyEvidence": MessageLookupByLibrary.simpleMessage("Evidence"),
    "smartRoutingKeyHistory": MessageLookupByLibrary.simpleMessage(
      "History on this network",
    ),
    "smartRoutingKeyMisfit": MessageLookupByLibrary.simpleMessage(
      "Fit for this network",
    ),
    "smartRoutingKeyVerdict": MessageLookupByLibrary.simpleMessage("Verdict"),
    "smartRoutingManualHold": MessageLookupByLibrary.simpleMessage(
      "Respect a manual pick",
    ),
    "smartRoutingManualHoldDesc": MessageLookupByLibrary.simpleMessage(
      "Keep the server you chose yourself until it stops working",
    ),
    "smartRoutingManualPinned": MessageLookupByLibrary.simpleMessage(
      "Held until it stops working",
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
    "smartRoutingMetered": MessageLookupByLibrary.simpleMessage("Metered link"),
    "smartRoutingNetworkFormat": MessageLookupByLibrary.simpleMessage(
      "Network",
    ),
    "smartRoutingNeverSwitched": MessageLookupByLibrary.simpleMessage(
      "No switch yet on this network",
    ),
    "smartRoutingNoAnswer": MessageLookupByLibrary.simpleMessage("no answer"),
    "smartRoutingNoServers": MessageLookupByLibrary.simpleMessage(
      "No reachable servers",
    ),
    "smartRoutingNodeChecks": MessageLookupByLibrary.simpleMessage(
      "Server checks",
    ),
    "smartRoutingNodeNoUdp": MessageLookupByLibrary.simpleMessage("No UDP"),
    "smartRoutingNodeUdp": MessageLookupByLibrary.simpleMessage("UDP"),
    "smartRoutingNodesMeasured": m50,
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
    "smartRoutingPresetEdited": m51,
    "smartRoutingPresetIran": MessageLookupByLibrary.simpleMessage("Iran"),
    "smartRoutingPresetOff": MessageLookupByLibrary.simpleMessage("Off"),
    "smartRoutingPresetRussia": MessageLookupByLibrary.simpleMessage("Russia"),
    "smartRoutingProbeBudget": m52,
    "smartRoutingProbing": MessageLookupByLibrary.simpleMessage("Probing"),
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
    "smartRoutingSearching": MessageLookupByLibrary.simpleMessage(
      "Picking a server…",
    ),
    "smartRoutingSeconds": m53,
    "smartRoutingSectionHealth": MessageLookupByLibrary.simpleMessage(
      "Servers",
    ),
    "smartRoutingSectionHistory": MessageLookupByLibrary.simpleMessage(
      "Earlier switches",
    ),
    "smartRoutingSectionNetwork": MessageLookupByLibrary.simpleMessage(
      "Network",
    ),
    "smartRoutingSectionRound": MessageLookupByLibrary.simpleMessage(
      "Decision",
    ),
    "smartRoutingServers": MessageLookupByLibrary.simpleMessage("Servers"),
    "smartRoutingServersCount": m54,
    "smartRoutingStepAdmit": MessageLookupByLibrary.simpleMessage(
      "Decided who is allowed",
    ),
    "smartRoutingStepAdmitBody": m55,
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
      "Verdict first, then specialist fit, then evidence, then latency band, history last",
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
    "smartRoutingSwitchLine": m56,
    "smartRoutingSwitched": MessageLookupByLibrary.simpleMessage("switched"),
    "smartRoutingSwitchedAgo": m57,
    "smartRoutingTechnical": MessageLookupByLibrary.simpleMessage(
      "Technical detail",
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
    "smartRoutingWave": MessageLookupByLibrary.simpleMessage(
      "Servers per check",
    ),
    "smartRoutingWaveDesc": MessageLookupByLibrary.simpleMessage(
      "How many servers one background check measures",
    ),
    "smartRoutingWaveNodes": m58,
    "smartRoutingWhatWasTested": MessageLookupByLibrary.simpleMessage(
      "Link check",
    ),
    "smartRoutingWhy": MessageLookupByLibrary.simpleMessage("Why"),
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
    "subscriptionDomainMoved": m59,
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Your subscription has expired",
    ),
    "subscriptionExpiresInDays": m60,
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
    "subscriptionProviderInterval": m61,
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
    "trafficFreeOfTotal": m62,
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
    "urlSchemeDesc": MessageLookupByLibrary.simpleMessage(
      "Deep links ReClash registers and opens",
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
    "urlTip": m63,
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
    "yearsAgo": m64,
    "zhCN": MessageLookupByLibrary.simpleMessage("Simplified Chinese"),
  };
}
