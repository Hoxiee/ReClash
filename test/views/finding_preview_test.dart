import 'package:reclash/common/common.dart';
import 'package:reclash/common/milestones/seasonal.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/finding_preview.dart';
import 'package:reclash/views/config/desync.dart';
import 'package:reclash/views/tools/connection_doctor.dart';
import 'package:reclash/views/dashboard/widgets/traffic_usage.dart';
import 'package:reclash/views/tools/findings.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('standalone examples do not change networking or measurements', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(developerMode: true));
    container.read(findingPreviewProvider.notifier).showAllRewards();
    final config = container.read(desyncSettingProvider);
    final doctor = container.read(connectionDoctorProvider);
    final traffic = container.read(totalTrafficProvider);
    Future<void> show(Widget child) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(child: child),
        ),
      );
      await tester.pump();
    }

    await show(const DesyncLadderPreview());
    final startButtons = tester.widgetList<FilledButton>(
      find.widgetWithText(
        FilledButton,
        currentAppLocalizations.desyncTestStart,
      ),
    );
    expect(startButtons, isNotEmpty);
    expect(startButtons.every((button) => button.onPressed == null), isTrue);
    expect(find.byType(CircleAvatar), findsWidgets);
    await tester.tap(find.byType(CircleAvatar).first);
    expect(container.read(desyncSettingProvider), config);
    await show(const DoctorTimingPreview());
    expect(find.textContaining('25 ms'), findsWidgets);
    expect(container.read(connectionDoctorProvider), doctor);
    await show(const Scaffold(body: TrafficUsage(preview: true)));
    await tester.pump(const Duration(seconds: 2));
    expect(container.read(totalTrafficProvider), traffic);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('findings reset clears only the active preview', (tester) async {
    tester.view.physicalSize = const Size(1100, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const actual = MilestoneProps(
      unlocked: {'vigil'},
      revealedAt: {'vigil': 1},
      revealQueue: ['crown'],
    );
    final container = ProviderContainer(
      overrides: [milestoneSettingProvider.overrideWithBuild((_, _) => actual)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(developerMode: true));
    container.read(findingPreviewProvider.notifier).showFinding('pi');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: FindingsView()),
      ),
    );
    await tester.pumpAndSettle();
    final reset = find.text(currentAppLocalizations.developerPreviewReset);
    await tester.scrollUntilVisible(reset, 300);
    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(container.read(findingPreviewProvider).enabled, isFalse);
    expect(container.read(milestoneSettingProvider), actual);
    expect(find.text('Reset findings?'), findsNothing);
  });

  testWidgets('preview controls are transient and can be reset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(developerMode: true));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: FindingPreviewView()),
      ),
    );
    await tester.pumpAndSettle();
    final localizations = currentAppLocalizations;
    await tester.tap(find.text(localizations.developerAllRewards));
    await tester.pumpAndSettle();
    expect(container.read(visibleMilestonesProvider).unlocked.length, 8);
    expect(container.read(milestoneSettingProvider).unlocked, isEmpty);

    await tester.tap(find.text(localizations.developerSeasonNewYear));
    await tester.pumpAndSettle();
    expect(container.read(visibleSeasonProvider), SeasonalMotif.newYear);
    final apply = find.text(localizations.developerPatinaApply);
    await tester.scrollUntilVisible(apply, 300);
    await tester.tap(apply);
    await tester.pumpAndSettle();
    expect(container.read(findingPreviewProvider).patinaDays, 120);

    final event = find.byKey(const ValueKey('preview-finding-pi'));
    await tester.scrollUntilVisible(event, 350);
    await tester.tap(event);
    await tester.pumpAndSettle();
    expect(container.read(findingPreviewProvider).pending, 'pi');
    expect(container.read(milestoneSettingProvider).revealedAt, isEmpty);
    final reset = find.text(localizations.developerPreviewReset);
    await tester.scrollUntilVisible(reset, -400);
    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(container.read(findingPreviewProvider).enabled, isFalse);
    expect(tester.takeException(), isNull);
  });
}
