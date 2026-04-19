import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_providers.dart';
import '../models/client.dart';
import '../models/invoice_summary.dart';
import 'auth_provider.dart';

final clientsStreamProvider = StreamProvider<List<Client>>((ref) {
  final uid = ref.watch(authStateProvider).maybeWhen(
        data: (u) => u?.uid,
        orElse: () => null,
      );
  if (uid == null) return Stream.value([]);
  return ref.watch(clientRepositoryProvider).watchClients(uid);
});

final clientStreamProvider = StreamProvider.family<Client?, String>((ref, clientId) {
  final uid = ref.watch(authStateProvider).maybeWhen(
        data: (u) => u?.uid,
        orElse: () => null,
      );
  if (uid == null) return Stream.value(null);
  return ref.watch(clientRepositoryProvider).watchClient(uid, clientId);
});

final invoicesForClientProvider =
    StreamProvider.family<List<InvoiceSummary>, String>((ref, clientId) {
  final uid = ref.watch(authStateProvider).maybeWhen(
        data: (u) => u?.uid,
        orElse: () => null,
      );
  if (uid == null) return Stream.value([]);
  return ref.watch(clientRepositoryProvider).watchInvoicesForClient(uid, clientId);
});
