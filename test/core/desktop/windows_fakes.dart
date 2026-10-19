import 'dart:async';

import 'package:reclash/core/desktop/windows_launcher.dart';

final class FakeWindowsCorePort implements WindowsCorePort {
  final events = StreamController<List<String>>.broadcast();
  final launched = Completer<void>();
  final List<String> calls = [];
  bool elevated = false;
  bool active = false;
  bool cancelConfirmed = false;
  bool stopConfirmed = true;
  Object? launchError;
  Object? elevationError;
  Object? cancelError;
  Completer<bool>? stopGate;
  int launches = 0;
  int stops = 0;
  String? home;
  String? hash;

  @override
  Future<bool> isElevated() async {
    final error = elevationError;
    if (error != null) {
      Error.throwWithStackTrace(error, StackTrace.current);
    }
    return elevated;
  }

  @override
  void prepare(String sessionId) {
    if (active) throw const WindowsLaunchException('windows_launch_pending');
    active = true;
    calls.add('prepare');
  }

  @override
  Stream<List<String>> launch({
    required String sessionId,
    required String address,
    required String homeDir,
    required String coreSha256,
  }) {
    calls.add('launch');
    launches++;
    home = homeDir;
    hash = coreSha256;
    if (!launched.isCompleted) launched.complete();
    final error = launchError;
    if (error != null) {
      Error.throwWithStackTrace(error, StackTrace.current);
    }
    return events.stream;
  }

  void emit(String kind, [String value = '42']) {
    if (kind == 'exited') active = false;
    events.add([kind, value]);
  }

  @override
  bool cancel(String sessionId) {
    calls.add('cancel');
    final error = cancelError;
    if (error != null) {
      Error.throwWithStackTrace(error, StackTrace.current);
    }
    if (cancelConfirmed) active = false;
    return !active;
  }

  @override
  Future<bool> stop(String sessionId, Duration timeout) async {
    stops++;
    final confirmed = await stopGate?.future ?? stopConfirmed;
    if (confirmed) active = false;
    return confirmed;
  }
}

WindowsCoreLauncher windowsLauncher(FakeWindowsCorePort port) {
  return WindowsCoreLauncher(
    port: port,
    readCoreSha256: () async => 'a' * 64,
    homeDirectory: () async => r'C:\Users\original\ReClash',
  );
}
