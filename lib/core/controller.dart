import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/core/core.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/core/spill.dart';
import 'package:reclash/core/desktop/privilege.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/protocol/registry.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:path/path.dart';

class CoreController {
  static CoreController? _instance;
  late CoreHandlerInterface _interface;

  CoreController._internal() {
    if (system.isAndroid) {
      _interface = coreLib!;
    } else {
      _interface = coreService!;
    }
  }

  @visibleForTesting
  CoreController.test(this._interface) {
    _instance = this;
  }

  @visibleForTesting
  CoreController.scoped(this._interface);

  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  factory CoreController() {
    _instance ??= CoreController._internal();
    return _instance!;
  }

  Future<CoreLifecycleResult> start() => _interface.start();

  Future<CoreLifecycleResult> restart() => _interface.restart();

  Future<CoreLifecycleResult> stop() => _interface.stop();

  Future<CoreLifecycleResult> close() => _interface.close();

  CoreProcessOwner? get processOwner => _interface.processOwner;

  void configurePrivilege({
    required bool tunEnabled,
    bool allowPrompt = false,
  }) {
    _interface.configurePrivilege(
      tunEnabled: tunEnabled,
      allowPrompt: allowPrompt,
    );
  }

  void revokePrivilegePrompt() => _interface.revokePrivilegePrompt();

  Future<DesktopPrivilegeDecision> preparePrivilege({
    required bool tunEnabled,
    bool allowPrompt = false,
  }) => _interface.preparePrivilege(
    tunEnabled: tunEnabled,
    allowPrompt: allowPrompt,
  );

  static Future<void> ensureHomeDir() async {
    final homePath = await appPath.homeDirPath;
    final homeDir = Directory(homePath);
    final isExists = await homeDir.exists();
    if (!isExists) {
      await homeDir.create(recursive: true);
    }
  }

  static Future<void> initGeo() async {
    final homePath = await appPath.homeDirPath;
    const geoFileNameList = [MMDB, GEOIP, GEOSITE, ASN];
    try {
      for (final geoFileName in geoFileNameList) {
        final geoFile = File(join(homePath, geoFileName));
        final isExists = await geoFile.exists();
        if (isExists) {
          continue;
        }
        final data = await rootBundle.load('assets/data/$geoFileName');
        final List<int> bytes = data.buffer.asUint8List();
        await geoFile.writeAsBytes(bytes, flush: true);
      }
    } catch (e) {
      commonPrint.log(
        'Failed to initialize geo data: $e',
        logLevel: LogLevel.error,
      );
      rethrow;
    }
  }

  Future<bool> init(int version) async {
    await ensureHomeDir();
    await initGeo();
    final homeDirPath = await appPath.homeDirPath;
    return _interface.init(InitParams(homeDir: homeDirPath, version: version));
  }

  FutureOr<bool> get isInit => _interface.isInit;

  Future<CoreInfo?> getCoreInfo() => _interface.getCoreInfo();

  Future<String> getAppliedConfigContent() async {
    return File(await appPath.configFilePath).readAsString();
  }

  Future<String> validateConfig(String path) async {
    return _withCoreInput(path, _interface.validateConfig);
  }

  Future<T> _withCoreInput<T>(
    String path,
    Future<T> Function(String) read,
  ) async {
    if (!isPrivilegedCoreOwner(processOwner)) return read(path);
    final home = await Directory(
      await appPath.homeDirPath,
    ).resolveSymbolicLinks();
    final source = File(path);
    final canonical = await source.resolveSymbolicLinks();
    if (isWithin(home, canonical)) return read(canonical);
    final input = await source.copy(await appPath.tempFilePath);
    try {
      return await read(await input.resolveSymbolicLinks());
    } finally {
      await input.safeDelete();
    }
  }

  Future<Uint8List> decryptProfilePayload(
    Uint8List bytes,
    String ageSecretKey,
  ) async {
    const prefix = '-----BEGIN AGE ENCRYPTED FILE-----';
    if (bytes.length < prefix.length ||
        String.fromCharCodes(bytes.take(prefix.length)) != prefix) {
      return bytes;
    }
    if (ageSecretKey.isEmpty) {
      throw const AgeSecretKeyRequiredException();
    }
    final path = await appPath.tempFilePath;
    final file = File('$path.decrypt.${DateTime.now().microsecondsSinceEpoch}');
    await file.safeWriteAsBytes(bytes);
    try {
      final plain = Uint8List.fromList(
        utf8.encode(
          await _withCoreInput(
            file.path,
            (input) => _interface.decryptConfig(input, ageSecretKey),
          ),
        ),
      );
      if (plain.length > subscriptionPayloadLimit) {
        throw const SubscriptionException(SubscriptionFailure.oversized);
      }
      return plain;
    } finally {
      await file.safeDelete();
    }
  }

