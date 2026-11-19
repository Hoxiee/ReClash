import 'package:collection/collection.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/desktop/helper_client.dart';
import 'package:reclash/core/desktop/site_lock_policy.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app.dart';
import 'config.dart';
import 'core.dart';

part 'generated/site_lock.g.dart';

/// The Core's last answer about the site locks; null until one arrives.
@Riverpod(keepAlive: true)
class SiteLockReportState extends _$SiteLockReportState {
  int _revision = 0;
  List<SiteLock>? _applied;

  @override
  SiteLockReport? build() {
    ref.listen(coreStatusProvider, (_, next) {
      if (next != CoreStatus.connected) _applied = null;
    });
    return null;
  }

  Future<void> refresh() async {
    if (ref.read(coreStatusProvider) != CoreStatus.connected) return;
    final revision = ++_revision;
    try {
      final report = await ref.read(coreHandlerProvider).siteLockStatus();
      if (!ref.mounted || revision != _revision) return;
      state = report;
    } catch (error) {
      commonPrint.log(
        'Site lock status failed: ${compactError(error)}',
        logLevel: coreFailureLogLevel(error),
      );
    }
  }

  /// Whether the Core already runs [locks], as the editor's push before a save leaves it.
  bool holds(List<SiteLock> locks) =>
      const ListEquality<SiteLock>().equals(_applied, locks);

  Future<SiteLockReport?> push(List<SiteLock> locks) async {
    final revision = ++_revision;
    try {
      final report = await ref.read(coreHandlerProvider).setSiteLocks(locks);
      if (!ref.mounted || revision != _revision) return report;
      if (report?.applied ?? false) _applied = locks;
      state = report;
      return report;
    } catch (error) {
      commonPrint.log(
        'Site lock push failed: ${compactError(error)}',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
  }
}

/// Whether any site lock is on, the notion every lock-scoped policy follows.
@Riverpod(keepAlive: true)
bool siteLockActive(Ref ref) => ref.watch(
  siteLocksProvider.select((locks) => locks.any((lock) => lock.enabled)),
);

/// The prefixes the Android TUN must always route while a lock is on: the
/// Core's locked addresses plus the fake-ip ranges. A Core that cannot answer yet keeps the last list.
@Riverpod(keepAlive: true)
class SiteLockRoutes extends _$SiteLockRoutes {
  @override
  Future<List<String>> build() async {
    if (!system.isAndroid || !ref.watch(siteLockActiveProvider)) {
      return const [];
    }
    ref.watch(siteLockReportStateProvider);
    final previous = state.value ?? const <String>[];
    if (ref.watch(coreStatusProvider) != CoreStatus.connected) return previous;
    final policy = await ref.read(coreHandlerProvider).siteLockPolicy();
    if (policy == null) return previous;
    return {...policy.addresses, ...policy.fakeRanges}.toList();
  }
}

/// The Helper's live site lock state; null where no Helper host layer exists
/// or it is not ready. A failing query surfaces as the error state.
@riverpod
Future<HelperSiteLock?> siteLockHostInfo(Ref ref) async {
  if (!system.isLinux && !system.isWindows) return null;
  final readiness = await helperClient.readiness(logFailure: false);
  if (readiness != HelperReadiness.ready) return null;
  return helperClient.siteLock();
}

/// What the Helper's host policy last reported.
@Riverpod(keepAlive: true)
class SiteLockHostState extends _$SiteLockHostState {
  @override
  SiteLockHostStatus build() => SiteLockHostStatus.inactive;

  void set(SiteLockHostStatus status) => state = status;
}
