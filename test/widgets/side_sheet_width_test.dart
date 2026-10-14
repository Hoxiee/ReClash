import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/widgets/layout/paged_sheet.dart';
import 'package:reclash/widgets/layout/scaffold.dart';
import 'package:reclash/widgets/layout/sheet.dart';
import 'package:reclash/widgets/layout/side_sheet.dart';

import '../helpers/test_app.dart';

typedef _Opener = void Function(BuildContext context);

Widget _page() {
  return CommonScaffold(
    title: 'title',
    body: ListView(
      children: [for (var i = 0; i < 3; i++) ListTile(title: Text('row $i'))],
    ),
  );
}

final _openers = <String, _Opener>{
  'showSheet': (context) =>
      showSheet<void>(context: context, builder: (_) => _page()),
  'a nested paged sheet': (context) => showSheet<void>(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) => NestedPagedSheet(builder: (_) => _page()),
  ),
  'showExtend': (context) => showExtend<void>(context, builder: (_) => _page()),
  'showSnapSheet': (context) => showSnapSheet<void>(
    context,
    builder: (_, _) => NestedPagedSheet(builder: (_) => _page()),
  ),
};

void main() {
  Future<void> open(
    WidgetTester tester,
    Size view,
    _Opener opener, {
    double sidebarWidth = 0,
  }) async {
    tester.view.physicalSize = view;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TestApp(
        overrides: [
          viewSizeProvider.overrideWithBuild((_, _) => view),
          panelBackgroundProvider.overrideWith((_) => null),
        ],
        child: Row(
          children: [
            SizedBox(width: sidebarWidth),
            Expanded(
              child: Navigator(
                onGenerateInitialRoutes: (_, _) => [
                  MaterialPageRoute<void>(
                    builder: (context) => Scaffold(
                      body: TextButton(
                        onPressed: () => opener(context),
                        child: const Text('open'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Rect sheetRect(WidgetTester tester) => tester.getRect(find.byType(SideSheet));

  // The desktop card floats inset from the top, trailing and bottom edges.
  const margin = EdgeInsets.fromLTRB(0, 16, 16, 16);

  Rect floatingCard(double viewWidth, double viewHeight, double width) {
    return Rect.fromLTWH(
      viewWidth - margin.right - width,
      margin.top,
      width,
      viewHeight - margin.vertical,
    );
  }

  const expectedWidths = [(700.0, 360.0), (1280.0, 512.0), (1920.0, 560.0)];

  for (final MapEntry(key: name, value: opener) in _openers.entries) {
    for (final (viewWidth, width) in expectedWidths) {
      testWidgets('$name in a ${viewWidth.round()} dp window opens a '
          'floating side sheet ${width.round()} dp wide', (tester) async {
        final view = Size(viewWidth, 800);
        await open(tester, view, opener);
        expect(sheetRect(tester), floatingCard(viewWidth, view.height, width));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the side sheet follows the window as it resizes', (
    tester,
  ) async {
    await open(tester, const Size(1280, 800), _openers['showSheet']!);
    expect(sheetRect(tester).width, 512);

    tester.view.physicalSize = const Size(1600, 900);
    await tester.pumpAndSettle();
    expect(sheetRect(tester), floatingCard(1600, 900, 560));

    tester.view.physicalSize = const Size(1000, 800);
    await tester.pumpAndSettle();
    expect(sheetRect(tester), floatingCard(1000, 800, 400));
  });

  testWidgets('a page beside the sidebar opens the same width as the window '
      'root', (tester) async {
    await open(
      tester,
      const Size(1280, 800),
      _openers['showSheet']!,
      sidebarWidth: 240,
    );
    expect(sheetRect(tester), floatingCard(1280, 800, 512));
  });
}
