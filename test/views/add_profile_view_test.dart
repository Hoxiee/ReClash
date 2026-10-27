import 'package:reclash/common/common.dart';
import 'package:reclash/features/form/form.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/state.dart';
import 'package:reclash/subscriptions/compatibility/clients.dart';
import 'package:reclash/subscriptions/external_link.dart';
import 'package:reclash/subscriptions/page_preview.dart';
import 'package:reclash/subscriptions/transport/transport.dart';
import 'package:reclash/views/profiles/add.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _RecordingProfilesAction extends ProfilesAction {
  final previews = <ProfileLinkSource>[];
  final confirmed = <ProfileLinkSource>[];

  @override
  Future<SubscriptionPagePreview> previewProfileLinkSource(
    ProfileLinkSource source, {
    SubscriptionCancellation? cancellation,
  }) async {
    previews.add(source);
    return const SubscriptionPagePreview(label: 'Clipboard subscription');
  }

  @override
  Future<Profile> addConfirmedLinkSource(
    ProfileLinkSource source, {
    String? label,
    SubscriptionClientSettings? clientSettings,
    BuildContext? reviewContext,
    SubscriptionCancellation? cancellation,
  }) async {
    confirmed.add(source);
    return Profile.normal(url: source.url!, label: label ?? '');
  }

  final batches = <List<ProfileLinkInput>>[];
  final singles = <String>[];
  final ageSecretKeys = <String>[];
  final singleSettings = <SubscriptionClientSettings?>[];
  final batchSettings = <SubscriptionClientSettings?>[];
  final batchSkipped = <int>[];

  @override
  Future<void> addProfileFromLink(
    String link, {
    String? label,
    String ageSecretKey = '',
    SubscriptionClientSettings? clientSettings,
  }) async {
    singles.add(link);
    ageSecretKeys.add(ageSecretKey);
    singleSettings.add(clientSettings);
  }

  @override
  Future<void> addProfilesFromLinks(
    List<ProfileLinkInput> links, {
    SubscriptionClientSettings? clientSettings,
    int skippedExisting = 0,
  }) async {
    batches.add(links);
    batchSettings.add(clientSettings);
    batchSkipped.add(skippedExisting);
  }
}

Finder _field(String title) => find.descendant(
  of: find.widgetWithText(FormRow, title),
  matching: find.byType(TextFormField),
);

ProviderContainer _containerFor(
  WidgetTester tester, {
  ProfilesAction? profilesAction,
  List<Profile> profiles = const [],
}) {
  const size = Size(1400, 1000);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(() => TestProfiles(profiles)),
      if (profilesAction != null)
        profilesActionProvider.overrideWith(() => profilesAction),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  return container;
}

