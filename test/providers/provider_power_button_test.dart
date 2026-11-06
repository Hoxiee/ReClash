import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/provider_settings.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import '../helpers/provider_presentation.dart';

class _MockRandom extends Mock implements Random {}

/// [pairs] reads like `shape:cookie,flower;type:solid`.
ProviderHints _hints(String? pairs) => presentedHints({
  if (pairs != null)
    'power-button': {
      for (final pair in pairs.split(';'))
        pair.split(':').first: pair.split(':').last,
    },
});

class _Harness {
  _Harness(String? header) : hints = _hints(header) {
    when(() => random.nextInt(any())).thenAnswer(
      (invocation) => draws++ % (invocation.positionalArguments.single as int),
    );
    container = ProviderContainer(
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => 1),
        providerHintsProvider.overrideWith((ref) => hints),
        providerPowerButtonProvider.overrideWith(
          () => ProviderPowerButtonSelection(random: random),
        ),
      ],
    );
    container.listen(currentProfileIdProvider, (_, _) {});
    container.listen(providerPowerButtonProvider, (_, _) {});
    addTearDown(container.dispose);
  }

  final random = _MockRandom();
  late final ProviderContainer container;
  ProviderHints? hints;
  var draws = 0;

  ProviderPowerButton get look => container.read(providerPowerButtonProvider);

  void update(String? header) {
    hints = _hints(header);
    container.invalidate(providerHintsProvider);
  }
}

void main() {
  test('a fixed shape never consumes a random draw', () {
    final harness = _Harness('shape:puffyDiamond;type:outline');
    expect(harness.look, (
      shape: ProviderPowerShape.puffyDiamond,
      type: ProviderPowerType.outline,
    ));
    expect(harness.draws, 0);
  });

  test('random draws once from every concrete shape', () {
    final harness = _Harness('shape:random;type:tonal');
    expect(harness.look, (
      shape: ProviderPowerShape.cookie,
      type: ProviderPowerType.tonal,
    ));
    verify(() => harness.random.nextInt(21)).called(1);
    for (var i = 0; i < 5; i++) {
      harness.container.invalidate(providerHintsProvider);
      expect(harness.look.shape, ProviderPowerShape.cookie);
    }
    expect(harness.draws, 1);
  });

  test('type, case, order and duplicate changes keep the same choice', () {
    final harness = _Harness('shape:cookie,flower;type:solid');
    expect(harness.look.shape, ProviderPowerShape.cookie);
    harness.update('shape:FLOWER, cookie, cookie, bogus;type:tonal');
    expect(harness.look, (
      shape: ProviderPowerShape.cookie,
      type: ProviderPowerType.tonal,
    ));
    harness.update('unknown:x;type:outline;shape:flower,cookie');
    expect(harness.look, (
      shape: ProviderPowerShape.cookie,
      type: ProviderPowerType.outline,
    ));
    expect(harness.draws, 1);
  });

  test('changing the pool draws only from the replacement pool', () {
    final harness = _Harness('shape:cookie,circle');
    expect(harness.look.shape, ProviderPowerShape.cookie);
    harness.update('shape:puffy,puffyDiamond;type:outline');
    expect(harness.look, (
      shape: ProviderPowerShape.puffyDiamond,
      type: ProviderPowerType.outline,
    ));
    expect(harness.draws, 2);
  });

  test('switching profiles draws again even for an identical pool', () {
    final harness = _Harness('shape:cookie,circle');
    expect(harness.look.shape, ProviderPowerShape.cookie);
    harness.container.read(currentProfileIdProvider.notifier).value = 2;
    expect(harness.look.shape, ProviderPowerShape.circle);
    harness.container.read(currentProfileIdProvider.notifier).value = 1;
    expect(harness.look.shape, ProviderPowerShape.cookie);
    expect(harness.draws, 3);
  });

  test('a one-element pool becomes a fixed shape', () {
    final harness = _Harness('shape:puffy,puffy,unknown');
    expect(harness.look.shape, ProviderPowerShape.puffy);
    expect(harness.draws, 0);
  });

  test('withdrawn or invalid hints restore the default without drawing', () {
    final harness = _Harness('shape:random;type:outline');
    expect(harness.look.type, ProviderPowerType.outline);
    harness.update(null);
    expect(harness.look, defaultProviderPowerButton);
    harness.update('shape:unknown,missing;type:invalid');
    expect(harness.look, defaultProviderPowerButton);
    expect(harness.draws, 1);
  });

  test('unloaded hints use the default and resolve once when loaded', () {
    final harness = _Harness(null);
    harness.hints = null;
    harness.container.invalidate(providerHintsProvider);
    expect(harness.look, defaultProviderPowerButton);
    harness.update('shape:puffy,puffyDiamond');
    expect(harness.look.shape, ProviderPowerShape.puffy);
    expect(harness.draws, 1);
  });
}
