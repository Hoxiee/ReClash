import 'dart:async';
import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('partial SOCKS replies yield while waiting for more data', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final responseSent = Completer<void>();
    final subscription = server.listen((socket) {
      socket.listen((_) async {
        socket.add(const [5]);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        socket.add(const [1]);
        responseSent.complete();
      });
    });
    try {
      final result = await desyncCheckSite('example.com', server.port);
      expect(result, DesyncSiteStatus.engineDown);
      expect(responseSent.isCompleted, isTrue);
    } finally {
      await subscription.cancel();
      await server.close();
    }
  }, timeout: const Timeout(Duration(seconds: 2)));

  test('truncated SOCKS domain reply is blocked without throwing', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final subscription = server.listen((socket) {
      var stage = 0;
      socket.listen((_) {
        if (stage++ == 0) {
          socket.add(const [5, 0]);
        } else {
          socket.add(const [5, 0, 0, 3]);
          socket.destroy();
        }
      });
    });
    try {
      final result = await desyncCheckSite('example.com', server.port);
      expect(result, DesyncSiteStatus.blocked);
    } finally {
      await subscription.cancel();
      await server.close();
    }
  }, timeout: const Timeout(Duration(seconds: 2)));

  test('stop prevents a completed site check from starting another', () async {
    final started = Completer<void>();
    final release = Completer<void>();
    final checked = <String>[];
    final tester = DesyncStrategyTester(
      port: 7898,
      applyArgs: (_) async {},
      checkSite: (host, _) async {
        checked.add(host);
        if (!started.isCompleted) started.complete();
        await release.future;
        return DesyncSiteStatus.blocked;
      },
    );
    final run = tester.run(
      originalArgs: desyncTestArgs(desyncTestPresets.first),
      sites: const ['one.test'],
    );
    await started.future;
    tester.stop();
    release.complete();

    final outcomes = await run;
    expect(checked, const ['one.test']);
    expect(outcomes, hasLength(1));
  });

  test('every preset line parses into a non-empty argument list', () {
    for (final line in desyncTestPresets) {
      final args = desyncTestArgs(line);
      expect(args, isNotEmpty, reason: line);
      expect(args.first, startsWith('-'), reason: line);
    }
  });

  test('the fake-SNI placeholder is filled, not passed through', () {
    for (final line in desyncTestPresets) {
      expect(desyncTestArgs(line).contains('{sni}'), isFalse, reason: line);
      expect(
        desyncTestArgs(line).contains(desyncTestFakeSni),
        line.contains('{sni}'),
        reason: line,
      );
    }
    expect(desyncTestArgs('-n {sni} -t5'), const ['-n', 'google.com', '-t5']);
  });

  test('the default ladder is one of the presets', () {
    final parsed = desyncTestPresets.map(desyncTestArgs).toList();
    final matches = parsed
        .where((args) => listEquals(args, desyncDefaultStrategy))
        .toList();
    expect(matches, hasLength(1));
  });

  test('preset lines are unique', () {
    expect(desyncTestPresets.toSet(), hasLength(desyncTestPresets.length));
  });

  test('site lists carry unique ids and bare hostnames', () {
    final ids = desyncTestSiteLists.map((list) => list.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
    final domains = desyncTestSiteLists.expand((list) => list.domains).toList();
    for (final site in domains) {
      expect(site, matches(RegExp(r'^[a-z0-9.-]+$')), reason: site);
    }
    expect(domains.toSet(), hasLength(domains.length));
  });

  test('the default selection resolves to the full domain union', () {
    final sites = desyncTestSitesFor(defaultDesyncTestSiteLists);
    expect(
      sites.length,
      desyncTestSiteLists
          .where((list) => defaultDesyncTestSiteLists.contains(list.id))
          .map((list) => list.domains.length)
          .reduce((a, b) => a + b),
    );
    expect(sites.toSet(), hasLength(sites.length));
  });

  test('the site union is distinct across overlapping selections', () {
    final sites = desyncTestSitesFor([
      for (final list in desyncTestSiteLists) list.id,
      ...defaultDesyncTestSiteLists,
    ]);
    expect(sites.toSet(), hasLength(sites.length));
  });

  test('an outcome counts only sites the engine answered for', () {
    const up = DesyncTestOutcome(
      text: '-d1',
      failedSites: ['youtu.be', 'youtube.com'],
      passedOnRetry: 4,
      total: 83,
      engineUp: true,
    );
    expect(up.passed, 81);
    expect(up.score, closeTo(79 / 83, 1e-9));

    const crashed = DesyncTestOutcome(
      text: '-d1',
      failedSites: [],
      passedOnRetry: 0,
      total: 83,
      engineUp: false,
    );
    expect(crashed.passed, 0);
    expect(crashed.score, 0);
    expect(crashed.total, 83);
  });
}
