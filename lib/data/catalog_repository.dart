import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/tax/activity_category.dart';
import '../models/catalog_item.dart';

class CatalogRepository {
  CatalogRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _items(String uid) =>
      _firestore.collection('users/$uid/catalogItems');

  Stream<List<CatalogItem>> watchCatalogItems(String uid) {
    return _items(uid).orderBy('description').snapshots().map((snap) {
      return snap.docs.map((d) => _fromDoc(uid, d)).toList();
    });
  }

  Stream<CatalogItem?> watchCatalogItem(String uid, String itemId) {
    return _items(uid).doc(itemId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return _fromDoc(uid, snap);
    });
  }

  Future<void> upsertItem(CatalogItem item) {
    return _items(item.userId).doc(item.id).set(_toMap(item));
  }

  Future<void> deleteItem(String uid, String itemId) {
    return _items(uid).doc(itemId).delete();
  }

  CatalogItem _fromDoc(String uid, DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final kind = _parseKind(data['kind'] as String?);
    final ac = _parseActivityCategory(data['activityCategory'] as String?);
    return CatalogItem(
      id: doc.id,
      userId: uid,
      description: data['description'] as String? ?? '',
      defaultUnitPrice: (data['defaultUnitPrice'] as num?)?.toDouble() ?? 0,
      kind: kind,
      activityCategory: ac ??
          (kind == CatalogKind.product
              ? ActivityCategory.commercial
              : ActivityCategory.services),
    );
  }

  ActivityCategory? _parseActivityCategory(String? s) {
    if (s == null || s.isEmpty) return null;
    for (final v in ActivityCategory.values) {
      if (v.name == s) return v;
    }
    return null;
  }

  Map<String, dynamic> _toMap(CatalogItem item) {
    return {
      'description': item.description.trim(),
      'defaultUnitPrice': item.defaultUnitPrice,
      'kind': item.kind.name,
      'activityCategory': item.activityCategory.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CatalogKind _parseKind(String? s) {
    return CatalogKind.values.firstWhere(
      (e) => e.name == s,
      orElse: () => CatalogKind.service,
    );
  }
}
