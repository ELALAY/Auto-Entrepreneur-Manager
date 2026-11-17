import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/expense.dart';

class ExpenseRepository {
  ExpenseRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _expenses(String uid) =>
      _firestore.collection('users/$uid/expenses');

  Stream<List<Expense>> watchExpenses(String uid) {
    return _expenses(uid).orderBy('date', descending: true).snapshots().map(
          (snap) =>
              snap.docs.map((d) => Expense.fromFirestoreDoc(uid, d)).toList(),
        );
  }

  Stream<Expense?> watchExpense(String uid, String expenseId) {
    return _expenses(uid).doc(expenseId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return Expense.fromFirestoreSnapshot(uid, snap);
    });
  }

  Future<void> upsertExpense(Expense expense) async {
    final map = expense.toFirestoreMap();
    if (expense.receiptUrl == null) {
      map['receiptUrl'] = FieldValue.delete();
    }
    await _expenses(expense.userId).doc(expense.id).set(map, SetOptions(merge: true));
  }

  Future<void> deleteExpense(String uid, String expenseId) async {
    final snap = await _expenses(uid).doc(expenseId).get();
    if (snap.exists) {
      final url = snap.data()?['receiptUrl'] as String?;
      if (url != null && url.isNotEmpty) {
        try {
          await _storage.refFromURL(url).delete();
        } catch (_) {}
      }
    }
    await _expenses(uid).doc(expenseId).delete();
  }

  /// Stores receipt image at a deterministic path for this expense id.
  Future<String> uploadReceipt(
    String uid,
    String expenseId,
    Uint8List bytes,
    String contentType,
  ) async {
    final ext = contentType.contains('png')
        ? 'png'
        : contentType.contains('webp')
            ? 'webp'
            : 'jpg';
    final ref = _storage.ref('users/$uid/expenses/$expenseId/receipt.$ext');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }

  Future<void> deleteReceiptInStorage(String downloadUrl) async {
    try {
      await _storage.refFromURL(downloadUrl).delete();
    } catch (_) {}
  }
}
