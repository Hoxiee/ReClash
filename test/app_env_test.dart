import 'package:reclash/state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a non-stable app env reads as a prerelease build', () {
    globalState.appEnv = 'pre';

    expect(globalState.isPre, isTrue);
  });
}
