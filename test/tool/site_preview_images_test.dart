import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore: avoid_relative_lib_imports
import '../../site_preview/lib/images.dart';

void main() {
  final images = PreviewImages(
    Uri.parse('https://site.example/runtime/preview/'),
  );

  test('preview pictures resolve only within the website origin', () {
    expect(
      images.resolve('/images/logo.png'),
      Uri.parse('https://site.example/images/logo.png'),
    );
    expect(
      images.resolve('logo.png'),
      Uri.parse('https://site.example/runtime/preview/logo.png'),
    );
    expect(
      images.resolve('//site.example/images/logo.svg'),
      Uri.parse('https://site.example/images/logo.svg'),
    );
    for (final src in [
      'https://provider.example/logo.png',
      '//provider.example/logo.png',
      'http://site.example/logo.png',
      'https://site.example:8443/logo.png',
      'https://token@site.example/logo.png',
      'https:logo.png',
      'http:/logo.png',
      'https://',
      'file:///tmp/logo.png',
      'javascript:alert(1)',
      'data:text/html;base64,PGgxPnRlc3Q8L2gxPg==',
      '',
    ]) {
      expect(images.resolve(src), isNull, reason: src);
    }
  });

  test('external pictures return no image provider', () async {
    final url = Uri.parse('https://provider.example/banner.png');
    expect(images.source(url), isNull);
    expect(await images.picture(url), isNull);
    expect(
      images.source(Uri.parse('https://site.example/images/banner.png')),
      isA<NetworkImage>(),
    );
  });

  test('inline image data is local and malformed data is ignored', () {
    final uri = Uri.parse('data:image/png;base64,AQID');
    final image = images.source(uri) as MemoryImage;
    expect(image.bytes, base64Decode('AQID'));
    expect(images.resolve('data:image/png;base64,%%%'), isNull);
    expect(images.source(Uri.parse('data:image/png;base64,')), isNull);
    expect(images.source(Uri.parse('data:text/plain;base64,AQID')), isNull);
  });

  testWidgets('an external logo uses its fallback without a network request', (
    tester,
  ) async {
    await tester.pumpWidget(
      images.logo(
        'https://provider.example/logo.svg',
        fallback: const Text('Provider', textDirection: TextDirection.ltr),
      ),
    );
    expect(find.text('Provider'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a malformed inline logo uses its fallback', (tester) async {
    await tester.pumpWidget(
      images.logo(
        'data:image/svg+xml;base64,%%%',
        fallback: const Text('Provider', textDirection: TextDirection.ltr),
      ),
    );
    expect(find.text('Provider'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
