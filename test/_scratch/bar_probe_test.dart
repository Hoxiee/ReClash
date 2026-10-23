import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/theme.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  testWidgets('probe', (tester) async {
    final container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(390, 844);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ThemeView()),
      ),
    );
    await tester.pumpAndSettle();
    final seg = find.byType(GlyphSegmentedControl<int>);
    // ignore: avoid_print
    print(tester.getRect(seg));
    await tester.tap(
      find.descendant(
        of: seg,
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Background',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    // ignore: avoid_print
    print('count ${seg.evaluate().length}');
    for (final e
        in find
            .byWidgetPredicate(
              (w) => w is Semantics && w.properties.label != null,
            )
            .evaluate()) {
      // ignore: avoid_print
      print('label ${(e.widget as Semantics).properties.label}');
    }
    tester.element(seg).visitAncestorElements((e) {
      final r = e.renderObject;
      final w = e.widget;
      if (w is Opacity ||
          w is AppBar ||
          w is IgnorePointer ||
          w is Scaffold ||
          w is PageActivityScope ||
          w is ExcludeSemantics) {
        // ignore: avoid_print
        print(
          '${w.runtimeType} ${r is RenderBox && r.hasSize ? r.size : ''} ${w is PageActivityScope ? w.isActive : ''} ${w is Opacity ? w.opacity : ''}',
        );
      }
      return w is! Scaffold;
    });
    // ignore: avoid_print
    print(tester.getRect(seg));
  });
}
