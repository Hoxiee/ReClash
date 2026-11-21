import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/core/controller.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

class _SeededReport extends SiteLockReportState {
  _SeededReport(this.seed);

  final SiteLockReport seed;

  @override
  SiteLockReport? build() => seed;
}

void main() {
  test('an unanswered push keeps the last report', () async {
    final core = _MockCore();
    const lock = SiteLock(
      id: 'lock',
      match: ['claude.ai'],
      exits: [SiteLockExit(type: 'ss', server: 'a.example', port: 443)],
    );
    const report = SiteLockReport(
      applied: true,
      locks: [SiteLockState(id: 'lock', status: SiteLockStatus.ready)],
    );
    when(() => core.setSiteLocks([lock])).thenAnswer((_) async => null);
    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        siteLockReportStateProvider.overrideWith(() => _SeededReport(report)),
      ],
    );
    addTearDown(container.dispose);

    final state = container.read(siteLockReportStateProvider.notifier);

    expect(await state.push([lock]), isNull);
    expect(state.state, report);
  });
}
