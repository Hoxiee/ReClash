import 'dart:io';

typedef SpeedTestClientFactory = HttpClient Function();
typedef SpeedTestByteCallback = void Function(int count);

abstract interface class SpeedTestBackend {
  String get id;
  String get name;
  Uri get website;
  Uri get measurementUri;

  /// Parallel connections per direction the service needs to fill a link.
  int get streams;

  SpeedTestSession open(SpeedTestClientFactory createClient);
}

abstract interface class SpeedTestSession {
  Future<double> latency();
  Future<void> download(
    int bytes,
    SpeedTestByteCallback onBytes, {
    int lane = 0,
  });
  Future<void> upload(int bytes, SpeedTestByteCallback onBytes, {int lane = 0});
  void abortTransfer();
  void close();
}
