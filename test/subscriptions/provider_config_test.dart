import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/subscriptions/metadata/hints.dart';
import 'package:reclash/subscriptions/metadata/metadata.dart';
import 'package:reclash/subscriptions/metadata/provider_cards.dart';
import 'package:reclash/subscriptions/metadata/provider_config.dart';
import 'package:reclash/subscriptions/provider_settings.dart';
import 'package:yaml/yaml.dart';

void main() {
  ProviderConfigResult parse(String source, [String locale = 'en']) =>
      parseProviderConfig(source, locale);

  String doc(String body) => 'version: 1\n$body';

  test('parses a complete document', () {
    final result = parse('''
version: 1
view: {proxies: {type: list}}
power-button: {type: outline}
wallpaper: {url: 'https://a.example/w.png'}
widgets: [health, serviceStatus]
cards:
  - id: promo
    type: banner
    title: {ru: Привет, en: Hello}
    text: Body
    image-dark: https://a.example/d.png
    button: {label: Go, url: 'https://a.example'}
  - id: note1
    type: note
    text: Careful
    level: info
    when: {days-left-below: 3}
  - id: acts
    type: actions
    items:
      - {icon: support, label: Help, url: 'https://a.example/h'}
      - {icon: copy, label: Copy, copy: abc}
power-labels:
  off: Disconnected
  on:
    - {title: Connected, hint: {ru: Привет, en: Safe}}
    - {ru: Подключено, en: Online}
''', 'ru-RU');
    final config = result.config!;
    expect(result.warnings, isEmpty);
    expect(config.cards.map((c) => c.id), ['promo', 'note1', 'acts']);
    expect((config.cards[0] as ProviderBanner).title, 'Привет');
    expect((config.cards[0] as ProviderBanner).imageDark, isNotNull);
    expect((config.cards[1] as ProviderNote).when.daysLeftBelow, 3);
    expect((config.cards[2] as ProviderActions).items, hasLength(2));
    expect(config.powerLabels['off']!.single.title, 'Disconnected');
    expect(config.powerLabels['on']![0].hint, 'Привет');
    expect(config.powerLabels['on']![1].title, 'Подключено');
    expect(config.widgets, ['health', 'servicestatus']);
  });

  group('size and syntax', () {
    test('rejects over 256 KiB measured in UTF-8 bytes', () {
      final ascii = doc('# ${'a' * (256 * 1024)}\n');
      expect(parse(ascii).config, isNull);
      final multibyte = doc('# ${'я' * (128 * 1024)}\n');
      expect(multibyte.length, lessThan(256 * 1024));
      expect(parse(multibyte).config, isNull);
      expect(parse(doc('# ${'a' * 1000}\n')).config, isNotNull);
    });

    test('never throws on malformed or hostile input', () {
      for (final source in [
        '',
        ':',
        '{{{{',
        '[1, 2',
        '\u0000',
        'a: "unterminated',
        '- 1\n- 2',
        'just text',
        '? [a]\n: b',
        '1: a',
        'version: 1\nversion: 1',
        '!!binary x',
        '${'[' * 5000}${']' * 5000}',
      ]) {
        expect(() => parse(source), returnsNormally, reason: source);
        expect(parse(source).config, isNull, reason: source);
      }
    });
  });

  group('version', () {
    test('is required and must be the integer 1', () {
      expect(parse('cards: []').config, isNull);
      for (final v in ['2', '0', '1.0', '"1"', 'true', 'null', '[1]']) {
        expect(parse('version: $v').config, isNull, reason: v);
      }
      expect(parse('version: 1').config, isNotNull);
    });
  });

  group('anchors and aliases', () {
    test('package:yaml gives an alias the same node instance', () {
      final node = loadYamlNode('a: &x [1]\nb: *x') as YamlMap;
      expect(identical(node.nodes['a'], node.nodes['b']), isTrue);
      final scalar = loadYamlNode('a: &x hi\nb: *x') as YamlMap;
      expect(identical(scalar.nodes['a'], scalar.nodes['b']), isTrue);
    });

    test('rejects a collection or scalar alias', () {
      expect(parse(doc('a: &x [1]\nb: *x')).config, isNull);
      expect(parse(doc('a: &x hi\nb: *x')).config, isNull);
      expect(parse(doc('a: &x hi\n*x : 1')).config, isNull);
    });

    test('an anchor that is never aliased is accepted', () {
      expect(parse(doc('widgets: &x [1]')).config, isNotNull);
    });

    test('rejects a billion laughs document quickly', () {
      final lines = <String>['a: &a0 [x, x, x, x, x, x, x, x, x]'];
      for (var i = 1; i < 10; i++) {
        final prev = 'a${i - 1}';
        lines.add('b$i: &a$i [${List.filled(9, '*$prev').join(', ')}]');
      }
      final watch = Stopwatch()..start();
      final result = parse(doc(lines.join('\n')));
      expect(result.config, isNull);
      expect(watch.elapsedMilliseconds, lessThan(2000));
    });

    test('equal but separate values are not aliases', () {
      expect(parse(doc('widgets: [a, a, [1], [1]]')).config, isNotNull);
    });
  });

  test('caps nesting depth at 32', () {
    String nested(int n) => '${'[' * n}1${']' * n}';
    expect(parse(doc('widgets: ${nested(20)}')).config, isNotNull);
    expect(parse(doc('widgets: ${nested(40)}')).config, isNull);
  });

  group('strict types', () {
    test('plain no stays a string in package:yaml', () {
      expect((loadYaml('a: no') as YamlMap)['a'], 'no');
      expect((loadYaml('a: yes') as YamlMap)['a'], 'yes');
      final result = parse(
        doc('''
cards:
  - {id: n, type: note, text: no}
'''),
      );
      expect((result.config!.cards.single as ProviderNote).text, 'no');
    });

    test('a number is not converted to text', () {
      final result = parse(
        doc('''
cards:
  - {id: a, type: note, text: 1.10}
  - {id: b, type: banner, title: 1.10}
  - {id: c, type: note, text: ok}
'''),
      );
      expect(result.config!.cards.map((c) => c.id), ['c']);
      expect(result.warnings, hasLength(2));
    });

    test('non-string keys reject the document', () {
      expect(parse(doc('widgets: {1: a}')).config, isNull);
    });
  });

  group('keys', () {
    test('an unknown top-level key warns and does not reject', () {
      final result = parse(doc('extra: 1'));
      expect(result.config, isNotNull);
      expect(result.warnings, contains('Unknown key extra'));
    });

    test('a camelCase key is unknown and ignored', () {
      final result = parse(
        doc('''
cards:
  - {id: a, type: note, text: hi, dismissible: true, daysLeftBelow: 1}
  - {id: b, type: banner, title: t, imageDark: 'https://a.example/d.png'}
power-labels: {powerOn: x}
'''),
      );
      final cards = result.config!.cards;
      expect(cards, hasLength(2));
      expect((cards[1] as ProviderBanner).imageDark, isNull);
      expect(result.warnings.where((w) => w.startsWith('Unknown key')), [
        'Unknown key daysLeftBelow in card a',
        'Unknown key imageDark in card b',
        'Unknown key powerOn in power-labels',
      ]);
    });

    test('a camelCase top-level key is unknown', () {
      expect(parse(doc('powerLabels: {}')).warnings, [
        'Unknown key powerLabels',
      ]);
    });

    test('a kebab key nobody defined warns at every depth', () {
      final result = parse(
        doc('''
cards:
  - {id: a, type: note, text: hi, foo-bar: 1, when: {not-a-clause: 1}}
power-labels: {done: x}
'''),
      );
      expect(result.config!.cards, hasLength(1));
      expect(result.warnings, [
        'Unknown key not-a-clause in card a',
        'Unknown key foo-bar in card a',
        'Unknown key done in power-labels',
      ]);
    });

    test('kebab keys read at depth', () {
      final result = parse(
        doc('''
cards:
  - id: a
    type: note
    text: hi
    when: {clientBelow: 1.0.0}
  - id: b
    type: note
    text: hi
    when: {client-below: 99.0.0, platforms: [linux, android]}
'''),
      );
      final cards = result.config!.cards;
      expect(cards[0].when.clientBelow, isNull);
      expect(cards[1].when.clientBelow, '99.0.0');
    });
  });

  group('localized text', () {
    String? title(String locale, String map) =>
        (parse(
                  doc('cards: [{id: a, type: banner, title: $map}]'),
                  locale,
                ).config?.cards.firstOrNull
                as ProviderBanner?)
            ?.title;

    test('resolves exact locale, language, en, then first entry', () {
      const map = '{pt-BR: Brasil, pt: Portugues, en: English, de: Deutsch}';
      expect(title('pt-BR', map), 'Brasil');
      expect(title('pt_br', map), 'Brasil');
      expect(title('pt-PT', map), 'Portugues');
      expect(title('fr', map), 'English');
      expect(title('fr', '{de: Deutsch, es: Espanol}'), 'Deutsch');
    });

    test('an empty or non-string entry invalidates the value', () {
      expect(title('en', '{en: ""}'), isNull);
      expect(title('en', '{en: 1}'), isNull);
      expect(title('en', '{en: Ok, ru: ""}'), isNull);
      expect(title('en', '{}'), isNull);
      expect(title('en', '{en: [a]}'), isNull);
    });

    test('applies to text and label', () {
      final result = parse(
        doc('''
cards:
  - id: n
    type: note
    text: {en: Hi, ru: Привет}
  - id: a
    type: actions
    items:
      - {icon: x, label: {en: One, ru: Один}, copy: c}
      - {icon: y, label: Two, copy: d}
'''),
        'ru',
      );
      final cards = result.config!.cards;
      expect((cards[0] as ProviderNote).text, 'Привет');
      expect((cards[1] as ProviderActions).items.first.label, 'Один');
    });

    test('applies to power label strings and hints', () {
      final result = parse(
        doc('''
power-labels:
  off: {en: Off, ru: Выкл}
  on: {title: {en: On, ru: Вкл}, hint: {en: Safe, ru: Безопасно}}
  paused: {en: ""}
'''),
        'ru',
      );
      final labels = result.config!.powerLabels;
      expect(labels['off']!.single.title, 'Выкл');
      expect(labels['on']!.single.title, 'Вкл');
      expect(labels['on']!.single.hint, 'Безопасно');
      expect(labels.containsKey('paused'), isFalse);
    });
  });

  test('bad cards are skipped and the document stays valid', () {
    final result = parse(
      doc('''
cards:
  - {id: ok, type: note, text: fine}
  - {id: bad, type: nope}
'''),
    );
    expect(result.config!.cards.map((c) => c.id), ['ok']);
    expect(result.warnings, contains('Card bad skipped'));
  });

  group('presentation sections', () {
    ProviderHints hints(String body) => ProviderHints(
      const SubscriptionMetadata(),
      config: parse(doc(body)).config,
    );

    test('view app colors set the light and dark primary', () {
      final result = parseProviderConfig('''
version: 1
view:
  app:
    color: "#336699"
    color-dark: "#88AAFF"
''', 'en');
      expect(result.warnings, isEmpty);
      final view = ProviderHints(
        const SubscriptionMetadata(),
        config: result.config,
      ).view;
      expect(view.primaryColor, 0xFF336699);
      expect(view.primaryColorDark, 0xFF88AAFF);
    });

    test('each valid section reaches its hint', () {
      final result = hints('''
view:
  proxies: {type: List, sort: delay}
  app: {navbar: floating, color: '#3F6FD8', black: true}
power-button: {shape: [Puffy, gem], type: outline}
wallpaper: {url: 'https://cdn.example.net/bg.webp', opacity: 12}
widgets: [CurrentOutbound, serviceStatus]
''');
      expect(result.view.proxiesType, ProxiesType.list);
      expect(result.view.proxiesSort, ProxiesSortType.delay);
      expect(result.view.floatingNavigationBar, isTrue);
      expect(result.view.primaryColor, 0xFF3F6FD8);
      expect(result.view.pureBlack, isTrue);
      expect(result.powerButton.shapes, [
        ProviderPowerShape.puffy,
        ProviderPowerShape.gem,
      ]);
      expect(result.powerButton.type, ProviderPowerType.outline);
      expect(result.background!.url.host, 'cdn.example.net');
      expect(result.background!.opacity, 0.12);
      expect(result.widgets, [
        DashboardWidget.currentOutbound,
        DashboardWidget.serviceStatus,
      ]);
    });

    test('a single shape string and random resolve', () {
      expect(hints('power-button: {shape: gem}').powerButton.shapes, [
        ProviderPowerShape.gem,
      ]);
      expect(
        hints('power-button: {shape: random}').powerButton.shapes,
        ProviderPowerShape.values,
      );
    });

    test('an absent or invalid section leaves its hint empty', () {
      final absent = hints('cards: []');
      expect(absent.view.proxiesType, isNull);
      expect(absent.powerButton, defaultProviderPowerButtonHint);
      expect(absent.background, isNull);
      expect(absent.widgets, isNull);

      const body =
          'view: 1\npower-button: [a]\nwallpaper: {opacity: 5}\n'
          'widgets: [health, 3]';
      expect(parse(doc(body)).warnings, hasLength(4));
      final invalid = hints(body);
      expect(invalid.view.proxiesType, isNull);
      expect(invalid.powerButton, defaultProviderPowerButtonHint);
      expect(invalid.background, isNull);
      expect(invalid.widgets, isNull);
      expect(parse(doc('wallpaper: {url: "http://a.example/x"}')).warnings, [
        'Invalid wallpaper section',
      ]);
    });

    test('unknown keys warn and the rest applies', () {
      const body =
          'view: {proxies: {type: list, bogus: 1}, nope: {a: b}}\n'
          'power-button: {glow: on, type: outline}\n'
          'wallpaper: {url: "https://a.example/x", blur: 3}';
      expect(parse(doc(body)).warnings, hasLength(4));
      final result = hints(body);
      expect(result.view.proxiesType, ProxiesType.list);
      expect(result.powerButton.type, ProviderPowerType.outline);
      expect(result.background, isNotNull);
    });

    test('values are strictly typed', () {
      for (final body in [
        'view: {app: {black: "true"}}',
        'view: {app: {black: 1}}',
        'view: {app: {color: 123456}}',
        'view: {proxies: {type: true}}',
      ]) {
        expect(parse(doc(body)).warnings, hasLength(1), reason: body);
        final view = hints(body).view;
        expect(view.pureBlack, isNull, reason: body);
        expect(view.primaryColor, isNull, reason: body);
        expect(view.proxiesType, isNull, reason: body);
      }
      expect(hints('view: {app: {black: false}}').view.pureBlack, isFalse);
    });

    test('opacity must be an int from 1 to 100 or falls back to 8', () {
      for (final value in ['0', '101', '12.5', '"30"', 'true']) {
        final body = 'wallpaper: {url: "https://a.example/x", opacity: $value}';
        expect(parse(doc(body)).warnings, hasLength(1), reason: value);
        expect(hints(body).background!.opacity, 0.08, reason: value);
      }
      const body = 'wallpaper: {url: "https://a.example/x", opacity: 100}';
      expect(parse(doc(body)).warnings, isEmpty);
      expect(hints(body).background!.opacity, 1);
    });

    test('file values are provider settings with ownership rules', () {
      final base = Config.realFromJson(null);
      ProviderSettingsInput input(String body) =>
          ProviderSettingsInput(hints(body));
      const file = 'view: {proxies: {type: list}, app: {black: true}}';
      final applied = applyProviderSettings(base, input(file));
      expect(applied.proxiesStyleProps.type, ProxiesType.list);
      expect(applied.themeProps.pureBlack, isTrue);
      expect(isProviderManaged(applied, 'proxies.type'), isTrue);

      final changed = applied.copyWith(
        proxiesStyleProps: applied.proxiesStyleProps.copyWith(
          type: ProxiesType.tab,
        ),
      );
      final kept = applyProviderSettings(changed, input(file));
      expect(kept.proxiesStyleProps.type, ProxiesType.tab);
      expect(isProviderManaged(kept, 'proxies.type'), isFalse);

      final withdrawn = applyProviderSettings(
        applied,
        const ProviderSettingsInput(ProviderHints.empty),
      );
      expect(withdrawn.proxiesStyleProps.type, base.proxiesStyleProps.type);
      expect(withdrawn.themeProps.pureBlack, base.themeProps.pureBlack);
    });
  });
}
