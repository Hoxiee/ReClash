import 'dart:convert';
import 'dart:io';

import 'package:reclash/common/net/doh.dart';
import 'package:flutter_test/flutter_test.dart';

String _answer(String data, {int type = 1, int ttl = 300}) => json.encode({
  'Status': 0,
  'Answer': [
    {'name': 'panel.test', 'type': type, 'TTL': ttl, 'data': data},
  ],
});

void main() {
  group('parseDohAnswer', () {
    test('an A record yields its address with a bounded lifetime', () {
      expect(parseDohAnswer(_answer('203.0.113.7', ttl: 5)), (
        address: InternetAddress('203.0.113.7'),
        ttl: dohMinTtl,
      ));
      expect(
        parseDohAnswer(_answer('203.0.113.7', ttl: 999999))?.ttl,
        dohMaxTtl,
      );
    });

    test('answers without an IPv4 address and broken bodies yield nothing', () {
      expect(parseDohAnswer(_answer('panel.example.com', type: 5)), isNull);
      expect(parseDohAnswer(_answer('2001:db8::1', type: 28)), isNull);
      expect(parseDohAnswer(json.encode({'Status': 3})), isNull);
      expect(parseDohAnswer('not json'), isNull);
    });
  });

  test('the query names the host and asks for an A record', () {
    final url = dohQueryUrl(dohEndpoints.first, 'panel.test');

    expect(url.host, '1.1.1.1');
    expect(url.queryParameters, {'name': 'panel.test', 'type': 'A'});
  });

  group('DohResolver', () {
    test('an address literal is nothing to resolve', () async {
      final asked = <Uri>[];
      final resolver = DohResolver(
        query: (url) async {
          asked.add(url);
          return _answer('203.0.113.7');
        },
      );

      expect(await resolver.lookup('203.0.113.7'), isNull);
      expect(await resolver.lookup(''), isNull);
      expect(asked, isEmpty);
    });

    test(
      'the first endpoint that answers wins, and its answer is cached',
      () async {
        var now = DateTime(2026, 5, 10, 12);
        final asked = <Uri>[];
        final resolver = DohResolver(
          query: (url) async {
            asked.add(url);
            return _answer('203.0.113.7', ttl: 120);
          },
          now: () => now,
        );

        expect(
          await resolver.lookup('panel.test'),
          InternetAddress('203.0.113.7'),
        );
        now = now.add(const Duration(minutes: 1));
        await resolver.lookup('panel.test');
        expect(asked, hasLength(1));

        now = now.add(const Duration(minutes: 2));
        await resolver.lookup('panel.test');
        expect(asked, hasLength(2));
      },
    );

    test('the cache evicts its least recently used hostname', () async {
      final asked = <String>[];
      final resolver = DohResolver(
        query: (url) async {
          asked.add(url.queryParameters['name']!);
          return _answer('203.0.113.7');
        },
      );

      for (var index = 0; index < dohCacheCapacity; index++) {
        await resolver.lookup('host-$index.test');
      }
      await resolver.lookup('host-0.test');
      await resolver.lookup('overflow.test');
      await resolver.lookup('host-1.test');
      await resolver.lookup('host-0.test');

      expect(asked.where((host) => host == 'host-1.test'), hasLength(2));
      expect(asked.where((host) => host == 'host-0.test'), hasLength(1));
    });

    test(
      'an endpoint that cannot answer hands the query to the next',
      () async {
        final asked = <Uri>[];
        final resolver = DohResolver(
          query: (url) async {
            asked.add(url);
            return url.host == Uri.parse(dohEndpoints.first).host
                ? null
                : _answer('203.0.113.7');
          },
        );

        expect(
          await resolver.lookup('panel.test'),
          InternetAddress('203.0.113.7'),
        );
        expect(asked, hasLength(2));
      },
    );

    test('a resolver nobody can reach is left alone for a while', () async {
      var now = DateTime(2026, 5, 10, 12);
      var asked = 0;
      final resolver = DohResolver(
        query: (url) async {
          asked++;
          return null;
        },
        now: () => now,
      );

      for (var attempt = 0; attempt < dohFailureLimit; attempt++) {
        expect(await resolver.lookup('panel.test'), isNull);
      }
      final beforeSleep = asked;

      expect(await resolver.lookup('panel.test'), isNull);
      expect(asked, beforeSleep);

      now = now.add(dohFailureSleep + const Duration(minutes: 1));
      expect(await resolver.lookup('panel.test'), isNull);
      expect(asked, greaterThan(beforeSleep));
    });
  });
}
