import 'package:reclash/providers/app.dart';
import 'package:reclash/ui/inherited.dart';
import 'package:reclash/ui/paged_sheet.dart';
import 'package:reclash/ui/scaffold.dart';
import 'package:reclash/ui/sheet.dart';
import 'package:reclash/ui/sheet_header.dart';
import 'package:reclash/ui/side_sheet.dart';
import 'package:reclash/ui/view_scope.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

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
    bool? mobileLayout,
    ValueNotifier<bool>? openerVisible,
  }) async {
    Widget page(BuildContext context) => Scaffold(
      body: TextButton(
        onPressed: () => opener(context),
        child: const Text('open'),
      ),
    );
    tester.view.physicalSize = view;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TestApp(
        overrides: [viewSizeProvider.overrideWithBuild((_, _) => view)],
        child: Builder(
          builder: (context) => ViewScope(
            size: MediaQuery.sizeOf(context),
            isMobile: mobileLayout ?? view.width <= 600,
            child: Row(
              children: [
                SizedBox(width: sidebarWidth),
                Expanded(
                  child: Navigator(
                    onGenerateInitialRoutes: (_, _) => [
                      MaterialPageRoute<void>(
                        builder: (context) => openerVisible == null
                            ? page(context)
                            : ValueListenableBuilder(
                                valueListenable: openerVisible,
                                builder: (_, visible, child) =>
                                    visible ? child! : const SizedBox.shrink(),
                                child: Builder(builder: page),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Rect sheetRect(WidgetTester tester) => tester.getRect(find.byType(SideSheet));

  const expectedWidths = [(700.0, 360.0), (1280.0, 512.0), (1920.0, 560.0)];

  for (final MapEntry(key: name, value: opener) in _openers.entries) {
    for (final (viewWidth, width) in expectedWidths) {
      testWidgets('$name in a ${viewWidth.round()} dp window opens a '
          'floating side sheet ${width.round()} dp wide', (tester) async {
        final view = Size(viewWidth, 800);
        await open(tester, view, opener);
        expect(
          sheetRect(tester),
          Rect.fromLTWH(viewWidth - width - 16, 16, width, view.height - 32),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final MapEntry(key: name, value: opener) in _openers.entries) {
    testWidgets('$name uses window width instead of the navigation layout', (
      tester,
    ) async {
      await open(tester, const Size(1280, 800), opener, mobileLayout: true);
      expect(sheetRect(tester).width, 512);
      expect(find.byType(SheetDragHandle), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$name stays compact in a narrow sidebar layout', (
      tester,
    ) async {
      await open(tester, const Size(500, 800), opener, mobileLayout: false);
      expect(find.byType(SideSheet), findsNothing);
      expect(
        find.byType(SheetDragHandle),
        name == 'showExtend' ? findsNothing : findsOneWidget,
      );
      expect(find.text('title'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a wide form remains a form sheet with bar navigation', (
    tester,
  ) async {
    await open(
      tester,
      const Size(1280, 800),
      (context) =>
          showFormSheet<void>(context: context, builder: (_) => _page()),
      mobileLayout: true,
    );
    expect(
      SheetProvider.of(tester.element(find.text('title')))?.type,
      SheetType.formSheet,
    );
    expect(find.byType(SheetDragHandle), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a narrow form stays a bottom sheet with sidebar navigation', (
    tester,
  ) async {
    await open(
      tester,
      const Size(500, 800),
      (context) =>
          showFormSheet<void>(context: context, builder: (_) => _page()),
      mobileLayout: false,
    );
    expect(
      SheetProvider.of(tester.element(find.text('title')))?.type,
      SheetType.bottomSheet,
    );
    expect(find.byType(SheetDragHandle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a snap sheet crosses the width breakpoint with bar navigation '
      'and completes only when dismissed', (tester) async {
    late Future<String?> result;
    var completed = false;
    String? value;
    await open(tester, const Size(1280, 800), (context) {
      result = showSnapSheet<String>(context, builder: (_, _) => _page());
      result.then((result) {
        completed = true;
        value = result;
      });
    }, mobileLayout: true);
    expect(find.byType(SideSheet), findsOneWidget);

    tester.view.physicalSize = const Size(500, 800);
    await tester.pumpAndSettle();
    expect(find.byType(SideSheet), findsNothing);
    expect(find.byType(SheetDragHandle), findsOneWidget);
    expect(completed, isFalse);

    tester.view.physicalSize = const Size(1280, 800);
    await tester.pumpAndSettle();
    expect(find.byType(SideSheet), findsOneWidget);
    expect(find.byType(SheetDragHandle), findsNothing);
    expect(completed, isFalse);

    Navigator.of(tester.element(find.text('title'))).pop('done');
    await tester.pumpAndSettle();
    expect(completed, isTrue);
    expect(value, 'done');
    expect(tester.takeException(), isNull);
  });

  for (final wideType in [SheetType.sideSheet, SheetType.formSheet]) {
    for (final initialWidth in [500.0, 1280.0]) {
      testWidgets('an open $wideType adapts from $initialWidth dp without '
          'losing input or completing', (tester) async {
        var completed = false;
        String? value;
        await open(tester, Size(initialWidth, 800), (context) {
          Widget page(BuildContext context) => CommonScaffold(
            title: 'title',
            body: ListView(
              children: [
                const TextField(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop('done'),
                  child: const Text('done'),
                ),
              ],
            ),
          );
          final result = wideType == SheetType.formSheet
              ? showFormSheet<String>(context: context, builder: page)
              : showSheet<String>(context: context, builder: page);
          result.then((result) {
            completed = true;
            value = result;
          });
        }, mobileLayout: true);
        final navigator = Navigator.of(tester.element(find.text('title')));
        final scaffold = tester.state(find.byType(CommonScaffold));
        await tester.enterText(find.byType(TextField), 'unsaved input');

        for (final width in [1280.0, 600.0, 601.0, 500.0]) {
          tester.view.physicalSize = Size(width, 800);
          await tester.pumpAndSettle();
          expect(
            SheetProvider.of(tester.element(find.text('title')))?.type,
            width <= 600 ? SheetType.bottomSheet : wideType,
          );
          expect(tester.state(find.byType(CommonScaffold)), same(scaffold));
          expect(find.text('unsaved input'), findsOneWidget);
          expect(
            Navigator.of(tester.element(find.text('title'))),
            same(navigator),
          );
          expect(completed, isFalse);
          expect(tester.takeException(), isNull);
        }

        await tester.tap(find.text('done'));
        await tester.pumpAndSettle();
        expect(completed, isTrue);
        expect(value, 'done');
        expect(find.text('title'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('an open $wideType still adapts after its opener unmounts', (
      tester,
    ) async {
      final visible = ValueNotifier(true);
      addTearDown(visible.dispose);
      late BuildContext openerContext;
      var completed = false;
      await open(tester, const Size(500, 800), (context) {
        openerContext = context;
        final result = wideType == SheetType.formSheet
            ? showFormSheet<void>(context: context, builder: (_) => _page())
            : showSheet<void>(context: context, builder: (_) => _page());
        result.then((_) => completed = true);
      }, openerVisible: visible);
      visible.value = false;
      await tester.pump();
      expect(openerContext.mounted, isFalse);

      final sheetContext = tester.element(find.text('title'));
      showDialog<void>(
        context: sheetContext,
        useRootNavigator: false,
        builder: (_) => const Text('cover'),
      );
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(1280, 800);
      await tester.pumpAndSettle();
      expect(find.text('cover'), findsOneWidget);
      expect(completed, isFalse);
      Navigator.of(tester.element(find.text('cover'))).pop();
      await tester.pumpAndSettle();
      expect(
        SheetProvider.of(tester.element(find.text('title')))?.type,
        wideType,
      );
      expect(completed, isFalse);

      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(completed, isTrue);
      expect(find.text('title'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an open $wideType preserves nested pages and scrolling', (
      tester,
    ) async {
      await open(tester, const Size(500, 800), (context) {
        Widget builder(BuildContext context) => NestedPagedSheet(
          builder: (context) => CommonScaffold(
            title: 'root',
            body: ListView(
              padding: const EdgeInsets.only(top: 80),
              children: [
                TextButton(
                  onPressed: () => showInSheet<void>(
                    context,
                    builder: (_) => CommonScaffold(
                      title: 'details',
                      body: ListView(
                        children: [
                          const TextField(),
                          for (var i = 0; i < 40; i++)
                            ListTile(title: Text('detail $i')),
                        ],
                      ),
                    ),
                  ),
                  child: const Text('next'),
                ),
              ],
            ),
          ),
        );
        if (wideType == SheetType.formSheet) {
          showFormSheet<void>(context: context, builder: builder);
        } else {
          showSheet<void>(
            context: context,
            props: nestedPagedSheetProps,
            builder: builder,
          );
        }
      });
      await tester.tap(find.text('next'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'nested input');
      final navigator = Navigator.of(tester.element(find.text('details')));

      for (final width in [1280.0, 500.0, 1280.0]) {
        tester.view.physicalSize = Size(width, 800);
        await tester.pumpAndSettle();
        expect(find.text('details'), findsOneWidget);
        expect(find.text('nested input'), findsOneWidget);
        expect(
          Navigator.of(tester.element(find.text('details'))),
          same(navigator),
        );
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView), const Offset(0, 300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      navigator.pop();
      await tester.pumpAndSettle();
      expect(find.text('root'), findsOneWidget);
      expect(find.text('details'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a snap sheet keeps the controller borrowed by a nested page', (
    tester,
  ) async {
    late Future<void> closed;
    await open(tester, const Size(500, 800), (context) {
      closed = showSnapSheet<void>(
        context,
        builder: (_, controller) => NestedPagedSheet(
          builder: (_) => CommonScaffold(
            title: 'title',
            body: ListView(
              controller: controller,
              children: [
                for (var i = 0; i < 50; i++) ListTile(title: Text('row $i')),
              ],
            ),
          ),
        ),
      );
    });
    final controller = tester
        .widget<ListView>(find.byType(ListView))
        .controller;
    expect(controller, isNotNull);

    for (final width in [1280.0, 500.0, 1280.0]) {
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpAndSettle();
      expect(
        tester.widget<ListView>(find.byType(ListView)).controller,
        same(controller),
      );
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();
      expect(controller!.offset, greaterThan(0));
      expect(tester.takeException(), isNull);
    }

    Navigator.of(tester.element(find.byType(NestedPagedSheet))).pop();
    await tester.pumpAndSettle();
    await closed;
    expect(find.text('title'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the side sheet follows the window as it resizes', (
    tester,
  ) async {
    await open(tester, const Size(1280, 800), _openers['showSheet']!);
    expect(sheetRect(tester).width, 512);

    tester.view.physicalSize = const Size(1600, 900);
    await tester.pumpAndSettle();
    expect(
      sheetRect(tester),
      const Rect.fromLTWH(1600 - 560 - 16, 16, 560, 900 - 32),
    );

    tester.view.physicalSize = const Size(1000, 800);
    await tester.pumpAndSettle();
    expect(
      sheetRect(tester),
      const Rect.fromLTWH(1000 - 400 - 16, 16, 400, 800 - 32),
    );
  });

  testWidgets('a page beside the sidebar opens the same width as the window '
      'root', (tester) async {
    await open(
      tester,
      const Size(1280, 800),
      _openers['showSheet']!,
      sidebarWidth: 240,
    );
    expect(
      sheetRect(tester),
      const Rect.fromLTWH(1280 - 512 - 16, 16, 512, 800 - 32),
    );
  });
}
