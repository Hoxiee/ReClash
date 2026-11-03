import 'dart:math' as math;

/// Days of history kept per profile, and the window the pace is read from.
const usageRetentionDays = 60;
const usageWindowDays = 7;

/// What a profile spent in one local calendar [day] (see [usageDayOf]); [mark]
/// is its cumulative use at the last sample, read only on the newest row.
class UsageDay {
  const UsageDay(this.day, this.bytes, this.mark);

  final int day;
  final int bytes;
  final int mark;

  @override
  bool operator ==(Object other) =>
      other is UsageDay &&
      other.day == day &&
      other.bytes == bytes &&
      other.mark == mark;

  @override
  int get hashCode => Object.hash(day, bytes, mark);
}

int usageDayOf(DateTime time) =>
    DateTime.utc(time.year, time.month, time.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

DateTime usageDateOf(int day) => DateTime(1970, 1, 1 + day);

/// The rows a sample of [used] bytes taken on [today] writes, given [last], the
/// profile's newest row. Provider counters only grow between resets, so the
/// growth since [last] is the spending of the days in between: spread evenly
/// when no sample fell on them.
List<UsageDay> planUsageSample({
  required UsageDay? last,
  required int used,
  required int today,
}) {
  if (last == null) return [UsageDay(today, 0, used)];
  final gap = today - last.day;
  if (used < last.mark || gap > usageRetentionDays) {
    final kept = gap <= 0 ? last.bytes : 0;
    return [UsageDay(math.max(today, last.day), kept, used)];
  }
  final delta = used - last.mark;
  if (gap <= 0) return [UsageDay(last.day, last.bytes + delta, used)];
  final share = delta ~/ gap;
  return [
    for (var day = last.day + 1; day < today; day++) UsageDay(day, share, used),
    UsageDay(today, delta - share * (gap - 1), used),
  ];
}

/// Bytes a day, over the whole days before [today] that follow the first
/// sample: the sampling day is partial and so is today. Null until there is one.
int? usagePace(Iterable<UsageDay> days, int today) {
  if (days.isEmpty) return null;
  final first = days.map((day) => day.day).reduce(math.min);
  final start = math.max(first + 1, today - usageWindowDays);
  final count = today - start;
  if (count < 1) return null;
  final total = days
      .where((day) => day.day >= start && day.day < today)
      .fold<int>(0, (sum, day) => sum + day.bytes);
  return total ~/ count;
}

enum TrafficForecastKind {
  /// Too little history to say anything.
  gathering,
  depleted,

  /// The quota is not going to run out in a year, or nothing is spent.
  plenty,

  /// Lasts to the end of the plan.
  lasts,

  /// Runs out on [TrafficForecast.runsOut] with no end of the plan to compare.
  until,

  /// Runs out [TrafficForecast.daysEarly] days before the plan ends.
  early,
}

class TrafficForecast {
  const TrafficForecast(
    this.kind, {
    this.perDay,
    this.runsOut,
    this.daysEarly = 0,
  });

  final TrafficForecastKind kind;
  final int? perDay;
  final DateTime? runsOut;
  final int daysEarly;
}

/// Where the traffic left of [total] ends at the pace of the recent [days].
TrafficForecast forecastTraffic({
  required List<UsageDay> days,
  required int used,
  required int total,
  required DateTime now,
  DateTime? expiry,
}) {
  final perDay = usagePace(days, usageDayOf(now));
  final left = total - used;
  if (left <= 0) {
    return TrafficForecast(TrafficForecastKind.depleted, perDay: perDay);
  }
  if (perDay == null) {
    return const TrafficForecast(TrafficForecastKind.gathering);
  }
  if (perDay == 0) {
    return const TrafficForecast(TrafficForecastKind.plenty, perDay: 0);
  }
  final daysLeft = left / perDay;
  final runsOut = now.add(
    Duration(
      milliseconds: (math.min(daysLeft, 36500) * Duration.millisecondsPerDay)
          .round(),
    ),
  );
  if (expiry == null) {
    return TrafficForecast(
      daysLeft > 365 ? TrafficForecastKind.plenty : TrafficForecastKind.until,
      perDay: perDay,
      runsOut: runsOut,
    );
  }
  final early = expiry.difference(runsOut).inDays;
  return TrafficForecast(
    early >= 1 ? TrafficForecastKind.early : TrafficForecastKind.lasts,
    perDay: perDay,
    runsOut: runsOut,
    daysEarly: math.max(early, 0),
  );
}
