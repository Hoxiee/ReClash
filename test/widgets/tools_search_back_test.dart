import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/tools/tools.dart';
import 'package:reclash/widgets/widgets.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('mobile back clears tools search instead of popping', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(400, 800);
    var rootBackCount = 0;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: CommonPopScope(
            onPop: (_) {
              rootBackCount++;
              return false;
            },
            child: const ToolsView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final field = find.byType(TextField);
    expect(field, findsOneWidget);
    await tester.enterText(field, 'theme');
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller?.text, 'theme');

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(rootBackCount, 0);
    expect(tester.widget<TextField>(field).controller?.text, isEmpty);
  });

  testWidgets('mobile back unfocuses empty tools search instead of popping', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(400, 800);
    var rootBackCount = 0;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: CommonPopScope(
            onPop: (_) {
              rootBackCount++;
              return false;
            },
            child: const ToolsView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final field = find.byType(TextField);
    expect(field, findsOneWidget);
    await tester.tap(field);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).focusNode?.hasFocus, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(rootBackCount, 0);
    expect(tester.widget<TextField>(field).focusNode?.hasFocus, isFalse);
  });
}
