import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/tax/tax_rates_config.dart';

/// Reads versioned parameters from `config/taxRates` (maintain via Console / Admin SDK).
class TaxRatesRepository {
  TaxRatesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const String configCollection = 'config';
  static const String taxRatesDocId = 'taxRates';

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection(configCollection).doc(taxRatesDocId);

  Stream<TaxRatesConfig?> watchTaxRates() {
    return _doc.snapshots().map((snap) => TaxRatesConfig.fromFirestoreData(snap.data()));
  }

  Future<TaxRatesConfig?> fetchTaxRates() async {
    final snap = await _doc.get();
    return TaxRatesConfig.fromFirestoreData(snap.data());
  }
}
