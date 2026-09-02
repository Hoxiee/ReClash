import 'package:reclash/models/models.dart';
import 'package:reclash/providers/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/state.dart';
import 'package:reclash/views/config/smart_pause.dart';
import 'package:reclash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

import '../helpers/test_app.dart';

class _TestVpnSetting extends VpnSetting {
  _TestVpnSetting(this._initial);

  final VpnProps _initial;

  @override
  VpnProps build() => _initial;
}

class _TestLocationPermissions extends LocationPermissions {
  _TestLocationPermissions(this._initial);

  final WifiSsidPermission _initial;

  @override
  WifiSsidPermission build() => _initial;
}

void main() {
  late ProviderContainer container;

  Future<void> pumpView(
    WidgetTester tester, {
    List<String> networks = const [],
    bool enabled = true,
    WifiSsidPermission permission = WifiSsidPermission.denied,
    bool isAndroid = false,
    bool isMacOS = false,
    Locale? locale,
    Size size = const Size(1400, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer(
      overrides: [
        vpnSettingProvider.overrideWith(
          () => _TestVpnSetting(
            VpnProps(
              smartPauseEnabled: enabled,
              smartPauseNetworks: networks,
            ),
          ),
        ),
        locationPermissionsProvider.overrideWith(
          () => _TestLocationPermissions(permission),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          locale: locale,
          child: SmartPauseView(isAndroid: isAndroid, isMacOS: isMacOS),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an empty list shows the placeholder and only the add action', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.text('No trusted networks yet'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Select all'), findsNothing);
    expect(find.byIcon(Icons.delete), findsNothing);
  });

  testWidgets('every trusted network is rendered', (tester) async {
    await pumpView(tester, networks: ['Home', '192.168.1.0/24']);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('192.168.1.0/24'), findsOneWidget);
    expect(find.text('No trusted networks yet'), findsNothing);
  });

  testWidgets('subnets and SSIDs get their own leading icons', (tester) async {
    await pumpView(tester, networks: ['Home', '192.168.1.0/24']);

    expect(find.byIcon(Icons.wifi_rounded), findsOneWidget);
    expect(find.byIcon(Icons.router_rounded), findsOneWidget);
  });

  testWidgets('the trusted-now status appears only with rules', (tester) async {
    await pumpView(tester, networks: ['Home']);
    expect(find.text('Current network is not trusted'), findsOneWidget);
  });

  testWidgets('the trusted-now status hides without rules', (tester) async {
    await pumpView(tester, networks: const []);
    expect(find.text('Current network is not trusted'), findsNothing);
  });

  testWidgets('the trusted-now status hides while disabled', (tester) async {
    await pumpView(tester, networks: ['Home'], enabled: false);
    expect(find.text('Current network is not trusted'), findsNothing);
  });

  testWidgets('selecting an item swaps the header into selection mode', (
    tester,
  ) async {
    await pumpView(tester, networks: ['Home', 'Office']);
    expect(find.byIcon(Icons.delete), findsNothing);

    await tester.tap(find.byType(CommonCheckBox).first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete), findsOneWidget);
    expect(find.text('Select all'), findsOneWidget);
    expect(find.text('Add'), findsNothing);
  });

  testWidgets('select all takes every network, and pressing it again clears', (
    tester,
  ) async {
    await pumpView(tester, networks: ['Home', 'Office']);
    await tester.tap(find.byType(CommonCheckBox).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
    expect(container.read(itemsProvider(_viewKey(tester))), {'Home', 'Office'});

    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
    expect(find.text('Add'), findsOneWidget, reason: 'selection was cleared');
  });

  testWidgets('deleting removes the selected networks and clears the selection', (
    tester,
  ) async {
    await pumpView(tester, networks: ['Home', 'Office']);
    await tester.tap(find.byType(CommonCheckBox).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(
      container.read(vpnSettingProvider).smartPauseNetworks,
      ['Office'],
    );
    expect(find.text('Home'), findsNothing);
    expect(find.text('Add'), findsOneWidget, reason: 'selection was cleared');
  });

  testWidgets('the switches toggle smart pause and connection closing', (
    tester,
  ) async {
    await pumpView(tester, networks: ['Home']);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(container.read(vpnSettingProvider).smartPauseEnabled, isFalse);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(container.read(vpnSettingProvider).smartPauseEnabled, isTrue);

    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();
    expect(
      container.read(vpnSettingProvider).smartPauseCloseConnections,
      isTrue,
    );
  });

  testWidgets('the location prerequisite reflects a denied permission', (
    tester,
  ) async {
    await pumpView(
      tester,
      permission: WifiSsidPermission.denied,
      isMacOS: true,
    );

    expect(find.bySemanticsLabel('Tap to authorize'), findsOneWidget);
    expect(find.bySemanticsLabel('Authorized'), findsNothing);
  });

  testWidgets('the location prerequisite reflects a granted permission', (
    tester,
  ) async {
    await pumpView(
      tester,
      permission: WifiSsidPermission.granted,
      isMacOS: true,
    );

    expect(find.bySemanticsLabel('Authorized'), findsOneWidget);
    expect(find.bySemanticsLabel('Tap to authorize'), findsNothing);
  });

  testWidgets('Android also asks to be left out of battery optimization', (
    tester,
  ) async {
    await pumpView(tester, isAndroid: true);

    expect(find.text('Ignore battery optimization'), findsOneWidget);
    expect(find.text('Location permission'), findsOneWidget);
  });

  testWidgets('the authorize action sits on its own line under the text', (
    tester,
  ) async {
    await pumpView(tester, isMacOS: true, locale: const Locale('ru'));

    final appLocalizations = AppLocalizations.of(
      tester.element(find.byType(SmartPauseView)),
    );
    final desc = find.text(appLocalizations.locationPermissionDesc);
    final button = find
        .ancestor(
          of: find.text(appLocalizations.tapToAuthorize),
          matching: find.byType(FilledButton),
        )
        .first;

    expect(
      tester.getTopLeft(button).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(desc).dy),
    );
    expect(
      tester.getRect(button).right,
      closeTo(
        tester.getRect(find.byType(DecorationListItem).first).right - 16,
        1,
      ),
    );
  });

  testWidgets('a desktop that is not macOS asks for no prerequisite', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.text('Ignore battery optimization'), findsNothing);
    expect(find.text('Location permission'), findsNothing);
    expect(find.bySemanticsLabel('Tap to authorize'), findsNothing);
  });
}

/// The view keys its shared selection notifier by [UniqueKeyStateMixin.key], so
/// a test has to read the same id off the mounted state.
String _viewKey(WidgetTester tester) {
  final state = tester.state(find.byType(SmartPauseView)) as dynamic;
  return state.key as String;
}
