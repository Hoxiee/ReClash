import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/views/config/on_demand_network_picker.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets(
    'loads, deduplicates and filters networks without changing SSIDs',
    (tester) async {
      String? chosen;
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          child: OnDemandNetworkPicker(
            selected: const {'Home'},
            listSsid: () async => ['Home', 'home', 'Office', 'Office'],
            onSelected: (ssid) => chosen = ssid,
            onEnterManually: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsNothing);
      expect(find.text('home'), findsOneWidget);
      expect(find.text('Office'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'off');
      await tester.pumpAndSettle();
      expect(find.text('home'), findsNothing);
      await tester.tap(find.text('Office'));
      expect(chosen, 'Office');
    },
  );

  testWidgets('a failed scan can be retried and repeated taps share a scan', (
    tester,
  ) async {
    var calls = 0;
    final answer = Completer<List<String>>();
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: OnDemandNetworkPicker(
          selected: const {},
          listSsid: () {
            calls++;
            if (calls == 1) return Future.error(Exception('scan failed'));
            return answer.future;
          },
          onSelected: (_) {},
          onEnterManually: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not read Wi-Fi'), findsOneWidget);
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pump();
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pump();
    expect(calls, 2);
    answer.complete(['Office']);
    await tester.pumpAndSettle();
    expect(find.text('Office'), findsOneWidget);
  });
}
