import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/icons/ico.dart';

Uint8List _png(int fill, int length) =>
    Uint8List.fromList(List.filled(length, fill));

int _u16(Uint8List bytes, int offset) =>
    bytes[offset] | (bytes[offset + 1] << 8);

int _u32(Uint8List bytes, int offset) =>
    _u16(bytes, offset) | (_u16(bytes, offset + 2) << 16);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('writes one directory entry per size, sorted, with correct offsets', () {
    final ico = buildIco([
      IcoEntry(size: 256, png: _png(3, 7)),
      IcoEntry(size: 16, png: _png(1, 5)),
      IcoEntry(size: 32, png: _png(2, 6)),
    ]);

    expect(_u16(ico, 0), 0);
    expect(_u16(ico, 2), 1);
    expect(_u16(ico, 4), 3);

    const firstImage = 6 + 16 * 3;
    expect([ico[6], ico[7]], [16, 16]);
    expect(_u32(ico, 6 + 8), 5);
    expect(_u32(ico, 6 + 12), firstImage);
    expect([ico[22], ico[23]], [32, 32]);
    expect(_u32(ico, 22 + 12), firstImage + 5);
    expect([ico[38], ico[39]], [0, 0]);
    expect(_u32(ico, 38 + 12), firstImage + 11);
    expect(ico.sublist(firstImage, firstImage + 5), everyElement(1));
    expect(ico.sublist(firstImage + 11), everyElement(3));
  });

  test('rejects sizes outside the ICO range and empty input', () {
    expect(() => buildIco([]), throwsArgumentError);
    expect(
      () => buildIco([IcoEntry(size: 512, png: _png(0, 1))]),
      throwsArgumentError,
    );
  });

  test('tray sizes stop at the 2x small-icon ceiling', () {
    expect(trayIcoSizes.last, 64);
    expect(icoSizes, containsAll(trayIcoSizes));
    expect(icoSizes.last, 256);
  });

  test('Windows application icons have no background at every size', () async {
    final bytes = File(
      'windows/runner/resources/app_icon.ico',
    ).readAsBytesSync();
    for (var index = 0; index < _u16(bytes, 4); index++) {
      final entry = 6 + index * 16;
      final length = _u32(bytes, entry + 8);
      final offset = _u32(bytes, entry + 12);
      final codec = await ui.instantiateImageCodec(
        bytes.sublist(offset, offset + length),
      );
      final frame = await codec.getNextFrame();
      try {
        final data = (await frame.image.toByteData())!;
        final pixels = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        var alpha = 0;
        for (var pixel = 3; pixel < pixels.length; pixel += 4) {
          alpha += pixels[pixel];
        }
        expect(
          alpha,
          lessThan(pixels.length ~/ 4 * 255 ~/ 2),
          reason: '${frame.image.width} by ${frame.image.height}',
        );
      } finally {
        frame.image.dispose();
        codec.dispose();
      }
    }
  });
}
