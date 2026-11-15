import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/wallpaper_store.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/database.dart';
import 'package:reclash/providers/provider_settings.dart';
import 'package:reclash/providers/wallpaper.dart';
import '../helpers/provider_presentation.dart';
import '../helpers/test_profiles.dart';
import 'package:reclash/subscriptions/provider_settings.dart';
import 'package:reclash/ui/wallpaper_image.dart';

final _svg = utf8.encode(
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1080 1920">'
  '<rect width="1080" height="1920" fill="#ff6b1a"/>'
  '</svg>',
);
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

final class _SweptStore extends WallpaperStore {
  _SweptStore(Directory root) : super(directory: () async => root);

  final swept = Completer<void>();

  @override
  Future<void> removeImagesExcept(
    Set<String> keep, {
    required DateTime before,
  }) async {
    await super.removeImagesExcept(keep, before: before);
    swept.complete();
  }
}

Future<ProviderSettingsInput> _backgroundInput(ProviderContainer container) {
  final ready = Completer<ProviderSettingsInput>();
  final subscription = container.listen(providerSettingsInputProvider, (
    _,
    input,
  ) {
    if (input != null && !input.backgroundPending && !ready.isCompleted) {
      ready.complete(input);
    }
  }, fireImmediately: true);
  return ready.future
      .timeout(const Duration(seconds: 5))
      .whenComplete(subscription.close);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;
  late WallpaperStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp(
      'reclash-provider-background-',
    );
    store = WallpaperStore(directory: () async => root);
  });

  tearDown(() async => root.delete(recursive: true));

  for (final extension in ['png', 'svg']) {
    test('фон подписки $extension берётся из кэша и применяется', () async {
      const url = 'https://img.example.test/background';
      final fileName = '${md5.convert(utf8.encode(url))}.$extension';
      final bytes = extension == 'svg' ? _svg : _png;
      File('${root.path}/$fileName').writeAsBytesSync(bytes);
      final container = ProviderContainer(
        overrides: [
          wallpaperStoreProvider.overrideWithValue(store),
          providerHintsProvider.overrideWithValue(
            presentedHints({
              'wallpaper': {'url': url, 'opacity': 22},
            }),
          ),
        ],
      );
      addTearDown(container.dispose);
      final input = await _backgroundInput(container);
      expect(input.backgroundFile, fileName);
      final config = applyProviderSettings(Config.realFromJson(null), input);
      expect(config.themeProps.wallpaper.enabled, isTrue);
      expect(config.themeProps.wallpaper.fileName, fileName);
      expect(config.themeProps.wallpaper.opacity, 0.22);

      final images = ProviderContainer(
        overrides: [
          wallpaperStoreProvider.overrideWithValue(store),
          themeSettingProvider.overrideWithBuild((_, _) => config.themeProps),
        ],
      );
      addTearDown(images.dispose);
      final image = await images.read(wallpaperImageProvider.future);
      if (extension == 'svg') {
        expect(image, isA<SvgWallpaperSource>());
        final loader = (image! as SvgWallpaperSource).loader as SvgBytesLoader;
        expect(loader.bytes, bytes);
      } else {
        expect(image, isA<RasterWallpaperSource>());
      }
    });
  }

  test('повреждённый SVG не становится активным изображением', () async {
    const fileName = '0123456789abcdef0123456789abcdef.svg';
    File('${root.path}/$fileName').writeAsStringSync('<svg');
    final container = ProviderContainer(
      overrides: [
        wallpaperStoreProvider.overrideWithValue(store),
        themeSettingProvider.overrideWithBuild(
          (_, _) => const ThemeProps(
            wallpaper: WallpaperProps(enabled: true, fileName: fileName),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    expect(await container.read(wallpaperImageProvider.future), isNull);
    expect(container.read(effectiveWallpaperImageProvider), isNull);
  });

  test('a sync removes an old wallpaper that no setting keeps', () async {
    const url = 'https://img.example.test/sweep';
    final providerName = '${md5.convert(utf8.encode(url))}.png';
    const libraryName = '00000000000000000000000000000005.png';
    const orphan = '00000000000000000000000000000006.png';
    final old = DateTime.now().subtract(const Duration(hours: 1));
    for (final name in [providerName, libraryName, orphan]) {
      File('${root.path}/$name')
        ..writeAsBytesSync(_png)
        ..setLastModifiedSync(old);
    }
    final sweeping = _SweptStore(root);
    final base = Config.realFromJson(null);
    final container = ProviderContainer(
      overrides: [
        ...buildConfigOverrides(
          base.copyWith(
            themeProps: base.themeProps.copyWith(
              wallpaper: const WallpaperProps(library: [libraryName]),
            ),
          ),
        ),
        profilesProvider.overrideWith(TestProfiles.new),
        wallpaperStoreProvider.overrideWithValue(sweeping),
        providerHintsProvider.overrideWithValue(
          presentedHints({
            'wallpaper': {'url': url, 'opacity': 22},
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(providerSettingsSyncProvider, (_, _) {});

    await sweeping.swept.future.timeout(const Duration(seconds: 5));

    expect(File('${root.path}/$orphan').existsSync(), isFalse);
    expect(File('${root.path}/$providerName').existsSync(), isTrue);
    expect(File('${root.path}/$libraryName').existsSync(), isTrue);
  });
}
