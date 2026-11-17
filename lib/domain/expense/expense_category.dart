/// Tax-relevant buckets for auto-entrepreneur expense tracking.
/// Persisted in Firestore as [ExpenseCategory.name].
enum ExpenseCategory {
  office,
  travel,
  telecom,
  rent,
  equipment,
  fees,
  marketing,
  other,
}

ExpenseCategory parseExpenseCategoryField(Object? raw) {
  if (raw is! String || raw.isEmpty) return ExpenseCategory.other;
  for (final c in ExpenseCategory.values) {
    if (c.name == raw) return c;
  }
  return ExpenseCategory.other;
}
