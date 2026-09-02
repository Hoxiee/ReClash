import 'package:reclash/common/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('ProtocolRegistrationPlan', () {
    test('builds registry writes for URL protocol registration', () {
      const plan = ProtocolRegistrationPlan(
        scheme: 'reclash',
        executable: r'C:\Program Files\ReClash\ReClash.exe',
      );

      expect(plan.protocolKey, r'Software\Classes\reclash');
      expect(plan.commandKey, r'shell\open\command');
      expect(plan.protocolValueName, 'URL Protocol');
      expect(plan.protocolValue, '');
      expect(plan.command, r'"C:\Program Files\ReClash\ReClash.exe" "%1"');
    });
  });
}
