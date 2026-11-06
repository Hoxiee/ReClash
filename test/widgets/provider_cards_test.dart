import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:reclash/providers/provider_settings.dart';
import 'package:reclash/state.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_cards.dart';
import 'package:reclash/subscriptions/metadata/provider_config.dart';
import 'package:reclash/ui/card.dart';
import 'package:reclash/ui/icons/app_glyphs.dart';
import 'package:reclash/ui/icons/glyph_icon.dart';
import 'package:reclash/views/dashboard/simple/widget_list.dart';
import 'package:reclash/widgets/icon.dart';
import 'package:reclash/widgets/provider_cards.dart';

import '../helpers/preferences.dart';
import '../helpers/test_app.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==',
);

ProviderCard _card(Map<String, Object?> json) =>
    parseProviderCards([json]).cards.single;

ProviderContainer _fromCards(List<Map<String, Object?>> json) =>
    ProviderContainer(
      overrides: [
        providerCardsProvider.overrideWithValue(parseProviderCards(json).cards),
      ],
    );

ProviderContainer _fromFile(
  List<Map<String, Object?>> json, {
  DateTime Function()? now,
}) => ProviderContainer(
  overrides: [
    providerHintsProvider.overrideWithValue(
      ProviderHints(
        const SubscriptionMetadata(),
        config: ProviderConfig(
          cards: parseProviderCards(json).cards,
          powerLabels: const {},
        ),
      ),
    ),
    providerCardsEnvironmentProvider.overrideWithValue((
      now: now ?? DateTime.now,
      platform: 'linux',
      appVersion: '1.0.0',
    )),
  ],
);

