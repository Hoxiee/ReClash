import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reclash/common/app_localizations.dart';
import 'package:reclash/common/exception.dart';
import 'package:reclash/common/path.dart';
import 'package:reclash/common/picker.dart';
import 'package:reclash/common/wallpaper_store.dart';
import 'package:reclash/models/wallpaper.dart';
import 'package:reclash/providers/action.dart';
import 'package:reclash/providers/config.dart';

final wallpaperStoreProvider = Provider<WallpaperStore>(
  (_) => WallpaperStore(
    directory: () async => Directory(await appPath.wallpapersDirPath),
  ),
);

final wallpaperPickerProvider = Provider<Future<PlatformFile?> Function()>(
  (_) => picker.pickerImage,
);

final wallpaperSaveProvider = Provider<Future<bool> Function()>(
  (ref) => ref.read(storeActionProvider.notifier).savePreferences,
);

final wallpaperImageProvider = FutureProvider<MemoryImage?>((ref) async {
  final fileName = ref.watch(
    themeSettingProvider.select((value) => value.wallpaper.fileName),
  );
  if (fileName == null) return null;
  return ref.watch(wallpaperThumbnailProvider(fileName).future);
});

final wallpaperThumbnailProvider = FutureProvider.family<MemoryImage?, String>((
  ref,
  fileName,
) async {
  try {
    final bytes = await ref.watch(wallpaperStoreProvider).readImage(fileName);
    if (bytes == null || !ref.mounted) return null;
    final image = MemoryImage(bytes);
    ref.onDispose(() => unawaited(image.evict()));
    return image;
  } catch (_) {
    return null;
  }
});

final wallpaperActionProvider = NotifierProvider<WallpaperAction, bool>(
  WallpaperAction.new,
);

class WallpaperAction extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> chooseImage() async {
    if (state) return;
    state = true;
    final store = ref.read(wallpaperStoreProvider);
    final previous = ref.read(themeSettingProvider).wallpaper;
    String? imported;
    try {
      if (previous.library.length >= maxWallpaperLibrary) {
        throw MessageException(
          currentAppLocalizations.wallpaperLibraryFull(maxWallpaperLibrary),
        );
      }
      final source = await ref.read(wallpaperPickerProvider)();
      if (source == null || !ref.mounted) return;
      imported = await store.importImage(source);
      if (!ref.mounted) return;
      final current = ref.read(themeSettingProvider).wallpaper;
      if (current != previous) return;
      await _commit(
        current.copyWith(
          enabled: true,
          fileName: imported,
          library: [imported, ...current.library],
        ),
      );
      imported = null;
    } on WallpaperImportException catch (error) {
      throw MessageException(switch (error.failure) {
        WallpaperImportFailure.invalidImage =>
          currentAppLocalizations.wallpaperImageError,
        WallpaperImportFailure.tooLarge =>
          currentAppLocalizations.wallpaperTooLarge,
      });
    } on MessageException {
      rethrow;
    } catch (_) {
      throw MessageException(currentAppLocalizations.wallpaperSaveError);
    } finally {
      if (imported != null) await _removeQuietly(store, imported);
      if (ref.mounted) state = false;
    }
  }

  Future<void> selectImage(String fileName) async {
    if (state) return;
    final current = ref.read(themeSettingProvider).wallpaper;
    if (!current.library.contains(fileName)) return;
    if (current.fileName == fileName && current.enabled) return;
    state = true;
    try {
      await _commit(current.copyWith(enabled: true, fileName: fileName));
    } finally {
      if (ref.mounted) state = false;
    }
  }

  Future<void> removeImage(String fileName) async {
    if (state) return;
    final current = ref.read(themeSettingProvider).wallpaper;
    if (!current.library.contains(fileName)) return;
    state = true;
    try {
      final removingActive = current.fileName == fileName;
      await _commit(
        current.copyWith(
          library: current.library.where((name) => name != fileName).toList(),
          fileName: removingActive ? null : current.fileName,
          enabled: removingActive ? false : current.enabled,
        ),
        prune: [fileName],
      );
    } finally {
      if (ref.mounted) state = false;
    }
  }

  Future<void> _commit(
    WallpaperProps next, {
    List<String> prune = const [],
  }) async {
    final previous = ref.read(themeSettingProvider).wallpaper;
    final save = ref.read(wallpaperSaveProvider);
    final store = ref.read(wallpaperStoreProvider);
    ref
        .read(themeSettingProvider.notifier)
        .update((value) => value.copyWith(wallpaper: next));
    var saved = false;
    try {
      saved = await save();
    } catch (_) {
      saved = false;
    }
    if (!saved) {
      if (ref.mounted && ref.read(themeSettingProvider).wallpaper == next) {
        ref
            .read(themeSettingProvider.notifier)
            .update((value) => value.copyWith(wallpaper: previous));
      }
      throw MessageException(currentAppLocalizations.wallpaperSaveError);
    }
    for (final fileName in prune) {
      if (!next.library.contains(fileName)) {
        await _removeQuietly(store, fileName);
      }
    }
  }

  Future<void> _removeQuietly(WallpaperStore store, String? fileName) async {
    try {
      await store.removeImage(fileName);
    } on FileSystemException {
      // Cleanup failure must not undo the saved selection.
    }
  }
}
