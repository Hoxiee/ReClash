import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

const probeTimeout = Duration(milliseconds: 800);

/// Whether something accepts a TCP connection on [host]:[port].
Future<bool> tcpReachable(String host, int port) async {
  try {
    final socket = await Socket.connect(host, port, timeout: probeTimeout);
    socket.destroy();
    return true;
  } on Object {
    return false;
  }
}

/// Whether [server] answers an `example.com` A query over UDP.
Future<bool> dnsAnswers(String server, Duration timeout) async {
  final address = InternetAddress.tryParse(server);
  if (address == null) return false;
  RawDatagramSocket? socket;
  try {
    socket = await RawDatagramSocket.bind(
      address.type == InternetAddressType.IPv6
          ? InternetAddress.anyIPv6
          : InternetAddress.anyIPv4,
      0,
    );
    final done = Completer<bool>();
    final subscription = socket.listen((event) {
      if (event != RawSocketEvent.read || done.isCompleted) return;
      final reply = socket?.receive();
      if (reply != null &&
          reply.data.length >= 12 &&
          reply.data[0] == 0x52 &&
          reply.data[1] == 0x43 &&
          reply.data[2] & 0x80 != 0) {
        done.complete(true);
      }
    });
    socket.send(_query, address, 53);
    final answered = await done.future.timeout(timeout, onTimeout: () => false);
    await subscription.cancel();
    return answered;
  } on Object {
    return false;
  } finally {
    socket?.close();
  }
}

final Uint8List _query = Uint8List.fromList([
  0x52, 0x43, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, //
  7, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, //
  3, 0x63, 0x6f, 0x6d, 0,
  0x00, 0x01, 0x00, 0x01,
]);
