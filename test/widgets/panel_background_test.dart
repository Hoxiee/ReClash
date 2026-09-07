import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  Future<void> pumpScaffold(
    WidgetTester tester, {
    required String? background,
  }) async {
    final profile = Profile(
      id: 7,
      autoUpdateDuration: Duration.zero,
      panelMeta: background == null ? null : PanelMeta(background: background),
    );
    final container = ProviderContainer(
      overrides: [currentProfileProvider.overrideWithValue(profile)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          includeNavigatorKey: false,
          child: CommonScaffold(title: 'Profiles', body: SizedBox()),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders a valid provider background behind scaffold content', (
    tester,
  ) async {
    await pumpScaffold(
      tester,
      background: 'https://cdn.example.com/background.webp,25',
    );

    final background = find.byKey(const ValueKey('panel-profile-background'));
    expect(background, findsOneWidget);
    expect(
      tester
          .widget<ImageCacheWidget>(
            find.descendant(
              of: background,
              matching: find.byType(ImageCacheWidget),
            ),
          )
          .src,
      'https://cdn.example.com/background.webp',
    );
    final overlay = tester.widget<ColoredBox>(
      find
          .descendant(of: find.byType(Stack), matching: find.byType(ColoredBox))
          .last,
    );
    expect(overlay.color.a, closeTo(0.75, 0.001));
  });

  testWidgets('falls back to the normal scaffold for an unsafe URL', (
    tester,
  ) async {
    await pumpScaffold(tester, background: 'file:///tmp/background.jpg');

    expect(
      find.byKey(const ValueKey('panel-profile-background')),
      findsNothing,
    );
    expect(find.byType(ImageCacheWidget), findsNothing);
  });
}
