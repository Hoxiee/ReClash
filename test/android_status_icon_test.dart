import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'helpers/android_launcher_icons.dart';

void main() {
  test('status icon fills the system live area without touching the edge', () {
    final file = File('android/service/src/main/res/drawable/ic_service.xml');
    final vector = AndroidVectorIcon.parse(file.readAsStringSync());
    expect(vector.sizeDp, 24);

    // A 24dp system icon carries its artwork in the inner 22dp live area.
    final bounds = vector.markBoundsDp;
    expect(bounds.longestSide, inInclusiveRange(20, 22));
    expect(bounds.left, greaterThanOrEqualTo(1));
    expect(bounds.top, greaterThanOrEqualTo(1));
    expect(bounds.right, lessThanOrEqualTo(23));
    expect(bounds.bottom, lessThanOrEqualTo(23));
    expect(bounds.center.dx, closeTo(12, 0.1));
    expect(bounds.center.dy, closeTo(12, 0.1));
  });
}
