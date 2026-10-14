import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/core/interface.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/core.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/connection/connections.dart';
import 'package:reclash/widgets/widgets.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

TrackerInfo _tracker({
  required String id,
  String host = 'example.com',
  String process = 'curl',
  List<String> chains = const ['Proxy'],
  int upload = 0,
  int download = 0,
  DateTime? start,
}) {
  return TrackerInfo(
    id: id,
    upload: upload,
    download: download,
    start: start ?? DateTime.utc(2026),
    metadata: Metadata(
      network: 'tcp',
      host: host,
      destinationIP: '1.1.1.1',
      destinationPort: '443',
      process: process,
    ),
    chains: chains,
    rule: 'DOMAIN',
    rulePayload: host,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCoreHandlerInterface core;
  late ProviderContainer container;

  setUp(() {
    core = MockCoreHandlerInterface();
    container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(core),
        profilesProvider.overrideWith(TestProfiles.new),
      ],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpConnections(
    WidgetTester tester, {
    SheetType? sheetType,
    Size size = const Size(1400, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: sheetType == null
              ? const ConnectionsView()
              : SheetProvider(
                  type: sheetType,
                  child: const Material(child: ConnectionsView()),
                ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> teardownView(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('shows the empty state when core reports no connections', (
    tester,
  ) async {
    when(core.getConnections).thenAnswer((_) async => const <TrackerInfo>[]);

    await pumpConnections(tester);

    expect(find.byType(NullStatus), findsOneWidget);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('renders one row per reported connection', (tester) async {
    when(core.getConnections).thenAnswer(
      (_) async => [
        _tracker(id: 'a', host: 'alpha.test'),
        _tracker(id: 'b', host: 'beta.test'),
      ],
    );

    await pumpConnections(tester);
    // NullStatusSwitcher fades the empty state out over the next frames.
    await tester.pump(commonDuration);
    await tester.pump(commonDuration);

    expect(find.byType(NullStatus), findsNothing);
    expect(find.textContaining('alpha.test'), findsWidgets);
    expect(find.textContaining('beta.test'), findsWidgets);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('orders rows by total traffic, then newest first', (
    tester,
  ) async {
    when(core.getConnections).thenAnswer(
      (_) async => [
        _tracker(id: 'a', host: 'alpha.test', download: 100),
        _tracker(id: 'b', host: 'beta.test', upload: 300, download: 300),
        _tracker(
          id: 'c',
          host: 'gamma.test',
          download: 100,
          start: DateTime.utc(2026, 2),
        ),
      ],
    );

    await pumpConnections(tester);

    double topOf(String host) =>
        tester.getTopLeft(find.textContaining(host).first).dy;
    expect(topOf('beta.test'), lessThan(topOf('gamma.test')));
    expect(topOf('gamma.test'), lessThan(topOf('alpha.test')));
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('keeps the empty state when core throws', (tester) async {
    when(core.getConnections).thenThrow(StateError('core down'));

    await pumpConnections(tester);

    expect(find.byType(NullStatus), findsOneWidget);
    expect(tester.takeException(), null);

    await teardownView(tester);
  });

  testWidgets('stops polling once the view is disposed', (tester) async {
    when(core.getConnections).thenAnswer((_) async => const <TrackerInfo>[]);

    await pumpConnections(tester);
    await teardownView(tester);
    clearInteractions(core);

    await tester.pump(const Duration(seconds: 3));

    verifyNever(core.getConnections);
  });

  for (final width in [390.0, 1400.0]) {
    testWidgets('pulls close and sort into one visible group at $width', (
      tester,
    ) async {
      when(core.getConnections).thenAnswer((_) async => const <TrackerInfo>[]);
      when(core.closeConnections).thenAnswer((_) async => true);

      await pumpConnections(tester, size: Size(width, 1000));

      final close = find.byGlyph(AppGlyphs.clearAll);
      final sort = find.byGlyph(AppGlyphs.sort);
      final group = find.byType(TonalButtonGroup);
      expect(group, findsOneWidget);
      expect(
        find.descendant(of: group, matching: close),
        findsOneWidget,
        reason: 'close shares the single action group',
      );
      expect(
        find.descendant(of: group, matching: sort),
        findsOneWidget,
        reason: 'sort shares the single action group',
      );
      expect(find.byGlyph(AppGlyphs.more), findsNothing);
      expect(find.byGlyph(AppGlyphs.search), findsOneWidget);
      expect(tester.getCenter(close).dx, lessThan(tester.getCenter(sort).dx));

      await tester.tap(close);
      await tester.pumpAndSettle();

      verify(core.closeConnections).called(1);
      expect(tester.takeException(), isNull);

      await teardownView(tester);
    });
  }

  for (final sheetType in [SheetType.bottomSheet, SheetType.sideSheet]) {
    testWidgets(
      'surfaces close and sort without an overflow in ${sheetType.name}',
      (tester) async {
        when(
          core.getConnections,
        ).thenAnswer((_) async => const <TrackerInfo>[]);
        when(core.closeConnections).thenAnswer((_) async => true);

        await pumpConnections(
          tester,
          sheetType: sheetType,
          size: Size(sheetType == SheetType.bottomSheet ? 390 : 600, 1000),
        );

        expect(find.byGlyph(AppGlyphs.more), findsNothing);
        final group = find.byType(TonalButtonGroup);
        expect(group, findsOneWidget);
        expect(
          find.descendant(of: group, matching: find.byGlyph(AppGlyphs.clearAll)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: group, matching: find.byGlyph(AppGlyphs.sort)),
          findsOneWidget,
        );

        if (sheetType == SheetType.bottomSheet) {
          expect(find.byType(DockedSearchBar), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(AppBar),
              matching: find.byGlyph(AppGlyphs.search),
            ),
            findsNothing,
          );
        }

        await tester.tap(find.byGlyph(AppGlyphs.clearAll));
        await tester.pumpAndSettle();

        verify(core.closeConnections).called(1);
        expect(tester.takeException(), isNull);

        await teardownView(tester);
      },
    );
  }

  for (final sheetType in [null, SheetType.bottomSheet, SheetType.sideSheet]) {
    testWidgets(
      'sorts and marks the chosen order in ${sheetType?.name ?? 'tab'}',
      (tester) async {
        when(core.getConnections).thenAnswer(
          (_) async => [
            _tracker(id: 'a', host: 'alpha.test', download: 100),
            _tracker(id: 'b', host: 'beta.test', download: 300),
          ],
        );

        await pumpConnections(tester, sheetType: sheetType);

        Future<void> openSortMenu() async {
          await tester.tap(find.byGlyph(AppGlyphs.sort));
          await tester.pumpAndSettle();
        }

        double topOf(String host) =>
            tester.getTopLeft(find.textContaining(host).first).dy;
        expect(topOf('beta.test'), lessThan(topOf('alpha.test')));

        await openSortMenu();
        final appLocalizations = AppLocalizations.current;
        await tester.tap(find.text(appLocalizations.host));
        await tester.pumpAndSettle();

        expect(topOf('alpha.test'), lessThan(topOf('beta.test')));

        await openSortMenu();
        final menu = tester.widget<CommonPopupMenu>(
          find.byType(CommonPopupMenu),
        );
        expect(
          menu.items.singleWhere((item) => item.glyph == AppGlyphs.check).label,
          appLocalizations.host,
        );
        expect(tester.takeException(), isNull);

        await teardownView(tester);
      },
    );
  }

  testWidgets('renders the regex toggle in the search bar', (tester) async {
    when(core.getConnections).thenAnswer((_) async => const <TrackerInfo>[]);

    await pumpConnections(tester);

    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();

    expect(find.byGlyph(AppGlyphs.code), findsOneWidget);

    await teardownView(tester);
  });
}
