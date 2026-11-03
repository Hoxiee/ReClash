import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reclash/database/database.dart';
import 'package:reclash/features/traffic_forecast/forecast.dart';
import 'package:reclash/models/models.dart';

void main() {
  late Database database;

  setUp(() async {
    database = Database(NativeDatabase.memory());
    await database.profilesDao.putAll([
      const Profile(
        id: 1,
        label: 'One',
        autoUpdateDuration: Duration.zero,
      ).toCompanion(),
    ]);
  });

  tearDown(() => database.close());

  Future<List<UsageDay>> read() => database.trafficUsageDao.watch(1).first;

  test('samples add up per local day', () async {
    final dao = database.trafficUsageDao;
    await dao.sample(1, 100, DateTime(2026, 11, 1, 9));
    await dao.sample(1, 160, DateTime(2026, 11, 1, 20));
    await dao.sample(1, 200, DateTime(2026, 11, 3, 8));

    final first = usageDayOf(DateTime(2026, 11, 1));
    expect(await read(), [
      UsageDay(first, 60, 160),
      UsageDay(first + 1, 20, 200),
      UsageDay(first + 2, 20, 200),
    ]);
  });

  test('days past the retention are dropped', () async {
    final dao = database.trafficUsageDao;
    final start = DateTime(2026, 1, 1);
    await dao.sample(1, 0, start);
    await dao.sample(1, 10, DateTime(2026, 1, 41));
    await dao.sample(1, 20, DateTime(2026, 1, 81));

    final days = await read();
    expect(days.first.day, greaterThanOrEqualTo(usageDayOf(start) + 20));
    expect(days.last.mark, 20);
  });

  test('deleting a profile deletes its usage', () async {
    await database.trafficUsageDao.sample(1, 5, DateTime(2026, 11, 1));
    await database.customStatement('DELETE FROM profiles WHERE id = 1');

    expect(await read(), isEmpty);
  });
}
