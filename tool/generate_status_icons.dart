import 'dart:io';
import 'dart:typed_data';

import 'src/icons/ico.dart';

const sourceDir = 'assets_source/images/icon';
const pngOutputDir = 'assets/images/tray/unix';
const icoOutputDir = 'assets/images/tray/windows';
const macosOutputDir = 'assets/images/tray/macos';
const statusIconNames = ['status_1', 'status_2', 'status_3', 'status_4'];
const macosStatusIconSources = {
  'status_1': '$sourceDir/glyph.svg',
  'status_4': '$sourceDir/status_4.svg',
};
const trayBaseSize = 18;
const trayScales = [1, 2, 3, 4];
const appIconSource = '$sourceDir/glyph.svg';
const appIconOutput = 'windows/runner/resources/app_icon.ico';
const androidRes = 'android/app/src/main/res';
const androidServiceRes = 'android/service/src/main/res';
const androidDensities = {
  'mdpi': (launcher: 48, television: 80),
  'hdpi': (launcher: 72, television: 120),
  'xhdpi': (launcher: 96, television: 160),
  'xxhdpi': (launcher: 144, television: 240),
  'xxxhdpi': (launcher: 192, television: 320),
};

Future<void> main() async {
  final rsvgConvert = await _findExecutable('rsvg-convert');
  if (rsvgConvert == null) {
    stderr.writeln(
      'rsvg-convert is required. Install librsvg before generating icons.',
    );
    exitCode = 1;
    return;
  }

  final magick = await _findExecutable('magick');
  if (magick == null) {
    stderr.writeln('ImageMagick is required to generate platform icons.');
    exitCode = 1;
    return;
  }

  await Directory(icoOutputDir).create(recursive: true);
  final tempDir = await Directory.systemTemp.createTemp('status_icons_');
  final renderer = _Renderer(rsvgConvert, magick, tempDir);
  try {
    for (final name in statusIconNames) {
      final source = File('$sourceDir/$name.svg');
      if (!source.existsSync()) {
        stderr.writeln('Missing source SVG: ${source.path}');
        exitCode = 1;
        return;
      }
      await _writeTrayVariants(renderer, source, name, pngOutputDir);
      await _writeIco(
        renderer,
        source,
        File('$icoOutputDir/$name.ico'),
        sizes: trayIcoSizes,
      );
    }
    for (final MapEntry(key: name, value: path)
        in macosStatusIconSources.entries) {
      final source = File(path);
      if (!source.existsSync()) {
        stderr.writeln('Missing source SVG: ${source.path}');
        exitCode = 1;
        return;
      }
      await _writeTrayVariants(
        renderer,
        await renderer.monochrome(source),
        name,
        macosOutputDir,
      );
    }
    await _writeAppIcons(renderer);
    await _writeAndroidIcons(renderer);
  } finally {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  }
}

Future<void> _writeAppIcons(_Renderer renderer) async {
  final appIcon = File(appIconSource);
  await _writeRaster(renderer, appIcon, File('assets/images/icon.png'), 550);
  await _writeIco(renderer, appIcon, File(appIconOutput));
  await File(appIconOutput).copy('assets/images/icon.ico');

  final macosIcon = await renderer.wrapRaster(File('$sourceDir/macos.png'));
  for (final size in [16, 32, 64, 128, 256, 512, 1024]) {
    await _writeRaster(
      renderer,
      macosIcon,
      File(
        'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_$size.png',
      ),
      size,
    );
  }
}

