import 'dart:async';
import 'dart:typed_data';

import 'package:reclash/common/common.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/manager/status_manager.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/external_link.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/protocol/codec.dart';
import 'package:reclash/views/disclaimer.dart';
import 'package:reclash/widgets/profile_import_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

Future<ProviderContainer> _pumpHost(
  WidgetTester tester, {
  Widget Function(Widget child)? homeBuilder,
  Size size = const Size(1000, 800),
  bool remote = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: RemoteFocusAdapter(
        enabled: remote,
        child: TestApp(
          homeBuilder: homeBuilder ?? (child) => child,
          child: const Scaffold(body: SizedBox.shrink()),
        ),
      ),
    ),
  );
  await tester.pump();
  return container;
}

ProfileLinkPreview _preview({String? announce}) {
  final draft = Profile.normal(url: 'https://sub.example/sub');
  final metadata = SubscriptionMetadata({
    'provider.name': 'Acme VPN',
    'provider.announce': ?announce,
  });
  return (
    draft: draft,
    prepared: PreparedSubscriptionUpdate(
      profileId: draft.id,
      sourceUrl: draft.url,
      sourceAgeSecretKey: '',
      sourcePreferences: draft.subscriptionPreferences,
      payload: SubscriptionImportResult(
        bytes: Uint8List(0),
        format: SubscriptionFormat.clash,
        summary: const SubscriptionImportSummary(nodes: 14),
      ),
      metadata: SubscriptionMetadataResult(
        metadata: metadata,
        source: SubscriptionDataSource.http,
      ),
      subscriptionInfo: const SubscriptionInfo(
        download: 1 << 30,
        total: 100 << 30,
      ),
      snapshot: SubscriptionSnapshot(
        metadata: metadata,
        receivedAt: DateTime.utc(2026),
      ),
      label: 'Acme Home',
      client: SubscriptionClientPreset.clash,
    ),
  );
}

FilledButton _disclaimerAgreeButton(WidgetTester tester) {
  return tester.widget<FilledButton>(
    find.descendant(
      of: find.byType(DisclaimerView),
      matching: find.byType(FilledButton),
    ),
  );
}

Future<void> _scrollDisclaimerTo(WidgetTester tester, Offset offset) async {
  await tester.drag(
    find
        .descendant(
          of: find.byType(DisclaimerView),
          matching: find.byType(Scrollable),
        )
        .first,
    offset,
  );
  await tester.pumpAndSettle();
}

Future<void> _agree(WidgetTester tester) async {
  await tester.tap(find.text('Agree'));
  await tester.pumpAndSettle();
}

