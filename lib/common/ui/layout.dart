import 'dart:math';
import 'dart:ui' show Size;

import 'package:reclash/enum/enum.dart';

import '../util/constant.dart';

double getWindowHeaderHeight({required bool isDesktop, required bool isMacOS}) {
  if (!isDesktop) return 0;
  return isMacOS ? 28 : 40;
}

/// Windows 11 draws its caption buttons 46 wide and renders every glyph as a
/// 10x10 Segoe Fluent icon.
const captionButtonWidth = 46.0;
const captionGlyphSize = 10.0;

/// The pin is not a caption button: it keeps the round Material button in a
/// square slot the height of the bar, with a regular icon size.
const pinIconSize = 16.0;

Size getCaptionButtonSize(double headerHeight) =>
    Size(captionButtonWidth, headerHeight);

bool showsWindowHeader({
  required bool isDesktop,
  required bool isMacOS,
  required int version,
  required bool isMobileView,
}) {
  if (!isDesktop) return false;
  return !(isMacOS && (version <= 10 || !isMobileView));
}

ViewMode getViewMode(Size viewSize) {
  // A phone keeps its short side across rotation, so deciding the mobile shell
  // on the shortest side keeps a landscape phone on the bottom bar instead of
  // flipping to the rail and tearing down the page tree, the wizard, and any
  // open tool. Width still separates laptop from desktop for content density.
  if (viewSize.shortestSide <= maxMobileWidth) return ViewMode.mobile;
  if (viewSize.width <= maxLaptopWidth) return ViewMode.laptop;
  return ViewMode.desktop;
}

int getProxiesColumns(double viewWidth, ProxiesLayout proxiesLayout) {
  final columns = max((viewWidth / 250).ceil(), 2);
  return switch (proxiesLayout) {
    ProxiesLayout.tight => columns + 1,
    ProxiesLayout.standard => columns,
    ProxiesLayout.loose => columns - 1,
  };
}

const profileItemMinWidth = 270.0;

int getProfilesColumns(
  double viewWidth, {
  double spacing = 0,
  double minItemWidth = profileItemMinWidth,
}) {
  final columns = (viewWidth + spacing) / (minItemWidth + spacing);
  return max(columns.floor(), 1);
}
