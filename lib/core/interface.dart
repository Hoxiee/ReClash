import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/models/speed_test.dart';
import 'package:reclash/subscriptions/metadata/provider_policy.dart';
import 'package:reclash/subscriptions/transport/header_policy.dart';
import 'package:reclash/subscriptions/protocol/registry.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

import 'desktop/model.dart';
import 'desktop/privilege.dart';
import 'method.dart';

mixin CoreInterface {
  CoreProcessOwner? get processOwner => null;

  int? get processId => null;

  void configurePrivilege({
    required bool tunEnabled,
    bool allowPrompt = false,
  }) {}

  void revokePrivilegePrompt() {}

  void allowPrivilegeInstall() {}

  void suspendPrivilege() {}

  Future<DesktopPrivilegeSetup> inspectPrivilege({
    required bool tunEnabled,
  }) async => DesktopPrivilegeSetup.notRequired;

  Future<DesktopPrivilegeDecision> preparePrivilege({
    required bool tunEnabled,
    bool allowPrompt = false,
  }) async => DesktopPrivilegeDecision.notRequired;

  Future<CoreLifecycleResult> start();

  Future<CoreLifecycleResult> restart();

  Future<CoreLifecycleResult> stop();

  Future<CoreLifecycleResult> close();

  Future<bool> init(InitParams params);

  Future<bool> get isInit;

  Future<CoreInfo?> getCoreInfo();

  Future<bool> forceGc();

  Future<String> validateConfig(String path);

  Future<ProviderGlobalNodes> getProviderGlobalNodes(String path);

  Future<String> decryptConfig(String path, String ageSecretKey);

  Future<List<String>> validateProxies(List<Map<String, dynamic>> proxies);

  Future<List<String>> validateFilters(List<String> filters);

  Future<List<Map<String, dynamic>>> convertProxies(String path);

  Future<List<String>> encodeShareLinks(List<Map<String, dynamic>> proxies);

  Future<List<List<Map<String, dynamic>>>> decodeShareLinks(List<String> lines);

  Future<Map<String, dynamic>> getConfig(String path);

  Future<ProfileBase> getProfileBase(String path);

  Future<Map<String, dynamic>> getProfileOutbounds(String path);

  Future<Map<String, dynamic>?> getProxyDefinition(String name);

  Future<String> buildProfile(SetupBase base);

  Future<String> dumpRuleSet(String path);

  Future<RuleSetInfo> compileRuleSet(
    String name, {
    String url = '',
    Map<String, String> headers = const {},
  });

  Future<SubscriptionResponse> fetchSubscription(
    String requestId,
    Uri url, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 20),
    int maxBytes = subscriptionWireLimit,
    bool protected = false,
    bool bypass = false,
  });

  Future<bool> cancelSubscriptionFetch(String requestId);

  Future<Delay?> asyncTestDelay(String url, String proxyName, Duration timeout);

  Future<ProbeResult?> probe(ProbeParams params);

  Future<OutboundIpResult?> outboundIp(OutboundIpParams params);

  Future<bool> startSpeedTest(
    SpeedTestSettings settings, {
    required String requestId,
    required String proxyName,
    required bool direct,
  });

  Future<Map<String, dynamic>?> getSpeedTest(String requestId);

  Future<bool> cancelSpeedTest(String requestId);

  Future<List<SpeedTestServer>> speedTestServers({
    required String requestId,
    required String proxyName,
    required bool direct,
    required bool useSystemDns,
    String search = '',
  });

  Future<List<ServiceCheckItem>> serviceCheck(ServiceCheckParams params);

  Future<ClockSkewResult?> clockSkew(ClockSkewParams params);

  Future<ReachResult?> reach(ReachParams params);

  Future<DialDirectResult?> dialDirect(DialDirectParams params);

  Future<String> updateConfig(UpdateParams updateParams);

  Future<String> setupConfig(SetupParams setupParams);

  Future<ProxiesData> getProxies();

  Future<ChangeProxyResult> changeProxy(ChangeProxyParams changeProxyParams);

  Future<RouteSnapshot?> watchRoute(bool watch);

  Future<RouteCheck?> checkRoutes(CheckRoutesParams params);
  Future<RcxStatus> rcxSetPolicy(RcxUserLayer layer);

  Future<RcxStatus> rcxStatus();

  Future<RcxExplanation> rcxExplain(String group);

  Future<List<RcxJournalEntry>> rcxJournal({
    int cursor = 0,
    String? group,
    int limit = 0,
  });

  Future<RcxDecision> rcxAction({
    required String group,
    required RcxAction action,
    String? node,
    bool here = false,
  });

  Future<bool> rcxHints(Map<String, Object?> hints);

  Future<List<RcxProfileInfo>> rcxProfiles();

  Future<RcxStudioResult> rcxStudio(Map<String, Object?> request);

  Future<bool> startListener();

  Future<bool> stopListener();

  Future<bool> setOnDemandPaused(bool paused, {required bool fullStop});

  Future<void> setTelegramProxy(
    TelegramProxyProps props, {
    required String notificationTitle,
    required String notificationStop,
  });

  Future<TelegramProxyState?> getTelegramProxy();

  Future<String> telegramProxySelfTest(int dc);

  Future<List<ExternalProvider>> getExternalProviders();

  Future<ExternalProvider?> getExternalProvider(String externalProviderName);

  Future<String> updateGeoData(String type);

  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  });

  Future<String> updateExternalProvider(String providerName);

  FutureOr<Traffic> getTraffic(bool onlyStatisticsProxy);

  FutureOr<Traffic> getTotalTraffic(bool onlyStatisticsProxy);

  FutureOr<CoreMemoryStats?> getMemoryStats();

  FutureOr<void> resetTraffic();

  FutureOr<void> startLog();

  FutureOr<void> stopLog();

  Future<bool> crash();

  FutureOr<List<TrackerInfo>> getConnections();

  FutureOr<int> getConnectionCount();

  FutureOr<bool> closeConnection(String id);

  FutureOr<String> clearEffect(int profileId);

  FutureOr<bool> closeConnections();

  FutureOr<bool> resetConnections();

  FutureOr<bool> clearDnsCache();
}

