import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/expense/expense_category.dart';

class Expense {
  const Expense({
    required this.id,
    required this.userId,
    required this.date,
    required this.amount,
    required this.category,
    required this.description,
    this.receiptUrl,
  });

  final String id;
  final String userId;
  final DateTime date;
  final double amount;
  final ExpenseCategory category;
  final String description;
  final String? receiptUrl;

  Expense copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? amount,
    ExpenseCategory? category,
    String? description,
    String? receiptUrl,
    bool clearReceiptUrl = false,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      receiptUrl: clearReceiptUrl ? null : (receiptUrl ?? this.receiptUrl),
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'date': Timestamp.fromDate(
        DateTime(date.year, date.month, date.day),
      ),
      'amount': amount,
      'category': category.name,
      'description': description.trim(),
      if (receiptUrl != null && receiptUrl!.isNotEmpty) 'receiptUrl': receiptUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Expense fromFirestoreDoc(
    String uid,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final ts = data['date'];
    DateTime date;
    if (ts is Timestamp) {
      final d = ts.toDate();
      date = DateTime(d.year, d.month, d.day);
    } else {
      date = DateTime.now();
    }
    return Expense(
      id: doc.id,
      userId: uid,
      date: date,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      category: parseExpenseCategoryField(data['category']),
      description: data['description'] as String? ?? '',
      receiptUrl: data['receiptUrl'] as String?,
    );
  }

  static Expense fromFirestoreSnapshot(
    String uid,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final ts = data['date'];
    DateTime date;
    if (ts is Timestamp) {
      final d = ts.toDate();
      date = DateTime(d.year, d.month, d.day);
    } else {
      date = DateTime.now();
    }
    return Expense(
      id: doc.id,
      userId: uid,
      date: date,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      category: parseExpenseCategoryField(data['category']),
      description: data['description'] as String? ?? '',
      receiptUrl: data['receiptUrl'] as String?,
    );
  }
}
