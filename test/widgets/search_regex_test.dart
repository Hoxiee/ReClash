import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

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
      body: ListView.builder(
        itemCount: 40,
        itemBuilder: (_, index) =>
            SizedBox(height: 40, child: Text('row $index')),
      ),
    );
  }
}

Widget _wrap(ProviderContainer container, Widget child) {
  return UncontrolledProviderScope(
    container: container,
    child: TestApp(child: child),
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

  testWidgets('the regex toggle rides inside the search field', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(_wrap(container, _SearchHost(onSearch: (_) {})));

    await tester.tap(find.byGlyph(AppGlyphs.search));
    await tester.pumpAndSettle();

    expect(find.byType(RegexSearchToggle), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byGlyph(AppGlyphs.code),
        matching: find.byType(TonalButtonGroup),
      ),
      findsNothing,
      reason: 'the regex toggle lives in the field, not an app-bar pill',
    );
    expect(
      find.byGlyph(AppGlyphs.close),
      findsOneWidget,
      reason: 'the close button stays its own app-bar control',
    );
  });

  testWidgets('a bottom sheet docks search and keeps its regex control', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    var query = '';

    await tester.pumpWidget(
      _wrap(
        container,
        SheetProvider(
          type: SheetType.bottomSheet,
          child: _SearchHost(onSearch: (value) => query = value),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DockedSearchBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byGlyph(AppGlyphs.search),
      ),
      findsNothing,
    );

    await tester.enterText(find.byType(TextField), 'needle');
    await tester.pump();
    await tester.tap(find.byGlyph(AppGlyphs.code));
    await tester.pumpAndSettle();

    expect(query, 'needle');
    expect(
      tester.state<_SearchHostState>(find.byType(_SearchHost))._useRegex,
      isTrue,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'needle',
    );
    expect(find.text('Logs'), findsOneWidget);
  });
}
