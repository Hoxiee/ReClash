import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/navigation_bar.dart';

import '../helpers/test_app.dart';

NavigationBarEntry _entry(String id) => NavigationBarEntry(
  id: id,
  icon: const GlyphIcon(AppGlyphs.tools),
  label: id,
);

void main() {
  testWidgets('membership changes fade without enabling outgoing controls', (
    tester,
  ) async {
    var entries = [_entry('dashboard'), _entry('profiles'), _entry('tools')];
    final selections = <String>[];
    late StateSetter rebuild;
    await tester.pumpWidget(
      TestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedNavigationBar(
                destinations: entries,
                selectedIndex: entries.length - 1,
                onSelected: (index) =>
                    selections.add(entries[index].id as String),
              ),
            );
          },
        ),
      ),
    );
    rebuild(() => entries = [_entry('dashboard'), _entry('tools')]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('profiles'), findsOneWidget);
    await tester.tap(find.text('profiles'), warnIfMissed: false);
    expect(selections, isNot(contains('profiles')));
    selections.clear();
    await tester.pumpAndSettle();
    expect(find.text('profiles'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('tools'));
    expect(selections, ['tools']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty and singleton strips do not construct an invalid bar', (
    tester,
  ) async {
    var entries = <NavigationBarEntry>[];
    var taps = 0;
    late StateSetter rebuild;
    await tester.pumpWidget(
      TestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedNavigationBar(
                destinations: entries,
                selectedIndex: 0,
                onSelected: (_) => taps++,
              ),
            );
          },
        ),
      ),
    );
    expect(find.byType(NavigationBar), findsNothing);
    rebuild(() => entries = [_entry('dashboard')]);
    await tester.pumpAndSettle();
    await tester.tap(find.text('dashboard'));
    expect(taps, 1);
    rebuild(() => entries = []);
    await tester.pumpAndSettle();
    expect(find.text('dashboard'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion replaces the strip without an outgoing copy', (
    tester,
  ) async {
    var entries = [_entry('dashboard'), _entry('profiles'), _entry('tools')];
    late StateSetter rebuild;
    await tester.pumpWidget(
      TestApp(
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return AnimatedNavigationBar(
                destinations: entries,
                selectedIndex: entries.length - 1,
                onSelected: (_) {},
              );
            },
          ),
        ),
      ),
    );
    rebuild(() => entries = [_entry('dashboard'), _entry('tools')]);
    await tester.pump();
    await tester.pump();
    expect(find.text('profiles'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('enabling reduced motion removes an in-flight outgoing strip', (
    tester,
  ) async {
    var entries = [_entry('dashboard'), _entry('profiles'), _entry('tools')];
    var reduceMotion = false;
    late StateSetter rebuild;
    await tester.pumpWidget(
      TestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return MediaQuery(
              data: MediaQueryData(disableAnimations: reduceMotion),
              child: AnimatedNavigationBar(
                destinations: entries,
                selectedIndex: entries.length - 1,
                onSelected: (_) {},
              ),
            );
          },
        ),
      ),
    );
    rebuild(() => entries = [_entry('dashboard'), _entry('tools')]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('profiles'), findsOneWidget);
    rebuild(() => reduceMotion = true);
    await tester.pump();
    expect(find.text('profiles'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the label behaviour reaches the bar and a singleton strip', (
    tester,
  ) async {
    var entries = [_entry('dashboard'), _entry('tools')];
    late StateSetter rebuild;
    await tester.pumpWidget(
      TestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedNavigationBar(
                destinations: entries,
                selectedIndex: 0,
                onSelected: (_) {},
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              ),
            );
          },
        ),
      ),
    );
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).labelBehavior,
      NavigationDestinationLabelBehavior.alwaysHide,
    );
    rebuild(() => entries = [_entry('dashboard')]);
    await tester.pumpAndSettle();
    expect(find.text('dashboard'), findsNothing);
    expect(find.bySemanticsLabel('dashboard'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
