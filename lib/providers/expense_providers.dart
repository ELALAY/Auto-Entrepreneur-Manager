import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_providers.dart';
import '../models/expense.dart';
import 'auth_provider.dart';

final expensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  final uid = ref.watch(authStateProvider).maybeWhen(
        data: (u) => u?.uid,
        orElse: () => null,
      );
  if (uid == null) return Stream.value([]);
  return ref.watch(expenseRepositoryProvider).watchExpenses(uid);
});

final expenseStreamProvider = StreamProvider.family<Expense?, String>((ref, expenseId) {
  final uid = ref.watch(authStateProvider).maybeWhen(
        data: (u) => u?.uid,
        orElse: () => null,
      );
  if (uid == null) return Stream.value(null);
  return ref.watch(expenseRepositoryProvider).watchExpense(uid, expenseId);
});
