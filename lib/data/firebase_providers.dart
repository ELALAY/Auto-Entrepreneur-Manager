import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_repository.dart';
import 'client_repository.dart';
import 'declaration_repository.dart';
import 'invoice_repository.dart';
import 'profile_repository.dart';
import 'tax_rates_repository.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    ref.watch(firebaseFirestoreProvider),
    ref.watch(firebaseStorageProvider),
  );
});

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository(ref.watch(firebaseFirestoreProvider));
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(firebaseFirestoreProvider));
});

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository(ref.watch(firebaseFirestoreProvider));
});

final taxRatesRepositoryProvider = Provider<TaxRatesRepository>((ref) {
  return TaxRatesRepository(ref.watch(firebaseFirestoreProvider));
});

final declarationRepositoryProvider = Provider<DeclarationRepository>((ref) {
  return DeclarationRepository(ref.watch(firebaseFirestoreProvider));
});
