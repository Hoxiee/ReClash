import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/models/models.dart';

void main() {
  test('reserved-suffix stubs are undialable', () {
    const inspection = ConfigInspection(
      servers: ['auto-wifi.local', 'node.example'],
    );
    expect(hasDialableNode(inspection), isFalse);
  });

  test('one real host keeps the payload', () {
    const inspection = ConfigInspection(
      servers: ['auto-wifi.local', 'de.lzkonline.xyz'],
    );
    expect(hasDialableNode(inspection), isTrue);
  });

  test('dot-terminated and cased hosts still match the suffix', () {
    const inspection = ConfigInspection(servers: ['Auto-Wifi.LOCAL.']);
    expect(hasDialableNode(inspection), isFalse);
  });

  test('providers and inspect errors never block the payload', () {
    const providers = ConfigInspection(servers: [], providers: true);
    const failed = ConfigInspection(servers: [], error: 'read failed');
    expect(hasDialableNode(providers), isTrue);
    expect(hasDialableNode(failed), isTrue);
  });

  test('an empty server list is undialable', () {
    const inspection = ConfigInspection(servers: []);
    expect(hasDialableNode(inspection), isFalse);
  });

  test('fromJson reads the core payload', () {
    final inspection = ConfigInspection.fromJson({
      'servers': ['a.local', 'b.example.com'],
      'providers': false,
    });
    expect(inspection.servers, ['a.local', 'b.example.com']);
    expect(inspection.providers, isFalse);
  });
}
