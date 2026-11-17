import 'package:auto_entrepreneur_manager/domain/expense/expense_category.dart';
import 'package:auto_entrepreneur_manager/features/dashboard/dashboard_quarter_snapshot.dart';
import 'package:auto_entrepreneur_manager/models/expense.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sumExpensesInQuarter keeps only expenses in that quarter', () {
    final expenses = [
      Expense(
        id: '1',
        userId: 'u',
        date: DateTime(2026, 11, 2),
        amount: 80,
        category: ExpenseCategory.office,
        description: 'paper',
      ),
      Expense(
        id: '2',
        userId: 'u',
        date: DateTime(2026, 1, 15),
        amount: 40,
        category: ExpenseCategory.travel,
        description: 'train',
      ),
    ];

    expect(sumExpensesInQuarter(expenses, 2026, 4), 80);
    expect(sumExpensesInQuarter(expenses, 2026, 1), 40);
  });
}
