import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_connect.dart';
import 'package:reclash/views/dashboard/widgets/hero/hero_status.dart';
import 'package:reclash/views/misc/finding_preview.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

void main() {
  testWidgets(
    'preview waits for visible calm hero and repeats without writes',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final active = ValueNotifier(false);
      final phase = ValueNotifier(HeroOrbPhase.on);
      addTearDown(active.dispose);
      addTearDown(phase.dispose);
      const actual = MilestoneProps(revealQueue: ['vigil']);
      const profile = Profile(id: 7, autoUpdateDuration: Duration.zero);
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          milestoneSettingProvider.overrideWithBuild((_, _) => actual),
          groupsProvider.overrideWithValue(const []),
          initProvider.overrideWithBuild((_, _) => true),
          isStartProvider.overrideWithValue(true),
          coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
          heroLifecycleProvider.overrideWith((ref) {
            void changed() => ref.invalidateSelf();
            phase.addListener(changed);
            ref.onDispose(() => phase.removeListener(changed));
            return phase.value;
          }),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(developerMode: true));
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(1100, 1600));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: ValueListenableBuilder<bool>(
              valueListenable: active,
              builder: (_, visible, _) => PageActivityScope(
                isActive: visible,
                child: const Scaffold(body: HeroConnect()),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final navigator = Navigator.of(tester.element(find.byType(HeroConnect)));
      navigator.push(
        MaterialPageRoute<void>(builder: (_) => const FindingPreviewView()),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      final event = find.byKey(const ValueKey('preview-finding-pi'));
      await tester.scrollUntilVisible(
        event,
        350,
        scrollable: find.descendant(
          of: find.byType(FindingPreviewView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(event);
      await tester.pump();
      expect(container.read(findingPreviewProvider).pending, 'pi');
      active.value = true;
      await tester.pump();
      expect(container.read(findingPreviewProvider).pending, 'pi');
      navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(container.read(findingPreviewProvider).active, 'pi');
      expect(find.byKey(const ValueKey('pi-session-note')), findsOneWidget);
      expect(container.read(milestoneSettingProvider), actual);

      phase.value = HeroOrbPhase.failed;
      await tester.pump();
      expect(find.byKey(const ValueKey('pi-session-note')), findsNothing);
      final preview = container.read(findingPreviewProvider.notifier);
      preview.showFinding('oscilloscope');
      await tester.pump();
      expect(container.read(findingPreviewProvider).pending, 'oscilloscope');
      expect(find.byKey(const ValueKey('hero-oscilloscope')), findsNothing);
      phase.value = HeroOrbPhase.on;
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('hero-oscilloscope')), findsOneWidget);
      active.value = false;
      await tester.pump();
      expect(find.byKey(const ValueKey('hero-oscilloscope')), findsNothing);
      await tester.pump(const Duration(seconds: 7));
      preview.showFinding('pi');
      await tester.pump();
      expect(container.read(findingPreviewProvider).pending, 'pi');
      active.value = true;
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('pi-session-note')), findsOneWidget);
      expect(container.read(milestoneSettingProvider), actual);
      expect(container.read(milestonesProvider), isNull);
      preview.reset();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 7));
      expect(tester.takeException(), isNull);
    },
  );
}
