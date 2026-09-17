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

enum DesyncSiteStatus { passed, blocked, engineDown }

class DesyncTestOutcome {
  const DesyncTestOutcome({
    required this.text,
    required this.failedSites,
    required this.passedOnRetry,
    required this.total,
    required this.engineUp,
    this.elapsed = Duration.zero,
  });

  final Duration elapsed;

  final String text;

  final List<String> failedSites;

  final int passedOnRetry;

  final int total;

  /// False when the line could not even keep the listener alive; the score
  /// means nothing then.
  final bool engineUp;

  int get passed => engineUp ? total - failedSites.length : 0;

  /// First-try passes weigh full, retry saves weigh half: a strategy that
  /// opens a site every time outranks one that needs a second roll.
  double get score =>
      engineUp ? (passed - passedOnRetry + passedOnRetry / 2) / total : 0;
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
    this.checkSite = desyncCheckSite,
  });

  final int port;

  final Future<void> Function(List<String> args) applyArgs;

  final Future<DesyncSiteStatus> Function(String host, int port) checkSite;

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
            if (sentinel == null) {
              engineUp = false;
            } else {
              await applyArgs(args);
              var swapped = await _awaitSwap(sentinel);
              if (!swapped && await _listenerAlive(port)) {
                // A draining branch bails its own start; push the options
                // once more after its drain window before giving up.
                await Future<void>.delayed(_drainWindow);
                await applyArgs(args);
                swapped = await _awaitSwap(sentinel);
              }
              sentinel.destroy();
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
        final outcome = engineUp
            ? await _testStrategy(line, sites)
            : DesyncTestOutcome(
                text: line,
                failedSites: const [],
                passedOnRetry: 0,
                total: sites.length,
                engineUp: false,
              );
        outcomes.add(outcome);
        onProgress?.call(i, outcome);
      }
    } finally {
      if (!listEquals(running, originalArgs)) {
        await _restore(originalArgs);
      }
    }
    return outcomes;
  }

  Future<void> _restore(List<String> originalArgs) async {
    if (!await _listenerAlive(port)) {
      await applyArgs(originalArgs);
      return;
    }
    final sentinel = await _connect(port);
    await applyArgs(originalArgs);
    if (sentinel != null) {
      await _awaitSwap(sentinel);
      sentinel.destroy();
    }
  }

  Future<DesyncTestOutcome> _testStrategy(
    String line,
    List<String> sites,
  ) async {
    final clock = Stopwatch()..start();
    final failed = <String>[];
    var passedOnRetry = 0;
    var engineUp = true;
    var consecutiveDown = 0;
    final queue = List<String>.of(sites);
    await Future.wait(
      List.generate(
        queue.length < _siteConcurrency ? queue.length : _siteConcurrency,
        (_) async {
          while (!_stopped) {
            final host = queue.isEmpty ? null : queue.removeAt(0);
            if (host == null || !engineUp) return;
            var passed = false;
            var onRetry = false;
            for (
              var attempt = 0;
              attempt < _siteAttempts && !_stopped;
              attempt++
            ) {
              final status = await checkSite(host, port);
              if (status == DesyncSiteStatus.engineDown) {
                if (++consecutiveDown >= _downAbort) {
                  engineUp = false;
                  queue.clear();
                  break;
                }
                continue;
              }
              consecutiveDown = 0;
              if (status == DesyncSiteStatus.passed) {
                passed = true;
                onRetry = attempt > 0;
                break;
              }
            }
            if (_stopped) return;
            if (!passed) {
              failed.add(host);
            } else if (onRetry) {
              passedOnRetry++;
            }
          }
        },
      ),
    );
    return DesyncTestOutcome(
      text: line,
      failedSites: failed,
      passedOnRetry: passedOnRetry,
      total: sites.length,
      engineUp: engineUp,
      elapsed: clock.elapsed,
    );
  }

  // A sentinel that survives the swap window means the options never
  // reached the module at all.
  Future<bool> _awaitSwap(Socket sentinel) async {
    try {
      await sentinel.drain<void>().timeout(_swapTimeout);
      return true;
    } on Exception {
      return false;
    }
  }

  Future<bool> _awaitListener() async {
    final deadline = DateTime.now().add(_listenerTimeout);
    while (DateTime.now().isBefore(deadline)) {
      if (await _listenerAlive(port)) return true;
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    return false;
  }
}

const _siteAttempts = 2;

const _siteConcurrency = 20;

const _downAbort = 5;

const _stepTimeout = Duration(seconds: 6);

const _dialTimeout = Duration(seconds: 10);

const _swapTimeout = Duration(seconds: 12);

// The native side can spend 2s joining the old branch and 8s waiting out a
// drain before the new listener binds.
const _listenerTimeout = Duration(seconds: 15);

const _drainWindow = Duration(seconds: 9);

const _bodyCap = 256 * 1024;

const _headerCap = 16 * 1024;

const _userAgent =
    'Mozilla/5.0 (Linux; Android 11; Redmi) AppleWebKit/537.36'
    ' (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36';

