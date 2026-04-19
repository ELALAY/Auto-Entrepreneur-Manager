import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/declaration.dart';
import '../models/enums.dart';

class DeclarationRepository {
  DeclarationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _decl(String uid) =>
      _firestore.collection('users/$uid/declarations');

  static String docIdForPeriod(int year, int quarter) => '${year}_Q$quarter';

  Stream<List<Declaration>> watchDeclarations(String uid) {
    return _decl(uid).orderBy('periodSort', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => _fromDoc(uid, d.id, d.data())).toList(),
        );
  }

  Stream<Declaration?> watchDeclaration(String uid, int year, int quarter) {
    final id = docIdForPeriod(year, quarter);
    return _decl(uid).doc(id).snapshots().map((snap) {
      if (!snap.exists) return null;
      return _fromDoc(uid, snap.id, snap.data()!);
    });
  }

  Future<void> saveDeclaration({
    required String uid,
    required int year,
    required int quarter,
    required double totalRevenue,
    required double irAmount,
    required double cnssAmount,
    required DeclarationStatus status,
    required int taxRatesVersion,
  }) async {
    final id = docIdForPeriod(year, quarter);
    final ref = _decl(uid).doc(id);
    final existing = await ref.get();
    final data = <String, dynamic>{
      'year': year,
      'quarter': quarter,
      'periodSort': year * 100 + quarter,
      'totalRevenue': totalRevenue,
      'irAmount': irAmount,
      'cnssAmount': cnssAmount,
      'status': status.name,
      'taxRatesVersion': taxRatesVersion,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!existing.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await ref.set(data, SetOptions(merge: true));
  }

  Future<void> markFiled({
    required String uid,
    required int year,
    required int quarter,
    required DateTime filedDate,
  }) async {
    final id = docIdForPeriod(year, quarter);
    await _decl(uid).doc(id).set(
      {
        'year': year,
        'quarter': quarter,
        'periodSort': year * 100 + quarter,
        'status': DeclarationStatus.filed.name,
        'filedDate': Timestamp.fromDate(filedDate),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Declaration _fromDoc(String uid, String id, Map<String, dynamic> data) {
    return Declaration(
      id: id,
      userId: uid,
      year: (data['year'] as num?)?.toInt() ?? 0,
      quarter: (data['quarter'] as num?)?.toInt() ?? 1,
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0,
      irAmount: (data['irAmount'] as num?)?.toDouble() ?? 0,
      cnssAmount: (data['cnssAmount'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(data['status'] as String?),
      filedDate: (data['filedDate'] as Timestamp?)?.toDate(),
      taxRatesVersion: (data['taxRatesVersion'] as num?)?.toInt(),
    );
  }

  DeclarationStatus _parseStatus(String? s) {
    return DeclarationStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => DeclarationStatus.draft,
    );
  }
}
