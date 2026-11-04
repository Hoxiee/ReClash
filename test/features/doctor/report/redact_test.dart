import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/features/doctor/report/archive.dart';
import 'package:reclash/features/doctor/report/redact.dart';
import 'package:reclash/features/doctor/report/report.dart';

const _salt = [1, 2, 3, 4];
const _subscription =
    'https://sub.example.net/api/v1/client/subscribe?token=f3a9c1e07b2d4e58';
const _uuid = '0b6f3c2a-9d41-4e8f-a1c7-3e5d2b9f8a10';

Redactor _provider([Iterable<String> secrets = const []]) =>
    Redactor(level: ReportRedaction.provider, secrets: secrets, salt: _salt);

Redactor _public([Iterable<String> secrets = const []]) =>
    Redactor(level: ReportRedaction.public, secrets: secrets, salt: _salt);

void main() {
  group('provider level', () {
    test('masks URL tokens, credentials and UUIDs, keeps hosts', () {
      final redactor = _provider();
      final text = redactor.text(
        'fetch $_subscription failed\n'
        'vless://$_uuid@nl1.edge.example.net:443?security=reality&sid=9c1e07b2\n'
        'https://user:hunter22@panel.example.net/sub/Xk2q9Lm4Pz7wQa1B',
      );

      expect(text, isNot(contains('f3a9c1e07b2d4e58')));
      expect(text, isNot(contains(_uuid)));
      expect(text, isNot(contains('hunter22')));
      expect(text, isNot(contains('Xk2q9Lm4Pz7wQa1B')));
      expect(text, isNot(contains('9c1e07b2')));
      expect(text, contains('https://sub.example.net/api/v1/client/subscribe'));
      expect(text, contains('nl1.edge.example.net:443'));
      expect(text, contains('security=reality'));
      expect(text, contains('panel.example.net'));
    });

    test('masks secret fields in YAML and JSON', () {
      final redactor = _provider();
      const yaml =
          '  - name: NL 01\n'
          '    server: nl1.edge.example.net\n'
          '    password: s3cretPass\n'
          '    private-key: "aGVsbG8td29ybGQta2V5"\n'
          '    short-id: 9c1e07b2\n';
      final text = redactor.text(yaml);
      expect(text, contains('password: ***'));
      expect(text, contains('private-key: "***"'));
      expect(text, contains('short-id: ***'));
      expect(text, contains('server: nl1.edge.example.net'));

      final json =
          redactor.json({
                'proxy': {'password': 's3cretPass', 'server': '1.2.3.4'},
                'note': '{"token":"abcdef123456"}',
              })!
              as Map<String, Object?>;
      expect(jsonEncode(json), isNot(contains('s3cretPass')));
      expect(jsonEncode(json), isNot(contains('abcdef123456')));
      expect(jsonEncode(json), contains('1.2.3.4'));
    });

    test('masks PEM private keys', () {
      final text = _provider().text(
        'key:\n-----BEGIN PRIVATE KEY-----\nMIIBVgIBADANBgkq\n'
        '-----END PRIVATE KEY-----\nnext',
      );
      expect(text, isNot(contains('MIIBVgIBADANBgkq')));
      expect(text, endsWith('next'));
    });

    test('masks the literal secrets it was given wherever they appear', () {
      final secrets = urlSecrets(_subscription);
      final text = _provider(secrets).text('cached as f3a9c1e07b2d4e58.yaml');
      expect(text, 'cached as ***.yaml');
      expect(urlOrigin(_subscription), 'https://sub.example.net/***');
    });
  });

  group('public level', () {
    test('hashes hosts and IPs stably within a report, keeps loopback', () {
      final redactor = _public();
      final first = redactor.text(
        'dial nl1.edge.example.net (203.0.113.7) via 127.0.0.1',
      );
      final second = redactor.text('again nl1.edge.example.net');

      expect(first, isNot(contains('example.net')));
      expect(first, isNot(contains('203.0.113.7')));
      expect(first, contains('127.0.0.1'));
      final host = RegExp(r'host-[0-9a-f]{8}').firstMatch(first)![0]!;
      expect(second, contains(host));
      expect(first, contains(RegExp(r'ip-[0-9a-f]{8}')));
    });

    test('a different salt gives different hashes', () {
      final a = _public().text('nl1.edge.example.net');
      final b = Redactor(
        level: ReportRedaction.public,
        secrets: const [],
        salt: const [9, 9, 9],
      ).text('nl1.edge.example.net');
      expect(a, isNot(b));
    });

    test('leaves file names and times alone', () {
      final text = _public().text('see 01-summary.md at 18:41:58');
      expect(text, 'see 01-summary.md at 18:41:58');
    });
  });

  group('inventory refusal', () {
    const data = ReportData(
      manifest: {'id': 'RC-0000-0000'},
      summary: {},
      config: 'token: f3a9c1e07b2d4e58\n',
      logs: {
        'core': ['plain line', 'leaked f3a9c1e07b2d4e58'],
      },
    );

    test('findLeak names the section that still holds a secret', () {
      final matcher = SecretMatcher(['f3a9c1e07b2d4e58']);
      expect(findLeak(data, matcher), 'config');
      expect(
        findLeak(
          ReportData(
            manifest: data.manifest,
            summary: data.summary,
            logs: data.logs,
          ),
          matcher,
        ),
        'logs/core',
      );
      expect(
        findLeak(redactReport(data, _provider(['f3a9c1e07b2d4e58'])), matcher),
        isNull,
      );
    });

    test('packing never writes a known secret', () async {
      final dir = await Directory.systemTemp.createTemp('report_redact');
      addTearDown(() => dir.delete(recursive: true));
      final path = '${dir.path}/out.zip';
      packReportSync((
        data: {
          ...data.toJson(),
          'profile': {'source': _subscription, 'label': 'Example VPN'},
        },
        secrets: urlSecrets(_subscription).toList(),
        redaction: ReportRedaction.provider,
        path: path,
      ));
      final archive = ZipDecoder().decodeBytes(File(path).readAsBytesSync());
      for (final file in archive.files) {
        final text = utf8.decode(file.content as List<int>);
        expect(text, isNot(contains('f3a9c1e07b2d4e58')), reason: file.name);
      }
    });
  });

  test('redaction is linear in input size', () {
    final redactor = _public(List.generate(200, (i) => 'secret-value-$i'));
    const line =
        '2026-11-03T18:42:03.004Z WARNING dial nl1.edge.example.net:443 '
        'from 192.168.1.23 error: i/o timeout';
    String run(int lines) => redactor.text(List.filled(lines, line).join('\n'));
    run(2000);
    final small = Stopwatch()..start();
    run(5000);
    small.stop();
    final large = Stopwatch()..start();
    run(50000);
    large.stop();
    expect(large.elapsedMicroseconds, lessThan(small.elapsedMicroseconds * 30));
  });
}
