import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;

import '../metadata/metadata.dart';
import '../protocol/codec.dart';
import '../protocol/registry.dart';
import 'header_policy.dart';

enum SubscriptionFailure {
  cancelled,
  timeout,
  transport,
  tls,
  unauthorized,
  deviceRequired,
  deviceLimit,
  rateLimited,
  http,
  redirect,
  oversized,
  invalid,
  empty,
  superseded,
}

class SubscriptionException implements Exception {
  const SubscriptionException(this.failure, {this.status});
  final SubscriptionFailure failure;
  final int? status;

  @override
  String toString() =>
      'Subscription ${failure.name}${status == null ? '' : ' ($status)'}';
}

class SubscriptionCancellation {
  final _cancelled = Completer<void>();
  bool get cancelled => _cancelled.isCompleted;
  Future<void> get whenCancelled => _cancelled.future;
  void cancel() {
    if (!_cancelled.isCompleted) _cancelled.complete();
  }
}

class SubscriptionResponse {
  const SubscriptionResponse({
    required this.bytes,
    required this.headers,
    required this.status,
    required this.uri,
    this.protected = false,
  });
  final Uint8List bytes;
  final Map<String, List<String>> headers;
  final int status;
  final Uri uri;
  final bool protected;
}

typedef ProtectedSubscriptionFetcher =
    Future<SubscriptionResponse> Function(
      Uri uri,
      Map<String, String> headers,
      Duration timeout,
      SubscriptionCancellation cancellation,
    );

class SubscriptionTransport {
  SubscriptionTransport({
    HttpClient Function()? createClient,
    this.protectedFetcher,
  }) : _createClient =
           createClient ??
           (() =>
               HttpOverrides.current?.createHttpClient(null) ?? HttpClient());
  final HttpClient Function() _createClient;
  final ProtectedSubscriptionFetcher? protectedFetcher;

  Future<SubscriptionResponse> fetch(
    Uri source, {
    Map<String, String> headers = const {},
    Duration timeout = const Duration(seconds: 30),
    SubscriptionCancellation? cancellation,
  }) async {
    final client = _createClient();
    client.autoUncompress = false;
    client.connectionTimeout = timeout;
    final localCancellation = cancellation ?? SubscriptionCancellation();
    var finished = false;
    var receivedResponse = false;
    unawaited(
      localCancellation.whenCancelled.then((_) {
        if (!finished) client.close(force: true);
      }),
    );
    final timer = Timer(timeout, () => client.close(force: true));
    final stopwatch = Stopwatch()..start();
    Future<SubscriptionResponse> direct() async {
      try {
        return await _fetch(
          client,
          source,
          headers,
          localCancellation,
          onResponse: () => receivedResponse = true,
        ).timeout(
          timeout,
          onTimeout: () =>
              throw const SubscriptionException(SubscriptionFailure.timeout),
        );
      } on SubscriptionException {
        rethrow;
      } on HandshakeException {
        throw const SubscriptionException(SubscriptionFailure.tls);
      } on SubscriptionHeaderException {
        throw const SubscriptionException(SubscriptionFailure.invalid);
      } on FormatException {
        throw const SubscriptionException(SubscriptionFailure.invalid);
      } on Object {
        if (localCancellation.cancelled) {
          throw const SubscriptionException(SubscriptionFailure.cancelled);
        }
        if (stopwatch.elapsed >= timeout) {
          throw const SubscriptionException(SubscriptionFailure.timeout);
        }
        throw const SubscriptionException(SubscriptionFailure.transport);
      }
    }

    try {
      if (localCancellation.cancelled) {
        throw const SubscriptionException(SubscriptionFailure.cancelled);
      }
      try {
        return await direct();
      } on SubscriptionException catch (error) {
        final protected = protectedFetcher;
        if (error.failure != SubscriptionFailure.transport ||
            receivedResponse ||
            protected == null) {
          rethrow;
        }
        finished = true;
        timer.cancel();
        client.close(force: true);
        final remaining = timeout - stopwatch.elapsed;
        if (remaining <= Duration.zero) {
          throw const SubscriptionException(SubscriptionFailure.timeout);
        }
        final response = await Future.any([
          protected(
            source,
            validateSubscriptionHeaders(headers, allowManaged: true),
            remaining,
            localCancellation,
          ),
          localCancellation.whenCancelled.then<SubscriptionResponse>((_) {
            throw const SubscriptionException(SubscriptionFailure.cancelled);
          }),
        ]).timeout(remaining);
        if (response.bytes.length > subscriptionWireLimit) {
          throw const SubscriptionException(SubscriptionFailure.oversized);
        }
        final device = readSubscriptionMetadata(response.headers).deviceStatus;
        if (device == SubscriptionDeviceStatus.required) {
          throw SubscriptionException(
            SubscriptionFailure.deviceRequired,
            status: response.status,
          );
        }
        if (device == SubscriptionDeviceStatus.limitReached) {
          throw SubscriptionException(
            SubscriptionFailure.deviceLimit,
            status: response.status,
          );
        }
        if (response.status == 401 || response.status == 403) {
          throw SubscriptionException(
            SubscriptionFailure.unauthorized,
            status: response.status,
          );
        }
        if (response.status == 429) {
          throw SubscriptionException(
            SubscriptionFailure.rateLimited,
            status: response.status,
          );
        }
        if (response.status < 200 || response.status >= 300) {
          throw SubscriptionException(
            SubscriptionFailure.http,
            status: response.status,
          );
        }
        final bytes = await decompressSubscriptionPayload(
          response.bytes,
          encoding: _contentEncoding(response.headers),
        );
        if (localCancellation.cancelled) {
          throw const SubscriptionException(SubscriptionFailure.cancelled);
        }
        if (bytes.isEmpty) {
          throw const SubscriptionException(SubscriptionFailure.empty);
        }
        return SubscriptionResponse(
          bytes: bytes,
          headers: response.headers,
          status: response.status,
          uri: response.uri,
          protected: true,
        );
      }
    } on SubscriptionException {
      rethrow;
    } on HandshakeException {
      throw const SubscriptionException(SubscriptionFailure.tls);
    } on TimeoutException {
      throw const SubscriptionException(SubscriptionFailure.timeout);
    } on Object {
      if (localCancellation.cancelled) {
        throw const SubscriptionException(SubscriptionFailure.cancelled);
      }
      if (stopwatch.elapsed >= timeout) {
        throw const SubscriptionException(SubscriptionFailure.timeout);
      }
      throw const SubscriptionException(SubscriptionFailure.transport);
    } finally {
      finished = true;
      timer.cancel();
      client.close(force: true);
    }
  }

