import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/tax/activity_category.dart';

ActivityCategory? parseActivityCategoryField(Object? raw) {
  if (raw is! String || raw.isEmpty) return null;
  for (final c in ActivityCategory.values) {
    if (c.name == raw) return c;
  }
  return null;
}

List<String> catalogLineIdsFromItemsField(Object? itemsRaw) {
  final ids = <String>{};
  if (itemsRaw is! List) return [];
  for (final e in itemsRaw) {
    if (e is Map) {
      final sid = e['serviceId'];
      if (sid is String && sid.isNotEmpty) ids.add(sid);
    }
  }
  return ids.toList();
}

/// Minimal invoice row for lists (e.g. client detail, invoice list).
class InvoiceSummary {
  const InvoiceSummary({
    required this.id,
    required this.number,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    required this.clientId,
    this.clientName = '',
    this.total = 0,
    this.paidTotal = 0,
    this.activityCategory,
    this.catalogLineIds = const [],
  });

  final String id;
  final String number;
  final DateTime issueDate;
  final DateTime dueDate;
  final String status;
  final String clientId;
  final String clientName;
  final double total;
  final double paidTotal;

  /// Snapshot from Firestore; may be null on older invoices.
  final ActivityCategory? activityCategory;

  /// Catalog template ids referenced on line items (`serviceId` in Firestore).
  final List<String> catalogLineIds;

  /// Shared parsing for invoice documents (list + client detail queries).
  factory InvoiceSummary.fromFirestoreDoc(
    String docId,
    Map<String, dynamic> data,
  ) {
    final ts = data['issueDate'];
    DateTime issueDate;
    if (ts is Timestamp) {
      issueDate = ts.toDate();
    } else {
      issueDate = DateTime.fromMillisecondsSinceEpoch(0);
    }
    final dts = data['dueDate'];
    DateTime dueDate;
    if (dts is Timestamp) {
      dueDate = dts.toDate();
    } else {
      dueDate = issueDate;
    }
    return InvoiceSummary(
      id: docId,
      number: data['number'] as String? ?? docId,
      issueDate: issueDate,
      dueDate: dueDate,
      status: data['status'] as String? ?? 'draft',
      clientId: data['clientId'] as String? ?? '',
      clientName: data['clientName'] as String? ?? '',
      total: (data['total'] as num?)?.toDouble() ?? 0,
      paidTotal: (data['paidTotal'] as num?)?.toDouble() ?? 0,
      activityCategory: parseActivityCategoryField(data['activityCategory']),
      catalogLineIds: catalogLineIdsFromItemsField(data['items']),
    );
  }

  double get balance => (total - paidTotal).clamp(0.0, double.infinity);

  bool get isPartiallyPaid => paidTotal > 0 && balance > 0.001;

  bool isOverdueNotPaid() {
    if (status == 'paid' || balance <= 0.001) return false;
    final now = DateTime.now();
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(due);
  }
}
