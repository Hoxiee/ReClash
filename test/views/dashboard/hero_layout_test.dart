import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/dashboard/widgets/dashboard_pager.dart';
import 'package:reclash/views/dashboard/widgets/hero_connect.dart';
import 'package:reclash/views/dashboard/widgets/hero_elastic_flow.dart';
import 'package:reclash/views/dashboard/widgets/hero_layout.dart';
import 'package:reclash/views/dashboard/widgets/hero_orb.dart';
import 'package:reclash/views/dashboard/widgets/hero_surface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

const _settle = Duration(milliseconds: 500);
const _splitBoard = ValueKey('dashboard-split-board');
const _showProvider = ValueKey('dashboard-show-provider');
const _showConnection = ValueKey('dashboard-show-connection');
const _subscriptionStrip = ValueKey('hero-subscription-strip');

// The orb animates for as long as it is on screen, so pumpAndSettle never
// returns on a board that shows one.
Future<void> _pumpBoard(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(_settle);
  await tester.pump(_settle);
}

Widget _flow({required double viewport, required double tail}) =>
    Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: 360,
        height: viewport,
        child: SingleChildScrollView(
          child: HeroElasticFlow(
            viewportHeight: viewport,
            headMin: heroOrbMinSize,
            headMax: heroOrbMaxSize,
            head: HeroOrbSlot(
              min: heroOrbMinSize,
              max: heroOrbMaxSize,
              builder: (context, size) =>
                  SizedBox.square(dimension: size, key: const ValueKey('orb')),
            ),
            tail: [SizedBox(height: tail, key: const ValueKey('tail'))],
          ),
        ),
      ),
    );