Future<void> _writeAndroidIcons(_Renderer renderer) async {
  final fullBleed = File('$sourceDir/app_fullbleed.svg');
  final round = File('${renderer.tempDir.path}/round.svg');
  await round.writeAsString(
    (await fullBleed.readAsString()).replaceFirst(
      RegExp(r'<rect\b[^>]*/>'),
      '<circle cx="512" cy="512" r="512" fill="#F2EDE3"/>',
    ),
  );
  for (final MapEntry(key: density, value: sizes) in androidDensities.entries) {
    for (final (name, source) in [
      ('ic_launcher', File('$sourceDir/app.svg')),
      ('ic_launcher_round', round),
    ]) {
      await _writeRaster(
        renderer,
        source,
        File('$androidRes/mipmap-$density/$name.webp'),
        sizes.launcher,
      );
    }
    await _writeRaster(
      renderer,
      fullBleed,
      File('$androidRes/mipmap-television-$density/ic_launcher.webp'),
      sizes.television,
    );
  }
  await _writeRaster(
    renderer,
    fullBleed,
    File('android/app/src/main/ic_launcher-playstore.png'),
    512,
  );
  await _writeRaster(
    renderer,
    File('$sourceDir/tv_banner.svg'),
    File('$androidRes/mipmap-xhdpi/ic_banner.png'),
    320,
    height: 180,
  );

  final mark = await File('$sourceDir/glyph.svg').readAsString();
  final foreground = _androidVector(
    mark,
    viewport: 108,
    scale: 0.145,
    translateX: 53.78975,
    translateY: 54.1769,
  );
  final monochrome = _androidVector(
    mark,
    viewport: 108,
    scale: 0.145,
    translateX: 53.78975,
    translateY: 54.1769,
    monochrome: true,
  );
  for (final name in ['ic_launcher_foreground', 'ic_launcher_foreground_tv']) {
    await File('$androidRes/drawable/$name.xml').writeAsString(foreground);
  }
  await File(
    '$androidRes/drawable/ic_launcher_monochrome.xml',
  ).writeAsString(monochrome);
  for (final (name, singleColor) in [('ic', true), ('ic_service', false)]) {
    await File('$androidServiceRes/drawable/$name.xml').writeAsString(
      _androidVector(
        mark,
        viewport: 24,
        scale: 0.062,
        translateX: 11.91004,
        translateY: 12.07564,
        monochrome: singleColor,
      ),
    );
  }
  for (final (directory, name, source) in [
    ('mipmap-anydpi-v26', 'ic_launcher', 'ic_launcher_foreground'),
    ('mipmap-anydpi-v26', 'ic_launcher_round', 'ic_launcher_foreground'),
    (
      'mipmap-television-anydpi-v26',
      'ic_launcher',
      'ic_launcher_foreground_tv',
    ),
  ]) {
    await File('$androidRes/$directory/$name.xml').writeAsString(
      '<?xml version="1.0" encoding="utf-8"?>\n'
      '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
      '    <background android:drawable="@color/ic_launcher_background"/>\n'
      '    <foreground android:drawable="@drawable/$source"/>\n'
      '    <monochrome android:drawable="@drawable/ic_launcher_monochrome"/>\n'
      '</adaptive-icon>\n',
    );
  }
  for (final (file, name, color) in [
    ('ic_launcher_background', 'ic_launcher_background', '#F2EDE3'),
    ('colors', 'shortcut_background', '#6E55F5'),
  ]) {
    await File('$androidRes/values/$file.xml').writeAsString(
      '<?xml version="1.0" encoding="utf-8"?>\n'
      '<resources>\n    <color name="$name">$color</color>\n</resources>\n',
    );
  }
}

Map<String, String> _svgAttributes(String source) => {
  for (final match in RegExp(r'([\w-]+)="([^"]*)"').allMatches(source))
    match[1]!: match[2]!,
};

String _androidVector(
  String svg, {
  required int viewport,
  required double scale,
  required double translateX,
  required double translateY,
  bool monochrome = false,
}) {
  final gradients = {
    for (final match in RegExp(
      r'<linearGradient\b([^>]*)>([\s\S]*?)</linearGradient>',
    ).allMatches(svg))
      _svgAttributes(match[1]!)['id']!: (
        attributes: _svgAttributes(match[1]!),
        stops: [
          for (final stop in RegExp(r'<stop\b([^>]*)/>').allMatches(match[2]!))
            _svgAttributes(stop[1]!),
        ],
      ),
  };
  final output = StringBuffer(
    '<vector xmlns:android="http://schemas.android.com/apk/res/android"\n'
    '    xmlns:aapt="http://schemas.android.com/aapt"\n'
    '    android:width="${viewport}dp" android:height="${viewport}dp"\n'
    '    android:viewportWidth="$viewport" android:viewportHeight="$viewport">\n'
    '  <group android:scaleX="$scale" android:scaleY="$scale"\n'
    '      android:translateX="$translateX" android:translateY="$translateY">\n',
  );
  for (final path in RegExp(r'<path\b([^>]*)/>').allMatches(svg)) {
    final attributes = _svgAttributes(path[1]!);
    final data = attributes['d']!;
    if (monochrome) {
      output.writeln(
        '    <path android:fillColor="#FFFFFF" android:pathData="$data"/>',
      );
      continue;
    }
    final fill = attributes['fill']!;
    final gradient = gradients[fill.substring(5, fill.length - 1)]!;
    final coordinates = gradient.attributes;
    output.writeln(
      '    <path android:pathData="$data">\n'
      '      <aapt:attr name="android:fillColor">\n'
      '        <gradient android:type="linear"\n'
      '            android:startX="${coordinates['x1']}" android:startY="${coordinates['y1']}"\n'
      '            android:endX="${coordinates['x2']}" android:endY="${coordinates['y2']}">',
    );
    for (final stop in gradient.stops) {
      output.writeln(
        '          <item android:offset="${stop['offset']}" android:color="${stop['stop-color']}"/>',
      );
    }
    output.writeln('        </gradient>\n      </aapt:attr>\n    </path>');
  }
  return (output..writeln('  </group>\n</vector>')).toString();
}

