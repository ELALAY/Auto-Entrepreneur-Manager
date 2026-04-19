import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase_providers.dart';
import '../models/catalog_item.dart';
import 'auth_provider.dart';

final catalogItemsStreamProvider = StreamProvider<List<CatalogItem>>((ref) {
  final uid = ref.watch(authStateProvider).maybeWhen(
        data: (u) => u?.uid,
        orElse: () => null,
      );
  if (uid == null) return Stream.value([]);
  return ref.watch(catalogRepositoryProvider).watchCatalogItems(uid);
});

final catalogItemStreamProvider =
    StreamProvider.family<CatalogItem?, String>((ref, itemId) {
  final uid = ref.watch(authStateProvider).maybeWhen(
        data: (u) => u?.uid,
        orElse: () => null,
      );
  if (uid == null) return Stream.value(null);
  return ref.watch(catalogRepositoryProvider).watchCatalogItem(uid, itemId);
});
