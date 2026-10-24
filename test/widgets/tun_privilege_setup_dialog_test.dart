import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/core/desktop/privilege.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/widgets/tun_privilege_setup_dialog.dart';

import '../helpers/test_app.dart';

class _FakeSetupAction extends SetupAction {
  final List<Completer<Object?>> authorizations = [];
  final List<bool> tunChanges = [];

  @override
  Future<Object?> authorizeTun() {
    final completer = Completer<Object?>();
    authorizations.add(completer);
    return completer.future;
  }

  @override
  Future<void> setTunEnabled(bool enabled) async => tunChanges.add(enabled);
}

void main() {
  late _FakeSetupAction setupAction;
  late ProviderContainer container;

  setUp(() {
    setupAction = _FakeSetupAction();
    container = ProviderContainer(
      overrides: [setupActionProvider.overrideWith(() => setupAction)],
    );
  });

  tearDown(() => container.dispose());

  Future<void> open(
    WidgetTester tester, {
    DesktopPrivilegeSetup setup = DesktopPrivilegeSetup.install,
    String platform = 'linux',
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showFloatingDialog<void>(
                  context: context,
                  dismissible: false,
                  child: TunPrivilegeSetupDialog(
                    setup: setup,
                    platform: platform,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('explains a Linux install before any system prompt', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Set up TUN'), findsOneWidget);
    expect(
      find.text('The administrator password is needed once for this version'),
      findsOneWidget,
    );
    expect(setupAction.authorizations, isEmpty);
  });

  testWidgets('an update offers to update and a Windows service', (
    tester,
  ) async {
    await open(
      tester,
      setup: DesktopPrivilegeSetup.update,
      platform: 'windows',
    );
    expect(find.text('Update the TUN helper'), findsOneWidget);
    expect(find.textContaining('ReClash Service'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Update'), findsOneWidget);
  });

  testWidgets('confirming locks the dialog until the setup settles', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Set up'));
    await tester.pump();
    expect(setupAction.authorizations, hasLength(1));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Not now'))
          .onPressed,
      isNull,
    );
    setupAction.authorizations.single.complete(null);
    await tester.pumpAndSettle();
    expect(find.byType(TunPrivilegeSetupDialog), findsNothing);
  });

  testWidgets('a failed setup stays open with its reason and a retry', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Set up'));
    await tester.pump();
    setupAction.authorizations.single.complete(
      const DesktopPrivilegeException('linux_cancelled'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TunPrivilegeSetupDialog), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(setupAction.authorizations, hasLength(2));
    setupAction.authorizations.last.complete(null);
    await tester.pumpAndSettle();
  });

  testWidgets('not now quiets the prompt until TUN is asked for again', (
    tester,
  ) async {
    container
        .read(tunPrivilegeSetupProvider.notifier)
        .request(DesktopPrivilegeSetup.install, explicit: false);
    await open(tester);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    final setup = container.read(tunPrivilegeSetupProvider.notifier);
    expect(container.read(tunPrivilegeSetupProvider), isNull);
    setup.request(DesktopPrivilegeSetup.install, explicit: false);
    expect(container.read(tunPrivilegeSetupProvider), isNull);
    setup.request(DesktopPrivilegeSetup.install, explicit: true);
    expect(
      container.read(tunPrivilegeSetupProvider),
      DesktopPrivilegeSetup.install,
    );
    expect(setupAction.authorizations, isEmpty);
  });

  testWidgets('without TUN turns TUN off instead of installing', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Without TUN'));
    await tester.pumpAndSettle();
    expect(setupAction.tunChanges, [false]);
    expect(setupAction.authorizations, isEmpty);
  });

  testWidgets('an unavailable backend offers no setup', (tester) async {
    await open(tester, setup: DesktopPrivilegeSetup.unavailable);
    expect(find.text('Set up'), findsNothing);
    expect(find.text('Without TUN'), findsOneWidget);
  });
}
