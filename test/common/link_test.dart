import 'dart:async';
import 'dart:convert';

import 'package:reclash/common/link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late StreamController<Uri> links;
  late List<Uri> received;

  setUp(() {
    links = StreamController<Uri>.broadcast();
    received = [];
    linkManager.uriLinkStream = () => links.stream;
  });

  tearDown(() async {
    linkManager.destroy();
    await links.close();
  });

  List<String> payloads() => received.map((uri) => uri.toString()).toList();

  Future<void> listen() async {
    await linkManager.initAppLinksListen(received.add);
  }

  Future<void> emit(String uri) async {
    links.add(Uri.parse(uri));
    await Future<void>.delayed(Duration.zero);
  }

  test('LinkManager is a singleton', () {
    expect(LinkManager(), same(linkManager));
  });

  test('every known scheme is delivered as a raw uri', () async {
    await listen();

    await emit('reclash://install-config?url=https://example.com/a.yaml');
    await emit('clash://install-config?url=https://example.com/a.yaml');
    await emit('incy://crypt1/abc');
    await emit('vless://uuid@example.com:443?type=tcp#Node');

    expect(payloads(), [
      'reclash://install-config?url=https://example.com/a.yaml',
      'clash://install-config?url=https://example.com/a.yaml',
      'incy://crypt1/abc',
      'vless://uuid@example.com:443?type=tcp#Node',
    ]);
  });

  test('an unclaimed scheme is ignored', () async {
    await listen();

    await emit('socks://example.com:1080');
    await emit('https://example.com/a.yaml');
    await emit('reclash://toggle');

    expect(
      payloads(),
      everyElement(isNot(startsWith('socks://'))),
    );
  });

  test('listening again replaces the previous subscription', () async {
    await listen();
    final first = linkManager.subscription;

    await listen();

    expect(linkManager.subscription, isNot(same(first)));

    await emit('reclash://toggle');

    expect(payloads(), ['reclash://toggle']);
  });

  test(
    'a seeded launch argument is delivered once a listener attaches',
    () async {
      linkManager.seedInitialLink([
        '--verbose',
        'reclash://install-config?url=https://example.com/a.yaml',
      ]);

      expect(received, isEmpty);

      await listen();

      expect(payloads(), ['reclash://install-config?url=https://example.com/a.yaml']);

      await listen();

      expect(payloads(), ['reclash://install-config?url=https://example.com/a.yaml']);
    },
  );

  test('a seeded share link is delivered too', () async {
    linkManager.seedInitialLink(['trojan://pass@example.com:443#Node']);

    await listen();

    expect(payloads(), ['trojan://pass@example.com:443#Node']);
  });

  test('launch arguments without a known scheme are ignored', () async {
    linkManager.seedInitialLink(['https://example.com/a.yaml', 'not a uri']);

    await listen();

    expect(received, isEmpty);
  });

  test('destroy stops delivery and is safe to repeat', () async {
    await listen();

    linkManager.destroy();
    linkManager.destroy();
    await emit('reclash://install-config?url=https://example.com/a.yaml');

    expect(linkManager.subscription, isNull);
    expect(received, isEmpty);
  });

  group('parseReClashCommand', () {
    test('maps every automation command', () {
      const cases = {
        'reclash://connect': ReClashCommand.connect,
        'reclash://disconnect': ReClashCommand.disconnect,
        'reclash://toggle': ReClashCommand.toggle,
        'reclash://open': ReClashCommand.open,
        'reclash://close': ReClashCommand.close,
      };
      for (final entry in cases.entries) {
        final command = parseReClashCommand(Uri.parse(entry.key));
        expect(command?.command, entry.value, reason: entry.key);
        expect(command?.payload, isNull, reason: entry.key);
      }
    });

    test('carries the path argument for import and add', () {
      final config = base64Encode('proxies: []'.codeUnits);
      final import = parseReClashCommand(
        Uri.parse('reclash://import/$config'),
      );
      expect(import?.command, ReClashCommand.importProfile);
      expect(import?.payload, config);

      final add = parseReClashCommand(
        Uri.parse('reclash://add/https%3A%2F%2Fexample.com%2Fsub'),
      );
      expect(add?.command, ReClashCommand.addProfile);
      expect(add?.payload, 'https://example.com/sub');
    });

    test('import and add without a payload are rejected', () {
      expect(parseReClashCommand(Uri.parse('reclash://import')), isNull);
      expect(parseReClashCommand(Uri.parse('reclash://add/')), isNull);
    });

    test('unknown commands and foreign schemes are rejected', () {
      expect(parseReClashCommand(Uri.parse('reclash://teleport')), isNull);
      expect(parseReClashCommand(Uri.parse('clash://toggle')), isNull);
      expect(parseReClashCommand(Uri.parse('reclash://')), isNull);
    });

    test('install-config stays a link, not a command', () {
      expect(
        parseReClashCommand(
          Uri.parse('reclash://install-config?url=https://example.com'),
        ),
        isNull,
      );
    });
  });

  group('parseIncomingLink', () {
    test('an install-config link reports its url', () {
      final link = parseIncomingLink(
        Uri.parse('reclash://install-config?url=https://example.com/a.yaml'),
      );
      expect(link?.payload, 'https://example.com/a.yaml');
      expect(link?.name, isNull);
    });

    test('an install-config link passes its name along', () {
      final link = parseIncomingLink(
        Uri.parse(
          'clash://install-config?url=https://example.com/a.yaml&name=My%20Panel',
        ),
      );
      expect(link?.name, 'My Panel');
    });

    test('an install-config link without a url is ignored', () {
      expect(
        parseIncomingLink(Uri.parse('reclash://install-config')),
        isNull,
      );
    });

    test('a link for another host is ignored', () {
      expect(
        parseIncomingLink(
          Uri.parse('reclash://open-profile?url=https://example.com/a.yaml'),
        ),
        isNull,
      );
    });

    test('reclash automation hosts are not links', () {
      expect(parseIncomingLink(Uri.parse('reclash://toggle')), isNull);
    });

    test('a foreign deep link is delivered whole', () {
      final link = parseIncomingLink(Uri.parse('incy://crypt1/abc'));
      expect(link?.payload, 'incy://crypt1/abc');
    });

    test('a share link is delivered whole', () {
      final link = parseIncomingLink(
        Uri.parse('vless://uuid@example.com:443?type=tcp#Node'),
      );
      expect(link?.payload, 'vless://uuid@example.com:443?type=tcp#Node');
    });
  });
}
