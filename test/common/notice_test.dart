import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/ui/notice.dart';
import 'package:reclash/common/util/constant.dart';
import 'package:reclash/l10n/l10n.dart';
import 'package:reclash/plugins/app.dart';
import 'package:reclash/providers/config.dart';
import 'package:reclash/state.dart';

const _notice = NoticeRequest(
  channelName: 'Subscription reminders',
  notificationKey: 'subscription:42',
  title: 'Kiwi VPN',
  message: 'Your subscription expires today',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Android reminders follow the current privacy flag with neutral public text',
    () async {
      await AppLocalizations.load(const Locale('en'));
      final container = ProviderContainer();
      globalState.container = container;
      final hold = container.listen(appSettingProvider, (_, _) {});
      const channel = MethodChannel('$packageName/app');
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return true;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
        hold.close();
        container.dispose();
      });

      for (final hide in [true, false]) {
        container
            .read(appSettingProvider.notifier)
            .update(
              (state) => state.copyWith(
                notificationSettings: state.notificationSettings.copyWith(
                  hideSensitiveOnLockScreen: hide,
                ),
              ),
            );
        expect(await SystemNotice().showAndroid(_notice, App()), isTrue);
        final call = calls.last;
        expect(call.method, 'showNotice');
        expect(call.arguments, containsPair('hideSensitiveOnLockScreen', hide));
        expect(
          call.arguments,
          containsPair('publicMessage', 'Subscription reminders'),
        );
        expect(call.arguments, containsPair('title', _notice.title));
        expect(call.arguments, containsPair('message', _notice.message));
      }
    },
  );

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
