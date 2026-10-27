import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/providers/providers.dart';
import 'package:reclash/views/config/on_demand_network_picker.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

import '../helpers/test_app.dart';

class _TestLocationPermissions extends LocationPermissions {
  _TestLocationPermissions(this._initial);

  final WifiSsidPermission _initial;

  @override
  WifiSsidPermission build() => _initial;
}

void main() {
  testWidgets('loads and deduplicates networks without changing SSIDs', (
    tester,
  ) async {
    String? chosen;
    var manual = false;
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: OnDemandNetworkPicker(
          selected: const {'Home'},
          requiresLocation: false,
          listSsid: () async => ['Home', 'home', 'Office', 'Office'],
          onSelected: (ssid) => chosen = ssid,
          onEnterManually: () => manual = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(find.text('home'), findsOneWidget);
    expect(find.text('Office'), findsOneWidget);
    await tester.tap(find.text('Office'));
    expect(chosen, 'Office');
    await tester.tap(find.byTooltip('Enter manually'));
    expect(manual, isTrue);
  });

  testWidgets('a failed scan can be retried from the status', (tester) async {
    var calls = 0;
    final answer = Completer<List<String>>();
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: OnDemandNetworkPicker(
          selected: const {},
          requiresLocation: false,
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
    await tester.tap(find.text('Refresh'));
    await tester.pump();
    expect(find.text('Refresh'), findsNothing);
    expect(calls, 2);
    answer.complete(['Office']);
    await tester.pumpAndSettle();
    expect(find.text('Office'), findsOneWidget);
  });

  testWidgets(
    'without location access the sheet asks for it and still allows manual '
    'entry, then scans once it is granted',
    (tester) async {
      var calls = 0;
      final container = ProviderContainer(
        overrides: [
          locationPermissionsProvider.overrideWith(
            () => _TestLocationPermissions(WifiSsidPermission.denied),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: OnDemandNetworkPicker(
              selected: const {},
              requiresLocation: true,
              listSsid: () async {
                calls++;
                return ['Office'];
              },
              onSelected: (_) {},
              onEnterManually: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(find.text('Location permission required'), findsOneWidget);
      expect(find.text('Authorize'), findsOneWidget);
      expect(find.byTooltip('Enter manually'), findsOneWidget);

      container.read(locationPermissionsProvider.notifier).state =
          WifiSsidPermission.granted;
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.text('Authorize'), findsNothing);
      expect(find.text('Office'), findsOneWidget);
    },
  );
}
