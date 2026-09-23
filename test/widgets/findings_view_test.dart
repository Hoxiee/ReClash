import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/tools/tools.dart';
import 'package:reclash/views/tools/findings.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  testWidgets('Tools hides findings until the first reveal', (tester) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          viewSizeProvider.overrideWithBuild((_, _) => const Size(800, 800)),
        ],
        child: const ToolsView(),
      ),
    );
    await tester.pump();

    expect(find.text('Findings'), findsNothing);
  });

  testWidgets('Tools opens only revealed findings', (tester) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          viewSizeProvider.overrideWithBuild((_, _) => const Size(800, 800)),
          milestoneSettingProvider.overrideWithBuild(
            (_, _) => const MilestoneProps(
              unlocked: {'vigil', 'fullLadder'},
              revealedAt: {'vigil': 1},
            ),
          ),
        ],
        child: const ToolsView(),
      ),
    );
    await tester.pump();
    final section = tester.widget<SettingSection>(
      find.ancestor(
        of: find.text('Findings'),
        matching: find.byType(SettingSection),
      ),
    );
    expect(section.title, 'Other');
    final item = tester.widget<DecorationListItem>(
      find.ancestor(
        of: find.text('Findings'),
        matching: find.byType(DecorationListItem),
      ),
    );
    expect(item.subtitle, isNull);
    expect(
      tester.getTopLeft(find.text('Findings')).dy,
      lessThan(tester.getTopLeft(find.text('Disclaimer')).dy),
    );

    await tester.tap(find.text('Findings'));
    await tester.pumpAndSettle();

    expect(find.byType(FindingsView), findsOneWidget);
    // vigil is revealed (relic tile shows its name); fullLadder is unlocked
    // but not revealed, so it stays a blank silhouette.
    expect(find.text('Vigil'), findsOneWidget);
    expect(find.text('Full ladder'), findsNothing);
    expect(find.text('Relics'), findsOneWidget);
    expect(find.text('Moments'), findsOneWidget);
  });

  testWidgets('reset confirms and removes the Tools entry', (tester) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [
          profilesProvider.overrideWith(TestProfiles.new),
          viewSizeProvider.overrideWithBuild((_, _) => const Size(800, 800)),
          milestoneSettingProvider.overrideWithBuild(
            (_, _) => const MilestoneProps(
              unlocked: {'vigil'},
              revealedAt: {'vigil': 1},
            ),
          ),
        ],
        child: const ToolsView(),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Findings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset findings'));
    await tester.pumpAndSettle();
    expect(find.text('Reset findings?'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(find.byType(FindingsView), findsNothing);
    expect(find.text('Findings'), findsNothing);
  });
}
