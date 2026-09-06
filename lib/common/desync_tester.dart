import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:reclash/common/desync.dart';
import 'package:reclash/models/models.dart';

/// Candidate lines from ByeByeDPI's proxy test set; {sni} is its fake-SNI
/// placeholder, filled the same way its tester does.
const desyncTestPresets = <String>[
  '-f-200 -Qr -s3:5+sm -a1 -As -d1 -s4+sm -s8+sh -f-300 -d6+sh -a1 -At,r,s -o2 -f-30 -As -r5 -Mh -r6+sh -f-250 -s2:7+s -s3:6+sm -a1 -At,r,s -s3:5+sm -s6+s -s7:9+s -q30+sm -a1',
  '-d1 -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -r1+s -S -a1 -As -d1 -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -S -a1',
  '-q2 -s2 -s3+s -r3 -s4 -r4 -s5+s -r5+s -s6 -s7+s -r8 -s9+s -Qr -Mh,d,r -a1 -At,r -s2+s -r2 -d2 -s3 -r3 -r4 -s4 -d5+s -r5 -d6 -s7+s -d7 -a1',
  '-o1 -d1 -a1 -At,r,s -s1 -d1 -s5+s -s10+s -s15+s -s20+s -r1+s -S -a1 -As -s1 -d1 -s5+s -s10+s -s15+s -s20+s -S -a1',
  '-n {sni} -Qr -f-204 -s1:5+sm -a1 -As -d1 -s3+s -s5+s -q7 -a1 -As -o2 -f-43 -a1 -As -r5 -Mh -s1:5+s -s3:7+sm -a1',
  '-n {sni} -Qr -f-205 -a1 -As -s1:3+sm -a1 -As -s5:8+sm -a1 -As -d3 -q7 -o2 -f-43 -f-85 -f-165 -r5 -Mh -a1',
  '-d1+s -s50+s -a1 -As -f20 -r2+s -a1 -At -d2 -s1+s -s5+s -s10+s -s15+s -s25+s -s35+s -s50+s -s60+s -a1',
  '-o1 -a1 -At,r,s -f-1 -a1 -At,r,s -d1:11+sm -S -a1 -At,r,s -n {sni} -Qr -f1 -d1:11+sm -s1:11+sm -S -a1',
  '-d1 -s1 -q1 -a1 -Ar -s5 -o1+s -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -a1',
  '-f1+nme -t6 -a1 -As -n {sni} -Qr -s1:6+sm -a1 -As -s5:12+sm -a1 -As -d3 -q7 -r6 -Mh -a1',
  '-d1 -s1+s -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -a1',
  '-d1 -s1+s -d1+s -s3+s -d6+s -s12+s -d14+s -s20+s -s24+s -s30+s -a1',
  '-o1 -a1 -At,r,s -f-1 -a1 -Ar,s -o1 -a1 -At -r1+s -f-1 -t6 -a1',
  '-d1 -s1+s -s3+s -s6+s -s9+s -s12+s -s15+s -s20+s -s30+s -a1',
  '-d1 -d3+s -s6+s -d6+s -s7+s -d8+s -s10+s -a1 -t12 -At,s -r3',
  '-f1 -t5 -n {sni} -q3+h -Qr -f2 -q1 -r1+s -t15 -q1 -o2 -a1',
  '-n {sni} -d2:5:2+h -f-3 -r2+sm -o2 -o50+s -r2+s -f-4 -a1',
  '-f-1 -Qr -s1+sm -d3+s -s5+sm -o2 -a1 -As -r1+s -d8+s -a1',
  '-r-1+s -o20+sm -s3:7+sm -d5:3+sm -f300+s -Qr -f-1 -a1',
  '-o2 -O4 -s1 -q1 -a1 -Ar -s5 -o1+s -f1+s -r20+s -a1',
  '-o1 -r-5+se -a1 -At,r,s -d1 -n {sni} -Qr -f-1 -a1',
  '--fake -1 --ttl 8 --split 1+s --disorder 3+s -a1',
  '-n {sni} -Qr -f6+nr -d2 -d11 -f9+hm -o3 -t7 -a1',
  '-r5+s -s25+s -a1 -At,r,s -s50 -r5+s -s50+s -a1',
  '-d1 -d3+s -s6+s -d9+s -s20+s -d25+s -s30+s -a1',
  '-d9+s -q20+s -s25+s -t5 -a1 -At,r,s -r1+h -a1',
  '-q1+s -s29+s -s30+s -s14+s -o5+s -f-1 -S -a1',
  '-d1 -s1+s -r1+s -e1 -m1 -o1+s -f-1 -t2 -a1',
  '-d1 -o1 -a1 -Ar -o1 -a1 -At -f-1 -r1+s -a1',
  '-d1 -s4 -d8 -s1+s -d5+s -s10+s -d20+s -a1',
  '-f-1 -n {sni} -Qr -s2+s -r3 -o20 -t4 -a1',
  '-n {sni} -Qr -d5+sm -f3+sm -o2 -t4 -a1',
  '-o1 -a1 -Ar -q1 -a1 -At -f-1 -r1+s -a1',
  '-q1 -a1 -Ar -o1 -a1 -At -f-1 -r1+s -a1',
  '-s4+sn -r9+s -Qr -n {sni} -S -a1',
  '-o1 -d1 -r1+s -S -s1+s -d3+s -a1',
  '-q1+s -s29+s -o5+s -f-1 -S -a1',
  '-n {sni} -Qr -m2 -f-1 -d7 -a1',
  '-d1 -s1+s -r1+s -f-1 -t8 -a1',
  '-o1 -a1 -An -f1+nme -t6 -a1',
  '-n {sni} -Qr -f-1 -r1+s -a1',
  '-n {sni} -Qr -d1:3 -f-1 -a1',
  '-s1 -d3+s -a1 -At -r1+s -a1',
  '-f-1 -t8 -n {sni} -s1+s -a1',
  '-n {sni} -Qr -d1 -f-1 -a1',
  '-f64+se -n {sni} -t5 -a1',
  '-o1 -a1 -At,r,s -d1 -a1',
  '-d1+s -o2 -s5 -r5 -a1',
  '-r8 -o2 -s7 -q4+s -a1',
  '-o1 -f-1 -r-5+se -a1',
  '-d6+s -q4+hm -o2 -a1',
  '-s5+s -s35+s -m4 -a1',
  '-f-1+sm -t7 -m2 -a1',
  '-o1 -r-5+se -a1',
  '-o1+s -d3+s -a1',
  '-o1 -s4 -s6 -a1',
  '-q1 -r25+s -a1',
  '-d1 -s3+s -a1',
  '-o3 -d7 -a1',
  '-d7 -s2 -a1',
];

