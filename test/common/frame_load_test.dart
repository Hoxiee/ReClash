import 'package:reclash/common/frame_load.dart';
import 'package:flutter_test/flutter_test.dart';

const _late = Duration(milliseconds: 20);
const _onTime = Duration(milliseconds: 10);

void main() {
  test('requires two complete overloaded windows across batches', () {
    final watch = FrameLoadWatch();
    expect(watch.overloadedAfter(List.filled(179, _late)), isFalse);
    expect(watch.overloadedAfter([_late]), isTrue);
    expect(watch.overloadedAfter(List.filled(90, _late)), isFalse);
    expect(watch.overloadedAfter(List.filled(90, _late)), isTrue);
  });

  test('a window within budget breaks the consecutive overload count', () {
    final watch = FrameLoadWatch();
    expect(watch.overloadedAfter(List.filled(90, _late)), isFalse);
    expect(watch.overloadedAfter(List.filled(90, _onTime)), isFalse);
    expect(watch.overloadedAfter(List.filled(90, _late)), isFalse);
    expect(watch.overloadedAfter(List.filled(90, _late)), isTrue);
  });

  test('exactly seventy percent late is not sustained overload', () {
    final watch = FrameLoadWatch(window: 10);
    final threshold = [...List.filled(7, _late), ...List.filled(3, _onTime)];
    expect(watch.overloadedAfter([...threshold, ...threshold]), isFalse);
    final overloaded = [...List.filled(8, _late), ...List.filled(2, _onTime)];
    expect(watch.overloadedAfter([...overloaded, ...overloaded]), isTrue);
  });

  test('a frame exactly at the budget is not late', () {
    final watch = FrameLoadWatch();
    expect(
      watch.overloadedAfter(List.filled(180, FrameLoadWatch.budget)),
      isFalse,
    );
  });

  test('a missed high-refresh target alone does not reduce quality', () {
    final watch = FrameLoadWatch();
    expect(watch.overloadedAfter(List.filled(360, _onTime)), isFalse);
  });

  test('reset discards complete and partial windows', () {
    final watch = FrameLoadWatch();
    expect(watch.overloadedAfter(List.filled(179, _late)), isFalse);
    watch.reset();
    expect(watch.overloadedAfter(List.filled(179, _late)), isFalse);
    expect(watch.overloadedAfter([_late]), isTrue);
  });

  test('empty batches add no frames', () {
    final watch = FrameLoadWatch(window: 2);
    expect(watch.overloadedAfter([_late]), isFalse);
    expect(watch.overloadedAfter([]), isFalse);
    expect(watch.overloadedAfter([_late, _late]), isFalse);
    expect(watch.overloadedAfter([_late]), isTrue);
  });
}