Profile _profile() => Profile(
  id: 1,
  label: 'Local profile',
  url: 'https://example.com/sub',
  lastUpdateDate: DateTime(2026, 9, 8, 12),
  autoUpdateDuration: const Duration(hours: 1),
  panelMeta: const PanelMeta(
    serviceName: 'Example VPN',
    announce: 'Maintenance starts Friday at 21:00 UTC.',
    supportUrl: 'https://example.com/support',
  ),
  subscriptionInfo: SubscriptionInfo(
    upload: 25,
    download: 25,
    total: 100,
    expire: DateTime(2027).millisecondsSinceEpoch ~/ 1000,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pumpBoard(
    WidgetTester tester, {
    required Size size,
    Profile? profile,
    double textScaleFactor = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScaleFactor;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    const group = Group(
      name: 'Selector',
      type: GroupType.Selector,
      hidden: false,
      now: 'Node A',
      all: [Proxy(name: 'Node A', type: 'Shadowsocks')],
    );
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([?profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile?.id),
        groupsProvider.overrideWithValue(const [group]),
        tunEnabledProvider.overrideWith((ref) => true),
        initProvider.overrideWithBuild((_, _) => true),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = size;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          includeNavigatorKey: false,
          child: Scaffold(body: DashboardPager()),
        ),
      ),
    );
    await _pumpBoard(tester);
    return container;
  }

  Future<void> resize(
    WidgetTester tester,
    ProviderContainer container,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    container.read(viewSizeProvider.notifier).value = size;
    await _pumpBoard(tester);
  }

  double orbSize(WidgetTester tester) =>
      tester.widget<HeroOrb>(find.byType(HeroOrb)).size;

  test('split predicate matches the measured viewports', () {
    bool split(double width, double height) =>
        heroSplitFor(BoxConstraints.tight(Size(width, height)));
    expect(split(1280, 800), isTrue);
    expect(split(1600, 900), isTrue);
    expect(split(944, 640), isTrue);
    expect(split(800, 400), isTrue);
    expect(split(360, 640), isFalse);
    expect(split(390, 844), isFalse);
    expect(split(412, 915), isFalse);
    expect(split(900, 1200), isFalse);
    expect(split(900, 700), isFalse);
    expect(split(420, 720), isFalse);
    expect(split(360, 520), isFalse);
  });

  testWidgets('orb absorbs the leftover height in 8px steps', (tester) async {
    await tester.pumpWidget(_flow(viewport: 640, tail: 400));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const ValueKey('orb'))).width, 240);

    await tester.pumpWidget(_flow(viewport: 640, tail: 405));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const ValueKey('orb'))).width, 232);

    await tester.pumpWidget(_flow(viewport: 640, tail: 519));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const ValueKey('orb'))).width, 120);

    await tester.pumpWidget(_flow(viewport: 1000, tail: 400));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const ValueKey('orb'))).width, 280);
  });

  testWidgets('the board centres everything it holds', (tester) async {
    await tester.pumpWidget(_flow(viewport: 800, tail: 300));
    await tester.pumpAndSettle();
    final orb = tester.getRect(find.byKey(const ValueKey('orb')));
    final tail = tester.getRect(find.byKey(const ValueKey('tail')));
    expect(orb.top, 110);
    expect(800 - tail.bottom, closeTo(orb.top, 0.01));
  });

  testWidgets('flow grows past the viewport instead of overflowing', (
    tester,
  ) async {
    await tester.pumpWidget(_flow(viewport: 400, tail: 700));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(HeroElasticFlow)).height, 820);
    expect(tester.getSize(find.byKey(const ValueKey('orb'))).width, 120);
  });

  const viewports = [
    Size(360, 640),
    Size(360, 780),
    Size(390, 844),
    Size(412, 915),
    Size(800, 400),
    Size(900, 1200),
    Size(1024, 640),
    Size(1280, 800),
    Size(1600, 900),
  ];

  for (final size in viewports) {
    for (final scale in const [1.0, 1.3, 1.6]) {
      testWidgets('board fits ${size.width}x${size.height} at $scale', (
        tester,
      ) async {
        await pumpBoard(
          tester,
          size: size,
          profile: _profile(),
          textScaleFactor: scale,
        );
        expect(tester.takeException(), isNull);
        final orb = orbSize(tester);
        expect(orb, greaterThanOrEqualTo(heroOrbMinSize));
        expect(orb, lessThanOrEqualTo(heroOrbMaxSize));
      });
    }
  }

  testWidgets('the orb takes the height the rest leaves over', (tester) async {
    for (final band in const [
      (Size(1600, 900), heroOrbMaxSize, heroOrbMaxSize),
      (Size(1280, 800), heroOrbMaxSize, heroOrbMaxSize),
      (Size(800, 400), heroOrbMinSize, 168.0),
      (Size(1024, 640), 200.0, heroOrbMaxSize),
    ]) {
      final container = await pumpBoard(
        tester,
        size: band.$1,
        profile: _profile(),
      );
      final orb = orbSize(tester);
      expect(orb, greaterThanOrEqualTo(band.$2), reason: '${band.$1}');
      expect(orb, lessThanOrEqualTo(band.$3), reason: '${band.$1}');
      container.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('portrait keeps 192px until the tail needs more room', (
    tester,
  ) async {
    final container = await pumpBoard(
      tester,
      size: const Size(420, 900),
      profile: _profile(),
    );
    expect(orbSize(tester), heroOrbBaseSize);

    await resize(tester, container, const Size(420, 660));
    expect(orbSize(tester), lessThan(heroOrbBaseSize));
    expect(orbSize(tester), greaterThanOrEqualTo(heroOrbMinSize));
    expect(tester.takeException(), isNull);
  });

  testWidgets('landscape and desktop take the two-column board', (
    tester,
  ) async {
    for (final size in const [Size(800, 400), Size(1280, 800)]) {
      final container = await pumpBoard(
        tester,
        size: size,
        profile: _profile(),
      );
      expect(find.byKey(_splitBoard), findsOneWidget);
      expect(find.byKey(_showProvider), findsNothing);
      expect(find.byKey(_subscriptionStrip), findsOneWidget);
      expect(find.text('Example VPN'), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(HeroSplitDetails),
          matching: find.textContaining('free of'),
        ),
        findsNothing,
      );
      expect(find.textContaining('free of'), findsOneWidget);
      expect(orbSize(tester), lessThanOrEqualTo(heroOrbMaxSize));
      expect(tester.takeException(), isNull);
      container.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('the detail column keeps one edge for every card', (
    tester,
  ) async {
    await pumpBoard(tester, size: const Size(1280, 800), profile: _profile());

    final cards = find.descendant(
      of: find.byType(HeroSplitDetails),
      matching: find.byType(HeroSurface),
    );
    final count = cards.evaluate().length;
    expect(count, greaterThan(1));

    final first = tester.getRect(cards.first);
    for (var i = 1; i < count; i++) {
      final rect = tester.getRect(cards.at(i));
      expect(rect.left, first.left, reason: 'card $i left');
      expect(rect.right, first.right, reason: 'card $i right');
    }
  });

  testWidgets('both columns centre the board they hold', (tester) async {
    await pumpBoard(tester, size: const Size(1280, 800), profile: _profile());

    final column = tester.getRect(find.byType(HeroSplitDetails));
    final cards = find.descendant(
      of: find.byType(HeroSplitDetails),
      matching: find.byType(HeroSurface),
    );
    final top = tester.getRect(cards.first).top;
    final bottom = tester.getRect(cards.at(cards.evaluate().length - 1)).bottom;

    expect(
      (top - column.top) - (column.bottom - bottom),
      closeTo(0, 24),
      reason: 'the cards must not hug the top of their column',
    );
  });

  testWidgets('a narrow viewport keeps the pager', (tester) async {
    await pumpBoard(tester, size: const Size(900, 1200), profile: _profile());
    expect(find.byKey(_splitBoard), findsNothing);
    expect(find.byKey(_showProvider), findsOneWidget);
  });

  testWidgets('crossing the breakpoint returns to the first page', (
    tester,
  ) async {
    final container = await pumpBoard(
      tester,
      size: const Size(900, 1200),
      profile: _profile(),
    );
    await tester.tap(find.byKey(_showProvider));
    await tester.pumpAndSettle();
    expect(find.byKey(_showConnection).hitTestable(), findsOneWidget);

    await resize(tester, container, const Size(1280, 800));
    expect(find.byKey(_splitBoard), findsOneWidget);
    expect(tester.takeException(), isNull);

    await resize(tester, container, const Size(900, 1200));
    expect(find.byKey(_splitBoard), findsNothing);
    expect(find.byKey(_showProvider).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