const desyncTestFakeSni = 'google.com';

/// The distinct union of the selected site lists, ByeByeDPI-style.
List<String> desyncTestSitesFor(List<String> ids) {
  return {
    for (final list in desyncTestSiteLists)
      if (ids.contains(list.id)) ...list.domains,
  }.toList();
}

class DesyncTestOutcome {
  const DesyncTestOutcome({
    required this.text,
    required this.failedSites,
    required this.total,
    required this.engineUp,
  });

  final String text;

  final List<String> failedSites;

  final int total;

  /// False when the line could not even keep the listener alive; the score
  /// means nothing then.
  final bool engineUp;

  int get passed => engineUp ? total - failedSites.length : 0;
}

List<String> desyncTestArgs(String line) {
  return desyncArgsFromText(line.replaceAll('{sni}', desyncTestFakeSni));
}

Future<bool> desyncEngineAlive(int port) => _listenerAlive(port);

/// Runs every preset through the live engine. Applying arguments is delegated
/// so the caller owns the config; the runner owns the engine's timing.
class DesyncStrategyTester {
  DesyncStrategyTester({
    required this.port,
    required this.applyArgs,
  });

  final int port;

  final Future<void> Function(List<String> args) applyArgs;

  var _stopped = false;

  void stop() => _stopped = true;

  Future<List<DesyncTestOutcome>> run({
    required List<String> originalArgs,
    required List<String> sites,
    void Function(int index, DesyncTestOutcome outcome)? onProgress,
  }) async {
    final outcomes = <DesyncTestOutcome>[];
    var engineUp = true;
    var running = originalArgs;
    try {
      for (var i = 0; i < desyncTestPresets.length && !_stopped; i++) {
        final line = desyncTestPresets[i];
        final args = desyncTestArgs(line);
        if (!listEquals(args, running)) {
          if (engineUp) {
            final sentinel = await _connect(port);
            await applyArgs(args);
            if (sentinel == null) {
              engineUp = false;
            } else {
              // The old engine's death arrives before the new listener does;
              // a sentinel that survives means the options never reached it.
              final swapped = await _awaitSwap(sentinel);
              if (!swapped && await _listenerAlive(port)) {
                break;
              }
              engineUp = swapped && await _awaitListener();
            }
            if (engineUp) {
              running = args;
            }
          } else {
            await applyArgs(args);
            engineUp = await _awaitListener();
            if (engineUp) {
              running = args;
            }
          }
        }
        if (!engineUp) {
          final outcome = DesyncTestOutcome(
            text: line,
            failedSites: const [],
            total: sites.length,
            engineUp: false,
          );
          outcomes.add(outcome);
          onProgress?.call(i, outcome);
          continue;
        }
        final outcome = await _testStrategy(line, sites);
        outcomes.add(outcome);
        onProgress?.call(i, outcome);
      }
    } finally {
      if (!listEquals(running, originalArgs)) {
        await applyArgs(originalArgs);
      }
    }
    return outcomes;
  }

