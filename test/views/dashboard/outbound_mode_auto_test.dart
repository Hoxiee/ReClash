import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/outbound_mode.dart';

import '../../helpers/preferences.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

class _FixedStatus extends RcxStatusState {
  _FixedStatus(this.status);

  final RcxStatus? status;

  @override
  RcxStatus? build() => status;
}

class _RecordingAction extends RcxRoutingAction {
  final manualCalls = <bool>[];

  @override
  Future<void> setManualMode(bool manual) async {
    manualCalls.add(manual);
  }
}

void main() {
  late AppLocalizations l;
  late _RecordingAction action;

  setUpAll(() async {
    await mockPreferences();
    l = await AppLocalizations.load(const Locale('en'));
  });

  Future<void> pump(WidgetTester tester, RcxStatus? status) async {
    action = _RecordingAction();
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        rcxStatusStateProvider.overrideWith(() => _FixedStatus(status)),
        rcxRoutingActionProvider.overrideWith(() => action),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: OutboundModeCard()),
      ),
    );
    await tester.pump();
  }

  testWidgets('offers Auto while a scenario holds the mode', (tester) async {
    await pump(
      tester,
      const RcxStatus(
        scenario: RcxScenarioStatus(id: 'user/a', holdsMode: true),
      ),
    );

    expect(find.text(l.rcxModeAuto), findsOneWidget);
  });

  testWidgets('has no Auto without a scenario', (tester) async {
    await pump(tester, const RcxStatus());

    expect(find.text(l.rcxModeAuto), findsNothing);
  });

  testWidgets('tapping Auto while the user holds the mode clears manual', (
    tester,
  ) async {
    await pump(
      tester,
      const RcxStatus(
        scenario: RcxScenarioStatus(
          id: 'user/a',
          holdsMode: true,
          manual: true,
        ),
      ),
    );

    await tester.tap(find.text(l.rcxModeAuto));
    await tester.pump();

    expect(action.manualCalls, [false]);
  });
}
