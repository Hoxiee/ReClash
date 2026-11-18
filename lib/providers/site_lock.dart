import 'package:reclash/common/common.dart';
import 'package:reclash/core/desktop/site_lock_policy.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app.dart';
import 'core.dart';

part 'generated/site_lock.g.dart';

/// The Core's last answer about the site locks; null until one arrives.
@Riverpod(keepAlive: true)
class SiteLockReportState extends _$SiteLockReportState {
  int _revision = 0;

  @override
  SiteLockReport? build() => null;

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

  Future<SiteLockReport?> push(List<SiteLock> locks) async {
    final revision = ++_revision;
    try {
      final report = await ref.read(coreHandlerProvider).setSiteLocks(locks);
      if (!ref.mounted || revision != _revision) return report;
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

/// What the Linux Helper's firewall policy last reported.
@Riverpod(keepAlive: true)
class SiteLockHostState extends _$SiteLockHostState {
  @override
  SiteLockHostStatus build() => SiteLockHostStatus.inactive;

  void set(SiteLockHostStatus status) => state = status;
}
