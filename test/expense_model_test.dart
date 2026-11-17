import 'package:auto_entrepreneur_manager/domain/expense/expense_category.dart';
import 'package:auto_entrepreneur_manager/utils/quarter_bounds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseCategory', () {
    test('parseExpenseCategoryField maps unknown to other', () {
      expect(parseExpenseCategoryField(null), ExpenseCategory.other);
      expect(parseExpenseCategoryField(''), ExpenseCategory.other);
      expect(parseExpenseCategoryField('office'), ExpenseCategory.office);
      expect(parseExpenseCategoryField('nosuch'), ExpenseCategory.other);
    });
  });

  group('quarter_bounds helpers', () {
    test('calendarQuarterContaining', () {
      expect(calendarQuarterContaining(DateTime(2026, 1, 15)), (2026, 1));
      expect(calendarQuarterContaining(DateTime(2026, 4, 1)), (2026, 2));
      expect(calendarQuarterContaining(DateTime(2026, 12, 31)), (2026, 4));
    });

    test('dateInCalendarMonth', () {
      expect(
        dateInCalendarMonth(DateTime(2026, 3, 10), 2026, 3),
        true,
      );
      expect(
        dateInCalendarMonth(DateTime(2026, 3, 10), 2026, 4),
        false,
      );
    });
  });
}