Future<void> _openMenu(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: Scaffold(
          body: Center(
            child: AddProfileMenu(
              builder: (open) =>
                  FilledButton(onPressed: open, child: const Text('add')),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('add'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('offers the QR code, file, link, clipboard, and custom entries', (
    tester,
  ) async {
    final container = _containerFor(tester);

    await _openMenu(tester, container);

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.qrcode), findsOne);
    expect(find.text(l10n.file), findsOne);
    expect(find.text(l10n.link), findsOne);
    expect(find.text(l10n.customProfile), findsOne);
    expect(find.text(l10n.profilePasteFromClipboard), findsOne);
    expect(tester.takeException(), null);
  });

  for (final input in [
    '  https://example.com/sub  ',
    'reclash://add?url=https%3A%2F%2Fexample.com%2Fsub',
  ]) {
    testWidgets('clipboard opens a preview before consent: $input', (
      tester,
    ) async {
      final action = _RecordingProfilesAction();
      final container = _containerFor(tester, profilesAction: action);
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async =>
            call.method == 'Clipboard.getData' ? {'text': input} : null,
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });
      await _openMenu(tester, container);
      await tester.tap(
        find.text(currentAppLocalizations.profilePasteFromClipboard),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();

      expect(action.previews.single.url, 'https://example.com/sub');
      expect(action.confirmed, isEmpty);
      expect(action.singles, isEmpty);
      expect(find.text('Clipboard subscription'), findsWidgets);

      await tester.tap(find.text(currentAppLocalizations.add));
      await tester.pumpAndSettle();
      expect(action.confirmed.single.url, 'https://example.com/sub');
      expect(tester.takeException(), isNull);
    });
  }

  for (final input in <String?>[null, '   ', 'not a link']) {
    testWidgets('invalid clipboard does not import: $input', (tester) async {
      final action = _RecordingProfilesAction();
      final container = _containerFor(tester, profilesAction: action);
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => call.method == 'Clipboard.getData'
            ? (input == null ? null : {'text': input})
            : null,
      );
      addTearDown(() {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });
      await _openMenu(tester, container);
      await tester.tap(
        find.text(currentAppLocalizations.profilePasteFromClipboard),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(action.previews, isEmpty);
      expect(action.confirmed, isEmpty);
      expect(action.singles, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('clipboard read failure is handled', (tester) async {
    final action = _RecordingProfilesAction();
    final container = _containerFor(tester, profilesAction: action);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') {
          throw PlatformException(code: 'clipboard-denied');
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });
    await _openMenu(tester, container);
    await tester.tap(
      find.text(currentAppLocalizations.profilePasteFromClipboard),
    );
    await tester.pumpAndSettle();
    expect(action.previews, isEmpty);
    expect(action.confirmed, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a batch link import skips existing profiles and adds the rest', (
    tester,
  ) async {
    final action = _RecordingProfilesAction();
    final container = _containerFor(
      tester,
      profilesAction: action,
      profiles: [Profile.normal(url: '  https://example.com/old  ')],
    );

    await _openMenu(tester, container);

    final l10n = currentAppLocalizations;
    await tester.tap(find.text(l10n.link));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l10n.batchImport));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).first,
      'https://example.com/a\nhttps://example.com/old\nhttps://example.com/b\nhttps://example.com/a',
    );
    await tester.enterText(_field(l10n.ageSecretKey), 'batch-key');
    await tester.pump();
    await tester.tap(find.text(l10n.submit));
    await tester.pumpAndSettle();

    expect(action.batches, [
      [
        (label: '', url: 'https://example.com/a', ageSecretKey: 'batch-key'),
        (label: '', url: 'https://example.com/b', ageSecretKey: 'batch-key'),
      ],
    ]);
    expect(action.batchSettings.single, isNull);
    expect(action.batchSkipped.single, 2);
    expect(tester.takeException(), null);
  });

  testWidgets('batch import retains duplicates when prevention is disabled', (
    tester,
  ) async {
    final action = _RecordingProfilesAction();
    const existingUrl = 'https://example.com/existing';
    final container = _containerFor(
      tester,
      profilesAction: action,
      profiles: [Profile.normal(url: existingUrl)],
    );
    final settings = container.listen(appSettingProvider, (_, _) {});
    addTearDown(settings.close);
    container
        .read(appSettingProvider.notifier)
        .update((value) => value.copyWith(preventDuplicateProfiles: false));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => AddProfileMenu(
                builder: (open) => TextButton(
                  onPressed: open,
                  child: const Text('Add profile'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add profile'));
    await tester.pumpAndSettle();

    final l10n = currentAppLocalizations;
    await tester.tap(find.text(l10n.link));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l10n.batchImport));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).first,
      '$existingUrl\nhttps://example.com/new\nhttps://example.com/new',
    );
    await tester.pump();
    await tester.tap(find.text(l10n.submit));
    await tester.pumpAndSettle();

    expect(action.batches.single, [
      (label: '', url: existingUrl, ageSecretKey: ''),
      (label: '', url: 'https://example.com/new', ageSecretKey: ''),
      (label: '', url: 'https://example.com/new', ageSecretKey: ''),
    ]);
    expect(action.batchSkipped.single, 0);
  });

  testWidgets('the link import takes a proxy share link', (tester) async {
    final action = _RecordingProfilesAction();
    final container = _containerFor(tester, profilesAction: action);

    await _openMenu(tester, container);

    final l10n = currentAppLocalizations;
    await tester.tap(find.text(l10n.link));
    await tester.pumpAndSettle();
    await tester.enterText(
      _field(l10n.link),
      'trojan://pass@example.com:443#HK',
    );
    await tester.pump();
    await tester.tap(find.text(l10n.submit));
    await tester.pumpAndSettle();

    expect(action.singles, ['trojan://pass@example.com:443#HK']);
    expect(action.singleSettings.single, isNull);
    expect(tester.takeException(), null);
  });

  testWidgets('the link import passes the age secret key along', (
    tester,
  ) async {
    final action = _RecordingProfilesAction();
    final container = _containerFor(tester, profilesAction: action);

    await _openMenu(tester, container);

    final l10n = currentAppLocalizations;
    await tester.tap(find.text(l10n.link));
    await tester.pumpAndSettle();
    await tester.enterText(_field(l10n.link), 'https://example.com/sub');
    await tester.enterText(_field(l10n.ageSecretKey), ' AGE-SECRET-KEY-1A ');
    await tester.pump();
    await tester.tap(find.text(l10n.submit));
    await tester.pumpAndSettle();

    expect(action.singles, ['https://example.com/sub']);
    expect(action.ageSecretKeys, ['AGE-SECRET-KEY-1A']);
    expect(action.singleSettings.single, isNull);
    expect(tester.takeException(), null);
  });

  testWidgets('the link import stores a chosen custom client identity', (
    tester,
  ) async {
    final action = _RecordingProfilesAction();
    final container = _containerFor(tester, profilesAction: action);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => AddProfileMenu(
                builder: (open) => TextButton(
                  onPressed: open,
                  child: const Text('Add profile'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add profile'));
    await tester.pumpAndSettle();

    final l10n = currentAppLocalizations;
    await tester.tap(find.text(l10n.link));
    await tester.pumpAndSettle();
    final identity = find.ancestor(
      of: find.text(l10n.subscriptionIdentityTitle),
      matching: find.byType(FormRow),
    );
    final request = find.ancestor(
      of: find.text(l10n.subscriptionClientRequestAs),
      matching: find.byType(ListTile),
    );
    final gap =
        tester.getTopLeft(request).dy - tester.getBottomLeft(identity).dy;
    expect(gap, lessThanOrEqualTo(32));
    await tester.enterText(_field(l10n.link), 'https://example.com/sub');
    await tester.tap(find.text(l10n.subscriptionClientRequestAs));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(l10n.subscriptionClientCustom));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.subscriptionClientCustom));
    await tester.pumpAndSettle();
    final customUserAgentField = _field(l10n.subscriptionClientCustomUserAgent);
    await tester.ensureVisible(customUserAgentField);
    await tester.pumpAndSettle();
    await tester.enterText(customUserAgentField, 'ExamplePanel/4');
    await tester.tap(find.text(l10n.submit));
    await tester.pumpAndSettle();

    expect(action.singles, ['https://example.com/sub']);
    expect(
      action.singleSettings.single?.preset,
      SubscriptionClientPreset.custom,
    );
    expect(action.singleSettings.single?.customUserAgent, 'ExamplePanel/4');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the link import rejects what is neither kind of link', (
    tester,
  ) async {
    final action = _RecordingProfilesAction();
    final container = _containerFor(tester, profilesAction: action);

    await _openMenu(tester, container);

    final l10n = currentAppLocalizations;
    await tester.tap(find.text(l10n.link));
    await tester.pumpAndSettle();
    await tester.enterText(
      _field(l10n.link),
      'wireguard://key@example.com:51820',
    );
    await tester.pump();
    await tester.tap(find.text(l10n.submit));
    await tester.pumpAndSettle();

    expect(find.text(l10n.invalidLinkTip), findsOne);
    expect(action.singles, isEmpty);
    expect(tester.takeException(), null);
  });
}