Map<String, Object?> telegramProxyArguments(TelegramProxyProps props) => {
  'enabled': props.enabled,
  'port': props.port,
  'secret': props.secret,
  'endpoints': props.endpoints,
  'outbound': props.outbound,
};

abstract class CoreHandlerInterface with CoreInterface {
  Future<T?> _invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    return await handleWatch(
      onStart: () {
        commonPrint.log(
          'Invoke method ${method.name} ${DateTime.now()} $arguments',
        );
      },
      function: () async {
        return invokeMethod<T>(
          method: method,
          arguments: arguments,
          timeout: timeout,
        );
      },
      onEnd: (result, elapsedMilliseconds) {
        commonPrint.log(
          'Invoke method ${method.name} completed in ${elapsedMilliseconds}ms',
        );
      },
    );
  }

  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  });

  Future<String> _invokeMessage({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    final message = await _invokeMethod<String>(
      method: method,
      arguments: arguments,
      timeout: timeout,
    );
    if (message == null) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${method.name}',
      );
    }
    return message;
  }

  @override
  Future<bool> init(InitParams params) async {
    return await _invokeMethod<bool>(
          method: CoreMethod.initClash,
          arguments: params.toJson(),
        ) ??
        false;
  }

  @override
  Future<bool> get isInit async {
    return await _invokeMethod<bool>(method: CoreMethod.getIsInit) ?? false;
  }

  @override
  Future<CoreInfo?> getCoreInfo() async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getCoreInfo,
    );
    return data == null ? null : CoreInfo.fromJson(data);
  }

  @override
  Future<bool> forceGc() async {
    return await _invokeMethod<bool>(method: CoreMethod.forceGc) ?? false;
  }

  @override
  Future<String> validateConfig(String path) async {
    return _invokeMessage(method: CoreMethod.validateConfig, arguments: path);
  }

  @override
  Future<ProviderGlobalNodes> getProviderGlobalNodes(String path) async {
    final result = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getProviderGlobalNodes,
      arguments: path,
    );
    if (result == null) {
      throw const CoreMethodException(
        code: 'empty_result',
        message: 'Core returned no GLOBAL nodes',
      );
    }
    return ProviderGlobalNodes.fromJson(result);
  }

  @override
  Future<String> decryptConfig(String path, String ageSecretKey) async {
    return _invokeMessage(
      method: CoreMethod.decryptConfig,
      arguments: {'path': path, 'age-secret-key': ageSecretKey},
    );
  }

  @override
  Future<List<String>> validateProxies(
    List<Map<String, dynamic>> proxies,
  ) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.validateProxies,
      arguments: proxies,
    );
    if (data == null || data.length != proxies.length) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${CoreMethod.validateProxies.name}',
      );
    }
    return data.map((item) => item?.toString() ?? '').toList();
  }

  @override
  Future<List<String>> validateFilters(List<String> filters) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.validateFilters,
      arguments: filters,
    );
    if (data == null || data.length != filters.length) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${CoreMethod.validateFilters.name}',
      );
    }
    return data.map((item) => item?.toString() ?? '').toList();
  }

  @override
  Future<List<Map<String, dynamic>>> convertProxies(String path) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.convertProxies,
      arguments: path,
    );
    return [
      for (final item in data ?? const [])
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }

  @override
  Future<List<String>> encodeShareLinks(
    List<Map<String, dynamic>> proxies,
  ) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.encodeShareLinks,
      arguments: proxies,
    );
    if (data == null || data.length != proxies.length) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${CoreMethod.encodeShareLinks.name}',
      );
    }
    return data.map((item) => item?.toString() ?? '').toList();
  }

  @override
  Future<List<List<Map<String, dynamic>>>> decodeShareLinks(
    List<String> lines,
  ) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.decodeShareLinks,
      arguments: lines,
    );
    if (data == null || data.length != lines.length) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${CoreMethod.decodeShareLinks.name}',
      );
    }
    return [
      for (final line in data)
        [
          for (final item in line is List ? line : const [])
            if (item is Map) Map<String, dynamic>.from(item),
        ],
    ];
  }

  @override
  Future<String> updateConfig(UpdateParams updateParams) async {
    return _invokeMessage(
      method: CoreMethod.updateConfig,
      arguments: updateParams.toJson(),
    );
  }

  @override
  Future<Map<String, dynamic>> getConfig(String path) async {
    final result = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getConfig,
      arguments: path,
    );
    if (result == null) {
      throw const CoreMethodException(
        code: 'empty_result',
        message: 'Core returned an empty config result',
      );
    }
    return result;
  }

  @override
  Future<ProfileBase> getProfileBase(String path) async {
    final result = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getProfileBase,
      arguments: path,
    );
    if (result == null) {
      throw const CoreMethodException(
        code: 'empty_result',
        message: 'Core returned an empty profile base',
      );
    }
    return ProfileBase.fromJson(result);
  }

  @override
  Future<Map<String, dynamic>> getProfileOutbounds(String path) async {
    final result = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getProfileOutbounds,
      arguments: path,
    );
    if (result == null) {
      throw const CoreMethodException(
        code: 'empty_result',
        message: 'Core returned no outbounds',
      );
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>?> getProxyDefinition(String name) {
    return _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getProxyDefinition,
      arguments: name,
    );
  }

  @override
  Future<String> buildProfile(SetupBase base) async {
    final result = await _invokeMethod<String>(
      method: CoreMethod.buildProfile,
      arguments: base.toJson(),
    );
    if (result == null || result.isEmpty) {
      throw const CoreMethodException(
        code: 'empty_result',
        message: 'Core returned no built profile',
      );
    }
    return result;
  }

  @override
  Future<String> setupConfig(SetupParams setupParams) async {
    return _invokeMessage(
      method: CoreMethod.setupConfig,
      arguments: setupParams.toJson(),
    );
  }

  @override
  Future<String> dumpRuleSet(String path) async {
    return _invokeMessage(method: CoreMethod.dumpRuleSet, arguments: path);
  }

  @override
  Future<RuleSetInfo> compileRuleSet(
    String name, {
    String url = '',
    Map<String, String> headers = const {},
  }) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.compileRuleSet,
      arguments: {
        'name': name,
        'url': url,
        'headers': validateResourceHeaders(headers),
      },
    );
    if (data == null) {
      throw const CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer compileRuleSet',
      );
    }
    return (
      behavior: RuleProviderBehavior.values.byName(data['behavior'] as String),
      format: RuleProviderFormat.values.byName(data['format'] as String),
    );
  }

  @override
  Future<SubscriptionResponse> fetchSubscription(
    String requestId,
    Uri url, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 20),
    int maxBytes = subscriptionWireLimit,
    bool protected = false,
    bool bypass = false,
  }) async {
    final validated = validateSubscriptionHeaders(headers, allowManaged: true);
    final result = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.fetchSubscription,
      arguments: {
        'requestId': requestId,
        'url': url.toString(),
        'headers': validated,
        'timeoutMillis': timeout.inMilliseconds,
        'maxBytes': maxBytes,
        'protected': protected,
        'bypass': bypass,
      },
    );
    if (result == null) {
      throw const CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer fetchSubscription',
      );
    }
    final rawHeaders = result['headers'] as Map? ?? const {};
    return SubscriptionResponse(
      status: result['status'] as int,
      headers: {
        for (final MapEntry(:key, :value) in Map<String, dynamic>.from(
          rawHeaders,
        ).entries)
          key.toString().toLowerCase(): List<String>.from(value as List),
      },
      bytes: Uint8List.fromList(base64.decode(result['bodyBase64'] as String)),
      uri: Uri.parse(result['finalUrl'] as String),
      protected: result['protected'] as bool? ?? false,
      bypassed: result['bypassed'] as bool? ?? false,
    );
  }

  @override
  Future<bool> cancelSubscriptionFetch(String requestId) async =>
      await _invokeMethod<bool>(
        method: CoreMethod.cancelSubscriptionFetch,
        arguments: {'requestId': requestId},
      ) ??
      false;

  @override
  Future<bool> crash() async {
    return await _invokeMethod<bool>(method: CoreMethod.crash) ?? false;
  }

  @override
  Future<ProxiesData> getProxies() async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getProxies,
    );
    return data != null
        ? ProxiesData.fromJson(data)
        : const ProxiesData(proxies: {}, all: []);
  }

  @override
  Future<ChangeProxyResult> changeProxy(
    ChangeProxyParams changeProxyParams,
  ) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.changeProxy,
      arguments: changeProxyParams.toJson(),
    );
    if (data == null) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${CoreMethod.changeProxy.name}',
      );
    }
    return ChangeProxyResult.fromJson(data);
  }

  Future<Map<String, dynamic>> _invokeRcx(
    CoreMethod method, [
    Object? arguments,
  ]) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: method,
      arguments: arguments,
    );
    if (data == null) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${method.name}',
      );
    }
    return data;
  }

  @override
  Future<RcxStatus> rcxSetPolicy(RcxUserLayer layer) async {
    return RcxStatus.fromJson(
      await _invokeRcx(CoreMethod.rcxSetPolicy, layer.toJson()),
    );
  }

  @override
  Future<RcxStatus> rcxStatus() async {
    return RcxStatus.fromJson(await _invokeRcx(CoreMethod.rcxStatus));
  }

  @override
  Future<RcxExplanation> rcxExplain(String group) async {
    return RcxExplanation.fromJson(
      await _invokeRcx(CoreMethod.rcxExplain, group),
    );
  }

  @override
  Future<List<RcxJournalEntry>> rcxJournal({
    int cursor = 0,
    String? group,
    int limit = 0,
  }) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.rcxJournal,
      arguments: {'cursor': cursor, 'group': ?group, 'limit': limit},
    );
    return [
      for (final item in data ?? const [])
        RcxJournalEntry.fromJson(Map<String, Object?>.from(item as Map)),
    ];
  }

  @override
  Future<RcxDecision> rcxAction({
    required String group,
    required RcxAction action,
    String? node,
    bool here = false,
  }) async {
    final data = await _invokeRcx(CoreMethod.rcxAction, {
      'group': group,
      'action': action.name,
      'node': ?node,
      'here': here,
    });
    return RcxDecision.fromJson(
      Map<String, Object?>.from(data['decision'] as Map),
    );
  }

  @override
  Future<bool> rcxHints(Map<String, Object?> hints) async {
    return await _invokeMethod<bool>(
          method: CoreMethod.rcxHints,
          arguments: hints,
        ) ??
        false;
  }

  @override
  Future<List<RcxProfileInfo>> rcxProfiles() async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.rcxProfiles,
    );
    return [
      for (final item in data ?? const [])
        RcxProfileInfo.fromJson(Map<String, Object?>.from(item as Map)),
    ];
  }

  @override
  Future<RcxStudioResult> rcxStudio(Map<String, Object?> request) async {
    return RcxStudioResult.fromJson(
      await _invokeRcx(CoreMethod.rcxStudio, request),
    );
  }

  @override
  Future<RouteSnapshot?> watchRoute(bool watch) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.watchRoute,
      arguments: watch,
    );
    return data == null ? null : RouteSnapshot.fromJson(data);
  }

  @override
  Future<RouteCheck?> checkRoutes(CheckRoutesParams params) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.checkRoutes,
      arguments: params.toJson(),
      timeout: coreGuardFor(probeTimeoutDuration.inMilliseconds),
    );
    return data == null ? null : RouteCheck.fromJson(data);
  }

  @override
  Future<List<ExternalProvider>> getExternalProviders() async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.getExternalProviders,
    );
    return data
            ?.whereType<Map>()
            .map(
              (item) =>
                  ExternalProvider.fromJson(Map<String, Object?>.from(item)),
            )
            .toList() ??
        [];
  }

  @override
  Future<ExternalProvider?> getExternalProvider(
    String externalProviderName,
  ) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getExternalProvider,
      arguments: externalProviderName,
    );
    return data == null ? null : ExternalProvider.fromJson(data);
  }

  @override
  Future<String> updateGeoData(String type) async {
    return _invokeMessage(method: CoreMethod.updateGeoData, arguments: type);
  }

  @override
  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  }) async {
    return _invokeMessage(
      method: CoreMethod.sideLoadExternalProvider,
      arguments: {'providerName': providerName, 'data': data},
    );
  }

  @override
  Future<String> updateExternalProvider(String providerName) async {
    return _invokeMessage(
      method: CoreMethod.updateExternalProvider,
      arguments: providerName,
    );
  }

  @override
  Future<List<TrackerInfo>> getConnections() async {
    final data = await _invokeMethod<Object>(method: CoreMethod.getConnections);
    return data is List<TrackerInfo> ? data : trackerInfosOf(data);
  }

  @override
  Future<int> getConnectionCount() async {
    return await _invokeMethod<int>(method: CoreMethod.getConnectionCount) ?? 0;
  }

  @override
  Future<bool> closeConnections() async {
    return await _invokeMethod<bool>(method: CoreMethod.closeConnections) ??
        false;
  }

  @override
  Future<bool> resetConnections() async {
    return await _invokeMethod<bool>(method: CoreMethod.resetConnections) ??
        false;
  }

  @override
  Future<bool> clearDnsCache() async {
    return await _invokeMethod<bool>(method: CoreMethod.clearDnsCache) ?? false;
  }

  @override
  Future<bool> closeConnection(String id) async {
    return await _invokeMethod<bool>(
          method: CoreMethod.closeConnection,
          arguments: id,
        ) ??
        false;
  }

  @override
  Future<Traffic> getTotalTraffic(bool onlyStatisticsProxy) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getTotalTraffic,
      arguments: onlyStatisticsProxy,
    );
    return data == null ? const Traffic() : Traffic.fromJson(data);
  }

  @override
  Future<Traffic> getTraffic(bool onlyStatisticsProxy) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getTraffic,
      arguments: onlyStatisticsProxy,
    );
    return data == null ? const Traffic() : Traffic.fromJson(data);
  }

  @override
  Future<String> clearEffect(int profileId) async {
    return _invokeMessage(method: CoreMethod.clearEffect, arguments: profileId);
  }

  @override
  FutureOr<void> resetTraffic() => _invokeUnobserved(CoreMethod.resetTraffic);

  @override
  FutureOr<void> startLog() => _invokeUnobserved(CoreMethod.startLog);

  @override
  FutureOr<void> stopLog() => _invokeUnobserved(CoreMethod.stopLog);

  /// For calls whose callers never wait on them, so a Core that is gone or
  /// restarting cannot surface as an unhandled asynchronous error.
  Future<void> _invokeUnobserved(CoreMethod method) async {
    try {
      await _invokeMethod<Object?>(method: method);
    } catch (error) {
      commonPrint.log(
        '${method.name} failed: $error',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }

  @override
  Future<bool> startListener() async {
    return await _invokeMethod<bool>(method: CoreMethod.startListener) ?? false;
  }

  @override
  Future<bool> stopListener() async {
    return await _invokeMethod<bool>(method: CoreMethod.stopListener) ?? false;
  }

  @override
  Future<bool> setOnDemandPaused(bool paused, {required bool fullStop}) async =>
      await _invokeMethod<bool>(
        method: CoreMethod.setOnDemandPaused,
        arguments: {'paused': paused, 'fullStop': fullStop},
      ) ??
      false;

  @override
  Future<void> setTelegramProxy(
    TelegramProxyProps props, {
    required String notificationTitle,
    required String notificationStop,
  }) => _invokeMethod<Map<String, Object?>>(
    method: CoreMethod.setTelegramProxy,
    arguments: telegramProxyArguments(props),
  );

  @override
  Future<TelegramProxyState?> getTelegramProxy() async {
    final data = await _invokeMethod<Map<String, Object?>>(
      method: CoreMethod.getTelegramProxy,
    );
    return data == null ? null : TelegramProxyState.fromJson(data);
  }

  @override
  Future<String> telegramProxySelfTest(int dc) async =>
      await _invokeMethod<String>(
        method: CoreMethod.telegramProxySelfTest,
        arguments: dc,
      ) ??
      '';

  @override
  Future<Delay?> asyncTestDelay(
    String url,
    String proxyName,
    Duration timeout,
  ) async {
    final delayParams = {
      'proxy-name': proxyName,
      'timeout': timeout.inMilliseconds,
      'test-url': url,
    };
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.asyncTestDelay,
      arguments: delayParams,
      timeout: delayTestGuardDuration,
    );
    return data == null ? null : Delay.fromJson(data);
  }

  @override
  Future<ProbeResult?> probe(ProbeParams params) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.probe,
      arguments: params.toJson(),
      timeout: probeGuardDuration(params),
    );
    return data == null ? null : ProbeResult.fromJson(data);
  }

  @override
  Future<OutboundIpResult?> outboundIp(OutboundIpParams params) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.outboundIp,
      arguments: params.toJson(),
      timeout: coreGuardFor(params.timeout),
    );
    return data == null ? null : OutboundIpResult.fromJson(data);
  }

  @override
  Future<bool> startSpeedTest(
    SpeedTestSettings settings, {
    required String requestId,
    required String proxyName,
    required bool direct,
  }) async =>
      await _invokeMethod<bool>(
        method: CoreMethod.startSpeedTest,
        arguments: settings.toRequest(
          requestId: requestId,
          proxyName: proxyName,
          direct: direct,
        ),
        timeout: const Duration(seconds: 10),
      ) ??
      false;

  @override
  Future<Map<String, dynamic>?> getSpeedTest(String requestId) =>
      _invokeMethod<Map<String, dynamic>>(
        method: CoreMethod.getSpeedTest,
        arguments: {'requestId': requestId},
        timeout: const Duration(seconds: 5),
      );

  @override
  Future<bool> cancelSpeedTest(String requestId) async =>
      await _invokeMethod<bool>(
        method: CoreMethod.cancelSpeedTest,
        arguments: {'requestId': requestId},
        timeout: const Duration(seconds: 5),
      ) ??
      false;

  @override
  Future<List<SpeedTestServer>> speedTestServers({
    required String requestId,
    required String proxyName,
    required bool direct,
    required bool useSystemDns,
    String search = '',
  }) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.speedTestServers,
      arguments: {
        'requestId': requestId,
        'proxyName': proxyName,
        'direct': direct,
        'useSystemDns': useSystemDns,
        'search': search,
      },
      timeout: const Duration(seconds: 20),
    );
    if (data == null) throw StateError('Speed test server lookup failed');
    return data
        .map((item) => SpeedTestServer.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ClockSkewResult?> clockSkew(ClockSkewParams params) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.doctorClockSkew,
      arguments: params.toJson(),
      timeout: coreGuardFor(params.timeout),
    );
    return data == null ? null : ClockSkewResult.fromJson(data);
  }

  @override
  Future<ReachResult?> reach(ReachParams params) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.doctorReach,
      arguments: params.toJson(),
      timeout: coreGuardFor(params.timeout),
    );
    return data == null ? null : ReachResult.fromJson(data);
  }

  @override
  Future<DialDirectResult?> dialDirect(DialDirectParams params) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.doctorDialDirect,
      arguments: params.toJson(),
      timeout: coreGuardFor(params.timeout),
    );
    return data == null ? null : DialDirectResult.fromJson(data);
  }

  @override
  Future<List<ServiceCheckItem>> serviceCheck(ServiceCheckParams params) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.serviceCheck,
      arguments: params.toJson(),
      timeout: coreGuardFor(
        params.timeout,
        budgetFactor: serviceSweepBudgetFactor,
      ),
    );
    return data == null
        ? const []
        : data
              .map(
                (item) =>
                    ServiceCheckItem.fromJson(item as Map<String, dynamic>),
              )
              .toList();
  }

  @override
  Future<CoreMemoryStats?> getMemoryStats() async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getMemoryStats,
    );
    return data == null ? null : CoreMemoryStats.fromJson(data);
  }
}
