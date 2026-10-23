import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/subscriptions/page_preview.dart';
import 'package:reclash/subscriptions/transport/transport.dart';

void main() {
  test('Remnawave page exposes account data without importing links', () {
    final panel = base64.encode(
      utf8.encode(
        jsonEncode({
          'response': {
            'isFound': true,
            'user': {
              'username': 'Home',
              'trafficUsedBytes': '1073741824',
              'trafficLimitBytes': '107374182400',
              'expiresAt': '2027-01-01T00:00:00Z',
            },
            'links': ['ss://secret'],
          },
        }),
      ),
    );
    final result = parseSubscriptionPage('''
      <html><head><title>Acme</title>
      <meta name="description" content="Hello &amp; welcome"></head>
      <body><div id="sbpg" data-panel="$panel"></div></body></html>
    ''');
    expect(result.label, 'Home');
    expect(result.metadata.name, 'Acme');
    expect(result.metadata.announce, 'Hello & welcome');
    expect(result.info?.download, 1 << 30);
    expect(result.info?.total, 100 << 30);
    expect(result.info?.expire, 1798761600);
  });

  test('3x-ui embedded page JSON is read without executing its script', () {
    final result = parseSubscriptionPage('''
      <title>Subscription</title><script>
      window.X_UI_BASE_PATH="/";window.__SUB_PAGE_DATA__={
        "subTitle":"Home", "announce":"Welcome", "uploadByte":42,
        "downloadByte":1024, "totalByte":2048, "expire":1798761600,
        "links":["ss://secret"]
      };</script>
    ''');
    expect(result.label, 'Home');
    expect(result.metadata.name, 'Home');
    expect(result.metadata.announce, 'Welcome');
    expect(result.info?.upload, 42);
    expect(result.info?.download, 1024);
    expect(result.info?.total, 2048);
    expect(result.info?.expire, 1798761600);
  });

  test('out-of-range page expiry is not exposed to the UI', () {
    final result = parseSubscriptionPage('''
      <script>window.__SUB_PAGE_DATA__={"uploadByte":0,"downloadByte":0,
        "totalByte":0,"expire":9007199254740991};</script>
    ''');
    expect(result.info, isNull);
  });

  test('Marzban default page provides labeled account fields', () {
    final result = parseSubscriptionPage('''
      <html><head><title>Subscription Information</title></head><body>
      <p>Username: Home</p><p>Status: <span>active</span></p>
      <p>Data Limit: 100.00 GB</p><p>Data Used: 1.00 GB (resets monthly)</p>
      <p>Expiration Date: 2027-01-01 00:00:00 (70 days remaining)</p>
      </body></html>
    ''');
    expect(result.label, 'Home');
    expect(result.info?.download, 1 << 30);
    expect(result.info?.total, 100 << 30);
    expect(result.info?.expire, DateTime(2027).millisecondsSinceEpoch ~/ 1000);
  });

  test('missing or malformed usage never becomes unlimited', () {
    for (final data in [
      'broken',
      base64.encode(utf8.encode('{"response":{}}')),
    ]) {
      final result = parseSubscriptionPage(
        '<title>Acme</title><div id="sbpg" data-panel="$data"></div>',
      );
      expect(result.info, isNull);
      expect(result.metadata.name, 'Acme');
    }
    final result = parseSubscriptionPage('''
      <p>Username: Home</p><p>Status: active</p><p>Data Limit: unknown</p>
      <p>Data Used: 1 GB</p><p>Expiration Date: ∞</p>
    ''');
    expect(result.info, isNull);
  });

  test('Marzban explicit infinity remains unlimited and perpetual', () {
    final result = parseSubscriptionPage('''
      <p>Username: Home</p><p>Status: active</p><p>Data Limit: ∞</p>
      <p>Data Used: 0 B</p><p>Expiration Date: ∞</p>
    ''');
    expect(result.info?.total, 0);
    expect(result.info?.expire, 0);
  });

  test('generic metadata does not consume scripts or image URLs', () {
    final result = parseSubscriptionPage('''
      <title>Fallback</title><meta property="og:site_name" content="Provider">
      <meta property="og:description" content="Page description">
      <meta property="og:image" content="https://assets.test/logo">
      <script>throw new Error('must not execute')</script>
    ''');
    expect(result.metadata.name, 'Provider');
    expect(result.metadata.announce, 'Page description');
    expect(result.metadata.logo, isNull);
    expect(result.info, isNull);
  });

  test(
    'browser preview never follows assets or retries a config response',
    () async {
      final previous = HttpOverrides.current;
      HttpOverrides.global = null;
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() async {
        await server.close(force: true);
        HttpOverrides.global = previous;
      });
      var requests = 0;
      var serveHtml = true;
      server.listen((request) async {
        requests++;
        expect(request.uri.path, '/sub');
        expect(request.headers.value('accept'), contains('text/html'));
        expect(request.headers.value('user-agent'), startsWith('Mozilla/'));
        expect(request.headers.value('x-hwid'), isNull);
        if (serveHtml) {
          request.response.headers.contentType = ContentType.html;
          request.response.write('''
          <title>Provider</title><img src="/asset">
          <script src="/code"></script><link rel="stylesheet" href="/style">
        ''');
        } else {
          request.response.headers.contentType = ContentType.text;
          request.response.headers.set('profile-title', 'Must not import');
          request.response.write('proxies: []\nrules: [MATCH,DIRECT]');
        }
        await request.response.close();
      });
      final url = 'http://127.0.0.1:${server.port}/sub';
      final page = await previewSubscriptionPage(
        url,
        transport: SubscriptionTransport(),
      );
      expect(page.metadata.name, 'Provider');
      expect(requests, 1);
      serveHtml = false;
      final config = await previewSubscriptionPage(
        url,
        transport: SubscriptionTransport(),
      );
      expect(config.metadata.fields, isEmpty);
      expect(config.info, isNull);
      expect(requests, 2);
    },
  );

  test('cancelled preview never sends a request', () async {
    final cancellation = SubscriptionCancellation()..cancel();
    await expectLater(
      previewSubscriptionPage(
        'http://127.0.0.1:1/sub',
        transport: SubscriptionTransport(),
        cancellation: cancellation,
      ),
      throwsA(
        isA<SubscriptionException>().having(
          (error) => error.failure,
          'failure',
          SubscriptionFailure.cancelled,
        ),
      ),
    );
  });
}
