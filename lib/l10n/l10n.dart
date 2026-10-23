// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(
      _current != null,
      'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalizations();
      AppLocalizations._current = instance;

      return instance;
    });
  }

  static AppLocalizations of(BuildContext context) {
    final instance = AppLocalizations.maybeOf(context);
    assert(
      instance != null,
      'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `Rule`
  String get rule {
    return Intl.message('Rule', name: 'rule', desc: '', args: []);
  }

  /// `Rules`
  String get rules {
    return Intl.message('Rules', name: 'rules', desc: '', args: []);
  }

  /// `Global`
  String get global {
    return Intl.message('Global', name: 'global', desc: '', args: []);
  }

  /// `Direct`
  String get direct {
    return Intl.message('Direct', name: 'direct', desc: '', args: []);
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
  }

  /// `Proxies`
  String get proxies {
    return Intl.message('Proxies', name: 'proxies', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Profiles`
  String get profiles {
    return Intl.message('Profiles', name: 'profiles', desc: '', args: []);
  }

  /// `Tools`
  String get tools {
    return Intl.message('Tools', name: 'tools', desc: '', args: []);
  }

  /// `Logs`
  String get logs {
    return Intl.message('Logs', name: 'logs', desc: '', args: []);
  }

  /// `Resources`
  String get resources {
    return Intl.message('Resources', name: 'resources', desc: '', args: []);
  }

  /// `Traffic usage`
  String get trafficUsage {
    return Intl.message(
      'Traffic usage',
      name: 'trafficUsage',
      desc: '',
      args: [],
    );
  }

  /// `Network speed`
  String get networkSpeed {
    return Intl.message(
      'Network speed',
      name: 'networkSpeed',
      desc: '',
      args: [],
    );
  }

  /// `Outbound mode`
  String get outboundMode {
    return Intl.message(
      'Outbound mode',
      name: 'outboundMode',
      desc: '',
      args: [],
    );
  }

  /// `Service status`
  String get serviceStatus {
    return Intl.message(
      'Service status',
      name: 'serviceStatus',
      desc: '',
      args: [],
    );
  }

  /// `Access restricted`
  String get serviceRestricted {
    return Intl.message(
      'Access restricted',
      name: 'serviceRestricted',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get serviceAvailable {
    return Intl.message(
      'Available',
      name: 'serviceAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Unavailable`
  String get serviceUnavailable {
    return Intl.message(
      'Unavailable',
      name: 'serviceUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Check failed`
  String get serviceFailed {
    return Intl.message(
      'Check failed',
      name: 'serviceFailed',
      desc: '',
      args: [],
    );
  }

  /// `Disallowed ISP`
  String get serviceDisallowedIsp {
    return Intl.message(
      'Disallowed ISP',
      name: 'serviceDisallowedIsp',
      desc: '',
      args: [],
    );
  }

  /// `Blocked`
  String get serviceBlocked {
    return Intl.message('Blocked', name: 'serviceBlocked', desc: '', args: []);
  }

  /// `Region not supported`
  String get serviceUnsupportedRegion {
    return Intl.message(
      'Region not supported',
      name: 'serviceUnsupportedRegion',
      desc: '',
      args: [],
    );
  }

  /// `Originals only`
  String get serviceOriginalsOnly {
    return Intl.message(
      'Originals only',
      name: 'serviceOriginalsOnly',
      desc: '',
      args: [],
    );
  }

  /// `Coming soon`
  String get serviceComingSoon {
    return Intl.message(
      'Coming soon',
      name: 'serviceComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Not checked`
  String get servicePending {
    return Intl.message(
      'Not checked',
      name: 'servicePending',
      desc: '',
      args: [],
    );
  }

  /// `Manage services`
  String get serviceManage {
    return Intl.message(
      'Manage services',
      name: 'serviceManage',
      desc: '',
      args: [],
    );
  }

  /// `Check`
  String get serviceCheck {
    return Intl.message('Check', name: 'serviceCheck', desc: '', args: []);
  }

  /// `Check all`
  String get serviceCheckAll {
    return Intl.message(
      'Check all',
      name: 'serviceCheckAll',
      desc: '',
      args: [],
    );
  }

  /// `Checked at {time}`
  String serviceCheckedAt(Object time) {
    return Intl.message(
      'Checked at $time',
      name: 'serviceCheckedAt',
      desc: '',
      args: [time],
    );
  }

  /// `Upload`
  String get upload {
    return Intl.message('Upload', name: 'upload', desc: '', args: []);
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `Used traffic`
  String get usedTraffic {
    return Intl.message(
      'Used traffic',
      name: 'usedTraffic',
      desc: '',
      args: [],
    );
  }

  /// `Total traffic`
  String get totalTraffic {
    return Intl.message(
      'Total traffic',
      name: 'totalTraffic',
      desc: '',
      args: [],
    );
  }

  /// `Expiration time`
  String get expireTime {
    return Intl.message(
      'Expiration time',
      name: 'expireTime',
      desc: '',
      args: [],
    );
  }

  /// `Add a profile to get started`
  String get nullProfileDesc {
    return Intl.message(
      'Add a profile to get started',
      name: 'nullProfileDesc',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Default`
  String get defaultText {
    return Intl.message('Default', name: 'defaultText', desc: '', args: []);
  }

  /// `More`
  String get more {
    return Intl.message('More', name: 'more', desc: '', args: []);
  }

  /// `Other`
  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `English`
  String get en {
    return Intl.message('English', name: 'en', desc: '', args: []);
  }

  /// `Spanish`
  String get es {
    return Intl.message('Spanish', name: 'es', desc: '', args: []);
  }

  /// `French`
  String get fr {
    return Intl.message('French', name: 'fr', desc: '', args: []);
  }

  /// `Japanese`
  String get ja {
    return Intl.message('Japanese', name: 'ja', desc: '', args: []);
  }

  /// `Korean`
  String get ko {
    return Intl.message('Korean', name: 'ko', desc: '', args: []);
  }

  /// `Russian`
  String get ru {
    return Intl.message('Russian', name: 'ru', desc: '', args: []);
  }

  /// `Simplified Chinese`
  String get zhCN {
    return Intl.message('Simplified Chinese', name: 'zhCN', desc: '', args: []);
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Extend`
  String get extend {
    return Intl.message('Extend', name: 'extend', desc: '', args: []);
  }

  /// `Runtime config`
  String get runtimeConfig {
    return Intl.message(
      'Runtime config',
      name: 'runtimeConfig',
      desc: '',
      args: [],
    );
  }

  /// `Allow LAN`
  String get allowLan {
    return Intl.message('Allow LAN', name: 'allowLan', desc: '', args: []);
  }

  /// `TUN`
  String get tun {
    return Intl.message('TUN', name: 'tun', desc: '', args: []);
  }

  /// `TUN works only in administrator mode.`
  String get tunDesc {
    return Intl.message(
      'TUN works only in administrator mode.',
      name: 'tunDesc',
      desc: '',
      args: [],
    );
  }

  /// `Minimize on exit`
  String get minimizeOnExit {
    return Intl.message(
      'Minimize on exit',
      name: 'minimizeOnExit',
      desc: '',
      args: [],
    );
  }

  /// `Auto launch`
  String get autoLaunch {
    return Intl.message('Auto launch', name: 'autoLaunch', desc: '', args: []);
  }

  /// `Silent launch`
  String get silentLaunch {
    return Intl.message(
      'Silent launch',
      name: 'silentLaunch',
      desc: '',
      args: [],
    );
  }

  /// `Silent launch starts without showing the window.`
  String get silentLaunchDesc {
    return Intl.message(
      'Silent launch starts without showing the window.',
      name: 'silentLaunchDesc',
      desc: '',
      args: [],
    );
  }

  /// `Auto run`
  String get autoRun {
    return Intl.message('Auto run', name: 'autoRun', desc: '', args: []);
  }

  /// `Auto run starts the proxy when the app opens.`
  String get autoRunDesc {
    return Intl.message(
      'Auto run starts the proxy when the app opens.',
      name: 'autoRunDesc',
      desc: '',
      args: [],
    );
  }

  /// `Logcat`
  String get logcat {
    return Intl.message('Logcat', name: 'logcat', desc: '', args: []);
  }

  /// `Turning off Logcat hides the logs entry.`
  String get logcatDesc {
    return Intl.message(
      'Turning off Logcat hides the logs entry.',
      name: 'logcatDesc',
      desc: '',
      args: [],
    );
  }

  /// `Auto check for updates`
  String get autoCheckUpdate {
    return Intl.message(
      'Auto check for updates',
      name: 'autoCheckUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Verify TLS certificates`
  String get checkCertificate {
    return Intl.message(
      'Verify TLS certificates',
      name: 'checkCertificate',
      desc: '',
      args: [],
    );
  }

  /// `With TLS verification off, subscriptions and backups are open to man-in-the-middle attacks.`
  String get checkCertificateDesc {
    return Intl.message(
      'With TLS verification off, subscriptions and backups are open to man-in-the-middle attacks.',
      name: 'checkCertificateDesc',
      desc: '',
      args: [],
    );
  }

  /// `Access control`
  String get accessControl {
    return Intl.message(
      'Access control',
      name: 'accessControl',
      desc: '',
      args: [],
    );
  }

  /// `Access control picks which apps use the proxy.`
  String get accessControlDesc {
    return Intl.message(
      'Access control picks which apps use the proxy.',
      name: 'accessControlDesc',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `seconds`
  String get seconds {
    return Intl.message('seconds', name: 'seconds', desc: '', args: []);
  }

  /// `QR code`
  String get qrcode {
    return Intl.message('QR code', name: 'qrcode', desc: '', args: []);
  }

  /// `Scan a QR code to obtain a profile`
  String get qrcodeDesc {
    return Intl.message(
      'Scan a QR code to obtain a profile',
      name: 'qrcodeDesc',
      desc: '',
      args: [],
    );
  }

  /// `URL`
  String get url {
    return Intl.message('URL', name: 'url', desc: '', args: []);
  }

  /// `Link`
  String get link {
    return Intl.message('Link', name: 'link', desc: '', args: []);
  }

  /// `Obtain a profile from a subscription link or a proxy share link`
  String get linkDesc {
    return Intl.message(
      'Obtain a profile from a subscription link or a proxy share link',
      name: 'linkDesc',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get file {
    return Intl.message('File', name: 'file', desc: '', args: []);
  }

  /// `Upload a profile file directly`
  String get fileDesc {
    return Intl.message(
      'Upload a profile file directly',
      name: 'fileDesc',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Please enter the profile name`
  String get profileNameNullValidationDesc {
    return Intl.message(
      'Please enter the profile name',
      name: 'profileNameNullValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get rename {
    return Intl.message('Rename', name: 'rename', desc: '', args: []);
  }

  /// `Please enter the profile URL`
  String get profileUrlNullValidationDesc {
    return Intl.message(
      'Please enter the profile URL',
      name: 'profileUrlNullValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid profile URL`
  String get profileUrlInvalidValidationDesc {
    return Intl.message(
      'Please enter a valid profile URL',
      name: 'profileUrlInvalidValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Auto update`
  String get autoUpdate {
    return Intl.message('Auto update', name: 'autoUpdate', desc: '', args: []);
  }

  /// `Auto-update interval`
  String get autoUpdateInterval {
    return Intl.message(
      'Auto-update interval',
      name: 'autoUpdateInterval',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the auto-update interval`
  String get profileAutoUpdateIntervalNullValidationDesc {
    return Intl.message(
      'Please enter the auto-update interval',
      name: 'profileAutoUpdateIntervalNullValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid interval`
  String get profileAutoUpdateIntervalInvalidValidationDesc {
    return Intl.message(
      'Please enter a valid interval',
      name: 'profileAutoUpdateIntervalInvalidValidationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Theme mode`
  String get themeMode {
    return Intl.message('Theme mode', name: 'themeMode', desc: '', args: []);
  }

  /// `Theme color`
  String get themeColor {
    return Intl.message('Theme color', name: 'themeColor', desc: '', args: []);
  }

  /// `Preview`
  String get preview {
    return Intl.message('Preview', name: 'preview', desc: '', args: []);
  }

  /// `Auto`
  String get auto {
    return Intl.message('Auto', name: 'auto', desc: '', args: []);
  }

  /// `Light`
  String get light {
    return Intl.message('Light', name: 'light', desc: '', args: []);
  }

  /// `Dark`
  String get dark {
    return Intl.message('Dark', name: 'dark', desc: '', args: []);
  }

  /// `Import from link`
  String get importFromLink {
    return Intl.message(
      'Import from link',
      name: 'importFromLink',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Do you want to create a profile from {url}?`
  String createProfileFromUrlTip(Object url) {
    return Intl.message(
      'Do you want to create a profile from $url?',
      name: 'createProfileFromUrlTip',
      desc: '',
      args: [url],
    );
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `Please upload a valid QR code`
  String get pleaseUploadValidQrcode {
    return Intl.message(
      'Please upload a valid QR code',
      name: 'pleaseUploadValidQrcode',
      desc: '',
      args: [],
    );
  }

  /// `Blacklist mode`
  String get blacklistMode {
    return Intl.message(
      'Blacklist mode',
      name: 'blacklistMode',
      desc: '',
      args: [],
    );
  }

  /// `Whitelist mode`
  String get whitelistMode {
    return Intl.message(
      'Whitelist mode',
      name: 'whitelistMode',
      desc: '',
      args: [],
    );
  }

  /// `Select all`
  String get selectAll {
    return Intl.message('Select all', name: 'selectAll', desc: '', args: []);
  }

  /// `Deselect all`
  String get cancelSelectAll {
    return Intl.message(
      'Deselect all',
      name: 'cancelSelectAll',
      desc: '',
      args: [],
    );
  }

  /// `App access control`
  String get appAccessControl {
    return Intl.message(
      'App access control',
      name: 'appAccessControl',
      desc: '',
      args: [],
    );
  }

  /// `Only selected apps go through the VPN`
  String get accessControlAllowDesc {
    return Intl.message(
      'Only selected apps go through the VPN',
      name: 'accessControlAllowDesc',
      desc: '',
      args: [],
    );
  }

  /// `Selected apps are excluded from the VPN`
  String get accessControlNotAllowDesc {
    return Intl.message(
      'Selected apps are excluded from the VPN',
      name: 'accessControlNotAllowDesc',
      desc: '',
      args: [],
    );
  }

  /// `App access control is disabled`
  String get accessControlDisabledDesc {
    return Intl.message(
      'App access control is disabled',
      name: 'accessControlDisabledDesc',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get selected {
    return Intl.message('Selected', name: 'selected', desc: '', args: []);
  }

  /// `Port`
  String get port {
    return Intl.message('Port', name: 'port', desc: '', args: []);
  }

  /// `Log level`
  String get logLevel {
    return Intl.message('Log level', name: 'logLevel', desc: '', args: []);
  }

  /// `Show`
  String get show {
    return Intl.message('Show', name: 'show', desc: '', args: []);
  }

  /// `Exit`
  String get exit {
    return Intl.message('Exit', name: 'exit', desc: '', args: []);
  }

  /// `System proxy`
  String get systemProxy {
    return Intl.message(
      'System proxy',
      name: 'systemProxy',
      desc: '',
      args: [],
    );
  }

  /// `Safe mode`
  String get safeMode {
    return Intl.message('Safe mode', name: 'safeMode', desc: '', args: []);
  }

  /// `{appName} (Safe mode)`
  String safeModeAppTitle(Object appName) {
    return Intl.message(
      '$appName (Safe mode)',
      name: 'safeModeAppTitle',
      desc: '',
      args: [appName],
    );
  }

  /// `Project`
  String get project {
    return Intl.message('Project', name: 'project', desc: '', args: []);
  }

  /// `Core`
  String get core {
    return Intl.message('Core', name: 'core', desc: '', args: []);
  }

  /// `Tab animation`
  String get tabAnimation {
    return Intl.message(
      'Tab animation',
      name: 'tabAnimation',
      desc: '',
      args: [],
    );
  }

  /// `A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.`
  String get desc {
    return Intl.message(
      'A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.',
      name: 'desc',
      desc: '',
      args: [],
    );
  }

  /// `Starting VPN…`
  String get startVpn {
    return Intl.message('Starting VPN…', name: 'startVpn', desc: '', args: []);
  }

  /// `Stopping VPN…`
  String get stopVpn {
    return Intl.message('Stopping VPN…', name: 'stopVpn', desc: '', args: []);
  }

  /// `Local network permission denied: using the gvisor stack, LAN is unreachable.`
  String get localNetworkDeniedTip {
    return Intl.message(
      'Local network permission denied: using the gvisor stack, LAN is unreachable.',
      name: 'localNetworkDeniedTip',
      desc: '',
      args: [],
    );
  }

  /// `Compatibility mode`
  String get compatible {
    return Intl.message(
      'Compatibility mode',
      name: 'compatible',
      desc: '',
      args: [],
    );
  }

  /// `The current proxy group cannot be selected`
  String get notSelectedTip {
    return Intl.message(
      'The current proxy group cannot be selected',
      name: 'notSelectedTip',
      desc: '',
      args: [],
    );
  }

  /// `Failed to switch proxy; the previous selection has been restored`
  String get changeProxyFailedTip {
    return Intl.message(
      'Failed to switch proxy; the previous selection has been restored',
      name: 'changeProxyFailedTip',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save the change; it has been rolled back`
  String get databaseWriteFailedTip {
    return Intl.message(
      'Failed to save the change; it has been rolled back',
      name: 'databaseWriteFailedTip',
      desc: '',
      args: [],
    );
  }

  /// `Tip`
  String get tip {
    return Intl.message('Tip', name: 'tip', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Backup`
  String get backup {
    return Intl.message('Backup', name: 'backup', desc: '', args: []);
  }

  /// `Backup successful`
  String get backupSuccess {
    return Intl.message(
      'Backup successful',
      name: 'backupSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No info`
  String get noInfo {
    return Intl.message('No info', name: 'noInfo', desc: '', args: []);
  }

  /// `Please bind WebDAV`
  String get pleaseBindWebDAV {
    return Intl.message(
      'Please bind WebDAV',
      name: 'pleaseBindWebDAV',
      desc: '',
      args: [],
    );
  }

  /// `Bind`
  String get bind {
    return Intl.message('Bind', name: 'bind', desc: '', args: []);
  }

  /// `Connectivity: `
  String get connectivity {
    return Intl.message(
      'Connectivity: ',
      name: 'connectivity',
      desc: '',
      args: [],
    );
  }

  /// `WebDAV configuration`
  String get webDAVConfiguration {
    return Intl.message(
      'WebDAV configuration',
      name: 'webDAVConfiguration',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `WebDAV server address`
  String get addressHelp {
    return Intl.message(
      'WebDAV server address',
      name: 'addressHelp',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid WebDAV address`
  String get addressTip {
    return Intl.message(
      'Please enter a valid WebDAV address',
      name: 'addressTip',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Authentication`
  String get authentication {
    return Intl.message(
      'Authentication',
      name: 'authentication',
      desc: '',
      args: [],
    );
  }

  /// `Authentication asks for a username and password on the local proxy port.`
  String get authenticationDesc {
    return Intl.message(
      'Authentication asks for a username and password on the local proxy port.',
      name: 'authenticationDesc',
      desc: '',
      args: [],
    );
  }

  /// `The system proxy is not applied while authentication is on.`
  String get authenticationSystemProxyDesc {
    return Intl.message(
      'The system proxy is not applied while authentication is on.',
      name: 'authenticationSystemProxyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Check for updates`
  String get checkUpdate {
    return Intl.message(
      'Check for updates',
      name: 'checkUpdate',
      desc: '',
      args: [],
    );
  }

  /// `New version found`
  String get discoverNewVersion {
    return Intl.message(
      'New version found',
      name: 'discoverNewVersion',
      desc: '',
      args: [],
    );
  }

  /// `The app is already up to date`
  String get checkUpdateError {
    return Intl.message(
      'The app is already up to date',
      name: 'checkUpdateError',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get goDownload {
    return Intl.message('Download', name: 'goDownload', desc: '', args: []);
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `Region`
  String get country {
    return Intl.message('Region', name: 'country', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Allow apps to bypass VPN`
  String get allowBypass {
    return Intl.message(
      'Allow apps to bypass VPN',
      name: 'allowBypass',
      desc: '',
      args: [],
    );
  }

  /// `External controller`
  String get externalController {
    return Intl.message(
      'External controller',
      name: 'externalController',
      desc: '',
      args: [],
    );
  }

  /// `The external controller lets you control the core on port 9090.`
  String get externalControllerDesc {
    return Intl.message(
      'The external controller lets you control the core on port 9090.',
      name: 'externalControllerDesc',
      desc: '',
      args: [],
    );
  }

  /// `External controller secret`
  String get externalControllerSecret {
    return Intl.message(
      'External controller secret',
      name: 'externalControllerSecret',
      desc: '',
      args: [],
    );
  }

  /// `IPv6 traffic is received only while IPv6 is on.`
  String get ipv6Desc {
    return Intl.message(
      'IPv6 traffic is received only while IPv6 is on.',
      name: 'ipv6Desc',
      desc: '',
      args: [],
    );
  }

  /// `App`
  String get app {
    return Intl.message('App', name: 'app', desc: '', args: []);
  }

  /// `General`
  String get general {
    return Intl.message('General', name: 'general', desc: '', args: []);
  }

  /// `Startup and background`
  String get startupAndBackground {
    return Intl.message(
      'Startup and background',
      name: 'startupAndBackground',
      desc: '',
      args: [],
    );
  }

  /// `Requests and updates`
  String get requestsAndUpdates {
    return Intl.message(
      'Requests and updates',
      name: 'requestsAndUpdates',
      desc: '',
      args: [],
    );
  }

  /// `Logs and diagnostics`
  String get logsAndDiagnostics {
    return Intl.message(
      'Logs and diagnostics',
      name: 'logsAndDiagnostics',
      desc: '',
      args: [],
    );
  }

  /// `User-Agent`
  String get userAgent {
    return Intl.message('User-Agent', name: 'userAgent', desc: '', args: []);
  }

  /// `Unified delay`
  String get unifiedDelay {
    return Intl.message(
      'Unified delay',
      name: 'unifiedDelay',
      desc: '',
      args: [],
    );
  }

  /// `TCP concurrent`
  String get tcpConcurrent {
    return Intl.message(
      'TCP concurrent',
      name: 'tcpConcurrent',
      desc: '',
      args: [],
    );
  }

  /// `Geo low-memory mode`
  String get geodataLoader {
    return Intl.message(
      'Geo low-memory mode',
      name: 'geodataLoader',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get requests {
    return Intl.message('Requests', name: 'requests', desc: '', args: []);
  }

  /// `Recent requests`
  String get recentRequests {
    return Intl.message(
      'Recent requests',
      name: 'recentRequests',
      desc: '',
      args: [],
    );
  }

  /// `Find process`
  String get findProcessMode {
    return Intl.message(
      'Find process',
      name: 'findProcessMode',
      desc: '',
      args: [],
    );
  }

  /// `Init`
  String get init {
    return Intl.message('Init', name: 'init', desc: '', args: []);
  }

  /// `Never expires`
  String get infiniteTime {
    return Intl.message(
      'Never expires',
      name: 'infiniteTime',
      desc: '',
      args: [],
    );
  }

  /// `Connections`
  String get connections {
    return Intl.message('Connections', name: 'connections', desc: '', args: []);
  }

  /// `Live connections`
  String get liveConnections {
    return Intl.message(
      'Live connections',
      name: 'liveConnections',
      desc: '',
      args: [],
    );
  }

  /// `Inbound`
  String get inbound {
    return Intl.message('Inbound', name: 'inbound', desc: '', args: []);
  }

  /// `Intranet IP`
  String get intranetIP {
    return Intl.message('Intranet IP', name: 'intranetIP', desc: '', args: []);
  }

  /// `View`
  String get view {
    return Intl.message('View', name: 'view', desc: '', args: []);
  }

  /// `Cut`
  String get cut {
    return Intl.message('Cut', name: 'cut', desc: '', args: []);
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `Couldn't copy to the clipboard. The selection may be too large`
  String get clipboardWriteFailed {
    return Intl.message(
      'Couldn\'t copy to the clipboard. The selection may be too large',
      name: 'clipboardWriteFailed',
      desc: '',
      args: [],
    );
  }

  /// `Paste`
  String get paste {
    return Intl.message('Paste', name: 'paste', desc: '', args: []);
  }

  /// `Test URL`
  String get testUrl {
    return Intl.message('Test URL', name: 'testUrl', desc: '', args: []);
  }

  /// `Sync`
  String get sync {
    return Intl.message('Sync', name: 'sync', desc: '', args: []);
  }

  /// `Hide from recent tasks`
  String get exclude {
    return Intl.message(
      'Hide from recent tasks',
      name: 'exclude',
      desc: '',
      args: [],
    );
  }

  /// `Compact`
  String get compact {
    return Intl.message('Compact', name: 'compact', desc: '', args: []);
  }

  /// `Tab`
  String get tab {
    return Intl.message('Tab', name: 'tab', desc: '', args: []);
  }

  /// `List`
  String get list {
    return Intl.message('List', name: 'list', desc: '', args: []);
  }

  /// `Delay`
  String get delay {
    return Intl.message('Delay', name: 'delay', desc: '', args: []);
  }

  /// `Style`
  String get style {
    return Intl.message('Style', name: 'style', desc: '', args: []);
  }

  /// `Size`
  String get size {
    return Intl.message('Size', name: 'size', desc: '', args: []);
  }

  /// `Sort`
  String get sort {
    return Intl.message('Sort', name: 'sort', desc: '', args: []);
  }

  /// `Columns`
  String get columns {
    return Intl.message('Columns', name: 'columns', desc: '', args: []);
  }

  /// `Proxy group`
  String get proxyGroup {
    return Intl.message('Proxy group', name: 'proxyGroup', desc: '', args: []);
  }

  /// `Go`
  String get go {
    return Intl.message('Go', name: 'go', desc: '', args: []);
  }

  /// `External link`
  String get externalLink {
    return Intl.message(
      'External link',
      name: 'externalLink',
      desc: '',
      args: [],
    );
  }

  /// `Other contributors`
  String get otherContributors {
    return Intl.message(
      'Other contributors',
      name: 'otherContributors',
      desc: '',
      args: [],
    );
  }

  /// `App icon design`
  String get appIconDesign {
    return Intl.message(
      'App icon design',
      name: 'appIconDesign',
      desc: '',
      args: [],
    );
  }

  /// `Auto close connections`
  String get autoCloseConnections {
    return Intl.message(
      'Auto close connections',
      name: 'autoCloseConnections',
      desc: '',
      args: [],
    );
  }

  /// `Auto close connections drops open connections when you switch proxies.`
  String get autoCloseConnectionsDesc {
    return Intl.message(
      'Auto close connections drops open connections when you switch proxies.',
      name: 'autoCloseConnectionsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Only count proxy traffic`
  String get onlyStatisticsProxy {
    return Intl.message(
      'Only count proxy traffic',
      name: 'onlyStatisticsProxy',
      desc: '',
      args: [],
    );
  }

  /// `Stop button in notification`
  String get showNotificationStopAction {
    return Intl.message(
      'Stop button in notification',
      name: 'showNotificationStopAction',
      desc: '',
      args: [],
    );
  }

  /// `Pure black mode`
  String get pureBlackMode {
    return Intl.message(
      'Pure black mode',
      name: 'pureBlackMode',
      desc: '',
      args: [],
    );
  }

  /// `Sidebar blur`
  String get sidebarBlur {
    return Intl.message(
      'Sidebar blur',
      name: 'sidebarBlur',
      desc: '',
      args: [],
    );
  }

  /// `Show the blurred desktop behind the window through the sidebar`
  String get sidebarBlurDesc {
    return Intl.message(
      'Show the blurred desktop behind the window through the sidebar',
      name: 'sidebarBlurDesc',
      desc: '',
      args: [],
    );
  }

  /// `Liquid Glass`
  String get liquidGlass {
    return Intl.message(
      'Liquid Glass',
      name: 'liquidGlass',
      desc: '',
      args: [],
    );
  }

  /// `TCP keep-alive interval`
  String get keepAliveIntervalDesc {
    return Intl.message(
      'TCP keep-alive interval',
      name: 'keepAliveIntervalDesc',
      desc: '',
      args: [],
    );
  }

  /// ` entries`
  String get entries {
    return Intl.message(' entries', name: 'entries', desc: '', args: []);
  }

  /// `Local`
  String get local {
    return Intl.message('Local', name: 'local', desc: '', args: []);
  }

  /// `Remote`
  String get remote {
    return Intl.message('Remote', name: 'remote', desc: '', args: []);
  }

  /// `Mode`
  String get mode {
    return Intl.message('Mode', name: 'mode', desc: '', args: []);
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `Source`
  String get source {
    return Intl.message('Source', name: 'source', desc: '', args: []);
  }

  /// `Action`
  String get action {
    return Intl.message('Action', name: 'action', desc: '', args: []);
  }

  /// `Smart selection`
  String get intelligentSelected {
    return Intl.message(
      'Smart selection',
      name: 'intelligentSelected',
      desc: '',
      args: [],
    );
  }

  /// `Import from clipboard`
  String get clipboardImport {
    return Intl.message(
      'Import from clipboard',
      name: 'clipboardImport',
      desc: '',
      args: [],
    );
  }

  /// `Export to clipboard`
  String get clipboardExport {
    return Intl.message(
      'Export to clipboard',
      name: 'clipboardExport',
      desc: '',
      args: [],
    );
  }

  /// `Layout`
  String get layout {
    return Intl.message('Layout', name: 'layout', desc: '', args: []);
  }

  /// `Tight`
  String get tight {
    return Intl.message('Tight', name: 'tight', desc: '', args: []);
  }

  /// `Standard`
  String get standard {
    return Intl.message('Standard', name: 'standard', desc: '', args: []);
  }

  /// `Ultra`
  String get ultra {
    return Intl.message('Ultra', name: 'ultra', desc: '', args: []);
  }

  /// `Loose`
  String get loose {
    return Intl.message('Loose', name: 'loose', desc: '', args: []);
  }

  /// `Sort profiles`
  String get profilesSort {
    return Intl.message(
      'Sort profiles',
      name: 'profilesSort',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message('Start', name: 'start', desc: '', args: []);
  }

  /// `Run time`
  String get runTime {
    return Intl.message('Run time', name: 'runTime', desc: '', args: []);
  }

  /// `Stop`
  String get stop {
    return Intl.message('Stop', name: 'stop', desc: '', args: []);
  }

  /// `Key`
  String get key {
    return Intl.message('Key', name: 'key', desc: '', args: []);
  }

  /// `Value`
  String get value {
    return Intl.message('Value', name: 'value', desc: '', args: []);
  }

  /// `VPN routes all system traffic through VpnService automatically.`
  String get vpnEnableDesc {
    return Intl.message(
      'VPN routes all system traffic through VpnService automatically.',
      name: 'vpnEnableDesc',
      desc: '',
      args: [],
    );
  }

  /// `Options`
  String get options {
    return Intl.message('Options', name: 'options', desc: '', args: []);
  }

  /// `Enabled`
  String get enabled {
    return Intl.message('Enabled', name: 'enabled', desc: '', args: []);
  }

  /// `Disabled`
  String get disabled {
    return Intl.message('Disabled', name: 'disabled', desc: '', args: []);
  }

  /// `UWP loopback exemption`
  String get loopback {
    return Intl.message(
      'UWP loopback exemption',
      name: 'loopback',
      desc: '',
      args: [],
    );
  }

  /// `External resources`
  String get providers {
    return Intl.message(
      'External resources',
      name: 'providers',
      desc: '',
      args: [],
    );
  }

  /// `Proxy providers`
  String get proxyProviders {
    return Intl.message(
      'Proxy providers',
      name: 'proxyProviders',
      desc: '',
      args: [],
    );
  }

  /// `Rule providers`
  String get ruleProviders {
    return Intl.message(
      'Rule providers',
      name: 'ruleProviders',
      desc: '',
      args: [],
    );
  }

  /// `Only remote providers are supported`
  String get providerUrlTip {
    return Intl.message(
      'Only remote providers are supported',
      name: 'providerUrlTip',
      desc: '',
      args: [],
    );
  }

  /// `The rule set has no usable entries`
  String get ruleSetEmptyTip {
    return Intl.message(
      'The rule set has no usable entries',
      name: 'ruleSetEmptyTip',
      desc: '',
      args: [],
    );
  }

  /// `The rule set mixes domains and IP ranges, so its type cannot be told`
  String get ruleSetMixedTip {
    return Intl.message(
      'The rule set mixes domains and IP ranges, so its type cannot be told',
      name: 'ruleSetMixedTip',
      desc: '',
      args: [],
    );
  }

  /// `This mrs file cannot be read`
  String get ruleSetInvalidTip {
    return Intl.message(
      'This mrs file cannot be read',
      name: 'ruleSetInvalidTip',
      desc: '',
      args: [],
    );
  }

  /// `Subscription info`
  String get subscriptionInfo {
    return Intl.message(
      'Subscription info',
      name: 'subscriptionInfo',
      desc: '',
      args: [],
    );
  }

  /// `NTP takes the time from an NTP server instead of the system clock.`
  String get ntpStatusDesc {
    return Intl.message(
      'NTP takes the time from an NTP server instead of the system clock.',
      name: 'ntpStatusDesc',
      desc: '',
      args: [],
    );
  }

  /// `Server`
  String get server {
    return Intl.message('Server', name: 'server', desc: '', args: []);
  }

  /// `Sync interval (minutes)`
  String get ntpInterval {
    return Intl.message(
      'Sync interval (minutes)',
      name: 'ntpInterval',
      desc: '',
      args: [],
    );
  }

  /// `Dialer proxy`
  String get dialerProxy {
    return Intl.message(
      'Dialer proxy',
      name: 'dialerProxy',
      desc: '',
      args: [],
    );
  }

  /// `Dialer proxy is the outbound used to reach the NTP server.`
  String get dialerProxyDesc {
    return Intl.message(
      'Dialer proxy is the outbound used to reach the NTP server.',
      name: 'dialerProxyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Write to system`
  String get writeToSystem {
    return Intl.message(
      'Write to system',
      name: 'writeToSystem',
      desc: '',
      args: [],
    );
  }

  /// `Write to system also sets the system clock; Android ignores it.`
  String get writeToSystemDesc {
    return Intl.message(
      'Write to system also sets the system clock; Android ignores it.',
      name: 'writeToSystemDesc',
      desc: '',
      args: [],
    );
  }

  /// `Sniffer`
  String get sniffer {
    return Intl.message('Sniffer', name: 'sniffer', desc: '', args: []);
  }

  /// `The sniffer reads the domain from TLS, HTTP and QUIC traffic so rules can match it.`
  String get snifferStatusDesc {
    return Intl.message(
      'The sniffer reads the domain from TLS, HTTP and QUIC traffic so rules can match it.',
      name: 'snifferStatusDesc',
      desc: '',
      args: [],
    );
  }

  /// `Override destination`
  String get overrideDestination {
    return Intl.message(
      'Override destination',
      name: 'overrideDestination',
      desc: '',
      args: [],
    );
  }

  /// `Override destination connects to the sniffed domain instead of the original address.`
  String get overrideDestinationDesc {
    return Intl.message(
      'Override destination connects to the sniffed domain instead of the original address.',
      name: 'overrideDestinationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Force DNS mapping`
  String get forceDnsMapping {
    return Intl.message(
      'Force DNS mapping',
      name: 'forceDnsMapping',
      desc: '',
      args: [],
    );
  }

  /// `Force DNS mapping also sniffs connections whose domain came from a DNS mapping.`
  String get forceDnsMappingDesc {
    return Intl.message(
      'Force DNS mapping also sniffs connections whose domain came from a DNS mapping.',
      name: 'forceDnsMappingDesc',
      desc: '',
      args: [],
    );
  }

  /// `Parse pure IP`
  String get parsePureIp {
    return Intl.message(
      'Parse pure IP',
      name: 'parsePureIp',
      desc: '',
      args: [],
    );
  }

  /// `Parse pure IP sniffs connections that carry only an IP address.`
  String get parsePureIpDesc {
    return Intl.message(
      'Parse pure IP sniffs connections that carry only an IP address.',
      name: 'parsePureIpDesc',
      desc: '',
      args: [],
    );
  }

  /// `Force domains`
  String get forceDomain {
    return Intl.message(
      'Force domains',
      name: 'forceDomain',
      desc: '',
      args: [],
    );
  }

  /// `Force domains are sniffed too; other connections that already have a domain are left alone.`
  String get forceDomainDesc {
    return Intl.message(
      'Force domains are sniffed too; other connections that already have a domain are left alone.',
      name: 'forceDomainDesc',
      desc: '',
      args: [],
    );
  }

  /// `Skip domains`
  String get skipDomain {
    return Intl.message('Skip domains', name: 'skipDomain', desc: '', args: []);
  }

  /// `A sniffed domain on the Skip domains list is not used.`
  String get skipDomainDesc {
    return Intl.message(
      'A sniffed domain on the Skip domains list is not used.',
      name: 'skipDomainDesc',
      desc: '',
      args: [],
    );
  }

  /// `Skip source addresses`
  String get skipSrcAddress {
    return Intl.message(
      'Skip source addresses',
      name: 'skipSrcAddress',
      desc: '',
      args: [],
    );
  }

  /// `Skip destination addresses`
  String get skipDstAddress {
    return Intl.message(
      'Skip destination addresses',
      name: 'skipDstAddress',
      desc: '',
      args: [],
    );
  }

  /// `Protocols`
  String get sniffProtocols {
    return Intl.message(
      'Protocols',
      name: 'sniffProtocols',
      desc: '',
      args: [],
    );
  }

  /// `Ports`
  String get ports {
    return Intl.message('Ports', name: 'ports', desc: '', args: []);
  }

  /// `Override entries`
  String get overrideEntries {
    return Intl.message(
      'Override entries',
      name: 'overrideEntries',
      desc: '',
      args: [],
    );
  }

  /// `Add override entry`
  String get addOverrideEntry {
    return Intl.message(
      'Add override entry',
      name: 'addOverrideEntry',
      desc: '',
      args: [],
    );
  }

  /// `Entries added here replace the DNS of every URL and file profile; anything not added keeps the profile's own setting. Custom profiles set their DNS in their content.`
  String get dnsOverrideDesc {
    return Intl.message(
      'Entries added here replace the DNS of every URL and file profile; anything not added keeps the profile\'s own setting. Custom profiles set their DNS in their content.',
      name: 'dnsOverrideDesc',
      desc: '',
      args: [],
    );
  }

  /// `settings`
  String get settingEntries {
    return Intl.message('settings', name: 'settingEntries', desc: '', args: []);
  }

  /// `Add setting`
  String get addSettingEntry {
    return Intl.message(
      'Add setting',
      name: 'addSettingEntry',
      desc: '',
      args: [],
    );
  }

  /// `Applies to this profile only; anything not added uses its default.`
  String get profileSettingsDesc {
    return Intl.message(
      'Applies to this profile only; anything not added uses its default.',
      name: 'profileSettingsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Health check`
  String get healthCheck {
    return Intl.message(
      'Health check',
      name: 'healthCheck',
      desc: '',
      args: [],
    );
  }

  /// `Discard the changes?`
  String get discardChanges {
    return Intl.message(
      'Discard the changes?',
      name: 'discardChanges',
      desc: '',
      args: [],
    );
  }

  /// `Quick edit`
  String get quickEdit {
    return Intl.message('Quick edit', name: 'quickEdit', desc: '', args: []);
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `With DNS off, the system DNS is used.`
  String get statusDesc {
    return Intl.message(
      'With DNS off, the system DNS is used.',
      name: 'statusDesc',
      desc: '',
      args: [],
    );
  }

  /// `Respect rules`
  String get respectRules {
    return Intl.message(
      'Respect rules',
      name: 'respectRules',
      desc: '',
      args: [],
    );
  }

  /// `Respect rules routes DNS connections by the rules and needs a Proxy Server Nameserver.`
  String get respectRulesDesc {
    return Intl.message(
      'Respect rules routes DNS connections by the rules and needs a Proxy Server Nameserver.',
      name: 'respectRulesDesc',
      desc: '',
      args: [],
    );
  }

  /// `DNS mode`
  String get dnsMode {
    return Intl.message('DNS mode', name: 'dnsMode', desc: '', args: []);
  }

  /// `Fake-IP range`
  String get fakeipRange {
    return Intl.message(
      'Fake-IP range',
      name: 'fakeipRange',
      desc: '',
      args: [],
    );
  }

  /// `Fake-IP filter`
  String get fakeipFilter {
    return Intl.message(
      'Fake-IP filter',
      name: 'fakeipFilter',
      desc: '',
      args: [],
    );
  }

  /// `Use hosts`
  String get useHosts {
    return Intl.message('Use hosts', name: 'useHosts', desc: '', args: []);
  }

  /// `Use system hosts`
  String get useSystemHosts {
    return Intl.message(
      'Use system hosts',
      name: 'useSystemHosts',
      desc: '',
      args: [],
    );
  }

  /// `Fallback filter`
  String get fallbackFilter {
    return Intl.message(
      'Fallback filter',
      name: 'fallbackFilter',
      desc: '',
      args: [],
    );
  }

  /// `Domain`
  String get domain {
    return Intl.message('Domain', name: 'domain', desc: '', args: []);
  }

  /// `Listen routing mark`
  String get listenRoutingMark {
    return Intl.message(
      'Listen routing mark',
      name: 'listenRoutingMark',
      desc: '',
      args: [],
    );
  }

  /// `Listen routing mark works only on Linux.`
  String get listenRoutingMarkDesc {
    return Intl.message(
      'Listen routing mark works only on Linux.',
      name: 'listenRoutingMarkDesc',
      desc: '',
      args: [],
    );
  }

  /// `IPv6 timeout (ms)`
  String get ipv6Timeout {
    return Intl.message(
      'IPv6 timeout (ms)',
      name: 'ipv6Timeout',
      desc: '',
      args: [],
    );
  }

  /// `Cache algorithm`
  String get cacheAlgorithm {
    return Intl.message(
      'Cache algorithm',
      name: 'cacheAlgorithm',
      desc: '',
      args: [],
    );
  }

  /// `Cache size`
  String get cacheMaxSize {
    return Intl.message('Cache size', name: 'cacheMaxSize', desc: '', args: []);
  }

  /// `Fake-IP range (IPv6)`
  String get fakeipRange6 {
    return Intl.message(
      'Fake-IP range (IPv6)',
      name: 'fakeipRange6',
      desc: '',
      args: [],
    );
  }

  /// `Fake-IP filter mode`
  String get fakeipFilterMode {
    return Intl.message(
      'Fake-IP filter mode',
      name: 'fakeipFilterMode',
      desc: '',
      args: [],
    );
  }

  /// `In Fake-IP filter mode, blacklist excludes matches, whitelist fakes only matches, and rule matches as rules.`
  String get fakeipFilterModeDesc {
    return Intl.message(
      'In Fake-IP filter mode, blacklist excludes matches, whitelist fakes only matches, and rule matches as rules.',
      name: 'fakeipFilterModeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Fake-IP TTL`
  String get fakeipTtl {
    return Intl.message('Fake-IP TTL', name: 'fakeipTtl', desc: '', args: []);
  }

  /// `Reset`
  String get reset {
    return Intl.message('Reset', name: 'reset', desc: '', args: []);
  }

  /// `Show/Hide`
  String get actionView {
    return Intl.message('Show/Hide', name: 'actionView', desc: '', args: []);
  }

  /// `Start/Stop`
  String get actionStart {
    return Intl.message('Start/Stop', name: 'actionStart', desc: '', args: []);
  }

  /// `Switch mode`
  String get actionMode {
    return Intl.message('Switch mode', name: 'actionMode', desc: '', args: []);
  }

  /// `System proxy`
  String get actionProxy {
    return Intl.message(
      'System proxy',
      name: 'actionProxy',
      desc: '',
      args: [],
    );
  }

  /// `TUN`
  String get actionTun {
    return Intl.message('TUN', name: 'actionTun', desc: '', args: []);
  }

  /// `Rule mode`
  String get actionRuleMode {
    return Intl.message(
      'Rule mode',
      name: 'actionRuleMode',
      desc: '',
      args: [],
    );
  }

  /// `Global mode`
  String get actionGlobalMode {
    return Intl.message(
      'Global mode',
      name: 'actionGlobalMode',
      desc: '',
      args: [],
    );
  }

  /// `Direct mode`
  String get actionDirectMode {
    return Intl.message(
      'Direct mode',
      name: 'actionDirectMode',
      desc: '',
      args: [],
    );
  }

  /// `Test all delays`
  String get actionDelayTest {
    return Intl.message(
      'Test all delays',
      name: 'actionDelayTest',
      desc: '',
      args: [],
    );
  }

  /// `Update profiles`
  String get actionUpdateProfiles {
    return Intl.message(
      'Update profiles',
      name: 'actionUpdateProfiles',
      desc: '',
      args: [],
    );
  }

  /// `Disclaimer`
  String get disclaimer {
    return Intl.message('Disclaimer', name: 'disclaimer', desc: '', args: []);
  }

  /// `Before using ReClash ("the Software"), please read this statement carefully and make sure you understand all of it. Tapping "Agree" means you have read, understood, and accept every term below. If you do not agree, tap "Exit" and stop using the Software.`
  String get disclaimerDesc {
    return Intl.message(
      'Before using ReClash ("the Software"), please read this statement carefully and make sure you understand all of it. Tapping "Agree" means you have read, understood, and accept every term below. If you do not agree, tap "Exit" and stop using the Software.',
      name: 'disclaimerDesc',
      desc: '',
      args: [],
    );
  }

  /// `Nature of the software`
  String get disclaimerSoftwareTitle {
    return Intl.message(
      'Nature of the software',
      name: 'disclaimerSoftwareTitle',
      desc: '',
      args: [],
    );
  }

  /// `The Software is an open-source network proxy client built on the Clash.Meta (mihomo) core. It only provides local tooling such as configuration management, rule-based routing, and traffic forwarding.`
  String get disclaimerSoftwareContent {
    return Intl.message(
      'The Software is an open-source network proxy client built on the Clash.Meta (mihomo) core. It only provides local tooling such as configuration management, rule-based routing, and traffic forwarding.',
      name: 'disclaimerSoftwareContent',
      desc: '',
      args: [],
    );
  }

  /// `The Software itself does not provide any proxy server, node, subscription, or network access service, and has no partnership, agency, or guarantee relationship with any provider of such services.`
  String get disclaimerNoServiceStatement {
    return Intl.message(
      'The Software itself does not provide any proxy server, node, subscription, or network access service, and has no partnership, agency, or guarantee relationship with any provider of such services.',
      name: 'disclaimerNoServiceStatement',
      desc: '',
      args: [],
    );
  }

  /// `Restrictions on use`
  String get disclaimerUsageTitle {
    return Intl.message(
      'Restrictions on use',
      name: 'disclaimerUsageTitle',
      desc: '',
      args: [],
    );
  }

  /// `The Software is intended only for non-commercial uses such as learning, exchange, and technical research. Using it for any commercial purpose is strictly prohibited, including but not limited to paid distribution, bundled sales, use as part of a commercial service, or doing business in the name of the Software. Any commercial activity is unrelated to the Software and its developers.\n\nUsing the Software for anything that violates the laws and regulations of your country or region is strictly prohibited, including but not limited to bypassing lawfully imposed network access restrictions, spreading illegal content, launching network attacks, or infringing the lawful rights of others.`
  String get disclaimerUsageContent {
    return Intl.message(
      'The Software is intended only for non-commercial uses such as learning, exchange, and technical research. Using it for any commercial purpose is strictly prohibited, including but not limited to paid distribution, bundled sales, use as part of a commercial service, or doing business in the name of the Software. Any commercial activity is unrelated to the Software and its developers.\n\nUsing the Software for anything that violates the laws and regulations of your country or region is strictly prohibited, including but not limited to bypassing lawfully imposed network access restrictions, spreading illegal content, launching network attacks, or infringing the lawful rights of others.',
      name: 'disclaimerUsageContent',
      desc: '',
      args: [],
    );
  }

  /// `Your responsibility`
  String get disclaimerResponsibilityTitle {
    return Intl.message(
      'Your responsibility',
      name: 'disclaimerResponsibilityTitle',
      desc: '',
      args: [],
    );
  }

  /// `You are responsible for making sure that using the Software is lawful where you live, and you alone bear the legal responsibility for everything you do with it and its consequences.\n\nThe subscriptions, nodes, and configurations you import are your own choice. Whether their source is lawful, their content is safe, and their service is reliable is a matter between you and their providers.`
  String get disclaimerResponsibilityContent {
    return Intl.message(
      'You are responsible for making sure that using the Software is lawful where you live, and you alone bear the legal responsibility for everything you do with it and its consequences.\n\nThe subscriptions, nodes, and configurations you import are your own choice. Whether their source is lawful, their content is safe, and their service is reliable is a matter between you and their providers.',
      name: 'disclaimerResponsibilityContent',
      desc: '',
      args: [],
    );
  }

  /// `Third-party content`
  String get disclaimerThirdPartyTitle {
    return Intl.message(
      'Third-party content',
      name: 'disclaimerThirdPartyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Subscription links, configuration files, rule sets, scripts, external resources, and external links are all provided by third parties. The developers cannot and do not review or guarantee their legality, accuracy, security, or availability.\n\nAny data leak, financial loss, account ban, or other loss caused by third-party content is to be settled between you and the third party; the developers bear no responsibility for it.`
  String get disclaimerThirdPartyContent {
    return Intl.message(
      'Subscription links, configuration files, rule sets, scripts, external resources, and external links are all provided by third parties. The developers cannot and do not review or guarantee their legality, accuracy, security, or availability.\n\nAny data leak, financial loss, account ban, or other loss caused by third-party content is to be settled between you and the third party; the developers bear no responsibility for it.',
      name: 'disclaimerThirdPartyContent',
      desc: '',
      args: [],
    );
  }

  /// `No warranty`
  String get disclaimerWarrantyTitle {
    return Intl.message(
      'No warranty',
      name: 'disclaimerWarrantyTitle',
      desc: '',
      args: [],
    );
  }

  /// `The Software is provided "as is" and "as available", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, non-infringement, uninterrupted availability, freedom from errors, or freedom from security vulnerabilities.\n\nThe developers do not guarantee that the Software will meet your needs or that it will run without interruption or error.`
  String get disclaimerWarrantyContent {
    return Intl.message(
      'The Software is provided "as is" and "as available", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, non-infringement, uninterrupted availability, freedom from errors, or freedom from security vulnerabilities.\n\nThe developers do not guarantee that the Software will meet your needs or that it will run without interruption or error.',
      name: 'disclaimerWarrantyContent',
      desc: '',
      args: [],
    );
  }

  /// `Limitation of liability`
  String get disclaimerLiabilityTitle {
    return Intl.message(
      'Limitation of liability',
      name: 'disclaimerLiabilityTitle',
      desc: '',
      args: [],
    );
  }

  /// `To the maximum extent permitted by applicable law, neither the developers nor any contributor shall be liable for any direct, indirect, incidental, special, punitive, or consequential damages arising from the use of or inability to use the Software, including but not limited to data loss, device damage, network failures, business interruption, lost profits, or any resulting legal dispute, even if advised of the possibility of such damages.`
  String get disclaimerLiabilityContent {
    return Intl.message(
      'To the maximum extent permitted by applicable law, neither the developers nor any contributor shall be liable for any direct, indirect, incidental, special, punitive, or consequential damages arising from the use of or inability to use the Software, including but not limited to data loss, device damage, network failures, business interruption, lost profits, or any resulting legal dispute, even if advised of the possibility of such damages.',
      name: 'disclaimerLiabilityContent',
      desc: '',
      args: [],
    );
  }

  /// `Data collection and privacy`
  String get disclaimerPrivacyTitle {
    return Intl.message(
      'Data collection and privacy',
      name: 'disclaimerPrivacyTitle',
      desc: '',
      args: [],
    );
  }

  /// `The Software does not collect or upload your subscription URLs, node details, configuration content, visited websites, connection records, traffic content, or logs. This data stays on your device and the developers have no access to it.\n\nThe Software only reaches the network when you use a feature that needs it, such as fetching the subscription URL you provided when updating a profile, or contacting GitHub when checking for updates.\n\nThe Software includes no analytics or crash reporting service on any platform.`
  String get disclaimerPrivacyContent {
    return Intl.message(
      'The Software does not collect or upload your subscription URLs, node details, configuration content, visited websites, connection records, traffic content, or logs. This data stays on your device and the developers have no access to it.\n\nThe Software only reaches the network when you use a feature that needs it, such as fetching the subscription URL you provided when updating a profile, or contacting GitHub when checking for updates.\n\nThe Software includes no analytics or crash reporting service on any platform.',
      name: 'disclaimerPrivacyContent',
      desc: '',
      args: [],
    );
  }

  /// `Open-source license`
  String get disclaimerLicenseTitle {
    return Intl.message(
      'Open-source license',
      name: 'disclaimerLicenseTitle',
      desc: '',
      args: [],
    );
  }

  /// `The Software is open source under the GPL-3.0 license. You may use, modify, and distribute it freely as long as you comply with that license, which requires derivative works to be released under GPL-3.0 as well and the original copyright notices to be kept.\n\nThird-party components in the Software, including the Clash.Meta core, follow their own licenses. The original authors are not responsible for any issue arising from modified or redistributed versions.`
  String get disclaimerLicenseContent {
    return Intl.message(
      'The Software is open source under the GPL-3.0 license. You may use, modify, and distribute it freely as long as you comply with that license, which requires derivative works to be released under GPL-3.0 as well and the original copyright notices to be kept.\n\nThird-party components in the Software, including the Clash.Meta core, follow their own licenses. The original authors are not responsible for any issue arising from modified or redistributed versions.',
      name: 'disclaimerLicenseContent',
      desc: '',
      args: [],
    );
  }

  /// `Changes to this statement`
  String get disclaimerChangesTitle {
    return Intl.message(
      'Changes to this statement',
      name: 'disclaimerChangesTitle',
      desc: '',
      args: [],
    );
  }

  /// `The developers may revise this statement with any release, and the revision takes effect when that release is published. Continuing to use the Software after updating means you accept the revised statement.`
  String get disclaimerChangesContent {
    return Intl.message(
      'The developers may revise this statement with any release, and the revision takes effect when that release is published. Continuing to use the Software after updating means you accept the revised statement.',
      name: 'disclaimerChangesContent',
      desc: '',
      args: [],
    );
  }

  /// `Acceptance`
  String get disclaimerAcceptTitle {
    return Intl.message(
      'Acceptance',
      name: 'disclaimerAcceptTitle',
      desc: '',
      args: [],
    );
  }

  /// `By installing, copying, or using the Software, you are deemed to have read and agreed to this entire statement. If you disagree with any of its terms, stop using and uninstall the Software immediately.`
  String get disclaimerAcceptContent {
    return Intl.message(
      'By installing, copying, or using the Software, you are deemed to have read and agreed to this entire statement. If you disagree with any of its terms, stop using and uninstall the Software immediately.',
      name: 'disclaimerAcceptContent',
      desc: '',
      args: [],
    );
  }

  /// `Restate the statement`
  String get disclaimerRestateTitle {
    return Intl.message(
      'Restate the statement',
      name: 'disclaimerRestateTitle',
      desc: '',
      args: [],
    );
  }

  /// `To confirm you understand, enter the following statement in full in the field below:`
  String get disclaimerRestateTip {
    return Intl.message(
      'To confirm you understand, enter the following statement in full in the field below:',
      name: 'disclaimerRestateTip',
      desc: '',
      args: [],
    );
  }

  /// `Enter the statement above`
  String get disclaimerRestateHint {
    return Intl.message(
      'Enter the statement above',
      name: 'disclaimerRestateHint',
      desc: '',
      args: [],
    );
  }

  /// `Does not match the statement`
  String get disclaimerRestateMismatch {
    return Intl.message(
      'Does not match the statement',
      name: 'disclaimerRestateMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Confirm the statement`
  String get disclaimerAcknowledgeTitle {
    return Intl.message(
      'Confirm the statement',
      name: 'disclaimerAcknowledgeTitle',
      desc: '',
      args: [],
    );
  }

  /// `To confirm you understand, read the following statement and check the box below:`
  String get disclaimerAcknowledgeTip {
    return Intl.message(
      'To confirm you understand, read the following statement and check the box below:',
      name: 'disclaimerAcknowledgeTip',
      desc: '',
      args: [],
    );
  }

  /// `I have read and understand this statement`
  String get disclaimerAcknowledgeLabel {
    return Intl.message(
      'I have read and understand this statement',
      name: 'disclaimerAcknowledgeLabel',
      desc: '',
      args: [],
    );
  }

  /// `Agree`
  String get agree {
    return Intl.message('Agree', name: 'agree', desc: '', args: []);
  }

  /// `Hotkey management`
  String get hotkeyManagement {
    return Intl.message(
      'Hotkey management',
      name: 'hotkeyManagement',
      desc: '',
      args: [],
    );
  }

  /// `Global hotkeys work even while the window is hidden. Tap an action to record its key combination.`
  String get hotkeyDesc {
    return Intl.message(
      'Global hotkeys work even while the window is hidden. Tap an action to record its key combination.',
      name: 'hotkeyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Not set`
  String get hotkeyNotSet {
    return Intl.message('Not set', name: 'hotkeyNotSet', desc: '', args: []);
  }

  /// `Press a key combination`
  String get pressKeyboard {
    return Intl.message(
      'Press a key combination',
      name: 'pressKeyboard',
      desc: '',
      args: [],
    );
  }

  /// `Include at least one of {modifiers}`
  String hotkeyNeedsModifier(Object modifiers) {
    return Intl.message(
      'Include at least one of $modifiers',
      name: 'hotkeyNeedsModifier',
      desc: '',
      args: [modifiers],
    );
  }

  /// `Already used by “{action}”. Saving moves it here.`
  String hotkeyConflictWith(Object action) {
    return Intl.message(
      'Already used by “$action”. Saving moves it here.',
      name: 'hotkeyConflictWith',
      desc: '',
      args: [action],
    );
  }

  /// `Not registered, it may be taken by another app`
  String get hotkeyUnavailable {
    return Intl.message(
      'Not registered, it may be taken by another app',
      name: 'hotkeyUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `No network`
  String get noNetwork {
    return Intl.message('No network', name: 'noNetwork', desc: '', args: []);
  }

  /// `With IPv6 on, the VPN allows IPv6 inbound.`
  String get ipv6InboundDesc {
    return Intl.message(
      'With IPv6 on, the VPN allows IPv6 inbound.',
      name: 'ipv6InboundDesc',
      desc: '',
      args: [],
    );
  }

  /// `Export logs`
  String get exportLogs {
    return Intl.message('Export logs', name: 'exportLogs', desc: '', args: []);
  }

  /// `Export successful`
  String get exportSuccess {
    return Intl.message(
      'Export successful',
      name: 'exportSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Icon style`
  String get iconStyle {
    return Intl.message('Icon style', name: 'iconStyle', desc: '', args: []);
  }

  /// `Filled`
  String get iconStyleFilled {
    return Intl.message('Filled', name: 'iconStyleFilled', desc: '', args: []);
  }

  /// `Plain`
  String get iconStylePlain {
    return Intl.message('Plain', name: 'iconStylePlain', desc: '', args: []);
  }

  /// `Hidden`
  String get iconStyleHidden {
    return Intl.message('Hidden', name: 'iconStyleHidden', desc: '', args: []);
  }

  /// `Filter`
  String get filter {
    return Intl.message('Filter', name: 'filter', desc: '', args: []);
  }

  /// `Hide timed-out proxies`
  String get hideTimeoutProxies {
    return Intl.message(
      'Hide timed-out proxies',
      name: 'hideTimeoutProxies',
      desc: '',
      args: [],
    );
  }

  /// `Leave out proxies whose last delay test timed out`
  String get hideTimeoutProxiesDesc {
    return Intl.message(
      'Leave out proxies whose last delay test timed out',
      name: 'hideTimeoutProxiesDesc',
      desc: '',
      args: [],
    );
  }

  /// `Stack mode`
  String get stackMode {
    return Intl.message('Stack mode', name: 'stackMode', desc: '', args: []);
  }

  /// `Network`
  String get network {
    return Intl.message('Network', name: 'network', desc: '', args: []);
  }

  /// `Bypass domains`
  String get bypassDomain {
    return Intl.message(
      'Bypass domains',
      name: 'bypassDomain',
      desc: '',
      args: [],
    );
  }

  /// `Bypass domains apply only while the system proxy is on.`
  String get bypassDomainDesc {
    return Intl.message(
      'Bypass domains apply only while the system proxy is on.',
      name: 'bypassDomainDesc',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to reset?`
  String get resetTip {
    return Intl.message(
      'Are you sure you want to reset?',
      name: 'resetTip',
      desc: '',
      args: [],
    );
  }

  /// `Icon`
  String get icon {
    return Intl.message('Icon', name: 'icon', desc: '', args: []);
  }

  /// `No data`
  String get noData {
    return Intl.message('No data', name: 'noData', desc: '', args: []);
  }

  /// `Font family`
  String get fontFamily {
    return Intl.message('Font family', name: 'fontFamily', desc: '', args: []);
  }

  /// `Installed fonts`
  String get installedFonts {
    return Intl.message(
      'Installed fonts',
      name: 'installedFonts',
      desc: '',
      args: [],
    );
  }

  /// `Toggle`
  String get toggle {
    return Intl.message('Toggle', name: 'toggle', desc: '', args: []);
  }

  /// `System`
  String get system {
    return Intl.message('System', name: 'system', desc: '', args: []);
  }

  /// `Route addresses`
  String get routeAddress {
    return Intl.message(
      'Route addresses',
      name: 'routeAddress',
      desc: '',
      args: [],
    );
  }

  /// `Outbound interface`
  String get interfaceNameMode {
    return Intl.message(
      'Outbound interface',
      name: 'interfaceNameMode',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get interfaceNameModeClear {
    return Intl.message(
      'Clear',
      name: 'interfaceNameModeClear',
      desc: '',
      args: [],
    );
  }

  /// `Follow config`
  String get interfaceNameModeFollow {
    return Intl.message(
      'Follow config',
      name: 'interfaceNameModeFollow',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get interfaceNameModeCustom {
    return Intl.message(
      'Custom',
      name: 'interfaceNameModeCustom',
      desc: '',
      args: [],
    );
  }

  /// `Interface name`
  String get interfaceName {
    return Intl.message(
      'Interface name',
      name: 'interfaceName',
      desc: '',
      args: [],
    );
  }

  /// `Interface name is the network interface outbound connections use.`
  String get interfaceNameDesc {
    return Intl.message(
      'Interface name is the network interface outbound connections use.',
      name: 'interfaceNameDesc',
      desc: '',
      args: [],
    );
  }

  /// `Copy environment variables`
  String get copyEnvVar {
    return Intl.message(
      'Copy environment variables',
      name: 'copyEnvVar',
      desc: '',
      args: [],
    );
  }

  /// `Memory info`
  String get memoryInfo {
    return Intl.message('Memory info', name: 'memoryInfo', desc: '', args: []);
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `Release memory`
  String get releaseMemory {
    return Intl.message(
      'Release memory',
      name: 'releaseMemory',
      desc: '',
      args: [],
    );
  }

  /// `Heap in use`
  String get memoryCoreHeapInuse {
    return Intl.message(
      'Heap in use',
      name: 'memoryCoreHeapInuse',
      desc: '',
      args: [],
    );
  }

  /// `Heap idle`
  String get memoryCoreHeapIdle {
    return Intl.message(
      'Heap idle',
      name: 'memoryCoreHeapIdle',
      desc: '',
      args: [],
    );
  }

  /// `Goroutine stacks`
  String get memoryCoreStack {
    return Intl.message(
      'Goroutine stacks',
      name: 'memoryCoreStack',
      desc: '',
      args: [],
    );
  }

  /// `Runtime overhead`
  String get memoryCoreRuntime {
    return Intl.message(
      'Runtime overhead',
      name: 'memoryCoreRuntime',
      desc: '',
      args: [],
    );
  }

  /// `Core is not running`
  String get memoryCoreNotRunning {
    return Intl.message(
      'Core is not running',
      name: 'memoryCoreNotRunning',
      desc: '',
      args: [],
    );
  }

  /// `Resident memory`
  String get memoryAppResident {
    return Intl.message(
      'Resident memory',
      name: 'memoryAppResident',
      desc: '',
      args: [],
    );
  }

  /// `App & shared`
  String get memoryAppShared {
    return Intl.message(
      'App & shared',
      name: 'memoryAppShared',
      desc: '',
      args: [],
    );
  }

  /// `Estimated from process resident memory; it may differ from what the system reports.`
  String get memoryEstimateDesc {
    return Intl.message(
      'Estimated from process resident memory; it may differ from what the system reports.',
      name: 'memoryEstimateDesc',
      desc: '',
      args: [],
    );
  }

  /// `The Core runs inside the app process. Its share is estimated from runtime stats, and the rest counts as app and shared memory.`
  String get memoryEstimateSharedDesc {
    return Intl.message(
      'The Core runs inside the app process. Its share is estimated from runtime stats, and the rest counts as app and shared memory.',
      name: 'memoryEstimateSharedDesc',
      desc: '',
      args: [],
    );
  }

  /// `Memory released`
  String get memoryReleased {
    return Intl.message(
      'Memory released',
      name: 'memoryReleased',
      desc: '',
      args: [],
    );
  }

  /// `Released {size}`
  String memoryReleasedSize(Object size) {
    return Intl.message(
      'Released $size',
      name: 'memoryReleasedSize',
      desc: '',
      args: [size],
    );
  }

  /// `Failed to release memory`
  String get releaseMemoryFailed {
    return Intl.message(
      'Failed to release memory',
      name: 'releaseMemoryFailed',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `The file has been modified. Save the changes?`
  String get fileIsUpdate {
    return Intl.message(
      'The file has been modified. Save the changes?',
      name: 'fileIsUpdate',
      desc: '',
      args: [],
    );
  }

  /// `The profile has been modified. Turn off auto update?`
  String get profileHasUpdate {
    return Intl.message(
      'The profile has been modified. Turn off auto update?',
      name: 'profileHasUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Cache the changes?`
  String get hasCacheChange {
    return Intl.message(
      'Cache the changes?',
      name: 'hasCacheChange',
      desc: '',
      args: [],
    );
  }

  /// `Copied successfully`
  String get copySuccess {
    return Intl.message(
      'Copied successfully',
      name: 'copySuccess',
      desc: '',
      args: [],
    );
  }

  /// `Copy link`
  String get copyLink {
    return Intl.message('Copy link', name: 'copyLink', desc: '', args: []);
  }

  /// `Export file`
  String get exportFile {
    return Intl.message('Export file', name: 'exportFile', desc: '', args: []);
  }

  /// `The cache is corrupted. Clear it?`
  String get cacheCorrupt {
    return Intl.message(
      'The cache is corrupted. Clear it?',
      name: 'cacheCorrupt',
      desc: '',
      args: [],
    );
  }

  /// `Relies on a third-party API; for reference only`
  String get detectionTip {
    return Intl.message(
      'Relies on a third-party API; for reference only',
      name: 'detectionTip',
      desc: '',
      args: [],
    );
  }

  /// `Listen`
  String get listen {
    return Intl.message('Listen', name: 'listen', desc: '', args: []);
  }

  /// `Undo`
  String get undo {
    return Intl.message('Undo', name: 'undo', desc: '', args: []);
  }

  /// `Redo`
  String get redo {
    return Intl.message('Redo', name: 'redo', desc: '', args: []);
  }

  /// `Word wrap`
  String get lineWrap {
    return Intl.message('Word wrap', name: 'lineWrap', desc: '', args: []);
  }

  /// `None`
  String get none {
    return Intl.message('None', name: 'none', desc: '', args: []);
  }

  /// `Advanced configuration`
  String get advancedConfig {
    return Intl.message(
      'Advanced configuration',
      name: 'advancedConfig',
      desc: '',
      args: [],
    );
  }

  /// `Advanced configuration holds network, DNS, added rules, and scripts.`
  String get advancedConfigDesc {
    return Intl.message(
      'Advanced configuration holds network, DNS, added rules, and scripts.',
      name: 'advancedConfigDesc',
      desc: '',
      args: [],
    );
  }

  /// `Add rule`
  String get addRule {
    return Intl.message('Add rule', name: 'addRule', desc: '', args: []);
  }

  /// `Content`
  String get content {
    return Intl.message('Content', name: 'content', desc: '', args: []);
  }

  /// `Rule target`
  String get ruleTarget {
    return Intl.message('Rule target', name: 'ruleTarget', desc: '', args: []);
  }

  /// `MATCH-TARGET`
  String get matchTarget {
    return Intl.message(
      'MATCH-TARGET',
      name: 'matchTarget',
      desc: '',
      args: [],
    );
  }

  /// `Follow profile`
  String get followProfile {
    return Intl.message(
      'Follow profile',
      name: 'followProfile',
      desc: '',
      args: [],
    );
  }

  /// `Source IP`
  String get sourceIp {
    return Intl.message('Source IP', name: 'sourceIp', desc: '', args: []);
  }

  /// `Don't resolve IP`
  String get noResolve {
    return Intl.message(
      'Don\'t resolve IP',
      name: 'noResolve',
      desc: '',
      args: [],
    );
  }

  /// `Save the changes?`
  String get saveChanges {
    return Intl.message(
      'Save the changes?',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Can't save`
  String get cannotSave {
    return Intl.message('Can\'t save', name: 'cannotSave', desc: '', args: []);
  }

  /// `Bottom bar`
  String get navigationBarStyle {
    return Intl.message(
      'Bottom bar',
      name: 'navigationBarStyle',
      desc: '',
      args: [],
    );
  }

  /// `Floating`
  String get floating {
    return Intl.message('Floating', name: 'floating', desc: '', args: []);
  }

  /// `Docked`
  String get docked {
    return Intl.message('Docked', name: 'docked', desc: '', args: []);
  }

  /// `Slide`
  String get slide {
    return Intl.message('Slide', name: 'slide', desc: '', args: []);
  }

  /// `Fade`
  String get fade {
    return Intl.message('Fade', name: 'fade', desc: '', args: []);
  }

  /// `Pure black`
  String get pureBlack {
    return Intl.message('Pure black', name: 'pureBlack', desc: '', args: []);
  }

  /// `Custom color`
  String get customColor {
    return Intl.message(
      'Custom color',
      name: 'customColor',
      desc: '',
      args: [],
    );
  }

  /// `Color style`
  String get colorStyle {
    return Intl.message('Color style', name: 'colorStyle', desc: '', args: []);
  }

  /// `Grid`
  String get grid {
    return Intl.message('Grid', name: 'grid', desc: '', args: []);
  }

  /// `Spectrum`
  String get spectrum {
    return Intl.message('Spectrum', name: 'spectrum', desc: '', args: []);
  }

  /// `Sliders`
  String get sliders {
    return Intl.message('Sliders', name: 'sliders', desc: '', args: []);
  }

  /// `Hue`
  String get hue {
    return Intl.message('Hue', name: 'hue', desc: '', args: []);
  }

  /// `Saturation`
  String get saturation {
    return Intl.message('Saturation', name: 'saturation', desc: '', args: []);
  }

  /// `Brightness`
  String get brightness {
    return Intl.message('Brightness', name: 'brightness', desc: '', args: []);
  }

  /// `Hex`
  String get hex {
    return Intl.message('Hex', name: 'hex', desc: '', args: []);
  }

  /// `Monochrome`
  String get monochromeScheme {
    return Intl.message(
      'Monochrome',
      name: 'monochromeScheme',
      desc: '',
      args: [],
    );
  }

  /// `Vivid`
  String get vividStyle {
    return Intl.message('Vivid', name: 'vividStyle', desc: '', args: []);
  }

  /// `Tinted`
  String get tintedStyle {
    return Intl.message('Tinted', name: 'tintedStyle', desc: '', args: []);
  }

  /// `Soft`
  String get softStyle {
    return Intl.message('Soft', name: 'softStyle', desc: '', args: []);
  }

  /// `Developer mode`
  String get developerMode {
    return Intl.message(
      'Developer mode',
      name: 'developerMode',
      desc: '',
      args: [],
    );
  }

  /// `Developer mode is enabled.`
  String get developerModeEnableTip {
    return Intl.message(
      'Developer mode is enabled.',
      name: 'developerModeEnableTip',
      desc: '',
      args: [],
    );
  }

  /// `Message test`
  String get messageTest {
    return Intl.message(
      'Message test',
      name: 'messageTest',
      desc: '',
      args: [],
    );
  }

  /// `This is a message.`
  String get messageTestTip {
    return Intl.message(
      'This is a message.',
      name: 'messageTestTip',
      desc: '',
      args: [],
    );
  }

  /// `Crash test`
  String get crashTest {
    return Intl.message('Crash test', name: 'crashTest', desc: '', args: []);
  }

  /// `Crash detected`
  String get crashDetected {
    return Intl.message(
      'Crash detected',
      name: 'crashDetected',
      desc: '',
      args: [],
    );
  }

  /// `The app failed to finish launching twice in a row. To break the loop, the profile {name} has been deselected and automatic setup was skipped. You can select it again at any time.`
  String crashDetectedTip(Object name) {
    return Intl.message(
      'The app failed to finish launching twice in a row. To break the loop, the profile $name has been deselected and automatic setup was skipped. You can select it again at any time.',
      name: 'crashDetectedTip',
      desc: '',
      args: [name],
    );
  }

  /// `Launch did not finish`
  String get launchInterrupted {
    return Intl.message(
      'Launch did not finish',
      name: 'launchInterrupted',
      desc: '',
      args: [],
    );
  }

  /// `The app exited unexpectedly while it was starting up last time. Automatic setup was skipped for this launch; you can start it manually to retry.`
  String get launchInterruptedTip {
    return Intl.message(
      'The app exited unexpectedly while it was starting up last time. Automatic setup was skipped for this launch; you can start it manually to retry.',
      name: 'launchInterruptedTip',
      desc: '',
      args: [],
    );
  }

  /// `Clear data`
  String get clearData {
    return Intl.message('Clear data', name: 'clearData', desc: '', args: []);
  }

  /// `Text scaling`
  String get textScale {
    return Intl.message('Text scaling', name: 'textScale', desc: '', args: []);
  }

  /// `Text in the app will look like this`
  String get textScalePreview {
    return Intl.message(
      'Text in the app will look like this',
      name: 'textScalePreview',
      desc: '',
      args: [],
    );
  }

  /// `Follow system`
  String get followSystem {
    return Intl.message(
      'Follow system',
      name: 'followSystem',
      desc: '',
      args: [],
    );
  }

  /// `Internet`
  String get internet {
    return Intl.message('Internet', name: 'internet', desc: '', args: []);
  }

  /// `System apps`
  String get systemApp {
    return Intl.message('System apps', name: 'systemApp', desc: '', args: []);
  }

  /// `No-network apps`
  String get noNetworkApp {
    return Intl.message(
      'No-network apps',
      name: 'noNetworkApp',
      desc: '',
      args: [],
    );
  }

  /// `Restore strategy`
  String get restoreStrategy {
    return Intl.message(
      'Restore strategy',
      name: 'restoreStrategy',
      desc: '',
      args: [],
    );
  }

  /// `Override`
  String get restoreStrategyOverride {
    return Intl.message(
      'Override',
      name: 'restoreStrategyOverride',
      desc: '',
      args: [],
    );
  }

  /// `Compatible`
  String get restoreStrategyCompatible {
    return Intl.message(
      'Compatible',
      name: 'restoreStrategyCompatible',
      desc: '',
      args: [],
    );
  }

  /// `Logs test`
  String get logsTest {
    return Intl.message('Logs test', name: 'logsTest', desc: '', args: []);
  }

  /// `{label} cannot be empty`
  String emptyTip(Object label) {
    return Intl.message(
      '$label cannot be empty',
      name: 'emptyTip',
      desc: '',
      args: [label],
    );
  }

  /// `{label} must be a URL`
  String urlTip(Object label) {
    return Intl.message(
      '$label must be a URL',
      name: 'urlTip',
      desc: '',
      args: [label],
    );
  }

  /// `Not a subscription link or a proxy share link`
  String get invalidLinkTip {
    return Intl.message(
      'Not a subscription link or a proxy share link',
      name: 'invalidLinkTip',
      desc: '',
      args: [],
    );
  }

  /// `{label} must be a number`
  String numberTip(Object label) {
    return Intl.message(
      '$label must be a number',
      name: 'numberTip',
      desc: '',
      args: [label],
    );
  }

  /// `{label} must be between {min} and {max}`
  String numberRangeTip(Object label, Object min, Object max) {
    return Intl.message(
      '$label must be between $min and $max',
      name: 'numberRangeTip',
      desc: '',
      args: [label, min, max],
    );
  }

  /// `Interval`
  String get interval {
    return Intl.message('Interval', name: 'interval', desc: '', args: []);
  }

  /// `{label} already exists`
  String existsTip(Object label) {
    return Intl.message(
      '$label already exists',
      name: 'existsTip',
      desc: '',
      args: [label],
    );
  }

  /// `{label} must be at most {max} characters`
  String maxLengthTip(Object label, Object max) {
    return Intl.message(
      '$label must be at most $max characters',
      name: 'maxLengthTip',
      desc: '',
      args: [label, max],
    );
  }

  /// `Single add`
  String get singleAdd {
    return Intl.message('Single add', name: 'singleAdd', desc: '', args: []);
  }

  /// `Batch add`
  String get batchAdd {
    return Intl.message('Batch add', name: 'batchAdd', desc: '', args: []);
  }

  /// `One item per line, or separated by commas`
  String get batchListInputTip {
    return Intl.message(
      'One item per line, or separated by commas',
      name: 'batchListInputTip',
      desc: '',
      args: [],
    );
  }

  /// `One entry per line: key, a space, then value`
  String get batchMapInputTip {
    return Intl.message(
      'One entry per line: key, a space, then value',
      name: 'batchMapInputTip',
      desc: '',
      args: [],
    );
  }

  /// `Single import`
  String get singleImport {
    return Intl.message(
      'Single import',
      name: 'singleImport',
      desc: '',
      args: [],
    );
  }

  /// `Batch import`
  String get batchImport {
    return Intl.message(
      'Batch import',
      name: 'batchImport',
      desc: '',
      args: [],
    );
  }

  /// `One URL per line`
  String get batchUrlInputTip {
    return Intl.message(
      'One URL per line',
      name: 'batchUrlInputTip',
      desc: '',
      args: [],
    );
  }

  /// `One link per line`
  String get batchLinkInputTip {
    return Intl.message(
      'One link per line',
      name: 'batchLinkInputTip',
      desc: '',
      args: [],
    );
  }

  /// `{count} to add, {skipped} skipped as existing`
  String batchPreviewTip(Object count, Object skipped) {
    return Intl.message(
      '$count to add, $skipped skipped as existing',
      name: 'batchPreviewTip',
      desc: '',
      args: [count, skipped],
    );
  }

  /// `Line {line}: {message}`
  String lineIssueTip(Object line, Object message) {
    return Intl.message(
      'Line $line: $message',
      name: 'lineIssueTip',
      desc: '',
      args: [line, message],
    );
  }

  /// `{label} must be a single item`
  String singleValueTip(Object label) {
    return Intl.message(
      '$label must be a single item',
      name: 'singleValueTip',
      desc: '',
      args: [label],
    );
  }

  /// `Are you sure you want to delete this {label}?`
  String deleteTip(Object label) {
    return Intl.message(
      'Are you sure you want to delete this $label?',
      name: 'deleteTip',
      desc: '',
      args: [label],
    );
  }

  /// `Are you sure you want to delete the selected {label}?`
  String deleteMultipTip(Object label) {
    return Intl.message(
      'Are you sure you want to delete the selected $label?',
      name: 'deleteMultipTip',
      desc: '',
      args: [label],
    );
  }

  /// `No {label} yet`
  String nullTip(Object label) {
    return Intl.message(
      'No $label yet',
      name: 'nullTip',
      desc: '',
      args: [label],
    );
  }

  /// `Script`
  String get script {
    return Intl.message('Script', name: 'script', desc: '', args: []);
  }

  /// `Color`
  String get color {
    return Intl.message('Color', name: 'color', desc: '', args: []);
  }

  /// `Unnamed`
  String get unnamed {
    return Intl.message('Unnamed', name: 'unnamed', desc: '', args: []);
  }

  /// `Please enter a script name`
  String get pleaseEnterScriptName {
    return Intl.message(
      'Please enter a script name',
      name: 'pleaseEnterScriptName',
      desc: '',
      args: [],
    );
  }

  /// `Mixed port`
  String get mixedPort {
    return Intl.message('Mixed port', name: 'mixedPort', desc: '', args: []);
  }

  /// `SOCKS port`
  String get socksPort {
    return Intl.message('SOCKS port', name: 'socksPort', desc: '', args: []);
  }

  /// `Redir port`
  String get redirPort {
    return Intl.message('Redir port', name: 'redirPort', desc: '', args: []);
  }

  /// `TProxy port`
  String get tproxyPort {
    return Intl.message('TProxy port', name: 'tproxyPort', desc: '', args: []);
  }

  /// `{label} must be between 1024 and 49151`
  String portTip(Object label) {
    return Intl.message(
      '$label must be between 1024 and 49151',
      name: 'portTip',
      desc: '',
      args: [label],
    );
  }

  /// `Please enter a different port`
  String get portConflictTip {
    return Intl.message(
      'Please enter a different port',
      name: 'portConflictTip',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get import {
    return Intl.message('Import', name: 'import', desc: '', args: []);
  }

  /// `Import from file`
  String get importFile {
    return Intl.message(
      'Import from file',
      name: 'importFile',
      desc: '',
      args: [],
    );
  }

  /// `Import from URL`
  String get importUrl {
    return Intl.message(
      'Import from URL',
      name: 'importUrl',
      desc: '',
      args: [],
    );
  }

  /// `Start from scratch`
  String get startFromScratch {
    return Intl.message(
      'Start from scratch',
      name: 'startFromScratch',
      desc: '',
      args: [],
    );
  }

  /// `Auto-set system DNS`
  String get autoSetSystemDns {
    return Intl.message(
      'Auto-set system DNS',
      name: 'autoSetSystemDns',
      desc: '',
      args: [],
    );
  }

  /// `{label} details`
  String details(Object label) {
    return Intl.message(
      '$label details',
      name: 'details',
      desc: '',
      args: [label],
    );
  }

  /// `Creation time`
  String get creationTime {
    return Intl.message(
      'Creation time',
      name: 'creationTime',
      desc: '',
      args: [],
    );
  }

  /// `Process`
  String get process {
    return Intl.message('Process', name: 'process', desc: '', args: []);
  }

  /// `Host`
  String get host {
    return Intl.message('Host', name: 'host', desc: '', args: []);
  }

  /// `Destination`
  String get destination {
    return Intl.message('Destination', name: 'destination', desc: '', args: []);
  }

  /// `Destination GeoIP`
  String get destinationGeoIP {
    return Intl.message(
      'Destination GeoIP',
      name: 'destinationGeoIP',
      desc: '',
      args: [],
    );
  }

  /// `Destination IP ASN`
  String get destinationIPASN {
    return Intl.message(
      'Destination IP ASN',
      name: 'destinationIPASN',
      desc: '',
      args: [],
    );
  }

  /// `Special proxy`
  String get specialProxy {
    return Intl.message(
      'Special proxy',
      name: 'specialProxy',
      desc: '',
      args: [],
    );
  }

  /// `Special rules`
  String get specialRules {
    return Intl.message(
      'Special rules',
      name: 'specialRules',
      desc: '',
      args: [],
    );
  }

  /// `Remote destination`
  String get remoteDestination {
    return Intl.message(
      'Remote destination',
      name: 'remoteDestination',
      desc: '',
      args: [],
    );
  }

  /// `Network type`
  String get networkType {
    return Intl.message(
      'Network type',
      name: 'networkType',
      desc: '',
      args: [],
    );
  }

  /// `Proxy chain`
  String get proxyChains {
    return Intl.message('Proxy chain', name: 'proxyChains', desc: '', args: []);
  }

  /// `Log`
  String get log {
    return Intl.message('Log', name: 'log', desc: '', args: []);
  }

  /// `Connection`
  String get connection {
    return Intl.message('Connection', name: 'connection', desc: '', args: []);
  }

  /// `Request`
  String get request {
    return Intl.message('Request', name: 'request', desc: '', args: []);
  }

  /// `Connected`
  String get connected {
    return Intl.message('Connected', name: 'connected', desc: '', args: []);
  }

  /// `Disconnected`
  String get disconnected {
    return Intl.message(
      'Disconnected',
      name: 'disconnected',
      desc: '',
      args: [],
    );
  }

  /// `Connecting…`
  String get connecting {
    return Intl.message('Connecting…', name: 'connecting', desc: '', args: []);
  }

  /// `Are you sure you want to restart the core?`
  String get restartCoreTip {
    return Intl.message(
      'Are you sure you want to restart the core?',
      name: 'restartCoreTip',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to force restart the core?`
  String get forceRestartCoreTip {
    return Intl.message(
      'Are you sure you want to force restart the core?',
      name: 'forceRestartCoreTip',
      desc: '',
      args: [],
    );
  }

  /// `DNS hijacking`
  String get dnsHijacking {
    return Intl.message(
      'DNS hijacking',
      name: 'dnsHijacking',
      desc: '',
      args: [],
    );
  }

  /// `Core status`
  String get coreStatus {
    return Intl.message('Core status', name: 'coreStatus', desc: '', args: []);
  }

  /// `Append system DNS`
  String get appendSystemDns {
    return Intl.message(
      'Append system DNS',
      name: 'appendSystemDns',
      desc: '',
      args: [],
    );
  }

  /// `Edit rule`
  String get editRule {
    return Intl.message('Edit rule', name: 'editRule', desc: '', args: []);
  }

  /// `Extend mode`
  String get extendMode {
    return Intl.message('Extend mode', name: 'extendMode', desc: '', args: []);
  }

  /// `Standard mode: adds rules on top of the profile`
  String get standardModeDesc {
    return Intl.message(
      'Standard mode: adds rules on top of the profile',
      name: 'standardModeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Script mode: rewrites the whole profile with an extension script`
  String get scriptModeDesc {
    return Intl.message(
      'Script mode: rewrites the whole profile with an extension script',
      name: 'scriptModeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Added rules`
  String get addedRules {
    return Intl.message('Added rules', name: 'addedRules', desc: '', args: []);
  }

  /// `Control global added rules`
  String get controlGlobalAddedRules {
    return Intl.message(
      'Control global added rules',
      name: 'controlGlobalAddedRules',
      desc: '',
      args: [],
    );
  }

  /// `Quick actions`
  String get quickActions {
    return Intl.message(
      'Quick actions',
      name: 'quickActions',
      desc: '',
      args: [],
    );
  }

  /// `Block QUIC`
  String get rulePresetBlockQuic {
    return Intl.message(
      'Block QUIC',
      name: 'rulePresetBlockQuic',
      desc: '',
      args: [],
    );
  }

  /// `Block STUN`
  String get rulePresetBlockStun {
    return Intl.message(
      'Block STUN',
      name: 'rulePresetBlockStun',
      desc: '',
      args: [],
    );
  }

  /// `Block DNS over TLS`
  String get rulePresetBlockDot {
    return Intl.message(
      'Block DNS over TLS',
      name: 'rulePresetBlockDot',
      desc: '',
      args: [],
    );
  }

  /// `Block proxy loopback`
  String get rulePresetBlockLoopback {
    return Intl.message(
      'Block proxy loopback',
      name: 'rulePresetBlockLoopback',
      desc: '',
      args: [],
    );
  }

  /// `Apple and Microsoft direct`
  String get rulePresetSystemServicesDirect {
    return Intl.message(
      'Apple and Microsoft direct',
      name: 'rulePresetSystemServicesDirect',
      desc: '',
      args: [],
    );
  }

  /// `BitTorrent direct`
  String get rulePresetBittorrentDirect {
    return Intl.message(
      'BitTorrent direct',
      name: 'rulePresetBittorrentDirect',
      desc: '',
      args: [],
    );
  }

  /// `LAN direct`
  String get rulePresetLanDirect {
    return Intl.message(
      'LAN direct',
      name: 'rulePresetLanDirect',
      desc: '',
      args: [],
    );
  }

  /// `Extend script`
  String get extendScript {
    return Intl.message(
      'Extend script',
      name: 'extendScript',
      desc: '',
      args: [],
    );
  }

  /// `Go to script configuration`
  String get goToConfigureScript {
    return Intl.message(
      'Go to script configuration',
      name: 'goToConfigureScript',
      desc: '',
      args: [],
    );
  }

  /// `Go to added rules configuration`
  String get goToConfigureAddedRules {
    return Intl.message(
      'Go to added rules configuration',
      name: 'goToConfigureAddedRules',
      desc: '',
      args: [],
    );
  }

  /// `Edit global rules`
  String get editGlobalRules {
    return Intl.message(
      'Edit global rules',
      name: 'editGlobalRules',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to force crash the core?`
  String get confirmForceCrashCore {
    return Intl.message(
      'Are you sure you want to force crash the core?',
      name: 'confirmForceCrashCore',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to clear all data?`
  String get confirmClearAllData {
    return Intl.message(
      'Are you sure you want to clear all data?',
      name: 'confirmClearAllData',
      desc: '',
      args: [],
    );
  }

  /// `Loading…`
  String get loading {
    return Intl.message('Loading…', name: 'loading', desc: '', args: []);
  }

  /// `{count, plural, =1{1 year ago} other{{count} years ago}}`
  String yearsAgo(num count) {
    return Intl.plural(
      count,
      one: '1 year ago',
      other: '$count years ago',
      name: 'yearsAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 month ago} other{{count} months ago}}`
  String monthsAgo(num count) {
    return Intl.plural(
      count,
      one: '1 month ago',
      other: '$count months ago',
      name: 'monthsAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 day ago} other{{count} days ago}}`
  String daysAgo(num count) {
    return Intl.plural(
      count,
      one: '1 day ago',
      other: '$count days ago',
      name: 'daysAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 hour ago} other{{count} hours ago}}`
  String hoursAgo(num count) {
    return Intl.plural(
      count,
      one: '1 hour ago',
      other: '$count hours ago',
      name: 'hoursAgo',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 minute ago} other{{count} minutes ago}}`
  String minutesAgo(num count) {
    return Intl.plural(
      count,
      one: '1 minute ago',
      other: '$count minutes ago',
      name: 'minutesAgo',
      desc: '',
      args: [count],
    );
  }

  /// `Just now`
  String get justNow {
    return Intl.message('Just now', name: 'justNow', desc: '', args: []);
  }

  /// `{count, plural, other{{count}y ago}}`
  String yearsAgoShort(num count) {
    return Intl.plural(
      count,
      other: '${count}y ago',
      name: 'yearsAgoShort',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, other{{count}mo ago}}`
  String monthsAgoShort(num count) {
    return Intl.plural(
      count,
      other: '${count}mo ago',
      name: 'monthsAgoShort',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, other{{count}d ago}}`
  String daysAgoShort(num count) {
    return Intl.plural(
      count,
      other: '${count}d ago',
      name: 'daysAgoShort',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, other{{count}h ago}}`
  String hoursAgoShort(num count) {
    return Intl.plural(
      count,
      other: '${count}h ago',
      name: 'hoursAgoShort',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, other{{count}m ago}}`
  String minutesAgoShort(num count) {
    return Intl.plural(
      count,
      other: '${count}m ago',
      name: 'minutesAgoShort',
      desc: '',
      args: [count],
    );
  }

  /// `Don't remind me again`
  String get noLongerRemind {
    return Intl.message(
      'Don\'t remind me again',
      name: 'noLongerRemind',
      desc: '',
      args: [],
    );
  }

  /// `Access control settings`
  String get accessControlSettings {
    return Intl.message(
      'Access control settings',
      name: 'accessControlSettings',
      desc: '',
      args: [],
    );
  }

  /// `Turn on`
  String get turnOn {
    return Intl.message('Turn on', name: 'turnOn', desc: '', args: []);
  }

  /// `Turn off`
  String get turnOff {
    return Intl.message('Turn off', name: 'turnOff', desc: '', args: []);
  }

  /// `VPN-related configuration change detected`
  String get vpnConfigChangeDetected {
    return Intl.message(
      'VPN-related configuration change detected',
      name: 'vpnConfigChangeDetected',
      desc: '',
      args: [],
    );
  }

  /// `Restart`
  String get restart {
    return Intl.message('Restart', name: 'restart', desc: '', args: []);
  }

  /// `Speed statistics`
  String get speedStatistics {
    return Intl.message(
      'Speed statistics',
      name: 'speedStatistics',
      desc: '',
      args: [],
    );
  }

  /// `This page has changes. Are you sure you want to reset?`
  String get resetPageChangesTip {
    return Intl.message(
      'This page has changes. Are you sure you want to reset?',
      name: 'resetPageChangesTip',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get customProfile {
    return Intl.message('Custom', name: 'customProfile', desc: '', args: []);
  }

  /// `Assemble proxy groups and rules from app proxies and other profiles`
  String get customProfileDesc {
    return Intl.message(
      'Assemble proxy groups and rules from app proxies and other profiles',
      name: 'customProfileDesc',
      desc: '',
      args: [],
    );
  }

  /// `Custom profile resources`
  String get customProfileResources {
    return Intl.message(
      'Custom profile resources',
      name: 'customProfileResources',
      desc: '',
      args: [],
    );
  }

  /// `Custom profile resources hold proxies, rule providers, filters, and icon sets.`
  String get customProfileResourcesDesc {
    return Intl.message(
      'Custom profile resources hold proxies, rule providers, filters, and icon sets.',
      name: 'customProfileResourcesDesc',
      desc: '',
      args: [],
    );
  }

  /// `Unknown network error`
  String get unknownNetworkError {
    return Intl.message(
      'Unknown network error',
      name: 'unknownNetworkError',
      desc: '',
      args: [],
    );
  }

  /// `This backup comes from a newer version of the app. Update the app before restoring it`
  String get backupFromNewerVersion {
    return Intl.message(
      'This backup comes from a newer version of the app. Update the app before restoring it',
      name: 'backupFromNewerVersion',
      desc: '',
      args: [],
    );
  }

  /// `The request timed out. Check your network or proxy, then try again`
  String get networkTimeoutError {
    return Intl.message(
      'The request timed out. Check your network or proxy, then try again',
      name: 'networkTimeoutError',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't resolve the server address. Check that the URL is correct and DNS is working`
  String get networkHostLookupError {
    return Intl.message(
      'Couldn\'t resolve the server address. Check that the URL is correct and DNS is working',
      name: 'networkHostLookupError',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't connect to the server. Check your network connection or proxy settings`
  String get networkConnectionError {
    return Intl.message(
      'Couldn\'t connect to the server. Check your network connection or proxy settings',
      name: 'networkConnectionError',
      desc: '',
      args: [],
    );
  }

  /// `Secure connection failed. The server's certificate may be invalid, or the connection is being intercepted`
  String get networkTlsError {
    return Intl.message(
      'Secure connection failed. The server\'s certificate may be invalid, or the connection is being intercepted',
      name: 'networkTlsError',
      desc: '',
      args: [],
    );
  }

  /// `The request was cancelled`
  String get networkCancelledError {
    return Intl.message(
      'The request was cancelled',
      name: 'networkCancelledError',
      desc: '',
      args: [],
    );
  }

  /// `The server denied access (HTTP {code}). The link may have expired, or the credentials are wrong`
  String networkAccessDeniedError(Object code) {
    return Intl.message(
      'The server denied access (HTTP $code). The link may have expired, or the credentials are wrong',
      name: 'networkAccessDeniedError',
      desc: '',
      args: [code],
    );
  }

  /// `Nothing was found at this address (HTTP {code}). Check that the URL is correct`
  String networkNotFoundError(Object code) {
    return Intl.message(
      'Nothing was found at this address (HTTP $code). Check that the URL is correct',
      name: 'networkNotFoundError',
      desc: '',
      args: [code],
    );
  }

  /// `Too many requests (HTTP 429). Wait a moment and try again`
  String get networkRateLimitedError {
    return Intl.message(
      'Too many requests (HTTP 429). Wait a moment and try again',
      name: 'networkRateLimitedError',
      desc: '',
      args: [],
    );
  }

  /// `The server ran into a problem (HTTP {code}). Try again later`
  String networkServerError(Object code) {
    return Intl.message(
      'The server ran into a problem (HTTP $code). Try again later',
      name: 'networkServerError',
      desc: '',
      args: [code],
    );
  }

  /// `The server rejected the request (HTTP {code})`
  String networkBadResponseError(Object code) {
    return Intl.message(
      'The server rejected the request (HTTP $code)',
      name: 'networkBadResponseError',
      desc: '',
      args: [code],
    );
  }

  /// `Network request failed: {detail}`
  String networkRequestFailed(Object detail) {
    return Intl.message(
      'Network request failed: $detail',
      name: 'networkRequestFailed',
      desc: '',
      args: [detail],
    );
  }

  /// `Invalid backup file`
  String get invalidBackupFile {
    return Intl.message(
      'Invalid backup file',
      name: 'invalidBackupFile',
      desc: '',
      args: [],
    );
  }

  /// `Prune cache`
  String get pruneCache {
    return Intl.message('Prune cache', name: 'pruneCache', desc: '', args: []);
  }

  /// `Backup and restore`
  String get backupAndRestore {
    return Intl.message(
      'Backup and restore',
      name: 'backupAndRestore',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get restore {
    return Intl.message('Restore', name: 'restore', desc: '', args: []);
  }

  /// `Restore successful`
  String get restoreSuccess {
    return Intl.message(
      'Restore successful',
      name: 'restoreSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Restore profiles only`
  String get restoreOnlyConfig {
    return Intl.message(
      'Restore profiles only',
      name: 'restoreOnlyConfig',
      desc: '',
      args: [],
    );
  }

  /// `Restore all data`
  String get restoreAllData {
    return Intl.message(
      'Restore all data',
      name: 'restoreAllData',
      desc: '',
      args: [],
    );
  }

  /// `Add profile`
  String get addProfile {
    return Intl.message('Add profile', name: 'addProfile', desc: '', args: []);
  }

  /// `Delay test`
  String get delayTest {
    return Intl.message('Delay test', name: 'delayTest', desc: '', args: []);
  }

  /// `Proxy group is empty`
  String get proxyGroupEmpty {
    return Intl.message(
      'Proxy group is empty',
      name: 'proxyGroupEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to exit the current window?`
  String get confirmExitWindow {
    return Intl.message(
      'Are you sure you want to exit the current window?',
      name: 'confirmExitWindow',
      desc: '',
      args: [],
    );
  }

  /// `Optional`
  String get optional {
    return Intl.message('Optional', name: 'optional', desc: '', args: []);
  }

  /// `Max failures`
  String get maxFailedTimes {
    return Intl.message(
      'Max failures',
      name: 'maxFailedTimes',
      desc: '',
      args: [],
    );
  }

  /// `Test interval`
  String get testInterval {
    return Intl.message(
      'Test interval',
      name: 'testInterval',
      desc: '',
      args: [],
    );
  }

  /// `Exclude filter`
  String get excludeFilter {
    return Intl.message(
      'Exclude filter',
      name: 'excludeFilter',
      desc: '',
      args: [],
    );
  }

  /// `Expected status`
  String get expectedStatus {
    return Intl.message(
      'Expected status',
      name: 'expectedStatus',
      desc: '',
      args: [],
    );
  }

  /// `Strategy`
  String get strategy {
    return Intl.message('Strategy', name: 'strategy', desc: '', args: []);
  }

  /// `Tolerance`
  String get tolerance {
    return Intl.message('Tolerance', name: 'tolerance', desc: '', args: []);
  }

  /// `Enter the proxy group name`
  String get inputProxyGroupName {
    return Intl.message(
      'Enter the proxy group name',
      name: 'inputProxyGroupName',
      desc: '',
      args: [],
    );
  }

  /// `Helper service unavailable; TUN mode cannot be enabled. Reinstall ReClash to restore it.`
  String get helperCorruptTip {
    return Intl.message(
      'Helper service unavailable; TUN mode cannot be enabled. Reinstall ReClash to restore it.',
      name: 'helperCorruptTip',
      desc: '',
      args: [],
    );
  }

  /// `TUN could not be authorized, so it was turned off.`
  String get tunAuthorizationFailed {
    return Intl.message(
      'TUN could not be authorized, so it was turned off.',
      name: 'tunAuthorizationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password for sudo`
  String get sudoPasswordTitle {
    return Intl.message(
      'Enter your password for sudo',
      name: 'sudoPasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Windows refused to run ReClashCore.exe (error {code}). An app control policy such as Smart App Control or AppLocker blocks unsigned programs; allow ReClash in that policy or turn it off, then try again.`
  String coreBlockedByPolicyTip(Object code) {
    return Intl.message(
      'Windows refused to run ReClashCore.exe (error $code). An app control policy such as Smart App Control or AppLocker blocks unsigned programs; allow ReClash in that policy or turn it off, then try again.',
      name: 'coreBlockedByPolicyTip',
      desc: '',
      args: [code],
    );
  }

  /// `Windows Smart App Control blocked ReClashCore.exe because it is not signed. Open Windows Security → App & browser control → Smart App Control settings, choose Off, then start ReClash again. Smart App Control cannot be turned back on without reinstalling Windows.`
  String get coreBlockedBySmartAppControlTip {
    return Intl.message(
      'Windows Smart App Control blocked ReClashCore.exe because it is not signed. Open Windows Security → App & browser control → Smart App Control settings, choose Off, then start ReClash again. Smart App Control cannot be turned back on without reinstalling Windows.',
      name: 'coreBlockedBySmartAppControlTip',
      desc: '',
      args: [],
    );
  }

  /// `Hide from list`
  String get hideFromList {
    return Intl.message(
      'Hide from list',
      name: 'hideFromList',
      desc: '',
      args: [],
    );
  }

  /// `Test when used`
  String get testWhenUsed {
    return Intl.message(
      'Test when used',
      name: 'testWhenUsed',
      desc: '',
      args: [],
    );
  }

  /// `Disable UDP`
  String get disableUDP {
    return Intl.message('Disable UDP', name: 'disableUDP', desc: '', args: []);
  }

  /// `Are you sure you want to delete this proxy group?`
  String get confirmDeleteProxyGroup {
    return Intl.message(
      'Are you sure you want to delete this proxy group?',
      name: 'confirmDeleteProxyGroup',
      desc: '',
      args: [],
    );
  }

  /// `Rule is empty`
  String get ruleEmpty {
    return Intl.message('Rule is empty', name: 'ruleEmpty', desc: '', args: []);
  }

  /// `Enter the rule content`
  String get inputRuleContent {
    return Intl.message(
      'Enter the rule content',
      name: 'inputRuleContent',
      desc: '',
      args: [],
    );
  }

  /// `Rule set`
  String get ruleSet {
    return Intl.message('Rule set', name: 'ruleSet', desc: '', args: []);
  }

  /// `Please select a rule set`
  String get selectRuleSet {
    return Intl.message(
      'Please select a rule set',
      name: 'selectRuleSet',
      desc: '',
      args: [],
    );
  }

  /// `Split strategy`
  String get splitStrategy {
    return Intl.message(
      'Split strategy',
      name: 'splitStrategy',
      desc: '',
      args: [],
    );
  }

  /// `Please select a split strategy`
  String get selectSplitStrategy {
    return Intl.message(
      'Please select a split strategy',
      name: 'selectSplitStrategy',
      desc: '',
      args: [],
    );
  }

  /// `Don't resolve hostname`
  String get noResolveHostname {
    return Intl.message(
      'Don\'t resolve hostname',
      name: 'noResolveHostname',
      desc: '',
      args: [],
    );
  }

  /// `Match source IP`
  String get matchSourceIp {
    return Intl.message(
      'Match source IP',
      name: 'matchSourceIp',
      desc: '',
      args: [],
    );
  }

  /// `Basic info`
  String get basicInfo {
    return Intl.message('Basic info', name: 'basicInfo', desc: '', args: []);
  }

  /// `Additional parameters`
  String get additionalParameters {
    return Intl.message(
      'Additional parameters',
      name: 'additionalParameters',
      desc: '',
      args: [],
    );
  }

  /// `Proxy type`
  String get proxyType {
    return Intl.message('Proxy type', name: 'proxyType', desc: '', args: []);
  }

  /// `Basic strategies`
  String get basicStrategy {
    return Intl.message(
      'Basic strategies',
      name: 'basicStrategy',
      desc: '',
      args: [],
    );
  }

  /// `Edit proxy`
  String get editProxy {
    return Intl.message('Edit proxy', name: 'editProxy', desc: '', args: []);
  }

  /// `Add nodes`
  String get addNodes {
    return Intl.message('Add nodes', name: 'addNodes', desc: '', args: []);
  }

  /// `Add proxy group`
  String get addProxyGroup {
    return Intl.message(
      'Add proxy group',
      name: 'addProxyGroup',
      desc: '',
      args: [],
    );
  }

  /// `Edit proxy group`
  String get editProxyGroup {
    return Intl.message(
      'Edit proxy group',
      name: 'editProxyGroup',
      desc: '',
      args: [],
    );
  }

  /// `Icon URL`
  String get iconUrl {
    return Intl.message('Icon URL', name: 'iconUrl', desc: '', args: []);
  }

  /// `Icon records`
  String get iconRecords {
    return Intl.message(
      'Icon records',
      name: 'iconRecords',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get custom {
    return Intl.message('Custom', name: 'custom', desc: '', args: []);
  }

  /// `Match the full domain`
  String get ruleActionDomainDesc {
    return Intl.message(
      'Match the full domain',
      name: 'ruleActionDomainDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match a domain suffix`
  String get ruleActionDomainSuffixDesc {
    return Intl.message(
      'Match a domain suffix',
      name: 'ruleActionDomainSuffixDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match a domain keyword`
  String get ruleActionDomainKeywordDesc {
    return Intl.message(
      'Match a domain keyword',
      name: 'ruleActionDomainKeywordDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match a domain regex`
  String get ruleActionDomainRegexDesc {
    return Intl.message(
      'Match a domain regex',
      name: 'ruleActionDomainRegexDesc',
      desc: '',
      args: [],
    );
  }

  /// `Wildcard match; only * and ? are supported`
  String get ruleActionDomainWildcardDesc {
    return Intl.message(
      'Wildcard match; only * and ? are supported',
      name: 'ruleActionDomainWildcardDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match domains in Geosite`
  String get ruleActionGeositeDesc {
    return Intl.message(
      'Match domains in Geosite',
      name: 'ruleActionGeositeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match an IP address range`
  String get ruleActionIpCidrDesc {
    return Intl.message(
      'Match an IP address range',
      name: 'ruleActionIpCidrDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match an IP address range; IP-CIDR6 is just an alias`
  String get ruleActionIpCidr6Desc {
    return Intl.message(
      'Match an IP address range; IP-CIDR6 is just an alias',
      name: 'ruleActionIpCidr6Desc',
      desc: '',
      args: [],
    );
  }

  /// `Match an IP suffix range`
  String get ruleActionIpSuffixDesc {
    return Intl.message(
      'Match an IP suffix range',
      name: 'ruleActionIpSuffixDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the IP's ASN`
  String get ruleActionIpAsnDesc {
    return Intl.message(
      'Match the IP\'s ASN',
      name: 'ruleActionIpAsnDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the IP's country code`
  String get ruleActionGeoipDesc {
    return Intl.message(
      'Match the IP\'s country code',
      name: 'ruleActionGeoipDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the source IP's country code`
  String get ruleActionSrcGeoipDesc {
    return Intl.message(
      'Match the source IP\'s country code',
      name: 'ruleActionSrcGeoipDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the source IP's ASN`
  String get ruleActionSrcIpAsnDesc {
    return Intl.message(
      'Match the source IP\'s ASN',
      name: 'ruleActionSrcIpAsnDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match a source IP address range`
  String get ruleActionSrcIpCidrDesc {
    return Intl.message(
      'Match a source IP address range',
      name: 'ruleActionSrcIpCidrDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match a source IP suffix range`
  String get ruleActionSrcIpSuffixDesc {
    return Intl.message(
      'Match a source IP suffix range',
      name: 'ruleActionSrcIpSuffixDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the destination port range`
  String get ruleActionDstPortDesc {
    return Intl.message(
      'Match the destination port range',
      name: 'ruleActionDstPortDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the source port range`
  String get ruleActionSrcPortDesc {
    return Intl.message(
      'Match the source port range',
      name: 'ruleActionSrcPortDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the inbound port`
  String get ruleActionInPortDesc {
    return Intl.message(
      'Match the inbound port',
      name: 'ruleActionInPortDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the inbound type`
  String get ruleActionInTypeDesc {
    return Intl.message(
      'Match the inbound type',
      name: 'ruleActionInTypeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the inbound username; separate multiple usernames with /`
  String get ruleActionInUserDesc {
    return Intl.message(
      'Match the inbound username; separate multiple usernames with /',
      name: 'ruleActionInUserDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the inbound name`
  String get ruleActionInNameDesc {
    return Intl.message(
      'Match the inbound name',
      name: 'ruleActionInNameDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the rematch name; separate multiple names with /`
  String get ruleActionRematchNameDesc {
    return Intl.message(
      'Match the rematch name; separate multiple names with /',
      name: 'ruleActionRematchNameDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match by the full process path`
  String get ruleActionProcessPathDesc {
    return Intl.message(
      'Match by the full process path',
      name: 'ruleActionProcessPathDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match by process path regex`
  String get ruleActionProcessPathRegexDesc {
    return Intl.message(
      'Match by process path regex',
      name: 'ruleActionProcessPathRegexDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match by process path wildcard; only * and ? are supported`
  String get ruleActionProcessPathWildcardDesc {
    return Intl.message(
      'Match by process path wildcard; only * and ? are supported',
      name: 'ruleActionProcessPathWildcardDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match by process name; matches the package name on Android`
  String get ruleActionProcessNameDesc {
    return Intl.message(
      'Match by process name; matches the package name on Android',
      name: 'ruleActionProcessNameDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match by process name regex; matches the package name on Android`
  String get ruleActionProcessNameRegexDesc {
    return Intl.message(
      'Match by process name regex; matches the package name on Android',
      name: 'ruleActionProcessNameRegexDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match by process name wildcard; only * and ? are supported`
  String get ruleActionProcessNameWildcardDesc {
    return Intl.message(
      'Match by process name wildcard; only * and ? are supported',
      name: 'ruleActionProcessNameWildcardDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the Linux user ID`
  String get ruleActionUidDesc {
    return Intl.message(
      'Match the Linux user ID',
      name: 'ruleActionUidDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match TCP or UDP`
  String get ruleActionNetworkDesc {
    return Intl.message(
      'Match TCP or UDP',
      name: 'ruleActionNetworkDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match the DSCP mark (tproxy UDP inbound only)`
  String get ruleActionDscpDesc {
    return Intl.message(
      'Match the DSCP mark (tproxy UDP inbound only)',
      name: 'ruleActionDscpDesc',
      desc: '',
      args: [],
    );
  }

  /// `Reference a rule set; requires rule-providers`
  String get ruleActionRuleSetDesc {
    return Intl.message(
      'Reference a rule set; requires rule-providers',
      name: 'ruleActionRuleSetDesc',
      desc: '',
      args: [],
    );
  }

  /// `Logical rule AND`
  String get ruleActionAndDesc {
    return Intl.message(
      'Logical rule AND',
      name: 'ruleActionAndDesc',
      desc: '',
      args: [],
    );
  }

  /// `Logical rule OR`
  String get ruleActionOrDesc {
    return Intl.message(
      'Logical rule OR',
      name: 'ruleActionOrDesc',
      desc: '',
      args: [],
    );
  }

  /// `Logical rule NOT`
  String get ruleActionNotDesc {
    return Intl.message(
      'Logical rule NOT',
      name: 'ruleActionNotDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match into a sub-rule; mind the parentheses`
  String get ruleActionSubRuleDesc {
    return Intl.message(
      'Match into a sub-rule; mind the parentheses',
      name: 'ruleActionSubRuleDesc',
      desc: '',
      args: [],
    );
  }

  /// `Match all requests, no conditions needed`
  String get ruleActionMatchDesc {
    return Intl.message(
      'Match all requests, no conditions needed',
      name: 'ruleActionMatchDesc',
      desc: '',
      args: [],
    );
  }

  /// `Content cannot be empty`
  String get contentNotEmpty {
    return Intl.message(
      'Content cannot be empty',
      name: 'contentNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Split strategy cannot be empty`
  String get splitStrategyNotEmpty {
    return Intl.message(
      'Split strategy cannot be empty',
      name: 'splitStrategyNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Timeout`
  String get timeout {
    return Intl.message('Timeout', name: 'timeout', desc: '', args: []);
  }

  /// `Failed`
  String get delayFailed {
    return Intl.message('Failed', name: 'delayFailed', desc: '', args: []);
  }

  /// `{subRule} is an invalid SUB_RULE`
  String invalidSubRule(Object subRule) {
    return Intl.message(
      '$subRule is an invalid SUB_RULE',
      name: 'invalidSubRule',
      desc: '',
      args: [subRule],
    );
  }

  /// `{target} is an invalid policy`
  String invalidPolicy(Object target) {
    return Intl.message(
      '$target is an invalid policy',
      name: 'invalidPolicy',
      desc: '',
      args: [target],
    );
  }

  /// `{providerName} is an invalid proxy provider`
  String invalidProxyProvider(Object providerName) {
    return Intl.message(
      '$providerName is an invalid proxy provider',
      name: 'invalidProxyProvider',
      desc: '',
      args: [providerName],
    );
  }

  /// `{ruleSet} is an invalid rule set`
  String invalidRuleSet(Object ruleSet) {
    return Intl.message(
      '$ruleSet is an invalid rule set',
      name: 'invalidRuleSet',
      desc: '',
      args: [ruleSet],
    );
  }

  /// `Only tcp or udp is supported`
  String get invalidNetworkContent {
    return Intl.message(
      'Only tcp or udp is supported',
      name: 'invalidNetworkContent',
      desc: '',
      args: [],
    );
  }

  /// `Enter numbers or ranges such as 80 or 8000-9000, separated by /`
  String get invalidRangeContent {
    return Intl.message(
      'Enter numbers or ranges such as 80 or 8000-9000, separated by /',
      name: 'invalidRangeContent',
      desc: '',
      args: [],
    );
  }

  /// `A DSCP mark cannot exceed 63`
  String get invalidDscpContent {
    return Intl.message(
      'A DSCP mark cannot exceed 63',
      name: 'invalidDscpContent',
      desc: '',
      args: [],
    );
  }

  /// `Enter an IP range in CIDR form such as 192.168.0.0/16`
  String get invalidCidrContent {
    return Intl.message(
      'Enter an IP range in CIDR form such as 192.168.0.0/16',
      name: 'invalidCidrContent',
      desc: '',
      args: [],
    );
  }

  /// `Enter a port or a range such as 443 or 8000-9000`
  String get invalidPortRangeContent {
    return Intl.message(
      'Enter a port or a range such as 443 or 8000-9000',
      name: 'invalidPortRangeContent',
      desc: '',
      args: [],
    );
  }

  /// `Enter a domain or an IP address`
  String get invalidHostContent {
    return Intl.message(
      'Enter a domain or an IP address',
      name: 'invalidHostContent',
      desc: '',
      args: [],
    );
  }

  /// `Enter an address and port such as 0.0.0.0:1053`
  String get invalidListenContent {
    return Intl.message(
      'Enter an address and port such as 0.0.0.0:1053',
      name: 'invalidListenContent',
      desc: '',
      args: [],
    );
  }

  /// `{proxyName} is an invalid proxy`
  String invalidProxy(Object proxyName) {
    return Intl.message(
      '$proxyName is an invalid proxy',
      name: 'invalidProxy',
      desc: '',
      args: [proxyName],
    );
  }

  /// `Location permission required`
  String get locationPermissionRequired {
    return Intl.message(
      'Location permission required',
      name: 'locationPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check {appName} in the list\n\nWhen you are done, return to the app to continue. Thank you for your cooperation.`
  String locationPermissionGuide(Object appName) {
    return Intl.message(
      '1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check $appName in the list\n\nWhen you are done, return to the app to continue. Thank you for your cooperation.',
      name: 'locationPermissionGuide',
      desc: '',
      args: [appName],
    );
  }

  /// `Prerequisites`
  String get prerequisites {
    return Intl.message(
      'Prerequisites',
      name: 'prerequisites',
      desc: '',
      args: [],
    );
  }

  /// `Ignore battery optimization`
  String get ignoreBatteryOptimization {
    return Intl.message(
      'Ignore battery optimization',
      name: 'ignoreBatteryOptimization',
      desc: '',
      args: [],
    );
  }

  /// `Ignore battery optimization keeps the app running in the background.`
  String get batteryOptimizationDesc {
    return Intl.message(
      'Ignore battery optimization keeps the app running in the background.',
      name: 'batteryOptimizationDesc',
      desc: '',
      args: [],
    );
  }

  /// `Location permission`
  String get locationPermission {
    return Intl.message(
      'Location permission',
      name: 'locationPermission',
      desc: '',
      args: [],
    );
  }

  /// `The system requires location permission to read the Wi-Fi name. On Android choose "Allow all the time", otherwise the Wi-Fi name cannot be read while the app is in the background.`
  String get locationPermissionDesc {
    return Intl.message(
      'The system requires location permission to read the Wi-Fi name. On Android choose "Allow all the time", otherwise the Wi-Fi name cannot be read while the app is in the background.',
      name: 'locationPermissionDesc',
      desc: '',
      args: [],
    );
  }

  /// `Exclude SSIDs`
  String get excludeSsids {
    return Intl.message(
      'Exclude SSIDs',
      name: 'excludeSsids',
      desc: '',
      args: [],
    );
  }

  /// `When connected to Wi-Fi with an excluded SSID, the app's running state switches automatically.`
  String get excludeSsidsDesc {
    return Intl.message(
      'When connected to Wi-Fi with an excluded SSID, the app\'s running state switches automatically.',
      name: 'excludeSsidsDesc',
      desc: '',
      args: [],
    );
  }

  /// `SSIDs are empty`
  String get ssidsEmpty {
    return Intl.message(
      'SSIDs are empty',
      name: 'ssidsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `On demand`
  String get onDemand {
    return Intl.message('On demand', name: 'onDemand', desc: '', args: []);
  }

  /// `On demand pauses the proxy on excluded Wi-Fi.`
  String get onDemandDesc {
    return Intl.message(
      'On demand pauses the proxy on excluded Wi-Fi.',
      name: 'onDemandDesc',
      desc: '',
      args: [],
    );
  }

  /// `Location permission was denied, so the current Wi-Fi name cannot be read. Please enable location permission manually in system settings.`
  String get locationPermissionDeniedMessage {
    return Intl.message(
      'Location permission was denied, so the current Wi-Fi name cannot be read. Please enable location permission manually in system settings.',
      name: 'locationPermissionDeniedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Add SSID`
  String get addSsid {
    return Intl.message('Add SSID', name: 'addSsid', desc: '', args: []);
  }

  /// `Edit SSID`
  String get editSsid {
    return Intl.message('Edit SSID', name: 'editSsid', desc: '', args: []);
  }

  /// `Authorized`
  String get authorized {
    return Intl.message('Authorized', name: 'authorized', desc: '', args: []);
  }

  /// `Tap to authorize`
  String get tapToAuthorize {
    return Intl.message(
      'Tap to authorize',
      name: 'tapToAuthorize',
      desc: '',
      args: [],
    );
  }

  /// `Suspended…`
  String get suspended {
    return Intl.message('Suspended…', name: 'suspended', desc: '', args: []);
  }

  /// `Auto-update interval`
  String get resourceUpdateInterval {
    return Intl.message(
      'Auto-update interval',
      name: 'resourceUpdateInterval',
      desc: '',
      args: [],
    );
  }

  /// `The auto-update interval must be greater than 0`
  String get resourceUpdateIntervalTip {
    return Intl.message(
      'The auto-update interval must be greater than 0',
      name: 'resourceUpdateIntervalTip',
      desc: '',
      args: [],
    );
  }

  /// `hours`
  String get hours {
    return Intl.message('hours', name: 'hours', desc: '', args: []);
  }

  /// `minutes`
  String get minutes {
    return Intl.message('minutes', name: 'minutes', desc: '', args: []);
  }

  /// `Geo`
  String get geoResources {
    return Intl.message('Geo', name: 'geoResources', desc: '', args: []);
  }

  /// `{name} is already up to date`
  String geoSkipped(Object name) {
    return Intl.message(
      '$name is already up to date',
      name: 'geoSkipped',
      desc: '',
      args: [name],
    );
  }

  /// `{name} updated`
  String geoUpdated(Object name) {
    return Intl.message(
      '$name updated',
      name: 'geoUpdated',
      desc: '',
      args: [name],
    );
  }

  /// `{count, plural, =1{1 second} other{{count} seconds}}`
  String secondsCount(num count) {
    return Intl.plural(
      count,
      one: '1 second',
      other: '$count seconds',
      name: 'secondsCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 proxy} other{{label} proxies}}`
  String proxiesCount(num count, Object label) {
    return Intl.plural(
      count,
      one: '1 proxy',
      other: '$label proxies',
      name: 'proxiesCount',
      desc: '',
      args: [count, label],
    );
  }

  /// `{count, plural, =1{1 rule} other{{label} rules}}`
  String rulesCount(num count, Object label) {
    return Intl.plural(
      count,
      one: '1 rule',
      other: '$label rules',
      name: 'rulesCount',
      desc: '',
      args: [count, label],
    );
  }

  /// `{count, plural, =1{1 proxy group} other{{label} proxy groups}}`
  String proxyGroupsCount(num count, Object label) {
    return Intl.plural(
      count,
      one: '1 proxy group',
      other: '$label proxy groups',
      name: 'proxyGroupsCount',
      desc: '',
      args: [count, label],
    );
  }

  /// `Breaking changes`
  String get changelogBreaking {
    return Intl.message(
      'Breaking changes',
      name: 'changelogBreaking',
      desc: '',
      args: [],
    );
  }

  /// `New features`
  String get changelogFeatures {
    return Intl.message(
      'New features',
      name: 'changelogFeatures',
      desc: '',
      args: [],
    );
  }

  /// `Bug fixes`
  String get changelogFixes {
    return Intl.message(
      'Bug fixes',
      name: 'changelogFixes',
      desc: '',
      args: [],
    );
  }

  /// `Performance`
  String get changelogPerformance {
    return Intl.message(
      'Performance',
      name: 'changelogPerformance',
      desc: '',
      args: [],
    );
  }

  /// `Reverts`
  String get changelogReverts {
    return Intl.message(
      'Reverts',
      name: 'changelogReverts',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Minimize`
  String get minimize {
    return Intl.message('Minimize', name: 'minimize', desc: '', args: []);
  }

  /// `Maximize`
  String get maximize {
    return Intl.message('Maximize', name: 'maximize', desc: '', args: []);
  }

  /// `Restore down`
  String get unmaximize {
    return Intl.message('Restore down', name: 'unmaximize', desc: '', args: []);
  }

  /// `Pin window`
  String get pinWindow {
    return Intl.message('Pin window', name: 'pinWindow', desc: '', args: []);
  }

  /// `Unpin window`
  String get unpinWindow {
    return Intl.message(
      'Unpin window',
      name: 'unpinWindow',
      desc: '',
      args: [],
    );
  }

  /// `Exit full screen`
  String get exitFullScreen {
    return Intl.message(
      'Exit full screen',
      name: 'exitFullScreen',
      desc: '',
      args: [],
    );
  }

  /// `Flashlight`
  String get torch {
    return Intl.message('Flashlight', name: 'torch', desc: '', args: []);
  }

  /// `Choose from album`
  String get pickFromAlbum {
    return Intl.message(
      'Choose from album',
      name: 'pickFromAlbum',
      desc: '',
      args: [],
    );
  }

  /// `Block connection`
  String get blockConnection {
    return Intl.message(
      'Block connection',
      name: 'blockConnection',
      desc: '',
      args: [],
    );
  }

  /// `Close connections`
  String get closeConnections {
    return Intl.message(
      'Close connections',
      name: 'closeConnections',
      desc: '',
      args: [],
    );
  }

  /// `Scroll to selected`
  String get scrollToSelected {
    return Intl.message(
      'Scroll to selected',
      name: 'scrollToSelected',
      desc: '',
      args: [],
    );
  }

  /// `Expand`
  String get showMore {
    return Intl.message('Expand', name: 'showMore', desc: '', args: []);
  }

  /// `Collapse`
  String get showLess {
    return Intl.message('Collapse', name: 'showLess', desc: '', args: []);
  }

  /// `Previous match`
  String get previousMatch {
    return Intl.message(
      'Previous match',
      name: 'previousMatch',
      desc: '',
      args: [],
    );
  }

  /// `Next match`
  String get nextMatch {
    return Intl.message('Next match', name: 'nextMatch', desc: '', args: []);
  }

  /// `Clear search`
  String get clearSearch {
    return Intl.message(
      'Clear search',
      name: 'clearSearch',
      desc: '',
      args: [],
    );
  }

  /// `No matching results`
  String get noSearchResults {
    return Intl.message(
      'No matching results',
      name: 'noSearchResults',
      desc: '',
      args: [],
    );
  }

  /// `Show password`
  String get showPassword {
    return Intl.message(
      'Show password',
      name: 'showPassword',
      desc: '',
      args: [],
    );
  }

  /// `Hide password`
  String get hidePassword {
    return Intl.message(
      'Hide password',
      name: 'hidePassword',
      desc: '',
      args: [],
    );
  }

  /// `Authorize`
  String get authorize {
    return Intl.message('Authorize', name: 'authorize', desc: '', args: []);
  }

  /// `App list permission required`
  String get installedAppsPermissionRequired {
    return Intl.message(
      'App list permission required',
      name: 'installedAppsPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `This system hides the installed app list until the permission is granted. Authorize it to configure the per-app proxy.`
  String get installedAppsPermissionDesc {
    return Intl.message(
      'This system hides the installed app list until the permission is granted. Authorize it to configure the per-app proxy.',
      name: 'installedAppsPermissionDesc',
      desc: '',
      args: [],
    );
  }

  /// `The app list permission was denied, so installed apps cannot be listed. Please grant it manually in system settings.`
  String get installedAppsPermissionDeniedMessage {
    return Intl.message(
      'The app list permission was denied, so installed apps cannot be listed. Please grant it manually in system settings.',
      name: 'installedAppsPermissionDeniedMessage',
      desc: '',
      args: [],
    );
  }

  /// `Outbound IP`
  String get outboundIp {
    return Intl.message('Outbound IP', name: 'outboundIp', desc: '', args: []);
  }

  /// `IP address`
  String get ipAddress {
    return Intl.message('IP address', name: 'ipAddress', desc: '', args: []);
  }

  /// `Level`
  String get ipQualityLevel {
    return Intl.message('Level', name: 'ipQualityLevel', desc: '', args: []);
  }

  /// `Good`
  String get ipQualityGood {
    return Intl.message('Good', name: 'ipQualityGood', desc: '', args: []);
  }

  /// `Normal`
  String get ipQualityNormal {
    return Intl.message('Normal', name: 'ipQualityNormal', desc: '', args: []);
  }

  /// `Risky`
  String get ipQualityRisky {
    return Intl.message('Risky', name: 'ipQualityRisky', desc: '', args: []);
  }

  /// `Type`
  String get ipType {
    return Intl.message('Type', name: 'ipType', desc: '', args: []);
  }

  /// `Residential`
  String get ipTypeResidential {
    return Intl.message(
      'Residential',
      name: 'ipTypeResidential',
      desc: '',
      args: [],
    );
  }

  /// `Mobile network`
  String get ipTypeMobile {
    return Intl.message(
      'Mobile network',
      name: 'ipTypeMobile',
      desc: '',
      args: [],
    );
  }

  /// `Business`
  String get ipTypeBusiness {
    return Intl.message('Business', name: 'ipTypeBusiness', desc: '', args: []);
  }

  /// `Data center`
  String get ipTypeHosting {
    return Intl.message(
      'Data center',
      name: 'ipTypeHosting',
      desc: '',
      args: [],
    );
  }

  /// `Flags`
  String get ipFlags {
    return Intl.message('Flags', name: 'ipFlags', desc: '', args: []);
  }

  /// `Proxy`
  String get ipFlagProxy {
    return Intl.message('Proxy', name: 'ipFlagProxy', desc: '', args: []);
  }

  /// `VPN`
  String get ipFlagVpn {
    return Intl.message('VPN', name: 'ipFlagVpn', desc: '', args: []);
  }

  /// `Tor`
  String get ipFlagTor {
    return Intl.message('Tor', name: 'ipFlagTor', desc: '', args: []);
  }

  /// `Abuse history`
  String get ipFlagAbuser {
    return Intl.message(
      'Abuse history',
      name: 'ipFlagAbuser',
      desc: '',
      args: [],
    );
  }

  /// `Organization`
  String get ipOrganization {
    return Intl.message(
      'Organization',
      name: 'ipOrganization',
      desc: '',
      args: [],
    );
  }

  /// `ASN`
  String get ipAsn {
    return Intl.message('ASN', name: 'ipAsn', desc: '', args: []);
  }

  /// `Answered by`
  String get ipQualitySource {
    return Intl.message(
      'Answered by',
      name: 'ipQualitySource',
      desc: '',
      args: [],
    );
  }

  /// `Sources`
  String get ipQualitySources {
    return Intl.message(
      'Sources',
      name: 'ipQualitySources',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't determine the IP type`
  String get ipQualityFailed {
    return Intl.message(
      'Couldn\'t determine the IP type',
      name: 'ipQualityFailed',
      desc: '',
      args: [],
    );
  }

  /// `Check again`
  String get ipQualityRetry {
    return Intl.message(
      'Check again',
      name: 'ipQualityRetry',
      desc: '',
      args: [],
    );
  }

  /// `No type`
  String get ipSourceNoType {
    return Intl.message('No type', name: 'ipSourceNoType', desc: '', args: []);
  }

  /// `Rate limited`
  String get ipSourceRateLimited {
    return Intl.message(
      'Rate limited',
      name: 'ipSourceRateLimited',
      desc: '',
      args: [],
    );
  }

  /// `Different outbound IP`
  String get ipSourceIpMismatch {
    return Intl.message(
      'Different outbound IP',
      name: 'ipSourceIpMismatch',
      desc: '',
      args: [],
    );
  }

  /// `Hide IP`
  String get hideIp {
    return Intl.message('Hide IP', name: 'hideIp', desc: '', args: []);
  }

  /// `Editor unavailable`
  String get editorUnavailable {
    return Intl.message(
      'Editor unavailable',
      name: 'editorUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Replace`
  String get replace {
    return Intl.message('Replace', name: 'replace', desc: '', args: []);
  }

  /// `Replace all`
  String get replaceAll {
    return Intl.message('Replace all', name: 'replaceAll', desc: '', args: []);
  }

  /// `Camera permission required`
  String get cameraPermissionRequired {
    return Intl.message(
      'Camera permission required',
      name: 'cameraPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Allow camera access in system settings to scan QR codes, or choose a QR code image from the album.`
  String get cameraPermissionDesc {
    return Intl.message(
      'Allow camera access in system settings to scan QR codes, or choose a QR code image from the album.',
      name: 'cameraPermissionDesc',
      desc: '',
      args: [],
    );
  }

  /// `Camera unavailable`
  String get cameraUnavailable {
    return Intl.message(
      'Camera unavailable',
      name: 'cameraUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `This QR code doesn't contain a profile link`
  String get invalidProfileQrcode {
    return Intl.message(
      'This QR code doesn\'t contain a profile link',
      name: 'invalidProfileQrcode',
      desc: '',
      args: [],
    );
  }

  /// `DNS queries`
  String get dnsQueries {
    return Intl.message('DNS queries', name: 'dnsQueries', desc: '', args: []);
  }

  /// `Record type`
  String get recordType {
    return Intl.message('Record type', name: 'recordType', desc: '', args: []);
  }

  /// `Answers`
  String get answers {
    return Intl.message('Answers', name: 'answers', desc: '', args: []);
  }

  /// `Response code`
  String get responseCode {
    return Intl.message(
      'Response code',
      name: 'responseCode',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Initiator`
  String get initiator {
    return Intl.message('Initiator', name: 'initiator', desc: '', args: []);
  }

  /// `Cache`
  String get cache {
    return Intl.message('Cache', name: 'cache', desc: '', args: []);
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `This external resource is not a text file`
  String get nonTextProviderFile {
    return Intl.message(
      'This external resource is not a text file',
      name: 'nonTextProviderFile',
      desc: '',
      args: [],
    );
  }

  /// `Add proxy`
  String get addCustomProxy {
    return Intl.message(
      'Add proxy',
      name: 'addCustomProxy',
      desc: '',
      args: [],
    );
  }

  /// `The configuration must be a YAML mapping with a name and a type`
  String get definitionNotMap {
    return Intl.message(
      'The configuration must be a YAML mapping with a name and a type',
      name: 'definitionNotMap',
      desc: '',
      args: [],
    );
  }

  /// `The rule must start with a supported type, such as DOMAIN,example.com,DIRECT`
  String get ruleTextInvalid {
    return Intl.message(
      'The rule must start with a supported type, such as DOMAIN,example.com,DIRECT',
      name: 'ruleTextInvalid',
      desc: '',
      args: [],
    );
  }

  /// `The rules must be a YAML list with one rule per item, such as - DOMAIN,example.com,DIRECT`
  String get ruleListInvalid {
    return Intl.message(
      'The rules must be a YAML list with one rule per item, such as - DOMAIN,example.com,DIRECT',
      name: 'ruleListInvalid',
      desc: '',
      args: [],
    );
  }

  /// `No proxy could be read from the links`
  String get shareLinksInvalid {
    return Intl.message(
      'No proxy could be read from the links',
      name: 'shareLinksInvalid',
      desc: '',
      args: [],
    );
  }

  /// `No proxy could be read from {link}`
  String shareLinkUnreadable(Object link) {
    return Intl.message(
      'No proxy could be read from $link',
      name: 'shareLinkUnreadable',
      desc: '',
      args: [link],
    );
  }

  /// `{name} and others ({count} proxies)`
  String proxiesProfileLabel(Object name, Object count) {
    return Intl.message(
      '$name and others ($count proxies)',
      name: 'proxiesProfileLabel',
      desc: '',
      args: [name, count],
    );
  }

  /// `Enter one link here; edit several from the quick edit of the list`
  String get singleShareLinkOnly {
    return Intl.message(
      'Enter one link here; edit several from the quick edit of the list',
      name: 'singleShareLinkOnly',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Empty fallback`
  String get emptyFallback {
    return Intl.message(
      'Empty fallback',
      name: 'emptyFallback',
      desc: '',
      args: [],
    );
  }

  /// `Default selection`
  String get defaultSelected {
    return Intl.message(
      'Default selection',
      name: 'defaultSelected',
      desc: '',
      args: [],
    );
  }

  /// `Hash by inbound user`
  String get hashByInUser {
    return Intl.message(
      'Hash by inbound user',
      name: 'hashByInUser',
      desc: '',
      args: [],
    );
  }

  /// `No local proxies`
  String get appProxiesEmpty {
    return Intl.message(
      'No local proxies',
      name: 'appProxiesEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Nodes`
  String get nodes {
    return Intl.message('Nodes', name: 'nodes', desc: '', args: []);
  }

  /// `Local proxies`
  String get localProxies {
    return Intl.message(
      'Local proxies',
      name: 'localProxies',
      desc: '',
      args: [],
    );
  }

  /// `The name is empty`
  String get customIssueEmptyName {
    return Intl.message(
      'The name is empty',
      name: 'customIssueEmptyName',
      desc: '',
      args: [],
    );
  }

  /// `{name} is a built-in policy name and cannot be used here`
  String customIssueReservedName(Object name) {
    return Intl.message(
      '$name is a built-in policy name and cannot be used here',
      name: 'customIssueReservedName',
      desc: '',
      args: [name],
    );
  }

  /// `The name {name} is already used by another proxy or proxy group`
  String customIssueDuplicateName(Object name) {
    return Intl.message(
      'The name $name is already used by another proxy or proxy group',
      name: 'customIssueDuplicateName',
      desc: '',
      args: [name],
    );
  }

  /// `The core cannot parse this proxy: {message}`
  String customIssueCoreRejected(Object message) {
    return Intl.message(
      'The core cannot parse this proxy: $message',
      name: 'customIssueCoreRejected',
      desc: '',
      args: [message],
    );
  }

  /// `These proxies or policies do not exist: {names}`
  String customIssueMissingProxies(Object names) {
    return Intl.message(
      'These proxies or policies do not exist: $names',
      name: 'customIssueMissingProxies',
      desc: '',
      args: [names],
    );
  }

  /// `These proxy providers do not exist: {names}`
  String customIssueMissingProviders(Object names) {
    return Intl.message(
      'These proxy providers do not exist: $names',
      name: 'customIssueMissingProviders',
      desc: '',
      args: [names],
    );
  }

  /// `No proxies or proxy providers are selected, so the core rejects this group`
  String get customIssueNoProxySource {
    return Intl.message(
      'No proxies or proxy providers are selected, so the core rejects this group',
      name: 'customIssueNoProxySource',
      desc: '',
      args: [],
    );
  }

  /// `Proxy groups reference each other in a loop: {path}`
  String customIssueGroupLoop(Object path) {
    return Intl.message(
      'Proxy groups reference each other in a loop: $path',
      name: 'customIssueGroupLoop',
      desc: '',
      args: [path],
    );
  }

  /// `The empty fallback must be a proxy, but {name} does not exist or is a proxy group`
  String customIssueInvalidEmptyFallback(Object name) {
    return Intl.message(
      'The empty fallback must be a proxy, but $name does not exist or is a proxy group',
      name: 'customIssueInvalidEmptyFallback',
      desc: '',
      args: [name],
    );
  }

  /// `{name} is not a valid regex: {message}`
  String customIssueInvalidFilter(Object name, Object message) {
    return Intl.message(
      '$name is not a valid regex: $message',
      name: 'customIssueInvalidFilter',
      desc: '',
      args: [name, message],
    );
  }

  /// `The dialer proxy {name} does not exist`
  String customIssueMissingDialer(Object name) {
    return Intl.message(
      'The dialer proxy $name does not exist',
      name: 'customIssueMissingDialer',
      desc: '',
      args: [name],
    );
  }

  /// `{proxy} dials through {target}, which leads back to {proxy}, so the dial loops`
  String customIssueDialerLoop(Object proxy, Object target) {
    return Intl.message(
      '$proxy dials through $target, which leads back to $proxy, so the dial loops',
      name: 'customIssueDialerLoop',
      desc: '',
      args: [proxy, target],
    );
  }

  /// `Dialing through {name} leads back to the proxy that uses it, so the connection was stopped`
  String dialerProxyLoopStopped(Object name) {
    return Intl.message(
      'Dialing through $name leads back to the proxy that uses it, so the connection was stopped',
      name: 'dialerProxyLoopStopped',
      desc: '',
      args: [name],
    );
  }

  /// `{count} items have problems, and applying this profile may fail`
  String customIssuesSummary(Object count) {
    return Intl.message(
      '$count items have problems, and applying this profile may fail',
      name: 'customIssuesSummary',
      desc: '',
      args: [count],
    );
  }

  /// `{label} is still used by {profiles}, which will not work properly once it is deleted. Are you sure you want to delete it?`
  String providerInUse(Object label, Object profiles) {
    return Intl.message(
      '$label is still used by $profiles, which will not work properly once it is deleted. Are you sure you want to delete it?',
      name: 'providerInUse',
      desc: '',
      args: [label, profiles],
    );
  }

  /// `{label} is still named by rules, proxy groups, dialer proxies, DNS or NTP in this profile, which stop working once it is deleted. Are you sure you want to delete it?`
  String proxyGroupInUse(Object label) {
    return Intl.message(
      '$label is still named by rules, proxy groups, dialer proxies, DNS or NTP in this profile, which stop working once it is deleted. Are you sure you want to delete it?',
      name: 'proxyGroupInUse',
      desc: '',
      args: [label],
    );
  }

  /// `These proxies will be deleted: {removed}. A line whose name changed counts as a new proxy, and custom profiles naming the deleted ones will flag them as missing. Apply anyway?`
  String proxiesRemovedTip(Object removed) {
    return Intl.message(
      'These proxies will be deleted: $removed. A line whose name changed counts as a new proxy, and custom profiles naming the deleted ones will flag them as missing. Apply anyway?',
      name: 'proxiesRemovedTip',
      desc: '',
      args: [removed],
    );
  }

  /// `These proxies will be deleted: {removed}. These will be added: {added}. A line whose name changed counts as a new proxy, and custom profiles naming the deleted ones will flag them as missing. Apply anyway?`
  String proxiesReplacedTip(Object removed, Object added) {
    return Intl.message(
      'These proxies will be deleted: $removed. These will be added: $added. A line whose name changed counts as a new proxy, and custom profiles naming the deleted ones will flag them as missing. Apply anyway?',
      name: 'proxiesReplacedTip',
      desc: '',
      args: [removed, added],
    );
  }

  /// `Size`
  String get fontSize {
    return Intl.message('Size', name: 'fontSize', desc: '', args: []);
  }

  /// `Large`
  String get large {
    return Intl.message('Large', name: 'large', desc: '', args: []);
  }

  /// `Extra large`
  String get extraLarge {
    return Intl.message('Extra large', name: 'extraLarge', desc: '', args: []);
  }

  /// `Switch profile`
  String get switchProfile {
    return Intl.message(
      'Switch profile',
      name: 'switchProfile',
      desc: '',
      args: [],
    );
  }

  /// `Last updated`
  String get lastUpdated {
    return Intl.message(
      'Last updated',
      name: 'lastUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Filters`
  String get filters {
    return Intl.message('Filters', name: 'filters', desc: '', args: []);
  }

  /// `Label`
  String get label {
    return Intl.message('Label', name: 'label', desc: '', args: []);
  }

  /// `Regex`
  String get regex {
    return Intl.message('Regex', name: 'regex', desc: '', args: []);
  }

  /// `Match case`
  String get matchCase {
    return Intl.message('Match case', name: 'matchCase', desc: '', args: []);
  }

  /// `Icon sets`
  String get iconSets {
    return Intl.message('Icon sets', name: 'iconSets', desc: '', args: []);
  }

  /// `Not a valid icon set`
  String get invalidIconSet {
    return Intl.message(
      'Not a valid icon set',
      name: 'invalidIconSet',
      desc: '',
      args: [],
    );
  }

  /// `Suggested`
  String get recommendedIcons {
    return Intl.message(
      'Suggested',
      name: 'recommendedIcons',
      desc: '',
      args: [],
    );
  }

  /// `Local image`
  String get localImage {
    return Intl.message('Local image', name: 'localImage', desc: '', args: []);
  }

  /// `No icon sets yet. Add them in Custom profile resources → Icon sets`
  String get iconSetsEmptyTip {
    return Intl.message(
      'No icon sets yet. Add them in Custom profile resources → Icon sets',
      name: 'iconSetsEmptyTip',
      desc: '',
      args: [],
    );
  }

  /// `Outbound`
  String get outbound {
    return Intl.message('Outbound', name: 'outbound', desc: '', args: []);
  }

  /// `Strict route`
  String get strictRoute {
    return Intl.message(
      'Strict route',
      name: 'strictRoute',
      desc: '',
      args: [],
    );
  }

  /// `TCP congestion control`
  String get congestionController {
    return Intl.message(
      'TCP congestion control',
      name: 'congestionController',
      desc: '',
      args: [],
    );
  }

  /// `TCP congestion control works only with the mips stack.`
  String get congestionControllerDesc {
    return Intl.message(
      'TCP congestion control works only with the mips stack.',
      name: 'congestionControllerDesc',
      desc: '',
      args: [],
    );
  }

  /// `Route exclude addresses`
  String get routeExcludeAddress {
    return Intl.message(
      'Route exclude addresses',
      name: 'routeExcludeAddress',
      desc: '',
      args: [],
    );
  }

  /// `TCP keep-alive idle`
  String get keepAliveIdle {
    return Intl.message(
      'TCP keep-alive idle',
      name: 'keepAliveIdle',
      desc: '',
      args: [],
    );
  }

  /// `Disable TCP keep-alive`
  String get disableKeepAlive {
    return Intl.message(
      'Disable TCP keep-alive',
      name: 'disableKeepAlive',
      desc: '',
      args: [],
    );
  }

  /// `Routing mark`
  String get routingMark {
    return Intl.message(
      'Routing mark',
      name: 'routingMark',
      desc: '',
      args: [],
    );
  }

  /// `Strict route keeps traffic such as DNS from bypassing TUN, and other devices can no longer reach this one.`
  String get strictRouteDesc {
    return Intl.message(
      'Strict route keeps traffic such as DNS from bypassing TUN, and other devices can no longer reach this one.',
      name: 'strictRouteDesc',
      desc: '',
      args: [],
    );
  }

  /// `Startup failed`
  String get initFailed {
    return Intl.message(
      'Startup failed',
      name: 'initFailed',
      desc: '',
      args: [],
    );
  }

  /// `ReClash ran into an error while starting and can't continue. Copy the details to report the problem. If it keeps happening, clearing the data usually lets the app start again.`
  String get initFailedTip {
    return Intl.message(
      'ReClash ran into an error while starting and can\'t continue. Copy the details to report the problem. If it keeps happening, clearing the data usually lets the app start again.',
      name: 'initFailedTip',
      desc: '',
      args: [],
    );
  }

  /// `Error details`
  String get errorDetails {
    return Intl.message(
      'Error details',
      name: 'errorDetails',
      desc: '',
      args: [],
    );
  }

  /// `Stack trace`
  String get stackTrace {
    return Intl.message('Stack trace', name: 'stackTrace', desc: '', args: []);
  }

  /// `This deletes all profiles, settings, and local data, then closes the app. Open it again to start fresh.`
  String get clearDataAndExitTip {
    return Intl.message(
      'This deletes all profiles, settings, and local data, then closes the app. Open it again to start fresh.',
      name: 'clearDataAndExitTip',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't clear the data: {detail}`
  String clearDataFailed(Object detail) {
    return Intl.message(
      'Couldn\'t clear the data: $detail',
      name: 'clearDataFailed',
      desc: '',
      args: [detail],
    );
  }

  /// `Bypass private addresses`
  String get bypassPrivateRoute {
    return Intl.message(
      'Bypass private addresses',
      name: 'bypassPrivateRoute',
      desc: '',
      args: [],
    );
  }

  /// `With Bypass private addresses on, LAN, loopback and multicast addresses skip TUN.`
  String get bypassPrivateRouteDesc {
    return Intl.message(
      'With Bypass private addresses on, LAN, loopback and multicast addresses skip TUN.',
      name: 'bypassPrivateRouteDesc',
      desc: '',
      args: [],
    );
  }

  /// `Disable ICMP forwarding`
  String get disableIcmpForwarding {
    return Intl.message(
      'Disable ICMP forwarding',
      name: 'disableIcmpForwarding',
      desc: '',
      args: [],
    );
  }

  /// `With ICMP forwarding disabled, TUN answers ping itself, so ping no longer shows the real latency.`
  String get disableIcmpForwardingDesc {
    return Intl.message(
      'With ICMP forwarding disabled, TUN answers ping itself, so ping no longer shows the real latency.',
      name: 'disableIcmpForwardingDesc',
      desc: '',
      args: [],
    );
  }

  /// `Excluded interfaces`
  String get excludeInterface {
    return Intl.message(
      'Excluded interfaces',
      name: 'excludeInterface',
      desc: '',
      args: [],
    );
  }

  /// `Traffic arriving on excluded interfaces, such as docker0, skips TUN.`
  String get excludeInterfaceDesc {
    return Intl.message(
      'Traffic arriving on excluded interfaces, such as docker0, skips TUN.',
      name: 'excludeInterfaceDesc',
      desc: '',
      args: [],
    );
  }

  /// `Included interfaces`
  String get includeInterface {
    return Intl.message(
      'Included interfaces',
      name: 'includeInterface',
      desc: '',
      args: [],
    );
  }

  /// `Only traffic arriving on included interfaces goes through TUN, and excluded interfaces no longer apply.`
  String get includeInterfaceDesc {
    return Intl.message(
      'Only traffic arriving on included interfaces goes through TUN, and excluded interfaces no longer apply.',
      name: 'includeInterfaceDesc',
      desc: '',
      args: [],
    );
  }

  /// `Included user IDs`
  String get includeUid {
    return Intl.message(
      'Included user IDs',
      name: 'includeUid',
      desc: '',
      args: [],
    );
  }

  /// `Only traffic from processes of included user IDs goes through TUN.`
  String get includeUidDesc {
    return Intl.message(
      'Only traffic from processes of included user IDs goes through TUN.',
      name: 'includeUidDesc',
      desc: '',
      args: [],
    );
  }

  /// `Excluded user IDs`
  String get excludeUid {
    return Intl.message(
      'Excluded user IDs',
      name: 'excludeUid',
      desc: '',
      args: [],
    );
  }

  /// `Traffic from processes of excluded user IDs skips TUN.`
  String get excludeUidDesc {
    return Intl.message(
      'Traffic from processes of excluded user IDs skips TUN.',
      name: 'excludeUidDesc',
      desc: '',
      args: [],
    );
  }

  /// `Excluded source ports`
  String get excludeSrcPort {
    return Intl.message(
      'Excluded source ports',
      name: 'excludeSrcPort',
      desc: '',
      args: [],
    );
  }

  /// `Traffic from excluded source ports skips TUN.`
  String get excludeSrcPortDesc {
    return Intl.message(
      'Traffic from excluded source ports skips TUN.',
      name: 'excludeSrcPortDesc',
      desc: '',
      args: [],
    );
  }

  /// `Excluded destination ports`
  String get excludeDstPort {
    return Intl.message(
      'Excluded destination ports',
      name: 'excludeDstPort',
      desc: '',
      args: [],
    );
  }

  /// `Traffic to excluded destination ports skips TUN.`
  String get excludeDstPortDesc {
    return Intl.message(
      'Traffic to excluded destination ports skips TUN.',
      name: 'excludeDstPortDesc',
      desc: '',
      args: [],
    );
  }

  /// `UDP timeout`
  String get udpTimeout {
    return Intl.message('UDP timeout', name: 'udpTimeout', desc: '', args: []);
  }

  /// `The UDP timeout is in seconds and works only with the gvisor, system and mixed stacks.`
  String get udpTimeoutDesc {
    return Intl.message(
      'The UDP timeout is in seconds and works only with the gvisor, system and mixed stacks.',
      name: 'udpTimeoutDesc',
      desc: '',
      args: [],
    );
  }

  /// `Without this entry, TUN hijacks every DNS query to port 53 (any:53).`
  String get dnsHijackDesc {
    return Intl.message(
      'Without this entry, TUN hijacks every DNS query to port 53 (any:53).',
      name: 'dnsHijackDesc',
      desc: '',
      args: [],
    );
  }

  /// `Entries added here replace the TUN settings of every profile; anything not added keeps the profile's own setting. Entries a custom profile adds itself take precedence.`
  String get tunOverrideDesc {
    return Intl.message(
      'Entries added here replace the TUN settings of every profile; anything not added keeps the profile\'s own setting. Entries a custom profile adds itself take precedence.',
      name: 'tunOverrideDesc',
      desc: '',
      args: [],
    );
  }

  /// `Applies to this profile only and takes precedence over the TUN override entries in the network settings.`
  String get profileTunSettingsDesc {
    return Intl.message(
      'Applies to this profile only and takes precedence over the TUN override entries in the network settings.',
      name: 'profileTunSettingsDesc',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =1{1 setting} other{{count} settings}}`
  String settingsCount(num count) {
    return Intl.plural(
      count,
      one: '1 setting',
      other: '$count settings',
      name: 'settingsCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} in effect`
  String sectionsInEffect(Object count) {
    return Intl.message(
      '$count in effect',
      name: 'sectionsInEffect',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, =1{1 item} other{{count} items}}`
  String itemsCount(num count) {
    return Intl.plural(
      count,
      one: '1 item',
      other: '$count items',
      name: 'itemsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Name prefix`
  String get additionalPrefix {
    return Intl.message(
      'Name prefix',
      name: 'additionalPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Name suffix`
  String get additionalSuffix {
    return Intl.message(
      'Name suffix',
      name: 'additionalSuffix',
      desc: '',
      args: [],
    );
  }

  /// `Skip certificate verification`
  String get skipCertVerify {
    return Intl.message(
      'Skip certificate verification',
      name: 'skipCertVerify',
      desc: '',
      args: [],
    );
  }

  /// `IP version`
  String get ipVersion {
    return Intl.message('IP version', name: 'ipVersion', desc: '', args: []);
  }

  /// `Add filters`
  String get addFilters {
    return Intl.message('Add filters', name: 'addFilters', desc: '', args: []);
  }

  /// `{label}: {message}`
  String failedItem(Object label, Object message) {
    return Intl.message(
      '$label: $message',
      name: 'failedItem',
      desc: '',
      args: [label, message],
    );
  }

  /// `{count} items failed`
  String failedCount(Object count) {
    return Intl.message(
      '$count items failed',
      name: 'failedCount',
      desc: '',
      args: [count],
    );
  }

  /// `This file is not a config that can be imported`
  String get importConfigInvalid {
    return Intl.message(
      'This file is not a config that can be imported',
      name: 'importConfigInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Importing replaces the proxy groups, rules and settings this profile has now`
  String get importConfigReplaceTip {
    return Intl.message(
      'Importing replaces the proxy groups, rules and settings this profile has now',
      name: 'importConfigReplaceTip',
      desc: '',
      args: [],
    );
  }

  /// `Network name`
  String get networkName {
    return Intl.message(
      'Network name',
      name: 'networkName',
      desc: '',
      args: [],
    );
  }

  /// `Network secret`
  String get networkSecret {
    return Intl.message(
      'Network secret',
      name: 'networkSecret',
      desc: '',
      args: [],
    );
  }

  /// `Peers`
  String get peers {
    return Intl.message('Peers', name: 'peers', desc: '', args: []);
  }

  /// `Virtual IPv4`
  String get virtualIpv4 {
    return Intl.message(
      'Virtual IPv4',
      name: 'virtualIpv4',
      desc: '',
      args: [],
    );
  }

  /// `Hostname`
  String get hostname {
    return Intl.message('Hostname', name: 'hostname', desc: '', args: []);
  }

  /// `Exit nodes`
  String get exitNodes {
    return Intl.message('Exit nodes', name: 'exitNodes', desc: '', args: []);
  }

  /// `Cipher`
  String get cipher {
    return Intl.message('Cipher', name: 'cipher', desc: '', args: []);
  }

  /// `Protocol`
  String get protocol {
    return Intl.message('Protocol', name: 'protocol', desc: '', args: []);
  }

  /// `Protocol parameter`
  String get protocolParam {
    return Intl.message(
      'Protocol parameter',
      name: 'protocolParam',
      desc: '',
      args: [],
    );
  }

  /// `Obfuscation`
  String get obfs {
    return Intl.message('Obfuscation', name: 'obfs', desc: '', args: []);
  }

  /// `Obfuscation parameter`
  String get obfsParam {
    return Intl.message(
      'Obfuscation parameter',
      name: 'obfsParam',
      desc: '',
      args: [],
    );
  }

  /// `Obfuscation password`
  String get obfsPassword {
    return Intl.message(
      'Obfuscation password',
      name: 'obfsPassword',
      desc: '',
      args: [],
    );
  }

  /// `Obfuscation mode`
  String get obfsMode {
    return Intl.message(
      'Obfuscation mode',
      name: 'obfsMode',
      desc: '',
      args: [],
    );
  }

  /// `Obfuscation host`
  String get obfsHost {
    return Intl.message(
      'Obfuscation host',
      name: 'obfsHost',
      desc: '',
      args: [],
    );
  }

  /// `Plugin`
  String get plugin {
    return Intl.message('Plugin', name: 'plugin', desc: '', args: []);
  }

  /// `Plugin mode`
  String get pluginMode {
    return Intl.message('Plugin mode', name: 'pluginMode', desc: '', args: []);
  }

  /// `Plugin host`
  String get pluginHost {
    return Intl.message('Plugin host', name: 'pluginHost', desc: '', args: []);
  }

  /// `Private key`
  String get privateKey {
    return Intl.message('Private key', name: 'privateKey', desc: '', args: []);
  }

  /// `Public key`
  String get publicKey {
    return Intl.message('Public key', name: 'publicKey', desc: '', args: []);
  }

  /// `Private key passphrase`
  String get privateKeyPassphrase {
    return Intl.message(
      'Private key passphrase',
      name: 'privateKeyPassphrase',
      desc: '',
      args: [],
    );
  }

  /// `Pre-shared key`
  String get preSharedKey {
    return Intl.message(
      'Pre-shared key',
      name: 'preSharedKey',
      desc: '',
      args: [],
    );
  }

  /// `Key`
  String get secretKey {
    return Intl.message('Key', name: 'secretKey', desc: '', args: []);
  }

  /// `Transport`
  String get transport {
    return Intl.message('Transport', name: 'transport', desc: '', args: []);
  }

  /// `Upload bandwidth`
  String get uploadBandwidth {
    return Intl.message(
      'Upload bandwidth',
      name: 'uploadBandwidth',
      desc: '',
      args: [],
    );
  }

  /// `Download bandwidth`
  String get downloadBandwidth {
    return Intl.message(
      'Download bandwidth',
      name: 'downloadBandwidth',
      desc: '',
      args: [],
    );
  }

  /// `Protocol version`
  String get protocolVersion {
    return Intl.message(
      'Protocol version',
      name: 'protocolVersion',
      desc: '',
      args: [],
    );
  }

  /// `Port hopping`
  String get portHopping {
    return Intl.message(
      'Port hopping',
      name: 'portHopping',
      desc: '',
      args: [],
    );
  }

  /// `Hop interval`
  String get hopInterval {
    return Intl.message(
      'Hop interval',
      name: 'hopInterval',
      desc: '',
      args: [],
    );
  }

  /// `Congestion control`
  String get congestionControl {
    return Intl.message(
      'Congestion control',
      name: 'congestionControl',
      desc: '',
      args: [],
    );
  }

  /// `UDP relay mode`
  String get udpRelayMode {
    return Intl.message(
      'UDP relay mode',
      name: 'udpRelayMode',
      desc: '',
      args: [],
    );
  }

  /// `Allowed IPs`
  String get allowedIps {
    return Intl.message('Allowed IPs', name: 'allowedIps', desc: '', args: []);
  }

  /// `Remote DNS resolution`
  String get remoteDnsResolve {
    return Intl.message(
      'Remote DNS resolution',
      name: 'remoteDnsResolve',
      desc: '',
      args: [],
    );
  }

  /// `Client fingerprint`
  String get clientFingerprint {
    return Intl.message(
      'Client fingerprint',
      name: 'clientFingerprint',
      desc: '',
      args: [],
    );
  }

  /// `Required`
  String get required {
    return Intl.message('Required', name: 'required', desc: '', args: []);
  }

  /// `Age secret key`
  String get ageSecretKey {
    return Intl.message(
      'Age secret key',
      name: 'ageSecretKey',
      desc: '',
      args: [],
    );
  }

  /// `Encrypted profile`
  String get ageEncryptedProfile {
    return Intl.message(
      'Encrypted profile',
      name: 'ageEncryptedProfile',
      desc: '',
      args: [],
    );
  }

  /// `This profile is encrypted with age and needs an age secret key to decrypt`
  String get ageSecretKeyRequiredTip {
    return Intl.message(
      'This profile is encrypted with age and needs an age secret key to decrypt',
      name: 'ageSecretKeyRequiredTip',
      desc: '',
      args: [],
    );
  }

  /// `Holds the start button and can't be removed`
  String get currentOutboundDesc {
    return Intl.message(
      'Holds the start button and can\'t be removed',
      name: 'currentOutboundDesc',
      desc: '',
      args: [],
    );
  }

  /// `Running`
  String get running {
    return Intl.message('Running', name: 'running', desc: '', args: []);
  }

  /// `Not running`
  String get notRunning {
    return Intl.message('Not running', name: 'notRunning', desc: '', args: []);
  }

  /// `Peak {value}`
  String trafficPeak(Object value) {
    return Intl.message(
      'Peak $value',
      name: 'trafficPeak',
      desc: '',
      args: [value],
    );
  }

  /// `Total {value}`
  String trafficTotal(Object value) {
    return Intl.message(
      'Total $value',
      name: 'trafficTotal',
      desc: '',
      args: [value],
    );
  }

  /// `Quality`
  String get ipQualityShort {
    return Intl.message('Quality', name: 'ipQualityShort', desc: '', args: []);
  }

  /// `Unknown type`
  String get ipTypeUnknown {
    return Intl.message(
      'Unknown type',
      name: 'ipTypeUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Tap the icon to retry`
  String get tapIconToRetry {
    return Intl.message(
      'Tap the icon to retry',
      name: 'tapIconToRetry',
      desc: '',
      args: [],
    );
  }

  /// `Traffic takeover`
  String get networkTakeover {
    return Intl.message(
      'Traffic takeover',
      name: 'networkTakeover',
      desc: '',
      args: [],
    );
  }

  /// `Port {port}`
  String portValue(Object port) {
    return Intl.message(
      'Port $port',
      name: 'portValue',
      desc: '',
      args: [port],
    );
  }

  /// `{count, plural, =1{1 issue} other{{count} issues}}`
  String serviceAbnormalCount(num count) {
    return Intl.plural(
      count,
      one: '1 issue',
      other: '$count issues',
      name: 'serviceAbnormalCount',
      desc: '',
      args: [count],
    );
  }

  /// `All available`
  String get serviceAllAvailable {
    return Intl.message(
      'All available',
      name: 'serviceAllAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Shown on the dashboard`
  String get serviceShownOnDashboard {
    return Intl.message(
      'Shown on the dashboard',
      name: 'serviceShownOnDashboard',
      desc: '',
      args: [],
    );
  }

  /// `{count} timed out`
  String groupTimeoutCount(Object count) {
    return Intl.message(
      '$count timed out',
      name: 'groupTimeoutCount',
      desc: '',
      args: [count],
    );
  }

  /// `groups`
  String get groupCountUnit {
    return Intl.message('groups', name: 'groupCountUnit', desc: '', args: []);
  }

  /// `{count, plural, =1{1 group} other{{count} groups}}`
  String groupCount(num count) {
    return Intl.plural(
      count,
      one: '1 group',
      other: '$count groups',
      name: 'groupCount',
      desc: '',
      args: [count],
    );
  }

  /// `Groups show up here once the core starts`
  String get proxyGroupsAfterStart {
    return Intl.message(
      'Groups show up here once the core starts',
      name: 'proxyGroupsAfterStart',
      desc: '',
      args: [],
    );
  }

  /// `used`
  String get usedShort {
    return Intl.message('used', name: 'usedShort', desc: '', args: []);
  }

  /// `Updated {time}`
  String profileUpdatedAt(Object time) {
    return Intl.message(
      'Updated $time',
      name: 'profileUpdatedAt',
      desc: '',
      args: [time],
    );
  }

  /// `Expires {date}, {days, plural, =1{1 day} other{{days} days}} left`
  String profileExpiresIn(Object date, num days) {
    return Intl.message(
      'Expires $date, ${Intl.plural(days, one: '1 day', other: '$days days')} left',
      name: 'profileExpiresIn',
      desc: '',
      args: [date, days],
    );
  }

  /// `{days, plural, =1{1 day left} other{{days} days left}}`
  String profileDaysLeft(num days) {
    return Intl.plural(
      days,
      one: '1 day left',
      other: '$days days left',
      name: 'profileDaysLeft',
      desc: '',
      args: [days],
    );
  }

  /// `Target`
  String get target {
    return Intl.message('Target', name: 'target', desc: '', args: []);
  }

  /// `Exit`
  String get outboundExit {
    return Intl.message('Exit', name: 'outboundExit', desc: '', args: []);
  }

  /// `Duration`
  String get duration {
    return Intl.message('Duration', name: 'duration', desc: '', args: []);
  }

  /// `Traffic`
  String get traffic {
    return Intl.message('Traffic', name: 'traffic', desc: '', args: []);
  }

  /// `Downloaded`
  String get totalDownload {
    return Intl.message(
      'Downloaded',
      name: 'totalDownload',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded`
  String get totalUpload {
    return Intl.message('Uploaded', name: 'totalUpload', desc: '', args: []);
  }

  /// `From`
  String get initiatorShort {
    return Intl.message('From', name: 'initiatorShort', desc: '', args: []);
  }

  /// `Result`
  String get result {
    return Intl.message('Result', name: 'result', desc: '', args: []);
  }

  /// `Took`
  String get elapsed {
    return Intl.message('Took', name: 'elapsed', desc: '', args: []);
  }

  /// `Connection stats`
  String get connectionStats {
    return Intl.message(
      'Connection stats',
      name: 'connectionStats',
      desc: '',
      args: [],
    );
  }

  /// `Live connections, recent requests and DNS queries`
  String get connectionStatsDesc {
    return Intl.message(
      'Live connections, recent requests and DNS queries',
      name: 'connectionStatsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Memory the app and the core use`
  String get memoryInfoDesc {
    return Intl.message(
      'Memory the app and the core use',
      name: 'memoryInfoDesc',
      desc: '',
      args: [],
    );
  }

  /// `Edit dashboard`
  String get editDashboard {
    return Intl.message(
      'Edit dashboard',
      name: 'editDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Available to add`
  String get dashboardAddableSection {
    return Intl.message(
      'Available to add',
      name: 'dashboardAddableSection',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, =1{1 SUB-RULE rule was dropped, since custom profiles do not support sub-rules} other{{label} SUB-RULE rules were dropped, since custom profiles do not support sub-rules}}`
  String customImportDroppedSubRules(num count, Object label) {
    return Intl.plural(
      count,
      one: '1 SUB-RULE rule was dropped, since custom profiles do not support sub-rules',
      other:
          '$label SUB-RULE rules were dropped, since custom profiles do not support sub-rules',
      name: 'customImportDroppedSubRules',
      desc: '',
      args: [count, label],
    );
  }

  /// `Auto-include`
  String get autoInclude {
    return Intl.message(
      'Auto-include',
      name: 'autoInclude',
      desc: '',
      args: [],
    );
  }

  /// `All referenced proxies`
  String get allReferencedProxies {
    return Intl.message(
      'All referenced proxies',
      name: 'allReferencedProxies',
      desc: '',
      args: [],
    );
  }

  /// `All referenced proxy providers`
  String get allReferencedProxyProviders {
    return Intl.message(
      'All referenced proxy providers',
      name: 'allReferencedProxyProviders',
      desc: '',
      args: [],
    );
  }

  /// `Maintainer`
  String get maintainer {
    return Intl.message('Maintainer', name: 'maintainer', desc: '', args: []);
  }

  /// `Gratitude`
  String get gratitude {
    return Intl.message('Gratitude', name: 'gratitude', desc: '', args: []);
  }

  /// `ReClash exists because of their work`
  String get gratitudeDesc {
    return Intl.message(
      'ReClash exists because of their work',
      name: 'gratitudeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Client foundation`
  String get creditFlClash {
    return Intl.message(
      'Client foundation',
      name: 'creditFlClash',
      desc: '',
      args: [],
    );
  }

  /// `Provider features and ideas`
  String get creditFlClashX {
    return Intl.message(
      'Provider features and ideas',
      name: 'creditFlClashX',
      desc: '',
      args: [],
    );
  }

  /// `Additional features`
  String get creditFlClashPatched {
    return Intl.message(
      'Additional features',
      name: 'creditFlClashPatched',
      desc: '',
      args: [],
    );
  }

  /// `Proxy core`
  String get creditMihomo {
    return Intl.message('Proxy core', name: 'creditMihomo', desc: '', args: []);
  }

  /// `DPI bypass`
  String get creditByeDpi {
    return Intl.message('DPI bypass', name: 'creditByeDpi', desc: '', args: []);
  }

  /// `License`
  String get license {
    return Intl.message('License', name: 'license', desc: '', args: []);
  }

  /// `Licenses`
  String get licenses {
    return Intl.message('Licenses', name: 'licenses', desc: '', args: []);
  }

  /// `Packages bundled into the app`
  String get licensesDesc {
    return Intl.message(
      'Packages bundled into the app',
      name: 'licensesDesc',
      desc: '',
      args: [],
    );
  }

  /// `App region`
  String get appRegion {
    return Intl.message('App region', name: 'appRegion', desc: '', args: []);
  }

  /// `Regional adaptation`
  String get regionalAdaptation {
    return Intl.message(
      'Regional adaptation',
      name: 'regionalAdaptation',
      desc: '',
      args: [],
    );
  }

  /// `Region profile`
  String get regionTitle {
    return Intl.message(
      'Region profile',
      name: 'regionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Picks DNS servers, TUN MTU, the bypass list and service checks for your country. The interface language does not change.`
  String get regionIntro {
    return Intl.message(
      'Picks DNS servers, TUN MTU, the bypass list and service checks for your country. The interface language does not change.',
      name: 'regionIntro',
      desc: '',
      args: [],
    );
  }

  /// `Values you changed yourself stay as they are.`
  String get regionCustomPreserved {
    return Intl.message(
      'Values you changed yourself stay as they are.',
      name: 'regionCustomPreserved',
      desc: '',
      args: [],
    );
  }

  /// `Your settings stay unchanged.`
  String get regionNoChanges {
    return Intl.message(
      'Your settings stay unchanged.',
      name: 'regionNoChanges',
      desc: '',
      args: [],
    );
  }

  /// `Apply region`
  String get regionApply {
    return Intl.message(
      'Apply region',
      name: 'regionApply',
      desc: '',
      args: [],
    );
  }

  /// `Choose a supported region before using regional app suggestions.`
  String get regionSelectBeforeApps {
    return Intl.message(
      'Choose a supported region before using regional app suggestions.',
      name: 'regionSelectBeforeApps',
      desc: '',
      args: [],
    );
  }

  /// `Not selected`
  String get regionNotSet {
    return Intl.message(
      'Not selected',
      name: 'regionNotSet',
      desc: '',
      args: [],
    );
  }

  /// `Other country`
  String get regionOther {
    return Intl.message(
      'Other country',
      name: 'regionOther',
      desc: '',
      args: [],
    );
  }

  /// `Russia`
  String get regionRussia {
    return Intl.message('Russia', name: 'regionRussia', desc: '', args: []);
  }

  /// `Iran`
  String get regionIran {
    return Intl.message('Iran', name: 'regionIran', desc: '', args: []);
  }

  /// `China`
  String get regionChina {
    return Intl.message('China', name: 'regionChina', desc: '', args: []);
  }

  /// `Egypt`
  String get regionEgypt {
    return Intl.message('Egypt', name: 'regionEgypt', desc: '', args: []);
  }

  /// `Service checks are off`
  String get regionNoServices {
    return Intl.message(
      'Service checks are off',
      name: 'regionNoServices',
      desc: '',
      args: [],
    );
  }

  /// `Select apps by region`
  String get regionSelectApps {
    return Intl.message(
      'Select apps by region',
      name: 'regionSelectApps',
      desc: '',
      args: [],
    );
  }

  /// `App selection preview`
  String get regionAppsPreviewTitle {
    return Intl.message(
      'App selection preview',
      name: 'regionAppsPreviewTitle',
      desc: '',
      args: [],
    );
  }

  /// `{region}: {bypassed} apps in the VPN bypass list, {proxied} in the VPN list. Both lists will be replaced; the mode and other settings stay unchanged. Package and SDK matches are suggestions: review them after applying.`
  String regionAppsPreview(String region, int bypassed, int proxied) {
    return Intl.message(
      '$region: $bypassed apps in the VPN bypass list, $proxied in the VPN list. Both lists will be replaced; the mode and other settings stay unchanged. Package and SDK matches are suggestions: review them after applying.',
      name: 'regionAppsPreview',
      desc: '',
      args: [region, bypassed, proxied],
    );
  }

  /// `No apps matched this region. Your lists are unchanged.`
  String get regionAppsEmpty {
    return Intl.message(
      'No apps matched this region. Your lists are unchanged.',
      name: 'regionAppsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `The region or app lists changed. Run selection again for the current settings.`
  String get regionAppsChanged {
    return Intl.message(
      'The region or app lists changed. Run selection again for the current settings.',
      name: 'regionAppsChanged',
      desc: '',
      args: [],
    );
  }

  /// `Recommended for this device`
  String get regionRecommended {
    return Intl.message(
      'Recommended for this device',
      name: 'regionRecommended',
      desc: '',
      args: [],
    );
  }

  /// `What changes`
  String get regionChangesTitle {
    return Intl.message(
      'What changes',
      name: 'regionChangesTitle',
      desc: '',
      args: [],
    );
  }

  /// `DNS servers`
  String get regionChangeDns {
    return Intl.message(
      'DNS servers',
      name: 'regionChangeDns',
      desc: '',
      args: [],
    );
  }

  /// `TUN MTU`
  String get regionChangeMtu {
    return Intl.message('TUN MTU', name: 'regionChangeMtu', desc: '', args: []);
  }

  /// `Service checks`
  String get regionChangeServices {
    return Intl.message(
      'Service checks',
      name: 'regionChangeServices',
      desc: '',
      args: [],
    );
  }

  /// `Restore defaults`
  String get restoreDefaults {
    return Intl.message(
      'Restore defaults',
      name: 'restoreDefaults',
      desc: '',
      args: [],
    );
  }

  /// `The bypass list and TUN MTU return to the defaults of the selected region.`
  String get networkRestoreDefaultsTip {
    return Intl.message(
      'The bypass list and TUN MTU return to the defaults of the selected region.',
      name: 'networkRestoreDefaultsTip',
      desc: '',
      args: [],
    );
  }

  /// `All DNS overrides are removed, and the DNS servers of the selected region are set again.`
  String get dnsRestoreDefaultsTip {
    return Intl.message(
      'All DNS overrides are removed, and the DNS servers of the selected region are set again.',
      name: 'dnsRestoreDefaultsTip',
      desc: '',
      args: [],
    );
  }

  /// `First connection`
  String get setupTitle {
    return Intl.message(
      'First connection',
      name: 'setupTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose your language`
  String get setupLanguageTitle {
    return Intl.message(
      'Choose your language',
      name: 'setupLanguageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select a language before reading the terms. You can change it later.`
  String get setupLanguageDescription {
    return Intl.message(
      'Select a language before reading the terms. You can change it later.',
      name: 'setupLanguageDescription',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get setupLanguageContinue {
    return Intl.message(
      'Continue',
      name: 'setupLanguageContinue',
      desc: '',
      args: [],
    );
  }

  /// `Add a connection profile`
  String get setupProfileTitle {
    return Intl.message(
      'Add a connection profile',
      name: 'setupProfileTitle',
      desc: '',
      args: [],
    );
  }

  /// `ReClash does not provide servers. Import a subscription or a configuration from your provider.`
  String get setupProfileDescription {
    return Intl.message(
      'ReClash does not provide servers. Import a subscription or a configuration from your provider.',
      name: 'setupProfileDescription',
      desc: '',
      args: [],
    );
  }

  /// `Profile ready`
  String get setupProfileReady {
    return Intl.message(
      'Profile ready',
      name: 'setupProfileReady',
      desc: '',
      args: [],
    );
  }

  /// `Import profile`
  String get setupProfileImport {
    return Intl.message(
      'Import profile',
      name: 'setupProfileImport',
      desc: '',
      args: [],
    );
  }

  /// `Subscription or share link`
  String get setupProfileLinkHint {
    return Intl.message(
      'Subscription or share link',
      name: 'setupProfileLinkHint',
      desc: '',
      args: [],
    );
  }

  /// `Set up later`
  String get setupProfileSkip {
    return Intl.message(
      'Set up later',
      name: 'setupProfileSkip',
      desc: '',
      args: [],
    );
  }

  /// `Which apps should connect?`
  String get setupCoverageTitle {
    return Intl.message(
      'Which apps should connect?',
      name: 'setupCoverageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose which apps use ReClash. Your profile rules decide which connections use a server.`
  String get setupCoverageDescription {
    return Intl.message(
      'Choose which apps use ReClash. Your profile rules decide which connections use a server.',
      name: 'setupCoverageDescription',
      desc: '',
      args: [],
    );
  }

  /// `All apps`
  String get setupCoverageAll {
    return Intl.message(
      'All apps',
      name: 'setupCoverageAll',
      desc: '',
      args: [],
    );
  }

  /// `TUN captures device traffic. The system may ask for permission.`
  String get setupCoverageAllDescription {
    return Intl.message(
      'TUN captures device traffic. The system may ask for permission.',
      name: 'setupCoverageAllDescription',
      desc: '',
      args: [],
    );
  }

  /// `System proxy`
  String get setupCoverageSystem {
    return Intl.message(
      'System proxy',
      name: 'setupCoverageSystem',
      desc: '',
      args: [],
    );
  }

  /// `Apps without system proxy support connect directly.`
  String get setupCoverageSystemDescription {
    return Intl.message(
      'Apps without system proxy support connect directly.',
      name: 'setupCoverageSystemDescription',
      desc: '',
      args: [],
    );
  }

  /// `I will configure apps manually`
  String get setupCoverageLocal {
    return Intl.message(
      'I will configure apps manually',
      name: 'setupCoverageLocal',
      desc: '',
      args: [],
    );
  }

  /// `Set the local proxy address in each app you want to connect.`
  String get setupCoverageLocalDescription {
    return Intl.message(
      'Set the local proxy address in each app you want to connect.',
      name: 'setupCoverageLocalDescription',
      desc: '',
      args: [],
    );
  }

  /// `Android will ask to create a VPN connection. App selection stays in access settings.`
  String get setupCoverageAndroidDescription {
    return Intl.message(
      'Android will ask to create a VPN connection. App selection stays in access settings.',
      name: 'setupCoverageAndroidDescription',
      desc: '',
      args: [],
    );
  }

  /// `Capturing all traffic does not mean sending all of it through a server. Direct routes remain in place.`
  String get setupCoverageNote {
    return Intl.message(
      'Capturing all traffic does not mean sending all of it through a server. Direct routes remain in place.',
      name: 'setupCoverageNote',
      desc: '',
      args: [],
    );
  }

  /// `Keep profile defaults`
  String get setupRegionNeutral {
    return Intl.message(
      'Keep profile defaults',
      name: 'setupRegionNeutral',
      desc: '',
      args: [],
    );
  }

  /// `Check connection`
  String get setupCheckAction {
    return Intl.message(
      'Check connection',
      name: 'setupCheckAction',
      desc: '',
      args: [],
    );
  }

  /// `Connecting and checking`
  String get setupCheckingTitle {
    return Intl.message(
      'Connecting and checking',
      name: 'setupCheckingTitle',
      desc: '',
      args: [],
    );
  }

  /// `We check one selected route. System permission requests open separately.`
  String get setupCheckingDescription {
    return Intl.message(
      'We check one selected route. System permission requests open separately.',
      name: 'setupCheckingDescription',
      desc: '',
      args: [],
    );
  }

  /// `Starting the core`
  String get setupPhaseCore {
    return Intl.message(
      'Starting the core',
      name: 'setupPhaseCore',
      desc: '',
      args: [],
    );
  }

  /// `Applying the profile`
  String get setupPhaseProfile {
    return Intl.message(
      'Applying the profile',
      name: 'setupPhaseProfile',
      desc: '',
      args: [],
    );
  }

  /// `Starting the connection`
  String get setupPhaseConnection {
    return Intl.message(
      'Starting the connection',
      name: 'setupPhaseConnection',
      desc: '',
      args: [],
    );
  }

  /// `Checking the route`
  String get setupPhaseRoute {
    return Intl.message(
      'Checking the route',
      name: 'setupPhaseRoute',
      desc: '',
      args: [],
    );
  }

  /// `Confirming the exit`
  String get setupPhaseExit {
    return Intl.message(
      'Confirming the exit',
      name: 'setupPhaseExit',
      desc: '',
      args: [],
    );
  }

  /// `Checking services`
  String get setupPhaseServices {
    return Intl.message(
      'Checking services',
      name: 'setupPhaseServices',
      desc: '',
      args: [],
    );
  }

  /// `Looking for another server`
  String get setupPhaseAlternatives {
    return Intl.message(
      'Looking for another server',
      name: 'setupPhaseAlternatives',
      desc: '',
      args: [],
    );
  }

  /// `{step} of {total}`
  String setupStepStatus(int step, int total) {
    return Intl.message(
      '$step of $total',
      name: 'setupStepStatus',
      desc: '',
      args: [step, total],
    );
  }

  /// `The result applies to this route, not every app or website.`
  String get setupCheckLimit {
    return Intl.message(
      'The result applies to this route, not every app or website.',
      name: 'setupCheckLimit',
      desc: '',
      args: [],
    );
  }

  /// `Connection works`
  String get setupConnectedTitle {
    return Intl.message(
      'Connection works',
      name: 'setupConnectedTitle',
      desc: '',
      args: [],
    );
  }

  /// `The selected route responded. Traffic follows your profile rules.`
  String get setupConnectedDescription {
    return Intl.message(
      'The selected route responded. Traffic follows your profile rules.',
      name: 'setupConnectedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Connected, with limits`
  String get setupPartialTitle {
    return Intl.message(
      'Connected, with limits',
      name: 'setupPartialTitle',
      desc: '',
      args: [],
    );
  }

  /// `The route responded, but some checks could not be confirmed.`
  String get setupPartialDescription {
    return Intl.message(
      'The route responded, but some checks could not be confirmed.',
      name: 'setupPartialDescription',
      desc: '',
      args: [],
    );
  }

  /// `Connection not confirmed`
  String get setupUnconfirmedTitle {
    return Intl.message(
      'Connection not confirmed',
      name: 'setupUnconfirmedTitle',
      desc: '',
      args: [],
    );
  }

  /// `The connection started, but the selected route did not provide enough results.`
  String get setupUnconfirmedDescription {
    return Intl.message(
      'The connection started, but the selected route did not provide enough results.',
      name: 'setupUnconfirmedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Connection needs attention`
  String get setupFailedTitle {
    return Intl.message(
      'Connection needs attention',
      name: 'setupFailedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Connect later`
  String get setupSavedTitle {
    return Intl.message(
      'Connect later',
      name: 'setupSavedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your choices are saved. You can connect from the dashboard when you are ready.`
  String get setupSavedDescription {
    return Intl.message(
      'Your choices are saved. You can connect from the dashboard when you are ready.',
      name: 'setupSavedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Connect when opening ReClash`
  String get setupAutoConnect {
    return Intl.message(
      'Connect when opening ReClash',
      name: 'setupAutoConnect',
      desc: '',
      args: [],
    );
  }

  /// `Start this connection together with the app.`
  String get setupAutoConnectDescription {
    return Intl.message(
      'Start this connection together with the app.',
      name: 'setupAutoConnectDescription',
      desc: '',
      args: [],
    );
  }

  /// `Save without connecting`
  String get setupSaveWithoutConnection {
    return Intl.message(
      'Save without connecting',
      name: 'setupSaveWithoutConnection',
      desc: '',
      args: [],
    );
  }

  /// `Check again`
  String get setupRepeat {
    return Intl.message('Check again', name: 'setupRepeat', desc: '', args: []);
  }

  /// `Try {server}`
  String setupTryServer(String server) {
    return Intl.message(
      'Try $server',
      name: 'setupTryServer',
      desc: '',
      args: [server],
    );
  }

  /// `This server responded to a separate probe. Switch and check the full route again.`
  String get setupAlternativeDescription {
    return Intl.message(
      'This server responded to a separate probe. Switch and check the full route again.',
      name: 'setupAlternativeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Check report`
  String get setupReport {
    return Intl.message(
      'Check report',
      name: 'setupReport',
      desc: '',
      args: [],
    );
  }

  /// `Your connection`
  String get setupReceipt {
    return Intl.message(
      'Your connection',
      name: 'setupReceipt',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get setupReceiptProfile {
    return Intl.message(
      'Profile',
      name: 'setupReceiptProfile',
      desc: '',
      args: [],
    );
  }

  /// `Coverage`
  String get setupReceiptCoverage {
    return Intl.message(
      'Coverage',
      name: 'setupReceiptCoverage',
      desc: '',
      args: [],
    );
  }

  /// `Check`
  String get setupReceiptCheck {
    return Intl.message('Check', name: 'setupReceiptCheck', desc: '', args: []);
  }

  /// `Not checked`
  String get setupNotChecked {
    return Intl.message(
      'Not checked',
      name: 'setupNotChecked',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get setupConfirmed {
    return Intl.message(
      'Confirmed',
      name: 'setupConfirmed',
      desc: '',
      args: [],
    );
  }

  /// `No response`
  String get setupUnavailable {
    return Intl.message(
      'No response',
      name: 'setupUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Check stopped`
  String get setupStoppedTitle {
    return Intl.message(
      'Check stopped',
      name: 'setupStoppedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your choices are saved. The previous connection was not stopped.`
  String get setupStoppedDescription {
    return Intl.message(
      'Your choices are saved. The previous connection was not stopped.',
      name: 'setupStoppedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Permission is needed`
  String get setupPermissionTitle {
    return Intl.message(
      'Permission is needed',
      name: 'setupPermissionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Allow the connection in the system prompt, retry, or choose a different scope.`
  String get setupPermissionDescription {
    return Intl.message(
      'Allow the connection in the system prompt, retry, or choose a different scope.',
      name: 'setupPermissionDescription',
      desc: '',
      args: [],
    );
  }

  /// `Local proxy is ready`
  String get setupLocalTitle {
    return Intl.message(
      'Local proxy is ready',
      name: 'setupLocalTitle',
      desc: '',
      args: [],
    );
  }

  /// `Set this address in the apps you want to connect. This check does not prove those apps are configured.`
  String get setupLocalDescription {
    return Intl.message(
      'Set this address in the apps you want to connect. This check does not prove those apps are configured.',
      name: 'setupLocalDescription',
      desc: '',
      args: [],
    );
  }

  /// `Copy proxy address`
  String get setupCopyProxy {
    return Intl.message(
      'Copy proxy address',
      name: 'setupCopyProxy',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get setupErrorDetails {
    return Intl.message(
      'Details',
      name: 'setupErrorDetails',
      desc: '',
      args: [],
    );
  }

  /// `Could not save your choices. Try again.`
  String get setupSaveError {
    return Intl.message(
      'Could not save your choices. Try again.',
      name: 'setupSaveError',
      desc: '',
      args: [],
    );
  }

  /// `Safe mode does not start a real connection. Save the setup or test it in a normal build.`
  String get setupSafeMode {
    return Intl.message(
      'Safe mode does not start a real connection. Save the setup or test it in a normal build.',
      name: 'setupSafeMode',
      desc: '',
      args: [],
    );
  }

  /// `Continue setup`
  String get setupResume {
    return Intl.message(
      'Continue setup',
      name: 'setupResume',
      desc: '',
      args: [],
    );
  }

  /// `Set up connection`
  String get setupRestart {
    return Intl.message(
      'Set up connection',
      name: 'setupRestart',
      desc: '',
      args: [],
    );
  }

  /// `Setup is incomplete; connection has not been checked.`
  String get setupLaterNote {
    return Intl.message(
      'Setup is incomplete; connection has not been checked.',
      name: 'setupLaterNote',
      desc: '',
      args: [],
    );
  }

  /// `{count} profiles available`
  String setupProfileCount(int count) {
    return Intl.message(
      '$count profiles available',
      name: 'setupProfileCount',
      desc: '',
      args: [count],
    );
  }

  /// `This profile is encrypted. Enter its age key to continue.`
  String get setupAgeKeyDescription {
    return Intl.message(
      'This profile is encrypted. Enter its age key to continue.',
      name: 'setupAgeKeyDescription',
      desc: '',
      args: [],
    );
  }

  /// `You can change any choice in settings.`
  String get setupFinishDescription {
    return Intl.message(
      'You can change any choice in settings.',
      name: 'setupFinishDescription',
      desc: '',
      args: [],
    );
  }

  /// `The route changed during the check. Check the current connection again.`
  String get setupRouteChanged {
    return Intl.message(
      'The route changed during the check. Check the current connection again.',
      name: 'setupRouteChanged',
      desc: '',
      args: [],
    );
  }

  /// `The operation did not finish. Try again or open the details.`
  String get setupUnknownError {
    return Intl.message(
      'The operation did not finish. Try again or open the details.',
      name: 'setupUnknownError',
      desc: '',
      args: [],
    );
  }

  /// `Allow connection`
  String get setupRequestPermission {
    return Intl.message(
      'Allow connection',
      name: 'setupRequestPermission',
      desc: '',
      args: [],
    );
  }

  /// `Region`
  String get setupReceiptRegion {
    return Intl.message(
      'Region',
      name: 'setupReceiptRegion',
      desc: '',
      args: [],
    );
  }

  /// `Where are you connecting from?`
  String get setupRegionTitle {
    return Intl.message(
      'Where are you connecting from?',
      name: 'setupRegionTitle',
      desc: '',
      args: [],
    );
  }

  /// `ReClash adjusts DNS, MTU and direct routes to the networks of your country. The interface language stays the same.`
  String get setupRegionStepDescription {
    return Intl.message(
      'ReClash adjusts DNS, MTU and direct routes to the networks of your country. The interface language stays the same.',
      name: 'setupRegionStepDescription',
      desc: '',
      args: [],
    );
  }

  /// `Regional settings are not changed.`
  String get setupRegionNeutralDescription {
    return Intl.message(
      'Regional settings are not changed.',
      name: 'setupRegionNeutralDescription',
      desc: '',
      args: [],
    );
  }

  /// `If you skip the choice, your current regional settings stay as they are.`
  String get setupRegionUnchosen {
    return Intl.message(
      'If you skip the choice, your current regional settings stay as they are.',
      name: 'setupRegionUnchosen',
      desc: '',
      args: [],
    );
  }

  /// `Recommended`
  String get setupRecommended {
    return Intl.message(
      'Recommended',
      name: 'setupRecommended',
      desc: '',
      args: [],
    );
  }

  /// `Local sites and apps go direct`
  String get setupDirectTitle {
    return Intl.message(
      'Local sites and apps go direct',
      name: 'setupDirectTitle',
      desc: '',
      args: [],
    );
  }

  /// `Services of your country open without the server: faster, and banks or government sites do not block you. These rules are added to the global rules:`
  String get setupDirectDescription {
    return Intl.message(
      'Services of your country open without the server: faster, and banks or government sites do not block you. These rules are added to the global rules:',
      name: 'setupDirectDescription',
      desc: '',
      args: [],
    );
  }

  /// `Looking for local apps…`
  String get setupDirectAppsScanning {
    return Intl.message(
      'Looking for local apps…',
      name: 'setupDirectAppsScanning',
      desc: '',
      args: [],
    );
  }

  /// `Apps that bypass the VPN: {count}`
  String setupDirectApps(int count) {
    return Intl.message(
      'Apps that bypass the VPN: $count',
      name: 'setupDirectApps',
      desc: '',
      args: [count],
    );
  }

  /// `They will work without the VPN. You can change the list later in access control.`
  String get setupDirectAppsReview {
    return Intl.message(
      'They will work without the VPN. You can change the list later in access control.',
      name: 'setupDirectAppsReview',
      desc: '',
      args: [],
    );
  }

  /// `No local apps found. Sites still go direct.`
  String get setupDirectAppsNone {
    return Intl.message(
      'No local apps found. Sites still go direct.',
      name: 'setupDirectAppsNone',
      desc: '',
      args: [],
    );
  }

  /// `Leave setup?`
  String get setupLeaveTitle {
    return Intl.message(
      'Leave setup?',
      name: 'setupLeaveTitle',
      desc: '',
      args: [],
    );
  }

  /// `ReClash will close. Your choices are saved, and setup continues the next time you open the app.`
  String get setupLeaveMessage {
    return Intl.message(
      'ReClash will close. Your choices are saved, and setup continues the next time you open the app.',
      name: 'setupLeaveMessage',
      desc: '',
      args: [],
    );
  }

  /// `Add or choose a profile to continue.`
  String get setupProfileContinueHint {
    return Intl.message(
      'Add or choose a profile to continue.',
      name: 'setupProfileContinueHint',
      desc: '',
      args: [],
    );
  }

  /// `Paste the link from your provider's email, bot or account page, or pick a file or QR code.`
  String get setupProfileImportHint {
    return Intl.message(
      'Paste the link from your provider\'s email, bot or account page, or pick a file or QR code.',
      name: 'setupProfileImportHint',
      desc: '',
      args: [],
    );
  }

  /// `Add another profile`
  String get setupProfileImportAnother {
    return Intl.message(
      'Add another profile',
      name: 'setupProfileImportAnother',
      desc: '',
      args: [],
    );
  }

  /// `Change settings`
  String get setupChangeSettings {
    return Intl.message(
      'Change settings',
      name: 'setupChangeSettings',
      desc: '',
      args: [],
    );
  }

  /// `What you can try`
  String get setupTipsTitle {
    return Intl.message(
      'What you can try',
      name: 'setupTipsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Make sure the internet works without ReClash.`
  String get setupTipNetwork {
    return Intl.message(
      'Make sure the internet works without ReClash.',
      name: 'setupTipNetwork',
      desc: '',
      args: [],
    );
  }

  /// `Update the profile, or pick another server after setup.`
  String get setupTipProfile {
    return Intl.message(
      'Update the profile, or pick another server after setup.',
      name: 'setupTipProfile',
      desc: '',
      args: [],
    );
  }

  /// `Choose a different coverage: some networks block VPN connections.`
  String get setupTipCoverage {
    return Intl.message(
      'Choose a different coverage: some networks block VPN connections.',
      name: 'setupTipCoverage',
      desc: '',
      args: [],
    );
  }

  /// `Update channel`
  String get updateChannel {
    return Intl.message(
      'Update channel',
      name: 'updateChannel',
      desc: '',
      args: [],
    );
  }

  /// `Release`
  String get updateChannelRelease {
    return Intl.message(
      'Release',
      name: 'updateChannelRelease',
      desc: '',
      args: [],
    );
  }

  /// `Pre-release`
  String get updateChannelPre {
    return Intl.message(
      'Pre-release',
      name: 'updateChannelPre',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't check for updates`
  String get updateCheckFailed {
    return Intl.message(
      'Couldn\'t check for updates',
      name: 'updateCheckFailed',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't download the update`
  String get updateDownloadFailed {
    return Intl.message(
      'Couldn\'t download the update',
      name: 'updateDownloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `The downloaded update failed integrity verification.`
  String get updateVerifyFailed {
    return Intl.message(
      'The downloaded update failed integrity verification.',
      name: 'updateVerifyFailed',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't start the package installer`
  String get updateInstallFailed {
    return Intl.message(
      'Couldn\'t start the package installer',
      name: 'updateInstallFailed',
      desc: '',
      args: [],
    );
  }

  /// `Allow ReClash to install apps from this source, then return to continue.`
  String get updatePermissionRequired {
    return Intl.message(
      'Allow ReClash to install apps from this source, then return to continue.',
      name: 'updatePermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Install update`
  String get installUpdate {
    return Intl.message(
      'Install update',
      name: 'installUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Downloading update`
  String get downloadingUpdate {
    return Intl.message(
      'Downloading update',
      name: 'downloadingUpdate',
      desc: '',
      args: [],
    );
  }

  /// `No release notes are available.`
  String get updateNotesUnavailable {
    return Intl.message(
      'No release notes are available.',
      name: 'updateNotesUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `See full release notes`
  String get updateSeeFullReleaseNotes {
    return Intl.message(
      'See full release notes',
      name: 'updateSeeFullReleaseNotes',
      desc: '',
      args: [],
    );
  }

  /// `Show all changes`
  String get updateShowAllNotes {
    return Intl.message(
      'Show all changes',
      name: 'updateShowAllNotes',
      desc: '',
      args: [],
    );
  }

  /// `Installed: {version}`
  String updateInstalledVersion(String version) {
    return Intl.message(
      'Installed: $version',
      name: 'updateInstalledVersion',
      desc: '',
      args: [version],
    );
  }

  /// `Updates`
  String get updateTitle {
    return Intl.message('Updates', name: 'updateTitle', desc: '', args: []);
  }

  /// `An update is available`
  String get updateOfferTitle {
    return Intl.message(
      'An update is available',
      name: 'updateOfferTitle',
      desc: '',
      args: [],
    );
  }

  /// `Release details`
  String get updateReleaseDetails {
    return Intl.message(
      'Release details',
      name: 'updateReleaseDetails',
      desc: '',
      args: [],
    );
  }

  /// `Device build`
  String get updatePackageDevice {
    return Intl.message(
      'Device build',
      name: 'updatePackageDevice',
      desc: '',
      args: [],
    );
  }

  /// `Download size`
  String get updatePackageSize {
    return Intl.message(
      'Download size',
      name: 'updatePackageSize',
      desc: '',
      args: [],
    );
  }

  /// `Package checks`
  String get updatePackageVerification {
    return Intl.message(
      'Package checks',
      name: 'updatePackageVerification',
      desc: '',
      args: [],
    );
  }

  /// `Integrity, app identity and signature verified`
  String get updatePackageVerified {
    return Intl.message(
      'Integrity, app identity and signature verified',
      name: 'updatePackageVerified',
      desc: '',
      args: [],
    );
  }

  /// `Checked after download, before installation`
  String get updatePackageVerificationPending {
    return Intl.message(
      'Checked after download, before installation',
      name: 'updatePackageVerificationPending',
      desc: '',
      args: [],
    );
  }

  /// `Update preferences`
  String get updatePreferencesTitle {
    return Intl.message(
      'Update preferences',
      name: 'updatePreferencesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose checking, downloading and installation separately.`
  String get updatePreferencesDescription {
    return Intl.message(
      'Choose checking, downloading and installation separately.',
      name: 'updatePreferencesDescription',
      desc: '',
      args: [],
    );
  }

  /// `Check automatically`
  String get updateCheckAutomatically {
    return Intl.message(
      'Check automatically',
      name: 'updateCheckAutomatically',
      desc: '',
      args: [],
    );
  }

  /// `Preload on Wi-Fi`
  String get updatePreload {
    return Intl.message(
      'Preload on Wi-Fi',
      name: 'updatePreload',
      desc: '',
      args: [],
    );
  }

  /// `Install automatically`
  String get updateAutoInstall {
    return Intl.message(
      'Install automatically',
      name: 'updateAutoInstall',
      desc: '',
      args: [],
    );
  }

  /// `Allow automatic installation?`
  String get updateAutoConsentTitle {
    return Intl.message(
      'Allow automatic installation?',
      name: 'updateAutoConsentTitle',
      desc: '',
      args: [],
    );
  }

  /// `ReClash may install verified, eligible stable updates without asking each time. It will never disconnect your VPN. Android may still ask you to confirm an installation.`
  String get updateAutoConsentDescription {
    return Intl.message(
      'ReClash may install verified, eligible stable updates without asking each time. It will never disconnect your VPN. Android may still ask you to confirm an installation.',
      name: 'updateAutoConsentDescription',
      desc: '',
      args: [],
    );
  }

  /// `Allow automatic installation`
  String get updateAllowAutomatic {
    return Intl.message(
      'Allow automatic installation',
      name: 'updateAllowAutomatic',
      desc: '',
      args: [],
    );
  }

  /// `Keep manual installation`
  String get updateDoNotEnable {
    return Intl.message(
      'Keep manual installation',
      name: 'updateDoNotEnable',
      desc: '',
      args: [],
    );
  }

  /// `On this platform, ReClash opens the release page. Download and install the update yourself.`
  String get updateDesktopDescription {
    return Intl.message(
      'On this platform, ReClash opens the release page. Download and install the update yourself.',
      name: 'updateDesktopDescription',
      desc: '',
      args: [],
    );
  }

  /// `Preferences weren't saved. Try saving again; automatic installation has not been enabled.`
  String get updatePreferencesSaveFailed {
    return Intl.message(
      'Preferences weren\'t saved. Try saving again; automatic installation has not been enabled.',
      name: 'updatePreferencesSaveFailed',
      desc: '',
      args: [],
    );
  }

  /// `Download paused`
  String get updatePausedTitle {
    return Intl.message(
      'Download paused',
      name: 'updatePausedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Checking the update`
  String get updateVerifyingTitle {
    return Intl.message(
      'Checking the update',
      name: 'updateVerifyingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ready to install`
  String get updateReadyTitle {
    return Intl.message(
      'Ready to install',
      name: 'updateReadyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Your VPN is still on`
  String get updateVpnTitle {
    return Intl.message(
      'Your VPN is still on',
      name: 'updateVpnTitle',
      desc: '',
      args: [],
    );
  }

  /// `Installation will briefly close ReClash. Disconnect only if you're ready to interrupt the connection.`
  String get updateVpnDescription {
    return Intl.message(
      'Installation will briefly close ReClash. Disconnect only if you\'re ready to interrupt the connection.',
      name: 'updateVpnDescription',
      desc: '',
      args: [],
    );
  }

  /// `Android permission needed`
  String get updatePermissionTitle {
    return Intl.message(
      'Android permission needed',
      name: 'updatePermissionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Confirm with Android`
  String get updateConfirmationTitle {
    return Intl.message(
      'Confirm with Android',
      name: 'updateConfirmationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Android requires your approval. Continue to open the system confirmation.`
  String get updateConfirmationDescription {
    return Intl.message(
      'Android requires your approval. Continue to open the system confirmation.',
      name: 'updateConfirmationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Installing the update`
  String get updateInstallingTitle {
    return Intl.message(
      'Installing the update',
      name: 'updateInstallingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Android is completing the installation. ReClash may close during this step.`
  String get updateInstallingDescription {
    return Intl.message(
      'Android is completing the installation. ReClash may close during this step.',
      name: 'updateInstallingDescription',
      desc: '',
      args: [],
    );
  }

  /// `Update installed`
  String get updateInstalledTitle {
    return Intl.message(
      'Update installed',
      name: 'updateInstalledTitle',
      desc: '',
      args: [],
    );
  }

  /// `You're up to date`
  String get updateCurrentTitle {
    return Intl.message(
      'You\'re up to date',
      name: 'updateCurrentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Checking for updates…`
  String get updateCheckingTitle {
    return Intl.message(
      'Checking for updates…',
      name: 'updateCheckingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Check your connection and try again.`
  String get updateCheckFailedDescription {
    return Intl.message(
      'Check your connection and try again.',
      name: 'updateCheckFailedDescription',
      desc: '',
      args: [],
    );
  }

  /// `The downloaded part is saved. Check your connection, then resume.`
  String get updateDownloadFailedDescription {
    return Intl.message(
      'The downloaded part is saved. Check your connection, then resume.',
      name: 'updateDownloadFailedDescription',
      desc: '',
      args: [],
    );
  }

  /// `This package can't be installed`
  String get updateVerifyFailedTitle {
    return Intl.message(
      'This package can\'t be installed',
      name: 'updateVerifyFailedTitle',
      desc: '',
      args: [],
    );
  }

  /// `The file, version or signature did not pass verification. Download a fresh copy to try again.`
  String get updateVerifyFailedDescription {
    return Intl.message(
      'The file, version or signature did not pass verification. Download a fresh copy to try again.',
      name: 'updateVerifyFailedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Android did not complete the installation. Try again when you're ready.`
  String get updateInstallFailedDescription {
    return Intl.message(
      'Android did not complete the installation. Try again when you\'re ready.',
      name: 'updateInstallFailedDescription',
      desc: '',
      args: [],
    );
  }

  /// `Download update`
  String get updateDownloadAction {
    return Intl.message(
      'Download update',
      name: 'updateDownloadAction',
      desc: '',
      args: [],
    );
  }

  /// `Not now`
  String get updateNotNow {
    return Intl.message('Not now', name: 'updateNotNow', desc: '', args: []);
  }

  /// `Continue in background`
  String get updateContinueBackground {
    return Intl.message(
      'Continue in background',
      name: 'updateContinueBackground',
      desc: '',
      args: [],
    );
  }

  /// `Pause`
  String get updatePauseAction {
    return Intl.message('Pause', name: 'updatePauseAction', desc: '', args: []);
  }

  /// `Resume download`
  String get updateResumeAction {
    return Intl.message(
      'Resume download',
      name: 'updateResumeAction',
      desc: '',
      args: [],
    );
  }

  /// `Cancel download`
  String get updateCancelDownload {
    return Intl.message(
      'Cancel download',
      name: 'updateCancelDownload',
      desc: '',
      args: [],
    );
  }

  /// `Install now`
  String get updateInstallNow {
    return Intl.message(
      'Install now',
      name: 'updateInstallNow',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect and install`
  String get updateDisconnectInstall {
    return Intl.message(
      'Disconnect and install',
      name: 'updateDisconnectInstall',
      desc: '',
      args: [],
    );
  }

  /// `Open Android settings`
  String get updateOpenAndroidSettings {
    return Intl.message(
      'Open Android settings',
      name: 'updateOpenAndroidSettings',
      desc: '',
      args: [],
    );
  }

  /// `Continue installation`
  String get updateContinueInstall {
    return Intl.message(
      'Continue installation',
      name: 'updateContinueInstall',
      desc: '',
      args: [],
    );
  }

  /// `Close window`
  String get updateCloseWindow {
    return Intl.message(
      'Close window',
      name: 'updateCloseWindow',
      desc: '',
      args: [],
    );
  }

  /// `Download again`
  String get updateDownloadAgain {
    return Intl.message(
      'Download again',
      name: 'updateDownloadAgain',
      desc: '',
      args: [],
    );
  }

  /// `Try installation again`
  String get updateRetryInstall {
    return Intl.message(
      'Try installation again',
      name: 'updateRetryInstall',
      desc: '',
      args: [],
    );
  }

  /// `Check again`
  String get updateRetryCheck {
    return Intl.message(
      'Check again',
      name: 'updateRetryCheck',
      desc: '',
      args: [],
    );
  }

  /// `Got it`
  String get updateGotIt {
    return Intl.message('Got it', name: 'updateGotIt', desc: '', args: []);
  }

  /// `A verified download for this device is unavailable. Open the release page to choose a package.`
  String get updateDirectUnavailable {
    return Intl.message(
      'A verified download for this device is unavailable. Open the release page to choose a package.',
      name: 'updateDirectUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `{speed}/s`
  String updateTransferSpeed(String speed) {
    return Intl.message(
      '$speed/s',
      name: 'updateTransferSpeed',
      desc: '',
      args: [speed],
    );
  }

  /// `{time} remaining`
  String updateRemainingTime(String time) {
    return Intl.message(
      '$time remaining',
      name: 'updateRemainingTime',
      desc: '',
      args: [time],
    );
  }

  /// `{count, plural, one{1 sec} other{{count} sec}}`
  String updateSeconds(int count) {
    return Intl.plural(
      count,
      one: '1 sec',
      other: '$count sec',
      name: 'updateSeconds',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 min} other{{count} min}}`
  String updateMinutes(int count) {
    return Intl.plural(
      count,
      one: '1 min',
      other: '$count min',
      name: 'updateMinutes',
      desc: '',
      args: [count],
    );
  }

  /// `Resume`
  String get updateResumeShort {
    return Intl.message(
      'Resume',
      name: 'updateResumeShort',
      desc: 'Short button on the dashboard update banner that resumes a paused or failed update download.',
      args: [],
    );
  }

  /// `URL scheme`
  String get urlScheme {
    return Intl.message('URL scheme', name: 'urlScheme', desc: '', args: []);
  }

  /// `Connection`
  String get urlSchemeConnection {
    return Intl.message(
      'Connection',
      name: 'urlSchemeConnection',
      desc: '',
      args: [],
    );
  }

  /// `Profiles`
  String get urlSchemeProfiles {
    return Intl.message(
      'Profiles',
      name: 'urlSchemeProfiles',
      desc: '',
      args: [],
    );
  }

  /// `External connection and close commands ask for confirmation.`
  String get urlSchemeConfirmationTip {
    return Intl.message(
      'External connection and close commands ask for confirmation.',
      name: 'urlSchemeConfirmationTip',
      desc: '',
      args: [],
    );
  }

  /// `Supported import links`
  String get urlSchemeSupportedLinks {
    return Intl.message(
      'Supported import links',
      name: 'urlSchemeSupportedLinks',
      desc: '',
      args: [],
    );
  }

  /// `Proxy share links`
  String get urlSchemeProxyLinks {
    return Intl.message(
      'Proxy share links',
      name: 'urlSchemeProxyLinks',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get urlSchemeConnect {
    return Intl.message(
      'Connect',
      name: 'urlSchemeConnect',
      desc: '',
      args: [],
    );
  }

  /// `Connect with the selected profile.`
  String get urlSchemeConnectDesc {
    return Intl.message(
      'Connect with the selected profile.',
      name: 'urlSchemeConnectDesc',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect`
  String get urlSchemeDisconnect {
    return Intl.message(
      'Disconnect',
      name: 'urlSchemeDisconnect',
      desc: '',
      args: [],
    );
  }

  /// `Stop the connection; keep the selected profile.`
  String get urlSchemeDisconnectDesc {
    return Intl.message(
      'Stop the connection; keep the selected profile.',
      name: 'urlSchemeDisconnectDesc',
      desc: '',
      args: [],
    );
  }

  /// `Toggle connection`
  String get urlSchemeToggle {
    return Intl.message(
      'Toggle connection',
      name: 'urlSchemeToggle',
      desc: '',
      args: [],
    );
  }

  /// `Connect if stopped; disconnect if running.`
  String get urlSchemeToggleDesc {
    return Intl.message(
      'Connect if stopped; disconnect if running.',
      name: 'urlSchemeToggleDesc',
      desc: '',
      args: [],
    );
  }

  /// `Show application`
  String get urlSchemeOpen {
    return Intl.message(
      'Show application',
      name: 'urlSchemeOpen',
      desc: '',
      args: [],
    );
  }

  /// `Bring ReClash to the foreground.`
  String get urlSchemeOpenDesc {
    return Intl.message(
      'Bring ReClash to the foreground.',
      name: 'urlSchemeOpenDesc',
      desc: '',
      args: [],
    );
  }

  /// `Close application`
  String get urlSchemeClose {
    return Intl.message(
      'Close application',
      name: 'urlSchemeClose',
      desc: '',
      args: [],
    );
  }

  /// `Use your configured close behavior.`
  String get urlSchemeCloseDesc {
    return Intl.message(
      'Use your configured close behavior.',
      name: 'urlSchemeCloseDesc',
      desc: '',
      args: [],
    );
  }

  /// `Add subscription`
  String get urlSchemeAdd {
    return Intl.message(
      'Add subscription',
      name: 'urlSchemeAdd',
      desc: '',
      args: [],
    );
  }

  /// `Add a subscription URL with an optional name.`
  String get urlSchemeAddDesc {
    return Intl.message(
      'Add a subscription URL with an optional name.',
      name: 'urlSchemeAddDesc',
      desc: '',
      args: [],
    );
  }

  /// `Import configuration`
  String get urlSchemeImport {
    return Intl.message(
      'Import configuration',
      name: 'urlSchemeImport',
      desc: '',
      args: [],
    );
  }

  /// `Embed a YAML or JSON configuration in the link.`
  String get urlSchemeImportDesc {
    return Intl.message(
      'Embed a YAML or JSON configuration in the link.',
      name: 'urlSchemeImportDesc',
      desc: '',
      args: [],
    );
  }

  /// `Install configuration`
  String get urlSchemeInstallConfig {
    return Intl.message(
      'Install configuration',
      name: 'urlSchemeInstallConfig',
      desc: '',
      args: [],
    );
  }

  /// `Use the subscription link format shared by Clash clients.`
  String get urlSchemeInstallConfigDesc {
    return Intl.message(
      'Use the subscription link format shared by Clash clients.',
      name: 'urlSchemeInstallConfigDesc',
      desc: '',
      args: [],
    );
  }

  /// `Build link`
  String get urlSchemeBuild {
    return Intl.message(
      'Build link',
      name: 'urlSchemeBuild',
      desc: '',
      args: [],
    );
  }

  /// `Inspect link`
  String get urlSchemeInspect {
    return Intl.message(
      'Inspect link',
      name: 'urlSchemeInspect',
      desc: '',
      args: [],
    );
  }

  /// `Action`
  String get urlSchemeAction {
    return Intl.message('Action', name: 'urlSchemeAction', desc: '', args: []);
  }

  /// `Parameters`
  String get urlSchemeParameters {
    return Intl.message(
      'Parameters',
      name: 'urlSchemeParameters',
      desc: '',
      args: [],
    );
  }

  /// `Copy link`
  String get urlSchemeCopyLink {
    return Intl.message(
      'Copy link',
      name: 'urlSchemeCopyLink',
      desc: '',
      args: [],
    );
  }

  /// `Use example`
  String get urlSchemeUseExample {
    return Intl.message(
      'Use example',
      name: 'urlSchemeUseExample',
      desc: '',
      args: [],
    );
  }

  /// `Example profile`
  String get urlSchemeExampleProfile {
    return Intl.message(
      'Example profile',
      name: 'urlSchemeExampleProfile',
      desc: '',
      args: [],
    );
  }

  /// `Paste a YAML or JSON configuration`
  String get urlSchemeConfigHint {
    return Intl.message(
      'Paste a YAML or JSON configuration',
      name: 'urlSchemeConfigHint',
      desc: '',
      args: [],
    );
  }

  /// `Link`
  String get urlSchemePreview {
    return Intl.message('Link', name: 'urlSchemePreview', desc: '', args: []);
  }

  /// `Enter a URL or configuration to build the link.`
  String get urlSchemePreviewEmpty {
    return Intl.message(
      'Enter a URL or configuration to build the link.',
      name: 'urlSchemePreviewEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Links may contain tokens or credentials. Share with care.`
  String get urlSchemePrivateLinkTip {
    return Intl.message(
      'Links may contain tokens or credentials. Share with care.',
      name: 'urlSchemePrivateLinkTip',
      desc: '',
      args: [],
    );
  }

  /// `Could not copy the link. Try again.`
  String get urlSchemeCopyFailed {
    return Intl.message(
      'Could not copy the link. Try again.',
      name: 'urlSchemeCopyFailed',
      desc: '',
      args: [],
    );
  }

  /// `Could not read the clipboard. Paste the link manually.`
  String get urlSchemePasteFailed {
    return Intl.message(
      'Could not read the clipboard. Paste the link manually.',
      name: 'urlSchemePasteFailed',
      desc: '',
      args: [],
    );
  }

  /// `Inspection stays on this device. It does not open a link, download a subscription or import a profile.`
  String get urlSchemeInspectTip {
    return Intl.message(
      'Inspection stays on this device. It does not open a link, download a subscription or import a profile.',
      name: 'urlSchemeInspectTip',
      desc: '',
      args: [],
    );
  }

  /// `Paste an application or profile link`
  String get urlSchemeInspectHint {
    return Intl.message(
      'Paste an application or profile link',
      name: 'urlSchemeInspectHint',
      desc: '',
      args: [],
    );
  }

  /// `Inspection result`
  String get urlSchemeInspectionResult {
    return Intl.message(
      'Inspection result',
      name: 'urlSchemeInspectionResult',
      desc: '',
      args: [],
    );
  }

  /// `Link recognized`
  String get urlSchemeRecognized {
    return Intl.message(
      'Link recognized',
      name: 'urlSchemeRecognized',
      desc: '',
      args: [],
    );
  }

  /// `No action was executed.`
  String get urlSchemeNoExecution {
    return Intl.message(
      'No action was executed.',
      name: 'urlSchemeNoExecution',
      desc: '',
      args: [],
    );
  }

  /// `The link structure is valid. Subscription availability and Core validation are checked only during import.`
  String get urlSchemeInspectionLimit {
    return Intl.message(
      'The link structure is valid. Subscription availability and Core validation are checked only during import.',
      name: 'urlSchemeInspectionLimit',
      desc: '',
      args: [],
    );
  }

  /// `Content format`
  String get urlSchemeContentFormat {
    return Intl.message(
      'Content format',
      name: 'urlSchemeContentFormat',
      desc: '',
      args: [],
    );
  }

  /// `Configuration contents`
  String get urlSchemeConfigSummary {
    return Intl.message(
      'Configuration contents',
      name: 'urlSchemeConfigSummary',
      desc: '',
      args: [],
    );
  }

  /// `{nodes} proxies, {groups} groups, {providers} remote providers`
  String urlSchemeConfigCounts(int nodes, int groups, int providers) {
    return Intl.message(
      '$nodes proxies, $groups groups, $providers remote providers',
      name: 'urlSchemeConfigCounts',
      desc: '',
      args: [nodes, groups, providers],
    );
  }

  /// `Conversion omits some content. Review and approve these changes during import.`
  String get urlSchemeConversionWarning {
    return Intl.message(
      'Conversion omits some content. Review and approve these changes during import.',
      name: 'urlSchemeConversionWarning',
      desc: '',
      args: [],
    );
  }

  /// `External application command`
  String get urlSchemeConfirmTitle {
    return Intl.message(
      'External application command',
      name: 'urlSchemeConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `This link requests “{action}”. Allow ReClash to perform this action?`
  String urlSchemeConfirmMessage(String action) {
    return Intl.message(
      'This link requests “$action”. Allow ReClash to perform this action?',
      name: 'urlSchemeConfirmMessage',
      desc: '',
      args: [action],
    );
  }

  /// `Import “{name}” from {source}? Profile validation and any conversion review follow your confirmation.`
  String urlSchemeImportConfirm(String name, String source) {
    return Intl.message(
      'Import “$name” from $source? Profile validation and any conversion review follow your confirmation.',
      name: 'urlSchemeImportConfirm',
      desc: '',
      args: [name, source],
    );
  }

  /// `Embedded configuration`
  String get urlSchemeEmbeddedConfig {
    return Intl.message(
      'Embedded configuration',
      name: 'urlSchemeEmbeddedConfig',
      desc: '',
      args: [],
    );
  }

  /// `Finish the connection setup before using external connection commands.`
  String get urlSchemeSetupRequired {
    return Intl.message(
      'Finish the connection setup before using external connection commands.',
      name: 'urlSchemeSetupRequired',
      desc: '',
      args: [],
    );
  }

  /// `Could not deliver the link, or the pending link queue is full. Try again after the current action finishes.`
  String get urlSchemeDeliveryError {
    return Intl.message(
      'Could not deliver the link, or the pending link queue is full. Try again after the current action finishes.',
      name: 'urlSchemeDeliveryError',
      desc: '',
      args: [],
    );
  }

  /// `The link is malformed. Check its structure and percent encoding.`
  String get urlSchemeInvalidLink {
    return Intl.message(
      'The link is malformed. Check its structure and percent encoding.',
      name: 'urlSchemeInvalidLink',
      desc: '',
      args: [],
    );
  }

  /// `This link command is not supported.`
  String get urlSchemeUnknownCommand {
    return Intl.message(
      'This link command is not supported.',
      name: 'urlSchemeUnknownCommand',
      desc: '',
      args: [],
    );
  }

  /// `The link is missing a subscription URL or configuration.`
  String get urlSchemeMissingPayload {
    return Intl.message(
      'The link is missing a subscription URL or configuration.',
      name: 'urlSchemeMissingPayload',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid HTTP or HTTPS subscription URL.`
  String get urlSchemeInvalidUrl {
    return Intl.message(
      'Enter a valid HTTP or HTTPS subscription URL.',
      name: 'urlSchemeInvalidUrl',
      desc: '',
      args: [],
    );
  }

  /// `Use a profile name of up to 64 characters, without control characters.`
  String get urlSchemeInvalidName {
    return Intl.message(
      'Use a profile name of up to 64 characters, without control characters.',
      name: 'urlSchemeInvalidName',
      desc: '',
      args: [],
    );
  }

  /// `The embedded configuration is not valid UTF-8 Base64 data.`
  String get urlSchemeInvalidBase64 {
    return Intl.message(
      'The embedded configuration is not valid UTF-8 Base64 data.',
      name: 'urlSchemeInvalidBase64',
      desc: '',
      args: [],
    );
  }

  /// `The link exceeds 4 MB or its embedded configuration exceeds 2 MB.`
  String get urlSchemeTooLarge {
    return Intl.message(
      'The link exceeds 4 MB or its embedded configuration exceeds 2 MB.',
      name: 'urlSchemeTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `The link contains too many nested wrappers.`
  String get urlSchemeTooDeep {
    return Intl.message(
      'The link contains too many nested wrappers.',
      name: 'urlSchemeTooDeep',
      desc: '',
      args: [],
    );
  }

  /// `This encryption version is not supported. Request a plain subscription link.`
  String get urlSchemeUnsupportedEncryption {
    return Intl.message(
      'This encryption version is not supported. Request a plain subscription link.',
      name: 'urlSchemeUnsupportedEncryption',
      desc: '',
      args: [],
    );
  }

  /// `The encrypted link could not be authenticated. It may be damaged or use a different key.`
  String get urlSchemeAuthenticationFailed {
    return Intl.message(
      'The encrypted link could not be authenticated. It may be damaged or use a different key.',
      name: 'urlSchemeAuthenticationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Telegram`
  String get telegramLinkTitle {
    return Intl.message(
      'Telegram',
      name: 'telegramLinkTitle',
      desc: '',
      args: [],
    );
  }

  /// `Open Telegram`
  String get telegramOpen {
    return Intl.message(
      'Open Telegram',
      name: 'telegramOpen',
      desc: '',
      args: [],
    );
  }

  /// `Open in browser`
  String get telegramWebFallback {
    return Intl.message(
      'Open in browser',
      name: 'telegramWebFallback',
      desc: '',
      args: [],
    );
  }

  /// `Telegram could not be opened on this device.`
  String get telegramAppUnavailable {
    return Intl.message(
      'Telegram could not be opened on this device.',
      name: 'telegramAppUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Formats`
  String get urlSchemeFormats {
    return Intl.message(
      'Formats',
      name: 'urlSchemeFormats',
      desc: '',
      args: [],
    );
  }

  /// `Link formats. Replace placeholders with your URL or data.`
  String get urlSchemeFormatsTip {
    return Intl.message(
      'Link formats. Replace placeholders with your URL or data.',
      name: 'urlSchemeFormatsTip',
      desc: '',
      args: [],
    );
  }

  /// `New subscription`
  String get profileImportTitle {
    return Intl.message(
      'New subscription',
      name: 'profileImportTitle',
      desc: '',
      args: [],
    );
  }

  /// `Checking the subscription…`
  String get profileImportChecking {
    return Intl.message(
      'Checking the subscription…',
      name: 'profileImportChecking',
      desc: '',
      args: [],
    );
  }

  /// `Couldn’t look inside the subscription. You can still add it.`
  String get profileImportPreviewFailed {
    return Intl.message(
      'Couldn’t look inside the subscription. You can still add it.',
      name: 'profileImportPreviewFailed',
      desc: '',
      args: [],
    );
  }

  /// `The subscription is encrypted; you’ll be asked for the key when adding it.`
  String get profileImportEncrypted {
    return Intl.message(
      'The subscription is encrypted; you’ll be asked for the key when adding it.',
      name: 'profileImportEncrypted',
      desc: '',
      args: [],
    );
  }

  /// `Subscription format`
  String get profileImportFormat {
    return Intl.message(
      'Subscription format',
      name: 'profileImportFormat',
      desc: '',
      args: [],
    );
  }

  /// `As the {client} app receives it`
  String profileImportFormatClient(String client) {
    return Intl.message(
      'As the $client app receives it',
      name: 'profileImportFormatClient',
      desc: '',
      args: [client],
    );
  }

  /// `The best format for ReClash, picked automatically`
  String get profileImportFormatReclash {
    return Intl.message(
      'The best format for ReClash, picked automatically',
      name: 'profileImportFormatReclash',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{1 server} other{{count} servers}}`
  String profileImportServerCount(int count) {
    return Intl.plural(
      count,
      one: '1 server',
      other: '$count servers',
      name: 'profileImportServerCount',
      desc: '',
      args: [count],
    );
  }

  /// `Already added as “{name}”`
  String profileImportAlreadyAdded(String name) {
    return Intl.message(
      'Already added as “$name”',
      name: 'profileImportAlreadyAdded',
      desc: '',
      args: [name],
    );
  }

  /// `Some parts aren’t supported; you’ll review them before adding.`
  String get profileImportLosses {
    return Intl.message(
      'Some parts aren’t supported; you’ll review them before adding.',
      name: 'profileImportLosses',
      desc: '',
      args: [],
    );
  }

  /// `Servers`
  String get profileImportServers {
    return Intl.message(
      'Servers',
      name: 'profileImportServers',
      desc: '',
      args: [],
    );
  }

  /// `Valid until`
  String get profileImportValidUntil {
    return Intl.message(
      'Valid until',
      name: 'profileImportValidUntil',
      desc: '',
      args: [],
    );
  }

  /// `Unlimited`
  String get profileImportUnlimited {
    return Intl.message(
      'Unlimited',
      name: 'profileImportUnlimited',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get profileImportExpired {
    return Intl.message(
      'Expired',
      name: 'profileImportExpired',
      desc: '',
      args: [],
    );
  }

  /// `From the provider`
  String get profileImportFromProvider {
    return Intl.message(
      'From the provider',
      name: 'profileImportFromProvider',
      desc: '',
      args: [],
    );
  }

  /// `Single server`
  String get profileImportSingleServer {
    return Intl.message(
      'Single server',
      name: 'profileImportSingleServer',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get appearanceTheme {
    return Intl.message('Theme', name: 'appearanceTheme', desc: '', args: []);
  }

  /// `Background`
  String get appearanceBackground {
    return Intl.message(
      'Background',
      name: 'appearanceBackground',
      desc: '',
      args: [],
    );
  }

  /// `Custom background`
  String get wallpaperTitle {
    return Intl.message(
      'Custom background',
      name: 'wallpaperTitle',
      desc: '',
      args: [],
    );
  }

  /// `Remove image`
  String get wallpaperRemove {
    return Intl.message(
      'Remove image',
      name: 'wallpaperRemove',
      desc: '',
      args: [],
    );
  }

  /// `Use custom background`
  String get wallpaperEnabled {
    return Intl.message(
      'Use custom background',
      name: 'wallpaperEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Image fit`
  String get wallpaperFit {
    return Intl.message('Image fit', name: 'wallpaperFit', desc: '', args: []);
  }

  /// `Fill`
  String get wallpaperFitCover {
    return Intl.message('Fill', name: 'wallpaperFitCover', desc: '', args: []);
  }

  /// `Fit`
  String get wallpaperFitContain {
    return Intl.message('Fit', name: 'wallpaperFitContain', desc: '', args: []);
  }

  /// `Stretch`
  String get wallpaperFitFill {
    return Intl.message(
      'Stretch',
      name: 'wallpaperFitFill',
      desc: '',
      args: [],
    );
  }

  /// `Scale`
  String get wallpaperScale {
    return Intl.message('Scale', name: 'wallpaperScale', desc: '', args: []);
  }

  /// `Horizontal position`
  String get wallpaperHorizontalPosition {
    return Intl.message(
      'Horizontal position',
      name: 'wallpaperHorizontalPosition',
      desc: '',
      args: [],
    );
  }

  /// `Vertical position`
  String get wallpaperVerticalPosition {
    return Intl.message(
      'Vertical position',
      name: 'wallpaperVerticalPosition',
      desc: '',
      args: [],
    );
  }

  /// `Image opacity`
  String get wallpaperOpacity {
    return Intl.message(
      'Image opacity',
      name: 'wallpaperOpacity',
      desc: '',
      args: [],
    );
  }

  /// `Dimming`
  String get wallpaperDimming {
    return Intl.message(
      'Dimming',
      name: 'wallpaperDimming',
      desc: '',
      args: [],
    );
  }

  /// `Blur`
  String get wallpaperBlur {
    return Intl.message('Blur', name: 'wallpaperBlur', desc: '', args: []);
  }

  /// `Card opacity`
  String get wallpaperCardOpacity {
    return Intl.message(
      'Card opacity',
      name: 'wallpaperCardOpacity',
      desc: '',
      args: [],
    );
  }

  /// `Choose a valid PNG, JPEG or WebP image.`
  String get wallpaperImageError {
    return Intl.message(
      'Choose a valid PNG, JPEG or WebP image.',
      name: 'wallpaperImageError',
      desc: '',
      args: [],
    );
  }

  /// `Choose an image up to 20 MB and 50 megapixels.`
  String get wallpaperTooLarge {
    return Intl.message(
      'Choose an image up to 20 MB and 50 megapixels.',
      name: 'wallpaperTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `Could not save the background. Your previous background has been kept.`
  String get wallpaperSaveError {
    return Intl.message(
      'Could not save the background. Your previous background has been kept.',
      name: 'wallpaperSaveError',
      desc: '',
      args: [],
    );
  }

  /// `PNG, JPEG or WebP · up to 20 MB`
  String get wallpaperSelectHint {
    return Intl.message(
      'PNG, JPEG or WebP · up to 20 MB',
      name: 'wallpaperSelectHint',
      desc: '',
      args: [],
    );
  }

  /// `Framing`
  String get wallpaperLayout {
    return Intl.message('Framing', name: 'wallpaperLayout', desc: '', args: []);
  }

  /// `Image adjustments`
  String get wallpaperEffects {
    return Intl.message(
      'Image adjustments',
      name: 'wallpaperEffects',
      desc: '',
      args: [],
    );
  }

  /// `Readability`
  String get wallpaperReadability {
    return Intl.message(
      'Readability',
      name: 'wallpaperReadability',
      desc: '',
      args: [],
    );
  }

  /// `You can keep up to {count} backgrounds. Remove one to add another.`
  String wallpaperLibraryFull(int count) {
    return Intl.message(
      'You can keep up to $count backgrounds. Remove one to add another.',
      name: 'wallpaperLibraryFull',
      desc: '',
      args: [count],
    );
  }

  /// `Interface`
  String get appearanceInterface {
    return Intl.message(
      'Interface',
      name: 'appearanceInterface',
      desc: '',
      args: [],
    );
  }

  /// `Reset effects`
  String get wallpaperReset {
    return Intl.message(
      'Reset effects',
      name: 'wallpaperReset',
      desc: '',
      args: [],
    );
  }

  /// `Reset framing`
  String get wallpaperResetLayout {
    return Intl.message(
      'Reset framing',
      name: 'wallpaperResetLayout',
      desc: '',
      args: [],
    );
  }

  /// `Background {index}`
  String wallpaperImageLabel(int index) {
    return Intl.message(
      'Background $index',
      name: 'wallpaperImageLabel',
      desc: '',
      args: [index],
    );
  }

  /// `Image unavailable`
  String get wallpaperUnavailable {
    return Intl.message(
      'Image unavailable',
      name: 'wallpaperUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Navigation`
  String get navigationLayout {
    return Intl.message(
      'Navigation',
      name: 'navigationLayout',
      desc: '',
      args: [],
    );
  }

  /// `Tab bar`
  String get navigationLayoutBar {
    return Intl.message(
      'Tab bar',
      name: 'navigationLayoutBar',
      desc: '',
      args: [],
    );
  }

  /// `Sidebar`
  String get navigationLayoutSidebar {
    return Intl.message(
      'Sidebar',
      name: 'navigationLayoutSidebar',
      desc: '',
      args: [],
    );
  }

  /// `Running`
  String get coreRunning {
    return Intl.message('Running', name: 'coreRunning', desc: '', args: []);
  }

  /// `Starting…`
  String get coreStarting {
    return Intl.message('Starting…', name: 'coreStarting', desc: '', args: []);
  }

  /// `Stopped`
  String get coreStopped {
    return Intl.message('Stopped', name: 'coreStopped', desc: '', args: []);
  }

  /// `Build time`
  String get coreBuildTime {
    return Intl.message(
      'Build time',
      name: 'coreBuildTime',
      desc: '',
      args: [],
    );
  }

  /// `Environment`
  String get coreEnvironment {
    return Intl.message(
      'Environment',
      name: 'coreEnvironment',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get coreLocation {
    return Intl.message('Location', name: 'coreLocation', desc: '', args: []);
  }

  /// `Platform`
  String get corePlatform {
    return Intl.message('Platform', name: 'corePlatform', desc: '', args: []);
  }

  /// `Architecture`
  String get coreArchitecture {
    return Intl.message(
      'Architecture',
      name: 'coreArchitecture',
      desc: '',
      args: [],
    );
  }

  /// `Build flags`
  String get coreBuildTags {
    return Intl.message(
      'Build flags',
      name: 'coreBuildTags',
      desc: '',
      args: [],
    );
  }

  /// `Execution mode`
  String get coreLaunchMode {
    return Intl.message(
      'Execution mode',
      name: 'coreLaunchMode',
      desc: '',
      args: [],
    );
  }

  /// `In-process library`
  String get coreModeLibrary {
    return Intl.message(
      'In-process library',
      name: 'coreModeLibrary',
      desc: '',
      args: [],
    );
  }

  /// `Separate process`
  String get coreModeProcess {
    return Intl.message(
      'Separate process',
      name: 'coreModeProcess',
      desc: '',
      args: [],
    );
  }

  /// `Process via Helper`
  String get coreModeHelper {
    return Intl.message(
      'Process via Helper',
      name: 'coreModeHelper',
      desc: '',
      args: [],
    );
  }

  /// `Data directory`
  String get coreWorkingDirectory {
    return Intl.message(
      'Data directory',
      name: 'coreWorkingDirectory',
      desc: '',
      args: [],
    );
  }

  /// `Core binary`
  String get coreExecutable {
    return Intl.message(
      'Core binary',
      name: 'coreExecutable',
      desc: '',
      args: [],
    );
  }

  /// `Could not read core information`
  String get coreInfoUnavailable {
    return Intl.message(
      'Could not read core information',
      name: 'coreInfoUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Runtime configuration`
  String get coreRuntimeConfig {
    return Intl.message(
      'Runtime configuration',
      name: 'coreRuntimeConfig',
      desc: '',
      args: [],
    );
  }

  /// `Open runtime configuration`
  String get coreOpenRuntimeConfig {
    return Intl.message(
      'Open runtime configuration',
      name: 'coreOpenRuntimeConfig',
      desc: '',
      args: [],
    );
  }

  /// `Generated configuration after settings and scripts. Read-only.`
  String get coreRuntimeConfigDescription {
    return Intl.message(
      'Generated configuration after settings and scripts. Read-only.',
      name: 'coreRuntimeConfigDescription',
      desc: '',
      args: [],
    );
  }

  /// `Could not read the runtime configuration`
  String get coreRuntimeConfigReadFailed {
    return Intl.message(
      'Could not read the runtime configuration',
      name: 'coreRuntimeConfigReadFailed',
      desc: '',
      args: [],
    );
  }

  /// `These combinations work while the app window is focused. For global shortcuts, connect desktop commands using the section below.`
  String get hotkeyLocalDesc {
    return Intl.message(
      'These combinations work while the app window is focused. For global shortcuts, connect desktop commands using the section below.',
      name: 'hotkeyLocalDesc',
      desc: '',
      args: [],
    );
  }

  /// `Safe mode disables shortcut actions; bindings remain editable.`
  String get hotkeySafeModeDesc {
    return Intl.message(
      'Safe mode disables shortcut actions; bindings remain editable.',
      name: 'hotkeySafeModeDesc',
      desc: '',
      args: [],
    );
  }

  /// `Desktop shortcuts`
  String get hotkeyDesktopCommands {
    return Intl.message(
      'Desktop shortcuts',
      name: 'hotkeyDesktopCommands',
      desc: '',
      args: [],
    );
  }

  /// `Assign a command to a custom shortcut in your desktop settings. ReClash must be running, but its window can stay hidden. Manage these global bindings in your desktop settings.`
  String get hotkeyDesktopCommandsDesc {
    return Intl.message(
      'Assign a command to a custom shortcut in your desktop settings. ReClash must be running, but its window can stay hidden. Manage these global bindings in your desktop settings.',
      name: 'hotkeyDesktopCommandsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Compositor configuration`
  String get hotkeyCompositorConfig {
    return Intl.message(
      'Compositor configuration',
      name: 'hotkeyCompositorConfig',
      desc: '',
      args: [],
    );
  }

  /// `Alternatively, add an include line to your compositor configuration. These files follow the combinations set in ReClash and temporarily clear them during recording. Your desktop configuration is never modified automatically; resolve any conflicting bindings there.`
  String get hotkeyCompositorConfigDesc {
    return Intl.message(
      'Alternatively, add an include line to your compositor configuration. These files follow the combinations set in ReClash and temporarily clear them during recording. Your desktop configuration is never modified automatically; resolve any conflicting bindings there.',
      name: 'hotkeyCompositorConfigDesc',
      desc: '',
      args: [],
    );
  }

  /// `Not exported: {actions}`
  String hotkeyExportSkipped(String actions) {
    return Intl.message(
      'Not exported: $actions',
      name: 'hotkeyExportSkipped',
      desc: '',
      args: [actions],
    );
  }

  /// `Compositor configuration files are unavailable. You can still use the desktop commands above.`
  String get hotkeyExportUnavailable {
    return Intl.message(
      'Compositor configuration files are unavailable. You can still use the desktop commands above.',
      name: 'hotkeyExportUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Restore defaults`
  String get hotkeyRestoreDefaults {
    return Intl.message(
      'Restore defaults',
      name: 'hotkeyRestoreDefaults',
      desc: '',
      args: [],
    );
  }

  /// `Replace all combinations with the defaults?`
  String get hotkeyRestoreDefaultsTip {
    return Intl.message(
      'Replace all combinations with the defaults?',
      name: 'hotkeyRestoreDefaultsTip',
      desc: '',
      args: [],
    );
  }

  /// `Clear all`
  String get hotkeyClearAll {
    return Intl.message(
      'Clear all',
      name: 'hotkeyClearAll',
      desc: '',
      args: [],
    );
  }

  /// `Remove all hotkey combinations?`
  String get hotkeyClearAllTip {
    return Intl.message(
      'Remove all hotkey combinations?',
      name: 'hotkeyClearAllTip',
      desc: '',
      args: [],
    );
  }

  /// `Managed elevated process`
  String get coreModeElevated {
    return Intl.message(
      'Managed elevated process',
      name: 'coreModeElevated',
      desc: '',
      args: [],
    );
  }

  /// `Managed process via signed Helper`
  String get coreModePrivilegedHelper {
    return Intl.message(
      'Managed process via signed Helper',
      name: 'coreModePrivilegedHelper',
      desc: '',
      args: [],
    );
  }

  /// `TUN needs authorization. Start the connection or enable TUN to authorize it.`
  String get desktopAuthorizationRequired {
    return Intl.message(
      'TUN needs authorization. Start the connection or enable TUN to authorize it.',
      name: 'desktopAuthorizationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Authorization was cancelled. TUN has not started.`
  String get desktopAuthorizationCancelled {
    return Intl.message(
      'Authorization was cancelled. TUN has not started.',
      name: 'desktopAuthorizationCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Authorization was not granted. TUN has not started.`
  String get desktopAuthorizationDenied {
    return Intl.message(
      'Authorization was not granted. TUN has not started.',
      name: 'desktopAuthorizationDenied',
      desc: '',
      args: [],
    );
  }

  /// `No graphical authorization agent is available. Start one for this desktop session and try again.`
  String get desktopAuthorizationAgentUnavailable {
    return Intl.message(
      'No graphical authorization agent is available. Start one for this desktop session and try again.',
      name: 'desktopAuthorizationAgentUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `The TUN Helper is unavailable. Check the installed package and service, then try again.`
  String get desktopHelperUnavailable {
    return Intl.message(
      'The TUN Helper is unavailable. Check the installed package and service, then try again.',
      name: 'desktopHelperUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Allow the ReClash Helper in System Settings → General → Login Items & Extensions, then try again.`
  String get desktopHelperApprovalRequired {
    return Intl.message(
      'Allow the ReClash Helper in System Settings → General → Login Items & Extensions, then try again.',
      name: 'desktopHelperApprovalRequired',
      desc: '',
      args: [],
    );
  }

  /// `TUN requires a correctly signed ReClash app and Helper. An unsigned or ad-hoc build cannot be authorized.`
  String get desktopSigningRequired {
    return Intl.message(
      'TUN requires a correctly signed ReClash app and Helper. An unsigned or ad-hoc build cannot be authorized.',
      name: 'desktopSigningRequired',
      desc: '',
      args: [],
    );
  }

  /// `The Core or Helper failed integrity verification. Reinstall a complete ReClash package.`
  String get desktopBundleInvalid {
    return Intl.message(
      'The Core or Helper failed integrity verification. Reinstall a complete ReClash package.',
      name: 'desktopBundleInvalid',
      desc: '',
      args: [],
    );
  }

  /// `The previous authorization or Core shutdown is still pending. Wait for it to finish before trying again.`
  String get desktopLaunchPending {
    return Intl.message(
      'The previous authorization or Core shutdown is still pending. Wait for it to finish before trying again.',
      name: 'desktopLaunchPending',
      desc: '',
      args: [],
    );
  }

  /// `Authorization timed out. Try again from the connection button.`
  String get desktopAuthorizationTimeout {
    return Intl.message(
      'Authorization timed out. Try again from the connection button.',
      name: 'desktopAuthorizationTimeout',
      desc: '',
      args: [],
    );
  }

  /// `The authorized Core could not complete a verified startup. Check the package and system logs.`
  String get desktopBootstrapFailed {
    return Intl.message(
      'The authorized Core could not complete a verified startup. Check the package and system logs.',
      name: 'desktopBootstrapFailed',
      desc: '',
      args: [],
    );
  }

  /// `The Core started, but the TUN adapter is not ready. Check the Core log before using TUN.`
  String get desktopTunNotReady {
    return Intl.message(
      'The Core started, but the TUN adapter is not ready. Check the Core log before using TUN.',
      name: 'desktopTunNotReady',
      desc: '',
      args: [],
    );
  }

  /// `The existing Linux Helper registration cannot be safely replaced. Inspect the owned service and registration; retrying authorization will not resolve this conflict.`
  String get desktopHelperRegistrationConflict {
    return Intl.message(
      'The existing Linux Helper registration cannot be safely replaced. Inspect the owned service and registration; retrying authorization will not resolve this conflict.',
      name: 'desktopHelperRegistrationConflict',
      desc: '',
      args: [],
    );
  }

  /// `systemd could not start the TUN Helper. Check the service journal; the installer attempted to restore the previous installation.`
  String get desktopHelperSystemdFailed {
    return Intl.message(
      'systemd could not start the TUN Helper. Check the service journal; the installer attempted to restore the previous installation.',
      name: 'desktopHelperSystemdFailed',
      desc: '',
      args: [],
    );
  }

  /// `The installed Helper uses a different protocol. Check for another installation or a service override, then reinstall the complete package.`
  String get desktopHelperProtocolMismatch {
    return Intl.message(
      'The installed Helper uses a different protocol. Check for another installation or a service override, then reinstall the complete package.',
      name: 'desktopHelperProtocolMismatch',
      desc: '',
      args: [],
    );
  }

  /// `TUN requires a Linux session managed by systemd. This system cannot run the network Helper.`
  String get desktopHelperSystemdRequired {
    return Intl.message(
      'TUN requires a Linux session managed by systemd. This system cannot run the network Helper.',
      name: 'desktopHelperSystemdRequired',
      desc: '',
      args: [],
    );
  }

  /// `Suggest a translation fix`
  String get translationSuggestFix {
    return Intl.message(
      'Suggest a translation fix',
      name: 'translationSuggestFix',
      desc: '',
      args: [],
    );
  }

  /// `Kazakh`
  String get kk {
    return Intl.message('Kazakh', name: 'kk', desc: '', args: []);
  }

  /// `Turkmen`
  String get tk {
    return Intl.message('Turkmen', name: 'tk', desc: '', args: []);
  }

  /// `Uzbek`
  String get uz {
    return Intl.message('Uzbek', name: 'uz', desc: '', args: []);
  }

  /// `Pick a network`
  String get pickNetwork {
    return Intl.message(
      'Pick a network',
      name: 'pickNetwork',
      desc: '',
      args: [],
    );
  }

  /// `Wi-Fi networks visible around you`
  String get pickNetworkDesc {
    return Intl.message(
      'Wi-Fi networks visible around you',
      name: 'pickNetworkDesc',
      desc: '',
      args: [],
    );
  }

  /// `Looking for nearby Wi-Fi networks…`
  String get pickNetworkScanning {
    return Intl.message(
      'Looking for nearby Wi-Fi networks…',
      name: 'pickNetworkScanning',
      desc: '',
      args: [],
    );
  }

  /// `No Wi-Fi networks found`
  String get pickNetworkEmpty {
    return Intl.message(
      'No Wi-Fi networks found',
      name: 'pickNetworkEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Location permission is required to list nearby Wi-Fi networks`
  String get pickNetworkGrantLocation {
    return Intl.message(
      'Location permission is required to list nearby Wi-Fi networks',
      name: 'pickNetworkGrantLocation',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get pickNetworkRefresh {
    return Intl.message(
      'Refresh',
      name: 'pickNetworkRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Enter manually`
  String get enterManually {
    return Intl.message(
      'Enter manually',
      name: 'enterManually',
      desc: '',
      args: [],
    );
  }

  /// `SSID (Home Wi-Fi) or subnet (192.168.1.0/24)`
  String get networkEntryHint {
    return Intl.message(
      'SSID (Home Wi-Fi) or subnet (192.168.1.0/24)',
      name: 'networkEntryHint',
      desc: '',
      args: [],
    );
  }

  /// `Close connections`
  String get onDemandCloseConnections {
    return Intl.message(
      'Close connections',
      name: 'onDemandCloseConnections',
      desc: '',
      args: [],
    );
  }

  /// `Drop every open connection when the VPN pauses`
  String get closeConnectionsDesc {
    return Intl.message(
      'Drop every open connection when the VPN pauses',
      name: 'closeConnectionsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Trusted networks`
  String get trustedNetworks {
    return Intl.message(
      'Trusted networks',
      name: 'trustedNetworks',
      desc: '',
      args: [],
    );
  }

  /// `The VPN pauses while connected to any of these networks`
  String get trustedNetworksDesc {
    return Intl.message(
      'The VPN pauses while connected to any of these networks',
      name: 'trustedNetworksDesc',
      desc: '',
      args: [],
    );
  }

  /// `Current network is trusted`
  String get trustedNow {
    return Intl.message(
      'Current network is trusted',
      name: 'trustedNow',
      desc: '',
      args: [],
    );
  }

  /// `Current network is not trusted`
  String get notTrustedNow {
    return Intl.message(
      'Current network is not trusted',
      name: 'notTrustedNow',
      desc: '',
      args: [],
    );
  }

  /// `Require SSID and subnet together`
  String get onDemandStrict {
    return Intl.message(
      'Require SSID and subnet together',
      name: 'onDemandStrict',
      desc: '',
      args: [],
    );
  }

  /// `When both kinds of rules exist, pause only if an SSID and a subnet both match`
  String get onDemandStrictDesc {
    return Intl.message(
      'When both kinds of rules exist, pause only if an SSID and a subnet both match',
      name: 'onDemandStrictDesc',
      desc: '',
      args: [],
    );
  }

  /// `Add network`
  String get addNetwork {
    return Intl.message('Add network', name: 'addNetwork', desc: '', args: []);
  }

  /// `Edit network`
  String get editNetwork {
    return Intl.message(
      'Edit network',
      name: 'editNetwork',
      desc: '',
      args: [],
    );
  }

  /// `Could not read Wi-Fi networks. Retry or enter a network manually.`
  String get onDemandScanFailed {
    return Intl.message(
      'Could not read Wi-Fi networks. Retry or enter a network manually.',
      name: 'onDemandScanFailed',
      desc: '',
      args: [],
    );
  }

  /// `An SSID cannot exceed 32 UTF-8 bytes`
  String get invalidSsid {
    return Intl.message(
      'An SSID cannot exceed 32 UTF-8 bytes',
      name: 'invalidSsid',
      desc: '',
      args: [],
    );
  }

  /// `This subnet trusts a wide range of networks`
  String get onDemandBroadNetwork {
    return Intl.message(
      'This subnet trusts a wide range of networks',
      name: 'onDemandBroadNetwork',
      desc: '',
      args: [],
    );
  }

  /// `Resume`
  String get onDemandResume {
    return Intl.message('Resume', name: 'onDemandResume', desc: '', args: []);
  }

  /// `Pause`
  String get onDemandPause {
    return Intl.message('Pause', name: 'onDemandPause', desc: '', args: []);
  }

  /// `Full stop`
  String get onDemandFullStop {
    return Intl.message(
      'Full stop',
      name: 'onDemandFullStop',
      desc: '',
      args: [],
    );
  }

  /// `Remove TUN and close local proxy ports while paused. The app keeps watching the network to resume automatically.`
  String get onDemandFullStopDesc {
    return Intl.message(
      'Remove TUN and close local proxy ports while paused. The app keeps watching the network to resume automatically.',
      name: 'onDemandFullStopDesc',
      desc: '',
      args: [],
    );
  }

  /// `Allow location access to see nearby Wi-Fi networks, or enter a network manually.`
  String get pickNetworkPermissionDesc {
    return Intl.message(
      'Allow location access to see nearby Wi-Fi networks, or enter a network manually.',
      name: 'pickNetworkPermissionDesc',
      desc: '',
      args: [],
    );
  }

  /// `Request as`
  String get subscriptionClientRequestAs {
    return Intl.message(
      'Request as',
      name: 'subscriptionClientRequestAs',
      desc: '',
      args: [],
    );
  }

  /// `Automatically`
  String get subscriptionClientAuto {
    return Intl.message(
      'Automatically',
      name: 'subscriptionClientAuto',
      desc: '',
      args: [],
    );
  }

  /// `ReClash`
  String get subscriptionClientReclash {
    return Intl.message(
      'ReClash',
      name: 'subscriptionClientReclash',
      desc: '',
      args: [],
    );
  }

  /// `Clash Meta`
  String get subscriptionClientClashMeta {
    return Intl.message(
      'Clash Meta',
      name: 'subscriptionClientClashMeta',
      desc: '',
      args: [],
    );
  }

  /// `Clash`
  String get subscriptionClientClash {
    return Intl.message(
      'Clash',
      name: 'subscriptionClientClash',
      desc: '',
      args: [],
    );
  }

  /// `Happ`
  String get subscriptionClientHapp {
    return Intl.message(
      'Happ',
      name: 'subscriptionClientHapp',
      desc: '',
      args: [],
    );
  }

  /// `INCY`
  String get subscriptionClientIncy {
    return Intl.message(
      'INCY',
      name: 'subscriptionClientIncy',
      desc: '',
      args: [],
    );
  }

  /// `sing-box / Karing`
  String get subscriptionClientSingbox {
    return Intl.message(
      'sing-box / Karing',
      name: 'subscriptionClientSingbox',
      desc: '',
      args: [],
    );
  }

  /// `v2rayNG`
  String get subscriptionClientV2rayng {
    return Intl.message(
      'v2rayNG',
      name: 'subscriptionClientV2rayng',
      desc: '',
      args: [],
    );
  }

  /// `Custom User-Agent`
  String get subscriptionClientCustom {
    return Intl.message(
      'Custom User-Agent',
      name: 'subscriptionClientCustom',
      desc: '',
      args: [],
    );
  }

  /// `User-Agent`
  String get subscriptionClientCustomUserAgent {
    return Intl.message(
      'User-Agent',
      name: 'subscriptionClientCustomUserAgent',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid User-Agent without control characters.`
  String get subscriptionClientCustomUserAgentInvalid {
    return Intl.message(
      'Enter a valid User-Agent without control characters.',
      name: 'subscriptionClientCustomUserAgentInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Client selection does not send device identity.`
  String get subscriptionClientDeviceDataHint {
    return Intl.message(
      'Client selection does not send device identity.',
      name: 'subscriptionClientDeviceDataHint',
      desc: '',
      args: [],
    );
  }

  /// `Review subscription import`
  String get subscriptionImportReviewTitle {
    return Intl.message(
      'Review subscription import',
      name: 'subscriptionImportReviewTitle',
      desc: '',
      args: [],
    );
  }

  /// `{count} proxy nodes can be imported from {format}.`
  String subscriptionImportReviewSummary(Object count, Object format) {
    return Intl.message(
      '$count proxy nodes can be imported from $format.',
      name: 'subscriptionImportReviewSummary',
      desc: '',
      args: [count, format],
    );
  }

  /// `No supported proxy nodes can be imported.`
  String get subscriptionImportNoNodes {
    return Intl.message(
      'No supported proxy nodes can be imported.',
      name: 'subscriptionImportNoNodes',
      desc: '',
      args: [],
    );
  }

  /// `The following source sections will not be transferred: {sections}.`
  String subscriptionImportIgnoredSections(Object sections) {
    return Intl.message(
      'The following source sections will not be transferred: $sections.',
      name: 'subscriptionImportIgnoredSections',
      desc: '',
      args: [sections],
    );
  }

  /// `{count} nodes cannot be converted.`
  String subscriptionImportSkippedNodes(Object count) {
    return Intl.message(
      '$count nodes cannot be converted.',
      name: 'subscriptionImportSkippedNodes',
      desc: '',
      args: [count],
    );
  }

  /// `I understand that source settings will be omitted.`
  String get subscriptionImportAcceptSections {
    return Intl.message(
      'I understand that source settings will be omitted.',
      name: 'subscriptionImportAcceptSections',
      desc: '',
      args: [],
    );
  }

  /// `Continue with only the supported nodes.`
  String get subscriptionImportAcceptPartial {
    return Intl.message(
      'Continue with only the supported nodes.',
      name: 'subscriptionImportAcceptPartial',
      desc: '',
      args: [],
    );
  }

  /// `I understand that some source data will not be preserved.`
  String get subscriptionImportAcceptOtherLosses {
    return Intl.message(
      'I understand that some source data will not be preserved.',
      name: 'subscriptionImportAcceptOtherLosses',
      desc: '',
      args: [],
    );
  }

  /// `Accept and import`
  String get subscriptionImportAccept {
    return Intl.message(
      'Accept and import',
      name: 'subscriptionImportAccept',
      desc: '',
      args: [],
    );
  }

  /// `Clash configuration`
  String get subscriptionImportFormatClash {
    return Intl.message(
      'Clash configuration',
      name: 'subscriptionImportFormatClash',
      desc: '',
      args: [],
    );
  }

  /// `proxy links`
  String get subscriptionImportFormatShareLinks {
    return Intl.message(
      'proxy links',
      name: 'subscriptionImportFormatShareLinks',
      desc: '',
      args: [],
    );
  }

  /// `encrypted subscription`
  String get subscriptionImportFormatEncrypted {
    return Intl.message(
      'encrypted subscription',
      name: 'subscriptionImportFormatEncrypted',
      desc: '',
      args: [],
    );
  }

  /// `unknown format`
  String get subscriptionImportFormatUnknown {
    return Intl.message(
      'unknown format',
      name: 'subscriptionImportFormatUnknown',
      desc: '',
      args: [],
    );
  }

  /// `These settings apply to subscription URLs. Share links are imported locally.`
  String get subscriptionClientUrlOnly {
    return Intl.message(
      'These settings apply to subscription URLs. Share links are imported locally.',
      name: 'subscriptionClientUrlOnly',
      desc: '',
      args: [],
    );
  }

  /// `Compatibility`
  String get subscriptionCompatibilityTitle {
    return Intl.message(
      'Compatibility',
      name: 'subscriptionCompatibilityTitle',
      desc: '',
      args: [],
    );
  }

  /// `Check`
  String get subscriptionCompatibilityCheck {
    return Intl.message(
      'Check',
      name: 'subscriptionCompatibilityCheck',
      desc: '',
      args: [],
    );
  }

  /// `Checks the current form without saving or restarting VPN. This checks parsing, not node availability.`
  String get subscriptionCompatibilityCheckHint {
    return Intl.message(
      'Checks the current form without saving or restarting VPN. This checks parsing, not node availability.',
      name: 'subscriptionCompatibilityCheckHint',
      desc: '',
      args: [],
    );
  }

  /// `Received as {client}: {format}, {count} proxy nodes.`
  String subscriptionCompatibilityPrepared(
    String client,
    String format,
    int count,
  ) {
    return Intl.message(
      'Received as $client: $format, $count proxy nodes.',
      name: 'subscriptionCompatibilityPrepared',
      desc: '',
      args: [client, format, count],
    );
  }

  /// `Apply checked result`
  String get subscriptionCompatibilityApplyPrepared {
    return Intl.message(
      'Apply checked result',
      name: 'subscriptionCompatibilityApplyPrepared',
      desc: '',
      args: [],
    );
  }

  /// `Core parsed this result. It has not been saved or applied.`
  String get subscriptionCompatibilityPreparedHint {
    return Intl.message(
      'Core parsed this result. It has not been saved or applied.',
      name: 'subscriptionCompatibilityPreparedHint',
      desc: '',
      args: [],
    );
  }

  /// `The import omits source data. Review the losses before applying.`
  String get subscriptionCompatibilityNeedsReview {
    return Intl.message(
      'The import omits source data. Review the losses before applying.',
      name: 'subscriptionCompatibilityNeedsReview',
      desc: '',
      args: [],
    );
  }

  /// `Last successful client`
  String get subscriptionCompatibilityLastSuccessful {
    return Intl.message(
      'Last successful client',
      name: 'subscriptionCompatibilityLastSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Use this client`
  String get subscriptionCompatibilityPinSuccessful {
    return Intl.message(
      'Use this client',
      name: 'subscriptionCompatibilityPinSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Ask about import losses again`
  String get subscriptionCompatibilityForgetConsent {
    return Intl.message(
      'Ask about import losses again',
      name: 'subscriptionCompatibilityForgetConsent',
      desc: '',
      args: [],
    );
  }

  /// `Could not obtain a compatible subscription. The existing configuration was not changed.`
  String get subscriptionCompatibilityCheckFailed {
    return Intl.message(
      'Could not obtain a compatible subscription. The existing configuration was not changed.',
      name: 'subscriptionCompatibilityCheckFailed',
      desc: '',
      args: [],
    );
  }

  /// `The subscription check timed out.`
  String get subscriptionCompatibilityTimeout {
    return Intl.message(
      'The subscription check timed out.',
      name: 'subscriptionCompatibilityTimeout',
      desc: '',
      args: [],
    );
  }

  /// `The server rejected authorization. Client negotiation stopped.`
  String get subscriptionCompatibilityAuthorization {
    return Intl.message(
      'The server rejected authorization. Client negotiation stopped.',
      name: 'subscriptionCompatibilityAuthorization',
      desc: '',
      args: [],
    );
  }

  /// `The server limited requests. Try again later.`
  String get subscriptionCompatibilityRateLimited {
    return Intl.message(
      'The server limited requests. Try again later.',
      name: 'subscriptionCompatibilityRateLimited',
      desc: '',
      args: [],
    );
  }

  /// `Connection failed. Client negotiation stopped.`
  String get subscriptionCompatibilityTransport {
    return Intl.message(
      'Connection failed. Client negotiation stopped.',
      name: 'subscriptionCompatibilityTransport',
      desc: '',
      args: [],
    );
  }

  /// `The form or profile changed. Check the subscription again.`
  String get subscriptionCompatibilitySuperseded {
    return Intl.message(
      'The form or profile changed. Check the subscription again.',
      name: 'subscriptionCompatibilitySuperseded',
      desc: '',
      args: [],
    );
  }

  /// `Enter the AGE key to check this subscription.`
  String get subscriptionCompatibilityAgeKey {
    return Intl.message(
      'Enter the AGE key to check this subscription.',
      name: 'subscriptionCompatibilityAgeKey',
      desc: '',
      args: [],
    );
  }

  /// `Remember this consent for this subscription`
  String get subscriptionImportRememberConsent {
    return Intl.message(
      'Remember this consent for this subscription',
      name: 'subscriptionImportRememberConsent',
      desc: '',
      args: [],
    );
  }

  /// `Applies only to this source, format and the accepted loss types. New losses require consent again.`
  String get subscriptionImportRememberConsentHint {
    return Intl.message(
      'Applies only to this source, format and the accepted loss types. New losses require consent again.',
      name: 'subscriptionImportRememberConsentHint',
      desc: '',
      args: [],
    );
  }

  /// `Show subscription URL`
  String get subscriptionCompatibilityShowUrl {
    return Intl.message(
      'Show subscription URL',
      name: 'subscriptionCompatibilityShowUrl',
      desc: '',
      args: [],
    );
  }

  /// `Hide subscription URL`
  String get subscriptionCompatibilityHideUrl {
    return Intl.message(
      'Hide subscription URL',
      name: 'subscriptionCompatibilityHideUrl',
      desc: '',
      args: [],
    );
  }

  /// `Send HWID`
  String get subscriptionIdentityTitle {
    return Intl.message(
      'Send HWID',
      name: 'subscriptionIdentityTitle',
      desc: '',
      args: [],
    );
  }

  /// `A stable pseudonymous device ID will be sent to this subscription origin. It is not hardware attestation and consent stays on this device.`
  String get subscriptionIdentityDisclosure {
    return Intl.message(
      'A stable pseudonymous device ID will be sent to this subscription origin. It is not hardware attestation and consent stays on this device.',
      name: 'subscriptionIdentityDisclosure',
      desc: '',
      args: [],
    );
  }

  /// `Also send operating system and device model`
  String get subscriptionIdentityDetails {
    return Intl.message(
      'Also send operating system and device model',
      name: 'subscriptionIdentityDetails',
      desc: '',
      args: [],
    );
  }

  /// `This also sends the operating system version and device model with the identifier.`
  String get subscriptionIdentityDetailsDisclosure {
    return Intl.message(
      'This also sends the operating system version and device model with the identifier.',
      name: 'subscriptionIdentityDetailsDisclosure',
      desc: '',
      args: [],
    );
  }

  /// `Subscription identity`
  String get subscriptionIdentitySettingsTitle {
    return Intl.message(
      'Subscription identity',
      name: 'subscriptionIdentitySettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Use global`
  String get subscriptionIdentityUseGlobal {
    return Intl.message(
      'Use global',
      name: 'subscriptionIdentityUseGlobal',
      desc: '',
      args: [],
    );
  }

  /// `Subscription`
  String get subscriptionProvider {
    return Intl.message(
      'Subscription',
      name: 'subscriptionProvider',
      desc: '',
      args: [],
    );
  }

  /// `Website`
  String get subscriptionProviderWebsite {
    return Intl.message(
      'Website',
      name: 'subscriptionProviderWebsite',
      desc: '',
      args: [],
    );
  }

  /// `Support`
  String get subscriptionProviderSupport {
    return Intl.message(
      'Support',
      name: 'subscriptionProviderSupport',
      desc: '',
      args: [],
    );
  }

  /// `Buy plan`
  String get subscriptionProviderBuyPlan {
    return Intl.message(
      'Buy plan',
      name: 'subscriptionProviderBuyPlan',
      desc: '',
      args: [],
    );
  }

  /// `Buy traffic`
  String get subscriptionProviderBuyTraffic {
    return Intl.message(
      'Buy traffic',
      name: 'subscriptionProviderBuyTraffic',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get subscriptionProviderAccount {
    return Intl.message(
      'Account',
      name: 'subscriptionProviderAccount',
      desc: '',
      args: [],
    );
  }

  /// `Logo URL`
  String get subscriptionProviderLogo {
    return Intl.message(
      'Logo URL',
      name: 'subscriptionProviderLogo',
      desc: '',
      args: [],
    );
  }

  /// `Use provider update interval`
  String get subscriptionUseProviderInterval {
    return Intl.message(
      'Use provider update interval',
      name: 'subscriptionUseProviderInterval',
      desc: '',
      args: [],
    );
  }

  /// `No device slots are available for this subscription. Remove a device from the provider account and try again.`
  String get subscriptionDeviceLimit {
    return Intl.message(
      'No device slots are available for this subscription. Remove a device from the provider account and try again.',
      name: 'subscriptionDeviceLimit',
      desc: '',
      args: [],
    );
  }

  /// `This subscription requires device registration. Follow the provider's instructions.`
  String get subscriptionDeviceRequired {
    return Intl.message(
      'This subscription requires device registration. Follow the provider\'s instructions.',
      name: 'subscriptionDeviceRequired',
      desc: '',
      args: [],
    );
  }

  /// `Added: {added}; skipped: {skipped}; failed: {failed}.`
  String profileBatchResult(int added, int skipped, int failed) {
    return Intl.message(
      'Added: $added; skipped: $skipped; failed: $failed.',
      name: 'profileBatchResult',
      desc: '',
      args: [added, skipped, failed],
    );
  }

  /// `Many subscriptions will stop working if HWID sending is turned off.`
  String get subscriptionIdentityRegionWarning {
    return Intl.message(
      'Many subscriptions will stop working if HWID sending is turned off.',
      name: 'subscriptionIdentityRegionWarning',
      desc: '',
      args: [],
    );
  }

  /// `Prevent duplicate subscriptions`
  String get preventDuplicateProfiles {
    return Intl.message(
      'Prevent duplicate subscriptions',
      name: 'preventDuplicateProfiles',
      desc: '',
      args: [],
    );
  }

  /// `Refuse a subscription link that an existing profile already uses`
  String get preventDuplicateProfilesDesc {
    return Intl.message(
      'Refuse a subscription link that an existing profile already uses',
      name: 'preventDuplicateProfilesDesc',
      desc: '',
      args: [],
    );
  }

  /// `A profile with this subscription URL already exists`
  String get profileImportDuplicate {
    return Intl.message(
      'A profile with this subscription URL already exists',
      name: 'profileImportDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Auto routing`
  String get rcxTitle {
    return Intl.message('Auto routing', name: 'rcxTitle', desc: '', args: []);
  }

  /// `Make this group smart`
  String get rcxMakeSmart {
    return Intl.message(
      'Make this group smart',
      name: 'rcxMakeSmart',
      desc: '',
      args: [],
    );
  }

  /// `ReClash keeps a working server selected in this group and switches when it fails. Checks run only while you use the network.`
  String get rcxMakeSmartHint {
    return Intl.message(
      'ReClash keeps a working server selected in this group and switches when it fails. Checks run only while you use the network.',
      name: 'rcxMakeSmartHint',
      desc: '',
      args: [],
    );
  }

  /// `Turn off auto routing`
  String get rcxTurnOff {
    return Intl.message(
      'Turn off auto routing',
      name: 'rcxTurnOff',
      desc: '',
      args: [],
    );
  }

  /// `Change server`
  String get rcxChangeServer {
    return Intl.message(
      'Change server',
      name: 'rcxChangeServer',
      desc: '',
      args: [],
    );
  }

  /// `Back to auto`
  String get rcxBackToAuto {
    return Intl.message(
      'Back to auto',
      name: 'rcxBackToAuto',
      desc: '',
      args: [],
    );
  }

  /// `Control`
  String get rcxControl {
    return Intl.message('Control', name: 'rcxControl', desc: '', args: []);
  }

  /// `Auto`
  String get rcxModeAuto {
    return Intl.message('Auto', name: 'rcxModeAuto', desc: '', args: []);
  }

  /// `Chooses and switches servers by the profile`
  String get rcxModeAutoHint {
    return Intl.message(
      'Chooses and switches servers by the profile',
      name: 'rcxModeAutoHint',
      desc: '',
      args: [],
    );
  }

  /// `Manual`
  String get rcxModeManual {
    return Intl.message('Manual', name: 'rcxModeManual', desc: '', args: []);
  }

  /// `You choose; auto routing never switches`
  String get rcxModeManualHint {
    return Intl.message(
      'You choose; auto routing never switches',
      name: 'rcxModeManualHint',
      desc: '',
      args: [],
    );
  }

  /// `Pinned: {node}`
  String rcxPinned(String node) {
    return Intl.message(
      'Pinned: $node',
      name: 'rcxPinned',
      desc: '',
      args: [node],
    );
  }

  /// `Pinned`
  String get rcxPinnedLabel {
    return Intl.message('Pinned', name: 'rcxPinnedLabel', desc: '', args: []);
  }

  /// `Left only when it fails, returned to when it recovers`
  String get rcxPinnedHint {
    return Intl.message(
      'Left only when it fails, returned to when it recovers',
      name: 'rcxPinnedHint',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get rcxProfile {
    return Intl.message('Profile', name: 'rcxProfile', desc: '', args: []);
  }

  /// `Built-in`
  String get rcxSourceBuiltin {
    return Intl.message(
      'Built-in',
      name: 'rcxSourceBuiltin',
      desc: '',
      args: [],
    );
  }

  /// `From provider`
  String get rcxSourceProvider {
    return Intl.message(
      'From provider',
      name: 'rcxSourceProvider',
      desc: '',
      args: [],
    );
  }

  /// `Mine`
  String get rcxSourceUser {
    return Intl.message('Mine', name: 'rcxSourceUser', desc: '', args: []);
  }

  /// `Simple`
  String get rcxLevelSimple {
    return Intl.message('Simple', name: 'rcxLevelSimple', desc: '', args: []);
  }

  /// `Advanced`
  String get rcxLevelAdvanced {
    return Intl.message(
      'Advanced',
      name: 'rcxLevelAdvanced',
      desc: '',
      args: [],
    );
  }

  /// `Servers`
  String get rcxServers {
    return Intl.message('Servers', name: 'rcxServers', desc: '', args: []);
  }

  /// `Name pattern`
  String get rcxServersPattern {
    return Intl.message(
      'Name pattern',
      name: 'rcxServersPattern',
      desc: '',
      args: [],
    );
  }

  /// `{count} of {total} match`
  String rcxServersMatch(int count, int total) {
    return Intl.message(
      '$count of $total match',
      name: 'rcxServersMatch',
      desc: '',
      args: [count, total],
    );
  }

  /// `The pattern is not a valid regular expression`
  String get rcxPatternInvalid {
    return Intl.message(
      'The pattern is not a valid regular expression',
      name: 'rcxPatternInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Switching`
  String get rcxSwitching {
    return Intl.message('Switching', name: 'rcxSwitching', desc: '', args: []);
  }

  /// `Rarely`
  String get rcxFeelCalm {
    return Intl.message('Rarely', name: 'rcxFeelCalm', desc: '', args: []);
  }

  /// `Often`
  String get rcxFeelEager {
    return Intl.message('Often', name: 'rcxFeelEager', desc: '', args: []);
  }

  /// `Balanced`
  String get rcxBalanced {
    return Intl.message('Balanced', name: 'rcxBalanced', desc: '', args: []);
  }

  /// `Checks`
  String get rcxChecks {
    return Intl.message('Checks', name: 'rcxChecks', desc: '', args: []);
  }

  /// `Economical`
  String get rcxEnergyEco {
    return Intl.message('Economical', name: 'rcxEnergyEco', desc: '', args: []);
  }

  /// `Precise`
  String get rcxEnergyPrecise {
    return Intl.message(
      'Precise',
      name: 'rcxEnergyPrecise',
      desc: '',
      args: [],
    );
  }

  /// `Checks today: {requests} · {used} of {cap}`
  String rcxEnergyToday(int requests, String used, String cap) {
    return Intl.message(
      'Checks today: $requests · $used of $cap',
      name: 'rcxEnergyToday',
      desc: '',
      args: [requests, used, cap],
    );
  }

  /// `Why this server`
  String get rcxWhy {
    return Intl.message('Why this server', name: 'rcxWhy', desc: '', args: []);
  }

  /// `History`
  String get rcxHistory {
    return Intl.message('History', name: 'rcxHistory', desc: '', args: []);
  }

  /// `Working`
  String get rcxHealthAlive {
    return Intl.message('Working', name: 'rcxHealthAlive', desc: '', args: []);
  }

  /// `Worked before`
  String get rcxHealthStale {
    return Intl.message(
      'Worked before',
      name: 'rcxHealthStale',
      desc: '',
      args: [],
    );
  }

  /// `Not checked`
  String get rcxHealthUnknown {
    return Intl.message(
      'Not checked',
      name: 'rcxHealthUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Not working`
  String get rcxHealthDead {
    return Intl.message(
      'Not working',
      name: 'rcxHealthDead',
      desc: '',
      args: [],
    );
  }

  /// `Controlled manually`
  String get rcxReasonManual {
    return Intl.message(
      'Controlled manually',
      name: 'rcxReasonManual',
      desc: '',
      args: [],
    );
  }

  /// `Holding the pinned server`
  String get rcxReasonHoldPinned {
    return Intl.message(
      'Holding the pinned server',
      name: 'rcxReasonHoldPinned',
      desc: '',
      args: [],
    );
  }

  /// `Switched to the pinned server {node}`
  String rcxReasonSwitchPinned(String node) {
    return Intl.message(
      'Switched to the pinned server $node',
      name: 'rcxReasonSwitchPinned',
      desc: '',
      args: [node],
    );
  }

  /// `No working server in the pool; holding the current one`
  String get rcxReasonStranded {
    return Intl.message(
      'No working server in the pool; holding the current one',
      name: 'rcxReasonStranded',
      desc: '',
      args: [],
    );
  }

  /// `No working server; fell back to {node}`
  String rcxReasonSwitchStranded(String node) {
    return Intl.message(
      'No working server; fell back to $node',
      name: 'rcxReasonSwitchStranded',
      desc: '',
      args: [node],
    );
  }

  /// `Selected the best available server`
  String get rcxReasonInitial {
    return Intl.message(
      'Selected the best available server',
      name: 'rcxReasonInitial',
      desc: '',
      args: [],
    );
  }

  /// `Changed server; {from} is skipped for 15 minutes`
  String rcxReasonChangeServer(String from) {
    return Intl.message(
      'Changed server; $from is skipped for 15 minutes',
      name: 'rcxReasonChangeServer',
      desc: '',
      args: [from],
    );
  }

  /// `{from} stopped working; switched to the best standby`
  String rcxReasonFailover(String from) {
    return Intl.message(
      '$from stopped working; switched to the best standby',
      name: 'rcxReasonFailover',
      desc: '',
      args: [from],
    );
  }

  /// `{from} is no longer in the pool`
  String rcxReasonOutOfPool(String from) {
    return Intl.message(
      '$from is no longer in the pool',
      name: 'rcxReasonOutOfPool',
      desc: '',
      args: [from],
    );
  }

  /// `No other working server to change to`
  String get rcxReasonNoAlternative {
    return Intl.message(
      'No other working server to change to',
      name: 'rcxReasonNoAlternative',
      desc: '',
      args: [],
    );
  }

  /// `This is the best server`
  String get rcxReasonBest {
    return Intl.message(
      'This is the best server',
      name: 'rcxReasonBest',
      desc: '',
      args: [],
    );
  }

  /// `Checking a better candidate`
  String get rcxReasonChecking {
    return Intl.message(
      'Checking a better candidate',
      name: 'rcxReasonChecking',
      desc: '',
      args: [],
    );
  }

  /// `Working; kept until it fails`
  String get rcxReasonWorking {
    return Intl.message(
      'Working; kept until it fails',
      name: 'rcxReasonWorking',
      desc: '',
      args: [],
    );
  }

  /// `Switched recently; holding before the next change`
  String get rcxReasonDwell {
    return Intl.message(
      'Switched recently; holding before the next change',
      name: 'rcxReasonDwell',
      desc: '',
      args: [],
    );
  }

  /// `Switch limit reached ({limit} per hour)`
  String rcxReasonFlapLimit(int limit) {
    return Intl.message(
      'Switch limit reached ($limit per hour)',
      name: 'rcxReasonFlapLimit',
      desc: '',
      args: [limit],
    );
  }

  /// `A faster server needs another measurement`
  String get rcxReasonConfirming {
    return Intl.message(
      'A faster server needs another measurement',
      name: 'rcxReasonConfirming',
      desc: '',
      args: [],
    );
  }

  /// `Moved to a server in “{tier}”`
  String rcxReasonBetterTier(String tier) {
    return Intl.message(
      'Moved to a server in “$tier”',
      name: 'rcxReasonBetterTier',
      desc: '',
      args: [tier],
    );
  }

  /// `Switched from {from}: {gain} ms faster`
  String rcxReasonFaster(String from, int gain) {
    return Intl.message(
      'Switched from $from: $gain ms faster',
      name: 'rcxReasonFaster',
      desc: '',
      args: [from, gain],
    );
  }

  /// `Could not select the server`
  String get rcxReasonSelectFailed {
    return Intl.message(
      'Could not select the server',
      name: 'rcxReasonSelectFailed',
      desc: '',
      args: [],
    );
  }

  /// `Will switch to {node} once a check confirms it`
  String rcxUntilCheck(String node) {
    return Intl.message(
      'Will switch to $node once a check confirms it',
      name: 'rcxUntilCheck',
      desc: '',
      args: [node],
    );
  }

  /// `May switch to {node} in {minutes} min`
  String rcxUntilDwell(String node, int minutes) {
    return Intl.message(
      'May switch to $node in $minutes min',
      name: 'rcxUntilDwell',
      desc: '',
      args: [node, minutes],
    );
  }

  /// `Will switch to {node} if it stays {gain} ms faster`
  String rcxUntilConfirm(String node, int gain) {
    return Intl.message(
      'Will switch to $node if it stays $gain ms faster',
      name: 'rcxUntilConfirm',
      desc: '',
      args: [node, gain],
    );
  }

  /// `Not in the pool`
  String get rcxExcludedNoMatch {
    return Intl.message(
      'Not in the pool',
      name: 'rcxExcludedNoMatch',
      desc: '',
      args: [],
    );
  }

  /// `Excluded by the profile`
  String get rcxExcludedByProfile {
    return Intl.message(
      'Excluded by the profile',
      name: 'rcxExcludedByProfile',
      desc: '',
      args: [],
    );
  }

  /// `Not a server`
  String get rcxExcludedUnroutable {
    return Intl.message(
      'Not a server',
      name: 'rcxExcludedUnroutable',
      desc: '',
      args: [],
    );
  }

  /// `Skipped after “Change server”`
  String get rcxExcludedCooldown {
    return Intl.message(
      'Skipped after “Change server”',
      name: 'rcxExcludedCooldown',
      desc: '',
      args: [],
    );
  }

  /// `Matches no preference`
  String get rcxExcludedNoTier {
    return Intl.message(
      'Matches no preference',
      name: 'rcxExcludedNoTier',
      desc: '',
      args: [],
    );
  }

  /// `Profile {profile} was not found; the default is used`
  String rcxProblemProfileMissing(String profile) {
    return Intl.message(
      'Profile $profile was not found; the default is used',
      name: 'rcxProblemProfileMissing',
      desc: '',
      args: [profile],
    );
  }

  /// `Profile error: {error}`
  String rcxProblemProfileInvalid(String error) {
    return Intl.message(
      'Profile error: $error',
      name: 'rcxProblemProfileInvalid',
      desc: '',
      args: [error],
    );
  }

  /// `This group is not a selector in the current config`
  String get rcxProblemGroupUnavailable {
    return Intl.message(
      'This group is not a selector in the current config',
      name: 'rcxProblemGroupUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `The group has no servers`
  String get rcxProblemGroupEmpty {
    return Intl.message(
      'The group has no servers',
      name: 'rcxProblemGroupEmpty',
      desc: '',
      args: [],
    );
  }

  /// `The network looks down; no server is blamed`
  String get rcxReasonNetworkSuspect {
    return Intl.message(
      'The network looks down; no server is blamed',
      name: 'rcxReasonNetworkSuspect',
      desc: '',
      args: [],
    );
  }

  /// `Network changed`
  String get rcxReasonNetworkChanged {
    return Intl.message(
      'Network changed',
      name: 'rcxReasonNetworkChanged',
      desc: '',
      args: [],
    );
  }

  /// `{node} stopped working`
  String rcxJournalFailure(String node) {
    return Intl.message(
      '$node stopped working',
      name: 'rcxJournalFailure',
      desc: '',
      args: [node],
    );
  }

  /// `Routing state could not be saved: {error}`
  String rcxProblemStoreFailed(String error) {
    return Intl.message(
      'Routing state could not be saved: $error',
      name: 'rcxProblemStoreFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Change to`
  String get rcxChangeTo {
    return Intl.message('Change to', name: 'rcxChangeTo', desc: '', args: []);
  }

  /// `Any`
  String get rcxAnyServer {
    return Intl.message('Any', name: 'rcxAnyServer', desc: '', args: []);
  }

  /// `Add a pattern`
  String get rcxAddPool {
    return Intl.message(
      'Add a pattern',
      name: 'rcxAddPool',
      desc: '',
      args: [],
    );
  }

  /// `Network: {kind}`
  String rcxNetwork(String kind) {
    return Intl.message(
      'Network: $kind',
      name: 'rcxNetwork',
      desc: '',
      args: [kind],
    );
  }

  /// `open internet`
  String get rcxKindOpen {
    return Intl.message(
      'open internet',
      name: 'rcxKindOpen',
      desc: '',
      args: [],
    );
  }

  /// `whitelists only`
  String get rcxKindWhitelist {
    return Intl.message(
      'whitelists only',
      name: 'rcxKindWhitelist',
      desc: '',
      args: [],
    );
  }

  /// `sign-in page`
  String get rcxKindPortal {
    return Intl.message(
      'sign-in page',
      name: 'rcxKindPortal',
      desc: '',
      args: [],
    );
  }

  /// `checking`
  String get rcxKindChecking {
    return Intl.message(
      'checking',
      name: 'rcxKindChecking',
      desc: '',
      args: [],
    );
  }

  /// `Paused while the network is “{kind}”: nothing is checked or switched`
  String rcxReasonPaused(String kind) {
    return Intl.message(
      'Paused while the network is “$kind”: nothing is checked or switched',
      name: 'rcxReasonPaused',
      desc: '',
      args: [kind],
    );
  }

  /// `Not checked yet`
  String get rcxExcludedPending {
    return Intl.message(
      'Not checked yet',
      name: 'rcxExcludedPending',
      desc: '',
      args: [],
    );
  }

  /// `may reach “{tier}” after a check`
  String rcxPendingTier(String tier) {
    return Intl.message(
      'may reach “$tier” after a check',
      name: 'rcxPendingTier',
      desc: '',
      args: [tier],
    );
  }

  /// `opens blocked`
  String get rcxCheckOpen {
    return Intl.message(
      'opens blocked',
      name: 'rcxCheckOpen',
      desc: '',
      args: [],
    );
  }

  /// `exit {country}`
  String rcxExit(String country) {
    return Intl.message(
      'exit $country',
      name: 'rcxExit',
      desc: '',
      args: [country],
    );
  }

  /// `Direct sites now go through this group`
  String get rcxReasonSplitOn {
    return Intl.message(
      'Direct sites now go through this group',
      name: 'rcxReasonSplitOn',
      desc: '',
      args: [],
    );
  }

  /// `Direct sites go direct again`
  String get rcxReasonSplitOff {
    return Intl.message(
      'Direct sites go direct again',
      name: 'rcxReasonSplitOff',
      desc: '',
      args: [],
    );
  }

  /// `Direct sites through this group`
  String get rcxDirectSplit {
    return Intl.message(
      'Direct sites through this group',
      name: 'rcxDirectSplit',
      desc: '',
      args: [],
    );
  }

  /// `When sites your rules send direct stop opening, they go through this group. Local addresses always stay direct.`
  String get rcxDirectSplitHint {
    return Intl.message(
      'When sites your rules send direct stop opening, they go through this group. Local addresses always stay direct.',
      name: 'rcxDirectSplitHint',
      desc: '',
      args: [],
    );
  }

  /// `On now`
  String get rcxDirectSplitActive {
    return Intl.message(
      'On now',
      name: 'rcxDirectSplitActive',
      desc: '',
      args: [],
    );
  }

  /// `Ready: direct sites still open`
  String get rcxDirectSplitStandby {
    return Intl.message(
      'Ready: direct sites still open',
      name: 'rcxDirectSplitStandby',
      desc: '',
      args: [],
    );
  }

  /// `Add tag`
  String get rcxAddTag {
    return Intl.message(
      'Add tag',
      name: 'rcxAddTag',
      desc: 'Row: add a named server filter (tag) to a routing profile',
      args: [],
    );
  }

  /// `Add tier`
  String get rcxAddTier {
    return Intl.message(
      'Add tier',
      name: 'rcxAddTier',
      desc: 'Row/title: add a preference tier to a routing profile',
      args: [],
    );
  }

  /// `Advanced`
  String get rcxAdvanced {
    return Intl.message(
      'Advanced',
      name: 'rcxAdvanced',
      desc: 'Section title for advanced profile parts edited as YAML',
      args: [],
    );
  }

  /// `These parts are edited as YAML.`
  String get rcxAdvancedHint {
    return Intl.message(
      'These parts are edited as YAML.',
      name: 'rcxAdvancedHint',
      desc: 'Footer under the advanced section',
      args: [],
    );
  }

  /// `Based on`
  String get rcxBasedOn {
    return Intl.message(
      'Based on',
      name: 'rcxBasedOn',
      desc: 'Row: the profile this one extends',
      args: [],
    );
  }

  /// `Behaviour`
  String get rcxBehaviour {
    return Intl.message(
      'Behaviour',
      name: 'rcxBehaviour',
      desc: 'Section title: switching, checks, no-candidate behaviour',
      args: [],
    );
  }

  /// `Bring changes over`
  String get rcxBringChanges {
    return Intl.message(
      'Bring changes over',
      name: 'rcxBringChanges',
      desc: 'Action: merge changes of the source profile into the user\'s copy',
      args: [],
    );
  }

  /// `Your own edits stay as they are`
  String get rcxBringChangesHint {
    return Intl.message(
      'Your own edits stay as they are',
      name: 'rcxBringChangesHint',
      desc: 'Subtitle of bring changes over',
      args: [],
    );
  }

  /// `Would pick {pick} instead of {now}`
  String rcxCheckDifferent(String pick, String now) {
    return Intl.message(
      'Would pick $pick instead of $now',
      name: 'rcxCheckDifferent',
      desc: 'Simulation result',
      args: [pick, now],
    );
  }

  /// `Would find no server`
  String get rcxCheckNone {
    return Intl.message(
      'Would find no server',
      name: 'rcxCheckNone',
      desc: 'Simulation result',
      args: [],
    );
  }

  /// `Check on {group}`
  String rcxCheckOn(String group) {
    return Intl.message(
      'Check on $group',
      name: 'rcxCheckOn',
      desc: 'Section title: simulation of the profile on a proxy group',
      args: [group],
    );
  }

  /// `Would keep {pick}`
  String rcxCheckSame(String pick) {
    return Intl.message(
      'Would keep $pick',
      name: 'rcxCheckSame',
      desc: 'Simulation result',
      args: [pick],
    );
  }

  /// `Availability checks`
  String get rcxChecksDeclared {
    return Intl.message(
      'Availability checks',
      name: 'rcxChecksDeclared',
      desc: 'Row title: checks declared by the profile',
      args: [],
    );
  }

  /// `Add condition`
  String get rcxCondAdd {
    return Intl.message(
      'Add condition',
      name: 'rcxCondAdd',
      desc: 'Row/title',
      args: [],
    );
  }

  /// `All conditions`
  String get rcxCondAll {
    return Intl.message(
      'All conditions',
      name: 'rcxCondAll',
      desc: 'Join choice: all clauses must hold',
      args: [],
    );
  }

  /// `Always`
  String get rcxCondAlways {
    return Intl.message(
      'Always',
      name: 'rcxCondAlways',
      desc: 'Empty network condition means always',
      args: [],
    );
  }

  /// `Any condition`
  String get rcxCondAny {
    return Intl.message(
      'Any condition',
      name: 'rcxCondAny',
      desc: 'Join choice: one clause is enough',
      args: [],
    );
  }

  /// `Any server`
  String get rcxCondAnyServer {
    return Intl.message(
      'Any server',
      name: 'rcxCondAnyServer',
      desc: 'Empty server condition means any server',
      args: [],
    );
  }

  /// `Field`
  String get rcxCondField {
    return Intl.message(
      'Field',
      name: 'rcxCondField',
      desc: 'Row: which attribute a clause tests',
      args: [],
    );
  }

  /// `Ignore case`
  String get rcxCondIgnoreCase {
    return Intl.message(
      'Ignore case',
      name: 'rcxCondIgnoreCase',
      desc: 'Switch for pattern matching',
      args: [],
    );
  }

  /// `Match`
  String get rcxCondMatch {
    return Intl.message(
      'Match',
      name: 'rcxCondMatch',
      desc: 'Section title: how clauses combine',
      args: [],
    );
  }

  /// `None declared`
  String get rcxCondNoNames {
    return Intl.message(
      'None declared',
      name: 'rcxCondNoNames',
      desc: 'Value when the profile declares no tags/checks/diagnostics',
      args: [],
    );
  }

  /// `not`
  String get rcxCondNotPrefix {
    return Intl.message(
      'not',
      name: 'rcxCondNotPrefix',
      desc: 'Lowercase word placed before a negated clause, e.g. \'not Exit country is RU\'',
      args: [],
    );
  }

  /// `Operator`
  String get rcxCondOp {
    return Intl.message(
      'Operator',
      name: 'rcxCondOp',
      desc: 'Row: comparison operator',
      args: [],
    );
  }

  /// `Pattern`
  String get rcxCondPattern {
    return Intl.message(
      'Pattern',
      name: 'rcxCondPattern',
      desc: 'Row: regular expression',
      args: [],
    );
  }

  /// `As text`
  String get rcxCondText {
    return Intl.message(
      'As text',
      name: 'rcxCondText',
      desc: 'Section title: the condition in the profile language',
      args: [],
    );
  }

  /// `This condition nests groups, so it is edited as text.`
  String get rcxCondTooComplex {
    return Intl.message(
      'This condition nests groups, so it is edited as text.',
      name: 'rcxCondTooComplex',
      desc: 'Shown instead of the clause list',
      args: [],
    );
  }

  /// `Value`
  String get rcxCondValue {
    return Intl.message('Value', name: 'rcxCondValue', desc: 'Row', args: []);
  }

  /// `Values, comma-separated`
  String get rcxCondValues {
    return Intl.message(
      'Values, comma-separated',
      name: 'rcxCondValues',
      desc: 'Row',
      args: [],
    );
  }

  /// `Allow`
  String get rcxConsentAllow {
    return Intl.message(
      'Allow',
      name: 'rcxConsentAllow',
      desc: 'Button: allow the profile to contact the listed hosts',
      args: [],
    );
  }

  /// `“{profile}” wants to check these sites`
  String rcxConsentAsk(String profile) {
    return Intl.message(
      '“$profile” wants to check these sites',
      name: 'rcxConsentAsk',
      desc: 'Consent prompt',
      args: [profile],
    );
  }

  /// `Until you allow it, the group runs the Simple profile. The sites are contacted only through your servers or to test the network.`
  String get rcxConsentHint {
    return Intl.message(
      'Until you allow it, the group runs the Simple profile. The sites are contacted only through your servers or to test the network.',
      name: 'rcxConsentHint',
      desc: 'Footer of consent section',
      args: [],
    );
  }

  /// `Permission needed`
  String get rcxConsentTitle {
    return Intl.message(
      'Permission needed',
      name: 'rcxConsentTitle',
      desc: 'Section title',
      args: [],
    );
  }

  /// `Sites it contacts`
  String get rcxContacts {
    return Intl.message(
      'Sites it contacts',
      name: 'rcxContacts',
      desc: 'Section title: hosts the profile makes the app contact',
      args: [],
    );
  }

  /// `Third-party sites belong neither to your provider nor to the built-in profiles.`
  String get rcxContactsHint {
    return Intl.message(
      'Third-party sites belong neither to your provider nor to the built-in profiles.',
      name: 'rcxContactsHint',
      desc: 'Footer',
      args: [],
    );
  }

  /// `Delete “{profile}”?`
  String rcxDeleteProfile(String profile) {
    return Intl.message(
      'Delete “$profile”?',
      name: 'rcxDeleteProfile',
      desc: 'Confirmation',
      args: [profile],
    );
  }

  /// `Duplicate and edit`
  String get rcxDuplicate {
    return Intl.message(
      'Duplicate and edit',
      name: 'rcxDuplicate',
      desc: 'Menu item',
      args: [],
    );
  }

  /// `Exit-country check`
  String get rcxExitCheck {
    return Intl.message(
      'Exit-country check',
      name: 'rcxExitCheck',
      desc: 'Row title',
      args: [],
    );
  }

  /// `Export`
  String get rcxExport {
    return Intl.message(
      'Export',
      name: 'rcxExport',
      desc: 'Menu item / sheet title',
      args: [],
    );
  }

  /// `Working`
  String get rcxFieldAlive {
    return Intl.message(
      'Working',
      name: 'rcxFieldAlive',
      desc: 'Condition field: server is alive',
      args: [],
    );
  }

  /// `In use`
  String get rcxFieldCurrent {
    return Intl.message(
      'In use',
      name: 'rcxFieldCurrent',
      desc: 'Condition field: the server in use now',
      args: [],
    );
  }

  /// `Not working`
  String get rcxFieldDead {
    return Intl.message(
      'Not working',
      name: 'rcxFieldDead',
      desc: 'Condition field',
      args: [],
    );
  }

  /// `Network diagnostic`
  String get rcxFieldDiag {
    return Intl.message(
      'Network diagnostic',
      name: 'rcxFieldDiag',
      desc: 'Condition field',
      args: [],
    );
  }

  /// `Entry country`
  String get rcxFieldEntry {
    return Intl.message(
      'Entry country',
      name: 'rcxFieldEntry',
      desc: 'Condition field: country of the server address',
      args: [],
    );
  }

  /// `Exit country`
  String get rcxFieldExit {
    return Intl.message(
      'Exit country',
      name: 'rcxFieldExit',
      desc: 'Condition field: verified country traffic exits in',
      args: [],
    );
  }

  /// `Fails check`
  String get rcxFieldFails {
    return Intl.message(
      'Fails check',
      name: 'rcxFieldFails',
      desc: 'Condition field',
      args: [],
    );
  }

  /// `Network kind`
  String get rcxFieldKind {
    return Intl.message(
      'Network kind',
      name: 'rcxFieldKind',
      desc: 'Condition field',
      args: [],
    );
  }

  /// `Latency, ms`
  String get rcxFieldLatency {
    return Intl.message(
      'Latency, ms',
      name: 'rcxFieldLatency',
      desc: 'Condition field',
      args: [],
    );
  }

  /// `Measured`
  String get rcxFieldMeasured {
    return Intl.message(
      'Measured',
      name: 'rcxFieldMeasured',
      desc: 'Condition field: has a latency sample',
      args: [],
    );
  }

  /// `Metered network`
  String get rcxFieldMetered {
    return Intl.message(
      'Metered network',
      name: 'rcxFieldMetered',
      desc: 'Condition field',
      args: [],
    );
  }

  /// `Name`
  String get rcxFieldName {
    return Intl.message(
      'Name',
      name: 'rcxFieldName',
      desc: 'Condition field: server name',
      args: [],
    );
  }

  /// `Passes check`
  String get rcxFieldPasses {
    return Intl.message(
      'Passes check',
      name: 'rcxFieldPasses',
      desc: 'Condition field',
      args: [],
    );
  }

  /// `Sign-in page`
  String get rcxFieldPortal {
    return Intl.message(
      'Sign-in page',
      name: 'rcxFieldPortal',
      desc: 'Condition field: captive portal network',
      args: [],
    );
  }

  /// `Provider`
  String get rcxFieldProvider {
    return Intl.message(
      'Provider',
      name: 'rcxFieldProvider',
      desc: 'Condition field: proxy provider name',
      args: [],
    );
  }

  /// `Server address`
  String get rcxFieldServer {
    return Intl.message(
      'Server address',
      name: 'rcxFieldServer',
      desc: 'Condition field',
      args: [],
    );
  }

  /// `Tag`
  String get rcxFieldTag {
    return Intl.message(
      'Tag',
      name: 'rcxFieldTag',
      desc: 'Condition field',
      args: [],
    );
  }

  /// `Connection type`
  String get rcxFieldTransport {
    return Intl.message(
      'Connection type',
      name: 'rcxFieldTransport',
      desc: 'Condition field: wifi, cellular, ethernet',
      args: [],
    );
  }

  /// `Protocol`
  String get rcxFieldType {
    return Intl.message(
      'Protocol',
      name: 'rcxFieldType',
      desc: 'Condition field: proxy type',
      args: [],
    );
  }

  /// `Supports UDP`
  String get rcxFieldUdp {
    return Intl.message(
      'Supports UDP',
      name: 'rcxFieldUdp',
      desc: 'Condition field',
      args: [],
    );
  }

  /// `General`
  String get rcxGeneral {
    return Intl.message(
      'General',
      name: 'rcxGeneral',
      desc: 'Section title',
      args: [],
    );
  }

  /// `Earlier versions`
  String get rcxHistoryVersions {
    return Intl.message(
      'Earlier versions',
      name: 'rcxHistoryVersions',
      desc: 'Menu item / sheet title',
      args: [],
    );
  }

  /// `Add to my profiles`
  String get rcxImportAdd {
    return Intl.message(
      'Add to my profiles',
      name: 'rcxImportAdd',
      desc: 'Confirm button',
      args: [],
    );
  }

  /// `Start the app's core to check this profile.`
  String get rcxImportNeedsCore {
    return Intl.message(
      'Start the app\'s core to check this profile.',
      name: 'rcxImportNeedsCore',
      desc: 'Error',
      args: [],
    );
  }

  /// `Import routing profile`
  String get rcxImportTitle {
    return Intl.message(
      'Import routing profile',
      name: 'rcxImportTitle',
      desc: 'Page title',
      args: [],
    );
  }

  /// `Added “{profile}”`
  String rcxImported(String profile) {
    return Intl.message(
      'Added “$profile”',
      name: 'rcxImported',
      desc: 'Toast',
      args: [profile],
    );
  }

  /// `Last resort`
  String get rcxLastResort {
    return Intl.message(
      'Last resort',
      name: 'rcxLastResort',
      desc: 'Switch/label: tier used only when better tiers are empty',
      args: [],
    );
  }

  /// `A last-resort tier is used only when no better tier has a server.`
  String get rcxLastResortHint {
    return Intl.message(
      'A last-resort tier is used only when no better tier has a server.',
      name: 'rcxLastResortHint',
      desc: 'Footer',
      args: [],
    );
  }

  /// `Level`
  String get rcxLevel {
    return Intl.message(
      'Level',
      name: 'rcxLevel',
      desc: 'Row: simple or advanced',
      args: [],
    );
  }

  /// `Line {line}: {text}`
  String rcxLine(int line, String text) {
    return Intl.message(
      'Line $line: $text',
      name: 'rcxLine',
      desc: 'Error with line number',
      args: [line, text],
    );
  }

  /// `Check {check} is never used, so it never runs`
  String rcxLintCheckUnused(String check) {
    return Intl.message(
      'Check $check is never used, so it never runs',
      name: 'rcxLintCheckUnused',
      desc: 'Lint warning',
      args: [check],
    );
  }

  /// `Contacts third-party sites: {hosts}`
  String rcxLintConsent(String hosts) {
    return Intl.message(
      'Contacts third-party sites: $hosts',
      name: 'rcxLintConsent',
      desc: 'Lint warning',
      args: [hosts],
    );
  }

  /// `No server of {group} passes the filter`
  String rcxLintPoolEmpty(String group) {
    return Intl.message(
      'No server of $group passes the filter',
      name: 'rcxLintPoolEmpty',
      desc: 'Lint warning',
      args: [group],
    );
  }

  /// `Tag {tag} is never used`
  String rcxLintTagUnused(String tag) {
    return Intl.message(
      'Tag $tag is never used',
      name: 'rcxLintTagUnused',
      desc: 'Lint warning',
      args: [tag],
    );
  }

  /// `No server of {group} is in “{tier}” right now`
  String rcxLintTierEmpty(String tier, String group) {
    return Intl.message(
      'No server of $group is in “$tier” right now',
      name: 'rcxLintTierEmpty',
      desc: 'Lint warning',
      args: [tier, group],
    );
  }

  /// `“{tier}” repeats the condition of “{after}”, so nothing lands in it`
  String rcxLintTierUnreachable(String tier, String after) {
    return Intl.message(
      '“$tier” repeats the condition of “$after”, so nothing lands in it',
      name: 'rcxLintTierUnreachable',
      desc: 'Lint warning',
      args: [tier, after],
    );
  }

  /// `Couldn't bring the changes over`
  String get rcxMergeFailed {
    return Intl.message(
      'Couldn\'t bring the changes over',
      name: 'rcxMergeFailed',
      desc: 'Toast',
      args: [],
    );
  }

  /// `Changes brought over`
  String get rcxMerged {
    return Intl.message(
      'Changes brought over',
      name: 'rcxMerged',
      desc: 'Toast',
      args: [],
    );
  }

  /// `Brought over; you changed these too, so yours were kept: {keys}`
  String rcxMergedConflicts(String keys) {
    return Intl.message(
      'Brought over; you changed these too, so yours were kept: $keys',
      name: 'rcxMergedConflicts',
      desc: 'Toast',
      args: [keys],
    );
  }

  /// `Move down`
  String get rcxMoveDown {
    return Intl.message(
      'Move down',
      name: 'rcxMoveDown',
      desc: 'Menu',
      args: [],
    );
  }

  /// `Move up`
  String get rcxMoveUp {
    return Intl.message('Move up', name: 'rcxMoveUp', desc: 'Menu', args: []);
  }

  /// `Needs your permission`
  String get rcxNeedsConsent {
    return Intl.message(
      'Needs your permission',
      name: 'rcxNeedsConsent',
      desc: 'Subtitle/reason',
      args: [],
    );
  }

  /// `Network kinds`
  String get rcxNetworkKinds {
    return Intl.message(
      'Network kinds',
      name: 'rcxNetworkKinds',
      desc: 'Row title',
      args: [],
    );
  }

  /// `New profile`
  String get rcxNewProfile {
    return Intl.message(
      'New profile',
      name: 'rcxNewProfile',
      desc: 'Row / default title',
      args: [],
    );
  }

  /// `fails`
  String get rcxOpFail {
    return Intl.message(
      'fails',
      name: 'rcxOpFail',
      desc: 'Operator: diagnostic fails',
      args: [],
    );
  }

  /// `is one of`
  String get rcxOpIn {
    return Intl.message(
      'is one of',
      name: 'rcxOpIn',
      desc: 'Operator',
      args: [],
    );
  }

  /// `is`
  String get rcxOpIs {
    return Intl.message('is', name: 'rcxOpIs', desc: 'Operator', args: []);
  }

  /// `is not`
  String get rcxOpIsNot {
    return Intl.message(
      'is not',
      name: 'rcxOpIsNot',
      desc: 'Operator',
      args: [],
    );
  }

  /// `matches`
  String get rcxOpMatches {
    return Intl.message(
      'matches',
      name: 'rcxOpMatches',
      desc: 'Operator: regex',
      args: [],
    );
  }

  /// `succeeds`
  String get rcxOpOk {
    return Intl.message(
      'succeeds',
      name: 'rcxOpOk',
      desc: 'Operator: diagnostic succeeds',
      args: [],
    );
  }

  /// `Per-network changes`
  String get rcxOverrides {
    return Intl.message(
      'Per-network changes',
      name: 'rcxOverrides',
      desc: 'Row title: overrides by network kind',
      args: [],
    );
  }

  /// `Leave out`
  String get rcxPoolExclude {
    return Intl.message(
      'Leave out',
      name: 'rcxPoolExclude',
      desc: 'Row: servers excluded from the pool',
      args: [],
    );
  }

  /// `Use`
  String get rcxPoolInclude {
    return Intl.message(
      'Use',
      name: 'rcxPoolInclude',
      desc: 'Row: servers included in the pool',
      args: [],
    );
  }

  /// `Name`
  String get rcxProfileName {
    return Intl.message(
      'Name',
      name: 'rcxProfileName',
      desc: 'Row: profile title',
      args: [],
    );
  }

  /// `The original profile changed`
  String get rcxSourceChanged {
    return Intl.message(
      'The original profile changed',
      name: 'rcxSourceChanged',
      desc: 'Section title',
      args: [],
    );
  }

  /// `What changed`
  String get rcxSourceChanges {
    return Intl.message(
      'What changed',
      name: 'rcxSourceChanges',
      desc: 'Row/page title: diff of the source',
      args: [],
    );
  }

  /// `When no server fits`
  String get rcxStranded {
    return Intl.message(
      'When no server fits',
      name: 'rcxStranded',
      desc: 'Row',
      args: [],
    );
  }

  /// `Go direct`
  String get rcxStrandedDirect {
    return Intl.message(
      'Go direct',
      name: 'rcxStrandedDirect',
      desc: 'Choice',
      args: [],
    );
  }

  /// `Keep the current server`
  String get rcxStrandedHold {
    return Intl.message(
      'Keep the current server',
      name: 'rcxStrandedHold',
      desc: 'Choice',
      args: [],
    );
  }

  /// `Tag name`
  String get rcxTagName {
    return Intl.message(
      'Tag name',
      name: 'rcxTagName',
      desc: 'Input label',
      args: [],
    );
  }

  /// `Latin letters, digits, - and _ only, up to 24`
  String get rcxTagNameInvalid {
    return Intl.message(
      'Latin letters, digits, - and _ only, up to 24',
      name: 'rcxTagNameInvalid',
      desc: 'Validation',
      args: [],
    );
  }

  /// `Tags`
  String get rcxTags {
    return Intl.message(
      'Tags',
      name: 'rcxTags',
      desc: 'Section title',
      args: [],
    );
  }

  /// `A tag names a set of servers once, for use in tiers as tag(name).`
  String get rcxTagsHint {
    return Intl.message(
      'A tag names a set of servers once, for use in tiers as tag(name).',
      name: 'rcxTagsHint',
      desc: 'Footer',
      args: [],
    );
  }

  /// `third party`
  String get rcxThirdParty {
    return Intl.message(
      'third party',
      name: 'rcxThirdParty',
      desc: 'Lowercase marker on a host',
      args: [],
    );
  }

  /// `Tier`
  String get rcxTier {
    return Intl.message('Tier', name: 'rcxTier', desc: 'Title', args: []);
  }

  /// `Label`
  String get rcxTierLabel {
    return Intl.message('Label', name: 'rcxTierLabel', desc: 'Row', args: []);
  }

  /// `Servers in this tier`
  String get rcxTierWhen {
    return Intl.message(
      'Servers in this tier',
      name: 'rcxTierWhen',
      desc: 'Row: the tier\'s condition',
      args: [],
    );
  }

  /// `Preference order`
  String get rcxTiers {
    return Intl.message(
      'Preference order',
      name: 'rcxTiers',
      desc: 'Section title: ordered tiers',
      args: [],
    );
  }

  /// `A server lands in the first tier it fits; the best tier with servers wins. Long press to reorder.`
  String get rcxTiersHint {
    return Intl.message(
      'A server lands in the first tier it fits; the best tier with servers wins. Long press to reorder.',
      name: 'rcxTiersHint',
      desc: 'Footer',
      args: [],
    );
  }

  /// `Translations`
  String get rcxTranslations {
    return Intl.message(
      'Translations',
      name: 'rcxTranslations',
      desc: 'Row title: languages of the profile\'s l10n',
      args: [],
    );
  }

  /// `check {name}`
  String rcxUseCheck(String name) {
    return Intl.message(
      'check $name',
      name: 'rcxUseCheck',
      desc: 'Lowercase: endpoint used by a check',
      args: [name],
    );
  }

  /// `network diagnostic {name}`
  String rcxUseDiagnostic(String name) {
    return Intl.message(
      'network diagnostic $name',
      name: 'rcxUseDiagnostic',
      desc: 'Lowercase',
      args: [name],
    );
  }

  /// `exit-country check`
  String get rcxUseEcho {
    return Intl.message(
      'exit-country check',
      name: 'rcxUseEcho',
      desc: 'Lowercase',
      args: [],
    );
  }

  /// `Warnings`
  String get rcxWarnings {
    return Intl.message(
      'Warnings',
      name: 'rcxWarnings',
      desc: 'Section title',
      args: [],
    );
  }

  /// `YAML`
  String get rcxYaml {
    return Intl.message(
      'YAML',
      name: 'rcxYaml',
      desc: 'Action / page title',
      args: [],
    );
  }

  /// `Add group`
  String get rcxAddGroup {
    return Intl.message('Add group', name: 'rcxAddGroup', desc: '', args: []);
  }

  /// `Add network kind`
  String get rcxAddKind {
    return Intl.message(
      'Add network kind',
      name: 'rcxAddKind',
      desc: '',
      args: [],
    );
  }

  /// `Every group`
  String get rcxAllGroups {
    return Intl.message(
      'Every group',
      name: 'rcxAllGroups',
      desc: '',
      args: [],
    );
  }

  /// `Main group`
  String get rcxMainGroup {
    return Intl.message('Main group', name: 'rcxMainGroup', desc: '', args: []);
  }

  /// `Auto control`
  String get rcxAutoControl {
    return Intl.message(
      'Auto control',
      name: 'rcxAutoControl',
      desc: '',
      args: [],
    );
  }

  /// `A scenario steers the whole connection: the mode on each kind of network and what every group does. Groups it does not name keep their own profile.`
  String get rcxAutoControlHint {
    return Intl.message(
      'A scenario steers the whole connection: the mode on each kind of network and what every group does. Groups it does not name keep their own profile.',
      name: 'rcxAutoControlHint',
      desc: '',
      args: [],
    );
  }

  /// `Check`
  String get rcxCheck {
    return Intl.message('Check', name: 'rcxCheck', desc: '', args: []);
  }

  /// `Against group`
  String get rcxCheckGroup {
    return Intl.message(
      'Against group',
      name: 'rcxCheckGroup',
      desc: '',
      args: [],
    );
  }

  /// `Condition {number}`
  String rcxCondClause(int number) {
    return Intl.message(
      'Condition $number',
      name: 'rcxCondClause',
      desc: '',
      args: [number],
    );
  }

  /// `Network diagnostics`
  String get rcxDiagnostics {
    return Intl.message(
      'Network diagnostics',
      name: 'rcxDiagnostics',
      desc: '',
      args: [],
    );
  }

  /// `except {condition}`
  String rcxExcept(String condition) {
    return Intl.message(
      'except $condition',
      name: 'rcxExcept',
      desc: '',
      args: [condition],
    );
  }

  /// `The whole group goes through this member with no server search; pick a load balancer or a nested group to hand it everything.`
  String get rcxFixedHint {
    return Intl.message(
      'The whole group goes through this member with no server search; pick a load balancer or a nested group to hand it everything.',
      name: 'rcxFixedHint',
      desc: '',
      args: [],
    );
  }

  /// `Through {member}`
  String rcxFixedOn(String member) {
    return Intl.message(
      'Through $member',
      name: 'rcxFixedOn',
      desc: '',
      args: [member],
    );
  }

  /// `Group profiles`
  String get rcxGroupProfiles {
    return Intl.message(
      'Group profiles',
      name: 'rcxGroupProfiles',
      desc: '',
      args: [],
    );
  }

  /// `How a smart group picks its server. Tap one of yours to edit it, any other to edit a copy.`
  String get rcxGroupProfilesHint {
    return Intl.message(
      'How a smart group picks its server. Tap one of yours to edit it, any other to edit a copy.',
      name: 'rcxGroupProfilesHint',
      desc: '',
      args: [],
    );
  }

  /// `Mode {from} → {to}`
  String rcxJournalMode(String from, String to) {
    return Intl.message(
      'Mode $from → $to',
      name: 'rcxJournalMode',
      desc: '',
      args: [from, to],
    );
  }

  /// `On this network these replace the scenario's groups of the same name; the others work as on every network.`
  String get rcxKindGroupsHint {
    return Intl.message(
      'On this network these replace the scenario\'s groups of the same name; the others work as on every network.',
      name: 'rcxKindGroupsHint',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get rcxKindName {
    return Intl.message('Name', name: 'rcxKindName', desc: '', args: []);
  }

  /// `Lowercase Latin letters, digits and dashes, up to 24`
  String get rcxKindNameInvalid {
    return Intl.message(
      'Lowercase Latin letters, digits and dashes, up to 24',
      name: 'rcxKindNameInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Recognized when`
  String get rcxKindWhen {
    return Intl.message(
      'Recognized when',
      name: 'rcxKindWhen',
      desc: '',
      args: [],
    );
  }

  /// `Kinds are tried top to bottom; the network gets the first that holds.`
  String get rcxKindWhenHint {
    return Intl.message(
      'Kinds are tried top to bottom; the network gets the first that holds.',
      name: 'rcxKindWhenHint',
      desc: '',
      args: [],
    );
  }

  /// `This config has no group {group}`
  String rcxLintGroupMissing(String group) {
    return Intl.message(
      'This config has no group $group',
      name: 'rcxLintGroupMissing',
      desc: '',
      args: [group],
    );
  }

  /// `Profiles and scenarios are made and edited in Advanced configuration → Auto routing.`
  String get rcxManageHint {
    return Intl.message(
      'Profiles and scenarios are made and edited in Advanced configuration → Auto routing.',
      name: 'rcxManageHint',
      desc: '',
      args: [],
    );
  }

  /// `Give the mode back to the scenario`
  String get rcxModeBackToAuto {
    return Intl.message(
      'Give the mode back to the scenario',
      name: 'rcxModeBackToAuto',
      desc: '',
      args: [],
    );
  }

  /// `The scenario sets the mode on this network`
  String get rcxModeByScenario {
    return Intl.message(
      'The scenario sets the mode on this network',
      name: 'rcxModeByScenario',
      desc: '',
      args: [],
    );
  }

  /// `Mode: {mode}`
  String rcxModeIs(String mode) {
    return Intl.message(
      'Mode: $mode',
      name: 'rcxModeIs',
      desc: '',
      args: [mode],
    );
  }

  /// `Don't change`
  String get rcxModeKeep {
    return Intl.message(
      'Don\'t change',
      name: 'rcxModeKeep',
      desc: '',
      args: [],
    );
  }

  /// `You chose the mode yourself; the scenario waits until you pick Auto`
  String get rcxModeManualNow {
    return Intl.message(
      'You chose the mode yourself; the scenario waits until you pick Auto',
      name: 'rcxModeManualNow',
      desc: '',
      args: [],
    );
  }

  /// `The mode is yours on this network`
  String get rcxModeYours {
    return Intl.message(
      'The mode is yours on this network',
      name: 'rcxModeYours',
      desc: '',
      args: [],
    );
  }

  /// `New scenario`
  String get rcxNewScenario {
    return Intl.message(
      'New scenario',
      name: 'rcxNewScenario',
      desc: '',
      args: [],
    );
  }

  /// `On this network`
  String get rcxOnThisNetwork {
    return Intl.message(
      'On this network',
      name: 'rcxOnThisNetwork',
      desc: '',
      args: [],
    );
  }

  /// `Group's own profile`
  String get rcxOwnProfile {
    return Intl.message(
      'Group\'s own profile',
      name: 'rcxOwnProfile',
      desc: '',
      args: [],
    );
  }

  /// `The group picks a server with this profile among the servers the pool keeps.`
  String get rcxProfileProgramHint {
    return Intl.message(
      'The group picks a server with this profile among the servers the pool keeps.',
      name: 'rcxProfileProgramHint',
      desc: '',
      args: [],
    );
  }

  /// `Action`
  String get rcxProgramAction {
    return Intl.message('Action', name: 'rcxProgramAction', desc: '', args: []);
  }

  /// `Hand to one member`
  String get rcxProgramFixed {
    return Intl.message(
      'Hand to one member',
      name: 'rcxProgramFixed',
      desc: '',
      args: [],
    );
  }

  /// `Member`
  String get rcxProgramMember {
    return Intl.message('Member', name: 'rcxProgramMember', desc: '', args: []);
  }

  /// `Pick a server`
  String get rcxProgramPick {
    return Intl.message(
      'Pick a server',
      name: 'rcxProgramPick',
      desc: '',
      args: [],
    );
  }

  /// `The scenario holds {node}`
  String rcxReasonFixed(String node) {
    return Intl.message(
      'The scenario holds $node',
      name: 'rcxReasonFixed',
      desc: '',
      args: [node],
    );
  }

  /// `{node} is not in this group`
  String rcxReasonFixedMissing(String node) {
    return Intl.message(
      '$node is not in this group',
      name: 'rcxReasonFixedMissing',
      desc: '',
      args: [node],
    );
  }

  /// `Not in use: mode {mode}`
  String rcxReasonIdle(String mode) {
    return Intl.message(
      'Not in use: mode $mode',
      name: 'rcxReasonIdle',
      desc: '',
      args: [mode],
    );
  }

  /// `The scenario moves to {node}`
  String rcxReasonSwitchFixed(String node) {
    return Intl.message(
      'The scenario moves to $node',
      name: 'rcxReasonSwitchFixed',
      desc: '',
      args: [node],
    );
  }

  /// `Scenario`
  String get rcxScenario {
    return Intl.message('Scenario', name: 'rcxScenario', desc: '', args: []);
  }

  /// `The scenario «{scenario}» drives this group now.`
  String rcxScenarioDrives(String scenario) {
    return Intl.message(
      'The scenario «$scenario» drives this group now.',
      name: 'rcxScenarioDrives',
      desc: '',
      args: [scenario],
    );
  }

  /// `Groups`
  String get rcxScenarioGroups {
    return Intl.message(
      'Groups',
      name: 'rcxScenarioGroups',
      desc: '',
      args: [],
    );
  }

  /// `Main group is where the final rule sends traffic; Every group covers the select groups not named here.`
  String get rcxScenarioGroupsHint {
    return Intl.message(
      'Main group is where the final rule sends traffic; Every group covers the select groups not named here.',
      name: 'rcxScenarioGroupsHint',
      desc: '',
      args: [],
    );
  }

  /// `Recognize networks by direct diagnostics, then change the mode and groups on each.`
  String get rcxScenarioKindsHint {
    return Intl.message(
      'Recognize networks by direct diagnostics, then change the mode and groups on each.',
      name: 'rcxScenarioKindsHint',
      desc: '',
      args: [],
    );
  }

  /// `Connection mode`
  String get rcxScenarioMode {
    return Intl.message(
      'Connection mode',
      name: 'rcxScenarioMode',
      desc: '',
      args: [],
    );
  }

  /// `Off`
  String get rcxScenarioOff {
    return Intl.message('Off', name: 'rcxScenarioOff', desc: '', args: []);
  }

  /// `Scenarios`
  String get rcxScenarios {
    return Intl.message('Scenarios', name: 'rcxScenarios', desc: '', args: []);
  }

  /// `A scenario drives the whole connection. Tap one of yours to edit it, any other to edit a copy.`
  String get rcxScenariosHint {
    return Intl.message(
      'A scenario drives the whole connection. Tap one of yours to edit it, any other to edit a copy.',
      name: 'rcxScenariosHint',
      desc: '',
      args: [],
    );
  }

  /// `Smart groups`
  String get rcxSmartGroups {
    return Intl.message(
      'Smart groups',
      name: 'rcxSmartGroups',
      desc: '',
      args: [],
    );
  }

  /// `Read to the end`
  String get disclaimerReadToEnd {
    return Intl.message(
      'Read to the end',
      name: 'disclaimerReadToEnd',
      desc: '',
      args: [],
    );
  }

  /// `Dropped include-all from the proxy groups {groups}; add the proxies or proxy providers they use`
  String customImportDroppedIncludeAll(Object groups) {
    return Intl.message(
      'Dropped include-all from the proxy groups $groups; add the proxies or proxy providers they use',
      name: 'customImportDroppedIncludeAll',
      desc: '',
      args: [groups],
    );
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Content`
  String get notificationContent {
    return Intl.message(
      'Content',
      name: 'notificationContent',
      desc: '',
      args: [],
    );
  }

  /// `Notification level`
  String get notificationVisibility {
    return Intl.message(
      'Notification level',
      name: 'notificationVisibility',
      desc: '',
      args: [],
    );
  }

  /// `Detailed`
  String get notificationVisibilityDetailed {
    return Intl.message(
      'Detailed',
      name: 'notificationVisibilityDetailed',
      desc: '',
      args: [],
    );
  }

  /// `Minimal`
  String get notificationVisibilityMinimal {
    return Intl.message(
      'Minimal',
      name: 'notificationVisibilityMinimal',
      desc: '',
      args: [],
    );
  }

  /// `Notification components`
  String get notificationComponents {
    return Intl.message(
      'Notification components',
      name: 'notificationComponents',
      desc: '',
      args: [],
    );
  }

  /// `Build the notification from live status components.`
  String get notificationComponentsDesc {
    return Intl.message(
      'Build the notification from live status components.',
      name: 'notificationComponentsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Add component`
  String get notificationAddComponent {
    return Intl.message(
      'Add component',
      name: 'notificationAddComponent',
      desc: '',
      args: [],
    );
  }

  /// `No components added`
  String get notificationComponentsEmpty {
    return Intl.message(
      'No components added',
      name: 'notificationComponentsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Current server`
  String get notificationCurrentServer {
    return Intl.message(
      'Current server',
      name: 'notificationCurrentServer',
      desc: '',
      args: [],
    );
  }

  /// `Network speed`
  String get notificationNetworkSpeed {
    return Intl.message(
      'Network speed',
      name: 'notificationNetworkSpeed',
      desc: '',
      args: [],
    );
  }

  /// `Session traffic`
  String get notificationSessionTraffic {
    return Intl.message(
      'Session traffic',
      name: 'notificationSessionTraffic',
      desc: '',
      args: [],
    );
  }

  /// `Automatic group`
  String get notificationAutomaticGroup {
    return Intl.message(
      'Automatic group',
      name: 'notificationAutomaticGroup',
      desc: '',
      args: [],
    );
  }

  /// `Hide idle speed`
  String get notificationHideIdleSpeed {
    return Intl.message(
      'Hide idle speed',
      name: 'notificationHideIdleSpeed',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get notificationPrivacy {
    return Intl.message(
      'Privacy',
      name: 'notificationPrivacy',
      desc: '',
      args: [],
    );
  }

  /// `Reminders`
  String get notificationReminders {
    return Intl.message(
      'Reminders',
      name: 'notificationReminders',
      desc: '',
      args: [],
    );
  }

  /// `Hide sensitive details on lock screen`
  String get notificationHideSensitive {
    return Intl.message(
      'Hide sensitive details on lock screen',
      name: 'notificationHideSensitive',
      desc: '',
      args: [],
    );
  }

  /// `Uses Android's lock-screen privacy settings for service notifications and reminders. Details remain visible while unlocked.`
  String get notificationHideSensitiveDesc {
    return Intl.message(
      'Uses Android\'s lock-screen privacy settings for service notifications and reminders. Details remain visible while unlocked.',
      name: 'notificationHideSensitiveDesc',
      desc: '',
      args: [],
    );
  }

  /// `Service channel`
  String get notificationServiceChannel {
    return Intl.message(
      'Service channel',
      name: 'notificationServiceChannel',
      desc: '',
      args: [],
    );
  }

  /// `Subscription reminders channel`
  String get notificationSubscriptionChannel {
    return Intl.message(
      'Subscription reminders channel',
      name: 'notificationSubscriptionChannel',
      desc: '',
      args: [],
    );
  }

  /// `Subscription reminders`
  String get notificationSubscriptionReminders {
    return Intl.message(
      'Subscription reminders',
      name: 'notificationSubscriptionReminders',
      desc: '',
      args: [],
    );
  }

  /// `Notify when a subscription needs attention`
  String get notificationSubscriptionRemindersDesc {
    return Intl.message(
      'Notify when a subscription needs attention',
      name: 'notificationSubscriptionRemindersDesc',
      desc: '',
      args: [],
    );
  }

  /// `Android delivery`
  String get notificationDelivery {
    return Intl.message(
      'Android delivery',
      name: 'notificationDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Checking Android notification access`
  String get notificationDeliveryChecking {
    return Intl.message(
      'Checking Android notification access',
      name: 'notificationDeliveryChecking',
      desc: '',
      args: [],
    );
  }

  /// `Notifications are blocked for ReClash`
  String get notificationDeliveryPermissionDisabled {
    return Intl.message(
      'Notifications are blocked for ReClash',
      name: 'notificationDeliveryPermissionDisabled',
      desc: '',
      args: [],
    );
  }

  /// `The ReClash service channel is disabled`
  String get notificationDeliveryServiceDisabled {
    return Intl.message(
      'The ReClash service channel is disabled',
      name: 'notificationDeliveryServiceDisabled',
      desc: '',
      args: [],
    );
  }

  /// `The subscription reminders channel is disabled`
  String get notificationDeliverySubscriptionDisabled {
    return Intl.message(
      'The subscription reminders channel is disabled',
      name: 'notificationDeliverySubscriptionDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Notifications can be delivered`
  String get notificationDeliveryReady {
    return Intl.message(
      'Notifications can be delivered',
      name: 'notificationDeliveryReady',
      desc: '',
      args: [],
    );
  }

  /// `The chosen group is missing from the profile`
  String get notificationServerGroupMissing {
    return Intl.message(
      'The chosen group is missing from the profile',
      name: 'notificationServerGroupMissing',
      desc: '',
      args: [],
    );
  }

  /// `No server group is resolved, so this line is hidden`
  String get notificationBlockedNoServerGroup {
    return Intl.message(
      'No server group is resolved, so this line is hidden',
      name: 'notificationBlockedNoServerGroup',
      desc: '',
      args: [],
    );
  }

  /// `Without components the notification shows only the protection status.`
  String get notificationComponentsEmptyDesc {
    return Intl.message(
      'Without components the notification shows only the protection status.',
      name: 'notificationComponentsEmptyDesc',
      desc: '',
      args: [],
    );
  }

  /// `Subscription reminders`
  String get subscriptionNoticeChannel {
    return Intl.message(
      'Subscription reminders',
      name: 'subscriptionNoticeChannel',
      desc: '',
      args: [],
    );
  }

  /// `Your subscription has expired`
  String get subscriptionExpired {
    return Intl.message(
      'Your subscription has expired',
      name: 'subscriptionExpired',
      desc: '',
      args: [],
    );
  }

  /// `Your subscription expires today`
  String get subscriptionExpiresToday {
    return Intl.message(
      'Your subscription expires today',
      name: 'subscriptionExpiresToday',
      desc: '',
      args: [],
    );
  }

  /// `Your subscription expires in {count, plural, =1{1 day} other{{count} days}}`
  String subscriptionExpiresInDays(int count) {
    return Intl.message(
      'Your subscription expires in ${Intl.plural(count, one: '1 day', other: '$count days')}',
      name: 'subscriptionExpiresInDays',
      desc: '',
      args: [count],
    );
  }

  /// `You have used {percent}% of your traffic`
  String subscriptionTrafficLow(int percent) {
    return Intl.message(
      'You have used $percent% of your traffic',
      name: 'subscriptionTrafficLow',
      desc: '',
      args: [percent],
    );
  }

  /// `Renew subscription`
  String get renewSubscription {
    return Intl.message(
      'Renew subscription',
      name: 'renewSubscription',
      desc: '',
      args: [],
    );
  }

  /// `Top up traffic`
  String get topUpTraffic {
    return Intl.message(
      'Top up traffic',
      name: 'topUpTraffic',
      desc: '',
      args: [],
    );
  }

  /// `Protection active`
  String get notificationActive {
    return Intl.message(
      'Protection active',
      name: 'notificationActive',
      desc: '',
      args: [],
    );
  }

  /// `Detailed shows live information and the stop button. Minimal shows only protection status.`
  String get notificationLevelDescription {
    return Intl.message(
      'Detailed shows live information and the stop button. Minimal shows only protection status.',
      name: 'notificationLevelDescription',
      desc: '',
      args: [],
    );
  }

  /// `Extra`
  String get extra {
    return Intl.message('Extra', name: 'extra', desc: '', args: []);
  }

  /// `Reset all data`
  String get resetAllData {
    return Intl.message(
      'Reset all data',
      name: 'resetAllData',
      desc: '',
      args: [],
    );
  }

  /// `All profiles, settings, scripts, wallpapers, and cached data will be permanently deleted. Backup archives will be kept. The app will then close. This cannot be undone.`
  String get resetAllDataDescription {
    return Intl.message(
      'All profiles, settings, scripts, wallpapers, and cached data will be permanently deleted. Backup archives will be kept. The app will then close. This cannot be undone.',
      name: 'resetAllDataDescription',
      desc: '',
      args: [],
    );
  }

  /// `Delete everything`
  String get resetAllDataConfirm {
    return Intl.message(
      'Delete everything',
      name: 'resetAllDataConfirm',
      desc: '',
      args: [],
    );
  }

  /// `You can confirm in {seconds} s`
  String resetAllDataWait(int seconds) {
    return Intl.message(
      'You can confirm in $seconds s',
      name: 'resetAllDataWait',
      desc: '',
      args: [seconds],
    );
  }

  /// `Deleting data…`
  String get resettingAllData {
    return Intl.message(
      'Deleting data…',
      name: 'resettingAllData',
      desc: '',
      args: [],
    );
  }

  /// `App icon`
  String get appIcon {
    return Intl.message('App icon', name: 'appIcon', desc: '', args: []);
  }

  /// `Standard`
  String get appIconStandard {
    return Intl.message(
      'Standard',
      name: 'appIconStandard',
      desc: '',
      args: [],
    );
  }

  /// `Velvet`
  String get appIconVelvet {
    return Intl.message('Velvet', name: 'appIconVelvet', desc: '', args: []);
  }

  /// `Solar`
  String get appIconSolar {
    return Intl.message('Solar', name: 'appIconSolar', desc: '', args: []);
  }

  /// `Circuit`
  String get appIconCircuit {
    return Intl.message('Circuit', name: 'appIconCircuit', desc: '', args: []);
  }

  /// `Echo`
  String get appIconEcho {
    return Intl.message('Echo', name: 'appIconEcho', desc: '', args: []);
  }

  /// `Ink`
  String get appIconInk {
    return Intl.message('Ink', name: 'appIconInk', desc: '', args: []);
  }

  /// `Blueprint`
  String get appIconBlueprint {
    return Intl.message(
      'Blueprint',
      name: 'appIconBlueprint',
      desc: '',
      args: [],
    );
  }

  /// `Strata`
  String get appIconStrata {
    return Intl.message('Strata', name: 'appIconStrata', desc: '', args: []);
  }

  /// `Shatter`
  String get appIconShatter {
    return Intl.message('Shatter', name: 'appIconShatter', desc: '', args: []);
  }

  /// `Trace`
  String get appIconTrace {
    return Intl.message('Trace', name: 'appIconTrace', desc: '', args: []);
  }

  /// `Topo`
  String get appIconTopo {
    return Intl.message('Topo', name: 'appIconTopo', desc: '', args: []);
  }

  /// `Spark`
  String get appIconSpark {
    return Intl.message('Spark', name: 'appIconSpark', desc: '', args: []);
  }

  /// `Use this icon`
  String get appIconApply {
    return Intl.message(
      'Use this icon',
      name: 'appIconApply',
      desc: '',
      args: [],
    );
  }

  /// `The home screen may take a few seconds to show the new icon, and some launchers remove the shortcut — add it again from the app list.`
  String get appIconChangeNote {
    return Intl.message(
      'The home screen may take a few seconds to show the new icon, and some launchers remove the shortcut — add it again from the app list.',
      name: 'appIconChangeNote',
      desc: '',
      args: [],
    );
  }

  /// `Contrast`
  String get colorContrast {
    return Intl.message('Contrast', name: 'colorContrast', desc: '', args: []);
  }

  /// `Medium`
  String get contrastMedium {
    return Intl.message('Medium', name: 'contrastMedium', desc: '', args: []);
  }

  /// `High`
  String get contrastHigh {
    return Intl.message('High', name: 'contrastHigh', desc: '', args: []);
  }

  /// `Tab labels`
  String get navigationLabels {
    return Intl.message(
      'Tab labels',
      name: 'navigationLabels',
      desc: '',
      args: [],
    );
  }

  /// `Always`
  String get navigationLabelsAlways {
    return Intl.message(
      'Always',
      name: 'navigationLabelsAlways',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get navigationLabelsSelected {
    return Intl.message(
      'Selected',
      name: 'navigationLabelsSelected',
      desc: '',
      args: [],
    );
  }

  /// `Never`
  String get navigationLabelsNever {
    return Intl.message(
      'Never',
      name: 'navigationLabelsNever',
      desc: '',
      args: [],
    );
  }

  /// `Tray icon`
  String get trayIcon {
    return Intl.message('Tray icon', name: 'trayIcon', desc: '', args: []);
  }

  /// `Color`
  String get trayIconColor {
    return Intl.message('Color', name: 'trayIconColor', desc: '', args: []);
  }

  /// `White`
  String get trayIconLight {
    return Intl.message('White', name: 'trayIconLight', desc: '', args: []);
  }

  /// `Black`
  String get trayIconDark {
    return Intl.message('Black', name: 'trayIconDark', desc: '', args: []);
  }

  /// `From provider`
  String get providerSettingManaged {
    return Intl.message(
      'From provider',
      name: 'providerSettingManaged',
      desc: 'Tag on a setting or app that the subscription provider currently sets',
      args: [],
    );
  }

  /// `Return to provider`
  String get providerSettingReturn {
    return Intl.message(
      'Return to provider',
      name: 'providerSettingReturn',
      desc: 'Action on a setting the user changed: let the subscription set it again',
      args: [],
    );
  }

  /// `Return settings to provider`
  String get providerSettingsReturnAll {
    return Intl.message(
      'Return settings to provider',
      name: 'providerSettingsReturnAll',
      desc: '',
      args: [],
    );
  }

  /// `Settings you changed follow the subscription again`
  String get providerSettingsReturnAllDesc {
    return Intl.message(
      'Settings you changed follow the subscription again',
      name: 'providerSettingsReturnAllDesc',
      desc: '',
      args: [],
    );
  }

  /// `Announcement`
  String get providerAnnouncement {
    return Intl.message(
      'Announcement',
      name: 'providerAnnouncement',
      desc: '',
      args: [],
    );
  }

  /// `Learn more`
  String get providerAnnouncementOpen {
    return Intl.message(
      'Learn more',
      name: 'providerAnnouncementOpen',
      desc: '',
      args: [],
    );
  }

  /// `Return apps to provider`
  String get accessReturnToProvider {
    return Intl.message(
      'Return apps to provider',
      name: 'accessReturnToProvider',
      desc: '',
      args: [],
    );
  }

  /// `Apps your provider keeps out of the VPN: {count}. Turn on access control to change the list.`
  String accessProviderDisabledDesc(int count) {
    return Intl.message(
      'Apps your provider keeps out of the VPN: $count. Turn on access control to change the list.',
      name: 'accessProviderDisabledDesc',
      desc: '',
      args: [count],
    );
  }

  /// `Dashboard access is disabled by your provider.`
  String get webDashboardRestricted {
    return Intl.message(
      'Dashboard access is disabled by your provider.',
      name: 'webDashboardRestricted',
      desc: '',
      args: [],
    );
  }

  /// `Notice`
  String get providerNotice {
    return Intl.message('Notice', name: 'providerNotice', desc: '', args: []);
  }

  /// `Application settings`
  String get applicationSettings {
    return Intl.message(
      'Application settings',
      name: 'applicationSettings',
      desc: '',
      args: [],
    );
  }

  /// `Configuration`
  String get toolsConfiguration {
    return Intl.message(
      'Configuration',
      name: 'toolsConfiguration',
      desc: '',
      args: [],
    );
  }

  /// `Resources and data`
  String get toolsData {
    return Intl.message(
      'Resources and data',
      name: 'toolsData',
      desc: '',
      args: [],
    );
  }

  /// `Diagnostics`
  String get toolsObservation {
    return Intl.message(
      'Diagnostics',
      name: 'toolsObservation',
      desc: '',
      args: [],
    );
  }

  /// `Information and debugging`
  String get toolsInformation {
    return Intl.message(
      'Information and debugging',
      name: 'toolsInformation',
      desc: '',
      args: [],
    );
  }

  /// `Pinned`
  String get toolsPinned {
    return Intl.message('Pinned', name: 'toolsPinned', desc: '', args: []);
  }

  /// `Pin`
  String get toolsPin {
    return Intl.message('Pin', name: 'toolsPin', desc: '', args: []);
  }

  /// `Unpin`
  String get toolsUnpin {
    return Intl.message('Unpin', name: 'toolsUnpin', desc: '', args: []);
  }

  /// `Action`
  String get toolsAction {
    return Intl.message('Action', name: 'toolsAction', desc: '', args: []);
  }

  /// `Setting`
  String get toolsSetting {
    return Intl.message('Setting', name: 'toolsSetting', desc: '', args: []);
  }

  /// `Section`
  String get toolsSection {
    return Intl.message('Section', name: 'toolsSection', desc: '', args: []);
  }

  /// `Run`
  String get toolsRun {
    return Intl.message('Run', name: 'toolsRun', desc: '', args: []);
  }

  /// `Update resources`
  String get toolsUpdateResources {
    return Intl.message(
      'Update resources',
      name: 'toolsUpdateResources',
      desc: '',
      args: [],
    );
  }

  /// `Restart core`
  String get toolsRestartCore {
    return Intl.message(
      'Restart core',
      name: 'toolsRestartCore',
      desc: '',
      args: [],
    );
  }

  /// `Start the core to use this action`
  String get toolsNeedsCore {
    return Intl.message(
      'Start the core to use this action',
      name: 'toolsNeedsCore',
      desc: '',
      args: [],
    );
  }

  /// `Enable authentication first`
  String get toolsNeedsAuthentication {
    return Intl.message(
      'Enable authentication first',
      name: 'toolsNeedsAuthentication',
      desc: '',
      args: [],
    );
  }

  /// `Enable the external controller first`
  String get toolsNeedsController {
    return Intl.message(
      'Enable the external controller first',
      name: 'toolsNeedsController',
      desc: '',
      args: [],
    );
  }

  /// `No matching settings or actions`
  String get toolsEmpty {
    return Intl.message(
      'No matching settings or actions',
      name: 'toolsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Choose a section or search for a setting`
  String get toolsChoose {
    return Intl.message(
      'Choose a section or search for a setting',
      name: 'toolsChoose',
      desc: '',
      args: [],
    );
  }

  /// `Recently used`
  String get toolsLastUsed {
    return Intl.message(
      'Recently used',
      name: 'toolsLastUsed',
      desc: '',
      args: [],
    );
  }

  /// `This will close all active connections. Continue?`
  String get toolsCloseConnectionsConfirm {
    return Intl.message(
      'This will close all active connections. Continue?',
      name: 'toolsCloseConnectionsConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Updating rules and scripts may reapply the configuration and affect connections. Continue?`
  String get toolsUpdateResourcesConfirm {
    return Intl.message(
      'Updating rules and scripts may reapply the configuration and affect connections. Continue?',
      name: 'toolsUpdateResourcesConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Action completed`
  String get toolsCompleted {
    return Intl.message(
      'Action completed',
      name: 'toolsCompleted',
      desc: '',
      args: [],
    );
  }

  /// `{count} results`
  String toolsResults(Object count) {
    return Intl.message(
      '$count results',
      name: 'toolsResults',
      desc: '',
      args: [count],
    );
  }

  /// `Add this DNS override on the DNS page first`
  String get toolsNeedsOverride {
    return Intl.message(
      'Add this DNS override on the DNS page first',
      name: 'toolsNeedsOverride',
      desc: '',
      args: [],
    );
  }

  /// `Select a custom network interface first`
  String get toolsNeedsCustomInterface {
    return Intl.message(
      'Select a custom network interface first',
      name: 'toolsNeedsCustomInterface',
      desc: '',
      args: [],
    );
  }

  /// `Configure WebDAV first`
  String get toolsNeedsWebdav {
    return Intl.message(
      'Configure WebDAV first',
      name: 'toolsNeedsWebdav',
      desc: '',
      args: [],
    );
  }

  /// `Select the MIPS network stack first`
  String get toolsNeedsMipsStack {
    return Intl.message(
      'Select the MIPS network stack first',
      name: 'toolsNeedsMipsStack',
      desc: '',
      args: [],
    );
  }

  /// `Web dashboard`
  String get webDashboard {
    return Intl.message(
      'Web dashboard',
      name: 'webDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Manage local web dashboards for the Core`
  String get webDashboardDesc {
    return Intl.message(
      'Manage local web dashboards for the Core',
      name: 'webDashboardDesc',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard`
  String get webDashboardFlavor {
    return Intl.message(
      'Dashboard',
      name: 'webDashboardFlavor',
      desc: '',
      args: [],
    );
  }

  /// `Open dashboard`
  String get webDashboardOpen {
    return Intl.message(
      'Open dashboard',
      name: 'webDashboardOpen',
      desc: '',
      args: [],
    );
  }

  /// `Open in browser`
  String get webDashboardOpenInBrowser {
    return Intl.message(
      'Open in browser',
      name: 'webDashboardOpenInBrowser',
      desc: '',
      args: [],
    );
  }

  /// `Reload`
  String get webDashboardReload {
    return Intl.message(
      'Reload',
      name: 'webDashboardReload',
      desc: '',
      args: [],
    );
  }

  /// `Install dashboard`
  String get webDashboardInstall {
    return Intl.message(
      'Install dashboard',
      name: 'webDashboardInstall',
      desc: '',
      args: [],
    );
  }

  /// `Not installed`
  String get webDashboardNotInstalled {
    return Intl.message(
      'Not installed',
      name: 'webDashboardNotInstalled',
      desc: '',
      args: [],
    );
  }

  /// `The selected dashboard is downloaded on first open. Downloads use a pinned release and SHA-256 verification.`
  String get webDashboardInstallTip {
    return Intl.message(
      'The selected dashboard is downloaded on first open. Downloads use a pinned release and SHA-256 verification.',
      name: 'webDashboardInstallTip',
      desc: '',
      args: [],
    );
  }

  /// `Access is local and protected by a secret. Opening a dashboard does not change your saved external controller settings.`
  String get webDashboardAccessTip {
    return Intl.message(
      'Access is local and protected by a secret. Opening a dashboard does not change your saved external controller settings.',
      name: 'webDashboardAccessTip',
      desc: '',
      args: [],
    );
  }

  /// `No dashboard session`
  String get webDashboardNoAccess {
    return Intl.message(
      'No dashboard session',
      name: 'webDashboardNoAccess',
      desc: '',
      args: [],
    );
  }

  /// `Access ends when the dashboard closes`
  String get webDashboardEmbeddedAccess {
    return Intl.message(
      'Access ends when the dashboard closes',
      name: 'webDashboardEmbeddedAccess',
      desc: '',
      args: [],
    );
  }

  /// `Browser access stays active until you end it or quit ReClash`
  String get webDashboardBrowserAccess {
    return Intl.message(
      'Browser access stays active until you end it or quit ReClash',
      name: 'webDashboardBrowserAccess',
      desc: '',
      args: [],
    );
  }

  /// `End dashboard access`
  String get webDashboardEndAccess {
    return Intl.message(
      'End dashboard access',
      name: 'webDashboardEndAccess',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard access ended`
  String get webDashboardAccessEnded {
    return Intl.message(
      'Dashboard access ended',
      name: 'webDashboardAccessEnded',
      desc: '',
      args: [],
    );
  }

  /// `Downloading dashboard`
  String get webDashboardDownloading {
    return Intl.message(
      'Downloading dashboard',
      name: 'webDashboardDownloading',
      desc: '',
      args: [],
    );
  }

  /// `Verifying download`
  String get webDashboardVerifying {
    return Intl.message(
      'Verifying download',
      name: 'webDashboardVerifying',
      desc: '',
      args: [],
    );
  }

  /// `Extracting dashboard`
  String get webDashboardExtracting {
    return Intl.message(
      'Extracting dashboard',
      name: 'webDashboardExtracting',
      desc: '',
      args: [],
    );
  }

  /// `Could not download the dashboard. Try again.`
  String get webDashboardDownloadFailed {
    return Intl.message(
      'Could not download the dashboard. Try again.',
      name: 'webDashboardDownloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `The dashboard checksum does not match the pinned release.`
  String get webDashboardChecksumFailed {
    return Intl.message(
      'The dashboard checksum does not match the pinned release.',
      name: 'webDashboardChecksumFailed',
      desc: '',
      args: [],
    );
  }

  /// `The download is not a valid dashboard archive.`
  String get webDashboardArchiveFailed {
    return Intl.message(
      'The download is not a valid dashboard archive.',
      name: 'webDashboardArchiveFailed',
      desc: '',
      args: [],
    );
  }

  /// `The dashboard archive exceeds the allowed size.`
  String get webDashboardTooLarge {
    return Intl.message(
      'The dashboard archive exceeds the allowed size.',
      name: 'webDashboardTooLarge',
      desc: '',
      args: [],
    );
  }

  /// `Could not safely read or replace the dashboard files.`
  String get webDashboardStorageFailed {
    return Intl.message(
      'Could not safely read or replace the dashboard files.',
      name: 'webDashboardStorageFailed',
      desc: '',
      args: [],
    );
  }

  /// `Another dashboard operation is in progress.`
  String get webDashboardBusy {
    return Intl.message(
      'Another dashboard operation is in progress.',
      name: 'webDashboardBusy',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard access is disabled in Safe Mode.`
  String get webDashboardSafeMode {
    return Intl.message(
      'Dashboard access is disabled in Safe Mode.',
      name: 'webDashboardSafeMode',
      desc: '',
      args: [],
    );
  }

  /// `Select a profile before opening the dashboard.`
  String get webDashboardNoProfile {
    return Intl.message(
      'Select a profile before opening the dashboard.',
      name: 'webDashboardNoProfile',
      desc: '',
      args: [],
    );
  }

  /// `The Core is not ready.`
  String get webDashboardCoreUnavailable {
    return Intl.message(
      'The Core is not ready.',
      name: 'webDashboardCoreUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Could not apply the dashboard configuration.`
  String get webDashboardApplyFailed {
    return Intl.message(
      'Could not apply the dashboard configuration.',
      name: 'webDashboardApplyFailed',
      desc: '',
      args: [],
    );
  }

  /// `The Core is not serving this dashboard.`
  String get webDashboardUnreachable {
    return Intl.message(
      'The Core is not serving this dashboard.',
      name: 'webDashboardUnreachable',
      desc: '',
      args: [],
    );
  }

  /// `The Core rejected the dashboard credentials. Reopen the dashboard.`
  String get webDashboardAuthenticationFailed {
    return Intl.message(
      'The Core rejected the dashboard credentials. Reopen the dashboard.',
      name: 'webDashboardAuthenticationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Could not open the browser.`
  String get webDashboardLaunchFailed {
    return Intl.message(
      'Could not open the browser.',
      name: 'webDashboardLaunchFailed',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard operation cancelled.`
  String get webDashboardCancelled {
    return Intl.message(
      'Dashboard operation cancelled.',
      name: 'webDashboardCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get webDashboardVersion {
    return Intl.message(
      'Version',
      name: 'webDashboardVersion',
      desc: '',
      args: [],
    );
  }

  /// `Access`
  String get webDashboardAccess {
    return Intl.message(
      'Access',
      name: 'webDashboardAccess',
      desc: '',
      args: [],
    );
  }

  /// `Off`
  String get webDashboardAccessOff {
    return Intl.message(
      'Off',
      name: 'webDashboardAccessOff',
      desc: '',
      args: [],
    );
  }

  /// `In the app`
  String get webDashboardAccessInApp {
    return Intl.message(
      'In the app',
      name: 'webDashboardAccessInApp',
      desc: '',
      args: [],
    );
  }

  /// `In the browser`
  String get webDashboardAccessInBrowser {
    return Intl.message(
      'In the browser',
      name: 'webDashboardAccessInBrowser',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'kk'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'tk'),
      Locale.fromSubtags(languageCode: 'uz'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
