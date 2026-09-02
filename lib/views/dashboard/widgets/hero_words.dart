import 'package:reclash/common/common.dart';

String _pluralWord(int n, String one, String few, String many) {
  if (n % 100 >= 11 && n % 100 <= 19) return many;
  switch (n % 10) {
    case 1:
      return one;
    case 2:
    case 3:
    case 4:
      return few;
    default:
      return many;
  }
}

String heroDaysWord(int days) => _pluralWord(
      days,
      currentAppLocalizations.day,
      currentAppLocalizations.daysGenitive,
      currentAppLocalizations.days,
    );

String _minutesWord(int minutes) => _pluralWord(
      minutes,
      currentAppLocalizations.minute,
      currentAppLocalizations.minutesPlural,
      currentAppLocalizations.minutesGenitive,
    );

String _hoursWord(int hours) => _pluralWord(
      hours,
      currentAppLocalizations.hour,
      currentAppLocalizations.hoursPlural,
      currentAppLocalizations.hoursGenitive,
    );

String heroDurationWords(int? elapsedMinutes) {
  if (elapsedMinutes == null) return '';
  final minutes = elapsedMinutes;
  if (minutes < 1) return currentAppLocalizations.heroJustNow;
  if (minutes < 60) return '$minutes ${_minutesWord(minutes)}';
  final hours = minutes ~/ 60;
  if (hours < 24) {
    final rest = minutes % 60;
    return rest > 0
        ? '$hours ${_hoursWord(hours)} $rest ${_minutesWord(rest)}'
        : '$hours ${_hoursWord(hours)}';
  }
  final days = hours ~/ 24;
  return '$days ${heroDaysWord(days)}';
}

String heroAgoWords(int? sinceEpochMs) {
  if (sinceEpochMs == null || sinceEpochMs <= 0) return '';
  final elapsed = DateTime.now().millisecondsSinceEpoch - sinceEpochMs;
  final minutes = elapsed ~/ 60000;
  if (minutes < 1) return currentAppLocalizations.heroJustNow;
  return currentAppLocalizations.heroRoutingAgo(
    heroDurationWords(minutes),
  );
}
