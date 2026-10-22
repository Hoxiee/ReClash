import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';

import '../../helpers/preferences.dart';
import '../../helpers/test_profiles.dart';

class _FixedStatus extends RcxStatusState {
  _FixedStatus(this.status);

  final RcxStatus? status;

  @override
  RcxStatus? build() => status;
}

void main() {
  setUpAll(() async {
    await mockPreferences();
  });

  ProviderContainer make({RcxStatus? status, Mode? own}) {
    final c = ProviderContainer(
      overrides: [
        coreStatusProvider.overrideWithValue(CoreStatus.disconnected),
        profilesProvider.overrideWith(() => TestProfiles(const [])),
        rcxStatusStateProvider.overrideWith(() => _FixedStatus(status)),
      ],
    );
    addTearDown(c.dispose);
    c.listen(rcxProfilesProvider, (_, _) {});
    c.listen(currentRoutingLayerProvider, (_, _) {});
    c.listen(effectiveModeProvider, (_, _) {});
    if (own != null) {
      c
          .read(patchClashConfigProvider.notifier)
          .update((state) => state.copyWith(mode: own));
    }
    return c;
  }

  group('currentRoutingLayer', () {
    test('splits scenarios from profiles by kind', () {
      final c = make();
      c.read(rcxProfilesProvider.notifier).value = {
        'p': const RcxUserProfile(text: 'profile text'),
        's': const RcxUserProfile(text: 'scenario text', kind: 'scenario'),
      };

      final layer = c.read(currentRoutingLayerProvider);
      expect(layer.profiles, {'p': 'profile text'});
      expect(layer.scenarios, {'s': 'scenario text'});
    });
  });

  group('effectiveMode', () {
    test('is the own mode without a status', () {
      final c = make(own: Mode.global);

      expect(c.read(effectiveModeProvider), Mode.global);
    });

    test('is the own mode when the scenario does not hold the mode', () {
      final c = make(
        own: Mode.global,
        status: const RcxStatus(
          tunnelMode: 'direct',
          scenario: RcxScenarioStatus(id: 'user/a'),
        ),
      );

      expect(c.read(effectiveModeProvider), Mode.global);
    });

    test('is the own mode when the user took the mode back', () {
      final c = make(
        own: Mode.global,
        status: const RcxStatus(
          tunnelMode: 'direct',
          scenario: RcxScenarioStatus(
            id: 'user/a',
            holdsMode: true,
            manual: true,
          ),
        ),
      );

      expect(c.read(effectiveModeProvider), Mode.global);
    });

    test('is the scenario tunnel mode while it holds the mode', () {
      final c = make(
        own: Mode.global,
        status: const RcxStatus(
          tunnelMode: 'direct',
          scenario: RcxScenarioStatus(id: 'user/a', holdsMode: true),
        ),
      );

      expect(c.read(effectiveModeProvider), Mode.direct);
    });
  });
}