  Future<DesyncTestOutcome> _testStrategy(String line, List<String> sites) async {
    final failed = <String>[];
    final queue = List<String>.of(sites);
    await Future.wait(
      List.generate(
        queue.length < _siteConcurrency ? queue.length : _siteConcurrency,
        (_) async {
          while (true) {
            final host = queue.isEmpty ? null : queue.removeAt(0);
            if (host == null) return;
            if (!await desyncCheckSite(host, port)) {
              failed.add(host);
            }
          }
        },
      ),
    );
    return DesyncTestOutcome(
      text: line,
      failedSites: failed,
      total: sites.length,
      engineUp: true,
    );
  }

  Future<bool> _awaitSwap(Socket sentinel) async {
    try {
      await sentinel.drain<void>().timeout(_swapTimeout);
    } on Exception {
      sentinel.destroy();
      return false;
    }
    sentinel.destroy();
    return true;
  }

  Future<bool> _awaitListener() async {
    final deadline = DateTime.now().add(_swapTimeout);
    while (DateTime.now().isBefore(deadline)) {
      if (await _listenerAlive(port)) return true;
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    return false;
  }
}

/// A full check is a SOCKS5 CONNECT, a TLS handshake whose ClientHello is the
/// censored payload, and any HTTP status line back.
Future<bool> desyncCheckSite(String host, int port) async {
  final buffer = _SocketBuffer();
  Socket? socket;
  SecureSocket? secure;
  try {
    socket = await _connect(port);
    if (socket == null) return false;
    socket.listen(
      buffer.add,
      onDone: buffer.close,
      onError: (Object _) => buffer.close(),
    );
    socket.add([5, 1, 0]);
    final greeting = await buffer.take(2, _stepTimeout);
    if (greeting.length < 2 || greeting[0] != 5) return false;
    final name = host.codeUnits;
    socket.add(<int>[
      5, 1, 0, 3, name.length, ...name, 443 >> 8, 443 & 0xff,
    ]);
    final reply = await buffer.take(10, _dialTimeout);
    if (reply.length < 10 || reply[0] != 5 || reply[1] != 0) return false;
    secure = await SecureSocket.secure(
      socket,
      host: host,
    ).timeout(_stepTimeout);
    socket = null;
    secure.add(
      'GET / HTTP/1.1\r\nHost: $host\r\nConnection: close\r\n\r\n'.codeUnits,
    );
    final response = await secure.first.timeout(_stepTimeout);
    return String.fromCharCodes(response.take(12)).startsWith('HTTP/');
  } on Exception {
    return false;
  } finally {
    secure?.destroy();
    socket?.destroy();
  }
}

const _siteConcurrency = 20;

const _stepTimeout = Duration(seconds: 6);

const _dialTimeout = Duration(seconds: 10);

const _swapTimeout = Duration(seconds: 12);

Future<Socket?> _connect(int port) async {
  try {
    return await Socket.connect(
      InternetAddress.loopbackIPv4,
      port,
      timeout: const Duration(seconds: 4),
    );
  } on Exception {
    return null;
  }
}

Future<bool> _listenerAlive(int port) async {
  final socket = await _connect(port);
  socket?.destroy();
  return socket != null;
}

class _SocketBuffer {
  final _data = <int>[];
  final _waiters = <Completer<void>>[];
  var _closed = false;

  void add(List<int> bytes) {
    _data.addAll(bytes);
    _resolve();
  }

  void close() {
    _closed = true;
    _resolve();
  }

  void _resolve() {
    while (_waiters.isNotEmpty) {
      _waiters.removeLast().complete();
    }
  }

  Future<Uint8List> take(int count, Duration timeout) async {
    while (_data.length < count && !_closed) {
      final completer = Completer<void>();
      _waiters.add(completer);
      await completer.future.timeout(timeout);
    }
    final taken = Uint8List.fromList(_data.take(count).toList());
    _data.removeRange(0, taken.length);
    return taken;
  }
}
