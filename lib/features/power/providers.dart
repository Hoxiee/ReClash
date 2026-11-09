import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/features/doctor/providers.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';

import 'attention.dart';
import 'face.dart';

/// Everything the face reads, with the run state as the providers hold it;
/// the button swaps in its own link while a request is held.
final powerInputsProvider = Provider<PowerInputs>((ref) {
  final hasProfile = ref.watch(
    profilesProvider.select((state) => state.isNotEmpty),
  );
  final isStart = ref.watch(isStartProvider);
  final link = !isStart
      ? PowerLink.off
      : ref.watch(coreStatusProvider) == CoreStatus.connecting
      ? PowerLink.connecting
      : ref.watch(suspendProvider)
      ? PowerLink.paused
      : PowerLink.on;
  final info = ref.watch(
    currentProfileProvider.select((profile) => profile?.subscriptionInfo),
  );
  final metadata =
      ref.watch(
        currentProfileProvider.select(
          (profile) => profile?.subscriptionSnapshot?.metadata,
        ),
      ) ??
      const SubscriptionMetadata();
  return PowerInputs(
    link: link,
    hasProfile: hasProfile,
    online: ref.watch(networkOnlineProvider),
    findings: ref.watch(findingsProvider).value ?? const [],
    health: ref.watch(connectionHealthProvider),
    account: ref.watch(accountStandingProvider),
    attention: info == null
        ? null
        : accountAttention(
            metadata: metadata,
            used: info.upload + info.download,
            total: info.total,
            expire: info.expire,
            now: DateTime.now(),
          ),
    links: accountLinks(metadata),
    direct: ref.watch(effectiveModeProvider) == Mode.direct,
  );
});

final powerFaceProvider = Provider<PowerFace>((ref) {
  final inputs = ref.watch(powerInputsProvider);
  final smart = ref.watch(
    appSettingProvider.select((setting) => setting.smartPowerButton),
  );
  return smart ? resolvePowerFace(inputs) : PowerFace.plain(inputs.link);
});

/// The face already offers renewing or topping up, so the subscription card
/// keeps its own buttons back.
final powerOffersAccountActionProvider = Provider<bool>(
  (ref) => switch (ref.watch(powerFaceProvider.select((face) => face.fix))) {
    PowerAction.renew || PowerAction.topUp || PowerAction.support => true,
    _ => false,
  },
);
