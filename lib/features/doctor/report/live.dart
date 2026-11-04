import 'dart:ffi';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/common/service_probe.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/recorder/provider.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/providers/service_status.dart';
import 'package:reclash/state.dart';
import 'package:riverpod/riverpod.dart';

import '../finding.dart';
import '../journal.dart';
import '../kernel.dart';
import '../path.dart';
import '../providers.dart';
import 'collector.dart';
import 'redact.dart';
import 'sections.dart';
import 'sources.dart';
import 'sweep.dart';

final _secretHeader = RegExp(
  'auth|token|key|secret|cookie|pass',
  caseSensitive: false,
);

/// Reads the running app. Nothing here spawns a process: device facts come
/// from the platform plugin and `dart:io`, everything else from providers.
final class RefReportSources implements ReportSources {
  RefReportSources(this._ref);

  final Ref _ref;

  DiagnosticKernel get _kernel => _ref.read(diagnosticKernelProvider);

  @override
  Future<Map<String, Object?>> device() async {
    final package = globalState.packageInfo;
    final settings = _ref.read(appSettingProvider);
    final (os, device, abi) = await _deviceInfo();
    return {
      'app': {
        'name': appName,
        'version': package.version,
        'build': package.buildNumber,
        'flavor': globalState.appEnv,
      },
      'safeMode': _ref.read(safeModeProvider),
      'platform': Platform.operatingSystem,
      'os': os,
      'device': device,
      'abi': abi,
      'locale': settings.locale ?? Platform.localeName,
      'region':
          settings.regionCode ??
          _ref.read(detectedRegionProvider).value?.countryCode,
      'uptimeMs': _ref.read(runTimeProvider),
    };
  }

  Future<(String, String, String)> _deviceInfo() async {
    final abi = Abi.current().toString();
    final info = await DeviceInfoPlugin().deviceInfo;
    return switch (info) {
      AndroidDeviceInfo(:final version, :final supportedAbis) => (
        'Android ${version.release} (SDK ${version.sdkInt})',
        '${info.manufacturer} ${info.model}',
        supportedAbis.firstOrNull ?? abi,
      ),
      WindowsDeviceInfo() => (
        '${info.productName} ${info.displayVersion} (${info.buildNumber})',
        'desktop',
        abi,
      ),
      MacOsDeviceInfo() => ('macOS ${info.osRelease}', info.modelName, abi),
      LinuxDeviceInfo() => (info.prettyName, 'desktop', abi),
      _ => (Platform.operatingSystemVersion, '', abi),
    };
  }

  @override
  Future<Map<String, Object?>> environment() async {
    List<NetworkInterface> interfaces;
    try {
      interfaces = await NetworkInterface.list(includeLoopback: false);
    } on Object {
      interfaces = const [];
    }
    return environmentJson(_kernel.snapshot, interfaces: interfaces);
  }

  @override
  List<Finding> findings() => _kernel.findings;

  @override
  Future<List<DiagnosticEvent>> incidents() => _kernel.history();

  @override
  bool get connected => _ref.read(coreStatusProvider) == CoreStatus.connected;

  @override
  PathResult? get lastPath => _kernel.path;

  @override
  Future<PathResult> runPath() => _kernel.runPath(force: true);

  @override
  NodeSweeper get sweeper => _ref.read(nodeSweeperProvider);

  @override
  Future<Map<String, Object?>> services() async {
    final core = _ref.read(coreHandlerProvider);
    final targets = _ref.read(enabledServiceTargetsProvider);
    Future<(Map<ServiceTarget, ServiceCheck>, String?)> run(
      String proxy,
    ) async {
      try {
        return (
          await checkServices(core, proxyName: proxy, targets: targets),
          null,
        );
      } on Object catch (error) {
        return (const <ServiceTarget, ServiceCheck>{}, '$error');
      }
    }

    final ((routed, routedError), (direct, directError)) = await (
      run(routedOutbound),
      run(directOutbound),
    ).wait;
    Map<String, Object?>? check(ServiceCheck? check) => check == null
        ? null
        : {
            'status': check.status.id,
            'delayMs': check.delay,
            'region': check.region,
            'node': check.node,
          };
    return {
      'checks': [
        for (final target in targets)
          {
            'service': target.id,
            'label': target.label,
            'routed': check(routed[target]),
            'direct': check(direct[target]),
          },
      ],
      'routedError': ?routedError,
      'directError': ?directError,
    };
  }

  @override
  ReportProfile? profile() {
    final profile = _ref.read(currentProfileProvider);
    if (profile == null) return null;
    final groups = _ref.read(groupsProvider);
    return (
      id: profile.id,
      label: profile.realLabel,
      json: {
        'id': profile.id,
        'label': profile.realLabel,
        'type': profile.type.name,
        'source': urlOrigin(profile.url),
        'updatedAt': profile.lastUpdateDate?.toUtc().toIso8601String(),
        'autoUpdate': profile.autoUpdate,
        'autoUpdateMinutes': profile.autoUpdateDuration.inMinutes,
        'usage': profile.subscriptionInfo?.toJson(),
        'subscription': profile.subscriptionSnapshot?.toJson(),
        'currentGroup': profile.currentGroupName,
        'groups': [
          for (final group in groups)
            {
              'name': group.name,
              'type': group.type.value,
              'now': group.now,
              'nodes': group.all.length,
              'hidden': group.hidden ?? false,
            },
        ],
        'selections': profile.selectedMap,
      },
      secrets: [
        ...urlSecrets(profile.url),
        if (profile.ageSecretKey.isNotEmpty) profile.ageSecretKey,
        for (final MapEntry(:key, :value)
            in profile.subscriptionPreferences.headers.entries)
          if (_secretHeader.hasMatch(key)) value,
      ],
    );
  }

  @override
  Future<String?> config() =>
      _ref.read(coreHandlerProvider).getAppliedConfigContent();

  @override
  PassiveRecorder get recorder => _ref.read(passiveRecorderProvider);
}
