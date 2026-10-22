import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const rcxLinkMaxBytes = 64 * 1024;
const _inflateStep = 512;

class RcxPayloadTooLarge extends FormatException {
  const RcxPayloadTooLarge() : super('Routing profile is too large');
}

String encodeRcxLink(String yaml) {
  final raw = ZLibEncoder(
    raw: true,
    level: 9,
  ).convert(Uint8List.fromList(utf8.encode(yaml)));
  return Uri(
    scheme: 'reclash',
    host: 'routing',
    queryParameters: {'p': base64Url.encode(raw).replaceAll('=', '')},
  ).toString();
}

String decodeRcxPayload(String p) {
  final Uint8List compressed;
  try {
    compressed = base64Url.decode(base64Url.normalize(p.trim()));
  } on FormatException {
    throw const FormatException('Routing link payload is not base64url');
  }
  if (compressed.isEmpty) {
    throw const FormatException('Routing link payload is empty');
  }
  final sink = _LimitedSink(rcxLinkMaxBytes);
  try {
    final input = ZLibDecoder(raw: true).startChunkedConversion(sink);
    for (var i = 0; i < compressed.length; i += _inflateStep) {
      input.add(
        Uint8List.sublistView(
          compressed,
          i,
          i + _inflateStep > compressed.length
              ? compressed.length
              : i + _inflateStep,
        ),
      );
    }
    input.close();
  } on FormatException {
    rethrow;
  } on Object {
    throw const FormatException('Routing link payload is not valid deflate');
  }
  final bytes = sink.takeBytes();
  if (bytes.isEmpty) {
    throw const FormatException('Routing link payload is empty');
  }
  return utf8.decode(bytes);
}

class _LimitedSink extends ByteConversionSinkBase {
  _LimitedSink(this.limit);

  final int limit;
  final _bytes = BytesBuilder(copy: false);

  Uint8List takeBytes() => _bytes.takeBytes();

  @override
  void add(List<int> chunk) {
    if (_bytes.length + chunk.length > limit) {
      throw const RcxPayloadTooLarge();
    }
    _bytes.add(chunk);
  }

  @override
  void close() {}
}
