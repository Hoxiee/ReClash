import 'package:reclash/common/constant.dart';
import 'package:reclash/common/layout.dart';
import 'package:reclash/enum/enum.dart';
import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('view mode changes at inclusive width boundaries', () {
    expect(getViewMode(maxMobileWidth.toDouble()), ViewMode.mobile);
    expect(getViewMode(maxMobileWidth + 0.1), ViewMode.laptop);
    expect(getViewMode(maxLaptopWidth.toDouble()), ViewMode.laptop);
    expect(getViewMode(maxLaptopWidth + 0.1), ViewMode.desktop);
  });

  test('only the desktop view expands the sidebar', () {
    expect(canExpandSidebar(ViewMode.mobile), isFalse);
    expect(canExpandSidebar(ViewMode.laptop), isFalse);
    expect(canExpandSidebar(ViewMode.desktop), isTrue);
  });

  test('the navigation layout overrides the view mode', () {
    const phone = Size(400, 800);
    const window = Size(1200, 800);
    expect(
      resolveViewMode(window, NavigationLayout.bar, tablet: false),
      ViewMode.mobile,
    );
    expect(
      resolveViewMode(phone, NavigationLayout.sidebar, tablet: false),
      ViewMode.laptop,
    );
    expect(
      resolveViewMode(window, NavigationLayout.sidebar, tablet: true),
      ViewMode.desktop,
    );
    expect(
      resolveViewMode(window, NavigationLayout.auto, tablet: false),
      ViewMode.desktop,
    );
    expect(
      resolveViewMode(window, NavigationLayout.auto, tablet: true),
      ViewMode.mobile,
    );
  });

  test('a tablet has a smallest side of at least 600', () {
    expect(isTabletSize(Size(maxMobileWidth.toDouble(), 1000)), isTrue);
    expect(isTabletSize(const Size(1000, 599)), isFalse);
  });
}
