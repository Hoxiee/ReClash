import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/icons/icons.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/state.dart';
import 'package:reclash/widgets/widgets.dart';
import '../helpers/test_app.dart';

void main() {
  late ProviderContainer container;
  List<NavigationItem> items() => [NavigationItem(glyph: AppGlyphs.dashboard,label: PageLabel.dashboard,builder:(_)=>const SizedBox.shrink())];
  setUp(() {FocusHighlightVisibility.visibleForTesting = true;});
  testWidgets('stress', (tester) async {
    tester.view.physicalSize = const Size(800,600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(overrides: [navigationItemsStateProvider.overrideWithValue(NavigationItemsState(value: items()))]);
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(800,600);
    var expanded=false;
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: TestApp(includeNavigatorKey:false, child: Scaffold(body: Align(alignment: Alignment.topLeft, child: SizedBox(height:500, child: StatefulBuilder(builder:(c,setState)=>AppNavRail(expanded: expanded,onToggle:(){setState(()=>expanded=!expanded);}))))))));
    await tester.pumpAndSettle();
    // expand
    await tester.tap(find.byKey(AppNavRail.toggleKey)); 
    for (var i=0;i<12;i++){await tester.pump(const Duration(milliseconds:30)); final w=tester.getSize(find.byType(AppNavRail)).width; expect(w, greaterThanOrEqualTo(48-0.01)); expect(w, lessThanOrEqualTo(80+0.01));}
    await tester.pumpAndSettle();
    // collapse
    await tester.tap(find.byKey(AppNavRail.toggleKey));
    for (var i=0;i<12;i++){await tester.pump(const Duration(milliseconds:30)); final w=tester.getSize(find.byType(AppNavRail)).width; expect(w, greaterThanOrEqualTo(48-0.01)); expect(w, lessThanOrEqualTo(80+0.01));}
    await tester.pumpAndSettle();
    // rapid
    for (var r=0;r<5;r++){
      await tester.tap(find.byKey(AppNavRail.toggleKey));
      await tester.pump(const Duration(milliseconds:40));
      final w=tester.getSize(find.byType(AppNavRail)).width;
      expect(w, greaterThanOrEqualTo(48-0.01)); expect(w, lessThanOrEqualTo(80+0.01));
    }
    await tester.pumpAndSettle();
  });
}
