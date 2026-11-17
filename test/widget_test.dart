import 'package:auto_entrepreneur_manager/domain/expense/expense_category.dart';
import 'package:auto_entrepreneur_manager/domain/tax/activity_category.dart';
import 'package:auto_entrepreneur_manager/domain/tax/tax_rates_config.dart';
import 'package:auto_entrepreneur_manager/features/dashboard/dashboard_screen.dart';
import 'package:auto_entrepreneur_manager/l10n/app_localizations.dart';
import 'package:auto_entrepreneur_manager/models/expense.dart';
import 'package:auto_entrepreneur_manager/providers/declaration_providers.dart';
import 'package:auto_entrepreneur_manager/providers/expense_providers.dart';
import 'package:auto_entrepreneur_manager/providers/invoice_providers.dart';
import 'package:auto_entrepreneur_manager/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dashboard shows quarter expenses and estimated IR+CNSS', (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          invoicesSummaryStreamProvider.overrideWith((ref) => Stream.value(const [])),
          declarationsListStreamProvider.overrideWith((ref) => Stream.value(const [])),
          expensesStreamProvider.overrideWith(
            (ref) => Stream.value([
              Expense(
                id: 'in',
                userId: 'u',
                date: DateTime(now.year, now.month, now.day),
                amount: 80,
                category: ExpenseCategory.office,
                description: 'paper',
              ),
              Expense(
                id: 'out',
                userId: 'u',
                date: DateTime(now.year - 1, 1, 15),
                amount: 40,
                category: ExpenseCategory.travel,
                description: 'last year',
              ),
            ]),
          ),
          taxRatesStreamProvider.overrideWith(
            (ref) => Stream.value(TaxRatesConfig.bundledMoroccoDefaults()),
          ),
          userProfileStreamProvider.overrideWith((ref) => Stream.value(null)),
          quarterPaidRevenueByActivityProvider.overrideWith(
            (ref, periodKey) async => {ActivityCategory.commercial: 10000},
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en'), Locale('fr')],
          home: DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Est. declaration (IR+CNSS)'), findsOneWidget);
    expect(find.textContaining('350,00'), findsOneWidget);
    expect(find.textContaining('80,00'), findsOneWidget);
    expect(find.textContaining('40,00'), findsNothing);
  });
}
