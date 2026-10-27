import 'package:reclash/manager/app_manager.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/state.dart';
import 'package:reclash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    globalState.appEnv = 'stable';
  });

  Future<void> pump(
    WidgetTester tester, {
    required bool safeMode,
    bool sandbox = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          safeModeProvider.overrideWithValue(safeMode),
          sandboxProvider.overrideWithValue(sandbox),
        ],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: AppEnvManager(child: SizedBox(key: Key('child'))),
        ),
      ),
    );
  }

  testWidgets('a stable build carries no banner', (tester) async {
    await pump(tester, safeMode: false);

    expect(find.byKey(const Key('child')), findsOneWidget);
    expect(find.byType(Banner), findsNothing);
  });

  testWidgets('a safe mode build is bannered on any channel', (tester) async {
    await pump(tester, safeMode: true);

    final banner = tester.widget<Banner>(find.byType(Banner));
    expect(banner.message, 'SAFE MODE');
    expect(find.byKey(const Key('child')), findsOneWidget);
  });

  testWidgets('a test subscription is bannered', (tester) async {
    await pump(tester, safeMode: false, sandbox: true);

    expect(tester.widget<Banner>(find.byType(Banner)).message, 'TEST');
  });
}
