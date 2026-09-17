import 'dart:async';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/profiles/add.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/widgets/widgets.dart';

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../helpers/test_app.dart';

ProviderContainer _containerFor(WidgetTester tester, {ProfilesAction? action}) {
  const size = Size(1400, 1000);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      if (action != null) profilesActionProvider.overrideWith(() => action),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  return container;
}

const _importedProfile = Profile(id: 99, autoUpdateDuration: Duration(days: 1));
const _imported = ProfileImportResult.imported(
  _importedProfile,
  ProfileImportSummary(
    format: ProfileImportFormat.clash,
    nodeCount: 1,
    groupCount: 1,
    hasProviders: false,
  ),
);

class _ImportAction extends ProfilesAction {
  _ImportAction(this.result, {this.warning = false});

  final Future<ProfileImportResult> result;
  final bool warning;
  int calls = 0;

  @override
  Future<ProfileImportResult> importProfile(
    ProfileImportRequest request,
  ) async {
    calls++;
    final value = await result;
    if (warning) {
      unawaited(
        dialogs.showMessage(
          message: const TextSpan(text: 'provider warning'),
          cancelable: false,
        ),
      );
    }
    return value;
  }
}

void main() {
  for (final fullPage in <bool?>[null, false, true]) {
    testWidgets(
      'import notifies its ${fullPage == null
          ? 'wizard'
          : fullPage
          ? 'page'
          : 'sheet'} owner after the form closes',
      (tester) async {
        final completion = Completer<ProfileImportResult>();
        final action = _ImportAction(
          completion.future,
          warning: fullPage != null,
        );
        final container = _containerFor(tester, action: action);
        var notifications = 0;
        ModalRoute<dynamic>? formRoute;
        bool? formWasActive;
        Widget chooser() => Builder(
          builder: (chooserContext) => AddProfileView(
            onProfileAdded: (_) {
              notifications++;
              formWasActive = formRoute?.isActive;
              if (fullPage != null) closeProfileImportRoute(chooserContext);
            },
          ),
        );
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: TestApp(
              child: Scaffold(
                body: fullPage == null
                    ? chooser()
                    : Builder(
                        builder: (context) => TextButton(
                          onPressed: () => showExtend<void>(
                            context,
                            props: ExtendProps(forceFull: fullPage),
                            builder: (_) => AdaptiveSheetScaffold(
                              title: 'chooser',
                              body: chooser(),
                            ),
                          ),
                          child: const Text('open chooser'),
                        ),
                      ),
              ),
            ),
          ),
        );
        if (fullPage != null) {
          await tester.tap(find.text('open chooser'));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text(currentAppLocalizations.url));
        await tester.pumpAndSettle();
        formRoute = ModalRoute.of(tester.element(find.byType(URLFormDialog)));
        await tester.enterText(
          find.byType(TextField).first,
          'https://example.com/sub',
        );
        await tester.tap(find.text(currentAppLocalizations.submit));
        await tester.pump();
        expect(notifications, 0);
        completion.complete(_imported);
        await tester.pumpAndSettle();
        expect(action.calls, 1);
        expect(notifications, 1);
        expect(formWasActive, false);
        expect(find.byType(URLFormDialog), findsNothing);
        if (fullPage == null) {
          expect(find.byType(AddProfileView), findsOneWidget);
        } else {
          expect(find.byType(AddProfileView), findsNothing);
          expect(find.text('provider warning'), findsOneWidget);
          await tester.tap(find.text(currentAppLocalizations.confirm));
          await tester.pumpAndSettle();
          expect(find.text('open chooser'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

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
    expect(find.text(currentAppLocalizations.qrcode), findsNothing);
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
                    onImport: (target) async {
                      imported.add(target);
                      return true;
                    },
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
                  await showDialog<Profile>(
                    context: context,
                    builder: (_) => RawProfileDialog(
                      onSubmit: (content) async {
                        popped = content;
                        return _imported;
                      },
                    ),
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
                  await showDialog<Profile>(
                    context: context,
                    builder: (_) => URLFormDialog(
                      onSubmit: (value) async {
                        popped = value;
                        return _imported;
                      },
                    ),
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
                  await showDialog<Profile>(
                    context: context,
                    builder: (_) => URLFormDialog(
                      onSubmit: (value) async {
                        popped = value;
                        return _imported;
                      },
                    ),
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
                  await showDialog<Profile>(
                    context: context,
                    builder: (_) =>
                        URLFormDialog(onSubmit: (_) async => _imported),
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
                  await showDialog<Profile>(
                    context: context,
                    builder: (_) => URLFormDialog(
                      onSubmit: (value) async {
                        popped = value;
                        return _imported;
                      },
                    ),
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

  for (final raw in [false, true]) {
    testWidgets(
      '${raw ? 'raw' : 'URL'} submit preserves failures and blocks duplicates',
      (tester) async {
        final container = _containerFor(tester);
        var completion = Completer<ProfileImportResult>();
        var calls = 0;
        Future<ProfileImportResult> submit(Object _) {
          calls++;
          return completion.future;
        }

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: TestApp(
              child: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showDialog<Profile>(
                      context: context,
                      builder: (_) => raw
                          ? RawProfileDialog(onSubmit: submit)
                          : URLFormDialog(onSubmit: submit),
                    ),
                    child: const Text('open async'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open async'));
        await tester.pumpAndSettle();
        final input = raw ? 'proxies: []' : 'https://example.com/sub';
        await tester.enterText(find.byType(TextField).first, input);
        await tester.tap(find.text(currentAppLocalizations.submit));
        await tester.pump();
        expect(calls, 1);
        final submitButton = tester.widget<TextButton>(
          find.byType(TextButton).last,
        );
        expect(submitButton.onPressed, isNull);
        if (!raw) {
          tester.widget<TextField>(find.byType(TextField).first).onSubmitted!(
            input,
          );
          await tester.pump();
          expect(calls, 1);
        }
        completion.complete(
          const ProfileImportResult.failed(ProfileImportFailure.invalidConfig),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextField>(find.byType(TextField).first)
              .controller!
              .text,
          input,
        );
        expect(find.text(currentAppLocalizations.submit), findsOneWidget);

        completion = Completer<ProfileImportResult>();
        await tester.tap(find.text(currentAppLocalizations.submit));
        await tester.pump();
        completion.complete(const ProfileImportResult.cancelled());
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextField>(find.byType(TextField).first)
              .controller!
              .text,
          input,
        );

        completion = Completer<ProfileImportResult>();
        await tester.tap(find.text(currentAppLocalizations.submit));
        await tester.pump();
        completion.complete(_imported);
        await tester.pumpAndSettle();
        expect(calls, 3);
        expect(
          find.byType(raw ? RawProfileDialog : URLFormDialog),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '${raw ? 'raw' : 'URL'} submit cleans up exceptions and disposal',
      (tester) async {
        final container = _containerFor(tester);
        final completion = Completer<ProfileImportResult>();
        var calls = 0;
        Future<ProfileImportResult> submit(Object _) {
          calls++;
          if (calls == 1) throw StateError('test failure');
          return completion.future;
        }

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: TestApp(
              child: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showDialog<Profile>(
                      context: context,
                      builder: (_) => raw
                          ? RawProfileDialog(onSubmit: submit)
                          : URLFormDialog(onSubmit: submit),
                    ),
                    child: const Text('open async'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open async'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextField).first,
          raw ? 'proxies: []' : 'https://example.com/sub',
        );
        await tester.tap(find.text(currentAppLocalizations.submit));
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextButton>(find.byType(TextButton).last).onPressed,
          isNotNull,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(currentAppLocalizations.submit));
        await tester.pump();
        globalState.navigatorKey.currentState!.pop();
        await tester.pumpAndSettle();
        completion.complete(_imported);
        await tester.pumpAndSettle();
        expect(find.text('open async'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('success closes its form beneath a warning, never the warning', (
    tester,
  ) async {
    final container = _containerFor(tester);
    Profile? result;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showDialog<Profile>(
                    context: context,
                    builder: (formContext) => URLFormDialog(
                      onSubmit: (_) async {
                        unawaited(
                          showDialog<void>(
                            context: formContext,
                            builder: (warningContext) => AlertDialog(
                              content: const Text('import warning'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(warningContext).pop(),
                                  child: const Text('dismiss warning'),
                                ),
                              ],
                            ),
                          ),
                        );
                        return _imported;
                      },
                    ),
                  );
                },
                child: const Text('open warning test'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open warning test'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).first,
      'https://example.com/sub',
    );
    await tester.tap(find.text(currentAppLocalizations.submit));
    await tester.pumpAndSettle();
    expect(result, _importedProfile);
    expect(find.byType(URLFormDialog), findsNothing);
    expect(find.text('import warning'), findsOneWidget);
    await tester.tap(find.text('dismiss warning'));
    await tester.pumpAndSettle();
    expect(find.text('open warning test'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
