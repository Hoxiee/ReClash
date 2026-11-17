import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/seasonal/calendar.dart';
import 'package:reclash/features/seasonal/layer.dart';
import 'package:reclash/features/seasonal/painter.dart';
import 'package:reclash/features/seasonal/providers.dart';

const _snow = SeasonalEffect(SeasonalEffectKind.snow, SeasonalDensity.medium);

class _Effects extends Notifier<List<SeasonalEffect>> {
  @override
  List<SeasonalEffect> build() => const [];

  void show(List<SeasonalEffect> effects) => state = effects;
}

final _effects = NotifierProvider<_Effects, List<SeasonalEffect>>(_Effects.new);

class _Page extends StatefulWidget {
  const _Page();

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  @override
  Widget build(BuildContext context) => const Text('page');
}

Future<void> _pumpBackdrop(WidgetTester tester, {bool reduceMotion = false}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        seasonalEffectsProvider.overrideWith((ref) => ref.watch(_effects)),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: const SeasonalBackdrop(child: _Page()),
        ),
      ),
    ),
  );
}

void _show(WidgetTester tester, List<SeasonalEffect> effects) {
  ProviderScope.containerOf(
    tester.element(find.byType(_Page)),
  ).read(_effects.notifier).show(effects);
}

Finder get _painter => find.byWidgetPredicate(
  (widget) => widget is CustomPaint && widget.painter is SeasonalPainter,
);

void main() {
  testWidgets('keeps the page state when effects come and go', (tester) async {
    await _pumpBackdrop(tester);
    final page = tester.state<_PageState>(find.byType(_Page));

    _show(tester, const [_snow]);
    await tester.pump();
    expect(tester.state<_PageState>(find.byType(_Page)), same(page));

    _show(tester, const []);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.state<_PageState>(find.byType(_Page)), same(page));

    _show(tester, const [_snow]);
    await tester.pump();
    expect(tester.state<_PageState>(find.byType(_Page)), same(page));
  });

  testWidgets('paints the effects while shown and drops them after fading', (
    tester,
  ) async {
    await _pumpBackdrop(tester);
    expect(_painter, findsNothing);

    _show(tester, const [_snow]);
    await tester.pump(const Duration(milliseconds: 100));
    expect(_painter, findsOneWidget);

    _show(tester, const []);
    await tester.pump(const Duration(seconds: 1));
    expect(_painter, findsNothing);
  });

  testWidgets(
    'a reduced-motion user gets a still backdrop without a frame loop',
    (tester) async {
      await _pumpBackdrop(tester, reduceMotion: true);

      _show(tester, const [_snow]);
      await tester.pump();

      expect(_painter, findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );

  testWidgets('keeps the particles moving when animations are allowed', (
    tester,
  ) async {
    await _pumpBackdrop(tester);

    _show(tester, const [_snow]);
    await tester.pump();

    expect(tester.binding.hasScheduledFrame, isTrue);
  });

  testWidgets('unmounting while shown leaves no frame loop behind', (
    tester,
  ) async {
    await _pumpBackdrop(tester);
    _show(tester, const [_snow]);
    await tester.pump();

    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
