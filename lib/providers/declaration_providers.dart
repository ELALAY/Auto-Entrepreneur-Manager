import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_providers.dart';
import '../models/declaration.dart';
import '../domain/tax/tax_rates_config.dart';
import '../providers/auth_provider.dart';

String declarationPeriodKey(int year, int quarter) => '$year-$quarter';

final taxRatesStreamProvider = StreamProvider<TaxRatesConfig?>((ref) {
  return ref.watch(taxRatesRepositoryProvider).watchTaxRates();
});

final declarationsListStreamProvider = StreamProvider<List<Declaration>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) {
    return Stream.value(const <Declaration>[]);
  }
  return ref.watch(declarationRepositoryProvider).watchDeclarations(uid);
});

final declarationForPeriodStreamProvider =
    StreamProvider.autoDispose.family<Declaration?, String>((ref, periodKey) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(null);
  final parts = periodKey.split('-');
  if (parts.length != 2) return Stream.value(null);
  final year = int.tryParse(parts[0]);
  final quarter = int.tryParse(parts[1]);
  if (year == null || quarter == null) return Stream.value(null);
  return ref.watch(declarationRepositoryProvider).watchDeclaration(uid, year, quarter);
});

final quarterPaidRevenueProvider =
    FutureProvider.autoDispose.family<double, String>((ref, periodKey) async {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return 0;
  final parts = periodKey.split('-');
  if (parts.length != 2) return 0;
  final year = int.tryParse(parts[0]);
  final quarter = int.tryParse(parts[1]);
  if (year == null || quarter == null) return 0;
  return ref.watch(invoiceRepositoryProvider).sumPaidRevenueInQuarter(uid, year, quarter);
});
