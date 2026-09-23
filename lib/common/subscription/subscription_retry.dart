import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:reclash/common/net/request.dart';
import 'package:reclash/core/method.dart';
import 'package:reclash/models/profile.dart';

typedef ProtectedSubscriptionHop =
    Future<Map<String, dynamic>> Function({
      required String url,
      required Map<String, String> headers,
      required int timeoutMillis,
    });

bool isSubscriptionTransportFailure(Object error) =>
    error is DioException &&
    error.response == null &&
    error.requestOptions.extra['subscriptionReceivedResponse'] != true &&
    const {
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    }.contains(error.type);

class SubscriptionRetry {
  SubscriptionRetry({
    required this.fetchNormally,
    required this.fetchProtected,
    required this.allowed,
    required this.confirm,
  });

  final FetchProfileResponse fetchNormally;
  final FetchProfileResponse fetchProtected;
  final bool Function() allowed;
  final Future<bool> Function() confirm;
  bool _canOffer = true;
  bool _protected = false;

  Future<Response<Uint8List>> fetch(
    String url, {
    Map<String, String>? headers,
  }) async {
    if (_protected) {
      if (!allowed()) {
        throw const CoreMethodException(
          code: 'subscription_protection',
          message: 'Subscription bypass is not allowed',
        );
      }
      return fetchProtected(url, headers: headers);
    }
    final canOffer = _canOffer;
    _canOffer = false;
    try {
      return await fetchNormally(url, headers: headers);
    } catch (error) {
      if (!canOffer || !isSubscriptionTransportFailure(error) || !allowed()) {
        rethrow;
      }
      if (!await confirm() || !allowed()) rethrow;
      _protected = true;
      return fetchProtected(url, headers: headers);
    }
  }
}

class ProtectedSubscriptionTransport implements HttpClientAdapter {
  ProtectedSubscriptionTransport({required this.hop, required this.allowed});

  final ProtectedSubscriptionHop hop;
  final bool Function() allowed;
  final Stopwatch _elapsed = Stopwatch();
  int _requests = 0;

  Future<Response<Uint8List>> download(
    String url, {
    Map<String, String>? headers,
  }) async {
    final dio = Dio()..httpClientAdapter = this;
    try {
      return await request.getFileResponseForUrl(
        url,
        headers: headers,
        transport: dio,
      );
    } finally {
      dio.close(force: true);
    }
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (!_elapsed.isRunning) _elapsed.start();
    final remaining = 30000 - _elapsed.elapsedMilliseconds;
    if (!allowed() ||
        remaining <= 0 ||
        _requests >= subscriptionRedirectLimit + 1) {
      throw const CoreMethodException(
        code: 'subscription_protection',
        message: 'Protected subscription request is no longer allowed',
      );
    }
    _requests++;
    final result = await hop(
      url: options.uri.toString(),
      headers: options.headers.map(
        (name, value) => MapEntry(name, value.toString()),
      ),
      timeoutMillis: remaining,
    );
    final status = result['status'];
    final rawHeaders = result['headers'];
    final encoded = result['body'];
    if (status is! int || rawHeaders is! Map || encoded is! String) {
      throw const CoreMethodException(
        code: 'subscription_protection',
        message: 'Malformed protected subscription response',
      );
    }
    final headers = rawHeaders.map(
      (key, value) => MapEntry(
        key.toString(),
        value is List
            ? value.map((item) => item.toString()).toList()
            : <String>[],
      ),
    );
    if (encoded.length > ((maxSubscriptionResponseBytes + 2) ~/ 3) * 4) {
      throw const CoreMethodException(
        code: 'subscription_too_large',
        message: 'Subscription response is too large',
      );
    }
    try {
      return ResponseBody.fromBytes(
        base64Decode(encoded),
        status,
        headers: headers,
      );
    } on FormatException {
      throw const CoreMethodException(
        code: 'subscription_protection',
        message: 'Malformed protected subscription response',
      );
    }
  }

  @override
  void close({bool force = false}) {}
}