  /// An age-encrypted config is rewritten in place into its plaintext, and a
  /// share-link list into a config of its proxies.
  Future<String> validateProfile(
    String path, [
    String ageSecretKey = '',
  ]) async {
    final file = File(path);
    if (await file.isAgeEncrypted) {
      if (ageSecretKey.isEmpty) {
        throw const AgeSecretKeyRequiredException();
      }
      await file.safeWriteAsString(
        await _withCoreInput(
          path,
          (input) => _interface.decryptConfig(input, ageSecretKey),
        ),
      );
    }
    final message = await validateConfig(path);
    if (message.isEmpty) {
      return message;
    }
    final List<Map<String, dynamic>> proxies;
    try {
      proxies = await _withCoreInput(path, _interface.convertProxies);
    } on Exception {
      return message;
    }
    if (proxies.isEmpty) {
      return message;
    }
    await file.safeWriteAsString(await encodeYamlTask({'proxies': proxies}));
    return validateConfig(path);
  }

  Future<List<String>> validateProxies(List<Map<String, dynamic>> proxies) {
    if (proxies.isEmpty) {
      return Future.value(const []);
    }
    return _interface.validateProxies(proxies);
  }

  Future<List<String>> validateFilters(List<String> filters) {
    if (filters.isEmpty) {
      return Future.value(const []);
    }
    return _interface.validateFilters(filters);
  }

  Future<List<String>> encodeShareLinks(List<Map<String, dynamic>> proxies) {
    if (proxies.isEmpty) {
      return Future.value(const []);
    }
    return _interface.encodeShareLinks(proxies);
  }

  Future<List<List<Map<String, dynamic>>>> decodeShareLinks(
    List<String> lines,
  ) {
    if (lines.isEmpty) {
      return Future.value(const []);
    }
    return _interface.decodeShareLinks(lines);
  }

  Future<String> validateConfigWithData(String data) async {
    final path = await appPath.tempFilePath;
    final file = File(path);
    await file.safeWriteAsString(data);
    try {
      return await validateConfig(path);
    } finally {
      await file.safeDelete();
    }
  }

  Future<String> updateConfig(UpdateParams updateParams) async {
    return _interface.updateConfig(updateParams);
  }

  Future<String> setupConfig({
    required SetupParams params,
    Future<void> Function()? preloadInvoke,
  }) async {
    if (preloadInvoke == null) {
      return _interface.setupConfig(params);
    }
    final (result, _) = await (
      _interface.setupConfig(params),
      preloadInvoke(),
    ).wait;
    return result;
  }

  Future<List<Group>> getProxiesGroups({
    required ProxiesSortType sortType,
    required DelayMap delayMap,
    required Map<String, String> selectedMap,
    required String defaultTestUrl,
    bool requireData = false,
  }) async {
    final proxiesData = await _interface.getProxies();
    if (requireData && proxiesData.all.isEmpty && proxiesData.proxies.isEmpty) {
      throw StateError('Core returned no proxy data');
    }
    return toGroupsTask(
      ComputeGroupsState(
        proxiesData: proxiesData,
        sortType: sortType,
        delayMap: delayMap,
        selectedMap: selectedMap,
        defaultTestUrl: defaultTestUrl,
      ),
    );
  }

  Future<ChangeProxyResult> changeProxy(ChangeProxyParams changeProxyParams) {
    return _interface.changeProxy(changeProxyParams);
  }

  Future<RouteSnapshot?> watchRoute(bool watch) {
    return _interface.watchRoute(watch);
  }

  Future<RcxStatus> rcxSetPolicy(RcxUserLayer layer) {
    return _interface.rcxSetPolicy(layer);
  }

  Future<RcxStatus> rcxStatus() {
    return _interface.rcxStatus();
  }

  Future<RcxExplanation> rcxExplain(String group) {
    return _interface.rcxExplain(group);
  }

  Future<List<RcxJournalEntry>> rcxJournal({String? group, int limit = 0}) {
    return _interface.rcxJournal(group: group, limit: limit);
  }

  Future<RcxDecision> rcxAction({
    required String group,
    required RcxAction action,
    String? node,
    bool here = false,
  }) {
    return _interface.rcxAction(
      group: group,
      action: action,
      node: node,
      here: here,
    );
  }

  Future<bool> rcxHints(Map<String, Object?> hints) {
    return _interface.rcxHints(hints);
  }

  Future<List<RcxProfileInfo>> rcxProfiles() {
    return _interface.rcxProfiles();
  }

