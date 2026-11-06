import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/provider_settings.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_cards.dart';
import 'package:reclash/subscriptions/metadata/provider_config.dart';
import 'package:reclash/subscriptions/metadata/provider_conditions.dart';
import 'package:reclash/subscriptions/metadata/provider_power_labels.dart';

ProviderCardsResult parse(Object? json) => parseProviderCards(json);

class _CountingRandom implements Random {
  int draws = 0;

  @override
  int nextInt(int max) => draws++ % max;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

void main() {
  group('cards', () {
    test('parses each type', () {
      final result = parse([
        {
          'id': 'works',
          'type': 'note',
          'level': 'warning',
          'text': 'Maintenance',
          'dismissible': true,
          'when': {'until': 10},
          'copy': 'CODE',
        },
        {
          'id': 'sale',
          'type': 'banner',
          'layout': 'split',
          'title': 'Sale',
          'image': 'https://cdn.example.net/a.webp',
          'countdown': 99,
          'button': {'label': 'Copy', 'copy': 'SALE30'},
        },
        {
          'id': 'links',
          'type': 'actions',
          'items': [
            {'icon': 'support', 'label': 'Bot', 'url': 'https://t.me/bot'},
            {'icon': 'speed', 'label': 'Speed', 'app': 'speedTest'},
          ],
        },
      ]);
      expect(result.warnings, isEmpty);
      final [note, banner, actions] = result.cards;
      expect((note as ProviderNote).level, ProviderNoteLevel.warning);
      expect(note.dismissible, isTrue);
      expect(note.action?.kind, ProviderActionKind.copy);
      expect(note.boundaries, [10]);
      expect((banner as ProviderBanner).layout, ProviderBannerLayout.split);
      expect(banner.button?.action.text, 'SALE30');
      expect(banner.boundaries, [99]);
      expect(
        (actions as ProviderActions).items.last.action.app,
        ProviderAppAction.speedTest,
      );
    });

    test('skips an invalid card alone with a warning', () {
      final result = parse([
        {'id': 'a', 'type': 'note', 'text': 'ok'},
        {'id': 'b', 'type': 'note'},
        {'id': 'c', 'type': 'future', 'text': 'x'},
        {'id': 'a', 'type': 'note', 'text': 'duplicate'},
        {'id': 'Bad Id', 'type': 'note', 'text': 'x'},
        'nope',
        {'id': 'd', 'type': 'note', 'text': 'ok'},
      ]);
      expect(result.cards.map((c) => c.id), ['a', 'd']);
      expect(result.warnings, hasLength(5));
    });

    test('limits cards to eight', () {
      final result = parse([
        for (var i = 0; i < 10; i++) {'id': 'n$i', 'type': 'note', 'text': 't'},
      ]);
      expect(result.cards, hasLength(8));
      expect(result.warnings, hasLength(1));
    });

    test('wrong top-level type yields nothing', () {
      final result = parse({'id': 'a'});
      expect(result.cards, isEmpty);
      expect(result.warnings, isNotEmpty);
    });

    test('rejects bad actions', () {
      Object? note(Map<String, Object?> extra) => {
        'id': 'n',
        'type': 'note',
        'text': 't',
        ...extra,
      };
      for (final extra in [
        {'url': 'https://a.example', 'copy': 'x'},
        {'url': 'javascript:alert(1)'},
        {'url': 5},
        {'copy': 'x' * 257},
        {'share': 'x' * 1025},
        {'app': 'format'},
      ]) {
        expect(parse([note(extra)]).cards, isEmpty, reason: '$extra');
      }
      expect(
        parse([
          note({'app': 'doctor'}),
        ]).cards,
        hasLength(1),
      );
    });

    test('actions card needs two to six items', () {
      final item = {'icon': 'a', 'label': 'L', 'app': 'doctor'};
      expect(
        parse([
          {
            'id': 'x',
            'type': 'actions',
            'items': [item],
          },
        ]).cards,
        isEmpty,
      );
      expect(
        parse([
          {'id': 'x', 'type': 'actions', 'items': List.filled(7, item)},
        ]).cards,
        isEmpty,
      );
    });

    test('images must be https', () {
      for (final image in [
        'http://a.example/i.png',
        'data:image/png;base64,AA',
        3,
      ]) {
        expect(
          parse([
            {'id': 'b', 'type': 'banner', 'image': image},
          ]).cards,
          isEmpty,
          reason: '$image',
        );
      }
    });

    test('hints without the file have no cards or labels', () {
      const hints = ProviderHints(SubscriptionMetadata());
      expect(hints.cards, isEmpty);
      expect(hints.powerLabels, isEmpty);
    });

    test('an out-of-range moment skips the card instead of throwing', () {
      const huge = 9999999999999;
      expect(
        parse([
          {
            'id': 'a',
            'type': 'note',
            'text': 't',
            'when': {'from': huge},
          },
          {
            'id': 'b',
            'type': 'note',
            'text': 't',
            'when': {'until': -1},
          },
          {'id': 'c', 'type': 'banner', 'title': 't', 'countdown': huge},
        ]).cards,
        isEmpty,
      );
    });

    test('a key the card type does not have warns and keeps the card', () {
      final result = parse([
        {
          'id': 'a',
          'type': 'note',
          'text': 't',
          'title': 'x',
          'when': {'days-left': 1},
        },
        {
          'id': 'b',
          'type': 'banner',
          'title': 't',
          'imageDark': 'https://a.example/d.png',
          'button': {'label': 'Go', 'copy': 'x', 'icon': 'copy'},
        },
        {
          'id': 'c',
          'type': 'actions',
          'items': [
            {'icon': 'copy', 'label': 'A', 'copy': 'a', 'tone': 'primary'},
            {'icon': 'copy', 'label': 'B', 'copy': 'b'},
          ],
        },
      ]);
      expect(result.cards.map((card) => card.id), ['a', 'b', 'c']);
      expect(result.warnings, [
        'Unknown key days-left in card a',
        'Unknown key title in card a',
        'Unknown key imageDark in card b',
        'Unknown key icon in card b',
        'Unknown key tone in card c',
      ]);
    });
  });

  group('conditions', () {
    final now = DateTime.fromMillisecondsSinceEpoch(1000000 * 1000);
    int sec(Duration d) => now.add(d).millisecondsSinceEpoch ~/ 1000;
    ProviderConditionSnapshot snap({
      int expire = 0,
      int total = 0,
      int used = 0,
      bool stale = false,
      String platform = 'linux',
      String version = '1.2.0',
    }) => ProviderConditionSnapshot(
      now: now,
      expire: expire,
      total: total,
      used: used,
      usageStale: stale,
      platform: platform,
      appVersion: version,
    );
    ProviderWhen when(Map<String, Object?> json) => ProviderWhen.parse(json)!;

    test('from and until', () {
      final w = when({
        'from': sec(const Duration(seconds: -5)),
        'until': sec(const Duration(seconds: 5)),
      });
      expect(w.holds(snap()), isTrue);
      expect(
        when({'from': sec(const Duration(seconds: 5))}).holds(snap()),
        isFalse,
      );
      expect(when({'until': sec(Duration.zero)}).holds(snap()), isFalse);
    });

    test('daysLeftBelow', () {
      final w = when({'days-left-below': 3});
      expect(
        w.holds(snap(expire: sec(const Duration(days: 2, hours: 1)))),
        isTrue,
      );
      expect(w.holds(snap(expire: sec(const Duration(days: 5)))), isFalse);
      expect(w.holds(snap()), isFalse);
      expect(
        w.holds(snap(expire: sec(const Duration(days: 2)), stale: true)),
        isFalse,
      );
    });

    test('trafficAbove', () {
      final w = when({'traffic-above': 80});
      expect(w.holds(snap(total: 100, used: 80)), isTrue);
      expect(w.holds(snap(total: 100, used: 79)), isFalse);
      expect(w.holds(snap(used: 80)), isFalse);
      expect(w.holds(snap(total: 100, used: 90, stale: true)), isFalse);
    });

    test('platforms and clientBelow', () {
      expect(
        when({
          'platforms': ['linux'],
        }).holds(snap()),
        isTrue,
      );
      expect(
        when({
          'platforms': ['android'],
        }).holds(snap()),
        isFalse,
      );
      expect(when({'client-below': '1.3.0'}).holds(snap()), isTrue);
      expect(when({'client-below': '1.2.0'}).holds(snap()), isFalse);
    });

    test('invalid clauses are rejected', () {
      expect(ProviderWhen.parse({'from': 'x'}), isNull);
      expect(
        ProviderWhen.parse({
          'platforms': ['beos'],
        }),
        isNull,
      );
      expect(ProviderWhen.parse({'client-below': 'zz'}), isNull);
      expect(ProviderWhen.parse([]), isNull);
    });

    test('nearest future boundary', () {
      expect(
        nearestFutureBoundary(now, [sec(const Duration(seconds: -1))]),
        isNull,
      );
      expect(
        nearestFutureBoundary(now, [
          sec(const Duration(seconds: 90)),
          sec(const Duration(seconds: 30)),
        ]),
        now.add(const Duration(seconds: 30)),
      );
    });
  });

  group('power labels', () {
    test('parses strings, objects and arrays', () {
      final labels = parseProviderPowerLabels({
        'off': 'Tap',
        'connecting': {'title': 'Wait', 'hint': 'Soon'},
        'on': [
          'A',
          {'title': 'B'},
          5,
          'x' * 65,
        ],
        'paused': {'title': 'P', 'hint': 'h' * 97},
        'other': 'ignored',
      });
      expect(labels['off'], [const ProviderPowerLabel('Tap')]);
      expect(labels['connecting'], [const ProviderPowerLabel('Wait', 'Soon')]);
      expect(labels['on'], hasLength(2));
      expect(labels.containsKey('paused'), isFalse);
      expect(labels.containsKey('other'), isFalse);
      expect(parseProviderPowerLabels([]), isEmpty);
    });

    test('placeholders fill or fall back', () {
      expect(
        fillProviderPlaceholders('{daysLeft} days', {'daysLeft': '5'}),
        '5 days',
      );
      expect(fillProviderPlaceholders('{server}', {'server': null}), isNull);
      expect(
        resolveProviderPowerLabel(
          const ProviderPowerLabel('T', '{trafficLeft}'),
          {'trafficLeft': null},
        ),
        isNull,
      );
      expect(
        resolveProviderPowerLabel(const ProviderPowerLabel('T'), {}),
        const ProviderPowerLabel('T'),
      );
    });
  });

  test('pool selection holds until the labels change', () {
    final random = _CountingRandom();
    ProviderHints withLabels(Object json) => ProviderHints(
      const SubscriptionMetadata(),
      config: ProviderConfig(
        cards: const [],
        powerLabels: parseProviderPowerLabels(json),
      ),
    );
    var hints = withLabels({
      'on': ['A', 'B'],
      'off': 'Tap',
    });
    final container = ProviderContainer(
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => 1),
        providerHintsProvider.overrideWith((ref) => hints),
        providerPowerLabelProvider.overrideWith(
          () => ProviderPowerLabelSelection(random: random),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(providerPowerLabelProvider, (_, _) {});
    final first = container.read(providerPowerLabelProvider);
    expect(first['on'], const ProviderPowerLabel('A'));
    expect(first['off'], const ProviderPowerLabel('Tap'));
    expect(random.draws, 1);
    for (var i = 0; i < 3; i++) {
      container.invalidate(providerHintsProvider);
      expect(container.read(providerPowerLabelProvider)['on'], first['on']);
    }
    expect(random.draws, 1);
    hints = withLabels({
      'on': ['C', 'D'],
    });
    container.invalidate(providerHintsProvider);
    expect(
      container.read(providerPowerLabelProvider)['on'],
      const ProviderPowerLabel('D'),
    );
  });
}
