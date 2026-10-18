import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_paths.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('profile_save_test');
    await useAppPaths(tempDir);
  });

  tearDownAll(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('Profile.saveFile', () {
    // EditProfileView relies on this throwing rather than silently
    // succeeding, so a caller-level try/catch can surface the failure.
    test('rejects an invalid config without touching the saved file', () async {
      final profile = Profile.normal(label: 'p');
      final bytes = Uint8List.fromList(utf8.encode('bad: ['));

      await expectLater(
        profile.saveFile(bytes, validate: (_, _) async => 'invalid config'),
        throwsA(
          isA<MessageException>().having(
            (e) => e.message,
            'message',
            'invalid config',
          ),
        ),
      );

      final savedFile = await profile.file;
      expect(await savedFile.length(), 0);
    });

    test('copies validated bytes and stamps the update time', () async {
      final profile = Profile.normal(label: 'p');
      final bytes = Uint8List.fromList(utf8.encode('proxies: []'));

      final saved = await profile.saveFile(bytes, validate: (_, _) async => '');

      expect(saved.lastUpdateDate, isNotNull);
      final savedFile = await profile.file;
      expect(await savedFile.readAsString(), 'proxies: []');
    });

    test(
      'stores validator-rewritten bytes instead of the original input',
      () async {
        final profile = Profile.normal(label: 'rewritten');
        final source = Uint8List.fromList(utf8.encode('age encrypted bytes'));

        await profile.saveFile(
          source,
          validate: (path, _) async {
            await File(path).writeAsString('decrypted Clash config');
            return '';
          },
        );

        expect(
          await (await profile.file).readAsString(),
          'decrypted Clash config',
        );
      },
    );

    test('restores the previous file when owner persistence fails', () async {
      final profile = Profile.normal(label: 'rollback');
      await profile.saveFile(
        Uint8List.fromList(utf8.encode('previous config')),
        validate: (_, _) async => '',
      );

      await expectLater(
        profile.saveFile(
          Uint8List.fromList(utf8.encode('next config')),
          validate: (_, _) async => '',
          onCommitted: (_) async => throw StateError('database write failed'),
        ),
        throwsStateError,
      );

      expect(await (await profile.file).readAsString(), 'previous config');
      expect(
        await File('${(await profile.file).path}.staged').exists(),
        isFalse,
      );
    });

    test(
      'serializes file and owner persistence for the same profile',
      () async {
        final profile = Profile.normal(label: 'serial');
        final firstCommitted = Completer<void>();
        final releaseFirst = Completer<void>();
        final secondValidated = Completer<void>();
        final commits = <String>[];
        addTearDown(() {
          if (!releaseFirst.isCompleted) releaseFirst.complete();
        });

        final first = profile.saveFile(
          Uint8List.fromList(utf8.encode('first config')),
          validate: (_, _) async => '',
          onCommitted: (_) async {
            commits.add('first');
            firstCommitted.complete();
            await releaseFirst.future;
          },
        );
        await firstCommitted.future;
        final second = profile.saveFile(
          Uint8List.fromList(utf8.encode('second config')),
          validate: (_, _) async {
            secondValidated.complete();
            return '';
          },
          onCommitted: (_) async => commits.add('second'),
        );
        await secondValidated.future;
        await pumpEventQueue();
        expect(commits, ['first']);
        expect(await (await profile.file).readAsString(), 'first config');

        releaseFirst.complete();
        await Future.wait([first, second]);
        final file = await profile.file;
        expect(commits, ['first', 'second']);
        expect(await file.readAsString(), 'second config');
        expect(await File('${file.path}.previous').exists(), isFalse);
        expect(await File('${file.path}.staged').exists(), isFalse);
      },
    );

    test('a superseded queued save never replaces the working file', () async {
      final profile = Profile.normal(label: 'superseded');
      await profile.saveFile(
        Uint8List.fromList(utf8.encode('working config')),
        validate: (_, _) async => '',
      );
      final entered = Completer<void>();
      final release = Completer<void>();
      final validated = Completer<void>();
      var current = true;
      var persisted = false;
      addTearDown(() {
        if (!release.isCompleted) release.complete();
      });
      final held = serializeProfileMutation(profile.id, () async {
        entered.complete();
        await release.future;
      });
      await entered.future;
      final pending = profile.saveFile(
        Uint8List.fromList(utf8.encode('obsolete config')),
        validate: (_, _) async {
          validated.complete();
          return '';
        },
        isCurrent: () => current,
        onCommitted: (_) async => persisted = true,
      );
      final rejected = expectLater(
        pending,
        throwsA(isA<SubscriptionUpdateSuperseded>()),
      );
      await validated.future;
      current = false;
      release.complete();
      await held;
      await rejected;

      final file = await profile.file;
      expect(await file.readAsString(), 'working config');
      expect(persisted, isFalse);
      expect(await File('${file.path}.previous').exists(), isFalse);
      expect(await File('${file.path}.staged').exists(), isFalse);
    });

    test(
      'a failed profile mutation does not block other or later writes',
      () async {
        final profile = Profile.normal(label: 'queue');
        final other = Profile.normal(label: 'other');
        final entered = Completer<void>();
        final release = Completer<void>();
        addTearDown(() {
          if (!release.isCompleted) release.complete();
        });
        final held = serializeProfileMutation(profile.id, () async {
          entered.complete();
          await release.future;
          throw StateError('owner failed');
        });
        final rejected = expectLater(held, throwsStateError);
        await entered.future;
        await other.saveFile(
          Uint8List.fromList(utf8.encode('independent config')),
          validate: (_, _) async => '',
        );
        final next = profile.saveFile(
          Uint8List.fromList(utf8.encode('recovered config')),
          validate: (_, _) async => '',
        );
        release.complete();
        await rejected;
        await next;

        expect(await (await other.file).readAsString(), 'independent config');
        expect(await (await profile.file).readAsString(), 'recovered config');
      },
    );

    test('validates with the profile age key', () async {
      final profile = Profile.normal(
        label: 'p',
      ).copyWith(ageSecretKey: 'AGE-SECRET-KEY-1A');
      final bytes = Uint8List.fromList(utf8.encode('proxies: []'));
      String? ageSecretKey;

      await profile.saveFile(
        bytes,
        validate: (_, key) async {
          ageSecretKey = key;
          return '';
        },
      );

      expect(ageSecretKey, 'AGE-SECRET-KEY-1A');
    });
  });
}
