/// Inclusive calendar bounds for a civil quarter (Morocco uses same calendar year).
(DateTime start, DateTime end) quarterDateBounds(int year, int quarter) {
  assert(quarter >= 1 && quarter <= 4);
  final firstMonth = (quarter - 1) * 3 + 1;
  final start = DateTime(year, firstMonth, 1);
  final lastMonth = firstMonth + 2;
  final end = DateTime(year, lastMonth + 1, 0);
  return (start, end);
}

bool dateOnlyInQuarter(DateTime instant, int year, int quarter) {
  final d = DateTime(instant.year, instant.month, instant.day);
  final (a, b) = quarterDateBounds(year, quarter);
  final start = DateTime(a.year, a.month, a.day);
  final end = DateTime(b.year, b.month, b.day);
  return !d.isBefore(start) && !d.isAfter(end);
}
