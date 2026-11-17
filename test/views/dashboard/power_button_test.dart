import 'package:flutter_test/flutter_test.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/ui/icons/icons.dart';
import 'package:reclash/ui/ui.dart';
import 'package:reclash/views/dashboard/simple/egg.dart';
import 'package:reclash/views/dashboard/simple/power_button.dart';
import 'package:reclash/views/dashboard/widgets/card.dart';
import 'package:reclash/widgets/icon.dart';

import '../../helpers/test_app.dart';

Widget _app({
  required ProviderPowerShape shape,
  ProviderPowerType type = ProviderPowerType.solid,
  PowerLink link = PowerLink.on,
  PowerBadge? badge,
  VoidCallback? onPressed,
  bool enabled = true,
  EggConfig egg = const EggConfig(),
  ValueChanged<EggStage>? onEggStage,
}) => TestApp(
  child: Scaffold(
    body: Center(
      child: PowerButton(
        key: ValueKey((shape, type)),
        link: link,
        size: 152,
        logo: '',
        images: const AppProviderImages(),
        label: 'Toggle tunnel',
        onPressed: enabled ? onPressed ?? () {} : null,
        look: (shape: shape, type: type),
        badge: badge,
        egg: egg,
        onEggStage: onEggStage,
      ),
    ),
  ),
);

void main() {
  group('egg', () {
    const hold = Duration(milliseconds: 600);
    const config = EggConfig(hold: hold);

    testWidgets('holding a running button fires without toggling', (
      tester,
    ) async {
      var taps = 0;
      final stages = <EggStage>[];
      await tester.pumpWidget(
        _app(
          shape: ProviderPowerShape.cookie,
          egg: config,
          onPressed: () => taps++,
          onEggStage: stages.add,
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PowerButton)),
      );
      await tester.pump(eggPressDuration + const Duration(milliseconds: 50));
      expect(stages, [EggStage.holding]);
      await tester.pump();
      await tester.pump(hold);
      await tester.pump(hold);
      expect(stages.last, EggStage.fired);
      await gesture.up();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(eggTextDuration);
      expect(stages.last, EggStage.idle);
      expect(taps, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('releasing early cancels without a burst', (tester) async {
      final stages = <EggStage>[];
      await tester.pumpWidget(
        _app(
          shape: ProviderPowerShape.cookie,
          egg: config,
          onEggStage: stages.add,
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PowerButton)),
      );
      await tester.pump(eggPressDuration + const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await tester.pump(const Duration(seconds: 2));
      expect(stages, [EggStage.holding, EggStage.idle]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a long press does nothing while the tunnel is off', (
      tester,
    ) async {
      var taps = 0;
      final stages = <EggStage>[];
      await tester.pumpWidget(
        _app(
          shape: ProviderPowerShape.cookie,
          link: PowerLink.off,
          egg: config,
          onPressed: () => taps++,
          onEggStage: stages.add,
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PowerButton)),
      );
      await tester.pump(const Duration(seconds: 1));
      await gesture.up();
      await tester.pump(const Duration(seconds: 2));
      expect(stages, isEmpty);
      expect(taps, 1);
    });

    testWidgets('losing the connection mid-hold resets the egg', (
      tester,
    ) async {
      final stages = <EggStage>[];
      await tester.pumpWidget(
        _app(
          shape: ProviderPowerShape.cookie,
          egg: config,
          onEggStage: stages.add,
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PowerButton)),
      );
      await tester.pump(eggPressDuration + const Duration(milliseconds: 50));
      await tester.pumpWidget(
        _app(
          shape: ProviderPowerShape.cookie,
          link: PowerLink.off,
          egg: config,
          onEggStage: stages.add,
        ),
      );
      await tester.pump();
      expect(stages.last, EggStage.idle);
      await gesture.up();
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    });
  });

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

  testWidgets('the badge follows the body through a press', (tester) async {
    for (final shape in [
      ProviderPowerShape.circle,
      ProviderPowerShape.cookie,
    ]) {
      await tester.pumpWidget(
        _app(
          shape: shape,
          badge: const PowerBadge(AppGlyphs.check, PowerTone.normal),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      final body = find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint &&
            widget.painter.runtimeType.toString() == '_BodyPainter',
      );
      final badge = find.byWidgetPredicate(
        (widget) => widget is GlyphIcon && widget.glyph == AppGlyphs.check,
      );
      Rect painted(Finder finder) {
        final box = tester.renderObject<RenderBox>(finder);
        return MatrixUtils.transformRect(
          box.getTransformTo(null),
          ElasticPress.paintBoundsOf(box),
        );
      }

      Offset anchor() =>
          (painted(badge).center - painted(body).center) / painted(body).width;

      final rest = anchor();
      final restWidth = painted(body).width;
      expect(rest.dx, greaterThan(0.2), reason: '$shape');
      expect(rest.dy, greaterThan(0.2), reason: '$shape');

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(PowerButton)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(painted(body).width, greaterThan(restWidth), reason: '$shape');
      expect((anchor() - rest).distance, lessThan(0.005), reason: '$shape');
      await gesture.up();
      await tester.pump(const Duration(seconds: 1));
    }
  });
}
