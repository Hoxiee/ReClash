import 'dart:async';

import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/subscriptions/compatibility/policy.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:reclash/ui/ui.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'common/common.dart';
import 'enum/enum.dart';
import 'models/models.dart';

class GlobalState {
  static GlobalState? _instance;
  GlobalKey<NavigatorState> get navigatorKey => rootNavigatorKey;
  String appEnv = 'pre';
  late PackageInfo packageInfo;
  late Measure measure;
  late ProviderContainer container;
  bool needInitStatus = true;

  bool get isPre => appEnv != 'stable';

  bool get canCrashCore => canCrashCoreFor(isDebug: kDebugMode, appEnv: appEnv);

  @visibleForTesting
  static bool canCrashCoreFor({required bool isDebug, required String appEnv}) {
    return isDebug || appEnv == 'dev';
  }

  String? lastConfigMd5;
  ConfigCounts? lastConfigCounts;
  bool isAttach = false;

  GlobalState._internal();

  factory GlobalState() {
    _instance ??= GlobalState._internal();
    return _instance!;
  }

  String get ua => container
      .read(patchClashConfigProvider.select((state) => state.globalUa))
      .takeFirstValid([packageInfo.ua]);

  Future<T?> loadingRun<T>(
    FutureOr<T> Function() futureFunction, {
    String? title,
    required LoadingTag? tag,
    bool silence = false,
  }) async {
    return globalState.safeRun(
      futureFunction,
      silence: silence,
      title: title,
      onStart: () {
        if (tag != null) {
          container.read(loadingProvider(tag).notifier).start();
        }
      },
      onEnd: () {
        if (tag != null) {
          container.read(loadingProvider(tag).notifier).stop();
        }
      },
    );
  }

  /// Concurrent [loadingRun]s would let the first to finish clear [tag].
  Future<void> batchRun<T>(
    List<T> items,
    Future<void> Function(T item) task, {
    required String Function(T item) label,
    required int concurrency,
    required LoadingTag? tag,
    int skipped = 0,
    bool reportSummary = false,
  }) async {
    final pool = TaskPool(concurrency);
    final failures = List<UpdatingMessage?>.filled(items.length, null);
    var added = 0;
    var cancelled = 0;
    await loadingRun(
      () => Future.wait([
        for (final (index, item) in items.indexed)
          pool.run(() async {
            try {
              await task(item);
              added++;
            } catch (e, s) {
              if (e is SubscriptionUpdateCancelled ||
                  e is SubscriptionUpdateSuperseded) {
                cancelled++;
                return;
              }
              commonPrint.log(
                '${label(item)} ===> ${compactError(e)}, $s',
                logLevel: LogLevel.warning,
              );
              failures[index] = UpdatingMessage(
                label: label(item),
                message: userFacingErrorMessage(e, currentAppLocalizations),
              );
            }
          }),
      ]),
      tag: tag,
    );
    final results = failures.nonNulls.toList();
    if (reportSummary) {
      dialogs.showBatchImportSummary(
        added: added,
        skipped: skipped + cancelled,
        failures: results,
      );
    } else {
      dialogs.showFailures(results);
    }
  }

  Future<T?> safeRun<T>(
    FutureOr<T> Function() futureFunction, {
    String? title,
    VoidCallback? onStart,
    VoidCallback? onEnd,
    bool silence = true,
  }) async {
    try {
      onStart?.call();
      return await futureFunction();
    } catch (e, s) {
      if (e is SubscriptionUpdateCancelled ||
          e is SubscriptionUpdateSuperseded) {
        return null;
      }
      commonPrint.log(
        title == null
            ? '${compactError(e)}, $s'
            : '$title ===> ${compactError(e)}, $s',
        logLevel: LogLevel.warning,
      );
      final message = userFacingErrorMessage(e, currentAppLocalizations);
      final supportUri = e is SubscriptionException ? e.supportUri : null;
      final isDeviceLimit =
          e is SubscriptionException &&
              e.failure == SubscriptionFailure.deviceLimit ||
          e is SubscriptionUpdateRejected &&
              e.reason == SubscriptionRetryReason.deviceLimitReached;
      if (isDeviceLimit) {
        dialogs.showNotifier(
          message,
          level: MessageLevel.warning,
          actionState: supportUri == null
              ? null
              : MessageActionState(
                  actionText:
                      currentAppLocalizations.subscriptionProviderSupport,
                  action: () =>
                      unawaited(dialogs.openUrl(supportUri.toString())),
                ),
        );
      } else if (silence) {
        dialogs.showNotifier(message, level: MessageLevel.error);
      } else {
        unawaited(
          dialogs.showAlert(
            title: title ?? currentAppLocalizations.tip,
            message: TextSpan(text: message),
          ),
        );
      }
      return null;
    } finally {
      onEnd?.call();
    }
  }
}

final globalState = GlobalState();
