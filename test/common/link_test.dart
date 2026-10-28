import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/link.dart';
import 'package:reclash/common/protocol.dart';
import 'package:reclash/common/url_scheme.dart';
import 'package:reclash/state.dart';

void main() {
  late LinkManager manager;
  late StreamController<String> links;
  late List<String> received;
  late int errors;

  setUp(() {
    links = StreamController<String>.broadcast();
    manager = LinkManager.scoped()..stringLinkStream = () => links.stream;
    received = [];
    errors = 0;
    final attached = globalState.isAttach;
    globalState.isAttach = false;
    addTearDown(() => globalState.isAttach = attached);
  });

  tearDown(() async {
    manager.destroy();
    await links.close();
  });

  Future<void> listen([FutureOr<void> Function(String)? handler]) => manager
      .initAppLinksListen(handler ?? received.add, onError: () => errors++);

  Future<void> emit(String link) async {
    links.add(link);
    await Future<void>.delayed(Duration.zero);
  }

  test('LinkManager is a singleton with isolated test instances', () {
    expect(LinkManager(), same(linkManager));
    expect(manager, isNot(same(linkManager)));
  });

  test(
    'delivery preserves the full input for parsing and confirmation',
    () async {
      await listen();
      const input =
          'reclash://install-config?url=https%3A%2F%2Fexample.com%2Fsub'
          '&name=Home';
      await emit(input);
      expect(received, [input]);
    },
  );

  test('known malformed links reach the user-facing parser', () async {
    await listen();
    const inputs = [
      'reclash://install-config',
      'reclash://install-config?url=',
      'reclash://open-profile?url=https://example.com/a.yaml',
      'reclash://add?url=%ZZ',
    ];
    for (final input in inputs) {
      await emit(input);
    }
    expect(received, inputs);
  });

  test('delivers every registered scheme without normalizing Base64', () async {
    await listen();
    for (final scheme in protocolSchemes) {
      await emit('$scheme://AbCdEFGh+/==');
    }
    expect(received, [
      for (final scheme in protocolSchemes) '$scheme://AbCdEFGh+/==',
    ]);
    expect(errors, 0);
  });

  test('ignores unrelated schemes and inputs without a scheme', () async {
    await listen();
    await emit('https://example.com/sub');
    await emit('other://connect');
    await emit('not a link');
    expect(received, isEmpty);
    expect(errors, 0);
  });

  test('listening again cancels the previous subscription', () async {
    await listen();
    final first = manager.subscription;
    await listen();
    expect(manager.subscription, isNot(same(first)));
    await emit('reclash://open');
    expect(received, ['reclash://open']);
  });

  test('a launch argument and its plugin echo execute only once', () async {
    manager.seedInitialLink(['--verbose', 'reclash://connect']);
    expect(received, isEmpty);
    await listen();
    await emit('reclash://connect');
    expect(received, ['reclash://connect']);
    await emit('reclash://connect');
    expect(received, ['reclash://connect', 'reclash://connect']);
    await listen();
    expect(received, hasLength(2));
  });

  testWidgets('a missing seed echo does not suppress later intentional links', (
    tester,
  ) async {
    manager.seedInitialLink(['vmess://AbCdEFGh']);
    await listen();
    await tester.pump(const Duration(seconds: 2));
    links.add('vmess://AbCdEFGh');
    await tester.pump();
    expect(received, ['vmess://AbCdEFGh', 'vmess://AbCdEFGh']);
  });

  test('launch arguments without a known scheme are ignored', () async {
    manager.seedInitialLink(['https://example.com/a.yaml', 'not a uri']);
    await listen();
    expect(received, isEmpty);
  });

  test('destroy discards an undelivered launch argument', () async {
    manager.seedInitialLink(['reclash://connect']);
    manager.destroy();
    await listen();
    expect(received, isEmpty);
  });

  test(
    'serializes handlers and coalesces active and queued duplicates',
    () async {
      final gate = Completer<void>();
      await listen((link) async {
        received.add(link);
        if (link == 'reclash://connect') await gate.future;
      });
      await emit('reclash://connect');
      await emit('reclash://connect');
      await emit('reclash://disconnect');
      await emit('reclash://disconnect');
      await emit('reclash://open');
      expect(received, ['reclash://connect']);
      gate.complete();
      await Future<void>.delayed(Duration.zero);
      expect(received, [
        'reclash://connect',
        'reclash://disconnect',
        'reclash://open',
      ]);
      await emit('reclash://disconnect');
      expect(received.last, 'reclash://disconnect');
      expect(received, hasLength(4));
    },
  );

  test('bounds the pending queue without losing accepted links', () async {
    final gate = Completer<void>();
    await listen((link) async {
      received.add(link);
      if (link == 'reclash://connect') await gate.future;
    });
    await emit('reclash://connect');
    for (var i = 0; i < 9; i++) {
      await emit('reclash://add?url=https://example.com/$i');
    }
    await emit('reclash://add?url=https://example.com/7');
    expect(errors, 1);
    gate.complete();
    await Future<void>.delayed(Duration.zero);
    expect(received, [
      'reclash://connect',
      for (var i = 0; i < 8; i++) 'reclash://add?url=https://example.com/$i',
    ]);
  });

  test('rejects oversized events before queueing them', () async {
    await listen();
    await emit('reclash://import/${'a' * urlSchemeMaxLength}');
    expect(received, isEmpty);
    expect(errors, 1);
  });

  test('a handler failure releases the queue for the next event', () async {
    await listen((link) {
      received.add(link);
      if (link == 'reclash://connect') throw StateError('failed');
    });
    await emit('reclash://connect');
    await emit('reclash://open');
    expect(errors, 1);
    expect(received, ['reclash://connect', 'reclash://open']);
  });

  test('stream errors are reported without stopping later events', () async {
    await listen();
    links.addError(StateError('stream failed'));
    await emit('reclash://open');
    expect(errors, 1);
    expect(received, ['reclash://open']);
  });

  test('an unavailable stream still delivers the launch argument', () async {
    manager.stringLinkStream = () => throw StateError('unavailable');
    manager.seedInitialLink(['reclash://open']);
    await listen();
    expect(errors, 1);
    expect(received, ['reclash://open']);
  });

  test(
    'destroy clears pending events and invalidates late completion',
    () async {
      final oldGate = Completer<void>();
      final newGate = Completer<void>();
      await listen((link) async {
        received.add(link);
        await oldGate.future;
      });
      await emit('reclash://connect');
      await emit('reclash://close');
      manager.destroy();
      await listen((link) async {
        received.add(link);
        if (link == 'reclash://open') await newGate.future;
      });
      await emit('reclash://open');
      oldGate.complete();
      await Future<void>.delayed(Duration.zero);
      await emit('reclash://disconnect');
      expect(received, ['reclash://connect', 'reclash://open']);
      newGate.complete();
      await Future<void>.delayed(Duration.zero);
      expect(received, [
        'reclash://connect',
        'reclash://open',
        'reclash://disconnect',
      ]);
    },
  );

  test('destroy stops delivery and is safe to repeat', () async {
    await listen();
    manager.destroy();
    manager.destroy();
    await emit('reclash://open');
    expect(manager.subscription, isNull);
    expect(links.hasListener, isFalse);
    expect(received, isEmpty);
  });

  test(
    'delivery logs contain only a scheme, never credentials or payload',
    () async {
      final output = <String?>[];
      final previous = debugPrint;
      debugPrint = (message, {wrapWidth}) => output.add(message);
      addTearDown(() => debugPrint = previous);
      await listen();
      await emit('reclash://add?url=https%3A%2F%2Fexample.com%2Fsecret-token');
      expect(output, ['[APP] onAppLink: reclash']);
    },
  );

  group('profileUrlFromQrCodes', () {
    test('accepts a bare url with surrounding whitespace', () {
      expect(
        profileUrlFromQrCodes([' https://example.com/sub?token=1\n']),
        'https://example.com/sub?token=1',
      );
    });

    test('unwraps unnamed install-config links for every config scheme', () {
      for (final scheme in configProtocolSchemes) {
        expect(
          profileUrlFromQrCodes([
            '$scheme://install-config?url=https%3A%2F%2Fexample.com%2Fa.yaml',
          ]),
          'https://example.com/a.yaml',
        );
      }
    });

    test('preserves named profile links and deep-link wrappers', () {
      for (final input in [
        'reclash://install-config?url=https%3A%2F%2Fexample.com%2Fsub&name=Home',
        'reclash://import?data=cHJveGllczogW10=',
        'incy://crypt1/AbCdEfGh',
        'happ://add/https%3A%2F%2Fexample.com%2Fsub',
        'vmess://AbCdEfGh==',
      ]) {
        expect(profileUrlFromQrCodes([input]), input);
      }
    });

    test('rejects codes that carry no profile source', () {
      expect(
        profileUrlFromQrCodes([
          null,
          '',
          'plain text',
          'https://',
          'reclash://connect',
          'clash://install-config?url=not-a-url',
          'clash://open-profile?url=https://example.com/a.yaml',
          'other://install-config?url=https://example.com/a.yaml',
        ]),
        isNull,
      );
    });

    test('skips malformed percent encoding before a valid code', () {
      expect(
        profileUrlFromQrCodes(['%', '%ZZ', 'https://example.com/sub']),
        'https://example.com/sub',
      );
    });

    test('returns the first code that carries a profile source', () {
      expect(
        profileUrlFromQrCodes([
          'plain text',
          'reclash://install-config?url=https://example.com/first.yaml',
          'https://example.com/second.yaml',
        ]),
        'https://example.com/first.yaml',
      );
    });
  });
}
