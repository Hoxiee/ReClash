import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/views/dashboard/widgets/goroutine_info.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_app.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

void main() {
  testWidgets('GoroutineInfo displays and refreshes the count', (tester) async {
    var count = 2;

    Future<int> readCount() async => count;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => Scaffold(body: child),
        child: GoroutineInfo(countReader: readCount),
      ),
    );
    await tester.pump();

    expect(find.text('2'), findsOneWidget);

    count = 5;
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('5'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the default reader queries the Core while connected', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.getGoroutineCount()).thenAnswer((_) async => 12);
    final container = _containerWith(coreInterface, CoreStatus.connected);
    addTearDown(container.dispose);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          homeBuilder: _scaffoldBody,
          child: GoroutineInfo(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    verify(
      () => coreInterface.getGoroutineCount(),
    ).called(greaterThanOrEqualTo(1));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the default reader skips the Core while disconnected', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.getGoroutineCount()).thenAnswer((_) async => 12);
    final container = _containerWith(coreInterface, CoreStatus.disconnected);
    addTearDown(container.dispose);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          homeBuilder: _scaffoldBody,
          child: GoroutineInfo(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    verifyNever(() => coreInterface.getGoroutineCount());

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Widget _scaffoldBody(Widget child) => Scaffold(body: child);

ProviderContainer _containerWith(
  CoreHandlerInterface coreInterface,
  CoreStatus status,
) {
  final container = ProviderContainer(
    overrides: [
      coreHandlerProvider.overrideWithValue(
        CoreController.scoped(coreInterface),
      ),
    ],
  );
  container.read(coreStatusProvider.notifier).value = status;
  return container;
}
