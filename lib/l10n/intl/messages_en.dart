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

  static String m0(count, skipped) =>
      "${count} to add, ${skipped} skipped as existing";

  static String m1(detail) => "Couldn\'t clear the data: ${detail}";

  static String m2(code) =>
      "Windows refused to run ReClashCore.exe (error ${code}). An app control policy such as Smart App Control or AppLocker blocks unsigned programs; allow ReClash in that policy or turn it off, then try again.";

  static String m3(name) =>
      "The app failed to finish launching twice in a row. To break the loop, the profile ${name} has been deselected and automatic setup was skipped. You can select it again at any time.";

  static String m4(url) => "Do you want to create a profile from ${url}?";

  static String m5(groups) =>
      "Dropped include-all from the proxy groups ${groups}; add the proxies or proxy providers they use";

  static String m6(count, label) =>
      "${Intl.plural(count, one: '1 SUB-RULE rule was dropped, since custom profiles do not support sub-rules', other: '${label} SUB-RULE rules were dropped, since custom profiles do not support sub-rules')}";

  static String m7(message) => "The core cannot parse this proxy: ${message}";

  static String m8(proxy, target) =>
      "${proxy} dials through ${target}, which leads back to ${proxy}, so the dial loops";

  static String m9(name) =>
      "The name ${name} is already used by another proxy or proxy group";

  static String m10(path) =>
      "Proxy groups reference each other in a loop: ${path}";

  static String m11(name) =>
      "The empty fallback must be a proxy, but ${name} does not exist or is a proxy group";

  static String m12(name, message) =>
      "${name} is not a valid regex: ${message}";

  static String m13(name) => "The dialer proxy ${name} does not exist";

  static String m14(names) => "These proxy providers do not exist: ${names}";

  static String m15(names) =>
      "These proxies or policies do not exist: ${names}";

  static String m16(name) =>
      "${name} is a built-in policy name and cannot be used here";

  static String m17(count) =>
      "${count} items have problems, and applying this profile may fail";

  static String m18(count) =>
      "${Intl.plural(count, one: '1 day ago', other: '${count} days ago')}";

  static String m19(count) => "${Intl.plural(count, other: '${count}d ago')}";

  static String m20(label) =>
      "Are you sure you want to delete the selected ${label}?";

  static String m21(label) => "Are you sure you want to delete this ${label}?";

  static String m22(label) => "${label} details";

  static String m23(name) =>
      "Dialing through ${name} leads back to the proxy that uses it, so the connection was stopped";

  static String m24(label) => "${label} cannot be empty";

  static String m25(label) => "${label} already exists";

  static String m26(count) => "${count} items failed";

  static String m27(label, message) => "${label}: ${message}";

  static String m28(name) => "${name} is already up to date";

  static String m29(name) => "${name} updated";

  static String m30(count) =>
      "${Intl.plural(count, one: '1 group', other: '${count} groups')}";

  static String m31(count) => "${count} timed out";

  static String m32(action) =>
      "Already used by “${action}”. Saving moves it here.";

  static String m33(actions) => "Not exported: ${actions}";

  static String m34(modifiers) => "Include at least one of ${modifiers}";

  static String m35(count) =>
      "${Intl.plural(count, one: '1 hour ago', other: '${count} hours ago')}";

  static String m36(count) => "${Intl.plural(count, other: '${count}h ago')}";

  static String m37(target) => "${target} is an invalid policy";

  static String m38(proxyName) => "${proxyName} is an invalid proxy";

  static String m39(providerName) =>
      "${providerName} is an invalid proxy provider";

  static String m40(ruleSet) => "${ruleSet} is an invalid rule set";

  static String m41(subRule) => "${subRule} is an invalid SUB_RULE";

  static String m42(count) =>
      "${Intl.plural(count, one: '1 item', other: '${count} items')}";

  static String m43(line, message) => "Line ${line}: ${message}";

  static String m44(appName) =>
      "1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check ${appName} in the list\n\nWhen you are done, return to the app to continue. Thank you for your cooperation.";

  static String m45(label, max) => "${label} must be at most ${max} characters";

  static String m46(size) => "Released ${size}";

  static String m47(count) =>
      "${Intl.plural(count, one: '1 minute ago', other: '${count} minutes ago')}";

  static String m48(count) => "${Intl.plural(count, other: '${count}m ago')}";

  static String m49(count) =>
      "${Intl.plural(count, one: '1 month ago', other: '${count} months ago')}";

  static String m50(count) => "${Intl.plural(count, other: '${count}mo ago')}";

  static String m51(code) =>
      "The server denied access (HTTP ${code}). The link may have expired, or the credentials are wrong";

  static String m52(code) => "The server rejected the request (HTTP ${code})";

  static String m53(code) =>
      "Nothing was found at this address (HTTP ${code}). Check that the URL is correct";

  static String m54(detail) => "Network request failed: ${detail}";

  static String m55(code) =>
      "The server ran into a problem (HTTP ${code}). Try again later";

  static String m56(label) => "No ${label} yet";

  static String m57(label, min, max) =>
      "${label} must be between ${min} and ${max}";

  static String m58(label) => "${label} must be a number";

  static String m59(label) => "${label} must be between 1024 and 49151";

  static String m60(port) => "Port ${port}";

  static String m61(added, skipped, failed) =>
      "Added: ${added}; skipped: ${skipped}; failed: ${failed}.";

  static String m62(days) =>
      "${Intl.plural(days, one: '1 day left', other: '${days} days left')}";

  static String m63(date, days) =>
      "Expires ${date}, ${Intl.plural(days, one: '1 day', other: '${days} days')} left";

  static String m64(time) => "Updated ${time}";

  static String m65(label, profiles) =>
      "${label} is still used by ${profiles}, which will not work properly once it is deleted. Are you sure you want to delete it?";

  static String m66(count, label) =>
      "${Intl.plural(count, one: '1 proxy', other: '${label} proxies')}";

  static String m67(name, count) => "${name} and others (${count} proxies)";

  static String m68(removed) =>
      "These proxies will be deleted: ${removed}. A line whose name changed counts as a new proxy, and custom profiles naming the deleted ones will flag them as missing. Apply anyway?";

  static String m69(removed, added) =>
      "These proxies will be deleted: ${removed}. These will be added: ${added}. A line whose name changed counts as a new proxy, and custom profiles naming the deleted ones will flag them as missing. Apply anyway?";

  static String m70(label) =>
      "${label} is still named by rules, proxy groups, dialer proxies, DNS or NTP in this profile, which stop working once it is deleted. Are you sure you want to delete it?";

  static String m71(count, label) =>
      "${Intl.plural(count, one: '1 proxy group', other: '${label} proxy groups')}";

  static String m72(region, bypassed, proxied) =>
      "${region}: ${bypassed} apps in the VPN bypass list, ${proxied} in the VPN list. Both lists will be replaced; the mode and other settings stay unchanged. Package and SDK matches are suggestions: review them after applying.";

  static String m73(region, value) =>
      "Region ${region} uses: ${value}. A custom list replaces the regional defaults.";

  static String m74(region, source) => "Suggested: ${region} · ${source}";

  static String m75(region, value) =>
      "Region ${region} supplies DNS defaults: ${value}. Manual overrides here take priority.";

  static String m76(region) => "Country profile: ${region}";

  static String m77(value) => "TUN MTU: ${value}";

  static String m78(value) => "Default service checks: ${value}";

  static String m79(region, value) =>
      "Region ${region} supplies MTU ${value}. Add an MTU override to use your own value.";

  static String m80(count, label) =>
      "${Intl.plural(count, one: '1 rule', other: '${label} rules')}";

  static String m81(appName) => "${appName} (Safe mode)";

  static String m82(count) =>
      "${Intl.plural(count, one: '1 second', other: '${count} seconds')}";

  static String m83(count) => "${count} in effect";

  static String m84(count) =>
      "${Intl.plural(count, one: '1 issue', other: '${count} issues')}";

  static String m85(time) => "Checked at ${time}";

  static String m86(count) =>
      "${Intl.plural(count, one: '1 setting', other: '${count} settings')}";

  static String m87(count) => "${count} profiles available";

  static String m88(step, total) => "${step} of ${total}";

  static String m89(server) => "Try ${server}";

  static String m90(link) => "No proxy could be read from ${link}";

  static String m91(label) => "${label} must be a single item";

  static String m92(client, format, count) =>
      "Received as ${client}: ${format}, ${count} proxy nodes.";

  static String m93(sections) =>
      "The following source sections will not be transferred: ${sections}.";

  static String m94(count, format) =>
      "${count} proxy nodes can be imported from ${format}.";

  static String m95(count) => "${count} nodes cannot be converted.";

  static String m96(count) => "${count} results";

  static String m97(value) => "Peak ${value}";

  static String m98(value) => "Total ${value}";

  static String m99(version) => "Installed: ${version}";

  static String m100(count) =>
      "${Intl.plural(count, one: '1 min', other: '${count} min')}";

  static String m101(time) => "${time} remaining";

  static String m102(count) =>
      "${Intl.plural(count, one: '1 sec', other: '${count} sec')}";

  static String m103(speed) => "${speed}/s";

  static String m104(nodes, groups, providers) =>
      "${nodes} proxies, ${groups} groups, ${providers} remote providers";

  static String m105(action) =>
      "This link requests “${action}”. Allow ReClash to perform this action?";

  static String m106(name, source) =>
      "Import “${name}” from ${source}? Profile validation and any conversion review follow your confirmation.";

  static String m107(label) => "${label} must be a URL";

  static String m108(index) => "Background ${index}";

  static String m109(count) =>
      "You can keep up to ${count} backgrounds. Remove one to add another.";

  static String m110(version) => "Installed version: ${version}";

  static String m111(count) =>
      "${Intl.plural(count, one: '1 year ago', other: '${count} years ago')}";

  static String m112(count) => "${Intl.plural(count, other: '${count}y ago')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Access control"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Only selected apps go through the VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Access control picks which apps use the proxy.",
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
    "actionDelayTest": MessageLookupByLibrary.simpleMessage("Test all delays"),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("Direct mode"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("Global mode"),
    "actionMode": MessageLookupByLibrary.simpleMessage("Switch mode"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("Rule mode"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Start/Stop"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage(
      "Update profiles",
    ),
    "actionView": MessageLookupByLibrary.simpleMessage("Show/Hide"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("Add proxy"),
    "addFilters": MessageLookupByLibrary.simpleMessage("Add filters"),
    "addNodes": MessageLookupByLibrary.simpleMessage("Add nodes"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage(
      "Add override entry",
    ),
    "addProfile": MessageLookupByLibrary.simpleMessage("Add profile"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("Add proxy group"),
    "addRule": MessageLookupByLibrary.simpleMessage("Add rule"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage("Add setting"),
    "addSsid": MessageLookupByLibrary.simpleMessage("Add SSID"),
    "addedRules": MessageLookupByLibrary.simpleMessage("Added rules"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Additional parameters",
    ),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage("Name prefix"),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage("Name suffix"),
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
      "Advanced configuration holds network, DNS, added rules, and scripts.",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage(
      "Encrypted profile",
    ),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage("Age secret key"),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "This profile is encrypted with age and needs an age secret key to decrypt",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Agree"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage(
      "All referenced proxies",
    ),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "All referenced proxy providers",
    ),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Allow apps to bypass VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("Allow LAN"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("Allowed IPs"),
    "answers": MessageLookupByLibrary.simpleMessage("Answers"),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "App access control",
    ),
    "appIconDesign": MessageLookupByLibrary.simpleMessage("App icon design"),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage("No local proxies"),
    "appRegion": MessageLookupByLibrary.simpleMessage("App region"),
    "appearanceBackground": MessageLookupByLibrary.simpleMessage("Background"),
    "appearanceInterface": MessageLookupByLibrary.simpleMessage("Interface"),
    "appearanceTheme": MessageLookupByLibrary.simpleMessage("Theme"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Append system DNS",
    ),
    "applicationSettings": MessageLookupByLibrary.simpleMessage(
      "Application settings",
    ),
    "authentication": MessageLookupByLibrary.simpleMessage("Authentication"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "Authentication asks for a username and password on the local proxy port.",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "The system proxy is not applied while authentication is on.",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Authorize"),
    "authorized": MessageLookupByLibrary.simpleMessage("Authorized"),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Auto check for updates",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Auto close connections",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Auto close connections drops open connections when you switch proxies.",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage("Auto-include"),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Auto launch"),
    "autoRun": MessageLookupByLibrary.simpleMessage("Auto run"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Auto run starts the proxy when the app opens.",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Auto-set system DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Auto update"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto-update interval",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "backup": MessageLookupByLibrary.simpleMessage("Backup"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Backup and restore",
    ),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "This backup comes from a newer version of the app. Update the app before restoring it",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("Backup successful"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Basic info"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("Basic strategies"),
    "batchAdd": MessageLookupByLibrary.simpleMessage("Batch add"),
    "batchImport": MessageLookupByLibrary.simpleMessage("Batch import"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage(
      "One link per line",
    ),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage(
      "One item per line, or separated by commas",
    ),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage(
      "One entry per line: key, a space, then value",
    ),
    "batchPreviewTip": m0,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage(
      "One URL per line",
    ),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Ignore battery optimization keeps the app running in the background.",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Bind"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Blacklist mode"),
    "blockConnection": MessageLookupByLibrary.simpleMessage("Block connection"),
    "brightness": MessageLookupByLibrary.simpleMessage("Brightness"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Bypass domains"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Bypass domains apply only while the system proxy is on.",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage(
      "Bypass private addresses",
    ),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "With Bypass private addresses on, LAN, loopback and multicast addresses skip TUN.",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("Cache"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("Cache algorithm"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "The cache is corrupted. Clear it?",
    ),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("Cache size"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Allow camera access in system settings to scan QR codes, or choose a QR code image from the album.",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Camera permission required",
    ),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage(
      "Camera unavailable",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("Deselect all"),
    "cannotSave": MessageLookupByLibrary.simpleMessage("Can\'t save"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Failed to switch proxy; the previous selection has been restored",
    ),
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
      "With TLS verification off, subscriptions and backups are open to man-in-the-middle attacks.",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Check for updates"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "The app is already up to date",
    ),
    "cipher": MessageLookupByLibrary.simpleMessage("Cipher"),
    "clearData": MessageLookupByLibrary.simpleMessage("Clear data"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "This deletes all profiles, settings, and local data, then closes the app. Open it again to start fresh.",
    ),
    "clearDataFailed": m1,
    "clearSearch": MessageLookupByLibrary.simpleMessage("Clear search"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage(
      "Client fingerprint",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Export to clipboard",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Import from clipboard",
    ),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t copy to the clipboard. The selection may be too large",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "closeConnections": MessageLookupByLibrary.simpleMessage(
      "Close connections",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Color"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("Color style"),
    "columns": MessageLookupByLibrary.simpleMessage("Columns"),
    "compact": MessageLookupByLibrary.simpleMessage("Compact"),
    "compatible": MessageLookupByLibrary.simpleMessage("Compatibility mode"),
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
    "congestionControl": MessageLookupByLibrary.simpleMessage(
      "Congestion control",
    ),
    "congestionController": MessageLookupByLibrary.simpleMessage(
      "TCP congestion control",
    ),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "TCP congestion control works only with the mips stack.",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "connecting": MessageLookupByLibrary.simpleMessage("Connecting…"),
    "connection": MessageLookupByLibrary.simpleMessage("Connection"),
    "connectionStats": MessageLookupByLibrary.simpleMessage("Connection stats"),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "Live connections, recent requests and DNS queries",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("Connections"),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectivity: "),
    "content": MessageLookupByLibrary.simpleMessage("Content"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Content cannot be empty",
    ),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Control global added rules",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Copy environment variables",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copy link"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Copied successfully"),
    "core": MessageLookupByLibrary.simpleMessage("Core"),
    "coreArchitecture": MessageLookupByLibrary.simpleMessage("Architecture"),
    "coreBlockedByPolicyTip": m2,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows Smart App Control blocked ReClashCore.exe because it is not signed. Open Windows Security → App & browser control → Smart App Control settings, choose Off, then start ReClash again. Smart App Control cannot be turned back on without reinstalling Windows.",
    ),
    "coreBuildTags": MessageLookupByLibrary.simpleMessage("Build flags"),
    "coreBuildTime": MessageLookupByLibrary.simpleMessage("Build time"),
    "coreEnvironment": MessageLookupByLibrary.simpleMessage("Environment"),
    "coreExecutable": MessageLookupByLibrary.simpleMessage("Core binary"),
    "coreInfoUnavailable": MessageLookupByLibrary.simpleMessage(
      "Could not read core information",
    ),
    "coreLaunchMode": MessageLookupByLibrary.simpleMessage("Execution mode"),
    "coreLocation": MessageLookupByLibrary.simpleMessage("Location"),
    "coreModeElevated": MessageLookupByLibrary.simpleMessage(
      "Managed elevated process",
    ),
    "coreModeHelper": MessageLookupByLibrary.simpleMessage(
      "Process via Helper",
    ),
    "coreModeLibrary": MessageLookupByLibrary.simpleMessage(
      "In-process library",
    ),
    "coreModePrivilegedHelper": MessageLookupByLibrary.simpleMessage(
      "Managed process via signed Helper",
    ),
    "coreModeProcess": MessageLookupByLibrary.simpleMessage("Separate process"),
    "coreOpenRuntimeConfig": MessageLookupByLibrary.simpleMessage(
      "Open runtime configuration",
    ),
    "corePlatform": MessageLookupByLibrary.simpleMessage("Platform"),
    "coreRunning": MessageLookupByLibrary.simpleMessage("Running"),
    "coreRuntimeConfig": MessageLookupByLibrary.simpleMessage(
      "Runtime configuration",
    ),
    "coreRuntimeConfigDescription": MessageLookupByLibrary.simpleMessage(
      "Generated configuration after settings and scripts. Read-only.",
    ),
    "coreRuntimeConfigReadFailed": MessageLookupByLibrary.simpleMessage(
      "Could not read the runtime configuration",
    ),
    "coreStarting": MessageLookupByLibrary.simpleMessage("Starting…"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Core status"),
    "coreStopped": MessageLookupByLibrary.simpleMessage("Stopped"),
    "coreWorkingDirectory": MessageLookupByLibrary.simpleMessage(
      "Data directory",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Region"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Crash detected"),
    "crashDetectedTip": m3,
    "crashTest": MessageLookupByLibrary.simpleMessage("Crash test"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createProfileFromUrlTip": m4,
    "creationTime": MessageLookupByLibrary.simpleMessage("Creation time"),
    "creditByeDpi": MessageLookupByLibrary.simpleMessage("DPI bypass"),
    "creditFlClash": MessageLookupByLibrary.simpleMessage("Client foundation"),
    "creditFlClashPatched": MessageLookupByLibrary.simpleMessage(
      "Additional features",
    ),
    "creditFlClashX": MessageLookupByLibrary.simpleMessage(
      "Provider features and ideas",
    ),
    "creditMihomo": MessageLookupByLibrary.simpleMessage("Proxy core"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage(
      "Holds the start button and can\'t be removed",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "customColor": MessageLookupByLibrary.simpleMessage("Custom color"),
    "customImportDroppedIncludeAll": m5,
    "customImportDroppedSubRules": m6,
    "customIssueCoreRejected": m7,
    "customIssueDialerLoop": m8,
    "customIssueDuplicateName": m9,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage(
      "The name is empty",
    ),
    "customIssueGroupLoop": m10,
    "customIssueInvalidEmptyFallback": m11,
    "customIssueInvalidFilter": m12,
    "customIssueMissingDialer": m13,
    "customIssueMissingProviders": m14,
    "customIssueMissingProxies": m15,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "No proxies or proxy providers are selected, so the core rejects this group",
    ),
    "customIssueReservedName": m16,
    "customIssuesSummary": m17,
    "customProfile": MessageLookupByLibrary.simpleMessage("Custom"),
    "customProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Assemble proxy groups and rules from app proxies and other profiles",
    ),
    "customProfileResources": MessageLookupByLibrary.simpleMessage(
      "Custom profile resources",
    ),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Custom profile resources hold proxies, rule providers, filters, and icon sets.",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("Cut"),
    "dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage(
      "Available to add",
    ),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Failed to save the change; it has been rolled back",
    ),
    "daysAgo": m18,
    "daysAgoShort": m19,
    "defaultSelected": MessageLookupByLibrary.simpleMessage(
      "Default selection",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("Default"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "The configuration must be a YAML mapping with a name and a type",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("Delay"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("Failed"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Delay test"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteMultipTip": m20,
    "deleteTip": m21,
    "desc": MessageLookupByLibrary.simpleMessage(
      "A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.",
    ),
    "desktopAuthorizationAgentUnavailable":
        MessageLookupByLibrary.simpleMessage(
          "No graphical authorization agent is available. Start one for this desktop session and try again.",
        ),
    "desktopAuthorizationCancelled": MessageLookupByLibrary.simpleMessage(
      "Authorization was cancelled. TUN has not started.",
    ),
    "desktopAuthorizationDenied": MessageLookupByLibrary.simpleMessage(
      "Authorization was not granted. TUN has not started.",
    ),
    "desktopAuthorizationRequired": MessageLookupByLibrary.simpleMessage(
      "TUN needs authorization. Start the connection or enable TUN to authorize it.",
    ),
    "desktopAuthorizationTimeout": MessageLookupByLibrary.simpleMessage(
      "Authorization timed out. Try again from the connection button.",
    ),
    "desktopBootstrapFailed": MessageLookupByLibrary.simpleMessage(
      "The authorized Core could not complete a verified startup. Check the package and system logs.",
    ),
    "desktopBundleInvalid": MessageLookupByLibrary.simpleMessage(
      "The Core or Helper failed integrity verification. Reinstall a complete ReClash package.",
    ),
    "desktopHelperApprovalRequired": MessageLookupByLibrary.simpleMessage(
      "Allow the ReClash Helper in System Settings → General → Login Items & Extensions, then try again.",
    ),
    "desktopHelperProtocolMismatch": MessageLookupByLibrary.simpleMessage(
      "The installed Helper uses a different protocol. Check for another installation or a service override, then reinstall the complete package.",
    ),
    "desktopHelperRegistrationConflict": MessageLookupByLibrary.simpleMessage(
      "The existing Linux Helper registration cannot be safely replaced. Inspect the owned service and registration; retrying authorization will not resolve this conflict.",
    ),
    "desktopHelperSystemdFailed": MessageLookupByLibrary.simpleMessage(
      "systemd could not start the TUN Helper. Check the service journal; the installer attempted to restore the previous installation.",
    ),
    "desktopHelperSystemdRequired": MessageLookupByLibrary.simpleMessage(
      "TUN requires a Linux session managed by systemd. This system cannot run the network Helper.",
    ),
    "desktopHelperUnavailable": MessageLookupByLibrary.simpleMessage(
      "The TUN Helper is unavailable. Check the installed package and service, then try again.",
    ),
    "desktopLaunchPending": MessageLookupByLibrary.simpleMessage(
      "The previous authorization or Core shutdown is still pending. Wait for it to finish before trying again.",
    ),
    "desktopSigningRequired": MessageLookupByLibrary.simpleMessage(
      "TUN requires a correctly signed ReClash app and Helper. An unsigned or ad-hoc build cannot be authorized.",
    ),
    "desktopTunNotReady": MessageLookupByLibrary.simpleMessage(
      "The Core started, but the TUN adapter is not ready. Check the Core log before using TUN.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Destination"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "Destination GeoIP",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "Destination IP ASN",
    ),
    "details": m22,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Relies on a third-party API; for reference only",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Developer mode"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Developer mode is enabled.",
    ),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("Dialer proxy"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Dialer proxy is the outbound used to reach the NTP server.",
    ),
    "dialerProxyLoopStopped": m23,
    "direct": MessageLookupByLibrary.simpleMessage("Direct"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage(
      "Disable ICMP forwarding",
    ),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "With ICMP forwarding disabled, TUN answers ping itself, so ping no longer shows the real latency.",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage(
      "Disable TCP keep-alive",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("Disable UDP"),
    "disabled": MessageLookupByLibrary.simpleMessage("Disabled"),
    "discardChanges": MessageLookupByLibrary.simpleMessage(
      "Discard the changes?",
    ),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Disclaimer"),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "By installing, copying, or using the Software, you are deemed to have read and agreed to this entire statement. If you disagree with any of its terms, stop using and uninstall the Software immediately.",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage("Acceptance"),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "I have read and understand this statement",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "To confirm you understand, read the following statement and check the box below:",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage(
      "Confirm the statement",
    ),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "The developers may revise this statement with any release, and the revision takes effect when that release is published. Continuing to use the Software after updating means you accept the revised statement.",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage(
      "Changes to this statement",
    ),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "Before using ReClash (\"the Software\"), please read this statement carefully and make sure you understand all of it. Tapping \"Agree\" means you have read, understood, and accept every term below. If you do not agree, tap \"Exit\" and stop using the Software.",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "To the maximum extent permitted by applicable law, neither the developers nor any contributor shall be liable for any direct, indirect, incidental, special, punitive, or consequential damages arising from the use of or inability to use the Software, including but not limited to data loss, device damage, network failures, business interruption, lost profits, or any resulting legal dispute, even if advised of the possibility of such damages.",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage(
      "Limitation of liability",
    ),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "The Software is open source under the GPL-3.0 license. You may use, modify, and distribute it freely as long as you comply with that license, which requires derivative works to be released under GPL-3.0 as well and the original copyright notices to be kept.\n\nThird-party components in the Software, including the Clash.Meta core, follow their own licenses. The original authors are not responsible for any issue arising from modified or redistributed versions.",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage(
      "Open-source license",
    ),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "The Software itself does not provide any proxy server, node, subscription, or network access service, and has no partnership, agency, or guarantee relationship with any provider of such services.",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "The Software does not collect or upload your subscription URLs, node details, configuration content, visited websites, connection records, traffic content, or logs. This data stays on your device and the developers have no access to it.\n\nThe Software only reaches the network when you use a feature that needs it, such as fetching the subscription URL you provided when updating a profile, or contacting GitHub when checking for updates.\n\nThe Software includes no analytics or crash reporting service on any platform.",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage(
      "Data collection and privacy",
    ),
    "disclaimerReadToEnd": MessageLookupByLibrary.simpleMessage(
      "Read to the end",
    ),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "You are responsible for making sure that using the Software is lawful where you live, and you alone bear the legal responsibility for everything you do with it and its consequences.\n\nThe subscriptions, nodes, and configurations you import are your own choice. Whether their source is lawful, their content is safe, and their service is reliable is a matter between you and their providers.",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Your responsibility",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage(
      "Enter the statement above",
    ),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "Does not match the statement",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "To confirm you understand, enter the following statement in full in the field below:",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage(
      "Restate the statement",
    ),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "The Software is an open-source network proxy client built on the Clash.Meta (mihomo) core. It only provides local tooling such as configuration management, rule-based routing, and traffic forwarding.",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage(
      "Nature of the software",
    ),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "Subscription links, configuration files, rule sets, scripts, external resources, and external links are all provided by third parties. The developers cannot and do not review or guarantee their legality, accuracy, security, or availability.\n\nAny data leak, financial loss, account ban, or other loss caused by third-party content is to be settled between you and the third party; the developers bear no responsibility for it.",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage(
      "Third-party content",
    ),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "The Software is intended only for non-commercial uses such as learning, exchange, and technical research. Using it for any commercial purpose is strictly prohibited, including but not limited to paid distribution, bundled sales, use as part of a commercial service, or doing business in the name of the Software. Any commercial activity is unrelated to the Software and its developers.\n\nUsing the Software for anything that violates the laws and regulations of your country or region is strictly prohibited, including but not limited to bypassing lawfully imposed network access restrictions, spreading illegal content, launching network attacks, or infringing the lawful rights of others.",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage(
      "Restrictions on use",
    ),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "The Software is provided \"as is\" and \"as available\", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, non-infringement, uninterrupted availability, freedom from errors, or freedom from security vulnerabilities.\n\nThe developers do not guarantee that the Software will meet your needs or that it will run without interruption or error.",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage(
      "No warranty",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Disconnected"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "New version found",
    ),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "Without this entry, TUN hijacks every DNS query to port 53 (any:53).",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS hijacking"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS mode"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Entries added here replace the DNS of every URL and file profile; anything not added keeps the profile\'s own setting. Custom profiles set their DNS in their content.",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS queries"),
    "docked": MessageLookupByLibrary.simpleMessage("Docked"),
    "domain": MessageLookupByLibrary.simpleMessage("Domain"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage(
      "Download bandwidth",
    ),
    "downloadingUpdate": MessageLookupByLibrary.simpleMessage(
      "Downloading update",
    ),
    "duration": MessageLookupByLibrary.simpleMessage("Duration"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editDashboard": MessageLookupByLibrary.simpleMessage("Edit dashboard"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Edit global rules",
    ),
    "editProxy": MessageLookupByLibrary.simpleMessage("Edit proxy"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("Edit proxy group"),
    "editRule": MessageLookupByLibrary.simpleMessage("Edit rule"),
    "editSsid": MessageLookupByLibrary.simpleMessage("Edit SSID"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Editor unavailable",
    ),
    "elapsed": MessageLookupByLibrary.simpleMessage("Took"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage("Empty fallback"),
    "emptyTip": m24,
    "en": MessageLookupByLibrary.simpleMessage("English"),
    "enabled": MessageLookupByLibrary.simpleMessage("Enabled"),
    "entries": MessageLookupByLibrary.simpleMessage(" entries"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "errorDetails": MessageLookupByLibrary.simpleMessage("Error details"),
    "es": MessageLookupByLibrary.simpleMessage("Spanish"),
    "exclude": MessageLookupByLibrary.simpleMessage("Hide from recent tasks"),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage(
      "Excluded destination ports",
    ),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Traffic to excluded destination ports skips TUN.",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage("Exclude filter"),
    "excludeInterface": MessageLookupByLibrary.simpleMessage(
      "Excluded interfaces",
    ),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Traffic arriving on excluded interfaces, such as docker0, skips TUN.",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage(
      "Excluded source ports",
    ),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Traffic from excluded source ports skips TUN.",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("Exclude SSIDs"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "When connected to Wi-Fi with an excluded SSID, the app\'s running state switches automatically.",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage("Excluded user IDs"),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Traffic from processes of excluded user IDs skips TUN.",
    ),
    "existsTip": m25,
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("Exit full screen"),
    "exitNodes": MessageLookupByLibrary.simpleMessage("Exit nodes"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Expected status"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Expiration time"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Export file"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Export logs"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export successful"),
    "extend": MessageLookupByLibrary.simpleMessage("Extend"),
    "extendMode": MessageLookupByLibrary.simpleMessage("Extend mode"),
    "extendScript": MessageLookupByLibrary.simpleMessage("Extend script"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "External controller",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "The external controller lets you control the core on port 9090.",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage(
      "External controller secret",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("External link"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("Extra large"),
    "fade": MessageLookupByLibrary.simpleMessage("Fade"),
    "failedCount": m26,
    "failedItem": m27,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IP filter"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage(
      "Fake-IP filter mode",
    ),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "In Fake-IP filter mode, blacklist excludes matches, whitelist fakes only matches, and rule matches as rules.",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP range"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage(
      "Fake-IP range (IPv6)",
    ),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("Fake-IP TTL"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Fallback filter"),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "Upload a profile file directly",
    ),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "The file has been modified. Save the changes?",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "filters": MessageLookupByLibrary.simpleMessage("Filters"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Find process"),
    "floating": MessageLookupByLibrary.simpleMessage("Floating"),
    "followProfile": MessageLookupByLibrary.simpleMessage("Follow profile"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Follow system"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Font family"),
    "fontSize": MessageLookupByLibrary.simpleMessage("Size"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage(
      "Force DNS mapping",
    ),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "Force DNS mapping also sniffs connections whose domain came from a DNS mapping.",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("Force domains"),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Force domains are sniffed too; other connections that already have a domain are left alone.",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force restart the core?",
    ),
    "fr": MessageLookupByLibrary.simpleMessage("French"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m28,
    "geoUpdated": m29,
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Geo low-memory mode",
    ),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Go"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Download"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage(
      "Go to added rules configuration",
    ),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Go to script configuration",
    ),
    "gratitude": MessageLookupByLibrary.simpleMessage("Gratitude"),
    "gratitudeDesc": MessageLookupByLibrary.simpleMessage(
      "ReClash exists because of their work",
    ),
    "grid": MessageLookupByLibrary.simpleMessage("Grid"),
    "groupCount": m30,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("groups"),
    "groupTimeoutCount": m31,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Cache the changes?",
    ),
    "hashByInUser": MessageLookupByLibrary.simpleMessage(
      "Hash by inbound user",
    ),
    "healthCheck": MessageLookupByLibrary.simpleMessage("Health check"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper service unavailable; TUN mode cannot be enabled. Reinstall ReClash to restore it.",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("Hex"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Hide from list"),
    "hideIp": MessageLookupByLibrary.simpleMessage("Hide IP"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Hide password"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "Hide timed-out proxies",
    ),
    "hideTimeoutProxiesDesc": MessageLookupByLibrary.simpleMessage(
      "Leave out proxies whose last delay test timed out",
    ),
    "hopInterval": MessageLookupByLibrary.simpleMessage("Hop interval"),
    "host": MessageLookupByLibrary.simpleMessage("Host"),
    "hostname": MessageLookupByLibrary.simpleMessage("Hostname"),
    "hotkeyClearAll": MessageLookupByLibrary.simpleMessage("Clear all"),
    "hotkeyClearAllTip": MessageLookupByLibrary.simpleMessage(
      "Remove all hotkey combinations?",
    ),
    "hotkeyCompositorConfig": MessageLookupByLibrary.simpleMessage(
      "Compositor configuration",
    ),
    "hotkeyCompositorConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Alternatively, add an include line to your compositor configuration. These files follow the combinations set in ReClash and temporarily clear them during recording. Your desktop configuration is never modified automatically; resolve any conflicting bindings there.",
    ),
    "hotkeyConflictWith": m32,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Global hotkeys work even while the window is hidden. Tap an action to record its key combination.",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage(
      "Desktop shortcuts",
    ),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Assign a command to a custom shortcut in your desktop settings. ReClash must be running, but its window can stay hidden. Manage these global bindings in your desktop settings.",
    ),
    "hotkeyExportSkipped": m33,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "Compositor configuration files are unavailable. You can still use the desktop commands above.",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "These combinations work while the app window is focused. For global shortcuts, connect desktop commands using the section below.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Hotkey management",
    ),
    "hotkeyNeedsModifier": m34,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("Not set"),
    "hotkeyRestoreDefaults": MessageLookupByLibrary.simpleMessage(
      "Restore defaults",
    ),
    "hotkeyRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "Replace all combinations with the defaults?",
    ),
    "hotkeySafeModeDesc": MessageLookupByLibrary.simpleMessage(
      "Safe mode disables shortcut actions; bindings remain editable.",
    ),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "Not registered, it may be taken by another app",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("hours"),
    "hoursAgo": m35,
    "hoursAgoShort": m36,
    "hue": MessageLookupByLibrary.simpleMessage("Hue"),
    "icon": MessageLookupByLibrary.simpleMessage("Icon"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("Icon records"),
    "iconSets": MessageLookupByLibrary.simpleMessage("Icon sets"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "No icon sets yet. Add them in Custom profile resources → Icon sets",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Icon style"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("Filled"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("Hidden"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("Plain"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("Icon URL"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Ignore battery optimization",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage(
      "This file is not a config that can be imported",
    ),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "Importing replaces the proxy groups, rules and settings this profile has now",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage("Import from file"),
    "importFromLink": MessageLookupByLibrary.simpleMessage("Import from link"),
    "importUrl": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "inbound": MessageLookupByLibrary.simpleMessage("Inbound"),
    "includeInterface": MessageLookupByLibrary.simpleMessage(
      "Included interfaces",
    ),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Only traffic arriving on included interfaces goes through TUN, and excluded interfaces no longer apply.",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage("Included user IDs"),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "Only traffic from processes of included user IDs goes through TUN.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Never expires"),
    "init": MessageLookupByLibrary.simpleMessage("Init"),
    "initFailed": MessageLookupByLibrary.simpleMessage("Startup failed"),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "ReClash ran into an error while starting and can\'t continue. Copy the details to report the problem. If it keeps happening, clearing the data usually lets the app start again.",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("Initiator"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("From"),
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
    "installedFonts": MessageLookupByLibrary.simpleMessage("Installed fonts"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Smart selection",
    ),
    "interfaceName": MessageLookupByLibrary.simpleMessage("Interface name"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "Interface name is the network interface outbound connections use.",
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
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "Enter an IP range in CIDR form such as 192.168.0.0/16",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "A DSCP mark cannot exceed 63",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage(
      "Enter a domain or an IP address",
    ),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage(
      "Not a valid icon set",
    ),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage(
      "Not a subscription link or a proxy share link",
    ),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "Enter an address and port such as 0.0.0.0:1053",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "Only tcp or udp is supported",
    ),
    "invalidPolicy": m37,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "Enter a port or a range such as 443 or 8000-9000",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "This QR code doesn\'t contain a profile link",
    ),
    "invalidProxy": m38,
    "invalidProxyProvider": m39,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "Enter numbers or ranges such as 80 or 8000-9000, separated by /",
    ),
    "invalidRuleSet": m40,
    "invalidSubRule": m41,
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP address"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("Abuse history"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("Proxy"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("Flags"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("Organization"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t determine the IP type",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("Good"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("Level"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("Normal"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("Check again"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("Risky"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("Quality"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("Answered by"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("Sources"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage(
      "Different outbound IP",
    ),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("No type"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage("Rate limited"),
    "ipType": MessageLookupByLibrary.simpleMessage("Type"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("Business"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("Data center"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("Mobile network"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("Residential"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("Unknown type"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("IP version"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "IPv6 traffic is received only while IPv6 is on.",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "With IPv6 on, the VPN allows IPv6 inbound.",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage("IPv6 timeout (ms)"),
    "itemsCount": m42,
    "ja": MessageLookupByLibrary.simpleMessage("Japanese"),
    "justNow": MessageLookupByLibrary.simpleMessage("Just now"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage(
      "TCP keep-alive idle",
    ),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP keep-alive interval",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Key"),
    "kk": MessageLookupByLibrary.simpleMessage("Kazakh"),
    "ko": MessageLookupByLibrary.simpleMessage("Korean"),
    "label": MessageLookupByLibrary.simpleMessage("Label"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "large": MessageLookupByLibrary.simpleMessage("Large"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("Last updated"),
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
    "lineIssueTip": m43,
    "lineWrap": MessageLookupByLibrary.simpleMessage("Word wrap"),
    "link": MessageLookupByLibrary.simpleMessage("Link"),
    "linkDesc": MessageLookupByLibrary.simpleMessage(
      "Obtain a profile from a subscription link or a proxy share link",
    ),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("Liquid Glass"),
    "list": MessageLookupByLibrary.simpleMessage("List"),
    "listen": MessageLookupByLibrary.simpleMessage("Listen"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage(
      "Listen routing mark",
    ),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "Listen routing mark works only on Linux.",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage("Live connections"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading…"),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localImage": MessageLookupByLibrary.simpleMessage("Local image"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "Local network permission denied: using the gvisor stack, LAN is unreachable.",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage("Local proxies"),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Location permission",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Location permission was denied, so the current Wi-Fi name cannot be read. Please enable location permission manually in system settings.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "The system requires location permission to read the Wi-Fi name. On Android choose \"Allow all the time\", otherwise the Wi-Fi name cannot be read while the app is in the background.",
    ),
    "locationPermissionGuide": m44,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Location permission required",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Log"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Log level"),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Turning off Logcat hides the logs entry.",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Logs"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Logs and diagnostics",
    ),
    "logsTest": MessageLookupByLibrary.simpleMessage("Logs test"),
    "loopback": MessageLookupByLibrary.simpleMessage("UWP loopback exemption"),
    "loose": MessageLookupByLibrary.simpleMessage("Loose"),
    "maintainer": MessageLookupByLibrary.simpleMessage("Maintainer"),
    "matchCase": MessageLookupByLibrary.simpleMessage("Match case"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("Match source IP"),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("Max failures"),
    "maxLengthTip": m45,
    "maximize": MessageLookupByLibrary.simpleMessage("Maximize"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage(
      "Resident memory",
    ),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage("App & shared"),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("Heap idle"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage("Heap in use"),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage(
      "Core is not running",
    ),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage(
      "Runtime overhead",
    ),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage("Goroutine stacks"),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "Estimated from process resident memory; it may differ from what the system reports.",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "The Core runs inside the app process. Its share is estimated from runtime stats, and the rest counts as app and shared memory.",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Memory info"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Memory the app and the core use",
    ),
    "memoryReleased": MessageLookupByLibrary.simpleMessage("Memory released"),
    "memoryReleasedSize": m46,
    "messageTest": MessageLookupByLibrary.simpleMessage("Message test"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "This is a message.",
    ),
    "minimize": MessageLookupByLibrary.simpleMessage("Minimize"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("Minimize on exit"),
    "minutes": MessageLookupByLibrary.simpleMessage("minutes"),
    "minutesAgo": m47,
    "minutesAgoShort": m48,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixed port"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "monthsAgo": m49,
    "monthsAgoShort": m50,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("Bottom bar"),
    "network": MessageLookupByLibrary.simpleMessage("Network"),
    "networkAccessDeniedError": m51,
    "networkBadResponseError": m52,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "The request was cancelled",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t connect to the server. Check your network connection or proxy settings",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t resolve the server address. Check that the URL is correct and DNS is working",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("Network name"),
    "networkNotFoundError": m53,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Too many requests (HTTP 429). Wait a moment and try again",
    ),
    "networkRequestFailed": m54,
    "networkSecret": MessageLookupByLibrary.simpleMessage("Network secret"),
    "networkServerError": m55,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Network speed"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage("Traffic takeover"),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "The request timed out. Check your network or proxy, then try again",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "Secure connection failed. The server\'s certificate may be invalid, or the connection is being intercepted",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("Network type"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Next match"),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "noData": MessageLookupByLibrary.simpleMessage("No data"),
    "noInfo": MessageLookupByLibrary.simpleMessage("No info"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Don\'t remind me again",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("No network"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("No-network apps"),
    "noResolve": MessageLookupByLibrary.simpleMessage("Don\'t resolve IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "Don\'t resolve hostname",
    ),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "No matching results",
    ),
    "nodes": MessageLookupByLibrary.simpleMessage("Nodes"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage(
      "This external resource is not a text file",
    ),
    "none": MessageLookupByLibrary.simpleMessage("None"),
    "notRunning": MessageLookupByLibrary.simpleMessage("Not running"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "The current proxy group cannot be selected",
    ),
    "ntpInterval": MessageLookupByLibrary.simpleMessage(
      "Sync interval (minutes)",
    ),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "NTP takes the time from an NTP server instead of the system clock.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Add a profile to get started",
    ),
    "nullTip": m56,
    "numberRangeTip": m57,
    "numberTip": m58,
    "obfs": MessageLookupByLibrary.simpleMessage("Obfuscation"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("Obfuscation host"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("Obfuscation mode"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("Obfuscation parameter"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage(
      "Obfuscation password",
    ),
    "onDemand": MessageLookupByLibrary.simpleMessage("On demand"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "On demand pauses the proxy on excluded Wi-Fi.",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Only count proxy traffic",
    ),
    "optional": MessageLookupByLibrary.simpleMessage("Optional"),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Other contributors",
    ),
    "outbound": MessageLookupByLibrary.simpleMessage("Outbound"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("Exit"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("Outbound IP"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Outbound mode"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage(
      "Override destination",
    ),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "Override destination connects to the sniffed domain instead of the original address.",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage("Override entries"),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("Parse pure IP"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "Parse pure IP sniffs connections that carry only an IP address.",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "paste": MessageLookupByLibrary.simpleMessage("Paste"),
    "peers": MessageLookupByLibrary.simpleMessage("Peers"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("Choose from album"),
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
    "plugin": MessageLookupByLibrary.simpleMessage("Plugin"),
    "pluginHost": MessageLookupByLibrary.simpleMessage("Plugin host"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("Plugin mode"),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a different port",
    ),
    "portHopping": MessageLookupByLibrary.simpleMessage("Port hopping"),
    "portTip": m59,
    "portValue": m60,
    "ports": MessageLookupByLibrary.simpleMessage("Ports"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("Pre-shared key"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Prerequisites"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Press a key combination",
    ),
    "preventDuplicateProfiles": MessageLookupByLibrary.simpleMessage(
      "Prevent duplicate subscriptions",
    ),
    "preventDuplicateProfilesDesc": MessageLookupByLibrary.simpleMessage(
      "Refuse a subscription link that an existing profile already uses",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("Previous match"),
    "privateKey": MessageLookupByLibrary.simpleMessage("Private key"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage(
      "Private key passphrase",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Process"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Please enter a valid interval"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Please enter the auto-update interval",
        ),
    "profileBatchResult": m61,
    "profileDaysLeft": m62,
    "profileExpiresIn": m63,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "The profile has been modified. Turn off auto update?",
    ),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "A profile with this subscription URL already exists",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter the profile name",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Applies to this profile only; anything not added uses its default.",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Applies to this profile only and takes precedence over the TUN override entries in the network settings.",
    ),
    "profileUpdatedAt": m64,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid profile URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter the profile URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profiles"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Sort profiles"),
    "project": MessageLookupByLibrary.simpleMessage("Project"),
    "protocol": MessageLookupByLibrary.simpleMessage("Protocol"),
    "protocolParam": MessageLookupByLibrary.simpleMessage("Protocol parameter"),
    "protocolVersion": MessageLookupByLibrary.simpleMessage("Protocol version"),
    "providerInUse": m65,
    "providerUrlTip": MessageLookupByLibrary.simpleMessage(
      "Only remote providers are supported",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("External resources"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxiesCount": m66,
    "proxiesProfileLabel": m67,
    "proxiesRemovedTip": m68,
    "proxiesReplacedTip": m69,
    "proxyChains": MessageLookupByLibrary.simpleMessage("Proxy chain"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proxy group"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy group is empty",
    ),
    "proxyGroupInUse": m70,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "Groups show up here once the core starts",
    ),
    "proxyGroupsCount": m71,
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Proxy providers"),
    "proxyType": MessageLookupByLibrary.simpleMessage("Proxy type"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Prune cache"),
    "publicKey": MessageLookupByLibrary.simpleMessage("Public key"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("Pure black"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Pure black mode"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR code"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Scan a QR code to obtain a profile",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("Quick actions"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("Quick edit"),
    "recentRequests": MessageLookupByLibrary.simpleMessage("Recent requests"),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("Suggested"),
    "recordType": MessageLookupByLibrary.simpleMessage("Record type"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir port"),
    "redo": MessageLookupByLibrary.simpleMessage("Redo"),
    "regex": MessageLookupByLibrary.simpleMessage("Regex"),
    "regionApply": MessageLookupByLibrary.simpleMessage("Apply region"),
    "regionAppsChanged": MessageLookupByLibrary.simpleMessage(
      "The region or app lists changed. Run selection again for the current settings.",
    ),
    "regionAppsEmpty": MessageLookupByLibrary.simpleMessage(
      "No apps matched this region. Your lists are unchanged.",
    ),
    "regionAppsPreview": m72,
    "regionAppsPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "App selection preview",
    ),
    "regionBypassSettings": m73,
    "regionChina": MessageLookupByLibrary.simpleMessage("China"),
    "regionChoose": MessageLookupByLibrary.simpleMessage("Choose a country"),
    "regionCurrent": MessageLookupByLibrary.simpleMessage("Current region"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "Your manual DNS and MTU overrides, bypass list, routing rules, and service choices are preserved.",
    ),
    "regionDetected": m74,
    "regionDetectionTitle": MessageLookupByLibrary.simpleMessage(
      "Device suggestion",
    ),
    "regionDnsSettings": m75,
    "regionEgypt": MessageLookupByLibrary.simpleMessage("Egypt"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "Regional network defaults and service checks, independent of the interface language.",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("Iran"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage(
      "Network defaults and service checks stay unchanged.",
    ),
    "regionNoDetected": MessageLookupByLibrary.simpleMessage(
      "No matching suggestion. Only the time zone and system locale are used.",
    ),
    "regionNoServices": MessageLookupByLibrary.simpleMessage(
      "Service checks are off",
    ),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("Off"),
    "regionOther": MessageLookupByLibrary.simpleMessage("Other / general"),
    "regionPreviewAndroid": MessageLookupByLibrary.simpleMessage(
      "On Android, MTU or bypass changes may need a confirmed VPN restart. App selection is a separate action.",
    ),
    "regionPreviewBase": m76,
    "regionPreviewMtu": m77,
    "regionPreviewRules": MessageLookupByLibrary.simpleMessage(
      "Proxy selection and your routing rules stay unchanged.",
    ),
    "regionPreviewServices": m78,
    "regionPreviewTitle": MessageLookupByLibrary.simpleMessage("Preview"),
    "regionProfileDefaults": MessageLookupByLibrary.simpleMessage(
      "Profile defaults",
    ),
    "regionRussia": MessageLookupByLibrary.simpleMessage("Russia"),
    "regionSelectApps": MessageLookupByLibrary.simpleMessage(
      "Select apps by region",
    ),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "Choose a supported region before using regional app suggestions.",
    ),
    "regionSourceLocaleCountry": MessageLookupByLibrary.simpleMessage(
      "system locale country",
    ),
    "regionSourceLocaleLanguage": MessageLookupByLibrary.simpleMessage(
      "system language",
    ),
    "regionSourceTimeZone": MessageLookupByLibrary.simpleMessage("time zone"),
    "regionTitle": MessageLookupByLibrary.simpleMessage("Region profile"),
    "regionTunSettings": m79,
    "regionUseDetected": MessageLookupByLibrary.simpleMessage(
      "Use detected region",
    ),
    "regionWarning": MessageLookupByLibrary.simpleMessage(
      "Choosing a country only updates this preview. Regional defaults change when you apply it.",
    ),
    "regionalAdaptation": MessageLookupByLibrary.simpleMessage(
      "Regional adaptation",
    ),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("Release memory"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to release memory",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("Remote"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Remote destination",
    ),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage(
      "Remote DNS resolution",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "rename": MessageLookupByLibrary.simpleMessage("Rename"),
    "replace": MessageLookupByLibrary.simpleMessage("Replace"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Replace all"),
    "request": MessageLookupByLibrary.simpleMessage("Request"),
    "requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Requests and updates",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Required"),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "This page has changes. Are you sure you want to reset?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to reset?",
    ),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto-update interval",
    ),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "The auto-update interval must be greater than 0",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "respectRules": MessageLookupByLibrary.simpleMessage("Respect rules"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "Respect rules routes DNS connections by the rules and needs a Proxy Server Nameserver.",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("Response code"),
    "restart": MessageLookupByLibrary.simpleMessage("Restart"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to restart the core?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restore"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("Restore all data"),
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
    "result": MessageLookupByLibrary.simpleMessage("Result"),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Route addresses"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage(
      "Route exclude addresses",
    ),
    "routingMark": MessageLookupByLibrary.simpleMessage("Routing mark"),
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
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "The rules must be a YAML list with one rule per item, such as - DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BitTorrent direct",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "Block DNS over TLS",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage(
      "Block proxy loopback",
    ),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage("Block QUIC"),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage("Block STUN"),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage("LAN direct"),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple and Microsoft direct",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Rule providers"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Rule set"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage(
      "The rule set has no usable entries",
    ),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage(
      "This mrs file cannot be read",
    ),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "The rule set mixes domains and IP ranges, so its type cannot be told",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Rule target"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "The rule must start with a supported type, such as DOMAIN,example.com,DIRECT",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("Rules"),
    "rulesCount": m80,
    "runTime": MessageLookupByLibrary.simpleMessage("Run time"),
    "running": MessageLookupByLibrary.simpleMessage("Running"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("Runtime config"),
    "safeMode": MessageLookupByLibrary.simpleMessage("Safe mode"),
    "safeModeAppTitle": m81,
    "saturation": MessageLookupByLibrary.simpleMessage("Saturation"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save the changes?"),
    "script": MessageLookupByLibrary.simpleMessage("Script"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Script mode: rewrites the whole profile with an extension script",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Scroll to selected",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "seconds": MessageLookupByLibrary.simpleMessage("seconds"),
    "secondsCount": m82,
    "secretKey": MessageLookupByLibrary.simpleMessage("Key"),
    "sectionsInEffect": m83,
    "selectAll": MessageLookupByLibrary.simpleMessage("Select all"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Please select a rule set",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Please select a split strategy",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "server": MessageLookupByLibrary.simpleMessage("Server"),
    "serviceAbnormalCount": m84,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage(
      "All available",
    ),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Available"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Blocked"),
    "serviceCheck": MessageLookupByLibrary.simpleMessage("Check"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Check all"),
    "serviceCheckedAt": m85,
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage(
      "Disallowed ISP",
    ),
    "serviceFailed": MessageLookupByLibrary.simpleMessage("Check failed"),
    "serviceManage": MessageLookupByLibrary.simpleMessage("Manage services"),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage(
      "Originals only",
    ),
    "servicePending": MessageLookupByLibrary.simpleMessage("Not checked"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage(
      "Access restricted",
    ),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage(
      "Shown on the dashboard",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("Service status"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("Unavailable"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage(
      "Region not supported",
    ),
    "settingEntries": MessageLookupByLibrary.simpleMessage("settings"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsCount": m86,
    "setupAgeKeyDescription": MessageLookupByLibrary.simpleMessage(
      "This profile is encrypted. Enter its age key to continue.",
    ),
    "setupAlternativeDescription": MessageLookupByLibrary.simpleMessage(
      "This server responded to a separate probe. Switch and check the full route again.",
    ),
    "setupAutoConnect": MessageLookupByLibrary.simpleMessage(
      "Connect when opening ReClash",
    ),
    "setupAutoConnectDescription": MessageLookupByLibrary.simpleMessage(
      "Start this connection together with the app.",
    ),
    "setupCheckAction": MessageLookupByLibrary.simpleMessage(
      "Check connection",
    ),
    "setupCheckLimit": MessageLookupByLibrary.simpleMessage(
      "The result applies to this route, not every app or website.",
    ),
    "setupCheckingDescription": MessageLookupByLibrary.simpleMessage(
      "We check one selected route. System permission requests open separately.",
    ),
    "setupCheckingTitle": MessageLookupByLibrary.simpleMessage(
      "Connecting and checking",
    ),
    "setupConfirmed": MessageLookupByLibrary.simpleMessage("Confirmed"),
    "setupConnectedDescription": MessageLookupByLibrary.simpleMessage(
      "The selected route responded. Traffic follows your profile rules.",
    ),
    "setupConnectedTitle": MessageLookupByLibrary.simpleMessage(
      "Connection works",
    ),
    "setupCopyProxy": MessageLookupByLibrary.simpleMessage(
      "Copy proxy address",
    ),
    "setupCoverageAll": MessageLookupByLibrary.simpleMessage("All apps"),
    "setupCoverageAllDescription": MessageLookupByLibrary.simpleMessage(
      "TUN captures device traffic. The system may ask for permission.",
    ),
    "setupCoverageAndroidDescription": MessageLookupByLibrary.simpleMessage(
      "Android will ask to create a VPN connection. App selection stays in access settings.",
    ),
    "setupCoverageDescription": MessageLookupByLibrary.simpleMessage(
      "Choose which apps use ReClash. Your profile rules decide which connections use a server.",
    ),
    "setupCoverageLocal": MessageLookupByLibrary.simpleMessage(
      "I will configure apps manually",
    ),
    "setupCoverageLocalDescription": MessageLookupByLibrary.simpleMessage(
      "Set the local proxy address in each app you want to connect.",
    ),
    "setupCoverageNote": MessageLookupByLibrary.simpleMessage(
      "Capturing all traffic does not mean sending all of it through a server. Direct routes remain in place.",
    ),
    "setupCoverageSystem": MessageLookupByLibrary.simpleMessage("System proxy"),
    "setupCoverageSystemDescription": MessageLookupByLibrary.simpleMessage(
      "Apps without system proxy support connect directly.",
    ),
    "setupCoverageTitle": MessageLookupByLibrary.simpleMessage(
      "Which apps should connect?",
    ),
    "setupErrorDetails": MessageLookupByLibrary.simpleMessage("Details"),
    "setupFailedTitle": MessageLookupByLibrary.simpleMessage(
      "Connection needs attention",
    ),
    "setupFinishDescription": MessageLookupByLibrary.simpleMessage(
      "You can change any choice in settings.",
    ),
    "setupLanguageContinue": MessageLookupByLibrary.simpleMessage("Continue"),
    "setupLanguageDescription": MessageLookupByLibrary.simpleMessage(
      "Select a language before reading the terms. You can change it later.",
    ),
    "setupLanguageTitle": MessageLookupByLibrary.simpleMessage(
      "Choose your language",
    ),
    "setupLaterNote": MessageLookupByLibrary.simpleMessage(
      "Setup is incomplete; connection has not been checked.",
    ),
    "setupLocalDescription": MessageLookupByLibrary.simpleMessage(
      "Set this address in the apps you want to connect. This check does not prove those apps are configured.",
    ),
    "setupLocalTitle": MessageLookupByLibrary.simpleMessage(
      "Local proxy is ready",
    ),
    "setupNotChecked": MessageLookupByLibrary.simpleMessage("Not checked"),
    "setupPartialDescription": MessageLookupByLibrary.simpleMessage(
      "The route responded, but some checks could not be confirmed.",
    ),
    "setupPartialTitle": MessageLookupByLibrary.simpleMessage(
      "Connected, with limits",
    ),
    "setupPermissionDescription": MessageLookupByLibrary.simpleMessage(
      "Allow the connection in the system prompt, retry, or choose a different scope.",
    ),
    "setupPermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Permission is needed",
    ),
    "setupPhaseAlternatives": MessageLookupByLibrary.simpleMessage(
      "Looking for another server",
    ),
    "setupPhaseConnection": MessageLookupByLibrary.simpleMessage(
      "Starting the connection",
    ),
    "setupPhaseCore": MessageLookupByLibrary.simpleMessage("Starting the core"),
    "setupPhaseExit": MessageLookupByLibrary.simpleMessage(
      "Confirming the exit",
    ),
    "setupPhaseProfile": MessageLookupByLibrary.simpleMessage(
      "Applying the profile",
    ),
    "setupPhaseRoute": MessageLookupByLibrary.simpleMessage(
      "Checking the route",
    ),
    "setupPhaseServices": MessageLookupByLibrary.simpleMessage(
      "Checking services",
    ),
    "setupProfileCount": m87,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash does not provide servers. Import a subscription or a configuration from your provider.",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage(
      "Import profile",
    ),
    "setupProfileLinkHint": MessageLookupByLibrary.simpleMessage(
      "Subscription or share link",
    ),
    "setupProfileReady": MessageLookupByLibrary.simpleMessage("Profile ready"),
    "setupProfileSkip": MessageLookupByLibrary.simpleMessage("Set up later"),
    "setupProfileTitle": MessageLookupByLibrary.simpleMessage(
      "Add a connection profile",
    ),
    "setupReceipt": MessageLookupByLibrary.simpleMessage("Your connection"),
    "setupReceiptCheck": MessageLookupByLibrary.simpleMessage("Check"),
    "setupReceiptCoverage": MessageLookupByLibrary.simpleMessage("Coverage"),
    "setupReceiptProfile": MessageLookupByLibrary.simpleMessage("Profile"),
    "setupRegionConfirm": MessageLookupByLibrary.simpleMessage(
      "Use these regional settings",
    ),
    "setupRegionDescription": MessageLookupByLibrary.simpleMessage(
      "The suggested region comes from this device, not the interface language. Apply it only if it matches your network.",
    ),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage(
      "Keep profile defaults",
    ),
    "setupRepeat": MessageLookupByLibrary.simpleMessage("Check again"),
    "setupReport": MessageLookupByLibrary.simpleMessage("Check report"),
    "setupRequestPermission": MessageLookupByLibrary.simpleMessage(
      "Allow connection",
    ),
    "setupRestart": MessageLookupByLibrary.simpleMessage("Set up connection"),
    "setupResume": MessageLookupByLibrary.simpleMessage("Continue setup"),
    "setupRouteChanged": MessageLookupByLibrary.simpleMessage(
      "The route changed during the check. Check the current connection again.",
    ),
    "setupSafeMode": MessageLookupByLibrary.simpleMessage(
      "Safe mode does not start a real connection. Save the setup or test it in a normal build.",
    ),
    "setupSaveError": MessageLookupByLibrary.simpleMessage(
      "Could not save your choices. Try again.",
    ),
    "setupSaveWithoutConnection": MessageLookupByLibrary.simpleMessage(
      "Save without connecting",
    ),
    "setupSavedDescription": MessageLookupByLibrary.simpleMessage(
      "Your choices are saved. You can connect from the dashboard when you are ready.",
    ),
    "setupSavedTitle": MessageLookupByLibrary.simpleMessage("Connect later"),
    "setupStepStatus": m88,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "Your choices are saved. The previous connection was not stopped.",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage("Check stopped"),
    "setupTitle": MessageLookupByLibrary.simpleMessage("First connection"),
    "setupTryServer": m89,
    "setupUnavailable": MessageLookupByLibrary.simpleMessage("No response"),
    "setupUnconfirmedDescription": MessageLookupByLibrary.simpleMessage(
      "The connection started, but the selected route did not provide enough results.",
    ),
    "setupUnconfirmedTitle": MessageLookupByLibrary.simpleMessage(
      "Connection not confirmed",
    ),
    "setupUnknownError": MessageLookupByLibrary.simpleMessage(
      "The operation did not finish. Try again or open the details.",
    ),
    "shareLinkUnreadable": m90,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "No proxy could be read from the links",
    ),
    "show": MessageLookupByLibrary.simpleMessage("Show"),
    "showLess": MessageLookupByLibrary.simpleMessage("Collapse"),
    "showMore": MessageLookupByLibrary.simpleMessage("Expand"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Stop button in notification",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Show password"),
    "sidebarBlur": MessageLookupByLibrary.simpleMessage("Sidebar blur"),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "Show the blurred desktop behind the window through the sidebar",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Silent launch"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Silent launch starts without showing the window.",
    ),
    "singleAdd": MessageLookupByLibrary.simpleMessage("Single add"),
    "singleImport": MessageLookupByLibrary.simpleMessage("Single import"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "Enter one link here; edit several from the quick edit of the list",
    ),
    "singleValueTip": m91,
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage(
      "Skip certificate verification",
    ),
    "skipDomain": MessageLookupByLibrary.simpleMessage("Skip domains"),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage(
      "A sniffed domain on the Skip domains list is not used.",
    ),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage(
      "Skip destination addresses",
    ),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage(
      "Skip source addresses",
    ),
    "slide": MessageLookupByLibrary.simpleMessage("Slide"),
    "sliders": MessageLookupByLibrary.simpleMessage("Sliders"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("Protocols"),
    "sniffer": MessageLookupByLibrary.simpleMessage("Sniffer"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "The sniffer reads the domain from TLS, HTTP and QUIC traffic so rules can match it.",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("SOCKS port"),
    "softStyle": MessageLookupByLibrary.simpleMessage("Soft"),
    "sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "source": MessageLookupByLibrary.simpleMessage("Source"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Source IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Special proxy"),
    "specialRules": MessageLookupByLibrary.simpleMessage("Special rules"),
    "spectrum": MessageLookupByLibrary.simpleMessage("Spectrum"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("Speed statistics"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("Split strategy"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Split strategy cannot be empty",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSIDs are empty"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Stack mode"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("Stack trace"),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Standard mode: adds rules on top of the profile",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage(
      "Start from scratch",
    ),
    "startVpn": MessageLookupByLibrary.simpleMessage("Starting VPN…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage(
      "Startup and background",
    ),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "With DNS off, the system DNS is used.",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Stopping VPN…"),
    "strategy": MessageLookupByLibrary.simpleMessage("Strategy"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("Strict route"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "Strict route keeps traffic such as DNS from bypassing TUN, and other devices can no longer reach this one.",
    ),
    "style": MessageLookupByLibrary.simpleMessage("Style"),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "subscriptionClientAuto": MessageLookupByLibrary.simpleMessage(
      "Automatically",
    ),
    "subscriptionClientClash": MessageLookupByLibrary.simpleMessage("Clash"),
    "subscriptionClientClashMeta": MessageLookupByLibrary.simpleMessage(
      "Clash Meta",
    ),
    "subscriptionClientCustom": MessageLookupByLibrary.simpleMessage(
      "Custom User-Agent",
    ),
    "subscriptionClientCustomUserAgent": MessageLookupByLibrary.simpleMessage(
      "User-Agent",
    ),
    "subscriptionClientCustomUserAgentInvalid":
        MessageLookupByLibrary.simpleMessage(
          "Enter a valid User-Agent without control characters.",
        ),
    "subscriptionClientDeviceDataHint": MessageLookupByLibrary.simpleMessage(
      "Client selection does not send device identity.",
    ),
    "subscriptionClientHapp": MessageLookupByLibrary.simpleMessage("Happ"),
    "subscriptionClientIncy": MessageLookupByLibrary.simpleMessage("INCY"),
    "subscriptionClientReclash": MessageLookupByLibrary.simpleMessage(
      "ReClash",
    ),
    "subscriptionClientRequestAs": MessageLookupByLibrary.simpleMessage(
      "Request as",
    ),
    "subscriptionClientSingbox": MessageLookupByLibrary.simpleMessage(
      "sing-box / Karing",
    ),
    "subscriptionClientUrlOnly": MessageLookupByLibrary.simpleMessage(
      "These settings apply to subscription URLs. Share links are imported locally.",
    ),
    "subscriptionClientV2rayng": MessageLookupByLibrary.simpleMessage(
      "v2rayNG",
    ),
    "subscriptionCompatibilityAgeKey": MessageLookupByLibrary.simpleMessage(
      "Enter the AGE key to check this subscription.",
    ),
    "subscriptionCompatibilityApplyPrepared":
        MessageLookupByLibrary.simpleMessage("Apply checked result"),
    "subscriptionCompatibilityAuthorization":
        MessageLookupByLibrary.simpleMessage(
          "The server rejected authorization. Client negotiation stopped.",
        ),
    "subscriptionCompatibilityCheck": MessageLookupByLibrary.simpleMessage(
      "Check",
    ),
    "subscriptionCompatibilityCheckFailed":
        MessageLookupByLibrary.simpleMessage(
          "Could not obtain a compatible subscription. The existing configuration was not changed.",
        ),
    "subscriptionCompatibilityCheckHint": MessageLookupByLibrary.simpleMessage(
      "Checks the current form without saving or restarting VPN. This checks parsing, not node availability.",
    ),
    "subscriptionCompatibilityForgetConsent":
        MessageLookupByLibrary.simpleMessage("Ask about import losses again"),
    "subscriptionCompatibilityHideUrl": MessageLookupByLibrary.simpleMessage(
      "Hide subscription URL",
    ),
    "subscriptionCompatibilityLastSuccessful":
        MessageLookupByLibrary.simpleMessage("Last successful client"),
    "subscriptionCompatibilityNeedsReview":
        MessageLookupByLibrary.simpleMessage(
          "The import omits source data. Review the losses before applying.",
        ),
    "subscriptionCompatibilityPinSuccessful":
        MessageLookupByLibrary.simpleMessage("Use this client"),
    "subscriptionCompatibilityPrepared": m92,
    "subscriptionCompatibilityPreparedHint":
        MessageLookupByLibrary.simpleMessage(
          "Core parsed this result. It has not been saved or applied.",
        ),
    "subscriptionCompatibilityRateLimited":
        MessageLookupByLibrary.simpleMessage(
          "The server limited requests. Try again later.",
        ),
    "subscriptionCompatibilityShowUrl": MessageLookupByLibrary.simpleMessage(
      "Show subscription URL",
    ),
    "subscriptionCompatibilitySuperseded": MessageLookupByLibrary.simpleMessage(
      "The form or profile changed. Check the subscription again.",
    ),
    "subscriptionCompatibilityTimeout": MessageLookupByLibrary.simpleMessage(
      "The subscription check timed out.",
    ),
    "subscriptionCompatibilityTitle": MessageLookupByLibrary.simpleMessage(
      "Compatibility",
    ),
    "subscriptionCompatibilityTransport": MessageLookupByLibrary.simpleMessage(
      "Connection failed. Client negotiation stopped.",
    ),
    "subscriptionDeviceLimit": MessageLookupByLibrary.simpleMessage(
      "No device slots are available for this subscription. Remove a device from the provider account and try again.",
    ),
    "subscriptionDeviceRequired": MessageLookupByLibrary.simpleMessage(
      "This subscription requires device registration. Follow the provider\'s instructions.",
    ),
    "subscriptionIdentityDetails": MessageLookupByLibrary.simpleMessage(
      "Also send operating system and device model",
    ),
    "subscriptionIdentityDetailsDisclosure":
        MessageLookupByLibrary.simpleMessage(
          "This also sends the operating system version and device model with the identifier.",
        ),
    "subscriptionIdentityDisclosure": MessageLookupByLibrary.simpleMessage(
      "A stable pseudonymous device ID will be sent to this subscription origin. It is not hardware attestation and consent stays on this device.",
    ),
    "subscriptionIdentityGlobalHint": MessageLookupByLibrary.simpleMessage(
      "When enabled, the device identifier is sent with requests for all URL subscriptions unless a profile overrides this setting. Operating system and device details remain separately opt-in per subscription.",
    ),
    "subscriptionIdentitySettingsTitle": MessageLookupByLibrary.simpleMessage(
      "Subscription identity",
    ),
    "subscriptionIdentityTitle": MessageLookupByLibrary.simpleMessage(
      "Send HWID",
    ),
    "subscriptionIdentityUseGlobal": MessageLookupByLibrary.simpleMessage(
      "Use global",
    ),
    "subscriptionImportAccept": MessageLookupByLibrary.simpleMessage(
      "Accept and import",
    ),
    "subscriptionImportAcceptOtherLosses": MessageLookupByLibrary.simpleMessage(
      "I understand that some source data will not be preserved.",
    ),
    "subscriptionImportAcceptPartial": MessageLookupByLibrary.simpleMessage(
      "Continue with only the supported nodes.",
    ),
    "subscriptionImportAcceptSections": MessageLookupByLibrary.simpleMessage(
      "I understand that source settings will be omitted.",
    ),
    "subscriptionImportFormatClash": MessageLookupByLibrary.simpleMessage(
      "Clash configuration",
    ),
    "subscriptionImportFormatEncrypted": MessageLookupByLibrary.simpleMessage(
      "encrypted subscription",
    ),
    "subscriptionImportFormatShareLinks": MessageLookupByLibrary.simpleMessage(
      "proxy links",
    ),
    "subscriptionImportFormatUnknown": MessageLookupByLibrary.simpleMessage(
      "unknown format",
    ),
    "subscriptionImportIgnoredSections": m93,
    "subscriptionImportNoNodes": MessageLookupByLibrary.simpleMessage(
      "No supported proxy nodes can be imported.",
    ),
    "subscriptionImportRememberConsent": MessageLookupByLibrary.simpleMessage(
      "Remember this consent for this subscription",
    ),
    "subscriptionImportRememberConsentHint":
        MessageLookupByLibrary.simpleMessage(
          "Applies only to this source, format and the accepted loss types. New losses require consent again.",
        ),
    "subscriptionImportReviewSummary": m94,
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "Review subscription import",
    ),
    "subscriptionImportSkippedNodes": m95,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Subscription info",
    ),
    "subscriptionProvider": MessageLookupByLibrary.simpleMessage(
      "Subscription",
    ),
    "subscriptionProviderAccount": MessageLookupByLibrary.simpleMessage(
      "Account",
    ),
    "subscriptionProviderBuyPlan": MessageLookupByLibrary.simpleMessage(
      "Buy plan",
    ),
    "subscriptionProviderBuyTraffic": MessageLookupByLibrary.simpleMessage(
      "Buy traffic",
    ),
    "subscriptionProviderLogo": MessageLookupByLibrary.simpleMessage(
      "Logo URL",
    ),
    "subscriptionProviderSupport": MessageLookupByLibrary.simpleMessage(
      "Support",
    ),
    "subscriptionProviderWebsite": MessageLookupByLibrary.simpleMessage(
      "Website",
    ),
    "subscriptionUseProviderInterval": MessageLookupByLibrary.simpleMessage(
      "Use provider update interval",
    ),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "Enter your password for sudo",
    ),
    "suspended": MessageLookupByLibrary.simpleMessage("Suspended…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("Switch profile"),
    "sync": MessageLookupByLibrary.simpleMessage("Sync"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "systemApp": MessageLookupByLibrary.simpleMessage("System apps"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "tab": MessageLookupByLibrary.simpleMessage("Tab"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Tab animation"),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage(
      "Tap the icon to retry",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("Tap to authorize"),
    "target": MessageLookupByLibrary.simpleMessage("Target"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP concurrent"),
    "telegramAppUnavailable": MessageLookupByLibrary.simpleMessage(
      "Telegram could not be opened on this device.",
    ),
    "telegramLinkTitle": MessageLookupByLibrary.simpleMessage("Telegram"),
    "telegramOpen": MessageLookupByLibrary.simpleMessage("Open Telegram"),
    "telegramWebFallback": MessageLookupByLibrary.simpleMessage(
      "Open in browser",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage("Test interval"),
    "testUrl": MessageLookupByLibrary.simpleMessage("Test URL"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("Test when used"),
    "textScale": MessageLookupByLibrary.simpleMessage("Text scaling"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage(
      "Text in the app will look like this",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Theme color"),
    "themeMode": MessageLookupByLibrary.simpleMessage("Theme mode"),
    "tight": MessageLookupByLibrary.simpleMessage("Tight"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "timeout": MessageLookupByLibrary.simpleMessage("Timeout"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("Tinted"),
    "tip": MessageLookupByLibrary.simpleMessage("Tip"),
    "tk": MessageLookupByLibrary.simpleMessage("Turkmen"),
    "toggle": MessageLookupByLibrary.simpleMessage("Toggle"),
    "tolerance": MessageLookupByLibrary.simpleMessage("Tolerance"),
    "tools": MessageLookupByLibrary.simpleMessage("Tools"),
    "toolsAction": MessageLookupByLibrary.simpleMessage("Action"),
    "toolsChoose": MessageLookupByLibrary.simpleMessage(
      "Choose a section or search for a setting",
    ),
    "toolsCloseConnectionsConfirm": MessageLookupByLibrary.simpleMessage(
      "This will close all active connections. Continue?",
    ),
    "toolsCompleted": MessageLookupByLibrary.simpleMessage("Action completed"),
    "toolsConfiguration": MessageLookupByLibrary.simpleMessage("Configuration"),
    "toolsData": MessageLookupByLibrary.simpleMessage("Resources and data"),
    "toolsEmpty": MessageLookupByLibrary.simpleMessage(
      "No matching settings or actions",
    ),
    "toolsInformation": MessageLookupByLibrary.simpleMessage(
      "Information and debugging",
    ),
    "toolsLastUsed": MessageLookupByLibrary.simpleMessage("Recently used"),
    "toolsNeedsAuthentication": MessageLookupByLibrary.simpleMessage(
      "Enable authentication first",
    ),
    "toolsNeedsController": MessageLookupByLibrary.simpleMessage(
      "Enable the external controller first",
    ),
    "toolsNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Start the core to use this action",
    ),
    "toolsNeedsCustomInterface": MessageLookupByLibrary.simpleMessage(
      "Select a custom network interface first",
    ),
    "toolsNeedsMipsStack": MessageLookupByLibrary.simpleMessage(
      "Select the MIPS network stack first",
    ),
    "toolsNeedsOverride": MessageLookupByLibrary.simpleMessage(
      "Add this DNS override on the DNS page first",
    ),
    "toolsNeedsWebdav": MessageLookupByLibrary.simpleMessage(
      "Configure WebDAV first",
    ),
    "toolsObservation": MessageLookupByLibrary.simpleMessage("Diagnostics"),
    "toolsPin": MessageLookupByLibrary.simpleMessage("Pin"),
    "toolsPinned": MessageLookupByLibrary.simpleMessage("Pinned"),
    "toolsRestartCore": MessageLookupByLibrary.simpleMessage("Restart core"),
    "toolsResults": m96,
    "toolsRun": MessageLookupByLibrary.simpleMessage("Run"),
    "toolsSection": MessageLookupByLibrary.simpleMessage("Section"),
    "toolsSetting": MessageLookupByLibrary.simpleMessage("Setting"),
    "toolsUnpin": MessageLookupByLibrary.simpleMessage("Unpin"),
    "toolsUpdateResources": MessageLookupByLibrary.simpleMessage(
      "Update resources",
    ),
    "toolsUpdateResourcesConfirm": MessageLookupByLibrary.simpleMessage(
      "Updating rules and scripts may reapply the configuration and affect connections. Continue?",
    ),
    "torch": MessageLookupByLibrary.simpleMessage("Flashlight"),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Downloaded"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Total traffic"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Uploaded"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy port"),
    "traffic": MessageLookupByLibrary.simpleMessage("Traffic"),
    "trafficPeak": m97,
    "trafficTotal": m98,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Traffic usage"),
    "translationNotice": MessageLookupByLibrary.simpleMessage(
      "ReClash speaks your language so nobody is left out. If a phrase sounds off to a native ear, let us know and we will fix it.",
    ),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage(
      "Suggest a translation fix",
    ),
    "transport": MessageLookupByLibrary.simpleMessage("Transport"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "TUN could not be authorized, so it was turned off.",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "TUN works only in administrator mode.",
    ),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "Entries added here replace the TUN settings of every profile; anything not added keeps the profile\'s own setting. Entries a custom profile adds itself take precedence.",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Turn off"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Turn on"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage("UDP relay mode"),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("UDP timeout"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "The UDP timeout is in seconds and works only with the gvisor, system and mixed stacks.",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("Ultra"),
    "undo": MessageLookupByLibrary.simpleMessage("Undo"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Unified delay"),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Unknown network error",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("Restore down"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Unnamed"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("Unpin window"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "updateAllowAutomatic": MessageLookupByLibrary.simpleMessage(
      "Allow automatic installation",
    ),
    "updateAndroidAutoNote": MessageLookupByLibrary.simpleMessage(
      "These preferences do not grant Android permission to install apps. You can change them at any time.",
    ),
    "updateAutoConsentDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash may install verified, eligible stable updates without asking each time. It will never disconnect your VPN. Android may still ask you to confirm an installation.",
    ),
    "updateAutoConsentTitle": MessageLookupByLibrary.simpleMessage(
      "Allow automatic installation?",
    ),
    "updateAutoInstall": MessageLookupByLibrary.simpleMessage(
      "Install automatically",
    ),
    "updateAutoInstallDescription": MessageLookupByLibrary.simpleMessage(
      "Install eligible stable updates only when the VPN is off. Important changes always wait for you.",
    ),
    "updateBackgroundNote": MessageLookupByLibrary.simpleMessage(
      "Closing this window does not stop the download.",
    ),
    "updateCancelDownload": MessageLookupByLibrary.simpleMessage(
      "Cancel download",
    ),
    "updateChannel": MessageLookupByLibrary.simpleMessage("Update channel"),
    "updateChannelPre": MessageLookupByLibrary.simpleMessage("Pre-release"),
    "updateChannelRelease": MessageLookupByLibrary.simpleMessage("Release"),
    "updateCheckAutomatically": MessageLookupByLibrary.simpleMessage(
      "Check automatically",
    ),
    "updateCheckFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t check for updates.",
    ),
    "updateCheckFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Check your connection and try again.",
    ),
    "updateCheckQuietly": MessageLookupByLibrary.simpleMessage(
      "Check periodically while ReClash is running. An update appears on the dashboard, without opening a window.",
    ),
    "updateCheckingDescription": MessageLookupByLibrary.simpleMessage(
      "Looking for a newer version on your selected channel.",
    ),
    "updateCloseWindow": MessageLookupByLibrary.simpleMessage("Close window"),
    "updateConfirmationDescription": MessageLookupByLibrary.simpleMessage(
      "Android requires your approval. Continue to open the system confirmation.",
    ),
    "updateConfirmationTitle": MessageLookupByLibrary.simpleMessage(
      "Confirm with Android",
    ),
    "updateContinueBackground": MessageLookupByLibrary.simpleMessage(
      "Continue in background",
    ),
    "updateContinueInstall": MessageLookupByLibrary.simpleMessage(
      "Continue installation",
    ),
    "updateCurrentTitle": MessageLookupByLibrary.simpleMessage(
      "You\'re up to date",
    ),
    "updateDesktopDescription": MessageLookupByLibrary.simpleMessage(
      "On this platform, ReClash opens the release page. Download and install the update yourself.",
    ),
    "updateDirectUnavailable": MessageLookupByLibrary.simpleMessage(
      "A verified download for this device is unavailable. Open the release page to choose a package.",
    ),
    "updateDisconnectInstall": MessageLookupByLibrary.simpleMessage(
      "Disconnect and install",
    ),
    "updateDoNotEnable": MessageLookupByLibrary.simpleMessage(
      "Keep manual installation",
    ),
    "updateDownloadAction": MessageLookupByLibrary.simpleMessage(
      "Download update",
    ),
    "updateDownloadAgain": MessageLookupByLibrary.simpleMessage(
      "Download again",
    ),
    "updateDownloadDescription": MessageLookupByLibrary.simpleMessage(
      "You can close this window. Progress remains on the dashboard.",
    ),
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t download the update.",
    ),
    "updateDownloadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "The downloaded part is saved. Check your connection, then resume.",
    ),
    "updateExistingVersionSafe": MessageLookupByLibrary.simpleMessage(
      "Your installed version remains unchanged.",
    ),
    "updateGotIt": MessageLookupByLibrary.simpleMessage("Got it"),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t start the package installer.",
    ),
    "updateInstallFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Android did not complete the installation. Try again when you\'re ready.",
    ),
    "updateInstallNow": MessageLookupByLibrary.simpleMessage("Install now"),
    "updateInstalledDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash is now using the new version.",
    ),
    "updateInstalledTitle": MessageLookupByLibrary.simpleMessage(
      "Update installed",
    ),
    "updateInstalledVersion": m99,
    "updateInstallingDescription": MessageLookupByLibrary.simpleMessage(
      "Android is completing the installation. ReClash may close during this step.",
    ),
    "updateInstallingTitle": MessageLookupByLibrary.simpleMessage(
      "Installing the update",
    ),
    "updateMinutes": m100,
    "updateNoUpdates": MessageLookupByLibrary.simpleMessage(
      "You\'re already using the latest version.",
    ),
    "updateNotNow": MessageLookupByLibrary.simpleMessage("Not now"),
    "updateNotesHeading": MessageLookupByLibrary.simpleMessage("What\'s new"),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage(
      "No release notes are available.",
    ),
    "updateOfferDownloadNote": MessageLookupByLibrary.simpleMessage(
      "Downloading does not install the update or interrupt your VPN.",
    ),
    "updateOfferTitle": MessageLookupByLibrary.simpleMessage(
      "An update is available",
    ),
    "updateOpenAndroidSettings": MessageLookupByLibrary.simpleMessage(
      "Open Android settings",
    ),
    "updatePackageDevice": MessageLookupByLibrary.simpleMessage("Device build"),
    "updatePackageSize": MessageLookupByLibrary.simpleMessage("Download size"),
    "updatePackageVerification": MessageLookupByLibrary.simpleMessage(
      "Package checks",
    ),
    "updatePackageVerificationPending": MessageLookupByLibrary.simpleMessage(
      "Checked after download, before installation",
    ),
    "updatePackageVerified": MessageLookupByLibrary.simpleMessage(
      "Integrity, app identity and signature verified",
    ),
    "updatePackageVersion": MessageLookupByLibrary.simpleMessage("Version"),
    "updatePauseAction": MessageLookupByLibrary.simpleMessage("Pause"),
    "updatePausedDescription": MessageLookupByLibrary.simpleMessage(
      "The downloaded part is saved. Resume when you\'re ready.",
    ),
    "updatePausedTitle": MessageLookupByLibrary.simpleMessage(
      "Download paused",
    ),
    "updatePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Allow ReClash to install apps from this source, then return to continue.",
    ),
    "updatePermissionTitle": MessageLookupByLibrary.simpleMessage(
      "Android permission needed",
    ),
    "updatePreferencesDescription": MessageLookupByLibrary.simpleMessage(
      "Choose checking, downloading and installation separately.",
    ),
    "updatePreferencesIntro": MessageLookupByLibrary.simpleMessage(
      "Updates, your way",
    ),
    "updatePreferencesSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Preferences weren\'t saved. Try saving again; automatic installation has not been enabled.",
    ),
    "updatePreferencesTitle": MessageLookupByLibrary.simpleMessage(
      "Update preferences",
    ),
    "updatePreload": MessageLookupByLibrary.simpleMessage("Preload on Wi-Fi"),
    "updatePreloadDescription": MessageLookupByLibrary.simpleMessage(
      "Download available updates over Wi-Fi. Leaving Wi-Fi pauses automatic downloads.",
    ),
    "updateReadyDescription": MessageLookupByLibrary.simpleMessage(
      "The package has passed all checks. Install now or keep it for later.",
    ),
    "updateReadyTitle": MessageLookupByLibrary.simpleMessage(
      "Ready to install",
    ),
    "updateReleaseDetails": MessageLookupByLibrary.simpleMessage(
      "Release details",
    ),
    "updateRemainingTime": m101,
    "updateResumeAction": MessageLookupByLibrary.simpleMessage(
      "Resume download",
    ),
    "updateRetryCheck": MessageLookupByLibrary.simpleMessage("Check again"),
    "updateRetryInstall": MessageLookupByLibrary.simpleMessage(
      "Try installation again",
    ),
    "updateSeconds": m102,
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "See full release notes",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage(
      "Show all changes",
    ),
    "updateTitle": MessageLookupByLibrary.simpleMessage("Updates"),
    "updateTransferSpeed": m103,
    "updateVerificationGuard": MessageLookupByLibrary.simpleMessage(
      "A package that fails verification will never be installed.",
    ),
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "The downloaded update failed integrity verification.",
    ),
    "updateVerifyFailedDescription": MessageLookupByLibrary.simpleMessage(
      "The file, version or signature did not pass verification. Download a fresh copy to try again.",
    ),
    "updateVerifyFailedTitle": MessageLookupByLibrary.simpleMessage(
      "This package can\'t be installed",
    ),
    "updateVerifyingDescription": MessageLookupByLibrary.simpleMessage(
      "Checking the file, app version and signing certificate before installation.",
    ),
    "updateVerifyingTitle": MessageLookupByLibrary.simpleMessage(
      "Checking the update",
    ),
    "updateVpnDescription": MessageLookupByLibrary.simpleMessage(
      "Installation will briefly close ReClash. Disconnect only if you\'re ready to interrupt the connection.",
    ),
    "updateVpnInstallNote": MessageLookupByLibrary.simpleMessage(
      "Installation will briefly close the app. Your VPN will not be stopped without your confirmation.",
    ),
    "updateVpnTitle": MessageLookupByLibrary.simpleMessage(
      "Your VPN is still on",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("Upload"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage("Upload bandwidth"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlScheme": MessageLookupByLibrary.simpleMessage("URL scheme"),
    "urlSchemeAction": MessageLookupByLibrary.simpleMessage("Action"),
    "urlSchemeAdd": MessageLookupByLibrary.simpleMessage("Add subscription"),
    "urlSchemeAddDesc": MessageLookupByLibrary.simpleMessage(
      "Create a profile from an HTTP or HTTPS subscription URL, with an optional name.",
    ),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "The encrypted link could not be authenticated. It may be damaged or use a different key.",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("Build link"),
    "urlSchemeBuilderTip": MessageLookupByLibrary.simpleMessage(
      "Only the fields needed by this action are included. Configuration links carry the full content; a link never bypasses confirmation.",
    ),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("Close application"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Follow your close behavior: hide the window or exit ReClash. Android follows its app close behavior.",
    ),
    "urlSchemeConfigCounts": m104,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "Paste a YAML or JSON configuration",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage(
      "Configuration contents",
    ),
    "urlSchemeConfirmMessage": m105,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "External application command",
    ),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "External connection and close commands require confirmation. Finish setup before using connection commands.",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Connect"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Start the connection using the selected profile and your current coverage settings.",
    ),
    "urlSchemeConnection": MessageLookupByLibrary.simpleMessage("Connection"),
    "urlSchemeContentFormat": MessageLookupByLibrary.simpleMessage(
      "Content format",
    ),
    "urlSchemeConversionWarning": MessageLookupByLibrary.simpleMessage(
      "Conversion omits some content. Review and approve these changes during import.",
    ),
    "urlSchemeCopyFailed": MessageLookupByLibrary.simpleMessage(
      "Could not copy the link. Try again.",
    ),
    "urlSchemeCopyLink": MessageLookupByLibrary.simpleMessage("Copy link"),
    "urlSchemeDeliveryError": MessageLookupByLibrary.simpleMessage(
      "Could not deliver the link, or the pending link queue is full. Try again after the current action finishes.",
    ),
    "urlSchemeDisconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
    "urlSchemeDisconnectDesc": MessageLookupByLibrary.simpleMessage(
      "Stop the current connection without changing the selected profile.",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage(
      "Embedded configuration",
    ),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage(
      "Example profile",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage(
      "Import configuration",
    ),
    "urlSchemeImportConfirm": m106,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "Import a UTF-8 configuration carried in the link as Base64, with an optional name.",
    ),
    "urlSchemeInspect": MessageLookupByLibrary.simpleMessage("Inspect link"),
    "urlSchemeInspectHint": MessageLookupByLibrary.simpleMessage(
      "Paste an application or profile link",
    ),
    "urlSchemeInspectTip": MessageLookupByLibrary.simpleMessage(
      "Inspection stays on this device. It does not open a link, download a subscription or import a profile.",
    ),
    "urlSchemeInspectionLimit": MessageLookupByLibrary.simpleMessage(
      "The link structure is valid. Subscription availability and Core validation are checked only during import.",
    ),
    "urlSchemeInspectionResult": MessageLookupByLibrary.simpleMessage(
      "Inspection result",
    ),
    "urlSchemeInstallConfig": MessageLookupByLibrary.simpleMessage(
      "Install configuration",
    ),
    "urlSchemeInstallConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Import a subscription using the install-config link format supported by Clash clients.",
    ),
    "urlSchemeIntro": MessageLookupByLibrary.simpleMessage(
      "Connect ReClash to shortcuts, websites and other apps. Build a ready-to-use link or inspect one before opening it.",
    ),
    "urlSchemeInvalidBase64": MessageLookupByLibrary.simpleMessage(
      "The embedded configuration is not valid UTF-8 Base64 data.",
    ),
    "urlSchemeInvalidLink": MessageLookupByLibrary.simpleMessage(
      "The link is malformed. Check its structure and percent encoding.",
    ),
    "urlSchemeInvalidName": MessageLookupByLibrary.simpleMessage(
      "Use a profile name of up to 64 characters, without control characters.",
    ),
    "urlSchemeInvalidUrl": MessageLookupByLibrary.simpleMessage(
      "Enter a valid HTTP or HTTPS subscription URL.",
    ),
    "urlSchemeMissingPayload": MessageLookupByLibrary.simpleMessage(
      "The link is missing a subscription URL or configuration.",
    ),
    "urlSchemeNoExecution": MessageLookupByLibrary.simpleMessage(
      "No action was executed.",
    ),
    "urlSchemeOpen": MessageLookupByLibrary.simpleMessage("Show application"),
    "urlSchemeOpenDesc": MessageLookupByLibrary.simpleMessage(
      "Bring ReClash to the foreground without changing the connection.",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("Parameters"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "Could not read the clipboard. Paste the link manually.",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage("Link preview"),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "Fill in the required fields to preview the link.",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "A link may contain access tokens or proxy credentials. Share it only with people you trust; ReClash keeps no link history.",
    ),
    "urlSchemeProfileCommandsTip": MessageLookupByLibrary.simpleMessage(
      "Profile commands open the builder. Incoming imports ask for confirmation and keep the existing validation and conversion checks.",
    ),
    "urlSchemeProfiles": MessageLookupByLibrary.simpleMessage("Profiles"),
    "urlSchemeProxyLinks": MessageLookupByLibrary.simpleMessage(
      "Proxy share links",
    ),
    "urlSchemeRecognized": MessageLookupByLibrary.simpleMessage(
      "Link recognized",
    ),
    "urlSchemeSetupRequired": MessageLookupByLibrary.simpleMessage(
      "Finish the connection setup before using external connection commands.",
    ),
    "urlSchemeSupportedLinks": MessageLookupByLibrary.simpleMessage(
      "Supported import links",
    ),
    "urlSchemeSupportedLinksTip": MessageLookupByLibrary.simpleMessage(
      "Clash links, INCY and Happ wrappers, and proxy share links also work in manual import and QR scanning. Unknown encryption versions are rejected.",
    ),
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage(
      "Toggle connection",
    ),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "Connect when stopped; disconnect when running. Confirmation names the actual action.",
    ),
    "urlSchemeTooDeep": MessageLookupByLibrary.simpleMessage(
      "The link contains too many nested wrappers.",
    ),
    "urlSchemeTooLarge": MessageLookupByLibrary.simpleMessage(
      "The link exceeds 4 MB or its embedded configuration exceeds 2 MB.",
    ),
    "urlSchemeUnknownCommand": MessageLookupByLibrary.simpleMessage(
      "This link command is not supported.",
    ),
    "urlSchemeUnsupportedEncryption": MessageLookupByLibrary.simpleMessage(
      "This encryption version is not supported. Request a plain subscription link.",
    ),
    "urlSchemeUseExample": MessageLookupByLibrary.simpleMessage("Use example"),
    "urlSchemeWrappedLinks": MessageLookupByLibrary.simpleMessage(
      "Subscription links, embedded configs and INCY crypt1",
    ),
    "urlTip": m107,
    "useHosts": MessageLookupByLibrary.simpleMessage("Use hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("Use system hosts"),
    "usedShort": MessageLookupByLibrary.simpleMessage("used"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("Used traffic"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "uz": MessageLookupByLibrary.simpleMessage("Uzbek"),
    "value": MessageLookupByLibrary.simpleMessage("Value"),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("Virtual IPv4"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("Vivid"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN-related configuration change detected",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VPN routes all system traffic through VpnService automatically.",
    ),
    "wallpaperBlur": MessageLookupByLibrary.simpleMessage("Blur"),
    "wallpaperCardOpacity": MessageLookupByLibrary.simpleMessage(
      "Card opacity",
    ),
    "wallpaperChoose": MessageLookupByLibrary.simpleMessage("Choose image"),
    "wallpaperDimming": MessageLookupByLibrary.simpleMessage("Dimming"),
    "wallpaperEffects": MessageLookupByLibrary.simpleMessage(
      "Image adjustments",
    ),
    "wallpaperEnabled": MessageLookupByLibrary.simpleMessage(
      "Use custom background",
    ),
    "wallpaperFit": MessageLookupByLibrary.simpleMessage("Image fit"),
    "wallpaperFitContain": MessageLookupByLibrary.simpleMessage("Fit"),
    "wallpaperFitCover": MessageLookupByLibrary.simpleMessage("Fill"),
    "wallpaperFitFill": MessageLookupByLibrary.simpleMessage("Stretch"),
    "wallpaperGalleryHint": MessageLookupByLibrary.simpleMessage(
      "Tap a saved background to use it, or add a new one.",
    ),
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "Horizontal position",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "Choose a valid PNG, JPEG or WebP image.",
    ),
    "wallpaperImageLabel": m108,
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("Framing"),
    "wallpaperLibraryFull": m109,
    "wallpaperOpacity": MessageLookupByLibrary.simpleMessage("Image opacity"),
    "wallpaperReadability": MessageLookupByLibrary.simpleMessage("Readability"),
    "wallpaperRemove": MessageLookupByLibrary.simpleMessage("Remove image"),
    "wallpaperReset": MessageLookupByLibrary.simpleMessage("Reset effects"),
    "wallpaperResetLayout": MessageLookupByLibrary.simpleMessage(
      "Reset framing",
    ),
    "wallpaperSaveError": MessageLookupByLibrary.simpleMessage(
      "Could not save the background. Your previous background has been kept.",
    ),
    "wallpaperScale": MessageLookupByLibrary.simpleMessage("Scale"),
    "wallpaperSelectHint": MessageLookupByLibrary.simpleMessage(
      "PNG, JPEG or WebP · up to 20 MB",
    ),
    "wallpaperTitle": MessageLookupByLibrary.simpleMessage("Custom background"),
    "wallpaperTooLarge": MessageLookupByLibrary.simpleMessage(
      "Choose an image up to 20 MB and 50 megapixels.",
    ),
    "wallpaperUnavailable": MessageLookupByLibrary.simpleMessage(
      "Image unavailable",
    ),
    "wallpaperVerticalPosition": MessageLookupByLibrary.simpleMessage(
      "Vertical position",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV configuration",
    ),
    "webDashboard": MessageLookupByLibrary.simpleMessage("Web dashboard"),
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage(
      "Dashboard access ended",
    ),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "Access is local and authenticated. Opening a dashboard does not change your saved external controller settings. For a browser, end access here when you are finished.",
    ),
    "webDashboardApplyFailed": MessageLookupByLibrary.simpleMessage(
      "Could not apply the dashboard configuration.",
    ),
    "webDashboardArchiveFailed": MessageLookupByLibrary.simpleMessage(
      "The download is not a valid dashboard archive.",
    ),
    "webDashboardAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "The Core rejected the dashboard credentials. Reopen the dashboard.",
    ),
    "webDashboardBrowserAccess": MessageLookupByLibrary.simpleMessage(
      "Browser access stays active until you end it or quit ReClash",
    ),
    "webDashboardBusy": MessageLookupByLibrary.simpleMessage(
      "Another dashboard operation is in progress.",
    ),
    "webDashboardCancelled": MessageLookupByLibrary.simpleMessage(
      "Dashboard operation cancelled.",
    ),
    "webDashboardChecksumFailed": MessageLookupByLibrary.simpleMessage(
      "The dashboard checksum does not match the pinned release.",
    ),
    "webDashboardCoreUnavailable": MessageLookupByLibrary.simpleMessage(
      "The Core is not ready.",
    ),
    "webDashboardDesc": MessageLookupByLibrary.simpleMessage(
      "Manage local web dashboards for the Core",
    ),
    "webDashboardDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Could not download the dashboard. Try again.",
    ),
    "webDashboardDownloading": MessageLookupByLibrary.simpleMessage(
      "Downloading dashboard",
    ),
    "webDashboardEmbeddedAccess": MessageLookupByLibrary.simpleMessage(
      "Access ends when the dashboard closes",
    ),
    "webDashboardEndAccess": MessageLookupByLibrary.simpleMessage(
      "End dashboard access",
    ),
    "webDashboardExtracting": MessageLookupByLibrary.simpleMessage(
      "Extracting dashboard",
    ),
    "webDashboardFiles": MessageLookupByLibrary.simpleMessage(
      "Dashboard files",
    ),
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage(
      "Install dashboard",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "The selected dashboard is downloaded on first open. Downloads use a pinned release and SHA-256 verification.",
    ),
    "webDashboardInstalledVersion": m110,
    "webDashboardLaunchFailed": MessageLookupByLibrary.simpleMessage(
      "Could not open the browser.",
    ),
    "webDashboardNoAccess": MessageLookupByLibrary.simpleMessage(
      "No dashboard session",
    ),
    "webDashboardNoProfile": MessageLookupByLibrary.simpleMessage(
      "Select a profile before opening the dashboard.",
    ),
    "webDashboardNotInstalled": MessageLookupByLibrary.simpleMessage(
      "Not installed",
    ),
    "webDashboardOpen": MessageLookupByLibrary.simpleMessage("Open dashboard"),
    "webDashboardOpenInBrowser": MessageLookupByLibrary.simpleMessage(
      "Open in browser",
    ),
    "webDashboardReload": MessageLookupByLibrary.simpleMessage("Reload"),
    "webDashboardSafeMode": MessageLookupByLibrary.simpleMessage(
      "Dashboard access is disabled in Safe Mode.",
    ),
    "webDashboardStorageFailed": MessageLookupByLibrary.simpleMessage(
      "Could not safely read or replace the dashboard files.",
    ),
    "webDashboardTooLarge": MessageLookupByLibrary.simpleMessage(
      "The dashboard archive exceeds the allowed size.",
    ),
    "webDashboardUnreachable": MessageLookupByLibrary.simpleMessage(
      "The Core is not serving this dashboard.",
    ),
    "webDashboardVerifying": MessageLookupByLibrary.simpleMessage(
      "Verifying download",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Whitelist mode"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("Write to system"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Write to system also sets the system clock; Android ignores it.",
    ),
    "yearsAgo": m111,
    "yearsAgoShort": m112,
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
    "zhCN": MessageLookupByLibrary.simpleMessage("Simplified Chinese"),
  };
}
