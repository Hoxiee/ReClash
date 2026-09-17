import 'package:reclash/common/seasonal.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProviderContainer containerFor({bool developer = true}) {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(developerMode: developer));
    return container;
  }

  test('preview cannot run outside developer mode', () {
    final container = containerFor(developer: false);
    final preview = container.read(findingPreviewProvider.notifier);
    preview.showFinding('vigil');
    preview.showAllRewards();
    preview.setSeason(SeasonalMotif.newYear);
    preview.setPatinaDays(120);
    expect(container.read(findingPreviewProvider).enabled, isFalse);
    expect(preview.activate(calm: true), isFalse);
  });

  test('all finding previews leave real settings and counters unchanged', () {
    final container = containerFor();
    final actual = container.read(milestoneSettingProvider);
    final snapshot = container.read(milestonesProvider);
    final preview = container.read(findingPreviewProvider.notifier);
    for (final id in findingIds) {
      preview.showFinding(id);
      expect(container.read(visibleMilestonesProvider).unlocked, contains(id));
      expect(container.read(findingPreviewProvider).pending, id);
    }
    expect(container.read(milestoneSettingProvider), actual);
    expect(container.read(milestonesProvider), same(snapshot));
    expect(
      container.read(visibleOdometerProvider)?.totalCoveredMillis,
      const Duration(days: 360).inMilliseconds,
    );
    preview.reset();
    expect(container.read(visibleMilestonesProvider), actual);
    expect(container.read(visibleOdometerProvider), same(snapshot));
  });

  test('ignores unknown findings and unsupported patina ages', () {
    final container = containerFor();
    final preview = container.read(findingPreviewProvider.notifier);
    preview.showFinding('unknown');
    preview.setPatinaDays(-1);
    expect(container.read(findingPreviewProvider).enabled, isFalse);
  });

  test('preview waits for calm and does not consume the real queue', () {
    final container = containerFor();
    container
        .read(milestoneSettingProvider.notifier)
        .update(
          (_) =>
              const MilestoneProps(unlocked: {'vigil'}, revealQueue: ['vigil']),
        );
    final preview = container.read(findingPreviewProvider.notifier);
    preview.showFinding('pi');
    expect(preview.activate(calm: false), isFalse);
    expect(container.read(findingPreviewProvider).pending, 'pi');
    expect(preview.activate(calm: true), isTrue);
    expect(container.read(findingPreviewProvider).active, 'pi');
    expect(container.read(milestoneSettingProvider).revealQueue, ['vigil']);
    preview.showFinding('pi');
    expect(container.read(findingPreviewProvider).active, isNull);
    expect(preview.activate(calm: true), isTrue);
  });

  test('disabling developer mode discards preview state', () async {
    final container = containerFor();
    final preview = container.read(findingPreviewProvider.notifier);
    preview.showAllRewards();
    preview.setSeason(SeasonalMotif.newYear);
    preview.setPatinaDays(120);
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(developerMode: false));
    await container.pump();
    expect(container.read(findingPreviewProvider).enabled, isFalse);
    expect(container.read(visibleMilestonesProvider).unlocked, isEmpty);
  });

  test('appearance master switch suppresses preview rewards and events', () {
    final container = containerFor();
    final preview = container.read(findingPreviewProvider.notifier);
    preview.showFinding('oscilloscope');
    container
        .read(milestoneSettingProvider.notifier)
        .update((state) => state.copyWith(findingsEnabled: false));
    expect(preview.activate(calm: true), isFalse);
    expect(container.read(visibleMilestonesProvider).unlocked, isEmpty);
  });

  test('gestures in preview do not award real findings', () {
    final container = containerFor();
    container.read(findingPreviewProvider.notifier).showFinding('marks');
    expect(
      container.read(milestonesProvider.notifier).discover('marks'),
      isFalse,
    );
    expect(container.read(milestoneSettingProvider).unlocked, isEmpty);
  });

  testWidgets('pi preview expires and can be replayed without restarting', (
    tester,
  ) async {
    final container = containerFor();
    final preview = container.read(findingPreviewProvider.notifier);
    preview.showFinding('pi');
    preview.activate(calm: true);
    await tester.pump(const Duration(seconds: 4));
    expect(container.read(findingPreviewProvider).active, isNull);
    preview.showFinding('pi');
    expect(preview.activate(calm: true), isTrue);
    preview.reset();
    await tester.pump(const Duration(seconds: 4));
    expect(container.read(findingPreviewProvider).active, isNull);
  });
}
