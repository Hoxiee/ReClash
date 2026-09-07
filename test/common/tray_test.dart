import 'package:reclash/common/tray.dart';
import 'package:test/test.dart';

void main() {
  group('AppTray.getTrayIcon', () {
    final windows = AppTray.forPlatform(isMacOS: false, isWindows: true);
    final macOS = AppTray.forPlatform(isMacOS: true, isWindows: false);
    final linux = AppTray.forPlatform(isMacOS: false, isWindows: false);

    test('windows loads ico files from the windows directory', () {
      expect(
        windows.getTrayIcon(isStart: false, tunEnable: false, paused: false),
        'assets/images/tray/windows/status_1.ico',
      );
      expect(
        windows.getTrayIcon(isStart: true, tunEnable: false, paused: false),
        'assets/images/tray/windows/status_2.ico',
      );
      expect(
        windows.getTrayIcon(isStart: true, tunEnable: true, paused: false),
        'assets/images/tray/windows/status_3.ico',
      );
    });

    test('linux loads png files from the unix directory', () {
      expect(
        linux.getTrayIcon(isStart: false, tunEnable: false, paused: false),
        'assets/images/tray/unix/status_1.png',
      );
      // A paused core still runs unprotected traffic, matching a disabled TUN.
      expect(
        linux.getTrayIcon(isStart: true, tunEnable: false, paused: false),
        'assets/images/tray/unix/status_2.png',
      );
      expect(
        linux.getTrayIcon(isStart: true, tunEnable: true, paused: false),
        'assets/images/tray/unix/status_3.png',
      );
      expect(
        linux.getTrayIcon(isStart: true, tunEnable: true, paused: true),
        'assets/images/tray/unix/status_2.png',
      );
    });

    test('macOS keeps the template icon in every state', () {
      for (final (isStart, tunEnable, paused) in [
        (false, false, false),
        (true, false, false),
        (true, true, false),
        (true, true, true),
      ]) {
        expect(
          macOS.getTrayIcon(
            isStart: isStart,
            tunEnable: tunEnable,
            paused: paused,
          ),
          'assets/images/tray/unix/status_1.png',
        );
      }
    });
  });
}
