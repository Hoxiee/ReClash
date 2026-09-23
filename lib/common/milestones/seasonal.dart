enum SeasonalMotif { newYear, birthday, firstRun, drift }

SeasonalMotif seasonalMotifAt(DateTime now, {DateTime? firstRun}) {
  if ((now.month == 12 && now.day >= 28) || (now.month == 1 && now.day <= 3)) {
    return SeasonalMotif.newYear;
  }
  if (now.month == 9 && now.day == 2) return SeasonalMotif.birthday;
  if (firstRun != null &&
      firstRun.year < now.year &&
      firstRun.month == now.month &&
      firstRun.day == now.day) {
    return SeasonalMotif.firstRun;
  }
  return SeasonalMotif.drift;
}
