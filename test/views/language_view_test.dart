import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/language.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1400, 2400);
  });

  tearDown(() => container.dispose());

  Future<void> pumpLanguageView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: LanguageView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  String? readLocale() => container.read(appSettingProvider).locale;

  testWidgets('lists the system default and every supported locale', (
    tester,
  ) async {
    await pumpLanguageView(tester);

    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Follow system'), findsOneWidget);
    expect(find.text('English'), findsWidgets);
    expect(find.text('Japanese'), findsOneWidget);
    expect(find.text('Korean'), findsOneWidget);
    expect(find.text('Russian'), findsOneWidget);
    expect(find.text('Spanish'), findsOneWidget);
    expect(find.text('French'), findsOneWidget);
    expect(find.text('简体中文'), findsOneWidget);
    expect(find.text('Chinese (Simplified)'), findsOneWidget);
    expect(find.text('Oʻzbekcha'), findsOneWidget);
    expect(find.text('Uzbek'), findsOneWidget);
    expect(find.text('Қазақша'), findsOneWidget);
    expect(find.text('Kazakh'), findsOneWidget);
    expect(find.text('Türkmençe'), findsOneWidget);
    expect(find.text('Turkmen'), findsOneWidget);
  });

  testWidgets('marks the saved locale, picks another and returns to default', (
    tester,
  ) async {
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(locale: 'ru'));
    await pumpLanguageView(tester);

    expect(readLocale(), 'ru');

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(readLocale(), 'es');

    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();
    expect(readLocale(), isNull);
  });
}
