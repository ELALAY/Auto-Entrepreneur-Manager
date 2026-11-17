import '../../domain/expense/expense_category.dart';
import '../../l10n/app_localizations.dart';

String expenseCategoryLabel(AppLocalizations l10n, ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.office:
      return l10n.expenseCategoryOffice;
    case ExpenseCategory.travel:
      return l10n.expenseCategoryTravel;
    case ExpenseCategory.telecom:
      return l10n.expenseCategoryTelecom;
    case ExpenseCategory.rent:
      return l10n.expenseCategoryRent;
    case ExpenseCategory.equipment:
      return l10n.expenseCategoryEquipment;
    case ExpenseCategory.fees:
      return l10n.expenseCategoryFees;
    case ExpenseCategory.marketing:
      return l10n.expenseCategoryMarketing;
    case ExpenseCategory.other:
      return l10n.expenseCategoryOther;
  }
}
