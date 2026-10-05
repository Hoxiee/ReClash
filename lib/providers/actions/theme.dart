part of '../action.dart';

@Riverpod(keepAlive: true)
class ThemeAction extends _$ThemeAction {
  @override
  void build() {}

  void updateBrightness() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(systemBrightnessProvider.notifier).value =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      ref.invalidate(effectiveThemeModeProvider);
    });
  }

  void updateViewSize(Size size) {
    // The root LayoutBuilder calls this on every layout pass; most pass the
    // same constraints. Skip scheduling (and the extra rebuild cascade down
    // viewWidth -> viewMode -> navigation) when the size is unchanged.
    if (ref.read(viewSizeProvider) == size) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(viewSizeProvider.notifier);
      if (notifier.value == size) {
        return;
      }
      notifier.value = size;
    });
  }
}
