import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/compatibility/prepare.dart';
import 'package:reclash/subscriptions/imports/import.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

import '../../helpers/app_paths.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = Directory.systemTemp.createTempSync('subscription_prepare');
    await useAppPaths(directory);
  });
  tearDown(() => directory.deleteSync(recursive: true));

  final payload = SubscriptionImportResult(
    bytes: Uint8List.fromList(utf8.encode('proxies: []')),
    format: SubscriptionFormat.clash,
    summary: const SubscriptionImportSummary(nodes: 1),
  );

  test(
    'validates only a temporary candidate and removes it afterwards',
    () async {
      late String candidatePath;
      await validateSubscriptionImport(
        payload,
        validate: (path, key) async {
          candidatePath = path;
          expect(await File(path).readAsString(), 'proxies: []');
          expect(key, '');
          return '';
        },
      );
      expect(await File(candidatePath).exists(), false);
      expect(directory.listSync(), isEmpty);
    },
  );

  test(
    'rejects Core parse failures without retaining body or error details',
    () async {
      await expectLater(
        validateSubscriptionImport(
          payload,
          validate: (_, _) async => 'secret address/key',
        ),
        throwsA(
          isA<SubscriptionImportException>().having(
            (error) => error.message,
            'message',
            isNot(contains('secret')),
          ),
        ),
      );
      expect(directory.listSync(), isEmpty);
    },
  );

  test(
    'cancellation after validation prevents returning a ready result',
    () async {
      var cancelled = false;
      await expectLater(
        validateSubscriptionImport(
          payload,
          isCancelled: () => cancelled,
          validate: (_, _) async {
            cancelled = true;
            return '';
          },
        ),
        throwsA(
          isA<SubscriptionException>().having(
            (error) => error.failure,
            'failure',
            SubscriptionFailure.cancelled,
          ),
        ),
      );
      expect(directory.listSync(), isEmpty);
    },
  );
}
