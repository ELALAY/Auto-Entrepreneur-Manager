import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_providers.dart';
import '../domain/tax/activity_category.dart';
import '../models/declaration.dart';
import '../domain/tax/tax_rates_config.dart';
import '../providers/auth_provider.dart';
import 'profile_providers.dart';

export '../utils/declaration_filing_deadline.dart' show declarationPeriodKey;

/// Effective rates from Firestore `config/taxRates`, or [TaxRatesConfig.bundledMoroccoDefaults]
/// when the document is missing / unparsable so declarations always load.
final taxRatesStreamProvider = StreamProvider<TaxRatesConfig>((ref) {
  return ref.watch(taxRatesRepositoryProvider).watchTaxRates().map(
        (remote) => remote ?? TaxRatesConfig.bundledMoroccoDefaults(),
      );
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

/// Cash-basis revenue in the quarter grouped by invoice activity (IR split).
final quarterPaidRevenueByActivityProvider =
    FutureProvider.autoDispose.family<Map<ActivityCategory, double>, String>(
        (ref, periodKey) async {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return {};
  final parts = periodKey.split('-');
  if (parts.length != 2) return {};
  final year = int.tryParse(parts[0]);
  final quarter = int.tryParse(parts[1]);
  if (year == null || quarter == null) return {};
  final profile = ref.watch(userProfileStreamProvider).valueOrNull;
  final fallback = profile?.activityCategory ?? ActivityCategory.commercial;
  return ref.read(invoiceRepositoryProvider).sumPaidRevenueByActivityInQuarter(
        uid,
        year,
        quarter,
        fallback,
      );
});
