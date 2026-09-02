import 'package:reclash/common/common.dart';
import 'package:reclash/core/core.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/manager/app_manager.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/state.dart';
import 'package:flutter/widgets.dart' show SizedBox;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

const _debounce = Duration(milliseconds: 700);

void main() {
  late _MockCoreHandlerInterface coreInterface;
  late List<String> calls;

  setUp(() {
    calls = [];
    coreInterface = _MockCoreHandlerInterface();
    Future<bool> log(String name) async {
      calls.add(name);
      return true;
    }

    when(() => coreInterface.pauseTun()).thenAnswer((_) => log('pause'));
    when(() => coreInterface.resumeTun()).thenAnswer((_) => log('resume'));
    when(
      () => coreInterface.closeConnections(),
    ).thenAnswer((_) => log('close'));
  });

  tearDown(() {
    debouncer.cancel(FunctionTag.smartPause);
  });

  Future<ProviderContainer> pumpManager(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(
          CoreController.scoped(coreInterface),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AppStateManager(child: SizedBox()),
      ),
    );
    return container;
  }

  testWidgets('pausing on a trusted network tears the TUN down and back up', (
    tester,
  ) async {
    final container = await pumpManager(tester);
    container
        .read(vpnSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            smartPauseEnabled: true,
            smartPauseNetworks: ['Office'],
          ),
        );
    container.read(currentSSIDProvider.notifier).value = 'Office';
    await tester.pump(_debounce);
    expect(calls, isEmpty, reason: 'nothing runs while stopped');

    container.read(runTimeProvider.notifier).update((_) => 1);
    await tester.pump(_debounce);
    expect(calls, ['pause']);

    container.read(currentSSIDProvider.notifier).value = 'Cafe';
    await tester.pump(_debounce);
    expect(calls, ['pause', 'resume']);
  });

  testWidgets('connections are closed on pause only when asked', (
    tester,
  ) async {
    final container = await pumpManager(tester);
    container
        .read(vpnSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            smartPauseEnabled: true,
            smartPauseNetworks: ['Office'],
            smartPauseCloseConnections: true,
          ),
        );
    container.read(currentSSIDProvider.notifier).value = 'Office';
    container.read(runTimeProvider.notifier).update((_) => 1);
    await tester.pump(_debounce);

    container.read(currentSSIDProvider.notifier).value = 'Cafe';
    await tester.pump(_debounce);
    expect(calls, ['pause', 'close', 'resume']);
  });

  testWidgets('a manual pause on an untrusted network holds until stop', (
    tester,
  ) async {
    final container = await pumpManager(tester);
    container.read(runTimeProvider.notifier).update((_) => 1);
    await tester.pump(_debounce);
    expect(calls, ['resume'], reason: 'a plain start re-issues resume');

    container.read(manualPauseProvider.notifier).pause(['Cafe']);
    await tester.pump(_debounce);
    expect(calls, ['resume', 'pause']);

    container.read(runTimeProvider.notifier).update((_) => null);
    await tester.pump(_debounce);
    expect(calls, ['resume', 'pause']);
    expect(container.read(manualPauseProvider).paused, isFalse);
  });
}
