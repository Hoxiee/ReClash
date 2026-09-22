import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_status.dart';
import 'package:reclash/views/dashboard/widgets/provider_effect_overlay.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  Future<ProviderContainer> pumpOverlay(
    WidgetTester tester, {
    required String? heroEffect,
    bool providerEffectsEnabled = true,
    int expire = 0,
  }) async {
    final profile = Profile(
      id: 7,
      autoUpdateDuration: Duration.zero,
      panelMeta: heroEffect == null
          ? null
          : PanelMeta(heroEffect: heroEffect, heroRing: '2E5BFF;7A36F0;FF5A8A'),
      subscriptionInfo: expire == 0 ? null : SubscriptionInfo(expire: expire),
    );
    final container = ProviderContainer(
      overrides: [
        currentProfileProvider.overrideWithValue(profile),
        heroLifecycleProvider.overrideWithValue(HeroOrbPhase.on),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: ProviderEffectOverlay(child: SizedBox.expand()),
        ),
      ),
    );
    await tester.pump();
    if (!providerEffectsEnabled) {
      container
          .read(milestoneSettingProvider.notifier)
          .update((state) => state.copyWith(providerEffectsEnabled: false));
      await tester.pump();
    }
    return container;
  }

  Finder effectPaint() => find.descendant(
    of: find.byType(ProviderEffectOverlay),
    matching: find.byType(CustomPaint),
  );

  testWidgets('paints an aurora when a secured profile requests it', (
    tester,
  ) async {
    await pumpOverlay(tester, heroEffect: 'aurora');
    expect(effectPaint(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('paints nothing when the panel names no effect', (tester) async {
    await pumpOverlay(tester, heroEffect: null);
    expect(effectPaint(), findsNothing);
  });

  testWidgets('the user toggle suppresses the effect', (tester) async {
    await pumpOverlay(
      tester,
      heroEffect: 'aurora',
      providerEffectsEnabled: false,
    );
    expect(effectPaint(), findsNothing);
  });

  testWidgets('an expired subscription hides the effect', (tester) async {
    await pumpOverlay(tester, heroEffect: 'aurora', expire: 1);
    expect(effectPaint(), findsNothing);
  });
}
