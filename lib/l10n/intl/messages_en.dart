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

  static String m0(count) =>
      "Apps your provider keeps out of the VPN: ${count}. Turn on access control to change the list.";

  static String m1(count, skipped) =>
      "${count} to add, ${skipped} skipped as existing";

  static String m2(detail) => "Couldn\'t clear the data: ${detail}";

  static String m3(code) =>
      "Windows refused to run ReClashCore.exe (error ${code}). An app control policy such as Smart App Control or AppLocker blocks unsigned programs; allow ReClash in that policy or turn it off, then try again.";

  static String m4(name) =>
      "The app failed to finish launching twice in a row. To break the loop, the profile ${name} has been deselected and automatic setup was skipped. You can select it again at any time.";

  static String m5(url) => "Do you want to create a profile from ${url}?";

  static String m6(groups) =>
      "Dropped include-all from the proxy groups ${groups}; add the proxies or proxy providers they use";

  static String m7(count, label) =>
      "${Intl.plural(count, one: '1 SUB-RULE rule was dropped, since custom profiles do not support sub-rules', other: '${label} SUB-RULE rules were dropped, since custom profiles do not support sub-rules')}";

  static String m8(message) => "The core cannot parse this proxy: ${message}";

  static String m9(proxy, target) =>
      "${proxy} dials through ${target}, which leads back to ${proxy}, so the dial loops";

  static String m10(name) =>
      "The name ${name} is already used by another proxy or proxy group";

  static String m11(path) =>
      "Proxy groups reference each other in a loop: ${path}";

  static String m12(name) =>
      "The empty fallback must be a proxy, but ${name} does not exist or is a proxy group";

  static String m13(name, message) =>
      "${name} is not a valid regex: ${message}";

  static String m14(name) => "The dialer proxy ${name} does not exist";

  static String m15(names) => "These proxy providers do not exist: ${names}";

  static String m16(names) =>
      "These proxies or policies do not exist: ${names}";

  static String m17(name) =>
      "${name} is a built-in policy name and cannot be used here";

  static String m18(count) =>
      "${count} items have problems, and applying this profile may fail";

  static String m19(count) =>
      "${Intl.plural(count, one: '1 day ago', other: '${count} days ago')}";

  static String m20(count) => "${Intl.plural(count, other: '${count}d ago')}";

  static String m21(label) =>
      "Are you sure you want to delete the selected ${label}?";

  static String m22(label) => "Are you sure you want to delete this ${label}?";

  static String m23(label) => "${label} details";

  static String m24(name) =>
      "Dialing through ${name} leads back to the proxy that uses it, so the connection was stopped";

  static String m25(label) => "${label} cannot be empty";

  static String m26(label) => "${label} already exists";

  static String m27(count) => "${count} items failed";

  static String m28(label, message) => "${label}: ${message}";

  static String m29(name) => "${name} is already up to date";

  static String m30(name) => "${name} updated";

  static String m31(count) =>
      "${Intl.plural(count, one: '1 group', other: '${count} groups')}";

  static String m32(count) => "${count} timed out";

  static String m33(action) =>
      "Already used by “${action}”. Saving moves it here.";

  static String m34(actions) => "Not exported: ${actions}";

  static String m35(modifiers) => "Include at least one of ${modifiers}";

  static String m36(count) =>
      "${Intl.plural(count, one: '1 hour ago', other: '${count} hours ago')}";

  static String m37(count) => "${Intl.plural(count, other: '${count}h ago')}";

  static String m38(target) => "${target} is an invalid policy";

  static String m39(proxyName) => "${proxyName} is an invalid proxy";

  static String m40(providerName) =>
      "${providerName} is an invalid proxy provider";

  static String m41(ruleSet) => "${ruleSet} is an invalid rule set";

  static String m42(subRule) => "${subRule} is an invalid SUB_RULE";

  static String m43(count) =>
      "${Intl.plural(count, one: '1 item', other: '${count} items')}";

  static String m44(line, message) => "Line ${line}: ${message}";

  static String m45(appName) =>
      "1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check ${appName} in the list\n\nWhen you are done, return to the app to continue. Thank you for your cooperation.";

  static String m46(label, max) => "${label} must be at most ${max} characters";

  static String m47(size) => "Released ${size}";

  static String m48(count) =>
      "${Intl.plural(count, one: '1 minute ago', other: '${count} minutes ago')}";

  static String m49(count) => "${Intl.plural(count, other: '${count}m ago')}";

  static String m50(count) =>
      "${Intl.plural(count, one: '1 month ago', other: '${count} months ago')}";

  static String m51(count) => "${Intl.plural(count, other: '${count}mo ago')}";

  static String m52(code) =>
      "The server denied access (HTTP ${code}). The link may have expired, or the credentials are wrong";

  static String m53(code) => "The server rejected the request (HTTP ${code})";

  static String m54(code) =>
      "Nothing was found at this address (HTTP ${code}). Check that the URL is correct";

  static String m55(detail) => "Network request failed: ${detail}";

  static String m56(code) =>
      "The server ran into a problem (HTTP ${code}). Try again later";

  static String m57(label) => "No ${label} yet";

  static String m58(label, min, max) =>
      "${label} must be between ${min} and ${max}";

  static String m59(label) => "${label} must be a number";

  static String m60(label) => "${label} must be between 1024 and 49151";

  static String m61(port) => "Port ${port}";

  static String m62(added, skipped, failed) =>
      "Added: ${added}; skipped: ${skipped}; failed: ${failed}.";

  static String m63(days) =>
      "${Intl.plural(days, one: '1 day left', other: '${days} days left')}";

  static String m64(date, days) =>
      "Expires ${date}, ${Intl.plural(days, one: '1 day', other: '${days} days')} left";

  static String m65(name) => "Already added as “${name}”";

  static String m66(client) => "As the ${client} app receives it";

  static String m67(count) =>
      "${Intl.plural(count, one: '1 server', other: '${count} servers')}";

  static String m68(time) => "Updated ${time}";

  static String m69(label, profiles) =>
      "${label} is still used by ${profiles}, which will not work properly once it is deleted. Are you sure you want to delete it?";

  static String m70(count, label) =>
      "${Intl.plural(count, one: '1 proxy', other: '${label} proxies')}";

  static String m71(name, count) => "${name} and others (${count} proxies)";

  static String m72(removed) =>
      "These proxies will be deleted: ${removed}. A line whose name changed counts as a new proxy, and custom profiles naming the deleted ones will flag them as missing. Apply anyway?";

  static String m73(removed, added) =>
      "These proxies will be deleted: ${removed}. These will be added: ${added}. A line whose name changed counts as a new proxy, and custom profiles naming the deleted ones will flag them as missing. Apply anyway?";

  static String m74(label) =>
      "${label} is still named by rules, proxy groups, dialer proxies, DNS or NTP in this profile, which stop working once it is deleted. Are you sure you want to delete it?";

  static String m75(count, label) =>
      "${Intl.plural(count, one: '1 proxy group', other: '${label} proxy groups')}";

  static String m76(pick, now) => "Would pick ${pick} instead of ${now}";

  static String m77(group) => "Check on ${group}";

  static String m78(pick) => "Would keep ${pick}";

  static String m79(number) => "Condition ${number}";

  static String m80(profile) => "“${profile}” wants to check these sites";

  static String m81(profile) => "Delete “${profile}”?";

  static String m82(requests, used, cap) =>
      "Checks today: ${requests} · ${used} of ${cap}";

  static String m83(condition) => "except ${condition}";

  static String m84(country) => "exit ${country}";

  static String m85(member) => "Through ${member}";

  static String m86(profile) => "Added “${profile}”";

  static String m87(node) => "${node} stopped working";

  static String m88(from, to) => "Mode ${from} → ${to}";

  static String m89(line, text) => "Line ${line}: ${text}";

  static String m90(check) => "Check ${check} is never used, so it never runs";

  static String m91(hosts) => "Contacts third-party sites: ${hosts}";

  static String m92(group) => "This config has no group ${group}";

  static String m93(group) => "No server of ${group} passes the filter";

  static String m94(tag) => "Tag ${tag} is never used";

  static String m95(tier, group) =>
      "No server of ${group} is in “${tier}” right now";

  static String m96(tier, after) =>
      "“${tier}” repeats the condition of “${after}”, so nothing lands in it";

  static String m97(keys) =>
      "Brought over; you changed these too, so yours were kept: ${keys}";

  static String m98(mode) => "Mode: ${mode}";

  static String m99(kind) => "Network: ${kind}";

  static String m100(tier) => "may reach “${tier}” after a check";

  static String m101(node) => "Pinned: ${node}";

  static String m102(error) => "Profile error: ${error}";

  static String m103(profile) =>
      "Profile ${profile} was not found; the default is used";

  static String m104(error) => "Routing state could not be saved: ${error}";

  static String m105(tier) => "Moved to a server in “${tier}”";

  static String m106(from) =>
      "Changed server; ${from} is skipped for 15 minutes";

  static String m107(from) =>
      "${from} stopped working; switched to the best standby";

  static String m108(from, gain) => "Switched from ${from}: ${gain} ms faster";

  static String m109(node) => "The scenario holds ${node}";

  static String m110(node) => "${node} is not in this group";

  static String m111(limit) => "Switch limit reached (${limit} per hour)";

  static String m112(mode) => "Not in use: mode ${mode}";

  static String m113(from) => "${from} is no longer in the pool";

  static String m114(kind) =>
      "Paused while the network is “${kind}”: nothing is checked or switched";

  static String m115(node) => "The scenario moves to ${node}";

  static String m116(node) => "Switched to the pinned server ${node}";

  static String m117(node) => "No working server; fell back to ${node}";

  static String m118(scenario) =>
      "The scenario «${scenario}» drives this group now.";

  static String m119(count, total) => "${count} of ${total} match";

  static String m120(node) => "Will switch to ${node} once a check confirms it";

  static String m121(node, gain) =>
      "Will switch to ${node} if it stays ${gain} ms faster";

  static String m122(node, minutes) =>
      "May switch to ${node} in ${minutes} min";

  static String m123(name) => "check ${name}";

  static String m124(name) => "network diagnostic ${name}";

  static String m125(region, bypassed, proxied) =>
      "${region}: ${bypassed} apps in the VPN bypass list, ${proxied} in the VPN list. Both lists will be replaced; the mode and other settings stay unchanged. Package and SDK matches are suggestions: review them after applying.";

  static String m126(seconds) => "You can confirm in ${seconds} s";

  static String m127(count, label) =>
      "${Intl.plural(count, one: '1 rule', other: '${label} rules')}";

  static String m128(appName) => "${appName} (Safe mode)";

  static String m129(count) =>
      "${Intl.plural(count, one: '1 second', other: '${count} seconds')}";

  static String m130(count) => "${count} in effect";

  static String m131(count) =>
      "${Intl.plural(count, one: '1 issue', other: '${count} issues')}";

  static String m132(time) => "Checked at ${time}";

  static String m133(count) =>
      "${Intl.plural(count, one: '1 setting', other: '${count} settings')}";

  static String m134(count) => "Apps that bypass the VPN: ${count}";

  static String m135(count) => "${count} profiles available";

  static String m136(step, total) => "${step} of ${total}";

  static String m137(server) => "Try ${server}";

  static String m138(link) => "No proxy could be read from ${link}";

  static String m139(label) => "${label} must be a single item";

  static String m140(client, format, count) =>
      "Received as ${client}: ${format}, ${count} proxy nodes.";

  static String m141(count) =>
      "Your subscription expires in ${Intl.plural(count, one: '1 day', other: '${count} days')}";

  static String m142(sections) =>
      "The following source sections will not be transferred: ${sections}.";

  static String m143(count, format) =>
      "${count} proxy nodes can be imported from ${format}.";

  static String m144(count) => "${count} nodes cannot be converted.";

  static String m145(percent) => "You have used ${percent}% of your traffic";

  static String m146(count) => "${count} results";

  static String m147(value) => "Peak ${value}";

  static String m148(value) => "Total ${value}";

  static String m149(version) => "Installed: ${version}";

  static String m150(count) =>
      "${Intl.plural(count, one: '1 min', other: '${count} min')}";

  static String m151(time) => "${time} remaining";

  static String m152(count) =>
      "${Intl.plural(count, one: '1 sec', other: '${count} sec')}";

  static String m153(speed) => "${speed}/s";

  static String m154(nodes, groups, providers) =>
      "${nodes} proxies, ${groups} groups, ${providers} remote providers";

  static String m155(action) =>
      "This link requests “${action}”. Allow ReClash to perform this action?";

  static String m156(name, source) =>
      "Import “${name}” from ${source}? Profile validation and any conversion review follow your confirmation.";

  static String m157(label) => "${label} must be a URL";

  static String m158(index) => "Background ${index}";

  static String m159(count) =>
      "You can keep up to ${count} backgrounds. Remove one to add another.";

  static String m160(count) =>
      "${Intl.plural(count, one: '1 year ago', other: '${count} years ago')}";

  static String m161(count) => "${Intl.plural(count, other: '${count}y ago')}";

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
    "accessProviderDisabledDesc": m0,
    "accessReturnToProvider": MessageLookupByLibrary.simpleMessage(
      "Return apps to provider",
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
    "addNetwork": MessageLookupByLibrary.simpleMessage("Add network"),
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
    "appIcon": MessageLookupByLibrary.simpleMessage("App icon"),
    "appIconApply": MessageLookupByLibrary.simpleMessage("Use this icon"),
    "appIconBlueprint": MessageLookupByLibrary.simpleMessage("Blueprint"),
    "appIconChangeNote": MessageLookupByLibrary.simpleMessage(
      "The home screen may take a few seconds to show the new icon, and some launchers remove the shortcut — add it again from the app list.",
    ),
    "appIconCircuit": MessageLookupByLibrary.simpleMessage("Circuit"),
    "appIconDesign": MessageLookupByLibrary.simpleMessage("App icon design"),
    "appIconEcho": MessageLookupByLibrary.simpleMessage("Echo"),
    "appIconInk": MessageLookupByLibrary.simpleMessage("Ink"),
    "appIconShatter": MessageLookupByLibrary.simpleMessage("Shatter"),
    "appIconSolar": MessageLookupByLibrary.simpleMessage("Solar"),
    "appIconSpark": MessageLookupByLibrary.simpleMessage("Spark"),
    "appIconStandard": MessageLookupByLibrary.simpleMessage("Standard"),
    "appIconStrata": MessageLookupByLibrary.simpleMessage("Strata"),
    "appIconTopo": MessageLookupByLibrary.simpleMessage("Topo"),
    "appIconTrace": MessageLookupByLibrary.simpleMessage("Trace"),
    "appIconVelvet": MessageLookupByLibrary.simpleMessage("Velvet"),
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
    "batchPreviewTip": m1,
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
    "clearDataFailed": m2,
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
    "closeConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Drop every open connection when the VPN pauses",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Color"),
    "colorContrast": MessageLookupByLibrary.simpleMessage("Contrast"),
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
    "contrastHigh": MessageLookupByLibrary.simpleMessage("High"),
    "contrastMedium": MessageLookupByLibrary.simpleMessage("Medium"),
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
    "coreBlockedByPolicyTip": m3,
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
    "crashDetectedTip": m4,
    "crashTest": MessageLookupByLibrary.simpleMessage("Crash test"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createProfileFromUrlTip": m5,
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
    "customImportDroppedIncludeAll": m6,
    "customImportDroppedSubRules": m7,
    "customIssueCoreRejected": m8,
    "customIssueDialerLoop": m9,
    "customIssueDuplicateName": m10,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage(
      "The name is empty",
    ),
    "customIssueGroupLoop": m11,
    "customIssueInvalidEmptyFallback": m12,
    "customIssueInvalidFilter": m13,
    "customIssueMissingDialer": m14,
    "customIssueMissingProviders": m15,
    "customIssueMissingProxies": m16,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "No proxies or proxy providers are selected, so the core rejects this group",
    ),
    "customIssueReservedName": m17,
    "customIssuesSummary": m18,
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
    "daysAgo": m19,
    "daysAgoShort": m20,
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
    "deleteMultipTip": m21,
    "deleteTip": m22,
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
    "details": m23,
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
    "dialerProxyLoopStopped": m24,
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
    "dnsRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "All DNS overrides are removed, and the DNS servers of the selected region are set again.",
    ),
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
    "editNetwork": MessageLookupByLibrary.simpleMessage("Edit network"),
    "editProxy": MessageLookupByLibrary.simpleMessage("Edit proxy"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("Edit proxy group"),
    "editRule": MessageLookupByLibrary.simpleMessage("Edit rule"),
    "editSsid": MessageLookupByLibrary.simpleMessage("Edit SSID"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Editor unavailable",
    ),
    "elapsed": MessageLookupByLibrary.simpleMessage("Took"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage("Empty fallback"),
    "emptyTip": m25,
    "en": MessageLookupByLibrary.simpleMessage("English"),
    "enabled": MessageLookupByLibrary.simpleMessage("Enabled"),
    "enterManually": MessageLookupByLibrary.simpleMessage("Enter manually"),
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
    "existsTip": m26,
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
    "extra": MessageLookupByLibrary.simpleMessage("Extra"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("Extra large"),
    "fade": MessageLookupByLibrary.simpleMessage("Fade"),
    "failedCount": m27,
    "failedItem": m28,
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
    "geoSkipped": m29,
    "geoUpdated": m30,
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
    "groupCount": m31,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("groups"),
    "groupTimeoutCount": m32,
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
    "hotkeyConflictWith": m33,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Global hotkeys work even while the window is hidden. Tap an action to record its key combination.",
    ),
    "hotkeyDesktopCommands": MessageLookupByLibrary.simpleMessage(
      "Desktop shortcuts",
    ),
    "hotkeyDesktopCommandsDesc": MessageLookupByLibrary.simpleMessage(
      "Assign a command to a custom shortcut in your desktop settings. ReClash must be running, but its window can stay hidden. Manage these global bindings in your desktop settings.",
    ),
    "hotkeyExportSkipped": m34,
    "hotkeyExportUnavailable": MessageLookupByLibrary.simpleMessage(
      "Compositor configuration files are unavailable. You can still use the desktop commands above.",
    ),
    "hotkeyLocalDesc": MessageLookupByLibrary.simpleMessage(
      "These combinations work while the app window is focused. For global shortcuts, connect desktop commands using the section below.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Hotkey management",
    ),
    "hotkeyNeedsModifier": m35,
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
    "hoursAgo": m36,
    "hoursAgoShort": m37,
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
    "invalidPolicy": m38,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "Enter a port or a range such as 443 or 8000-9000",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "This QR code doesn\'t contain a profile link",
    ),
    "invalidProxy": m39,
    "invalidProxyProvider": m40,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "Enter numbers or ranges such as 80 or 8000-9000, separated by /",
    ),
    "invalidRuleSet": m41,
    "invalidSsid": MessageLookupByLibrary.simpleMessage(
      "An SSID cannot exceed 32 UTF-8 bytes",
    ),
    "invalidSubRule": m42,
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
    "itemsCount": m43,
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
    "lineIssueTip": m44,
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
    "locationPermissionGuide": m45,
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
    "maxLengthTip": m46,
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
    "memoryReleasedSize": m47,
    "messageTest": MessageLookupByLibrary.simpleMessage("Message test"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "This is a message.",
    ),
    "minimize": MessageLookupByLibrary.simpleMessage("Minimize"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("Minimize on exit"),
    "minutes": MessageLookupByLibrary.simpleMessage("minutes"),
    "minutesAgo": m48,
    "minutesAgoShort": m49,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixed port"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "monthsAgo": m50,
    "monthsAgoShort": m51,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("Bottom bar"),
    "navigationLabels": MessageLookupByLibrary.simpleMessage("Tab labels"),
    "navigationLabelsAlways": MessageLookupByLibrary.simpleMessage("Always"),
    "navigationLabelsNever": MessageLookupByLibrary.simpleMessage("Never"),
    "navigationLabelsSelected": MessageLookupByLibrary.simpleMessage(
      "Selected",
    ),
    "navigationLayout": MessageLookupByLibrary.simpleMessage("Navigation"),
    "navigationLayoutBar": MessageLookupByLibrary.simpleMessage("Tab bar"),
    "navigationLayoutSidebar": MessageLookupByLibrary.simpleMessage("Sidebar"),
    "network": MessageLookupByLibrary.simpleMessage("Network"),
    "networkAccessDeniedError": m52,
    "networkBadResponseError": m53,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "The request was cancelled",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t connect to the server. Check your network connection or proxy settings",
    ),
    "networkEntryHint": MessageLookupByLibrary.simpleMessage(
      "SSID (Home Wi-Fi) or subnet (192.168.1.0/24)",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t resolve the server address. Check that the URL is correct and DNS is working",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("Network name"),
    "networkNotFoundError": m54,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Too many requests (HTTP 429). Wait a moment and try again",
    ),
    "networkRequestFailed": m55,
    "networkRestoreDefaultsTip": MessageLookupByLibrary.simpleMessage(
      "The bypass list and TUN MTU return to the defaults of the selected region.",
    ),
    "networkSecret": MessageLookupByLibrary.simpleMessage("Network secret"),
    "networkServerError": m56,
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
    "notTrustedNow": MessageLookupByLibrary.simpleMessage(
      "Current network is not trusted",
    ),
    "notification": MessageLookupByLibrary.simpleMessage("Notification"),
    "notificationActive": MessageLookupByLibrary.simpleMessage(
      "Protection active",
    ),
    "notificationAddComponent": MessageLookupByLibrary.simpleMessage(
      "Add component",
    ),
    "notificationAutomaticGroup": MessageLookupByLibrary.simpleMessage(
      "Automatic group",
    ),
    "notificationBlockedNoServerGroup": MessageLookupByLibrary.simpleMessage(
      "No server group is resolved, so this line is hidden",
    ),
    "notificationComponents": MessageLookupByLibrary.simpleMessage(
      "Notification components",
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
    "notificationContent": MessageLookupByLibrary.simpleMessage("Content"),
    "notificationCurrentServer": MessageLookupByLibrary.simpleMessage(
      "Current server",
    ),
    "notificationDelivery": MessageLookupByLibrary.simpleMessage(
      "Android delivery",
    ),
    "notificationDeliveryChecking": MessageLookupByLibrary.simpleMessage(
      "Checking Android notification access",
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
    "notificationHideIdleSpeed": MessageLookupByLibrary.simpleMessage(
      "Hide idle speed",
    ),
    "notificationHideSensitive": MessageLookupByLibrary.simpleMessage(
      "Hide sensitive details on lock screen",
    ),
    "notificationHideSensitiveDesc": MessageLookupByLibrary.simpleMessage(
      "Uses Android\'s lock-screen privacy settings for service notifications and reminders. Details remain visible while unlocked.",
    ),
    "notificationLevelDescription": MessageLookupByLibrary.simpleMessage(
      "Detailed shows live information and the stop button. Minimal shows only protection status.",
    ),
    "notificationNetworkSpeed": MessageLookupByLibrary.simpleMessage(
      "Network speed",
    ),
    "notificationPrivacy": MessageLookupByLibrary.simpleMessage("Privacy"),
    "notificationReminders": MessageLookupByLibrary.simpleMessage("Reminders"),
    "notificationServerGroupMissing": MessageLookupByLibrary.simpleMessage(
      "The chosen group is missing from the profile",
    ),
    "notificationServiceChannel": MessageLookupByLibrary.simpleMessage(
      "Service channel",
    ),
    "notificationSessionTraffic": MessageLookupByLibrary.simpleMessage(
      "Session traffic",
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
    "notificationVisibilityDetailed": MessageLookupByLibrary.simpleMessage(
      "Detailed",
    ),
    "notificationVisibilityMinimal": MessageLookupByLibrary.simpleMessage(
      "Minimal",
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
    "nullTip": m57,
    "numberRangeTip": m58,
    "numberTip": m59,
    "obfs": MessageLookupByLibrary.simpleMessage("Obfuscation"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("Obfuscation host"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("Obfuscation mode"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("Obfuscation parameter"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage(
      "Obfuscation password",
    ),
    "onDemand": MessageLookupByLibrary.simpleMessage("On demand"),
    "onDemandBroadNetwork": MessageLookupByLibrary.simpleMessage(
      "This subnet trusts a wide range of networks",
    ),
    "onDemandCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Close connections",
    ),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "On demand pauses the proxy on excluded Wi-Fi.",
    ),
    "onDemandFullStop": MessageLookupByLibrary.simpleMessage("Full stop"),
    "onDemandFullStopDesc": MessageLookupByLibrary.simpleMessage(
      "Remove TUN and close local proxy ports while paused. The app keeps watching the network to resume automatically.",
    ),
    "onDemandPause": MessageLookupByLibrary.simpleMessage("Pause"),
    "onDemandResume": MessageLookupByLibrary.simpleMessage("Resume"),
    "onDemandScanFailed": MessageLookupByLibrary.simpleMessage(
      "Could not read Wi-Fi networks. Retry or enter a network manually.",
    ),
    "onDemandStrict": MessageLookupByLibrary.simpleMessage(
      "Require SSID and subnet together",
    ),
    "onDemandStrictDesc": MessageLookupByLibrary.simpleMessage(
      "When both kinds of rules exist, pause only if an SSID and a subnet both match",
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
    "pickNetworkPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Allow location access to see nearby Wi-Fi networks, or enter a network manually.",
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
    "plugin": MessageLookupByLibrary.simpleMessage("Plugin"),
    "pluginHost": MessageLookupByLibrary.simpleMessage("Plugin host"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("Plugin mode"),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a different port",
    ),
    "portHopping": MessageLookupByLibrary.simpleMessage("Port hopping"),
    "portTip": m60,
    "portValue": m61,
    "ports": MessageLookupByLibrary.simpleMessage("Ports"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("Pre-shared key"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Prerequisites"),
    "pressBackAgainToExit": MessageLookupByLibrary.simpleMessage(
      "Press back again to exit",
    ),
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
    "profileBatchResult": m62,
    "profileDaysLeft": m63,
    "profileExpiresIn": m64,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "The profile has been modified. Turn off auto update?",
    ),
    "profileImportAlreadyAdded": m65,
    "profileImportChecking": MessageLookupByLibrary.simpleMessage(
      "Loading subscription page…",
    ),
    "profileImportDuplicate": MessageLookupByLibrary.simpleMessage(
      "A profile with this subscription URL already exists",
    ),
    "profileImportEncrypted": MessageLookupByLibrary.simpleMessage(
      "The subscription is encrypted; you’ll be asked for the key when adding it.",
    ),
    "profileImportExpired": MessageLookupByLibrary.simpleMessage("Expired"),
    "profileImportFormat": MessageLookupByLibrary.simpleMessage(
      "Subscription format",
    ),
    "profileImportFormatClient": m66,
    "profileImportFormatReclash": MessageLookupByLibrary.simpleMessage(
      "The best format for ReClash, picked automatically",
    ),
    "profileImportFromProvider": MessageLookupByLibrary.simpleMessage(
      "From the provider",
    ),
    "profileImportLosses": MessageLookupByLibrary.simpleMessage(
      "Some parts aren’t supported; you’ll review them before adding.",
    ),
    "profileImportPreviewFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn’t load the subscription page. You can still add it.",
    ),
    "profileImportServerCount": m67,
    "profileImportServers": MessageLookupByLibrary.simpleMessage("Servers"),
    "profileImportSingleServer": MessageLookupByLibrary.simpleMessage(
      "Single server",
    ),
    "profileImportTitle": MessageLookupByLibrary.simpleMessage(
      "New subscription",
    ),
    "profileImportUnlimited": MessageLookupByLibrary.simpleMessage("Unlimited"),
    "profileImportValidUntil": MessageLookupByLibrary.simpleMessage(
      "Valid until",
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
    "profileUpdatedAt": m68,
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
    "providerAnnouncement": MessageLookupByLibrary.simpleMessage(
      "Announcement",
    ),
    "providerAnnouncementOpen": MessageLookupByLibrary.simpleMessage(
      "Learn more",
    ),
    "providerInUse": m69,
    "providerNotice": MessageLookupByLibrary.simpleMessage("Notice"),
    "providerSettingManaged": MessageLookupByLibrary.simpleMessage(
      "From provider",
    ),
    "providerSettingReturn": MessageLookupByLibrary.simpleMessage(
      "Return to provider",
    ),
    "providerSettingsReturnAll": MessageLookupByLibrary.simpleMessage(
      "Return settings to provider",
    ),
    "providerSettingsReturnAllDesc": MessageLookupByLibrary.simpleMessage(
      "Settings you changed follow the subscription again",
    ),
    "providerUrlTip": MessageLookupByLibrary.simpleMessage(
      "Only remote providers are supported",
    ),
    "providers": MessageLookupByLibrary.simpleMessage("External resources"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxiesCount": m70,
    "proxiesProfileLabel": m71,
    "proxiesRemovedTip": m72,
    "proxiesReplacedTip": m73,
    "proxyChains": MessageLookupByLibrary.simpleMessage("Proxy chain"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proxy group"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy group is empty",
    ),
    "proxyGroupInUse": m74,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "Groups show up here once the core starts",
    ),
    "proxyGroupsCount": m75,
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
    "rcxAddGroup": MessageLookupByLibrary.simpleMessage("Add group"),
    "rcxAddKind": MessageLookupByLibrary.simpleMessage("Add network kind"),
    "rcxAddPool": MessageLookupByLibrary.simpleMessage("Add a pattern"),
    "rcxAddTag": MessageLookupByLibrary.simpleMessage("Add tag"),
    "rcxAddTier": MessageLookupByLibrary.simpleMessage("Add tier"),
    "rcxAdvanced": MessageLookupByLibrary.simpleMessage("Advanced"),
    "rcxAdvancedHint": MessageLookupByLibrary.simpleMessage(
      "These parts are edited as YAML.",
    ),
    "rcxAllGroups": MessageLookupByLibrary.simpleMessage("Every group"),
    "rcxAnyServer": MessageLookupByLibrary.simpleMessage("Any"),
    "rcxAutoControl": MessageLookupByLibrary.simpleMessage("Auto control"),
    "rcxAutoControlHint": MessageLookupByLibrary.simpleMessage(
      "A scenario steers the whole connection: the mode on each kind of network and what every group does. Groups it does not name keep their own profile.",
    ),
    "rcxBackToAuto": MessageLookupByLibrary.simpleMessage("Back to auto"),
    "rcxBalanced": MessageLookupByLibrary.simpleMessage("Balanced"),
    "rcxBasedOn": MessageLookupByLibrary.simpleMessage("Based on"),
    "rcxBehaviour": MessageLookupByLibrary.simpleMessage("Behaviour"),
    "rcxBringChanges": MessageLookupByLibrary.simpleMessage(
      "Bring changes over",
    ),
    "rcxBringChangesHint": MessageLookupByLibrary.simpleMessage(
      "Your own edits stay as they are",
    ),
    "rcxChangeServer": MessageLookupByLibrary.simpleMessage("Change server"),
    "rcxChangeTo": MessageLookupByLibrary.simpleMessage("Change to"),
    "rcxCheck": MessageLookupByLibrary.simpleMessage("Check"),
    "rcxCheckDifferent": m76,
    "rcxCheckGroup": MessageLookupByLibrary.simpleMessage("Against group"),
    "rcxCheckNone": MessageLookupByLibrary.simpleMessage(
      "Would find no server",
    ),
    "rcxCheckOn": m77,
    "rcxCheckOpen": MessageLookupByLibrary.simpleMessage("opens blocked"),
    "rcxCheckSame": m78,
    "rcxChecks": MessageLookupByLibrary.simpleMessage("Checks"),
    "rcxChecksDeclared": MessageLookupByLibrary.simpleMessage(
      "Availability checks",
    ),
    "rcxCondAdd": MessageLookupByLibrary.simpleMessage("Add condition"),
    "rcxCondAll": MessageLookupByLibrary.simpleMessage("All conditions"),
    "rcxCondAlways": MessageLookupByLibrary.simpleMessage("Always"),
    "rcxCondAny": MessageLookupByLibrary.simpleMessage("Any condition"),
    "rcxCondAnyServer": MessageLookupByLibrary.simpleMessage("Any server"),
    "rcxCondClause": m79,
    "rcxCondField": MessageLookupByLibrary.simpleMessage("Field"),
    "rcxCondIgnoreCase": MessageLookupByLibrary.simpleMessage("Ignore case"),
    "rcxCondMatch": MessageLookupByLibrary.simpleMessage("Match"),
    "rcxCondNoNames": MessageLookupByLibrary.simpleMessage("None declared"),
    "rcxCondNotPrefix": MessageLookupByLibrary.simpleMessage("not"),
    "rcxCondOp": MessageLookupByLibrary.simpleMessage("Operator"),
    "rcxCondPattern": MessageLookupByLibrary.simpleMessage("Pattern"),
    "rcxCondText": MessageLookupByLibrary.simpleMessage("As text"),
    "rcxCondTooComplex": MessageLookupByLibrary.simpleMessage(
      "This condition nests groups, so it is edited as text.",
    ),
    "rcxCondValue": MessageLookupByLibrary.simpleMessage("Value"),
    "rcxCondValues": MessageLookupByLibrary.simpleMessage(
      "Values, comma-separated",
    ),
    "rcxConsentAllow": MessageLookupByLibrary.simpleMessage("Allow"),
    "rcxConsentAsk": m80,
    "rcxConsentHint": MessageLookupByLibrary.simpleMessage(
      "Until you allow it, the group runs the Simple profile. The sites are contacted only through your servers or to test the network.",
    ),
    "rcxConsentTitle": MessageLookupByLibrary.simpleMessage(
      "Permission needed",
    ),
    "rcxContacts": MessageLookupByLibrary.simpleMessage("Sites it contacts"),
    "rcxContactsHint": MessageLookupByLibrary.simpleMessage(
      "Third-party sites belong neither to your provider nor to the built-in profiles.",
    ),
    "rcxControl": MessageLookupByLibrary.simpleMessage("Control"),
    "rcxDeleteProfile": m81,
    "rcxDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Network diagnostics",
    ),
    "rcxDirectSplit": MessageLookupByLibrary.simpleMessage(
      "Direct sites through this group",
    ),
    "rcxDirectSplitActive": MessageLookupByLibrary.simpleMessage("On now"),
    "rcxDirectSplitHint": MessageLookupByLibrary.simpleMessage(
      "When sites your rules send direct stop opening, they go through this group. Local addresses always stay direct.",
    ),
    "rcxDirectSplitStandby": MessageLookupByLibrary.simpleMessage(
      "Ready: direct sites still open",
    ),
    "rcxDuplicate": MessageLookupByLibrary.simpleMessage("Duplicate and edit"),
    "rcxEnergyEco": MessageLookupByLibrary.simpleMessage("Economical"),
    "rcxEnergyPrecise": MessageLookupByLibrary.simpleMessage("Precise"),
    "rcxEnergyToday": m82,
    "rcxExcept": m83,
    "rcxExcludedByProfile": MessageLookupByLibrary.simpleMessage(
      "Excluded by the profile",
    ),
    "rcxExcludedCooldown": MessageLookupByLibrary.simpleMessage(
      "Skipped after “Change server”",
    ),
    "rcxExcludedNoMatch": MessageLookupByLibrary.simpleMessage(
      "Not in the pool",
    ),
    "rcxExcludedNoTier": MessageLookupByLibrary.simpleMessage(
      "Matches no preference",
    ),
    "rcxExcludedPending": MessageLookupByLibrary.simpleMessage(
      "Not checked yet",
    ),
    "rcxExcludedUnroutable": MessageLookupByLibrary.simpleMessage(
      "Not a server",
    ),
    "rcxExit": m84,
    "rcxExitCheck": MessageLookupByLibrary.simpleMessage("Exit-country check"),
    "rcxExport": MessageLookupByLibrary.simpleMessage("Export"),
    "rcxFeelCalm": MessageLookupByLibrary.simpleMessage("Rarely"),
    "rcxFeelEager": MessageLookupByLibrary.simpleMessage("Often"),
    "rcxFieldAlive": MessageLookupByLibrary.simpleMessage("Working"),
    "rcxFieldCurrent": MessageLookupByLibrary.simpleMessage("In use"),
    "rcxFieldDead": MessageLookupByLibrary.simpleMessage("Not working"),
    "rcxFieldDiag": MessageLookupByLibrary.simpleMessage("Network diagnostic"),
    "rcxFieldEntry": MessageLookupByLibrary.simpleMessage("Entry country"),
    "rcxFieldExit": MessageLookupByLibrary.simpleMessage("Exit country"),
    "rcxFieldFails": MessageLookupByLibrary.simpleMessage("Fails check"),
    "rcxFieldKind": MessageLookupByLibrary.simpleMessage("Network kind"),
    "rcxFieldLatency": MessageLookupByLibrary.simpleMessage("Latency, ms"),
    "rcxFieldMeasured": MessageLookupByLibrary.simpleMessage("Measured"),
    "rcxFieldMetered": MessageLookupByLibrary.simpleMessage("Metered network"),
    "rcxFieldName": MessageLookupByLibrary.simpleMessage("Name"),
    "rcxFieldPasses": MessageLookupByLibrary.simpleMessage("Passes check"),
    "rcxFieldPortal": MessageLookupByLibrary.simpleMessage("Sign-in page"),
    "rcxFieldProvider": MessageLookupByLibrary.simpleMessage("Provider"),
    "rcxFieldServer": MessageLookupByLibrary.simpleMessage("Server address"),
    "rcxFieldTag": MessageLookupByLibrary.simpleMessage("Tag"),
    "rcxFieldTransport": MessageLookupByLibrary.simpleMessage(
      "Connection type",
    ),
    "rcxFieldType": MessageLookupByLibrary.simpleMessage("Protocol"),
    "rcxFieldUdp": MessageLookupByLibrary.simpleMessage("Supports UDP"),
    "rcxFixedHint": MessageLookupByLibrary.simpleMessage(
      "The whole group goes through this member with no server search; pick a load balancer or a nested group to hand it everything.",
    ),
    "rcxFixedOn": m85,
    "rcxGeneral": MessageLookupByLibrary.simpleMessage("General"),
    "rcxGroupProfiles": MessageLookupByLibrary.simpleMessage("Group profiles"),
    "rcxGroupProfilesHint": MessageLookupByLibrary.simpleMessage(
      "How a smart group picks its server. Tap one of yours to edit it, any other to edit a copy.",
    ),
    "rcxHealthAlive": MessageLookupByLibrary.simpleMessage("Working"),
    "rcxHealthDead": MessageLookupByLibrary.simpleMessage("Not working"),
    "rcxHealthStale": MessageLookupByLibrary.simpleMessage("Worked before"),
    "rcxHealthUnknown": MessageLookupByLibrary.simpleMessage("Not checked"),
    "rcxHistory": MessageLookupByLibrary.simpleMessage("History"),
    "rcxHistoryVersions": MessageLookupByLibrary.simpleMessage(
      "Earlier versions",
    ),
    "rcxImportAdd": MessageLookupByLibrary.simpleMessage("Add to my profiles"),
    "rcxImportNeedsCore": MessageLookupByLibrary.simpleMessage(
      "Start the app\'s core to check this profile.",
    ),
    "rcxImportTitle": MessageLookupByLibrary.simpleMessage(
      "Import routing profile",
    ),
    "rcxImported": m86,
    "rcxJournalFailure": m87,
    "rcxJournalMode": m88,
    "rcxKindChecking": MessageLookupByLibrary.simpleMessage("checking"),
    "rcxKindGroupsHint": MessageLookupByLibrary.simpleMessage(
      "On this network these replace the scenario\'s groups of the same name; the others work as on every network.",
    ),
    "rcxKindName": MessageLookupByLibrary.simpleMessage("Name"),
    "rcxKindNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Lowercase Latin letters, digits and dashes, up to 24",
    ),
    "rcxKindOpen": MessageLookupByLibrary.simpleMessage("open internet"),
    "rcxKindPortal": MessageLookupByLibrary.simpleMessage("sign-in page"),
    "rcxKindWhen": MessageLookupByLibrary.simpleMessage("Recognized when"),
    "rcxKindWhenHint": MessageLookupByLibrary.simpleMessage(
      "Kinds are tried top to bottom; the network gets the first that holds.",
    ),
    "rcxKindWhitelist": MessageLookupByLibrary.simpleMessage("whitelists only"),
    "rcxLastResort": MessageLookupByLibrary.simpleMessage("Last resort"),
    "rcxLastResortHint": MessageLookupByLibrary.simpleMessage(
      "A last-resort tier is used only when no better tier has a server.",
    ),
    "rcxLevel": MessageLookupByLibrary.simpleMessage("Level"),
    "rcxLevelAdvanced": MessageLookupByLibrary.simpleMessage("Advanced"),
    "rcxLevelSimple": MessageLookupByLibrary.simpleMessage("Simple"),
    "rcxLine": m89,
    "rcxLintCheckUnused": m90,
    "rcxLintConsent": m91,
    "rcxLintGroupMissing": m92,
    "rcxLintPoolEmpty": m93,
    "rcxLintTagUnused": m94,
    "rcxLintTierEmpty": m95,
    "rcxLintTierUnreachable": m96,
    "rcxMainGroup": MessageLookupByLibrary.simpleMessage("Main group"),
    "rcxMakeSmart": MessageLookupByLibrary.simpleMessage(
      "Make this group smart",
    ),
    "rcxMakeSmartHint": MessageLookupByLibrary.simpleMessage(
      "ReClash keeps a working server selected in this group and switches when it fails. Checks run only while you use the network.",
    ),
    "rcxManageHint": MessageLookupByLibrary.simpleMessage(
      "Profiles and scenarios are made and edited in Advanced configuration → Auto routing.",
    ),
    "rcxMergeFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t bring the changes over",
    ),
    "rcxMerged": MessageLookupByLibrary.simpleMessage("Changes brought over"),
    "rcxMergedConflicts": m97,
    "rcxModeAuto": MessageLookupByLibrary.simpleMessage("Auto"),
    "rcxModeAutoHint": MessageLookupByLibrary.simpleMessage(
      "Chooses and switches servers by the profile",
    ),
    "rcxModeBackToAuto": MessageLookupByLibrary.simpleMessage(
      "Give the mode back to the scenario",
    ),
    "rcxModeByScenario": MessageLookupByLibrary.simpleMessage(
      "The scenario sets the mode on this network",
    ),
    "rcxModeIs": m98,
    "rcxModeKeep": MessageLookupByLibrary.simpleMessage("Don\'t change"),
    "rcxModeManual": MessageLookupByLibrary.simpleMessage("Manual"),
    "rcxModeManualHint": MessageLookupByLibrary.simpleMessage(
      "You choose; auto routing never switches",
    ),
    "rcxModeManualNow": MessageLookupByLibrary.simpleMessage(
      "You chose the mode yourself; the scenario waits until you pick Auto",
    ),
    "rcxModeYours": MessageLookupByLibrary.simpleMessage(
      "The mode is yours on this network",
    ),
    "rcxMoveDown": MessageLookupByLibrary.simpleMessage("Move down"),
    "rcxMoveUp": MessageLookupByLibrary.simpleMessage("Move up"),
    "rcxNeedsConsent": MessageLookupByLibrary.simpleMessage(
      "Needs your permission",
    ),
    "rcxNetwork": m99,
    "rcxNetworkKinds": MessageLookupByLibrary.simpleMessage("Network kinds"),
    "rcxNewProfile": MessageLookupByLibrary.simpleMessage("New profile"),
    "rcxNewScenario": MessageLookupByLibrary.simpleMessage("New scenario"),
    "rcxOnThisNetwork": MessageLookupByLibrary.simpleMessage("On this network"),
    "rcxOpFail": MessageLookupByLibrary.simpleMessage("fails"),
    "rcxOpIn": MessageLookupByLibrary.simpleMessage("is one of"),
    "rcxOpIs": MessageLookupByLibrary.simpleMessage("is"),
    "rcxOpIsNot": MessageLookupByLibrary.simpleMessage("is not"),
    "rcxOpMatches": MessageLookupByLibrary.simpleMessage("matches"),
    "rcxOpOk": MessageLookupByLibrary.simpleMessage("succeeds"),
    "rcxOverrides": MessageLookupByLibrary.simpleMessage("Per-network changes"),
    "rcxOwnProfile": MessageLookupByLibrary.simpleMessage(
      "Group\'s own profile",
    ),
    "rcxPatternInvalid": MessageLookupByLibrary.simpleMessage(
      "The pattern is not a valid regular expression",
    ),
    "rcxPendingTier": m100,
    "rcxPinned": m101,
    "rcxPinnedHint": MessageLookupByLibrary.simpleMessage(
      "Left only when it fails, returned to when it recovers",
    ),
    "rcxPinnedLabel": MessageLookupByLibrary.simpleMessage("Pinned"),
    "rcxPoolExclude": MessageLookupByLibrary.simpleMessage("Leave out"),
    "rcxPoolInclude": MessageLookupByLibrary.simpleMessage("Use"),
    "rcxProblemGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "The group has no servers",
    ),
    "rcxProblemGroupUnavailable": MessageLookupByLibrary.simpleMessage(
      "This group is not a selector in the current config",
    ),
    "rcxProblemProfileInvalid": m102,
    "rcxProblemProfileMissing": m103,
    "rcxProblemStoreFailed": m104,
    "rcxProfile": MessageLookupByLibrary.simpleMessage("Profile"),
    "rcxProfileName": MessageLookupByLibrary.simpleMessage("Name"),
    "rcxProfileProgramHint": MessageLookupByLibrary.simpleMessage(
      "The group picks a server with this profile among the servers the pool keeps.",
    ),
    "rcxProgramAction": MessageLookupByLibrary.simpleMessage("Action"),
    "rcxProgramFixed": MessageLookupByLibrary.simpleMessage(
      "Hand to one member",
    ),
    "rcxProgramMember": MessageLookupByLibrary.simpleMessage("Member"),
    "rcxProgramPick": MessageLookupByLibrary.simpleMessage("Pick a server"),
    "rcxReasonBest": MessageLookupByLibrary.simpleMessage(
      "This is the best server",
    ),
    "rcxReasonBetterTier": m105,
    "rcxReasonChangeServer": m106,
    "rcxReasonChecking": MessageLookupByLibrary.simpleMessage(
      "Checking a better candidate",
    ),
    "rcxReasonConfirming": MessageLookupByLibrary.simpleMessage(
      "A faster server needs another measurement",
    ),
    "rcxReasonDwell": MessageLookupByLibrary.simpleMessage(
      "Switched recently; holding before the next change",
    ),
    "rcxReasonFailover": m107,
    "rcxReasonFaster": m108,
    "rcxReasonFixed": m109,
    "rcxReasonFixedMissing": m110,
    "rcxReasonFlapLimit": m111,
    "rcxReasonHoldPinned": MessageLookupByLibrary.simpleMessage(
      "Holding the pinned server",
    ),
    "rcxReasonIdle": m112,
    "rcxReasonInitial": MessageLookupByLibrary.simpleMessage(
      "Selected the best available server",
    ),
    "rcxReasonManual": MessageLookupByLibrary.simpleMessage(
      "Controlled manually",
    ),
    "rcxReasonNetworkChanged": MessageLookupByLibrary.simpleMessage(
      "Network changed",
    ),
    "rcxReasonNetworkSuspect": MessageLookupByLibrary.simpleMessage(
      "The network looks down; no server is blamed",
    ),
    "rcxReasonNoAlternative": MessageLookupByLibrary.simpleMessage(
      "No other working server to change to",
    ),
    "rcxReasonOutOfPool": m113,
    "rcxReasonPaused": m114,
    "rcxReasonSelectFailed": MessageLookupByLibrary.simpleMessage(
      "Could not select the server",
    ),
    "rcxReasonSplitOff": MessageLookupByLibrary.simpleMessage(
      "Direct sites go direct again",
    ),
    "rcxReasonSplitOn": MessageLookupByLibrary.simpleMessage(
      "Direct sites now go through this group",
    ),
    "rcxReasonStranded": MessageLookupByLibrary.simpleMessage(
      "No working server in the pool; holding the current one",
    ),
    "rcxReasonSwitchFixed": m115,
    "rcxReasonSwitchPinned": m116,
    "rcxReasonSwitchStranded": m117,
    "rcxReasonWorking": MessageLookupByLibrary.simpleMessage(
      "Working; kept until it fails",
    ),
    "rcxScenario": MessageLookupByLibrary.simpleMessage("Scenario"),
    "rcxScenarioDrives": m118,
    "rcxScenarioGroups": MessageLookupByLibrary.simpleMessage("Groups"),
    "rcxScenarioGroupsHint": MessageLookupByLibrary.simpleMessage(
      "Main group is where the final rule sends traffic; Every group covers the select groups not named here.",
    ),
    "rcxScenarioKindsHint": MessageLookupByLibrary.simpleMessage(
      "Recognize networks by direct diagnostics, then change the mode and groups on each.",
    ),
    "rcxScenarioMode": MessageLookupByLibrary.simpleMessage("Connection mode"),
    "rcxScenarioOff": MessageLookupByLibrary.simpleMessage("Off"),
    "rcxScenarios": MessageLookupByLibrary.simpleMessage("Scenarios"),
    "rcxScenariosHint": MessageLookupByLibrary.simpleMessage(
      "A scenario drives the whole connection. Tap one of yours to edit it, any other to edit a copy.",
    ),
    "rcxServers": MessageLookupByLibrary.simpleMessage("Servers"),
    "rcxServersMatch": m119,
    "rcxServersPattern": MessageLookupByLibrary.simpleMessage("Name pattern"),
    "rcxSmartGroups": MessageLookupByLibrary.simpleMessage("Smart groups"),
    "rcxSourceBuiltin": MessageLookupByLibrary.simpleMessage("Built-in"),
    "rcxSourceChanged": MessageLookupByLibrary.simpleMessage(
      "The original profile changed",
    ),
    "rcxSourceChanges": MessageLookupByLibrary.simpleMessage("What changed"),
    "rcxSourceProvider": MessageLookupByLibrary.simpleMessage("From provider"),
    "rcxSourceUser": MessageLookupByLibrary.simpleMessage("Mine"),
    "rcxStranded": MessageLookupByLibrary.simpleMessage("When no server fits"),
    "rcxStrandedDirect": MessageLookupByLibrary.simpleMessage("Go direct"),
    "rcxStrandedHold": MessageLookupByLibrary.simpleMessage(
      "Keep the current server",
    ),
    "rcxSwitching": MessageLookupByLibrary.simpleMessage("Switching"),
    "rcxTagName": MessageLookupByLibrary.simpleMessage("Tag name"),
    "rcxTagNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Latin letters, digits, - and _ only, up to 24",
    ),
    "rcxTags": MessageLookupByLibrary.simpleMessage("Tags"),
    "rcxTagsHint": MessageLookupByLibrary.simpleMessage(
      "A tag names a set of servers once, for use in tiers as tag(name).",
    ),
    "rcxThirdParty": MessageLookupByLibrary.simpleMessage("third party"),
    "rcxTier": MessageLookupByLibrary.simpleMessage("Tier"),
    "rcxTierLabel": MessageLookupByLibrary.simpleMessage("Label"),
    "rcxTierWhen": MessageLookupByLibrary.simpleMessage("Servers in this tier"),
    "rcxTiers": MessageLookupByLibrary.simpleMessage("Preference order"),
    "rcxTiersHint": MessageLookupByLibrary.simpleMessage(
      "A server lands in the first tier it fits; the best tier with servers wins. Long press to reorder.",
    ),
    "rcxTitle": MessageLookupByLibrary.simpleMessage("Auto routing"),
    "rcxTranslations": MessageLookupByLibrary.simpleMessage("Translations"),
    "rcxTurnOff": MessageLookupByLibrary.simpleMessage("Turn off auto routing"),
    "rcxUntilCheck": m120,
    "rcxUntilConfirm": m121,
    "rcxUntilDwell": m122,
    "rcxUseCheck": m123,
    "rcxUseDiagnostic": m124,
    "rcxUseEcho": MessageLookupByLibrary.simpleMessage("exit-country check"),
    "rcxWarnings": MessageLookupByLibrary.simpleMessage("Warnings"),
    "rcxWhy": MessageLookupByLibrary.simpleMessage("Why this server"),
    "rcxYaml": MessageLookupByLibrary.simpleMessage("YAML"),
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
    "regionAppsPreview": m125,
    "regionAppsPreviewTitle": MessageLookupByLibrary.simpleMessage(
      "App selection preview",
    ),
    "regionChangeDns": MessageLookupByLibrary.simpleMessage("DNS servers"),
    "regionChangeMtu": MessageLookupByLibrary.simpleMessage("TUN MTU"),
    "regionChangeServices": MessageLookupByLibrary.simpleMessage(
      "Service checks",
    ),
    "regionChangesTitle": MessageLookupByLibrary.simpleMessage("What changes"),
    "regionChina": MessageLookupByLibrary.simpleMessage("China"),
    "regionCustomPreserved": MessageLookupByLibrary.simpleMessage(
      "Values you changed yourself stay as they are.",
    ),
    "regionEgypt": MessageLookupByLibrary.simpleMessage("Egypt"),
    "regionIntro": MessageLookupByLibrary.simpleMessage(
      "Picks DNS servers, TUN MTU, the bypass list and service checks for your country. The interface language does not change.",
    ),
    "regionIran": MessageLookupByLibrary.simpleMessage("Iran"),
    "regionNoChanges": MessageLookupByLibrary.simpleMessage(
      "Your settings stay unchanged.",
    ),
    "regionNoServices": MessageLookupByLibrary.simpleMessage(
      "Service checks are off",
    ),
    "regionNotSet": MessageLookupByLibrary.simpleMessage("Not selected"),
    "regionOther": MessageLookupByLibrary.simpleMessage("Other country"),
    "regionRecommended": MessageLookupByLibrary.simpleMessage(
      "Recommended for this device",
    ),
    "regionRussia": MessageLookupByLibrary.simpleMessage("Russia"),
    "regionSelectApps": MessageLookupByLibrary.simpleMessage(
      "Select apps by region",
    ),
    "regionSelectBeforeApps": MessageLookupByLibrary.simpleMessage(
      "Choose a supported region before using regional app suggestions.",
    ),
    "regionTitle": MessageLookupByLibrary.simpleMessage("Region profile"),
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
    "renewSubscription": MessageLookupByLibrary.simpleMessage(
      "Renew subscription",
    ),
    "replace": MessageLookupByLibrary.simpleMessage("Replace"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Replace all"),
    "request": MessageLookupByLibrary.simpleMessage("Request"),
    "requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Requests and updates",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Required"),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetAllData": MessageLookupByLibrary.simpleMessage("Reset all data"),
    "resetAllDataConfirm": MessageLookupByLibrary.simpleMessage(
      "Delete everything",
    ),
    "resetAllDataDescription": MessageLookupByLibrary.simpleMessage(
      "All profiles, settings, scripts, wallpapers, and cached data will be permanently deleted. Backup archives will be kept. The app will then close. This cannot be undone.",
    ),
    "resetAllDataWait": m126,
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "This page has changes. Are you sure you want to reset?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to reset?",
    ),
    "resettingAllData": MessageLookupByLibrary.simpleMessage("Deleting data…"),
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
    "restoreDefaults": MessageLookupByLibrary.simpleMessage("Restore defaults"),
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
    "rulesCount": m127,
    "runTime": MessageLookupByLibrary.simpleMessage("Run time"),
    "running": MessageLookupByLibrary.simpleMessage("Running"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("Runtime config"),
    "safeMode": MessageLookupByLibrary.simpleMessage("Safe mode"),
    "safeModeAppTitle": m128,
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
    "secondsCount": m129,
    "secretKey": MessageLookupByLibrary.simpleMessage("Key"),
    "sectionsInEffect": m130,
    "selectAll": MessageLookupByLibrary.simpleMessage("Select all"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Please select a rule set",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Please select a split strategy",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "server": MessageLookupByLibrary.simpleMessage("Server"),
    "serviceAbnormalCount": m131,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage(
      "All available",
    ),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Available"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Blocked"),
    "serviceCheck": MessageLookupByLibrary.simpleMessage("Check"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Check all"),
    "serviceCheckedAt": m132,
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
    "settingsCount": m133,
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
    "setupChangeSettings": MessageLookupByLibrary.simpleMessage(
      "Change settings",
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
    "setupDirectApps": m134,
    "setupDirectAppsNone": MessageLookupByLibrary.simpleMessage(
      "No local apps found. Sites still go direct.",
    ),
    "setupDirectAppsReview": MessageLookupByLibrary.simpleMessage(
      "They will work without the VPN. You can change the list later in access control.",
    ),
    "setupDirectAppsScanning": MessageLookupByLibrary.simpleMessage(
      "Looking for local apps…",
    ),
    "setupDirectDescription": MessageLookupByLibrary.simpleMessage(
      "Services of your country open without the server: faster, and banks or government sites do not block you. These rules are added to the global rules:",
    ),
    "setupDirectTitle": MessageLookupByLibrary.simpleMessage(
      "Local sites and apps go direct",
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
    "setupLeaveMessage": MessageLookupByLibrary.simpleMessage(
      "ReClash will close. Your choices are saved, and setup continues the next time you open the app.",
    ),
    "setupLeaveTitle": MessageLookupByLibrary.simpleMessage("Leave setup?"),
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
    "setupProfileContinueHint": MessageLookupByLibrary.simpleMessage(
      "Add or choose a profile to continue.",
    ),
    "setupProfileCount": m135,
    "setupProfileDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash does not provide servers. Import a subscription or a configuration from your provider.",
    ),
    "setupProfileImport": MessageLookupByLibrary.simpleMessage(
      "Import profile",
    ),
    "setupProfileImportAnother": MessageLookupByLibrary.simpleMessage(
      "Add another profile",
    ),
    "setupProfileImportHint": MessageLookupByLibrary.simpleMessage(
      "Paste the link from your provider\'s email, bot or account page, or pick a file or QR code.",
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
    "setupReceiptRegion": MessageLookupByLibrary.simpleMessage("Region"),
    "setupRecommended": MessageLookupByLibrary.simpleMessage("Recommended"),
    "setupRegionNeutral": MessageLookupByLibrary.simpleMessage(
      "Keep profile defaults",
    ),
    "setupRegionNeutralDescription": MessageLookupByLibrary.simpleMessage(
      "Regional settings are not changed.",
    ),
    "setupRegionStepDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash adjusts DNS, MTU and direct routes to the networks of your country. The interface language stays the same.",
    ),
    "setupRegionTitle": MessageLookupByLibrary.simpleMessage(
      "Where are you connecting from?",
    ),
    "setupRegionUnchosen": MessageLookupByLibrary.simpleMessage(
      "If you skip the choice, your current regional settings stay as they are.",
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
    "setupStepStatus": m136,
    "setupStoppedDescription": MessageLookupByLibrary.simpleMessage(
      "Your choices are saved. The previous connection was not stopped.",
    ),
    "setupStoppedTitle": MessageLookupByLibrary.simpleMessage("Check stopped"),
    "setupTipCoverage": MessageLookupByLibrary.simpleMessage(
      "Choose a different coverage: some networks block VPN connections.",
    ),
    "setupTipNetwork": MessageLookupByLibrary.simpleMessage(
      "Make sure the internet works without ReClash.",
    ),
    "setupTipProfile": MessageLookupByLibrary.simpleMessage(
      "Update the profile, or pick another server after setup.",
    ),
    "setupTipsTitle": MessageLookupByLibrary.simpleMessage("What you can try"),
    "setupTitle": MessageLookupByLibrary.simpleMessage("First connection"),
    "setupTryServer": m137,
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
    "shareLinkUnreadable": m138,
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
    "singleValueTip": m139,
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
    "subscriptionCompatibilityPrepared": m140,
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
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Your subscription has expired",
    ),
    "subscriptionExpiresInDays": m141,
    "subscriptionExpiresToday": MessageLookupByLibrary.simpleMessage(
      "Your subscription expires today",
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
    "subscriptionIdentityRegionWarning": MessageLookupByLibrary.simpleMessage(
      "Many subscriptions will stop working if HWID sending is turned off.",
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
    "subscriptionImportIgnoredSections": m142,
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
    "subscriptionImportReviewSummary": m143,
    "subscriptionImportReviewTitle": MessageLookupByLibrary.simpleMessage(
      "Review subscription import",
    ),
    "subscriptionImportSkippedNodes": m144,
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Subscription info",
    ),
    "subscriptionNoticeChannel": MessageLookupByLibrary.simpleMessage(
      "Subscription reminders",
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
    "subscriptionTrafficLow": m145,
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
    "toolsResults": m146,
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
    "topUpTraffic": MessageLookupByLibrary.simpleMessage("Top up traffic"),
    "torch": MessageLookupByLibrary.simpleMessage("Flashlight"),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("Downloaded"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Total traffic"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("Uploaded"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy port"),
    "traffic": MessageLookupByLibrary.simpleMessage("Traffic"),
    "trafficPeak": m147,
    "trafficTotal": m148,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Traffic usage"),
    "translationSuggestFix": MessageLookupByLibrary.simpleMessage(
      "Suggest a translation fix",
    ),
    "transport": MessageLookupByLibrary.simpleMessage("Transport"),
    "trayIcon": MessageLookupByLibrary.simpleMessage("Tray icon"),
    "trayIconColor": MessageLookupByLibrary.simpleMessage("Color"),
    "trayIconDark": MessageLookupByLibrary.simpleMessage("Black"),
    "trayIconLight": MessageLookupByLibrary.simpleMessage("White"),
    "trustedNetworks": MessageLookupByLibrary.simpleMessage("Trusted networks"),
    "trustedNetworksDesc": MessageLookupByLibrary.simpleMessage(
      "The VPN pauses while connected to any of these networks",
    ),
    "trustedNow": MessageLookupByLibrary.simpleMessage(
      "Current network is trusted",
    ),
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
    "updateAutoConsentDescription": MessageLookupByLibrary.simpleMessage(
      "ReClash may install verified, eligible stable updates without asking each time. It will never disconnect your VPN. Android may still ask you to confirm an installation.",
    ),
    "updateAutoConsentTitle": MessageLookupByLibrary.simpleMessage(
      "Allow automatic installation?",
    ),
    "updateAutoInstall": MessageLookupByLibrary.simpleMessage(
      "Install automatically",
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
      "Couldn\'t check for updates",
    ),
    "updateCheckFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Check your connection and try again.",
    ),
    "updateCheckingTitle": MessageLookupByLibrary.simpleMessage(
      "Checking for updates…",
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
    "updateDownloadFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t download the update",
    ),
    "updateDownloadFailedDescription": MessageLookupByLibrary.simpleMessage(
      "The downloaded part is saved. Check your connection, then resume.",
    ),
    "updateGotIt": MessageLookupByLibrary.simpleMessage("Got it"),
    "updateInstallFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t start the package installer",
    ),
    "updateInstallFailedDescription": MessageLookupByLibrary.simpleMessage(
      "Android did not complete the installation. Try again when you\'re ready.",
    ),
    "updateInstallNow": MessageLookupByLibrary.simpleMessage("Install now"),
    "updateInstalledTitle": MessageLookupByLibrary.simpleMessage(
      "Update installed",
    ),
    "updateInstalledVersion": m149,
    "updateInstallingDescription": MessageLookupByLibrary.simpleMessage(
      "Android is completing the installation. ReClash may close during this step.",
    ),
    "updateInstallingTitle": MessageLookupByLibrary.simpleMessage(
      "Installing the update",
    ),
    "updateMinutes": m150,
    "updateNotNow": MessageLookupByLibrary.simpleMessage("Not now"),
    "updateNotesUnavailable": MessageLookupByLibrary.simpleMessage(
      "No release notes are available.",
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
    "updatePauseAction": MessageLookupByLibrary.simpleMessage("Pause"),
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
    "updatePreferencesSaveFailed": MessageLookupByLibrary.simpleMessage(
      "Preferences weren\'t saved. Try saving again; automatic installation has not been enabled.",
    ),
    "updatePreferencesTitle": MessageLookupByLibrary.simpleMessage(
      "Update preferences",
    ),
    "updatePreload": MessageLookupByLibrary.simpleMessage("Preload on Wi-Fi"),
    "updateReadyTitle": MessageLookupByLibrary.simpleMessage(
      "Ready to install",
    ),
    "updateReleaseDetails": MessageLookupByLibrary.simpleMessage(
      "Release details",
    ),
    "updateRemainingTime": m151,
    "updateResumeAction": MessageLookupByLibrary.simpleMessage(
      "Resume download",
    ),
    "updateResumeShort": MessageLookupByLibrary.simpleMessage("Resume"),
    "updateRetryCheck": MessageLookupByLibrary.simpleMessage("Check again"),
    "updateRetryInstall": MessageLookupByLibrary.simpleMessage(
      "Try installation again",
    ),
    "updateSeconds": m152,
    "updateSeeFullReleaseNotes": MessageLookupByLibrary.simpleMessage(
      "See full release notes",
    ),
    "updateShowAllNotes": MessageLookupByLibrary.simpleMessage(
      "Show all changes",
    ),
    "updateTitle": MessageLookupByLibrary.simpleMessage("Updates"),
    "updateTransferSpeed": m153,
    "updateVerifyFailed": MessageLookupByLibrary.simpleMessage(
      "The downloaded update failed integrity verification.",
    ),
    "updateVerifyFailedDescription": MessageLookupByLibrary.simpleMessage(
      "The file, version or signature did not pass verification. Download a fresh copy to try again.",
    ),
    "updateVerifyFailedTitle": MessageLookupByLibrary.simpleMessage(
      "This package can\'t be installed",
    ),
    "updateVerifyingTitle": MessageLookupByLibrary.simpleMessage(
      "Checking the update",
    ),
    "updateVpnDescription": MessageLookupByLibrary.simpleMessage(
      "Installation will briefly close ReClash. Disconnect only if you\'re ready to interrupt the connection.",
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
      "Add a subscription URL with an optional name.",
    ),
    "urlSchemeAuthenticationFailed": MessageLookupByLibrary.simpleMessage(
      "The encrypted link could not be authenticated. It may be damaged or use a different key.",
    ),
    "urlSchemeBuild": MessageLookupByLibrary.simpleMessage("Build link"),
    "urlSchemeClose": MessageLookupByLibrary.simpleMessage("Close application"),
    "urlSchemeCloseDesc": MessageLookupByLibrary.simpleMessage(
      "Use your configured close behavior.",
    ),
    "urlSchemeConfigCounts": m154,
    "urlSchemeConfigHint": MessageLookupByLibrary.simpleMessage(
      "Paste a YAML or JSON configuration",
    ),
    "urlSchemeConfigSummary": MessageLookupByLibrary.simpleMessage(
      "Configuration contents",
    ),
    "urlSchemeConfirmMessage": m155,
    "urlSchemeConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "External application command",
    ),
    "urlSchemeConfirmationTip": MessageLookupByLibrary.simpleMessage(
      "External connection and close commands ask for confirmation.",
    ),
    "urlSchemeConnect": MessageLookupByLibrary.simpleMessage("Connect"),
    "urlSchemeConnectDesc": MessageLookupByLibrary.simpleMessage(
      "Connect with the selected profile.",
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
      "Stop the connection; keep the selected profile.",
    ),
    "urlSchemeEmbeddedConfig": MessageLookupByLibrary.simpleMessage(
      "Embedded configuration",
    ),
    "urlSchemeExampleProfile": MessageLookupByLibrary.simpleMessage(
      "Example profile",
    ),
    "urlSchemeFormats": MessageLookupByLibrary.simpleMessage("Formats"),
    "urlSchemeFormatsTip": MessageLookupByLibrary.simpleMessage(
      "Link formats. Replace placeholders with your URL or data.",
    ),
    "urlSchemeImport": MessageLookupByLibrary.simpleMessage(
      "Import configuration",
    ),
    "urlSchemeImportConfirm": m156,
    "urlSchemeImportDesc": MessageLookupByLibrary.simpleMessage(
      "Embed a YAML or JSON configuration in the link.",
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
      "Use the subscription link format shared by Clash clients.",
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
      "Bring ReClash to the foreground.",
    ),
    "urlSchemeParameters": MessageLookupByLibrary.simpleMessage("Parameters"),
    "urlSchemePasteFailed": MessageLookupByLibrary.simpleMessage(
      "Could not read the clipboard. Paste the link manually.",
    ),
    "urlSchemePreview": MessageLookupByLibrary.simpleMessage("Link"),
    "urlSchemePreviewEmpty": MessageLookupByLibrary.simpleMessage(
      "Enter a URL or configuration to build the link.",
    ),
    "urlSchemePrivateLinkTip": MessageLookupByLibrary.simpleMessage(
      "Links may contain tokens or credentials. Share with care.",
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
    "urlSchemeToggle": MessageLookupByLibrary.simpleMessage(
      "Toggle connection",
    ),
    "urlSchemeToggleDesc": MessageLookupByLibrary.simpleMessage(
      "Connect if stopped; disconnect if running.",
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
    "urlTip": m157,
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
    "wallpaperHorizontalPosition": MessageLookupByLibrary.simpleMessage(
      "Horizontal position",
    ),
    "wallpaperImageError": MessageLookupByLibrary.simpleMessage(
      "Choose a valid PNG, JPEG or WebP image.",
    ),
    "wallpaperImageLabel": m158,
    "wallpaperLayout": MessageLookupByLibrary.simpleMessage("Framing"),
    "wallpaperLibraryFull": m159,
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
    "webDashboardAccess": MessageLookupByLibrary.simpleMessage("Access"),
    "webDashboardAccessEnded": MessageLookupByLibrary.simpleMessage(
      "Dashboard access ended",
    ),
    "webDashboardAccessInApp": MessageLookupByLibrary.simpleMessage(
      "In the app",
    ),
    "webDashboardAccessInBrowser": MessageLookupByLibrary.simpleMessage(
      "In the browser",
    ),
    "webDashboardAccessOff": MessageLookupByLibrary.simpleMessage("Off"),
    "webDashboardAccessTip": MessageLookupByLibrary.simpleMessage(
      "Access is local and protected by a secret. Opening a dashboard does not change your saved external controller settings.",
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
    "webDashboardFlavor": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "webDashboardInstall": MessageLookupByLibrary.simpleMessage(
      "Install dashboard",
    ),
    "webDashboardInstallTip": MessageLookupByLibrary.simpleMessage(
      "The selected dashboard is downloaded on first open. Downloads use a pinned release and SHA-256 verification.",
    ),
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
    "webDashboardRestricted": MessageLookupByLibrary.simpleMessage(
      "Dashboard access is disabled by your provider.",
    ),
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
    "webDashboardVersion": MessageLookupByLibrary.simpleMessage("Version"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Whitelist mode"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("Write to system"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "Write to system also sets the system clock; Android ignores it.",
    ),
    "yearsAgo": m160,
    "yearsAgoShort": m161,
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
    "zhCN": MessageLookupByLibrary.simpleMessage("Simplified Chinese"),
  };
}