/// SOCKS5 CONNECT, a TLS handshake (the censored payload), then a sub-400
/// status line whose body is not truncated below its declared length.
Future<DesyncSiteStatus> desyncCheckSite(String host, int port) async {
  final buffer = _SocketBuffer();
  Socket? socket;
  SecureSocket? secure;
  try {
    socket = await _connect(port);
    if (socket == null) return DesyncSiteStatus.engineDown;
    socket.listen(
      buffer.add,
      onDone: buffer.close,
      onError: (Object _) => buffer.close(),
    );
    socket.add([5, 1, 0]);
    final greeting = await buffer.take(2, _stepTimeout);
    if (greeting.length < 2 || greeting[0] != 5 || greeting[1] != 0) {
      return DesyncSiteStatus.engineDown;
    }
    final name = host.codeUnits;
    socket.add(<int>[5, 1, 0, 3, name.length, ...name, 443 >> 8, 443 & 0xff]);
    final head = await buffer.take(4, _dialTimeout);
    if (head.length < 4 || head[0] != 5) {
      return DesyncSiteStatus.engineDown;
    }
    switch (head[3]) {
      case 1:
        if ((await buffer.take(6, _stepTimeout)).length < 6) {
          return DesyncSiteStatus.blocked;
        }
      case 3:
        final length = await buffer.take(1, _stepTimeout);
        if (length.isEmpty) return DesyncSiteStatus.blocked;
        final rest = await buffer.take(length[0] + 2, _stepTimeout);
        if (rest.length < length[0] + 2) {
          return DesyncSiteStatus.blocked;
        }
      case 4:
        if ((await buffer.take(20, _stepTimeout)).length < 20) {
          return DesyncSiteStatus.blocked;
        }
      default:
        return DesyncSiteStatus.blocked;
    }
    if (head[1] != 0) return DesyncSiteStatus.blocked;
    final response = _SocketBuffer();
    secure = await SecureSocket.secure(
      socket,
      host: host,
      supportedProtocols: const ['http/1.1'],
    ).timeout(_stepTimeout);
    socket = null;
    secure.listen(
      response.add,
      onDone: response.close,
      onError: (Object _) => response.close(),
    );
    secure.add(
      'GET / HTTP/1.1\r\n'
              'Host: $host\r\n'
              'User-Agent: $_userAgent\r\n'
              'Accept: */*\r\n'
              'Connection: close\r\n'
              '\r\n'
          .codeUnits,
    );
    final header = await response.takeUntil(_crlf2, _headerCap, _stepTimeout);
    if (header == null) return DesyncSiteStatus.blocked;
    final text = String.fromCharCodes(header);
    final code = int.tryParse(
      text.split(' ').elementAtOrNull(1)?.split('\r\n').first ?? '',
    );
    if (code == null || code >= 400) return DesyncSiteStatus.blocked;
    final declared = _contentLength(text);
    if (declared <= 0) return DesyncSiteStatus.passed;
    final target = declared > _bodyCap ? _bodyCap : declared;
    final bodyClock = Stopwatch()..start();
    while (response.length < target && !response.isClosed) {
      await response.wait(_remainingTimeout(bodyClock, _stepTimeout));
    }
    return response.length >= target
        ? DesyncSiteStatus.passed
        : DesyncSiteStatus.blocked;
  } on Exception {
    return DesyncSiteStatus.blocked;
  } finally {
    secure?.destroy();
    socket?.destroy();
  }
}

const _crlf2 = <int>[13, 10, 13, 10];

int _contentLength(String header) {
  for (final line in header.split('\r\n')) {
    final index = line.indexOf(':');
    if (index < 0) continue;
    if (line.substring(0, index).trim().toLowerCase() == 'content-length') {
      return int.tryParse(line.substring(index + 1).trim()) ?? 0;
    }
  }
  return 0;
}

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

Duration _remainingTimeout(Stopwatch clock, Duration timeout) {
  final remaining = timeout - clock.elapsed;
  if (remaining <= Duration.zero) {
    throw TimeoutException('Socket step timed out', timeout);
  }
  return remaining;
}

class _SocketBuffer {
  final _data = <int>[];
  final _waiters = <Completer<void>>[];
  var _closed = false;

  int get length => _data.length;

  bool get isClosed => _closed;

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

  Future<void> wait(Duration timeout) {
    if (_closed) return Future.value();
    final completer = Completer<void>();
    _waiters.add(completer);
    return completer.future.timeout(timeout).whenComplete(() {
      _waiters.remove(completer);
    });
  }

  Future<Uint8List> take(int count, Duration timeout) async {
    final clock = Stopwatch()..start();
    while (_data.length < count && !_closed) {
      await wait(_remainingTimeout(clock, timeout));
    }
    final taken = Uint8List.fromList(_data.take(count).toList());
    _data.removeRange(0, taken.length);
    return taken;
  }

  /// Reads up to [cap] bytes until [pattern]; null on close or timeout.
  Future<Uint8List?> takeUntil(
    List<int> pattern,
    int cap,
    Duration timeout,
  ) async {
    final clock = Stopwatch()..start();
    while (!_closed) {
      final index = _indexOf(pattern);
      if (index >= 0) {
        return Uint8List.fromList(_data.take(index + pattern.length).toList());
      }
      if (_data.length > cap) return null;
      await wait(_remainingTimeout(clock, timeout));
    }
    return null;
  }

  int _indexOf(List<int> pattern) {
    for (var i = 0; i + pattern.length <= _data.length; i++) {
      var matched = true;
      for (var j = 0; j < pattern.length; j++) {
        if (_data[i + j] != pattern[j]) {
          matched = false;
          break;
        }
      }
      if (matched) return i;
    }
    return -1;
  }
}
