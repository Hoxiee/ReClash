import 'dart:async';

import 'package:reclash/models/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/pages/home.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

class _SystemAction extends SystemAction {
  int closes = 0;
  Completer<void>? pending;

  @override
  Future<void> handleClose([bool exit = true]) async {
    closes++;
    await pending?.future;
  }
}

void main() {
  late _SystemAction action;
  late List<MethodCall> tips;

  setUp(() {
    action = _SystemAction();
    tips = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('com.reclash/app'), (
          call,
        ) async {
          tips.add(call);
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('com.reclash/app'), null);
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    bool desktop = false,
    bool tv = false,
    Widget child = const Scaffold(body: Text('Home')),
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          systemActionProvider.overrideWith(() => action),
          shownPageLabelProvider.overrideWithValue(PageLabel.dashboard),
        ],
        child: TestApp(
          locale: const Locale('ru'),
          child: HomeBackScopeContainer(
            isDesktop: desktop,
            isAndroid: !desktop,
            isTV: tv,
            child: Shortcuts(
              shortcuts: const {
                SingleActivator(LogicalKeyboardKey.escape): EscapeBackIntent(),
              },
              child: Builder(
                builder: (context) => Actions(
                  actions: {
                    EscapeBackIntent: CallbackAction<EscapeBackIntent>(
                      onInvoke: (_) => Navigator.of(context).maybePop(),
                    ),
                  },
                  child: Focus(autofocus: true, child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pump();
  }

  testWidgets('desktop Escape never closes the root', (tester) async {
    await pumpHome(tester, desktop: true);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(action.closes, 0);
    expect(tips, isEmpty);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('desktop back dismisses a dialog without closing the app', (
    tester,
  ) async {
    await pumpHome(tester, desktop: true);
    final context = tester.element(find.text('Home'));
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => const AlertDialog(content: Text('Dialog')),
      ),
    );
    await tester.pumpAndSettle();
    await back(tester);
    await tester.pumpAndSettle();
    expect(find.text('Dialog'), findsNothing);
    expect(action.closes, 0);
  });

  testWidgets('Android root back prompts natively and then closes once', (
    tester,
  ) async {
    action.pending = Completer<void>();
    await pumpHome(tester);
    await back(tester);
    expect(action.closes, 0);
    expect(tips.single.method, 'tip');
    expect(tips.single.arguments, {'message': 'Нажмите ещё раз, чтобы выйти'});
    await tester.pump(const Duration(milliseconds: 1900));
    await back(tester);
    await back(tester);
    expect(action.closes, 1);
    expect(tips, hasLength(1));
    action.pending!.complete();
    await tester.pump();
  });

  testWidgets('Android nested routes go back without prompting to exit', (
    tester,
  ) async {
    await pumpHome(tester);
    final context = tester.element(find.text('Home'));
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('Details')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await back(tester);
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsNothing);
    expect(find.text('Home'), findsOneWidget);
    expect(tips, isEmpty);
    expect(action.closes, 0);
  });

  testWidgets('failed native prompt does not arm exit', (tester) async {
    await pumpHome(tester);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('com.reclash/app'), (
          call,
        ) async {
          throw PlatformException(code: 'unavailable');
        });
    final scope = tester.widget<CommonPopScope>(find.byType(CommonPopScope));
    final context = tester.element(find.byType(CommonPopScope));
    await expectLater(
      Future<bool>.sync(() => scope.onPop!(context)),
      throwsA(isA<PlatformException>()),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('com.reclash/app'), (
          call,
        ) async {
          tips.add(call);
          return true;
        });
    await back(tester);
    expect(tips, hasLength(1));
    expect(action.closes, 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Android confirmation expires after two seconds', (tester) async {
    await pumpHome(tester);
    await back(tester);
    await tester.pump(const Duration(seconds: 2));
    await back(tester);
    expect(action.closes, 0);
    expect(tips, hasLength(2));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('backgrounding resets Android confirmation', (tester) async {
    await pumpHome(tester);
    await back(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await back(tester);
    expect(action.closes, 0);
    expect(tips, hasLength(2));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('failed close can be retried with a fresh confirmation', (
    tester,
  ) async {
    await pumpHome(tester);
    await back(tester);
    action.pending = Completer<void>();
    final scope = tester.widget<CommonPopScope>(find.byType(CommonPopScope));
    final context = tester.element(find.byType(CommonPopScope));
    final closing = Future<bool>.sync(() => scope.onPop!(context));
    final failed = expectLater(closing, throwsStateError);
    action.pending!.completeError(StateError('close failed'));
    await failed;
    action.pending = null;
    await back(tester);
    expect(action.closes, 1);
    await back(tester);
    expect(action.closes, 2);
  });
}