  Future<SubscriptionResponse> _fetch(
    HttpClient client,
    Uri source,
    Map<String, String> fields,
    SubscriptionCancellation cancellation, {
    required void Function() onResponse,
  }) async {
    var uri = source;
    var headers = Map<String, String>.from(
      validateSubscriptionHeaders(fields, allowManaged: true),
    );
    if (uri.userInfo.isNotEmpty) {
      final credentials = uri.userInfo
          .split(':')
          .map(Uri.decodeComponent)
          .join(':');
      headers.putIfAbsent(
        'Authorization',
        () => 'Basic ${base64.encode(utf8.encode(credentials))}',
      );
      uri = uri.replace(userInfo: '');
    }
    final seen = <String>{};
    for (var hop = 0; hop <= 5; hop++) {
      if (cancellation.cancelled) {
        throw const SubscriptionException(SubscriptionFailure.cancelled);
      }
      if ((uri.scheme != 'https' && uri.scheme != 'http') ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty ||
          !seen.add(uri.toString())) {
        throw const SubscriptionException(SubscriptionFailure.redirect);
      }
      final request = await client.getUrl(uri);
      request.followRedirects = false;
      request.maxRedirects = 0;
      request.headers.set(HttpHeaders.acceptEncodingHeader, 'gzip, deflate');
      for (final MapEntry(:key, :value) in headers.entries) {
        request.headers.set(key, value);
      }
      final response = await request.close();
      onResponse();
      final responseHeaders = <String, List<String>>{};
      var size = 0;
      response.headers.forEach((name, values) {
        for (final value in values) {
          final length = utf8.encode(value).length;
          size += name.length + length + 4;
          if (length > subscriptionHeaderLimit ||
              size > subscriptionHeadersLimit) {
            throw const SubscriptionException(SubscriptionFailure.oversized);
          }
        }
        responseHeaders[name.toLowerCase()] = List.unmodifiable(values);
      });
      if (const {301, 302, 303, 307, 308}.contains(response.statusCode)) {
        final locations = responseHeaders['location'];
        if (hop == 5 || locations == null || locations.length != 1) {
          throw const SubscriptionException(SubscriptionFailure.redirect);
        }
        final next = uri.resolve(locations.single);
        if (uri.scheme == 'https' && next.scheme != 'https') {
          throw const SubscriptionException(SubscriptionFailure.redirect);
        }
        headers = redirectSubscriptionHeaders(headers, uri, next);
        uri = next;
        continue;
      }
      final status = response.statusCode;
      final device = readSubscriptionMetadata(responseHeaders).deviceStatus;
      if (device == SubscriptionDeviceStatus.required) {
        throw SubscriptionException(
          SubscriptionFailure.deviceRequired,
          status: status,
        );
      }
      if (device == SubscriptionDeviceStatus.limitReached) {
        throw SubscriptionException(
          SubscriptionFailure.deviceLimit,
          status: status,
        );
      }
      if (status == 401 || status == 403) {
        throw SubscriptionException(
          SubscriptionFailure.unauthorized,
          status: status,
        );
      }
      if (status == 429) {
        throw SubscriptionException(
          SubscriptionFailure.rateLimited,
          status: status,
        );
      }
      if (status < 200 || status >= 300) {
        throw SubscriptionException(SubscriptionFailure.http, status: status);
      }
      if (response.contentLength > subscriptionWireLimit) {
        throw const SubscriptionException(SubscriptionFailure.oversized);
      }
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response) {
        if (cancellation.cancelled) {
          throw const SubscriptionException(SubscriptionFailure.cancelled);
        }
        if (builder.length + chunk.length > subscriptionWireLimit) {
          throw const SubscriptionException(SubscriptionFailure.oversized);
        }
        builder.add(chunk);
      }
      final bytes = await decompressSubscriptionPayload(
        builder.takeBytes(),
        encoding: _contentEncoding(responseHeaders),
      );
      if (cancellation.cancelled) {
        throw const SubscriptionException(SubscriptionFailure.cancelled);
      }
      if (bytes.isEmpty) {
        throw const SubscriptionException(SubscriptionFailure.empty);
      }
      return SubscriptionResponse(
        bytes: bytes,
        headers: Map.unmodifiable(responseHeaders),
        status: status,
        uri: uri,
      );
    }
    throw const SubscriptionException(SubscriptionFailure.redirect);
  }
}

