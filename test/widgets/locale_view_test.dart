import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/locale.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/test_app.dart';

void main() {
  Future<void> pumpView(WidgetTester tester, List<Override> overrides) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: overrides,
        child: const LocaleView(),
      ),
    );
    await tester.pump();
  }

  testWidgets('language names stay native regardless of the active locale', (
    tester,
  ) async {
    await pumpView(tester, const []);

    expect(find.text('English'), findsNWidgets(2));
    expect(find.text('Русский'), findsOneWidget);
    expect(find.text('日本語'), findsOneWidget);
    expect(find.text('简体中文'), findsOneWidget);
    expect(find.text('Japanese'), findsOneWidget);
    expect(find.text('Russian'), findsOneWidget);
    expect(find.text('Chinese (Simplified)'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
    expect(tester.takeException(), null);
  });

  testWidgets('marks the active locale and writes the choice on tap', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        appSettingProvider.overrideWithBuild((_, _) => const AppSettingProps()),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          includeNavigatorKey: false,
          wrapInProviderScope: false,
          child: LocaleView(),
        ),
      ),
    );
    await tester.pump();

    DecorationListItem tileOf(String text) =>
        find
                .ancestor(
                  of: find.text(text),
                  matching: find.byType(DecorationListItem),
                )
                .evaluate()
                .single
                .widget
            as DecorationListItem;

    expect(tileOf('Default').isSelected, isTrue);

    await tester.tap(find.text('Русский'));
    await tester.pump();

    expect(container.read(appSettingProvider).locale, 'ru');
    expect(tileOf('Русский').isSelected, isTrue);
    expect(tileOf('Default').isSelected, isFalse);
    expect(tester.takeException(), null);
  });
}
