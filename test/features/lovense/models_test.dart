import 'dart:convert';

import 'package:reclash/features/lovense/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LovenseEndpoint', () {
    test('defaults to verified HTTPS on the local PC Remote', () {
      final endpoint = LovenseEndpoint.parse(lovenseDefaultAddress);
      expect(
        endpoint.uri.toString(),
        'https://127-0-0-1.lovense.club:30010/command',
      );
      expect(endpoint.address.address, '127.0.0.1');
    });

    for (final address in [
      'localhost',
      '127.0.0.1',
      '10.1.2.3',
      '172.16.0.1',
      '172.31.255.1',
      '192.168.1.10',
      '169.254.1.2',
    ]) {
      test('accepts local address $address and pins its IP', () {
        final endpoint = LovenseEndpoint.parse(address);
        expect(endpoint.uri.scheme, 'https');
        expect(endpoint.uri.port, 30010);
        expect(endpoint.uri.path, '/command');
        expect(endpoint.uri.host, endsWith('.lovense.club'));
        expect(
          endpoint.address.address,
          address == 'localhost' ? '127.0.0.1' : address,
        );
      });
    }

    for (final address in ['[::1]', '[fd12::1]', '[fe80::1]']) {
      test('accepts private IPv6 $address', () {
        expect(LovenseEndpoint.parse(address).uri.scheme, 'https');
      });
    }

    test('supports explicit HTTP without an automatic downgrade', () {
      final endpoint = LovenseEndpoint.parse('http://192.168.1.10');
      expect(
        endpoint.uri.toString(),
        'http://192-168-1-10.lovense.club:20010/command',
      );
      expect(endpoint.address.address, '192.168.1.10');
    });

    test('preserves an explicit port and accepts the command path', () {
      final endpoint = LovenseEndpoint.parse(
        ' https://192-168-1-10.lovense.club:31000/command ',
      );
      expect(endpoint.uri.port, 31000);
      expect(
        endpoint.displayAddress,
        'https://192-168-1-10.lovense.club:31000',
      );
    });

    for (final address in [
      '',
      '8.8.8.8',
      '0.0.0.0',
      '100.64.1.1',
      '172.15.0.1',
      '172.32.0.1',
      '[2001:4860:4860::8888]',
      'example.com',
      'evil.lovense.club',
      '8-8-8-8.lovense.club',
      '127-0-0-1.lovense.club.evil.example',
      'https://user:password@127.0.0.1',
      'ftp://127.0.0.1',
      'http://127.0.0.1/other',
      'http://127.0.0.1?secret=1',
      'http://127.0.0.1#secret',
      'http://127.0.0.1:0',
      'http://127.0.0.1:65536',
      'http://127.0.0.1:-1',
    ]) {
      test('rejects non-LAN or ambiguous address $address', () {
        expect(
          () => LovenseEndpoint.parse(address),
          throwsA(
            isA<LovenseError>().having(
              (e) => e.kind,
              'kind',
              LovenseErrorKind.invalidAddress,
            ),
          ),
        );
      });
    }
  });

  group('GetToys decoding', () {
    final raw = {
      'toy1': {
        'id': 'toy1',
        'name': 'nora',
        'nickName': 'My Nora',
        'status': '1',
        'battery': 60,
        'fullFunctionNames': ['Vibrate', 'Rotate'],
      },
      'toy2': {
        'name': 'max',
        'status': 0,
        'battery': -1,
        'shortFunctionNames': ['v', 'p'],
      },
    };

    for (final asString in [true, false]) {
      test(
        'parses ${asString ? 'JSON string' : 'direct map'} and capabilities',
        () {
          final toys = parseLovenseToys(asString ? jsonEncode(raw) : raw);
          final nora = toys.firstWhere((toy) => toy.id == 'toy1');
          expect(nora.displayName, 'My Nora');
          expect(nora.connected, isTrue);
          expect(nora.battery, 60);
          expect(nora.functions, [
            LovenseFunction.vibrate,
            LovenseFunction.rotate,
          ]);
          final max = toys.firstWhere((toy) => toy.id == 'toy2');
          expect(max.connected, isFalse);
          expect(max.battery, isNull);
          expect(max.functions, [
            LovenseFunction.vibrate,
            LovenseFunction.pump,
          ]);
        },
      );
    }

    test('older Remote has an explicit basic Vibrate fallback', () {
      final toy = parseLovenseToys({
        'old': {'name': 'lush', 'status': 1},
      }).single;
      expect(toy.functions, [LovenseFunction.vibrate]);
      expect(toy.hasFunctionInfo, isFalse);
    });

    test('reported but unknown functions do not enable fallback actuation', () {
      final toy = parseLovenseToys({
        'new': {
          'status': 1,
          'fullFunctionNames': ['Unknown'],
        },
      }).single;
      expect(toy.functions, isEmpty);
      expect(toy.hasFunctionInfo, isTrue);
    });

    test('Stroke is a modifier, not a standalone action', () {
      final toy = parseLovenseToys({
        'solace': {
          'status': 1,
          'fullFunctionNames': ['Thrusting', 'Stroke'],
        },
      }).single;
      expect(toy.functions, [LovenseFunction.thrusting]);
      expect(toy.supportsStroke, isTrue);
    });

    for (final raw in [
      null,
      'not JSON',
      '[]',
      [],
      {'id': false},
      {
        'id': {'id': 'first,second'},
      },
      {
        'id': {'id': 123},
      },
      {
        'id': {'fullFunctionNames': 'Vibrate'},
      },
      {
        for (var i = 0; i < 101; i++) '$i': {'id': '$i'},
      },
    ]) {
      test(
        'rejects malformed or oversized toys collection ${raw.runtimeType}',
        () {
          expect(() => parseLovenseToys(raw), throwsA(isA<LovenseError>()));
        },
      );
    }

    test('empty collection is a valid connection without toys', () {
      expect(parseLovenseToys('{}'), isEmpty);
    });
  });
}
