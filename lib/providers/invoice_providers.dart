import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_providers.dart';
import '../models/invoice.dart';
import '../models/invoice_summary.dart';
import '../models/payment.dart';
import 'auth_provider.dart';

final invoicesSummaryStreamProvider = StreamProvider<List<InvoiceSummary>>((ref) {
  final uid = ref.watch(authStateProvider).maybeWhen(
        data: (u) => u?.uid,
        orElse: () => null,
      );
  if (uid == null) return Stream.value([]);
  return ref.watch(invoiceRepositoryProvider).watchInvoiceSummaries(uid);
});

final invoiceStreamProvider = StreamProvider.family<Invoice?, String>((ref, invoiceId) {
  final uid = ref.watch(authStateProvider).maybeWhen(
        data: (u) => u?.uid,
        orElse: () => null,
      );
  if (uid == null) return Stream.value(null);
  return ref.watch(invoiceRepositoryProvider).watchInvoice(uid, invoiceId);
});

final invoicePaymentsStreamProvider =
    StreamProvider.family<List<Payment>, String>((ref, invoiceId) {
  final uid = ref.watch(authStateProvider).maybeWhen(
        data: (u) => u?.uid,
        orElse: () => null,
      );
  if (uid == null) return Stream.value([]);
  return ref.watch(invoiceRepositoryProvider).watchPayments(uid, invoiceId);
});
