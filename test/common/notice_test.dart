import 'dart:io';

import 'package:reclash/common/ui/notice.dart';
import 'package:flutter_test/flutter_test.dart';

const _notice = NoticeRequest(
  channelName: 'Subscription reminders',
  notificationKey: 'subscription:42',
  title: 'Kiwi VPN',
  message: 'Your subscription expires today',
);

void main() {
  test('panel text arrives as one short line', () {
    expect(sanitizeNoticeText('  Kiwi\n\tVPN  '), 'Kiwi VPN');
    expect(sanitizeNoticeText('--urgency=critical'), 'urgency=critical');
    expect(sanitizeNoticeText('abcdef', maxLength: 3), 'abc…');
    expect(sanitizeNoticeText('abc', maxLength: 3), 'abc');
  });

  test('notify-send takes the text as operands, never as flags', () {
    final arguments = SystemNotice.linuxArguments(_notice);

    expect(arguments.last, _notice.message);
    expect(arguments[arguments.indexOf('--') + 1], _notice.title);
  });

  test('osascript takes the text as arguments, never as source', () {
    final arguments = SystemNotice.macOSArguments(_notice);

    expect(arguments.sublist(arguments.length - 2), [
      _notice.message,
      _notice.title,
    ]);
    expect(
      arguments.where((argument) => argument.contains(_notice.title)),
      hasLength(1),
    );
  });

  test('a sender that fails is reported as no notice shown', () async {
    final notice = SystemNotice();
    final senders = <String>[];
    notice.runProcess = (executable, arguments) async {
      senders.add(executable);
      return ProcessResult(0, 1, '', 'no notification daemon');
    };
    addTearDown(() => notice.runProcess = Process.run);

    expect(await notice.show(_notice), isFalse);
    if (Platform.isLinux) {
      expect(senders, ['notify-send']);
    } else if (Platform.isMacOS) {
      expect(senders, ['osascript']);
    }
  });
}
