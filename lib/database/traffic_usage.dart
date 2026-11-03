part of 'database.dart';

@DataClassName('TrafficUsageRecord')
class TrafficUsage extends Table {
  @override
  String get tableName => 'traffic_usage';

  IntColumn get profileId =>
      integer().references(Profiles, #id, onDelete: KeyAction.cascade)();

  IntColumn get day => integer()();

  IntColumn get bytes => integer()();

  IntColumn get mark => integer()();

  @override
  Set<Column> get primaryKey => {profileId, day};
}

@DriftAccessor(tables: [TrafficUsage])
class TrafficUsageDao extends DatabaseAccessor<Database>
    with _$TrafficUsageDaoMixin {
  TrafficUsageDao(super.attachedDatabase);

  UsageDay _toDay(TrafficUsageRecord row) =>
      UsageDay(row.day, row.bytes, row.mark);

  Stream<List<UsageDay>> watch(int profileId) {
    final stmt = trafficUsage.select()
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([(t) => OrderingTerm.asc(t.day)]);
    return stmt.watch().map((rows) => rows.map(_toDay).toList());
  }

  Future<UsageDay?> _latest(int profileId) async {
    final stmt = trafficUsage.select()
      ..where((t) => t.profileId.equals(profileId))
      ..orderBy([(t) => OrderingTerm.desc(t.day)])
      ..limit(1);
    final row = await stmt.getSingleOrNull();
    return row == null ? null : _toDay(row);
  }

  /// Records [used] bytes, the profile's counter at [at], and drops the days
  /// past [usageRetentionDays].
  Future<void> sample(int profileId, int used, DateTime at) {
    final today = usageDayOf(at);
    return transaction(() async {
      final rows = planUsageSample(
        last: await _latest(profileId),
        used: used,
        today: today,
      );
      for (final row in rows) {
        await trafficUsage.insertOnConflictUpdate(
          TrafficUsageCompanion.insert(
            profileId: profileId,
            day: row.day,
            bytes: row.bytes,
            mark: row.mark,
          ),
        );
      }
      await (trafficUsage.delete()..where(
            (t) =>
                t.profileId.equals(profileId) &
                t.day.isSmallerThanValue(today - usageRetentionDays),
          ))
          .go();
    });
  }
}
