import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';

import 'desktop/model.dart';
import 'method.dart';

mixin CoreInterface {
  CoreProcessOwner? get processOwner => null;

  Future<CoreLifecycleResult> start();

  Future<CoreLifecycleResult> restart();

  Future<CoreLifecycleResult> stop();

  Future<CoreLifecycleResult> close();

  void setRecoveryHandler(
    Future<void> Function(bool Function() isCurrent)? handler,
  ) {}

  Future<bool> init(InitParams params);

  Future<bool> get isInit;

  Future<String> getVersion();

  Future<bool> forceGc();

  Future<String> validateConfig(String path);

  Future<ConfigInspection?> inspectConfig(String path);

  Future<Map<String, dynamic>> fetchSubscription({
    required String url,
    required Map<String, String> headers,
    required int timeoutMillis,
  });

  Future<Map<String, dynamic>> getConfig(String path);

  Future<Delay?> asyncTestDelay(String url, String proxyName);

  Future<String> updateConfig(UpdateParams updateParams);

  Future<String> setupConfig(SetupParams setupParams);

  Future<ProxiesData> getProxies();

  Future<String> changeProxy(ChangeProxyParams changeProxyParams);

  Future<bool> startListener();

  Future<bool> stopListener();

  Future<bool> pauseTun();

  Future<bool> resumeTun();

  Future<bool> setUiActive(bool active);

  Future<List<ExternalProvider>> getExternalProviders();

  Future<ExternalProvider?> getExternalProvider(String externalProviderName);

  Future<String> updateGeoData(String type);

  Future<String> sideLoadExternalProvider({
    required String providerName,
    required String data,
  });

  Future<String> updateExternalProvider(String providerName);

  Future<bool> configureSmartRouting(RcxConfigParams params);

  Future<RcxStatus?> smartRoutingStatus();

  Future<RcxReport?> smartRoutingReport();

  Future<bool> smartRoutingDeepScan();

  Future<OdometerSnapshot?> odometerReport();

  Future<bool> signalOdometer(OdometerSignal signal);

  Future<DoctorSnapshot> doctorSnapshot();

  Future<DoctorSnapshot> startDoctor(DoctorStartParams params);

  Future<DoctorSnapshot> cancelDoctor(DoctorCancelParams params);

  Future<DoctorSnapshot> flushDoctorDns(DoctorHealParams params);

  Future<DoctorReport> exportDoctorReport();

  Future<SubscriptionReport> exportSubscriptionReport();

  Future<bool> setSubscriptionMetadata(SubscriptionMetadata metadata);

  FutureOr<Traffic> getTraffic(bool onlyStatisticsProxy);

  FutureOr<Traffic> getTotalTraffic(bool onlyStatisticsProxy);

  FutureOr<CoreMemoryStats?> getMemoryStats();

  FutureOr<int> getGoroutineCount();

  FutureOr<void> resetTraffic();

  FutureOr<void> startLog();

  FutureOr<void> stopLog();

  Future<bool> crash();

  FutureOr<List<TrackerInfo>> getConnections();

  FutureOr<bool> closeConnection(String id);

  FutureOr<String> clearEffect(int profileId);

  FutureOr<bool> closeConnections();

  FutureOr<bool> resetConnections();
}

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
  Future<String> getVersion() async {
    return _invokeMessage(method: CoreMethod.getVersion);
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
  Future<ConfigInspection?> inspectConfig(String path) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.inspectConfig,
      arguments: path,
    );
    return data == null ? null : ConfigInspection.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> fetchSubscription({
    required String url,
    required Map<String, String> headers,
    required int timeoutMillis,
  }) async {
    final result = await invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.fetchSubscription,
      arguments: {
        'url': url,
        'headers': headers,
        'timeoutMillis': timeoutMillis,
      },
      timeout: Duration(milliseconds: timeoutMillis + 1000),
    );
    if (result == null) {
      throw const CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer subscription download',
      );
    }
    return result;
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
  Future<String> setupConfig(SetupParams setupParams) async {
    return _invokeMessage(
      method: CoreMethod.setupConfig,
      arguments: setupParams.toJson(),
    );
  }

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
  Future<String> changeProxy(ChangeProxyParams changeProxyParams) async {
    return _invokeMessage(
      method: CoreMethod.changeProxy,
      arguments: changeProxyParams.toJson(),
    );
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
  Future<bool> configureSmartRouting(RcxConfigParams params) async {
    return await _invokeMethod<bool>(
          method: CoreMethod.rcxConfigure,
          arguments: params.toJson(),
        ) ??
        false;
  }

  @override
  Future<RcxStatus?> smartRoutingStatus() async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.rcxStatus,
    );
    if (data == null) {
      return null;
    }
    return RcxStatus.fromJson(data);
  }

  @override
  Future<RcxReport?> smartRoutingReport() async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.rcxReport,
    );
    if (data == null) {
      return null;
    }
    return RcxReport.fromJson(data);
  }

  @override
  Future<bool> smartRoutingDeepScan() async {
    return await _invokeMethod<bool>(method: CoreMethod.rcxDeepScan) ?? false;
  }

  @override
  Future<OdometerSnapshot?> odometerReport() async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.odometerReport,
    );
    return data == null ? null : OdometerSnapshot.fromJson(data);
  }

  @override
  Future<bool> signalOdometer(OdometerSignal signal) async {
    return await _invokeMethod<bool>(
          method: CoreMethod.odometerSignal,
          arguments: signal.toJson(),
        ) ??
        false;
  }

  @override
  Future<DoctorSnapshot> doctorSnapshot() async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.doctorSnapshot,
    );
    if (data == null) {
      throw const CoreMethodException(
        code: 'empty_result',
        message: 'Core returned an empty doctor snapshot',
      );
    }
    return DoctorSnapshot.fromJson(data);
  }

  @override
  Future<DoctorSnapshot> startDoctor(DoctorStartParams params) async {
    return _doctorSnapshotResult(
      CoreMethod.doctorStart,
      arguments: params.toJson(),
    );
  }

  @override
  Future<DoctorSnapshot> cancelDoctor(DoctorCancelParams params) async {
    return _doctorSnapshotResult(
      CoreMethod.doctorCancel,
      arguments: params.toJson(),
    );
  }

  @override
  Future<DoctorSnapshot> flushDoctorDns(DoctorHealParams params) async {
    return _doctorSnapshotResult(
      CoreMethod.doctorFlushDns,
      arguments: params.toJson(),
    );
  }

  Future<DoctorSnapshot> _doctorSnapshotResult(
    CoreMethod method, {
    Object? arguments,
  }) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: method,
      arguments: arguments,
    );
    if (data == null) {
      throw CoreMethodException(
        code: 'empty_result',
        message: 'Core returned an empty ${method.name} result',
      );
    }
    return DoctorSnapshot.fromJson(data);
  }

  @override
  Future<DoctorReport> exportDoctorReport() async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.doctorExport,
    );
    if (data == null) {
      throw const CoreMethodException(
        code: 'empty_result',
        message: 'Core returned an empty doctor report',
      );
    }
    return DoctorReport.fromJson(data);
  }

  @override
  Future<SubscriptionReport> exportSubscriptionReport() async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.subscriptionReportExport,
    );
    if (data == null) {
      throw const CoreMethodException(
        code: 'empty_result',
        message: 'Core returned an empty subscription report',
      );
    }
    return SubscriptionReport.fromJson(data);
  }

  @override
  Future<bool> setSubscriptionMetadata(SubscriptionMetadata metadata) async {
    return await _invokeMethod<bool>(
          method: CoreMethod.subscriptionReportMetadata,
          arguments: metadata.toJson(),
        ) ??
        false;
  }

  @override
  Future<List<TrackerInfo>> getConnections() async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getConnections,
    );
    final connections = data?['connections'];
    if (connections is! List) {
      return [];
    }
    return connections
        .whereType<Map>()
        .map((item) => TrackerInfo.fromJson(Map<String, Object?>.from(item)))
        .toList();
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
  FutureOr<void> resetTraffic() {
    _invokeMethod(method: CoreMethod.resetTraffic).ignore();
  }

  @override
  FutureOr<void> startLog() {
    _invokeMethod(method: CoreMethod.startLog).ignore();
  }

  @override
  FutureOr<void> stopLog() {
    _invokeMethod<bool>(method: CoreMethod.stopLog).ignore();
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
  Future<bool> pauseTun() async {
    return await _invokeMethod<bool>(method: CoreMethod.pauseTun) ?? false;
  }

  @override
  Future<bool> resumeTun() async {
    return await _invokeMethod<bool>(method: CoreMethod.resumeTun) ?? false;
  }

  @override
  Future<bool> setUiActive(bool active) async {
    return await _invokeMethod<bool>(
          method: CoreMethod.setUiActive,
          arguments: active,
        ) ??
        false;
  }

  @override
  Future<Delay?> asyncTestDelay(String url, String proxyName) async {
    final delayParams = {
      'proxy-name': proxyName,
      'timeout': delayTestTimeoutDuration.inMilliseconds,
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
  Future<CoreMemoryStats?> getMemoryStats() async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getMemoryStats,
    );
    return data == null ? null : CoreMemoryStats.fromJson(data);
  }

  @override
  Future<int> getGoroutineCount() async {
    return await _invokeMethod<int>(method: CoreMethod.getGoroutineCount) ?? 0;
  }
}
