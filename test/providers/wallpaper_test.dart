import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/exception.dart';
import 'package:reclash/common/wallpaper_store.dart';
import 'package:reclash/models/models.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/providers/wallpaper.dart';
import 'package:riverpod/riverpod.dart';

final class _PickedFile extends PlatformFile {
  @override
  String get name => 'source.png';
  @override
  Uri get uri => Uri.file('/unused.png');
  @override
  XFile get xFile => XFile('/unused.png');
  @override
  int lengthSync() => 0;
  @override
  Future<int> length() async => 0;
  @override
  Future<Uint8List> readAsBytes() async => Uint8List(0);
  @override
  Stream<Uint8List> readAsByteStream() => const Stream.empty();
}

final class _WallpaperStore extends WallpaperStore {
  _WallpaperStore() : super(directory: () async => Directory.systemTemp);

  static const imported = '00000000000000000000000000000004.png';

  int imports = 0;
  final removed = <String>[];

  @override
  Future<String> importImage(PlatformFile source) async {
    imports++;
    return imported;
  }

  @override
  Future<void> removeImage(String? fileName) async {
    if (fileName != null) removed.add(fileName);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const library = [
    '00000000000000000000000000000001.png',
    '00000000000000000000000000000002.png',
    '00000000000000000000000000000003.png',
  ];
  const previous = WallpaperProps(
    enabled: true,
    fileName: '00000000000000000000000000000001.png',
    library: library,
    opacity: 0.6,
  );

  late _WallpaperStore store;
  late ProviderContainer container;
  late bool saved;
  late int picks;

  setUp(() async {
    await AppLocalizations.load(const Locale('en'));
    store = _WallpaperStore();
    saved = true;
    picks = 0;
    container = ProviderContainer(
      overrides: [
        themeSettingProvider.overrideWithBuild(
          (_, _) => const ThemeProps(wallpaper: previous),
        ),
        wallpaperStoreProvider.overrideWithValue(store),
        wallpaperPickerProvider.overrideWithValue(() async {
          picks++;
          return _PickedFile();
        }),
        wallpaperSaveProvider.overrideWithValue(() async => saved),
      ],
    );
    container.listen(themeSettingProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  test(
    'imports and saves a fourth background without replacing the library',
    () async {
      await container.read(wallpaperActionProvider.notifier).chooseImage();
      expect(picks, 1);
      expect(store.imports, 1);
      expect(
        container.read(themeSettingProvider).wallpaper,
        previous.copyWith(
          library: [...library, _WallpaperStore.imported],
          fileName: _WallpaperStore.imported,
        ),
      );
      expect(store.removed, isEmpty);
      expect(container.read(wallpaperActionProvider), isFalse);
    },
  );

  test('rejects a fifth background before opening the picker', () async {
    container
        .read(themeSettingProvider.notifier)
        .update(
          (theme) => theme.copyWith(
            wallpaper: previous.copyWith(
              library: [...library, _WallpaperStore.imported],
            ),
          ),
        );
    await expectLater(
      container.read(wallpaperActionProvider.notifier).chooseImage(),
      throwsA(isA<MessageException>()),
    );
    expect(picks, 0);
    expect(store.imports, 0);
    expect(
      container.read(themeSettingProvider).wallpaper.library,
      hasLength(4),
    );
    expect(container.read(wallpaperActionProvider), isFalse);
  });

  test(
    'a failed save keeps the old library and cleans up the fourth image',
    () async {
      saved = false;
      await expectLater(
        container.read(wallpaperActionProvider.notifier).chooseImage(),
        throwsA(isA<MessageException>()),
      );
      expect(container.read(themeSettingProvider).wallpaper, previous);
      expect(store.removed, [_WallpaperStore.imported]);
      expect(container.read(wallpaperActionProvider), isFalse);
    },
  );
}
