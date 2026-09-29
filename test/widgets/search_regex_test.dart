import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';

import '../helpers/glyph_finders.dart';

/// Mirrors how a real view drives search: flipping regex calls [onRegexChange],
/// which does a setState and republishes a fresh [AppBarSearchState] (with a new
/// closure and a null query) into the same [CommonScaffold].
class _SearchHost extends StatefulWidget {
  const _SearchHost({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  State<_SearchHost> createState() => _SearchHostState();
}

class _SearchHostState extends State<_SearchHost> {
  bool _useRegex = false;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Logs',
      searchState: AppBarSearchState(
        onSearch: widget.onSearch,
        onRegexChange: (value) => setState(() => _useRegex = value),
        useRegex: _useRegex,
      ),
      body: const SizedBox(),
    );
  }
}

Widget _wrap(ProviderContainer container, Widget child) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      navigatorKey: globalState.navigatorKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  testWidgets('toggling regex keeps search open and propagates useRegex', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;

    var lastQuery = '';
    await tester.pumpWidget(
      _wrap(container, _SearchHost(onSearch: (value) => lastQuery = value)),
    );

    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'needle');
    expect(lastQuery, 'needle');

    final host = tester.state<_SearchHostState>(find.byType(_SearchHost));
    expect(host._useRegex, isFalse);

    await tester.tap(find.byGlyph(AppGlyphs.code));
    await tester.pumpAndSettle();

    expect(host._useRegex, isTrue, reason: 'regex toggle must propagate');
    expect(
      find.byType(TextField),
      findsOneWidget,
      reason: 'toggling regex must not collapse the open search',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'needle',
      reason: 'the live query survives the regex toggle rebuild',
    );
  });

  testWidgets('regex and close fold into one grouped pill', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(_wrap(container, _SearchHost(onSearch: (_) {})));

    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();

    final group = find.byType(TonalButtonGroup);
    expect(group, findsOneWidget);
    expect(
      find.descendant(of: group, matching: find.byGlyph(AppGlyphs.code)),
      findsOneWidget,
      reason: 'the regex toggle belongs inside the grouped pill',
    );
    expect(
      find.descendant(of: group, matching: find.byGlyph(AppGlyphs.close)),
      findsOneWidget,
      reason: 'the close button shares the grouped pill with regex',
    );
  });

  testWidgets(
    'a bottom sheet gets the app-bar search button, not a docked bar',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      globalState.container = container;

      await tester.pumpWidget(
        _wrap(
          container,
          SheetProvider(
            type: SheetType.bottomSheet,
            child: CommonScaffold(
              title: 'Connections',
              searchState: AppBarSearchState(onSearch: (_) {}),
              body: const SizedBox(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byType(DockedSearchBar),
        findsNothing,
        reason: 'sheets no longer dock a search bar at the bottom',
      );
      expect(
        find.byGlyph(AppGlyphs.search),
        findsOneWidget,
        reason: 'the app-bar search button drives search inside a sheet',
      );
    },
  );
}
