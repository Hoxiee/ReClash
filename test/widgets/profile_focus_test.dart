import 'package:reclash/common/common.dart';
import 'package:reclash/common/ui/theme.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/profiles/profiles.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_profiles.dart';

Profile urlProfile(String label) =>
    Profile.normal(label: label, url: 'https://example.com/sub').copyWith(
      subscriptionInfo: const SubscriptionInfo(
        upload: 1024,
        download: 2048,
        total: 4096,
        expire: 1234567890,
      ),
    );

Future<ProviderContainer> pumpProfiles(
  WidgetTester tester, {
  required List<Profile> profiles,
}) async {
  tester.view.physicalSize = const Size(900, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(() => TestProfiles(profiles)),
      currentProfileIdProvider.overrideWithBuild((_, _) => profiles.first.id),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = const Size(900, 800);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        builder: (context, child) {
          globalState.measure = Measure.of(context, 1);
          globalState.theme = CommonTheme.of(context, 1);
          return child!;
        },
        home: const ProfilesView(),
      ),
    ),
  );
  await tester.pump();
  return container;
}

void main() {
  testWidgets('arrow right from a profile card focuses its more button', (
    tester,
  ) async {
    final profiles = [
      urlProfile('url 1'),
      Profile.normal(label: 'file 1'),
      urlProfile('url 2'),
    ];
    await pumpProfiles(tester, profiles: profiles);

    final cards = find
        .byType(OutlinedButton)
        .evaluate()
        .map((element) => element.widget)
        .toList();

    Future<void> focusCard(int index) async {
      for (var tab = 0; tab < 50; tab++) {
        final context = FocusManager.instance.primaryFocus?.context;
        final focusedCard = context
            ?.findAncestorWidgetOfExactType<OutlinedButton>();
        final focusedAction = context
            ?.findAncestorWidgetOfExactType<IconButton>();
        if (focusedAction == null && identical(focusedCard, cards[index])) {
          return;
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      fail('Profile card $index was not reachable');
    }

    for (var profileIndex = 0; profileIndex < profiles.length; profileIndex++) {
      await focusCard(profileIndex);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      final context = FocusManager.instance.primaryFocus?.context;
      expect(context?.findAncestorWidgetOfExactType<IconButton>(), isNotNull);
      expect(
        context?.findAncestorWidgetOfExactType<ListItem>()?.key,
        Key(profiles[profileIndex].id.toString()),
      );
    }
  });

  testWidgets('developer fixture profiles carry a Dev badge', (tester) async {
    final fixture = developerSubscriptions[1];
    final devProfile = Profile.normal(
      label: 'dev',
    ).copyWith(panelMeta: PanelMeta(serviceLogo: fixture.logo));
    await pumpProfiles(
      tester,
      profiles: [
        devProfile,
        Profile.normal(label: 'plain'),
      ],
    );

    final devCard = find.ancestor(
      of: find.text('dev'),
      matching: find.byType(ListItem),
    );
    expect(
      tester
          .widgetList<CommonChip>(
            find.descendant(of: devCard, matching: find.byType(CommonChip)),
          )
          .map((chip) => chip.label),
      contains('Dev'),
    );
    final plainCard = find.ancestor(
      of: find.text('plain'),
      matching: find.byType(ListItem),
    );
    expect(
      find.descendant(of: plainCard, matching: find.byType(CommonChip)),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('subscription menu item opens the usage dialog', (tester) async {
    await pumpProfiles(tester, profiles: [urlProfile('url')]);

    final profileItem = find.ancestor(
      of: find.text('url'),
      matching: find.byType(ListItem),
    );
    await tester.tap(
      find.descendant(of: profileItem, matching: find.byIcon(Icons.more_vert)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(currentAppLocalizations.more).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.subscriptionInfo));
    await tester.pumpAndSettle();

    expect(find.byType(CommonDialog), findsOneWidget);
    expect(find.byType(SubscriptionInfoDetailView), findsOneWidget);
    expect(find.text(currentAppLocalizations.subscriptionInfo), findsOneWidget);
  });
}