String? _contentEncoding(Map<String, List<String>> headers) {
  final values = headers['content-encoding'];
  if (values == null) return null;
  if (values.length != 1) {
    throw const SubscriptionException(SubscriptionFailure.invalid);
  }
  final encoding = values.single.trim().toLowerCase();
  if (!const {'gzip', 'deflate', 'identity'}.contains(encoding)) {
    throw const SubscriptionException(SubscriptionFailure.invalid);
  }
  return encoding;
}

Future<Uint8List> decompressSubscriptionPayload(
  Uint8List bytes, {
  String? encoding,
}) => IsolatePayload.decode(bytes, encoding);

abstract final class IsolatePayload {
  static Future<Uint8List> decode(Uint8List bytes, String? encoding) =>
      compute(_decodePayload, (bytes, encoding));
}

Uint8List _decodePayload((Uint8List, String?) input) {
  final (bytes, encoding) = input;
  final isGzip =
      encoding != 'identity' &&
      bytes.length >= 2 &&
      bytes[0] == 0x1f &&
      bytes[1] == 0x8b;
  final isZlib =
      encoding != 'identity' &&
      bytes.length >= 2 &&
      bytes[0] == 0x78 &&
      ((bytes[0] << 8) | bytes[1]) % 31 == 0;
  final codec = encoding == 'gzip' || isGzip
      ? gzip
      : encoding == 'deflate' || isZlib
      ? zlib
      : null;
  if (codec == null) {
    if (bytes.length > subscriptionPayloadLimit) {
      throw const SubscriptionException(SubscriptionFailure.oversized);
    }
    return bytes;
  }
  final output = _BoundedPayloadSink();
  try {
    final sink = codec.decoder.startChunkedConversion(output);
    for (var offset = 0; offset < bytes.length; offset += 4096) {
      sink.add(
        bytes.sublist(
          offset,
          offset + 4096 < bytes.length ? offset + 4096 : bytes.length,
        ),
      );
    }
    sink.close();
    return output.bytes.takeBytes();
  } on SubscriptionException {
    rethrow;
  } on FormatException {
    if (encoding == null) return bytes;
    throw const SubscriptionException(SubscriptionFailure.invalid);
  }
}

class _BoundedPayloadSink implements Sink<List<int>> {
  final bytes = BytesBuilder(copy: false);
  @override
  void add(List<int> data) {
    if (bytes.length + data.length > subscriptionPayloadLimit) {
      throw const SubscriptionException(SubscriptionFailure.oversized);
    }
    bytes.add(data);
  }

  @override
  void close() {}
}
