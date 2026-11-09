import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/features/doctor/cause.dart';
import 'package:reclash/features/power/face.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/provider_power_labels.dart';
import 'package:reclash/ui/icons/app_glyphs.dart';
import 'package:reclash/views/dashboard/simple/home_view.dart';
import 'package:reclash/views/dashboard/simple/power_button.dart';
import 'package:reclash/widgets/icon.dart';

import '../../../helpers/test_app.dart';

const _english = Locale('en');

Widget _status(
  PowerFace face, {
  ProviderPowerLabel? custom,
  ValueChanged<PowerAction>? onFix,
}) => TestApp(
  locale: _english,
  child: Scaffold(
    body: Center(
      child: PowerStatusView(
        face: face,
        custom: custom,
        pausedHint: null,
        live: const Text('LIVE'),
        onFix: onFix,
      ),
    ),
  ),
);

PowerFace _ending({PowerAction? fix}) => PowerFace(
  state: PowerFaceState.ending,
  link: PowerLink.off,
  tone: PowerTone.attention,
  tap: PowerAction.start,
  fix: fix,
  attention: const AccountAttention.days(2),
);

void main() {
  group('PowerStatusView', () {
    testWidgets('an off face shows its title and the connect hint', (
      tester,
    ) async {
      await tester.pumpWidget(_status(PowerFace.plain(PowerLink.off)));
      expect(find.text('Not protected'), findsOneWidget);
      expect(find.text('Tap to connect'), findsOneWidget);
    });

    testWidgets('an ending face offers renewal with the days left', (
      tester,
    ) async {
      await tester.pumpWidget(_status(_ending(fix: PowerAction.renew)));
      expect(find.text('2 days left'), findsOneWidget);
      expect(find.text('Renew'), findsOneWidget);
    });

    testWidgets('a grace face names the ended subscription in its pill', (
      tester,
    ) async {
      await tester.pumpWidget(
        _status(
          const PowerFace(
            state: PowerFaceState.grace,
            link: PowerLink.on,
            tone: PowerTone.attention,
            tap: PowerAction.stop,
            fix: PowerAction.renew,
            cause: FailureCause.subscriptionExpired,
          ),
        ),
      );
      expect(find.text('Subscription ended'), findsOneWidget);
      expect(find.text('Renew'), findsOneWidget);
    });

    testWidgets('an ending face with support shows only the days left', (
      tester,
    ) async {
      await tester.pumpWidget(_status(_ending(fix: PowerAction.support)));
      expect(find.text('2 days left'), findsOneWidget);
      expect(find.textContaining('Contact support'), findsNothing);
    });

    testWidgets('tapping the pill reports its fix action', (tester) async {
      final fixes = <PowerAction>[];
      await tester.pumpWidget(
        _status(_ending(fix: PowerAction.renew), onFix: fixes.add),
      );
      await tester.tap(find.byType(PowerPillView));
      expect(fixes, [PowerAction.renew]);
    });

    testWidgets('a checking face hides the fix and shows the checking hint', (
      tester,
    ) async {
      await tester.pumpWidget(
        _status(
          const PowerFace(
            state: PowerFaceState.expired,
            link: PowerLink.off,
            tone: PowerTone.problem,
            tap: PowerAction.start,
            fix: PowerAction.renew,
            checking: true,
          ),
          onFix: (_) {},
        ),
      );
      expect(find.text('Checking the subscription…'), findsOneWidget);
      expect(find.byType(PowerPillView), findsNothing);
    });

    testWidgets('a plain on face shows the live line', (tester) async {
      await tester.pumpWidget(_status(PowerFace.plain(PowerLink.on)));
      expect(find.text('Protected'), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
    });

    testWidgets('a provider label replaces the title', (tester) async {
      await tester.pumpWidget(
        _status(
          PowerFace.plain(PowerLink.off),
          custom: const ProviderPowerLabel('Shielded'),
        ),
      );
      expect(find.text('Shielded'), findsOneWidget);
      expect(find.text('Not protected'), findsNothing);
    });
  });

  group('SimplePowerView', () {
    testWidgets('every face state lays out within a phone surface', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final state in PowerFaceState.values) {
        for (final fix in [null, PowerAction.renew, PowerAction.causeSheet]) {
          final face = PowerFace(
            state: state,
            link: PowerLink.on,
            tone: PowerTone.problem,
            tap: PowerAction.stop,
            fix: fix,
            attention: const AccountAttention.days(2),
          );
          await tester.pumpWidget(
            TestApp(
              locale: _english,
              child: Scaffold(
                body: SimplePowerView(
                  minSize: 152,
                  maxSize: 240,
                  face: face,
                  onPressed: () {},
                  logo: '',
                  images: const AppProviderImages(),
                  look: defaultProviderPowerButton,
                  status: PowerStatusView(
                    face: face,
                    custom: null,
                    pausedHint: null,
                    live: const Text('LIVE'),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '$state/$fix');
        }
      }
    });
  });

  group('powerBadge', () {
    test('a verified connection shows the check badge', () {
      const face = PowerFace(
        state: PowerFaceState.on,
        link: PowerLink.on,
        tone: PowerTone.normal,
        tap: PowerAction.stop,
        verified: true,
      );
      expect(
        powerBadge(face),
        const PowerBadge(AppGlyphs.check, PowerTone.normal),
      );
    });

    test('an unverified connection has no badge', () {
      expect(powerBadge(PowerFace.plain(PowerLink.on)), isNull);
    });

    test('a locked account shows the lock badge in the failure tone', () {
      const face = PowerFace(
        state: PowerFaceState.accountLocked,
        link: PowerLink.off,
        tone: PowerTone.failure,
        tap: PowerAction.accountSheet,
        fix: PowerAction.renew,
        cause: FailureCause.subscriptionExpired,
      );
      expect(
        powerBadge(face),
        const PowerBadge(AppGlyphs.lock, PowerTone.failure),
      );
    });
  });

  group('powerLabelState', () {
    test('maps the states that a provider label may replace', () {
      const cases = <(PowerFaceState, String?)>[
        (PowerFaceState.accountLocked, 'expired'),
        (PowerFaceState.verifying, 'connecting'),
        (PowerFaceState.broken, null),
      ];
      for (final (state, label) in cases) {
        final face = PowerFace(
          state: state,
          link: PowerLink.on,
          tone: PowerTone.normal,
          tap: PowerAction.stop,
        );
        expect(powerLabelState(face), label, reason: '$state');
      }
    });
  });
}
