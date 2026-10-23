import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/core/core.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/plugins/service.dart';
import 'package:reclash/subscriptions/notification/reminder.dart';
import 'package:reclash/providers/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AndroidManager extends ConsumerStatefulWidget {
  final Widget child;

  const AndroidManager({super.key, required this.child});

  @override
  ConsumerState<AndroidManager> createState() => _AndroidContainerState();
}

class _AndroidContainerState extends ConsumerState<AndroidManager>
    with ServiceListener, WidgetsBindingObserver {
  Timer? _reminderTimer;
  bool _checkingReminders = false;
  int _pauseRevision = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reminderTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => unawaited(_checkReminders()),
    );
    ref.listenManual(
      profilesProvider,
      (_, _) => unawaited(_checkReminders()),
      fireImmediately: true,
    );
    ref.listenManual(
      appSettingProvider.select(
        (s) => s.notificationSettings.subscriptionReminders,
      ),
      (_, enabled) {
        if (enabled) {
          unawaited(_checkReminders());
        }
      },
    );
    ref.listenManual(appSettingProvider.select((state) => state.hidden), (
      prev,
      next,
    ) {
      app?.updateExcludeFromRecents(next);
    }, fireImmediately: true);
    ref.listenManual(
      appSettingProvider.select((state) => state.appIcon),
      (_, icon) => unawaited(_applyAppIcon(icon)),
      fireImmediately: true,
    );
    ref.listenManual(loadedLocaleProvider, (prev, next) {
      if (prev != null && prev != next && !safeModeBuild) {
        app?.initShortcuts();
      }
    });
    ref.listenManual(sharedStateProvider, (prev, next) {
      if (prev != next) {
        debouncer.call(FunctionTag.saveSharedFile, () async {
          await preferences.saveShareState(next);
        }, duration: const Duration(seconds: 1));
        if (prev?.needSyncSharedState != next.needSyncSharedState) {
          service?.syncState(next.needSyncSharedState);
        }
      }
    });
    service?.addListener(this);
    final revision = _pauseRevision;
    unawaited(
      service
          ?.getOnDemandPaused()
          .then((paused) {
            if (mounted && revision == _pauseRevision) onOnDemandPause(paused);
          })
          .catchError((Object error) {
            commonPrint.log('Unable to read on-demand state: $error');
          }),
    );
    app?.onPackagesChanged = _reloadPackages;
  }

  // Disabling the launcher alias drops the dynamic shortcuts bound to it.
  Future<void> _applyAppIcon(AppIcon icon) async {
    try {
      await app?.setAppIcon(icon);
      if (!safeModeBuild) {
        await app?.initShortcuts();
      }
    } catch (error) {
      commonPrint.log('Unable to set the app icon: $error');
    }
  }

  /// A reload reads every installed app's label, and a round of store updates
  /// reports each app on its own.
  void _reloadPackages() {
    if (ref.read(packagesProvider).isEmpty) {
      return;
    }
    debouncer.call(FunctionTag.reloadPackages, () async {
      if (mounted) {
        await ref.read(systemActionProvider.notifier).getPackages();
      }
    }, duration: const Duration(seconds: 2));
  }

  Future<void> _checkReminders() async {
    if (_checkingReminders ||
        !system.isAndroid ||
        ref.read(safeModeProvider) ||
        !ref
            .read(appSettingProvider)
            .notificationSettings
            .subscriptionReminders) {
      return;
    }
    _checkingReminders = true;
    try {
      for (final id in ref.read(profilesProvider).map((p) => p.id).toList()) {
        if (!mounted) return;
        final profile = ref.read(profilesProvider).getProfile(id);
        if (profile == null) continue;
        try {
          await subscriptionReminder.check(
            profile,
            currentProfile: () =>
                mounted ? ref.read(profilesProvider).getProfile(id) : null,
          );
        } on Object catch (error) {
          commonPrint.log(
            'Subscription reminder failed: ${compactError(error)}',
            logLevel: LogLevel.warning,
          );
        }
      }
    } finally {
      _checkingReminders = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_checkReminders());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reminderTimer?.cancel();
    debouncer.cancel(FunctionTag.reloadPackages);
    if (app?.onPackagesChanged == _reloadPackages) {
      app?.onPackagesChanged = null;
    }
    service?.removeListener(this);
    super.dispose();
  }

  @override
  void onServiceEvent(CoreEvent event) {
    coreEventManager.sendEvent(event);
    super.onServiceEvent(event);
  }

  @override
  void onOnDemandPause(bool paused) {
    _pauseRevision++;
    ref.read(nativeOnDemandPauseProvider.notifier).value = paused;
  }

  @override
  void onServiceStopped() {
    unawaited(ref.read(setupActionProvider.notifier).setRunning(false));
    super.onServiceStopped();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
