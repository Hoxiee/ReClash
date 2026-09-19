import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void _noop() {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    system.isTVForTesting = true;
    FocusHighlightVisibility.visibleForTesting = true;
  });
  tearDown(() {
    system.isTVForTesting = false;
    FocusHighlightVisibility.visibleForTesting = false;
  });

  String? focusedText() {
    final ctx = FocusManager.instance.primaryFocus?.context;
    if (ctx == null) return null;
    final texts = find
        .descendant(of: find.byWidget(ctx.widget), matching: find.byType(Text))
        .evaluate()
        .map((e) => (e.widget as Text).data)
        .whereType<String>()
        .toList();
    return texts.isEmpty ? null : texts.join('|');
  }

  Future<ProviderContainer> pumpHost(
    WidgetTester tester,
    void Function(BuildContext context) onTap,
  ) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1000, 800));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () => onTap(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('confirm dialog lands focus on the confirm action', (
    tester,
  ) async {
    await pumpHost(tester, (context) {
      dialogs.showMessage(
        context: context,
        message: const TextSpan(text: 'body'),
        confirmText: 'Yes',
        cancelText: 'No',
      );
    });
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(focusedText(), 'Yes');
  });

  testWidgets('choice dialog lands focus on the first option', (tester) async {
    await pumpHost(tester, (context) {
      dialogs.showCommonDialog<void>(
        context: context,
        child: const CommonDialog(
          title: 'Pick',
          overrideScroll: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListItem(title: Text('Alpha'), onTap: _noop),
              ListItem(title: Text('Beta'), onTap: _noop),
            ],
          ),
        ),
      );
    });
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(focusedText(), 'Alpha');
  });

  testWidgets('sheet lands focus on the first body control, not close', (
    tester,
  ) async {
    await pumpHost(tester, (context) {
      showSheet<void>(
        context: context,
        builder: (_) => const SizedBox(
          height: 300,
          child: AdaptiveSheetScaffold(
            title: 'Sheet',
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListItem(title: Text('One'), onTap: _noop),
                ListItem(title: Text('Two'), onTap: _noop),
              ],
            ),
          ),
        ),
      );
    });
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(focusedText(), 'One');
  });
}
