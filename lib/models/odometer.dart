class OdometerSnapshot {
  final int firstRunMillis;
  final int streakMillis;
  final int bestStreakMillis;
  final int totalCoveredMillis;
  final int stitchCount;
  final int sessions;
  final int upBytes;
  final int downBytes;
  final int exams;
  final int examsClean;
  final int autoDecisions;
  final int manualSwitches;
  final int quietManualMillis;
  final int ladderTop;
  final bool ladderCompleted;
  final List<String> countries;
  final int recoveries;
  final int cleanDayRun;
  final int bestCleanDayRun;

  const OdometerSnapshot({
    this.firstRunMillis = 0,
    this.streakMillis = 0,
    this.bestStreakMillis = 0,
    this.totalCoveredMillis = 0,
    this.stitchCount = 0,
    this.sessions = 0,
    this.upBytes = 0,
    this.downBytes = 0,
    this.exams = 0,
    this.examsClean = 0,
    this.autoDecisions = 0,
    this.manualSwitches = 0,
    this.quietManualMillis = 0,
    this.ladderTop = 0,
    this.ladderCompleted = false,
    this.countries = const [],
    this.recoveries = 0,
    this.cleanDayRun = 0,
    this.bestCleanDayRun = 0,
  });

  factory OdometerSnapshot.fromJson(Map<String, dynamic> json) {
    int number(String key) => (json[key] as num?)?.toInt() ?? 0;
    return OdometerSnapshot(
      firstRunMillis: number('firstRunMillis'),
      streakMillis: number('streakMillis'),
      bestStreakMillis: number('bestStreakMillis'),
      totalCoveredMillis: number('totalCoveredMillis'),
      stitchCount: number('stitchCount'),
      sessions: number('sessions'),
      upBytes: number('upBytes'),
      downBytes: number('downBytes'),
      exams: number('exams'),
      examsClean: number('examsClean'),
      autoDecisions: number('autoDecisions'),
      manualSwitches: number('manualSwitches'),
      quietManualMillis: number('quietManualMillis'),
      ladderTop: number('ladderTop'),
      ladderCompleted: json['ladderCompleted'] == true,
      countries:
          (json['countries'] as List?)?.whereType<String>().toList() ??
          const [],
      recoveries: number('recoveries'),
      cleanDayRun: number('cleanDayRun'),
      bestCleanDayRun: number('bestCleanDayRun'),
    );
  }
}

enum OdometerSignalKind { prepareUp, prepareDown, ladder }

class OdometerSignal {
  final OdometerSignalKind kind;
  final String? reason;
  final int? value;

  const OdometerSignal(this.kind, {this.reason, this.value});

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    if (reason != null) 'reason': reason,
    if (value != null) 'value': value,
  };
}
