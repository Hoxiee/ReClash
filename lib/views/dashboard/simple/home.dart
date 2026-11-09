import 'dart:async';
import 'dart:math' as math;

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/providers.dart';
import 'package:reclash/features/power/attention.dart';
import 'package:reclash/features/power/face.dart';
import 'package:reclash/features/power/providers.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/provider_conditions.dart';
import 'package:reclash/subscriptions/metadata/provider_power_labels.dart';
import 'package:reclash/subscriptions/notification/record.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/style.dart';
import 'package:reclash/views/dashboard/widgets/profile_detail.dart';
import 'package:reclash/views/dashboard/widgets/update_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/views/doctor/doctor.dart';
import 'package:reclash/widgets/icon.dart';

import 'home_view.dart';
import 'location_card.dart';
import 'power_account_sheet.dart';
import 'subscription_card.dart';

export 'home_view.dart' show powerTooltip;

/// The button, what it did and what is left to spend, under a pending app
/// update; on a phone also where traffic leaves.
class SimpleHome extends ConsumerWidget {
  const SimpleHome({super.key, required this.padding, this.wide = false});

  final EdgeInsets padding;
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (minSize, maxSize) = wide ? (184.0, 256.0) : (160.0, 220.0);
    final hasUpdate = ref.watch(
      appUpdateActionProvider.select((state) => state.hasUpdate),
    );
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: FillHero(
          viewport: constraints.maxHeight - padding.vertical,
          minHero: SimplePower.heightOf(minSize),
          above: hasUpdate ? const UpdateCard() : null,
          hero: SimplePower(minSize: minSize, maxSize: maxSize),
          below: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                if (!wide) const LocationCard(),
                const SubscriptionCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Asks for a run and shows the request: a start reads as connecting for at
/// least [_holdDuration] and until the request settles, while the run state
/// itself stays with the providers.
class PowerRequest extends ConsumerStatefulWidget {
  const PowerRequest({super.key, required this.builder});

  /// A null toggle means there is no profile to run.
  final Widget Function(
    BuildContext context,
    PowerLink link,
    VoidCallback? toggle,
  )
  builder;

  @override
  ConsumerState<PowerRequest> createState() => _PowerRequestState();
}

class _PowerRequestState extends ConsumerState<PowerRequest> {
  static const _holdDuration = Duration(milliseconds: 600);

  var _request = 0;
  var _starting = false;
  Timer? _hold;

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  Future<void> _toggle() async {
    final request = ++_request;
    final starting = !ref.read(isStartProvider) && !_starting;
    _hold?.cancel();
    setState(() {
      _starting = starting;
      _hold = starting
          ? Timer(_holdDuration, () {
              if (mounted) setState(() => _hold = null);
            })
          : null;
    });
    try {
      await ref.read(commonActionProvider.notifier).toggleRunning();
    } finally {
      if (mounted && request == _request) {
        setState(() => _starting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasProfile = ref.watch(
      profilesProvider.select((state) => state.isNotEmpty),
    );
    final isStart = ref.watch(isStartProvider);
    final suspended = isStart && ref.watch(suspendProvider);
    final coreConnecting =
        isStart && ref.watch(coreStatusProvider) == CoreStatus.connecting;
    final link = !hasProfile
        ? PowerLink.off
        : _starting || _hold != null || coreConnecting
        ? PowerLink.connecting
        : suspended
        ? PowerLink.paused
        : isStart
        ? PowerLink.on
        : PowerLink.off;
    return widget.builder(context, link, hasProfile ? _toggle : null);
  }
}

/// The power button over its status, both drawn from the power face.
class SimplePower extends ConsumerStatefulWidget {
  const SimplePower({super.key, required this.minSize, required this.maxSize});

  /// The button grows with its room between these, the status always under
  /// it.
  final double minSize;
  final double maxSize;

  static double heightOf(double size) => SimplePowerView.heightOf(size);

  @override
  ConsumerState<SimplePower> createState() => _SimplePowerState();
}

class _SimplePowerState extends ConsumerState<SimplePower> {
  /// How long a fix that leaves the app keeps the start it was asked for.
  static const _startIntentFor = Duration(minutes: 10);

  DateTime? _startWhenClear;

  @override
  void initState() {
    super.initState();
    ref.listenManual(powerFaceProvider, (_, face) => _continueStart(face));
  }

  /// Starts once the fix cleared what kept the button from starting, unless
  /// the run state moved first.
  void _continueStart(PowerFace face) {
    final since = _startWhenClear;
    if (since == null) return;
    if (face.link != PowerLink.off ||
        DateTime.now().difference(since) > _startIntentFor) {
      _startWhenClear = null;
      return;
    }
    switch (face.state) {
      case PowerFaceState.off ||
          PowerFaceState.ending ||
          PowerFaceState.expired ||
          PowerFaceState.exhausted:
        _startWhenClear = null;
        unawaited(ref.read(commonActionProvider.notifier).setRunning(true));
      default:
    }
  }

  Future<void> _remedy(String remedyId, PowerFace face) async {
    if (face.link == PowerLink.off) _startWhenClear = DateTime.now();
    await ref.read(diagnosticKernelProvider).apply(remedyId);
  }

  Future<void> _act(
    PowerAction action,
    PowerFace face,
    VoidCallback? toggle,
  ) async {
    switch (action) {
      case PowerAction.start || PowerAction.stop || PowerAction.resume:
        _startWhenClear = null;
        toggle?.call();
      case PowerAction.addProfile:
        showProfilesSheet(context);
      case PowerAction.accountSheet:
        await showPowerAccountSheet(context);
      case PowerAction.causeSheet:
        await showDoctorSheet(context, cause: face.cause);
      case PowerAction.renew || PowerAction.topUp || PowerAction.support:
        final metadata = ref
            .read(currentProfileProvider)
            ?.subscriptionSnapshot
            ?.metadata;
        final url = metadata == null ? null : accountLinkUrl(metadata, action);
        if (url != null) await dialogs.openUrl(url.toString());
      case PowerAction.updateProfile:
        final profile = ref.read(currentProfileProvider);
        if (profile == null) return;
        await ref
            .read(profilesActionProvider.notifier)
            .updateProfile(profile, showLoading: true);
      case PowerAction.grantVpn:
        await _remedy('device.requestVpnPermission', face);
      case PowerAction.openVpnSettings:
        await _remedy('device.openVpnSettings', face);
      case PowerAction.openDateSettings:
        await _remedy('device.openDateSettings', face);
      case PowerAction.openPortal:
        await _remedy('network.openCaptivePortal', face);
      case PowerAction.ruleMode:
        await ref.read(diagnosticKernelProvider).apply('config.ruleMode');
      case PowerAction.repair:
        await ref.read(connectionSupervisorProvider).repair();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.colorScheme.brightness == Brightness.dark;
    final logo = ref.watch(
      currentProfileProvider.select(
        (profile) =>
            profile?.subscriptionSnapshot?.metadata.logoFor(dark: dark) ?? '',
      ),
    );
    final look = ref.watch(providerPowerButtonProvider);
    final inputs = ref.watch(powerInputsProvider);
    return PowerRequest(
      builder: (context, link, toggle) {
        final face = resolvePowerFace(inputs.withLink(link));
        void act(PowerAction action) => unawaited(_act(action, face, toggle));
        return SimplePowerView(
          minSize: widget.minSize,
          maxSize: widget.maxSize,
          face: face,
          onPressed: switch (face.tap) {
            final tap? => () => act(tap),
            null => null,
          },
          logo: logo,
          images: const AppProviderImages(),
          look: look,
          status: _StatusText(face: face, onFix: act),
        );
      },
    );
  }
}

class _StatusText extends ConsumerWidget {
  const _StatusText({required this.face, required this.onFix});

  final PowerFace face;
  final ValueChanged<PowerAction> onFix;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PowerStatusView(
    face: face,
    custom: _customLabel(ref),
    pausedHint: face.link == PowerLink.paused
        ? _pausedHint(context, ref)
        : null,
    live: const _LiveLine(),
    onFix: onFix,
  );

  String _pausedHint(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return switch (ref.watch(onDemandMatchedNetworksProvider).firstOrNull) {
      final network? => appLocalizations.simpleStatusPausedOn(network),
      null => appLocalizations.simpleStatusPausedHint,
    };
  }

  /// The provider's label for the face, null when it has none or a
  /// placeholder has no value.
  ProviderPowerLabel? _customLabel(WidgetRef ref) {
    final state = powerLabelState(face);
    if (state == null) return null;
    final label = ref.watch(providerPowerLabelProvider)[state];
    if (label == null) return null;
    final info = ref.watch(
      currentProfileProvider.select((profile) => profile?.subscriptionInfo),
    );
    final metadata = ref.watch(
      currentProfileProvider.select(
        (profile) => profile?.subscriptionSnapshot?.metadata,
      ),
    );
    final expiry = metadata?.perpetual == true || info == null
        ? null
        : subscriptionExpireDate(info.expire);
    final left = info == null || metadata?.unlimited == true || info.total <= 0
        ? null
        : math.max(0, info.total - info.upload - info.download);
    return resolveProviderPowerLabel(label, {
      'daysLeft': expiry == null
          ? null
          : '${remainingDays(expire: info!.expire, now: DateTime.now())}',
      'trafficLeft': left == null ? null : dashboardTraffic(left),
      'server': ref.watch(providerServerNodeProvider),
    });
  }
}

/// The session time and the speed each way, refreshed every second.
class _LiveLine extends ConsumerWidget {
  const _LiveLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final traffic = ref.watch(
      trafficsProvider.select((state) => state.list.safeLast(const Traffic())),
    );
    return PowerLiveLineView(
      time: getTimeText(ref.watch(runTimeProvider)),
      down: traffic.down,
      up: traffic.up,
    );
  }
}
