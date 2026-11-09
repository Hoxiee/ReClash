import 'package:flutter_test/flutter_test.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/views/dashboard/simple/power_button.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/widgets/icon.dart';

import '../../helpers/test_app.dart';

Widget _app({
  required ProviderPowerShape shape,
  ProviderPowerType type = ProviderPowerType.solid,
  PowerLink link = PowerLink.on,
  VoidCallback? onPressed,
  bool enabled = true,
}) => TestApp(
  child: Scaffold(
    body: Center(
      child: PowerButton(
        key: ValueKey((shape, type)),
        link: link,
        size: 152,
        logo: '',
        images: const AppProviderImages(),
        tooltip: 'Toggle tunnel',
        onPressed: enabled ? onPressed ?? () {} : null,
        look: (shape: shape, type: type),
      ),
    ),
  ),
);

void main() {
  for (final type in ProviderPowerType.values) {
    testWidgets('every $type shape renders each connection state', (
      tester,
    ) async {
      for (final shape in ProviderPowerShape.values) {
        for (final link in [
          PowerLink.off,
          PowerLink.connecting,
          PowerLink.on,
          PowerLink.paused,
          PowerLink.off,
        ]) {
          await tester.pumpWidget(_app(shape: shape, type: type, link: link));
          await tester.pump(const Duration(milliseconds: 500));
          expect(tester.takeException(), isNull, reason: '$shape/$type/$link');
          expect(find.byType(PowerButton), findsOneWidget);
        }
      }
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('burst stays soft and sharpBurst uses the sharp polygon', (
    tester,
  ) async {
    for (final entry in {
      ProviderPowerShape.burst: MaterialShapes.softBurst,
      ProviderPowerShape.sharpBurst: MaterialShapes.burst,
      ProviderPowerShape.pixelCircle: MaterialShapes.pixelCircle,
      ProviderPowerShape.softBoom: MaterialShapes.softBoom,
      ProviderPowerShape.boom: MaterialShapes.boom,
    }.entries) {
      await tester.pumpWidget(_app(shape: entry.key));
      final halos = tester.widgetList<ShapeBadge>(find.byType(ShapeBadge));
      expect(halos, hasLength(2));
      for (final halo in halos) {
        expect(halo.shape, same(entry.value));
      }
    }
  });

  testWidgets('new shapes remain tappable and honor disabled controls', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _app(shape: ProviderPowerShape.pixelCircle, onPressed: () => taps++),
    );
    await tester.tap(find.byType(PowerButton));
    expect(taps, 1);
    await tester.pumpWidget(
      _app(
        shape: ProviderPowerShape.pixelCircle,
        enabled: false,
        onPressed: () => taps++,
      ),
    );
    await tester.tap(find.byType(PowerButton));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });
}