Future<void> _pump(
  WidgetTester tester,
  ProviderContainer container, {
  bool dark = false,
  double width = 360,
  Widget child = const ProviderCards(),
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  globalState.container = container;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Finder _noteCard(String text) =>
    find.ancestor(of: find.text(text), matching: find.byType(CommonCard));

double _gapBetween(WidgetTester tester, String upper, String lower) =>
    tester.getRect(_noteCard(lower)).top -
    tester.getRect(_noteCard(upper)).bottom;

List<String?> _painterNames(WidgetTester tester, String text) => [
  for (final paint in tester.widgetList<CustomPaint>(
    find.ancestor(of: find.text(text), matching: find.byType(CustomPaint)),
  ))
    paint.painter?.runtimeType.toString(),
];

void main() {
  setUp(() async {
    await mockPreferences();
    providerImageReader = (_) async => Uint8List.fromList(_png);
  });
  tearDown(() => providerImageReader = null);

  for (final dark in [false, true]) {
    for (final layout in ['hero', 'split', 'strip', 'image']) {
      testWidgets('$layout banner fits 360 dp (dark: $dark)', (tester) async {
        final container = _fromCards([
          {
            'id': 'b',
            'type': 'banner',
            'layout': layout,
            'title': 'Sale title',
            'text': 'A fairly long line of banner text that must wrap nicely',
            'image': 'https://cdn.example.net/a.png',
            'image-dark': 'https://cdn.example.net/b.png',
            'button': {'label': 'Copy code', 'copy': 'SALE'},
          },
        ]);
        addTearDown(container.dispose);
        await _pump(tester, container, dark: dark);
        expect(tester.takeException(), isNull);
        expect(find.byType(ProviderCards), findsOneWidget);
        if (layout != 'image') expect(find.text('Sale title'), findsOneWidget);
        final width = tester.getSize(find.byType(ProviderCards)).width;
        expect(width, lessThanOrEqualTo(360));
      });

      testWidgets('$layout banner with a failed image (dark: $dark)', (
        tester,
      ) async {
        providerImageReader = (_) async =>
            Uint8List.fromList(utf8.encode('<svg/>'));
        final container = _fromCards([
          {
            'id': 'b',
            'type': 'banner',
            'layout': layout,
            'title': 'Sale title',
            'image': 'https://cdn.example.net/a.svg',
          },
        ]);
        addTearDown(container.dispose);
        await _pump(tester, container, dark: dark);
        expect(tester.takeException(), isNull);
        expect(
          find.text('Sale title'),
          layout == 'image' ? findsNothing : findsOneWidget,
        );
        if (layout == 'image') {
          expect(find.byType(CommonCard), findsNothing);
        }
      });
    }
  }

  for (final width in [320.0, 360.0]) {
    testWidgets('a long hero title keeps its button visible at $width', (
      tester,
    ) async {
      final container = _fromCards([
        {
          'id': 'b',
          'type': 'banner',
          'layout': 'hero',
          'title': 'A very long promotional title that would need three lines',
          'text': 'Offer text under the title',
          'image': 'https://cdn.example.net/a.png',
          'button': {'label': 'Copy code', 'copy': 'SALE'},
        },
      ]);
      addTearDown(container.dispose);
      await _pump(tester, container, width: width);
      expect(tester.takeException(), isNull);
      final card = tester.getRect(find.byType(ProviderCards));
      final button = tester.getRect(find.text('Copy code'));
      expect(button.bottom, lessThanOrEqualTo(card.bottom));
      expect(card.height, greaterThanOrEqualTo(card.width * 9 / 16));
    });
  }

  testWidgets('a hero is capped at 320 dp on a wide screen', (tester) async {
    final container = _fromCards([
      {
        'id': 'b',
        'type': 'banner',
        'layout': 'hero',
        'title': 'Short',
        'image': 'https://cdn.example.net/a.png',
      },
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container, width: 1200);
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ProviderCards)).height, 320);
  });

  testWidgets('a split with a failed image starts its text at the edge', (
    tester,
  ) async {
    providerImageReader = (_) async =>
        Uint8List.fromList(utf8.encode('<svg/>'));
    final container = _fromCards([
      {
        'id': 'b',
        'type': 'banner',
        'layout': 'split',
        'title': 'Hi',
        'image': 'https://cdn.example.net/a.svg',
      },
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container);
    final card = tester.getRect(find.byType(ProviderCards));
    expect(tester.getTopLeft(find.text('Hi')).dx, card.left + 16);
  });

  for (final side in ['start', 'end']) {
    testWidgets('a split fills a 1200 dp card with its image flush ($side)', (
      tester,
    ) async {
      final container = _fromCards([
        {
          'id': 'b',
          'type': 'banner',
          'layout': 'split',
          'side': side,
          'title': 'Hi',
          'image': 'https://cdn.example.net/a.png',
        },
      ]);
      addTearDown(container.dispose);
      await _pump(tester, container, width: 1200);
      expect(tester.takeException(), isNull);
      final card = tester.getRect(find.byType(ProviderCards));
      expect(card.width, 1200 - 24);
      final image = tester.getRect(find.byType(Image));
      expect(image.width, 120);
      expect(image.height, card.height);
      expect(
        side == 'start' ? image.left : image.right,
        side == 'start' ? card.left : card.right,
      );
    });
  }

  testWidgets('an oversize image counts as a failed load', (tester) async {
    providerImageReader = (_) async =>
        Uint8List(providerImageLimit + 1)..setAll(0, _png);
    final container = _fromCards([
      {
        'id': 'b',
        'type': 'banner',
        'layout': 'image',
        'image': 'https://cdn.example.net/a.png',
      },
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container);
    expect(find.byType(CommonCard), findsNothing);
  });

  testWidgets('note levels use their glyph colours and fill', (tester) async {
    final container = _fromCards([
      for (final level in ['info', 'warning', 'critical'])
        {'id': level, 'type': 'note', 'level': level, 'text': 'Note $level'},
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container);
    final cards = tester
        .widgetList<CommonCard>(find.byType(CommonCard))
        .toList();
    expect(cards.map((card) => card.isError), [false, false, true]);
    expect(find.byTooltip('Close'), findsNothing);
  });

  testWidgets('an app action without its link is hidden', (tester) async {
    final container = _fromCards([
      {
        'id': 'a',
        'type': 'actions',
        'items': [
          {'icon': 'support', 'label': 'Chat', 'app': 'support'},
          {'icon': 'speed', 'label': 'Speed', 'app': 'speedTest'},
          {'icon': 'doctor', 'label': 'Doctor', 'app': 'doctor'},
        ],
      },
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container);
    expect(find.text('Chat'), findsNothing);
    expect(find.text('Speed'), findsOneWidget);
    expect(find.text('Doctor'), findsOneWidget);
  });

  testWidgets('only a dismissible card is dismissed, and by content', (
    tester,
  ) async {
    final json = [
      {'id': 'fixed', 'type': 'note', 'text': 'Stays'},
      {'id': 'gone', 'type': 'note', 'text': 'First', 'dismissible': true},
    ];
    final container = _fromFile(json);
    addTearDown(container.dispose);
    await _pump(tester, container);
    expect(find.byTooltip('Close'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    expect(find.text('Stays'), findsOneWidget);
    expect(find.text('First'), findsNothing);
    final id = providerCardDismissId(_card(json.last));
    expect(container.read(dismissedNoticesProvider), contains(id));

    final changed = [
      json.first,
      {...json.last, 'text': 'Second'},
    ];
    final next = _fromFile(changed);
    addTearDown(next.dispose);
    next.read(dismissedNoticesProvider.notifier).state = {id};
    await _pump(tester, next);
    expect(find.text('Second'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('a condition boundary flips visibility through one timer', (
    tester,
  ) async {
    var now = DateTime.fromMillisecondsSinceEpoch(1000 * 1000);
    final container = _fromFile([
      {
        'id': 'later',
        'type': 'note',
        'text': 'Opens soon',
        'when': {'from': 1010},
      },
    ], now: () => now);
    addTearDown(container.dispose);
    await _pump(tester, container);
    expect(find.text('Opens soon'), findsNothing);
    now = DateTime.fromMillisecondsSinceEpoch(1011 * 1000);
    await tester.pump(const Duration(seconds: 11));
    await tester.pump();
    expect(find.text('Opens soon'), findsOneWidget);
  });

  testWidgets('a hero without an image is a compact text card at 1200 dp', (
    tester,
  ) async {
    final container = _fromCards([
      {'id': 'b', 'type': 'banner', 'layout': 'hero', 'title': 'Short'},
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container, width: 1200);
    expect(tester.takeException(), isNull);
    expect(find.text('Short'), findsOneWidget);
    expect(tester.getSize(find.byType(ProviderCards)).height, lessThan(160));
  });

  testWidgets('an image banner without an image renders nothing', (
    tester,
  ) async {
    final container = _fromCards([
      {'id': 'b', 'type': 'banner', 'layout': 'image', 'title': 'Hidden'},
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container);
    expect(tester.takeException(), isNull);
    expect(find.text('Hidden'), findsNothing);
    expect(find.byType(CommonCard), findsNothing);
  });

  testWidgets('a split without an image starts its text at the edge', (
    tester,
  ) async {
    final container = _fromCards([
      {'id': 'b', 'type': 'banner', 'layout': 'split', 'title': 'Hi'},
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container);
    final card = tester.getRect(find.byType(ProviderCards));
    expect(tester.getTopLeft(find.text('Hi')).dx, card.left + 16);
  });

  testWidgets('an image banner with a working image is at most 320 dp tall', (
    tester,
  ) async {
    final container = _fromCards([
      {
        'id': 'b',
        'type': 'banner',
        'layout': 'image',
        'image': 'https://cdn.example.net/a.png',
      },
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container, width: 1200);
    expect(tester.takeException(), isNull);
    expect(find.byType(CommonCard), findsOneWidget);
    expect(
      tester.getSize(find.byType(ProviderCards)).height,
      lessThanOrEqualTo(320),
    );
  });

  final dismissibleSurfaces = <Map<String, Object?>>[
    {'id': 'note', 'type': 'note', 'text': 'Closable', 'dismissible': true},
    {
      'id': 'actions',
      'type': 'actions',
      'dismissible': true,
      'items': [
        {'icon': 'copy', 'label': 'One', 'copy': 'one'},
        {'icon': 'copy', 'label': 'Two', 'copy': 'two'},
      ],
    },
  ];
  for (final dark in [false, true]) {
    for (final json in dismissibleSurfaces) {
      testWidgets('a dismissible ${json['type']} closes with a variant glyph '
          '(dark: $dark)', (tester) async {
        final container = _fromCards([json]);
        addTearDown(container.dispose);
        await _pump(tester, container, dark: dark);
        final close = tester.widget<GlyphIcon>(
          find.descendant(
            of: find.byType(IconButton),
            matching: find.byType(GlyphIcon),
          ),
        );
        final scheme = Theme.of(
          tester.element(find.byType(ProviderCards)),
        ).colorScheme;
        expect(close.color, scheme.onSurfaceVariant);
      });
    }
  }

  for (final dark in [false, true]) {
    testWidgets('a dismissible banner closes with an on-container glyph '
        '(dark: $dark)', (tester) async {
      final container = _fromCards([
        {
          'id': 'b',
          'type': 'banner',
          'layout': 'hero',
          'title': 'Promo',
          'image': 'https://cdn.example.net/a.png',
          'dismissible': true,
        },
      ]);
      addTearDown(container.dispose);
      await _pump(tester, container, dark: dark);
      final close = tester.widget<GlyphIcon>(
        find.descendant(
          of: find.byType(IconButton),
          matching: find.byType(GlyphIcon),
        ),
      );
      final scheme = Theme.of(
        tester.element(find.byType(ProviderCards)),
      ).colorScheme;
      expect(close.color, scheme.onSecondaryContainer);
    });
  }

  for (final side in ['start', 'end']) {
    testWidgets('a dismissible split puts its close button over the image '
        '($side)', (tester) async {
      final container = _fromCards([
        {
          'id': 'b',
          'type': 'banner',
          'layout': 'split',
          'side': side,
          'title': 'Hi',
          'image': 'https://cdn.example.net/a.png',
          'dismissible': true,
        },
      ]);
      addTearDown(container.dispose);
      await _pump(tester, container);
      expect(tester.takeException(), isNull);
      final close = tester.getCenter(find.byType(IconButton));
      final text = tester.getRect(find.text('Hi'));
      if (side == 'start') {
        expect(close.dx, lessThan(text.left));
      } else {
        expect(close.dx, greaterThan(text.right));
      }
    });
  }

  testWidgets('plain, action and dismissible notes share one height', (
    tester,
  ) async {
    final container = _fromCards([
      {'id': 'plain', 'type': 'note', 'text': 'Plain'},
      {'id': 'copy', 'type': 'note', 'text': 'Copy', 'copy': 'CODE'},
      {'id': 'close', 'type': 'note', 'text': 'Close me', 'dismissible': true},
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container);
    expect(tester.takeException(), isNull);
    final heights = [
      for (final text in ['Plain', 'Copy', 'Close me'])
        tester
            .getSize(
              find.ancestor(
                of: find.text(text),
                matching: find.byType(CommonCard),
              ),
            )
            .height,
    ];
    expect(heights, everyElement(heights.first));
  });

  final actionsPerRow = {2: 2, 3: 3, 4: 2};
  for (final entry in actionsPerRow.entries) {
    testWidgets('an actions card of ${entry.key} items fills ${entry.value} '
        'per row at 900 dp', (tester) async {
      final labels = ['One', 'Two', 'Three', 'Four'].take(entry.key).toList();
      final container = _fromCards([
        {
          'id': 'a',
          'type': 'actions',
          'items': [
            for (final label in labels)
              {'icon': 'copy', 'label': label, 'copy': label},
          ],
        },
      ]);
      addTearDown(container.dispose);
      await _pump(tester, container, width: 900);
      expect(tester.takeException(), isNull);
      final buttons = [
        for (final label in labels)
          tester.getRect(
            find
                .ancestor(
                  of: find.text(label),
                  matching: find.byWidgetPredicate((w) => w is FilledButton),
                )
                .first,
          ),
      ];
      final rowTop = buttons.first.top;
      expect(buttons.where((b) => b.top == rowTop), hasLength(entry.value));
      if (labels.length == 4) expect(buttons[2].left, buttons[0].left);
    });
  }

  testWidgets('a failed image banner between notes leaves only one gap', (
    tester,
  ) async {
    providerImageReader = (_) async => null;
    final container = _fromCards([
      {'id': 'first', 'type': 'note', 'text': 'Before'},
      {
        'id': 'b',
        'type': 'banner',
        'layout': 'image',
        'image': 'https://cdn.example.net/a.png',
      },
      {'id': 'last', 'type': 'note', 'text': 'After'},
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(CommonCard), findsNWidgets(2));
    expect(_gapBetween(tester, 'Before', 'After'), 12);
  });

  testWidgets(
    'a failed image banner first starts the column at the first note',
    (tester) async {
      providerImageReader = (_) async => null;
      final container = _fromCards([
        {
          'id': 'b',
          'type': 'banner',
          'layout': 'image',
          'image': 'https://cdn.example.net/a.png',
        },
        {'id': 'first', 'type': 'note', 'text': 'Before'},
        {'id': 'last', 'type': 'note', 'text': 'After'},
      ]);
      addTearDown(container.dispose);
      await _pump(tester, container);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getTopLeft(_noteCard('Before')).dy,
        tester.getTopLeft(find.byType(ProviderCards)).dy,
      );
      expect(_gapBetween(tester, 'Before', 'After'), 12);
    },
  );

  testWidgets(
    'an actions card with no linked items between notes leaves one gap',
    (tester) async {
      final container = _fromCards([
        {'id': 'first', 'type': 'note', 'text': 'Before'},
        {
          'id': 'a',
          'type': 'actions',
          'items': [
            {'icon': 'refresh', 'label': 'Renew', 'app': 'renew'},
            {'icon': 'gift', 'label': 'Top up', 'app': 'topUp'},
          ],
        },
        {'id': 'last', 'type': 'note', 'text': 'After'},
      ]);
      addTearDown(container.dispose);
      await _pump(tester, container);
      expect(tester.takeException(), isNull);
      expect(find.byType(CommonCard), findsNWidgets(2));
      expect(_gapBetween(tester, 'Before', 'After'), 12);
    },
  );

  testWidgets('an expired countdown banner between notes leaves one gap', (
    tester,
  ) async {
    final container = _fromCards([
      {'id': 'first', 'type': 'note', 'text': 'Before'},
      {
        'id': 'b',
        'type': 'banner',
        'layout': 'hero',
        'title': 'Ended',
        'countdown': 1000,
      },
      {'id': 'last', 'type': 'note', 'text': 'After'},
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container);
    expect(tester.takeException(), isNull);
    expect(find.text('Ended'), findsNothing);
    expect(_gapBetween(tester, 'Before', 'After'), 12);
  });

  testWidgets(
    'a hero with long text grows past 16:9 and keeps its title off the fade',
    (tester) async {
      const title =
          'A very long promotional title that wraps onto a second line';
      final container = _fromCards([
        {
          'id': 'b',
          'type': 'banner',
          'layout': 'hero',
          'title': title,
          'text': 'Long offer detail. ' * 12,
          'image': 'https://cdn.example.net/a.png',
        },
      ]);
      addTearDown(container.dispose);
      await _pump(tester, container, width: 390);
      expect(tester.takeException(), isNull);
      final card = tester.getRect(find.byType(ProviderCards));
      expect(card.height, greaterThan(card.width * 9 / 16));
      expect(
        tester.getTopLeft(find.text(title)).dy - card.top,
        greaterThanOrEqualTo(64),
      );
    },
  );

  testWidgets('a hero with short text keeps 16:9 and its title off the fade', (
    tester,
  ) async {
    final container = _fromCards([
      {
        'id': 'b',
        'type': 'banner',
        'layout': 'hero',
        'title': 'Short',
        'text': 'Offer',
        'image': 'https://cdn.example.net/a.png',
      },
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container, width: 390);
    expect(tester.takeException(), isNull);
    final card = tester.getRect(find.byType(ProviderCards));
    expect(card.height, closeTo(card.width * 9 / 16, 0.5));
    expect(
      tester.getTopLeft(find.text('Short')).dy - card.top,
      greaterThanOrEqualTo(64),
    );
  });

  testWidgets('a hero paints its text scrim once the image is ready', (
    tester,
  ) async {
    final container = _fromCards([
      {
        'id': 'b',
        'type': 'banner',
        'layout': 'hero',
        'title': 'Scrim',
        'image': 'https://cdn.example.net/a.png',
      },
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container);
    expect(_painterNames(tester, 'Scrim'), contains('_TextScrimPainter'));
  });

  testWidgets('a hero paints no text scrim while its image loads', (
    tester,
  ) async {
    providerImageReader = (_) => Completer<Uint8List?>().future;
    final container = _fromCards([
      {
        'id': 'b',
        'type': 'banner',
        'layout': 'hero',
        'title': 'Loading',
        'image': 'https://cdn.example.net/a.png',
      },
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container);
    final painters = _painterNames(tester, 'Loading');
    expect(painters, contains(null));
    expect(painters, isNot(contains('_TextScrimPainter')));
  });

  testWidgets('a hero without an image paints no text scrim', (tester) async {
    final container = _fromCards([
      {'id': 'b', 'type': 'banner', 'layout': 'hero', 'title': 'Bare'},
    ]);
    addTearDown(container.dispose);
    await _pump(tester, container);
    expect(_painterNames(tester, 'Bare'), isNot(contains('_TextScrimPainter')));
  });

  for (final level in ['critical', 'info']) {
    testWidgets(
      'a tappable $level note draws its chevron in its level colour',
      (tester) async {
        final container = _fromCards([
          {
            'id': 'n',
            'type': 'note',
            'level': level,
            'text': 'Tap me',
            'copy': 'CODE',
          },
        ]);
        addTearDown(container.dispose);
        await _pump(tester, container);
        final chevron = tester.widget<GlyphIcon>(
          find.byWidgetPredicate(
            (w) => w is GlyphIcon && w.glyph == AppGlyphs.chevronForward,
          ),
        );
        final scheme = Theme.of(
          tester.element(find.byType(ProviderCards)),
        ).colorScheme;
        expect(
          chevron.color,
          level == 'critical'
              ? scheme.onErrorContainer
              : scheme.onSurfaceVariant,
        );
      },
    );
  }

  testWidgets('the widget editor lists no provider card', (tester) async {
    final container = _fromCards([
      {'id': 'n', 'type': 'note', 'text': 'Provider note'},
    ]);
    addTearDown(container.dispose);
    await _pump(
      tester,
      container,
      child: SizedBox(
        height: 600,
        child: SimpleWidgetList(
          editing: true,
          onDone: () {},
          padding: EdgeInsets.zero,
        ),
      ),
    );
    expect(find.byType(ProviderCards), findsNothing);
    expect(find.text('Provider note'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
