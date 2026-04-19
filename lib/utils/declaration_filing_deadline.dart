/// Quarterly turnover declaration for Morocco AE: filing is due by the last day
/// of the month following each quarter (April, July, October; Q4 → January next year).

/// Stable period key aligned with declaration providers (`year-quarter`, e.g. `2026-1`).
String declarationPeriodKey(int year, int quarter) => '$year-$quarter';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Last calendar day of the civil quarter [year]-Q[quarter] (the period covered).
DateTime quarterEndDate(int year, int quarter) {
  assert(quarter >= 1 && quarter <= 4);
  return DateTime(year, quarter * 3 + 1, 0);
}

/// Last calendar day to submit the declaration for [year]-Q[quarter] (inclusive).
DateTime filingDeadlineDate(int year, int quarter) {
  assert(quarter >= 1 && quarter <= 4);
  final quarterEndMonth = quarter * 3;
  final deadlineMonth = quarterEndMonth + 1;
  if (deadlineMonth > 12) {
    return DateTime(year + 1, 2, 0);
  }
  return DateTime(year, deadlineMonth + 1, 0);
}

DeclarationFilingStatus _statusForPeriod(
  int year,
  int quarter,
  DateTime today,
) {
  final deadline = _dateOnly(filingDeadlineDate(year, quarter));
  final daysRemaining = deadline.difference(today).inDays;
  return DeclarationFilingStatus(
    declarationYear: year,
    declarationQuarter: quarter,
    deadline: deadline,
    daysRemaining: daysRemaining,
  );
}

/// Most recent civil quarter that has fully ended before [today] (date-only).
({int year, int quarter}) latestEndedQuarter(DateTime now) {
  final today = _dateOnly(now);
  var y = now.year;
  var q = ((now.month - 1) ~/ 3) + 1;
  while (true) {
    final qEnd = _dateOnly(quarterEndDate(y, q));
    if (today.isAfter(qEnd)) {
      return (year: y, quarter: q);
    }
    if (q == 1) {
      y--;
      q = 4;
    } else {
      q--;
    }
  }
}

/// The **latest civil quarter that has already ended**: if that period is not yet
/// filed, surface it; otherwise nothing (older quarters are ignored).
DeclarationFilingStatus? outstandingDeclarationFiling({
  required DateTime now,
  required bool Function(int year, int quarter) isQuarterFiled,
}) {
  final today = _dateOnly(now);
  final latest = latestEndedQuarter(now);
  if (isQuarterFiled(latest.year, latest.quarter)) {
    return null;
  }
  return _statusForPeriod(latest.year, latest.quarter, today);
}

class DeclarationFilingStatus {
  const DeclarationFilingStatus({
    required this.declarationYear,
    required this.declarationQuarter,
    required this.deadline,
    required this.daysRemaining,
  });

  final int declarationYear;
  final int declarationQuarter;
  final DateTime deadline;

  /// Positive / zero = days until deadline; negative = days past deadline.
  final int daysRemaining;

  String get periodKey =>
      declarationPeriodKey(declarationYear, declarationQuarter);
}

/// Nearest future filing deadline among quarters not yet filed (dashboard stats).
DeclarationFilingStatus? nextDeclarationFilingCountdown(
  DateTime now, {
  required bool Function(int year, int quarter) isQuarterFiled,
}) {
  final today = _dateOnly(now);
  DeclarationFilingStatus? best;

  for (final year in [now.year - 1, now.year, now.year + 1]) {
    for (var q = 1; q <= 4; q++) {
      if (isQuarterFiled(year, q)) continue;
      final dl = _dateOnly(filingDeadlineDate(year, q));
      if (dl.isBefore(today)) continue;
      final daysRemaining = dl.difference(today).inDays;
      final cand = DeclarationFilingStatus(
        declarationYear: year,
        declarationQuarter: q,
        deadline: dl,
        daysRemaining: daysRemaining,
      );
      final b = best;
      if (b == null || cand.deadline.isBefore(b.deadline)) {
        best = cand;
      }
    }
  }
  return best;
}
