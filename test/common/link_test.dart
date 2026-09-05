import 'dart:async';

import 'package:reclash/common/link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late StreamController<Uri> links;
  late List<IncomingLink> received;

  setUp(() {
    links = StreamController<Uri>.broadcast();
    received = [];
    linkManager.uriLinkStream = () => links.stream;
  });

  tearDown(() async {
    linkManager.destroy();
    await links.close();
  });

  List<String> payloads() => received.map((link) => link.payload).toList();

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

  test('an install-config link reports its url', () async {
    await listen();

    await emit('reclash://install-config?url=https://example.com/a.yaml');

    expect(payloads(), ['https://example.com/a.yaml']);
    expect(received.single.name, isNull);
  });

  test('an install-config link passes its name along', () async {
    await listen();

    await emit(
      'clash://install-config?url=https://example.com/a.yaml&name=My%20Panel',
    );

    expect(received.single.name, 'My Panel');
  });

  test('an install-config link without a url is ignored', () async {
    await listen();

    await emit('reclash://install-config');

    expect(received, isEmpty);
  });

  test('a link for another host is ignored', () async {
    await listen();

    await emit('reclash://open-profile?url=https://example.com/a.yaml');

    expect(received, isEmpty);
  });

  test('a foreign deep link is delivered whole, host and all', () async {
    await listen();

    await emit('incy://crypt1/abc');
    await emit('happ://add/https%3A%2F%2Fexample.com%2Fa.yaml');

    expect(payloads(), [
      'incy://crypt1/abc',
      'happ://add/https%3A%2F%2Fexample.com%2Fa.yaml',
    ]);
  });

  test('a share link is delivered whole', () async {
    await listen();

    await emit('vless://uuid@example.com:443?type=tcp#Node');

    expect(payloads(), ['vless://uuid@example.com:443?type=tcp#Node']);
  });

  test('an unclaimed scheme is ignored', () async {
    await listen();

    await emit('socks://example.com:1080');
    await emit('https://example.com/a.yaml');

    expect(received, isEmpty);
  });

  test('listening again replaces the previous subscription', () async {
    await listen();
    final first = linkManager.subscription;

    await listen();

    expect(linkManager.subscription, isNot(same(first)));

    await emit('reclash://install-config?url=https://example.com/a.yaml');

    expect(payloads(), ['https://example.com/a.yaml']);
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

      expect(payloads(), ['https://example.com/a.yaml']);

      await listen();

      expect(payloads(), ['https://example.com/a.yaml']);
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
}
