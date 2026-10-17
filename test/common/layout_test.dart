import 'package:reclash/common/constant.dart';
import 'package:reclash/common/layout.dart';
import 'package:reclash/enum/enum.dart';
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
}
