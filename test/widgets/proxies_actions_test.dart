import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/views/proxies/card.dart';
import 'package:reclash/views/proxies/proxies.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

Group _group(String name, [int count = 4]) => Group(
  type: GroupType.Selector,
  name: name,
  all: [for (var i = 0; i < count; i++) Proxy(name: '$name-$i', type: 'ss')],
);

Finder _inBar(Finder finder) =>
    find.descendant(of: find.byType(AppBar), matching: finder);

void main() {
  late ProviderContainer container;

  Future<void> pumpView(
    WidgetTester tester, {
    ProxiesType type = ProxiesType.list,
    Set<String> unfolded = const {'A'},
    List<Group>? groups,
    bool picker = false,
    double width = 412,
  }) async {
    tester.view.physicalSize = Size(width, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    groups ??= [_group('A'), _group('B')];
    final profile = Profile.normal().copyWith(
      currentGroupName: 'A',
      selectedMap: {'A': 'A-90'},
      unfoldSet: unfolded,
    );
    container = ProviderContainer(
      overrides: [
        viewModeProvider.overrideWithValue(
          width < 600 ? ViewMode.mobile : ViewMode.desktop,
        ),
        currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
        profilesProvider.overrideWith(() => TestProfiles([profile])),
        currentGroupsStateProvider.overrideWithValue(
          GroupsState(value: groups),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(currentProfileProvider, (_, _) {});
    globalState.container = container;
    container.read(groupsProvider.notifier).value = groups;
    container
        .read(proxiesStyleSettingProvider.notifier)
        .update((state) => state.copyWith(type: type));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: ProxiesView(picker: picker)),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final width in [320.0, 1280.0]) {
    testWidgets('tabs keep locate beside search and delay at $width dp', (
      tester,
    ) async {
      await pumpView(
        tester,
        type: ProxiesType.tab,
        groups: [_group('A', 120), _group('B')],
        width: width,
      );
      final search = _inBar(find.byTooltip('Search'));
      final delay = _inBar(find.byTooltip('Delay test'));
      final locate = _inBar(find.byTooltip('Scroll to selected'));
      final group = find.ancestor(
        of: search,
        matching: find.byType(TonalButtonGroup),
      );
      expect(group, findsOneWidget);
      for (final action in [search, delay, locate]) {
        expect(action.hitTestable(), findsOneWidget);
        expect(find.descendant(of: group, matching: action), findsOneWidget);
      }
      expect(_inBar(find.byGlyph(AppGlyphs.expandAll)), findsNothing);

      await tester.tap(locate);
      await tester.pumpAndSettle();
      expect(
        find.text('A-90', findRichText: true).first.hitTestable(),
        findsOneWidget,
      );

      await tester.tap(_inBar(find.byTooltip('More')));
      await tester.pumpAndSettle();
      final menu = find.byType(CommonPopupMenu);
      expect(
        find.descendant(of: menu, matching: find.text('Scroll to selected')),
        findsNothing,
      );
      expect(
        find.descendant(of: menu, matching: find.byGlyph(AppGlyphs.shuffle)),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'list toggles all groups from a mixed state and preserves others',
    (tester) async {
      await pumpView(tester, unfolded: {'A', 'Other'});
      expect(find.byType(ProxyCard), findsWidgets);
      expect(_inBar(find.byGlyph(AppGlyphs.collapseAll)), findsOneWidget);
      expect(_inBar(find.byTooltip('Scroll to selected')), findsNothing);

      await tester.tap(_inBar(find.byTooltip('Collapse all groups')));
      await tester.pumpAndSettle();
      expect(container.read(unfoldSetProvider), {'Other'});
      expect(find.byType(ProxyCard), findsNothing);
      expect(_inBar(find.byGlyph(AppGlyphs.expandAll)), findsOneWidget);

      await tester.tap(_inBar(find.byTooltip('Expand all groups')));
      await tester.pumpAndSettle();
      expect(container.read(unfoldSetProvider), {'A', 'B', 'Other'});
      expect(find.byType(ProxyCard), findsWidgets);
      expect(_inBar(find.byGlyph(AppGlyphs.collapseAll)), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('list action follows individual group folding', (tester) async {
    await pumpView(tester);

    await tester.tap(find.text('A', findRichText: true).last);
    await tester.pumpAndSettle();
    expect(_inBar(find.byTooltip('Expand all groups')), findsOneWidget);

    await tester.tap(find.text('B', findRichText: true).last);
    await tester.pumpAndSettle();
    expect(_inBar(find.byTooltip('Collapse all groups')), findsOneWidget);
    expect(container.read(unfoldSetProvider), {'B'});
  });

  testWidgets(
    'list folding respects the search without changing hidden groups',
    (tester) async {
      await pumpView(tester, unfolded: {'A', 'B', 'Other'});
      container.read(queryProvider(QueryTag.proxies).notifier).value = 'A-';
      await tester.pumpAndSettle();

      await tester.tap(_inBar(find.byTooltip('Collapse all groups')));
      await tester.pumpAndSettle();
      expect(container.read(unfoldSetProvider), {'B', 'Other'});

      await tester.tap(_inBar(find.byTooltip('Expand all groups')));
      await tester.pumpAndSettle();
      expect(container.read(unfoldSetProvider), {'A', 'B', 'Other'});

      container.read(queryProvider(QueryTag.proxies).notifier).value =
          'missing';
      await tester.pumpAndSettle();
      final action = tester.widget<IconButton>(
        find.ancestor(
          of: _inBar(find.byTooltip('Expand all groups')),
          matching: find.byType(IconButton),
        ),
      );
      expect(action.onPressed, isNull);
      expect(container.read(unfoldSetProvider), {'A', 'B', 'Other'});
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('an empty list disables the group action', (tester) async {
    await pumpView(tester, groups: []);
    final action = tester.widget<IconButton>(
      find.ancestor(
        of: _inBar(find.byTooltip('Expand all groups')),
        matching: find.byType(IconButton),
      ),
    );
    expect(action.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  for (final type in ProxiesType.values) {
    testWidgets('the ${type.name} picker keeps its minimal bar', (
      tester,
    ) async {
      await pumpView(tester, type: type, picker: true);
      expect(_inBar(find.byTooltip('Search')), findsOneWidget);
      expect(_inBar(find.byTooltip('Scroll to selected')), findsNothing);
      expect(_inBar(find.byGlyph(AppGlyphs.expandAll)), findsNothing);
      expect(_inBar(find.byGlyph(AppGlyphs.collapseAll)), findsNothing);
      expect(_inBar(find.byTooltip('More')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
