import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/widgets/base/inherited.dart';
import 'package:reclash/widgets/layout/floating_header.dart';
import 'package:reclash/widgets/layout/scaffold.dart';
import 'package:reclash/widgets/layout/sheet.dart';
import 'package:reclash/widgets/layout/side_sheet.dart';

import '../helpers/test_app.dart';

const _mobile = Size(400, 900);

Future<void> _open(
  WidgetTester tester,
  void Function(BuildContext) open, {
  Size size = _mobile,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
  await tester.pumpWidget(
    TestApp(
      overrides: [viewSizeProvider.overrideWithBuild((_, _) => size)],
      child: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => open(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a fit sheet keeps its height cap and returns a typed result', (
    tester,
  ) async {
    String? result;
    const contentKey = ValueKey('capped-sheet');
    await _open(tester, (context) async {
      result = await showSheet<String>(
        context: context,
        props: const SheetProps(maxHeight: 300),
        builder: (context) => SizedBox(
          key: contentKey,
          height: 600,
          child: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop('chosen'),
              child: const Text('choose'),
            ),
          ),
        ),
      );
    });

    expect(tester.getSize(find.byKey(contentKey)).height, 300);
    await tester.tap(find.text('choose'));
    await tester.pumpAndSettle();
    expect(result, 'chosen');
    expect(find.byKey(contentKey), findsNothing);
  });

  testWidgets('a side sheet preserves explicit width and optional blur', (
    tester,
  ) async {
    await _open(
      tester,
      (context) => showSheet<void>(
        context: context,
        props: const SheetProps(maxWidth: 280, blur: true),
        builder: (_) => const SizedBox.expand(child: Text('narrow')),
      ),
      size: const Size(1280, 800),
    );

    expect(tester.getSize(find.byType(SideSheet)).width, 280);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('live content can observe the sheet settling', (tester) async {
    late ValueListenable<bool> settling;
    await _open(
      tester,
      (context) => showSnapSheet<void>(
        context,
        builder: (_, controller) => CommonScaffold(
          title: 'live content',
          body: Builder(
            builder: (context) {
              settling = SheetSettlingScope.of(context)!;
              return ListView.builder(
                controller: controller,
                itemCount: 60,
                itemBuilder: (_, index) =>
                    SizedBox(height: 40, child: Text('row $index')),
              );
            },
          ),
        ),
      ),
    );

    expect(settling.value, isFalse);
    await tester.fling(find.byType(Scrollable), const Offset(0, -200), 2000);
    expect(settling.value, isTrue);
    await tester.pumpAndSettle();
    expect(settling.value, isFalse);
  });

  testWidgets('a horizontal sheet controller scrolls without resizing', (
    tester,
  ) async {
    await _open(
      tester,
      (context) => showSnapSheet<void>(
        context,
        builder: (_, _) => const CommonScaffold(
          title: 'horizontal content',
          body: Center(child: _HorizontalList()),
        ),
      ),
    );
    final top = tester.getTopLeft(find.byType(SheetDragHandle)).dy;
    final controller = tester
        .widget<ListView>(find.byType(ListView))
        .controller!;
    expect(controller, isA<SheetScrollController>());

    await tester.drag(find.byType(ListView), const Offset(-180, 0));
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
    expect(tester.getTopLeft(find.byType(SheetDragHandle)).dy, closeTo(top, 1));
  });

  testWidgets('a fit sheet respects reduced motion', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await _open(
      tester,
      (context) => showSheet<void>(
        context: context,
        builder: (_) => const SizedBox(height: 180, child: Text('reduced')),
      ),
    );
    final route = ModalRoute.of(tester.element(find.text('reduced')))!;
    expect(route.transitionDuration, Duration.zero);
    expect(route.reverseTransitionDuration, Duration.zero);
    expect(route.animation!.isCompleted, isTrue);
  });
}

class _HorizontalList extends StatefulWidget {
  const _HorizontalList();

  @override
  State<_HorizontalList> createState() => _HorizontalListState();
}

class _HorizontalListState extends State<_HorizontalList> {
  late final _controller = sheetScrollController(context);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        itemBuilder: (_, index) => SizedBox(width: 120, child: Text('$index')),
      ),
    );
  }
}