/// The real manager stack mounts [StatusManager] above the app navigator, so
/// [Dialogs.showNotifier] can reach it from `navigatorKey.currentContext`.
Future<void> _pumpStatusManagerHost(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1000, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container
      .read(viewSizeProvider.notifier)
      .update((_) => const Size(1000, 800));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: globalState.navigatorKey,
        localizationsDelegates: const [AppLocalizations.delegate],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        builder: (context, child) {
          globalState.measure = Measure.of(context, 1);
          return StatusManager(child: child!);
        },
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  for (final scheme in ['happ', 'incy']) {
    testWidgets('$scheme import offers its own format beside the ReClash one', (
      tester,
    ) async {
      await _pumpHost(tester);
      final l10n = currentAppLocalizations;
      const url = 'https://sub.example/private?token=secret';
      final source = await tester.runAsync(
        () => resolveProfileLink(
          '$scheme://add/${Uri.encodeComponent(url)}?name=Home',
        ),
      );
      final result = showProfileImportDialog(source!);
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsWidgets);
      expect(find.text('sub.example'), findsWidgets);
      expect(find.textContaining('secret'), findsNothing);
      final native = scheme == 'happ'
          ? l10n.subscriptionClientHapp
          : l10n.subscriptionClientIncy;
      expect(find.text(native), findsOneWidget);
      expect(find.text(l10n.profileImportFormatClient(native)), findsOne);
      await tester.tap(find.text(l10n.subscriptionClientReclash));
      await tester.pump();
      await tester.tap(find.text(l10n.add));
      await tester.pumpAndSettle();

      final choice = await result;
      expect(choice?.clientSettings.preset, SubscriptionClientPreset.auto);
      expect(choice?.label, 'Home');
      expect(choice?.preview, isNull);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('import previews the subscription and hands the result on', (
    tester,
  ) async {
    await _pumpHost(tester);
    final l10n = currentAppLocalizations;
    final requested = <SubscriptionClientPreset>[];
    final pending = Completer<ProfileLinkPreview>();
    final preview = _preview(announce: 'Welcome aboard');
    final result = showProfileImportDialog(
      const ProfileLinkSource(
        url: 'https://sub.example/private?token=secret',
        preset: SubscriptionClientPreset.happ,
      ),
      preview: (source, settings, {cancellation}) {
        requested.add(settings.preset);
        return pending.future;
      },
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(requested, [SubscriptionClientPreset.happ]);
    expect(find.text(l10n.profileImportChecking), findsWidgets);

    pending.complete(preview);
    await tester.pumpAndSettle();

    expect(find.text('Acme VPN'), findsOneWidget);
    expect(find.text('Welcome aboard'), findsOneWidget);
    expect(find.text('14'), findsOneWidget);
    expect(
      find.textContaining(l10n.profileImportServerCount(14)),
      findsOneWidget,
    );
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'Acme Home',
    );
    await tester.enterText(find.byType(EditableText), 'Work');
    await tester.tap(find.text(l10n.add));
    await tester.pumpAndSettle();

    final choice = await result;
    expect(choice?.label, 'Work');
    expect(choice?.clientSettings.preset, SubscriptionClientPreset.happ);
    expect(choice?.preview, same(preview));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed preview can be retried and still imports', (
    tester,
  ) async {
    await _pumpHost(tester);
    final l10n = currentAppLocalizations;
    var calls = 0;
    final result = showProfileImportDialog(
      const ProfileLinkSource(url: 'https://sub.example/sub'),
      preview: (source, settings, {cancellation}) async {
        calls++;
        throw const SubscriptionUpdateCancelled();
      },
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.profileImportPreviewFailed), findsOneWidget);
    await tester.tap(find.text(l10n.retry));
    await tester.pumpAndSettle();
    expect(calls, 2);

    await tester.tap(find.text(l10n.add));
    await tester.pumpAndSettle();
    final choice = await result;
    expect(choice?.preview, isNull);
    expect(choice?.clientSettings.preset, SubscriptionClientPreset.auto);
  });

  testWidgets('an already added subscription is not fetched or offered', (
    tester,
  ) async {
    await _pumpHost(tester);
    final l10n = currentAppLocalizations;
    var calls = 0;
    final result = showProfileImportDialog(
      const ProfileLinkSource(url: 'https://sub.example/sub'),
      duplicateOf: 'Home',
      preview: (source, settings, {cancellation}) async {
        calls++;
        return _preview();
      },
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.profileImportAlreadyAdded('Home')), findsOneWidget);
    expect(find.text(l10n.add), findsNothing);
    expect(calls, 0);
    await tester.tap(find.text(l10n.close));
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });

  testWidgets('profile import dialog fits a narrow viewport', (tester) async {
    await _pumpHost(tester, size: const Size(320, 640));
    final result = showProfileImportDialog(
      const ProfileLinkSource(
        url: 'https://sub.example/private?token=secret',
        preset: SubscriptionClientPreset.incy,
      ),
      preview: (source, settings, {cancellation}) async =>
          _preview(announce: 'A long provider message ' * 6),
    );
    await tester.pumpAndSettle();

    expect(find.text('Acme VPN'), findsOneWidget);
    expect(tester.takeException(), isNull);
    Navigator.of(globalState.navigatorKey.currentContext!).pop();
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });

  testWidgets('Telegram links use a destination-aware dialog', (tester) async {
    await _pumpHost(tester);
    final l10n = currentAppLocalizations;
    final result = dialogs.openUrl('tg://resolve?domain=ReClash');
    await tester.pumpAndSettle();

    expect(find.text(l10n.telegramLinkTitle), findsOneWidget);
    expect(find.text('ReClash'), findsOneWidget);
    expect(find.text(l10n.telegramOpen), findsOneWidget);
    await tester.tap(find.text(l10n.cancel));
    await tester.pumpAndSettle();
    await result;
  });

  testWidgets('showMessage resolves true when confirmed', (tester) async {
    await _pumpHost(tester);

    final result = dialogs.showMessage(message: const TextSpan(text: 'body'));
    await tester.pumpAndSettle();

    expect(find.text('body'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(await result, isTrue);
    expect(tester.takeException(), null);
  });

  testWidgets('showMessage resolves false when cancelled', (tester) async {
    await _pumpHost(tester);

    final result = dialogs.showMessage(message: const TextSpan(text: 'body'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await result, isFalse);
  });

  testWidgets('showAlert offers a single acknowledging action', (tester) async {
    await _pumpHost(tester);

    final result = dialogs.showAlert(message: const TextSpan(text: 'body'));
    await tester.pumpAndSettle();

    expect(find.text('body'), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextButton),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    await result;
    expect(find.text('body'), findsNothing);
  });

  testWidgets('showMessage scrolls a long message only once the window is '
      'out of room', (tester) async {
    await _pumpHost(tester, size: const Size(1000, 1400));

    final result = dialogs.showMessage(
      message: TextSpan(
        text: List.filled(30, 'a line of the message').join(' '),
      ),
    );
    await tester.pumpAndSettle();

    final scrollables = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(Scrollable),
    );
    expect(scrollables, findsWidgets);
    for (final element in scrollables.evaluate()) {
      final state = (element as StatefulElement).state as ScrollableState;
      expect(state.position.maxScrollExtent, 0);
    }
    expect(
      tester.getSize(find.byType(SelectableText)).height,
      greaterThan(500),
    );

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('showMessage honours custom title and action labels', (
    tester,
  ) async {
    await _pumpHost(tester);

    final result = dialogs.showMessage(
      message: const TextSpan(text: 'body'),
      title: 'Custom title',
      confirmText: 'Go',
      cancelText: 'Back',
    );
    await tester.pumpAndSettle();

    expect(find.text('Custom title'), findsOneWidget);
    expect(find.text('Go'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });

  testWidgets('showCommonDialog returns the value the child pops', (
    tester,
  ) async {
    await _pumpHost(tester);

    final result = dialogs.showCommonDialog<String>(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).pop('picked'),
          child: const Text('pick'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('pick'));
    await tester.pumpAndSettle();

    expect(await result, 'picked');
  });

  testWidgets('a dialog stacked on a dialog brings its own scrim', (
    tester,
  ) async {
    await _pumpHost(tester);

    final result = dialogs.showCommonDialog<void>(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () {
            dialogs.showCommonDialog<void>(
              context: context,
              child: const Text('inner'),
            );
          },
          child: const Text('open inner'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final outer = tester.element(find.text('open inner'));
    final scrim = outer.colorScheme.alertScrim;
    expect(ModalRoute.of(outer)!.barrierColor, scrim);

    await tester.tap(find.text('open inner'));
    await tester.pumpAndSettle();
    final inner = tester.element(find.text('inner'));
    expect(ModalRoute.of(inner)!.barrierColor, scrim);
    expect(find.byType(BackdropFilter), findsNothing);

    Navigator.of(inner).pop();
    await tester.pumpAndSettle();
    Navigator.of(outer).pop();
    await tester.pumpAndSettle();
    await result;
  });

  testWidgets('showFailureDetails groups failures under their reason', (
    tester,
  ) async {
    await _pumpHost(tester);

    const longMessage =
        'failed to update provider because the Go core returned a very long '
        'error message that cannot fit on a single line';
    final result = dialogs.showFailureDetails(const [
      UpdatingMessage(label: 'profile-a', message: 'updated'),
      UpdatingMessage(label: 'profile-b', message: longMessage),
      UpdatingMessage(label: 'profile-c', message: longMessage),
    ]);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Error details'), findsOneWidget);
    expect(find.text('profile-a'), findsOneWidget);
    expect(find.text('profile-b'), findsOneWidget);
    expect(find.text('profile-c'), findsOneWidget);
    final messageText = tester.widget<Text>(find.text(longMessage));
    expect(messageText.maxLines, isNull);
    expect(
      tester.getTopLeft(find.text('profile-c')).dy,
      lessThan(tester.getTopLeft(find.text(longMessage)).dy),
    );
    expect(find.byGlyph(AppGlyphs.error), findsNothing);

    Navigator.of(tester.element(find.text('profile-a'))).pop();
    await tester.pumpAndSettle();
    await result;
    expect(find.text('profile-a'), findsNothing);
  });

  testWidgets(
    'requestDisclaimerConsent maps agree, exit, and back to a boolean',
    (tester) async {
      await _pumpHost(tester);

      final agreed = requestDisclaimerConsent();
      await tester.pumpAndSettle();
      expect(find.text('Data collection and privacy'), findsOneWidget);
      await _scrollDisclaimerTo(tester, const Offset(0, -100000));
      await _agree(tester);
      expect(await agreed, isTrue);

      final declined = requestDisclaimerConsent();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();
      expect(await declined, isFalse);

      final dismissed = requestDisclaimerConsent();
      await tester.pumpAndSettle();
      rootNavigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(await dismissed, isFalse);
    },
  );

  testWidgets('disclaimer agree unlocks only once the terms reach the end', (
    tester,
  ) async {
    await _pumpHost(tester);

    final agreed = requestDisclaimerConsent();
    await tester.pumpAndSettle();
    expect(find.text('Read to the end'), findsOneWidget);
    expect(_disclaimerAgreeButton(tester).onPressed, isNull);

    await _scrollDisclaimerTo(tester, const Offset(0, -300));
    expect(_disclaimerAgreeButton(tester).onPressed, isNull);

    await _scrollDisclaimerTo(tester, const Offset(0, -100000));
    await _scrollDisclaimerTo(tester, const Offset(0, 100000));
    expect(_disclaimerAgreeButton(tester).onPressed, isNotNull);
    expect(find.text('Read to the end'), findsNothing);

    await _agree(tester);
    expect(await agreed, isTrue);
  });

  testWidgets('disclaimer consent on mobile labels the locked button', (
    tester,
  ) async {
    await _pumpHost(tester, size: const Size(400, 800));

    final agreed = requestDisclaimerConsent();
    await tester.pumpAndSettle();
    expect(find.text('Agree'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.text('Read to the end'),
      ),
      findsOneWidget,
    );

    await _scrollDisclaimerTo(tester, const Offset(0, -100000));
    await _agree(tester);
    expect(await agreed, isTrue);
  });

  testWidgets(
    'disclaimer consent on desktop keeps the title clear of the window corner',
    (tester) async {
      await _pumpHost(tester);

      final agreed = requestDisclaimerConsent();
      await tester.pumpAndSettle();

      final view = find.byType(DisclaimerView);
      expect(
        find.descendant(of: view, matching: find.byType(AppBar)),
        findsNothing,
        reason:
            'the macOS traffic lights sit over the top-left corner, where an '
            'app bar puts its back button, and backing out declines anyway',
      );
      expect(
        tester
            .getTopLeft(
              find.descendant(of: view, matching: find.text('Disclaimer')),
            )
            .dy,
        greaterThanOrEqualTo(macOSTrafficLightsArea.height),
      );
      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.text('Agree'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();
      expect(await agreed, isFalse);
    },
  );

  testWidgets('disclaimer Agree accepts without a restatement dialog', (
    tester,
  ) async {
    await _pumpHost(tester);

    final agreed = requestDisclaimerConsent();
    await tester.pumpAndSettle();
    await _scrollDisclaimerTo(tester, const Offset(0, -100000));
    await _agree(tester);

    expect(await agreed, isTrue);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Restate the statement'), findsNothing);
  });

  testWidgets('DisclaimerView without consent shows no agree or exit', (
    tester,
  ) async {
    await _pumpHost(tester, homeBuilder: (_) => const DisclaimerView());

    expect(find.text('Disclaimer'), findsWidgets);
    expect(find.text('Agree'), findsNothing);
    expect(find.text('Exit'), findsNothing);
  });

  testWidgets('batch import reports added, skipped, and failed counts', (
    tester,
  ) async {
    await _pumpStatusManagerHost(tester);
    final l10n = currentAppLocalizations;
    dialogs.showBatchImportSummary(
      added: 2,
      skipped: 1,
      failures: const [UpdatingMessage(label: 'bad', message: 'Invalid input')],
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.profileBatchResult(2, 1, 1)), findsOneWidget);
    expect(find.text(l10n.view), findsOneWidget);
  });

  testWidgets('showNotifier delivers text through the StatusManager host', (
    tester,
  ) async {
    await _pumpStatusManagerHost(tester);

    dialogs.showNotifier('something happened');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('something happened'), findsOneWidget);
    expect(tester.takeException(), null);
  });

  testWidgets('showNotifier drops empty text before reaching the host', (
    tester,
  ) async {
    await _pumpStatusManagerHost(tester);

    dialogs.showNotifier('');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(''), findsNothing);
    expect(tester.takeException(), null);
  });

  testWidgets('showNotifier is inert without a StatusManager ancestor', (
    tester,
  ) async {
    await _pumpHost(tester);

    dialogs.showNotifier('no host listening');
    await tester.pumpAndSettle();

    expect(find.text('no host listening'), findsNothing);
    expect(tester.takeException(), null);
  });
}