Future<void> _writeRaster(
  _Renderer renderer,
  File source,
  File output,
  int size, {
  int? height,
}) async {
  final png = await renderer.render(source, size, height: height);
  await output.parent.create(recursive: true);
  await output.writeAsBytes(
    output.path.endsWith('.webp') ? await renderer.webp(png) : png,
  );
  stdout.writeln('Generated ${output.path}');
}

Future<void> _writeTrayVariants(
  _Renderer renderer,
  File source,
  String name,
  String outputDir,
) async {
  for (final scale in trayScales) {
    final directory = scale == 1 ? outputDir : '$outputDir/$scale.0x';
    await Directory(directory).create(recursive: true);
    final output = File('$directory/$name.png');
    await output.writeAsBytes(
      await renderer.render(source, trayBaseSize * scale),
    );
    stdout.writeln('Generated ${output.path}');
  }
}

Future<void> _writeIco(
  _Renderer renderer,
  File source,
  File output, {
  List<int> sizes = icoSizes,
}) async {
  final entries = [
    for (final size in sizes)
      IcoEntry(size: size, png: await renderer.render(source, size)),
  ];
  await output.parent.create(recursive: true);
  await output.writeAsBytes(buildIco(entries));
  stdout.writeln('Generated ${output.path}');
}

Future<String?> _findExecutable(String executable) async {
  final result = await Process.run('which', [executable]);
  if (result.exitCode != 0) {
    return null;
  }
  return (result.stdout as String).trim();
}

class _Renderer {
  _Renderer(this.rsvgConvert, this.magick, this.tempDir);

  final String rsvgConvert;
  final String magick;
  final Directory tempDir;
  int _sequence = 0;

  Future<Uint8List> render(File source, int size, {int? height}) async {
    final output = File('${tempDir.path}/${_sequence++}-$size.png');
    final result = await Process.run(rsvgConvert, [
      '-w',
      '$size',
      '-h',
      '${height ?? size}',
      '-o',
      output.path,
      source.path,
    ]);
    if (result.exitCode != 0) {
      stderr
        ..writeln('Failed to render ${source.path} at ${size}px')
        ..writeln(result.stderr);
      exit(result.exitCode);
    }
    return output.readAsBytes();
  }

  Future<Uint8List> webp(Uint8List png) async {
    final input = File('${tempDir.path}/${_sequence++}.png');
    final output = File('${input.path}.webp');
    await input.writeAsBytes(png);
    final result = await Process.run(magick, [
      input.path,
      '-define',
      'webp:lossless=true',
      '-strip',
      output.path,
    ]);
    if (result.exitCode != 0) {
      stderr.writeln(result.stderr);
      exit(result.exitCode);
    }
    return output.readAsBytes();
  }

  // librsvg only resolves raster references from the SVG source directory.
  Future<File> wrapRaster(File raster) async {
    final copy = await raster.copy('${tempDir.path}/${_basename(raster)}');
    final wrapper = File('${tempDir.path}/${_basename(raster)}.svg');
    await wrapper.writeAsString(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'xmlns:xlink="http://www.w3.org/1999/xlink" '
      'width="256" height="256" viewBox="0 0 256 256">'
      '<image xlink:href="${_basename(copy)}" width="256" height="256"/>'
      '</svg>',
    );
    return wrapper;
  }

  Future<File> monochrome(File source) async {
    final copy = File('${tempDir.path}/mono-${_basename(source)}');
    await copy.writeAsString(
      (await source.readAsString()).replaceAllMapped(
        RegExp(r'\b(fill|stroke)="(?!none")[^"]*"'),
        (match) => '${match[1]}="#000000"',
      ),
    );
    return copy;
  }

  String _basename(File file) => file.uri.pathSegments.last;
}
