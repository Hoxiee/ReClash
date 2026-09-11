import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/profiles/add.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/widgets/widgets.dart';

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../helpers/test_app.dart';

ProviderContainer _containerFor(WidgetTester tester) {
  const size = Size(1400, 1000);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  return container;
}

void main() {
  testWidgets('shows LAN import only on TV', (tester) async {
    final container = _containerFor(tester);
    addTearDown(() => system.isTVForTesting = false);

    Future<void> pump() async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: Scaffold(body: AddProfileView(key: UniqueKey())),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    system.isTVForTesting = false;
    await pump();
    expect(find.byKey(const Key('lan-profile-import')), findsNothing);

    system.isTVForTesting = true;
    await pump();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ListItem && widget.key == const Key('lan-profile-import'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('LAN import dialog closes its listener on dispose', (
    tester,
  ) async {
    final container = _containerFor(tester);
    final imported = <SubscriptionImportTarget>[];

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => LanProfileImportDialog(
                    address: InternetAddress.loopbackIPv4,
                    onImport: (target) async => imported.add(target),
                  ),
                ),
                child: const Text('open LAN import'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open LAN import'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(QrImageView), findsOneWidget);
    final address = tester.widget<SelectableText>(find.byType(SelectableText));
    expect(address.data, contains('http://127.0.0.1:'));

    await tester.tap(find.text(currentAppLocalizations.close));
    await tester.pumpAndSettle();

    expect(find.byType(LanProfileImportDialog), findsNothing);
    expect(imported, isEmpty);
  });

  testWidgets('lists the QR code, file, and URL import entries', (
    tester,
  ) async {
    final container = _containerFor(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(builder: (context) => const AddProfileView()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.qrcode), findsOne);
    expect(find.text(l10n.file), findsOne);
    expect(find.text(l10n.url), findsOne);
    expect(find.text(l10n.setupRawConfig), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('raw configuration dialog validates and returns content', (
    tester,
  ) async {
    final container = _containerFor(tester);
    String? popped;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  popped = await showDialog<String>(
                    context: context,
                    builder: (_) => const RawProfileDialog(),
                  );
                },
                child: const Text('open raw'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open raw'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.submit));
    await tester.pump();
    expect(find.text(currentAppLocalizations.contentNotEmpty), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'proxies: []');
    await tester.tap(find.text(currentAppLocalizations.submit));
    await tester.pumpAndSettle();

    expect(popped, 'proxies: []');
    expect(find.byType(RawProfileDialog), findsNothing);
  });

  testWidgets('URL import dialog rejects an empty value and keeps the sheet', (
    tester,
  ) async {
    final container = _containerFor(tester);
    URLFormDialogResult? popped;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  popped = await showDialog<URLFormDialogResult>(
                    context: context,
                    builder: (_) => const URLFormDialog(),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(URLFormDialog), findsOne);

    await tester.tap(find.text(currentAppLocalizations.submit));
    await tester.pumpAndSettle();

    expect(
      find.byType(URLFormDialog),
      findsOne,
      reason: 'an empty URL must not close the dialog',
    );
    expect(popped, isNull);
    expect(tester.takeException(), null);
  });

  testWidgets('URL import dialog returns the entered value', (tester) async {
    final container = _containerFor(tester);
    URLFormDialogResult? popped;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  popped = await showDialog<URLFormDialogResult>(
                    context: context,
                    builder: (_) => const URLFormDialog(),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'https://example.com/profile',
    );
    await tester.tap(find.text(currentAppLocalizations.submit));
    await tester.pumpAndSettle();

    expect(find.byType(URLFormDialog), findsNothing);
    expect(popped?.url, 'https://example.com/profile');
    expect(popped?.client, SubscriptionClient.auto);
    expect(popped?.customUserAgent, '');
    expect(tester.takeException(), null);
  });

  testWidgets('URL import dialog hides presets until expanded', (tester) async {
    final container = _containerFor(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  await showDialog<URLFormDialogResult>(
                    context: context,
                    builder: (_) => const URLFormDialog(),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(
      find.text(currentAppLocalizations.subscriptionClientAuto),
      findsNothing,
    );
    expect(
      find.text(currentAppLocalizations.subscriptionClientHapp),
      findsNothing,
    );

    await tester.tap(find.byTooltip(currentAppLocalizations.showMore));
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.subscriptionClientAuto), findsOne);
    expect(find.byType(TextField), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('URL import dialog follows the picked preset', (tester) async {
    final container = _containerFor(tester);
    URLFormDialogResult? popped;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  popped = await showDialog<URLFormDialogResult>(
                    context: context,
                    builder: (_) => const URLFormDialog(),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(currentAppLocalizations.showMore));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'https://example.com/profile',
    );
    await tester.tap(find.text(currentAppLocalizations.subscriptionClientHapp));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text(currentAppLocalizations.submit), findsOne);

    await tester.tap(find.text(currentAppLocalizations.submit));
    await tester.pumpAndSettle();

    expect(find.byType(URLFormDialog), findsNothing);
    expect(popped?.client, SubscriptionClient.happ);
    expect(tester.takeException(), null);
  });
}
