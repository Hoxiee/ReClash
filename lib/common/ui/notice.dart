import 'dart:io';

import 'package:reclash/common/common.dart';
import 'package:reclash/enum/enum.dart';
import 'package:reclash/plugins/app.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

const _maxNoticeTitleLength = 80;

/// Panels write these strings and they reach argv unchecked: one line, and no
/// leading dashes for the desktop senders to read as flags.
String sanitizeNoticeText(
  String value, {
  int maxLength = _maxNoticeTitleLength,
}) {
  final single = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  final bare = single.replaceFirst(RegExp('^-+'), '').trim();
  return bare.length <= maxLength ? bare : '${bare.substring(0, maxLength)}…';
}

class NoticeRequest {
  final String channelName;
  final String notificationKey;
  final String title;
  final String message;
  final String? actionLabel;
  final String? actionUrl;

  const NoticeRequest({
    required this.channelName,
    required this.notificationKey,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionUrl,
  });

  @override
  String toString() => 'NoticeRequest($title, $message, $actionUrl)';
}

/// One-off notices, apart from the ongoing service notification Android owns.
/// Desktop delivery leans on the session's own sender, or does not happen.
class SystemNotice {
  static SystemNotice? _instance;

  @visibleForTesting
  ProcessRunner runProcess = Process.run;

  SystemNotice._internal();

  factory SystemNotice() {
    _instance ??= SystemNotice._internal();
    return _instance!;
  }

  static List<String> linuxArguments(NoticeRequest notice) => [
    '--app-name=$appName',
    '--urgency=normal',
    '--',
    notice.title,
    notice.message,
  ];

  static List<String> macOSArguments(NoticeRequest notice) => [
    '-e',
    'on run argv',
    '-e',
    'display notification (item 1 of argv) with title (item 2 of argv)',
    '-e',
    'end run',
    notice.message,
    notice.title,
  ];

  Future<bool> show(NoticeRequest notice) async {
    try {
      if (system.isAndroid) {
        return await app?.showNotice(
              channelName: notice.channelName,
              notificationKey: notice.notificationKey,
              title: notice.title,
              message: notice.message,
              actionLabel: notice.actionLabel,
              actionUrl: notice.actionUrl,
            ) ??
            false;
      }
      if (system.isLinux) {
        return await _runSender('notify-send', linuxArguments(notice));
      }
      if (system.isMacOS) {
        return await _runSender('osascript', macOSArguments(notice));
      }
      return false;
    } catch (error) {
      commonPrint.log(
        'Unable to show a notice: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      return false;
    }
  }

  Future<bool> _runSender(String executable, List<String> arguments) async {
    final result = await runProcess(executable, arguments);
    if (result.exitCode == 0) {
      return true;
    }
    commonPrint.log(
      '$executable exited with ${result.exitCode}: '
      '${result.stderr.toString().trim()}',
      logLevel: LogLevel.warning,
    );
    return false;
  }
}

final systemNotice = SystemNotice();