  Future<RcxStudioResult> rcxStudio(Map<String, Object?> request) {
    return _interface.rcxStudio(request);
  }

  Future<List<TrackerInfo>> getConnections() async {
    return _interface.getConnections();
  }

  Future<int> getConnectionCount() async {
    return _interface.getConnectionCount();
  }

  Future<void> closeConnection(String id) async {
    await _interface.closeConnection(id);
  }

  Future<void> closeConnections() async {
    await _interface.closeConnections();
  }

  Future<void> resetConnections() async {
    await _interface.resetConnections();
  }

  Future<List<ExternalProvider>> getExternalProviders() async {
    return _interface.getExternalProviders();
  }

  Future<ExternalProvider?> getExternalProvider(
    String externalProviderName,
  ) async {
    return _interface.getExternalProvider(externalProviderName);
  }

  Future<String> updateGeoData(String type) {
    return _interface.updateGeoData(type);
  }

  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) {
    return _interface.sideLoadExternalProvider(
      providerName: providerName,
      data: data,
    );
  }

  Future<String> dumpRuleSet(String path) {
    return _withCoreInput(path, _interface.dumpRuleSet);
  }

  Future<RuleSetInfo> compileRuleSet(
    String name, {
    String url = '',
    Map<String, String> headers = const {},
  }) {
    return _interface.compileRuleSet(name, url: url, headers: headers);
  }

  Future<SubscriptionResponse> fetchSubscription(
    String requestId,
    Uri url, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 20),
    int maxBytes = subscriptionWireLimit,
    bool protected = false,
    bool bypass = false,
  }) => _interface.fetchSubscription(
    requestId,
    url,
    headers: headers,
    timeout: timeout,
    maxBytes: maxBytes,
    protected: protected,
    bypass: bypass,
  );

  Future<bool> cancelSubscriptionFetch(String requestId) =>
      _interface.cancelSubscriptionFetch(requestId);

  Future<String> updateExternalProvider({required String providerName}) async {
    return _interface.updateExternalProvider(providerName);
  }

  Future<bool> startListener() async {
    return _interface.startListener();
  }

  Future<bool> setOnDemandPaused(bool paused, {required bool fullStop}) =>
      _interface.setOnDemandPaused(paused, fullStop: fullStop);

  Future<bool> stopListener() async {
    return _interface.stopListener();
  }

  Future<Delay?> getDelay(String url, String proxyName) async {
    return _interface.asyncTestDelay(url, proxyName);
  }

  Future<ProbeResult?> probe(ProbeParams params) => _interface.probe(params);

  Future<OutboundIpResult?> outboundIp(OutboundIpParams params) =>
      _interface.outboundIp(params);

  Future<List<ServiceCheckItem>> serviceCheck(ServiceCheckParams params) =>
      _interface.serviceCheck(params);

  Future<Map<String, dynamic>> getConfig(int id) async {
    return _readConfig(await appPath.getProfilePath(id.toString()));
  }

  Future<Map<String, dynamic>> _readConfig(String path) async {
    final data = Map<String, dynamic>.from(await _interface.getConfig(path));
    data['rules'] = data['rule'];
    data.remove('rule');
    return data;
  }

  Future<Map<String, dynamic>> getProfileOutbounds(int id) async {
    return _interface.getProfileOutbounds(
      await appPath.getProfilePath(id.toString()),
    );
  }

  Future<String> buildProfile(SetupBase base) async {
    return readSpilledText(await _interface.buildProfile(base));
  }

  Future<({ProfileBase base, String path})> getProfileBase(int id) async {
    final path = await appPath.getProfilePath(id.toString());
    final base = await _interface.getProfileBase(path);
    final config = Map<String, dynamic>.from(base.config)..remove('rule');
    return (base: base.copyWith(config: config), path: path);
  }

  Future<Traffic> getTraffic(bool onlyStatisticsProxy) async {
    return _interface.getTraffic(onlyStatisticsProxy);
  }

  Future<Traffic> getTotalTraffic(bool onlyStatisticsProxy) async {
    return _interface.getTotalTraffic(onlyStatisticsProxy);
  }

  Future<CoreMemoryStats?> getMemoryStats() async {
    return _interface.getMemoryStats();
  }

  void resetTraffic() {
    _interface.resetTraffic();
  }

  void startLog() {
    _interface.startLog();
  }

  void stopLog() {
    _interface.stopLog();
  }

  Future<void> requestGc() async {
    await _interface.forceGc();
  }

  Future<void> crash() async {
    await _interface.crash();
  }

  Future<String> clearEffect(int profileId) async {
    return _interface.clearEffect(profileId);
  }
}

final coreController = CoreController();
