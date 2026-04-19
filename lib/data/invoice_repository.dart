import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/enums.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/invoice_summary.dart';
import '../models/payment.dart';
import '../utils/quarter_bounds.dart';

class InvoiceRepository {
  InvoiceRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _counterRef(String uid) =>
      _firestore.doc('users/$uid/meta/invoiceCounter');

  CollectionReference<Map<String, dynamic>> _invoices(String uid) =>
      _firestore.collection('users/$uid/invoices');

  CollectionReference<Map<String, dynamic>> _payments(String uid, String invoiceId) =>
      _firestore.collection('users/$uid/invoices/$invoiceId/payments');

  Stream<List<InvoiceSummary>> watchInvoiceSummaries(String uid) {
    return _invoices(uid)
        .orderBy('issueDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _summaryFromDoc(d)).toList());
  }

  Stream<Invoice?> watchInvoice(String uid, String invoiceId) {
    return _invoices(uid).doc(invoiceId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return _invoiceFromDoc(uid, snap);
    });
  }

  Stream<List<Payment>> watchPayments(String uid, String invoiceId) {
    return _payments(uid, invoiceId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _paymentFromDoc(uid, invoiceId, d)).toList());
  }

  /// Sum of payment amounts whose [Payment.date] falls in the given civil quarter (cash-basis revenue).
  Future<double> sumPaidRevenueInQuarter(String uid, int year, int quarter) async {
    final invSnap = await _invoices(uid).get();
    var sum = 0.0;
    for (final inv in invSnap.docs) {
      final paySnap = await _payments(uid, inv.id).get();
      for (final p in paySnap.docs) {
        final ts = p.data()['date'];
        if (ts is! Timestamp) continue;
        final date = ts.toDate();
        if (dateOnlyInQuarter(date, year, quarter)) {
          sum += (p.data()['amount'] as num?)?.toDouble() ?? 0;
        }
      }
    }
    return sum;
  }

  /// Assigns sequential [number] via transaction; returns new invoice id.
  Future<String> createInvoice({
    required String uid,
    required String clientId,
    required String clientName,
    required String clientAddress,
    required String clientIce,
    required String clientIf,
    required DateTime issueDate,
    required DateTime dueDate,
    required InvoiceStatus status,
    required List<InvoiceItem> items,
    required bool signatureEnabled,
    String? templateId,
    String? notes,
  }) async {
    final ref = _invoices(uid).doc();
    final id = ref.id;
    final total = items.fold<double>(0, (s, i) => s + i.lineTotal);

    await _firestore.runTransaction((txn) async {
      final cSnap = await txn.get(_counterRef(uid));
      final last = (cSnap.data()?['lastNumber'] as num?)?.toInt() ?? 0;
      final next = last + 1;
      final numberStr = next.toString().padLeft(6, '0');

      txn.set(_counterRef(uid), {'lastNumber': next}, SetOptions(merge: true));

      txn.set(ref, {
        'userId': uid,
        'clientId': clientId,
        'clientName': clientName,
        'clientAddress': clientAddress,
        'clientIce': clientIce,
        'clientIf': clientIf,
        'number': numberStr,
        'issueDate': Timestamp.fromDate(issueDate),
        'dueDate': Timestamp.fromDate(dueDate),
        'status': status.name,
        'items': items.map(_itemToMap).toList(),
        'signatureEnabled': signatureEnabled,
        'templateId': templateId,
        'notes': notes,
        'total': total,
        'paidTotal': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return id;
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final total = invoice.items.fold<double>(0, (s, i) => s + i.lineTotal);
    await _invoices(invoice.userId).doc(invoice.id).set(
          {
            'clientId': invoice.clientId,
            'clientName': invoice.clientName,
            'clientAddress': invoice.clientAddress,
            'clientIce': invoice.clientIce,
            'clientIf': invoice.clientIf,
            'issueDate': Timestamp.fromDate(invoice.issueDate),
            'dueDate': Timestamp.fromDate(invoice.dueDate),
            'status': invoice.status.name,
            'items': invoice.items.map(_itemToMap).toList(),
            'signatureEnabled': invoice.signatureEnabled,
            'templateId': invoice.templateId,
            'notes': invoice.notes,
            'total': total,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
  }

  Future<void> addPayment({
    required String uid,
    required String invoiceId,
    required double amount,
    required DateTime date,
    required PaymentMethod method,
  }) async {
    final payRef = _payments(uid, invoiceId).doc();
    await _firestore.runTransaction((txn) async {
      final invRef = _invoices(uid).doc(invoiceId);
      final invSnap = await txn.get(invRef);
      if (!invSnap.exists) {
        throw StateError('Invoice not found');
      }
      final data = invSnap.data()!;
      final total = (data['total'] as num?)?.toDouble() ?? 0;
      var paid = (data['paidTotal'] as num?)?.toDouble() ?? 0;
      paid += amount;

      txn.set(payRef, {
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'method': method.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final updates = <String, dynamic>{
        'paidTotal': paid,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (paid >= total - 0.001) {
        updates['status'] = InvoiceStatus.paid.name;
      }

      txn.update(invRef, updates);
    });
  }

  InvoiceSummary _summaryFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
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
      id: doc.id,
      number: data['number'] as String? ?? doc.id,
      issueDate: issueDate,
      dueDate: dueDate,
      status: data['status'] as String? ?? 'draft',
      clientId: data['clientId'] as String? ?? '',
      clientName: data['clientName'] as String? ?? '',
      total: (data['total'] as num?)?.toDouble() ?? 0,
      paidTotal: (data['paidTotal'] as num?)?.toDouble() ?? 0,
    );
  }

  Invoice _invoiceFromDoc(String uid, DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final itemsRaw = data['items'];
    final items = <InvoiceItem>[];
    if (itemsRaw is List) {
      for (final e in itemsRaw) {
        if (e is Map<String, dynamic>) {
          items.add(_itemFromMap(e));
        } else if (e is Map) {
          items.add(_itemFromMap(Map<String, dynamic>.from(e)));
        }
      }
    }

    return Invoice(
      id: doc.id,
      userId: uid,
      clientId: data['clientId'] as String? ?? '',
      clientName: data['clientName'] as String? ?? '',
      clientAddress: data['clientAddress'] as String? ?? '',
      clientIce: data['clientIce'] as String? ?? '',
      clientIf: data['clientIf'] as String? ?? '',
      number: data['number'] as String? ?? '',
      issueDate: (data['issueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _parseStatus(data['status'] as String?),
      items: items,
      signatureEnabled: data['signatureEnabled'] as bool? ?? false,
      templateId: data['templateId'] as String?,
      notes: data['notes'] as String?,
      paidTotal: (data['paidTotal'] as num?)?.toDouble() ?? 0,
    );
  }

  Payment _paymentFromDoc(
    String uid,
    String invoiceId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return Payment(
      id: doc.id,
      userId: uid,
      invoiceId: invoiceId,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      method: _parsePaymentMethod(data['method'] as String?),
    );
  }

  Map<String, dynamic> _itemToMap(InvoiceItem i) {
    return {
      if (i.serviceId != null) 'serviceId': i.serviceId,
      'description': i.description,
      'quantity': i.quantity,
      'unitPrice': i.unitPrice,
    };
  }

  InvoiceItem _itemFromMap(Map<String, dynamic> m) {
    return InvoiceItem(
      serviceId: m['serviceId'] as String?,
      description: m['description'] as String? ?? '',
      quantity: (m['quantity'] as num?)?.toDouble() ?? 0,
      unitPrice: (m['unitPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  InvoiceStatus _parseStatus(String? s) {
    return InvoiceStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => InvoiceStatus.draft,
    );
  }

  PaymentMethod _parsePaymentMethod(String? s) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == s,
      orElse: () => PaymentMethod.autre,
    );
  }
}
