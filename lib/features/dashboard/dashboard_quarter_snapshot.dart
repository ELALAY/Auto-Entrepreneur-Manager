import '../../models/expense.dart';
import '../../utils/quarter_bounds.dart';

/// Sum of expense amounts whose date falls in the civil quarter.
double sumExpensesInQuarter(Iterable<Expense> expenses, int year, int quarter) {
  var total = 0.0;
  for (final expense in expenses) {
    if (dateOnlyInQuarter(expense.date, year, quarter)) {
      total += expense.amount;
    }
  }
  return total;
}
