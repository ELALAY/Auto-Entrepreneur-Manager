import 'dart:math' show max;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/tax/activity_category.dart';
import '../models/enums.dart';
import '../models/invoice_number_config.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/invoice_summary.dart';
import '../models/payment.dart';
import '../utils/quarter_bounds.dart';

class InvoiceRepository {
  InvoiceRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.doc('users/$uid');

  DocumentReference<Map<String, dynamic>> _counterRef(String uid) =>
      _firestore.doc('users/$uid/meta/invoiceCounter');

  /// Same fields as [ProfileRepository] — read inside [createInvoice]'s transaction
  /// so numbering always matches committed Firestore data (avoids stale cache).
  InvoiceNumberConfig _invoiceNumberConfigFromUserData(
    Map<String, dynamic>? data,
  ) {
    if (data == null) return const InvoiceNumberConfig();
    final prefix = data['invoiceNumberPrefix'] as String? ?? 'INV';
    final pattern = data['invoiceNumberPattern'] as String? ??
        '{prefix}_{year}_{count}';
    final digits = (data['invoiceNumberCountDigits'] as num?)?.toInt() ?? 3;
    return InvoiceNumberConfig(
      prefix: prefix,
      pattern: pattern,
      countDigits: digits.clamp(1, 12),
    );
  }

  /// Next `{count}` from profile, or legacy full-number string (trailing digits).
  int? _nextInvoiceCountFromUserData(Map<String, dynamic>? data) {
    if (data == null) return null;
    final n = data['nextInvoiceCount'];
    if (n is num) {
      final v = n.toInt();
      if (v >= 1) return v;
    }
    final legacy = data['nextInvoiceNumber'] as String?;
    if (legacy != null && legacy.trim().isNotEmpty) {
      final t = legacy.trim();
      final parsed = parseTrailingInvoiceSequence(t);
      if (parsed != null && parsed >= 1) return parsed;
      final direct = int.tryParse(t);
      if (direct != null && direct >= 1) return direct;
    }
    return null;
  }

  /// Read-only preview of the next invoice number (does not increment the counter).
  /// Uses the same rules as [createInvoice] for profile format and per-year sequence.
  Future<String> previewNextInvoiceNumber({
    required String uid,
    required DateTime issueDate,
  }) async {
    final userSnap = await _userDoc(uid).get();
    final userData = userSnap.data();
    final cfg = normalizeInvoiceNumberConfig(
      _invoiceNumberConfigFromUserData(userData),
    );
    final cSnap = await _counterRef(uid).get();
    final counterData = cSnap.data() ?? {};
    final yearKey = issueDate.year.toString();
    var yearLast = <String, dynamic>{};
    final rawYear = counterData['yearLast'];
    if (rawYear is Map) {
      yearLast = Map<String, dynamic>.from(
        rawYear.map((k, v) => MapEntry(k.toString(), v)),
      );
    }
    final lastForYear = (yearLast[yearKey] as num?)?.toInt() ?? 0;
    final profileCount = _nextInvoiceCountFromUserData(userData);
    final counterNext = lastForYear + 1;
    final count = profileCount != null
        ? max(counterNext, profileCount)
        : counterNext;
    return formatInvoiceNumber(
      cfg,
      year: issueDate.year,
      count: count,
    );
  }

  CollectionReference<Map<String, dynamic>> _invoices(String uid) =>
      _firestore.collection('users/$uid/invoices');

  CollectionReference<Map<String, dynamic>> _payments(String uid, String invoiceId) =>
      _firestore.collection('users/$uid/invoices/$invoiceId/payments');

  /// Writes logo choice for new invoices (always explicit).
  Map<String, dynamic> _newInvoiceLogoFields({
    required bool invoiceUseBundledLogo,
    String? invoiceLogoUrl,
  }) {
    if (invoiceUseBundledLogo) {
      return {
        'invoiceUseBundledLogo': true,
        'invoiceLogoUrl': FieldValue.delete(),
      };
    }
    return {
      'invoiceUseBundledLogo': false,
      'invoiceLogoUrl': invoiceLogoUrl?.trim() ?? '',
    };
  }

  /// On update, omit keys when the invoice never had logo fields (legacy) and the model
  /// still has nulls, so we do not overwrite Firestore.
  Map<String, dynamic> _updateInvoiceLogoFields(Invoice inv) {
    if (inv.invoiceUseBundledLogo == null) {
      return {};
    }
    if (inv.invoiceUseBundledLogo == true) {
      return {
        'invoiceUseBundledLogo': true,
        'invoiceLogoUrl': FieldValue.delete(),
      };
    }
    return {
      'invoiceUseBundledLogo': false,
      'invoiceLogoUrl': inv.invoiceLogoUrl?.trim() ?? '',
    };
  }

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

  /// Cash-basis revenue in the quarter, grouped by invoice [activityCategory].
  /// Invoices without a stored category use [legacyFallback].
  Future<Map<ActivityCategory, double>> sumPaidRevenueByActivityInQuarter(
    String uid,
    int year,
    int quarter,
    ActivityCategory legacyFallback,
  ) async {
    final invSnap = await _invoices(uid).get();
    final map = <ActivityCategory, double>{};
    for (final inv in invSnap.docs) {
      final data = inv.data();
      final cat = parseActivityCategoryField(data['activityCategory']) ??
          legacyFallback;
      final paySnap = await _payments(uid, inv.id).get();
      for (final p in paySnap.docs) {
        final ts = p.data()['date'];
        if (ts is! Timestamp) continue;
        final date = ts.toDate();
        if (dateOnlyInQuarter(date, year, quarter)) {
          final amt = (p.data()['amount'] as num?)?.toDouble() ?? 0;
          map[cat] = (map[cat] ?? 0) + amt;
        }
      }
    }
    return map;
  }

  /// Assigns a per-calendar-year sequential number and formats it; returns new invoice id.
  ///
  /// Invoice number formatting is read from `users/{uid}` inside this transaction so it
  /// always matches persisted profile fields (not a possibly stale [getProfile] cache).
  ///
  /// When [numberOverride] is null or empty, if `users/{uid}.nextInvoiceCount` is set it is
  /// combined with the per-year counter as `max(last+1, nextInvoiceCount)` for the sequence
  /// count in the formatted number. After every successful create, `nextInvoiceCount` on the
  /// user document is set to one more than the last count stored for the invoice issue year
  /// (same transaction). Legacy string `nextInvoiceNumber` is deleted when present.
  ///
  /// If [numberOverride] is non-empty after trim, it is stored as-is; trailing digits are
  /// used to bump the yearly counter so automatic numbering can continue after manual values.
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
    required bool invoiceUseBundledLogo,
    String? invoiceLogoUrl,
    String? numberOverride,
    String? templateId,
    String? notes,
    required ActivityCategory activityCategory,
  }) async {
    final ref = _invoices(uid).doc();
    final id = ref.id;
    final total = items.fold<double>(0, (s, i) => s + i.lineTotal);

    await _firestore.runTransaction((txn) async {
      final userSnap = await txn.get(_userDoc(uid));
      final invoiceNumberConfig = _invoiceNumberConfigFromUserData(
        userSnap.data(),
      );

      final cSnap = await txn.get(_counterRef(uid));
      final counterData = cSnap.data() ?? {};
      final yearKey = issueDate.year.toString();
      var yearLast = <String, dynamic>{};
      final rawYear = counterData['yearLast'];
      if (rawYear is Map) {
        yearLast = Map<String, dynamic>.from(
          rawYear.map((k, v) => MapEntry(k.toString(), v)),
        );
      }
      final lastForYear = (yearLast[yearKey] as num?)?.toInt() ?? 0;

      final cfg = normalizeInvoiceNumberConfig(invoiceNumberConfig);
      final trimmedOverride = numberOverride?.trim();

      final String numberStr;
      if (trimmedOverride != null && trimmedOverride.isNotEmpty) {
        numberStr = trimmedOverride;
        final parsed = parseTrailingInvoiceSequence(trimmedOverride);
        if (parsed != null) {
          yearLast[yearKey] = max(lastForYear, parsed);
        } else {
          yearLast[yearKey] = lastForYear;
        }
      } else {
        final userData = userSnap.data();
        final profileCount = _nextInvoiceCountFromUserData(userData);
        final counterNext = lastForYear + 1;
        final int count = profileCount != null
            ? max(counterNext, profileCount)
            : counterNext;
        yearLast[yearKey] = max(lastForYear, count);
        numberStr = formatInvoiceNumber(
          cfg,
          year: issueDate.year,
          count: count,
        );
      }

      final issuedLastForYear =
          (yearLast[yearKey] as num?)?.toInt() ?? 0;
      txn.set(
        _userDoc(uid),
        {
          'nextInvoiceCount': issuedLastForYear + 1,
          'nextInvoiceNumber': FieldValue.delete(),
        },
        SetOptions(merge: true),
      );

      txn.set(
        _counterRef(uid),
        {'yearLast': yearLast},
        SetOptions(merge: true),
      );

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
        'activityCategory': activityCategory.name,
        'total': total,
        'paidTotal': 0.0,
        ..._newInvoiceLogoFields(
          invoiceUseBundledLogo: invoiceUseBundledLogo,
          invoiceLogoUrl: invoiceLogoUrl,
        ),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return id;
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final total = invoice.items.fold<double>(0, (s, i) => s + i.lineTotal);
    final numberTrimmed = invoice.number.trim();
    await _invoices(invoice.userId).doc(invoice.id).set(
          {
            'clientId': invoice.clientId,
            'clientName': invoice.clientName,
            'clientAddress': invoice.clientAddress,
            'clientIce': invoice.clientIce,
            'clientIf': invoice.clientIf,
            'number': numberTrimmed,
            'issueDate': Timestamp.fromDate(invoice.issueDate),
            'dueDate': Timestamp.fromDate(invoice.dueDate),
            'status': invoice.status.name,
            'items': invoice.items.map(_itemToMap).toList(),
            'signatureEnabled': invoice.signatureEnabled,
            'templateId': invoice.templateId,
            'notes': invoice.notes,
            if (invoice.activityCategory != null)
              'activityCategory': invoice.activityCategory!.name,
            'total': total,
            ..._updateInvoiceLogoFields(invoice),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
    await _syncYearCounterToAtLeast(
      invoice.userId,
      invoice.issueDate.year,
      numberTrimmed,
    );
  }

  /// Bumps `yearLast` when [invoiceNumber] ends with a digit group larger than the stored counter.
  Future<void> _syncYearCounterToAtLeast(
    String uid,
    int year,
    String invoiceNumber,
  ) async {
    final parsed = parseTrailingInvoiceSequence(invoiceNumber);
    if (parsed == null) return;
    await _firestore.runTransaction((txn) async {
      final cSnap = await txn.get(_counterRef(uid));
      final counterData = cSnap.data() ?? {};
      final yearKey = year.toString();
      var yearLast = <String, dynamic>{};
      final rawYear = counterData['yearLast'];
      if (rawYear is Map) {
        yearLast = Map<String, dynamic>.from(
          rawYear.map((k, v) => MapEntry(k.toString(), v)),
        );
      }
      final lastForYear = (yearLast[yearKey] as num?)?.toInt() ?? 0;
      if (parsed <= lastForYear) return;
      yearLast[yearKey] = parsed;
      txn.set(
        _counterRef(uid),
        {'yearLast': yearLast},
        SetOptions(merge: true),
      );
    });
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

  Future<void> deletePayment({
    required String uid,
    required String invoiceId,
    required String paymentId,
    required double amount,
  }) async {
    final payRef = _payments(uid, invoiceId).doc(paymentId);
    await _firestore.runTransaction((txn) async {
      final invRef = _invoices(uid).doc(invoiceId);
      final invSnap = await txn.get(invRef);
      if (!invSnap.exists) throw StateError('Invoice not found');
      final data = invSnap.data()!;
      final total = (data['total'] as num?)?.toDouble() ?? 0;
      var paid = (data['paidTotal'] as num?)?.toDouble() ?? 0;
      paid = (paid - amount).clamp(0, double.infinity);

      txn.delete(payRef);

      final updates = <String, dynamic>{
        'paidTotal': paid,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      // Revert paid status if balance reappears
      if (data['status'] == InvoiceStatus.paid.name && paid < total - 0.001) {
        updates['status'] = InvoiceStatus.sent.name;
      }
      txn.update(invRef, updates);
    });
  }

  Future<void> updatePayment({
    required String uid,
    required String invoiceId,
    required String paymentId,
    required double oldAmount,
    required double newAmount,
    required DateTime date,
    required PaymentMethod method,
  }) async {
    final payRef = _payments(uid, invoiceId).doc(paymentId);
    await _firestore.runTransaction((txn) async {
      final invRef = _invoices(uid).doc(invoiceId);
      final invSnap = await txn.get(invRef);
      if (!invSnap.exists) throw StateError('Invoice not found');
      final data = invSnap.data()!;
      final total = (data['total'] as num?)?.toDouble() ?? 0;
      var paid = (data['paidTotal'] as num?)?.toDouble() ?? 0;
      paid = (paid - oldAmount + newAmount).clamp(0, double.infinity);

      txn.update(payRef, {
        'amount': newAmount,
        'date': Timestamp.fromDate(date),
        'method': method.name,
      });

      final updates = <String, dynamic>{
        'paidTotal': paid,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (paid >= total - 0.001) {
        updates['status'] = InvoiceStatus.paid.name;
      } else if (data['status'] == InvoiceStatus.paid.name) {
        updates['status'] = InvoiceStatus.sent.name;
      }
      txn.update(invRef, updates);
    });
  }

  InvoiceSummary _summaryFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return InvoiceSummary.fromFirestoreDoc(doc.id, doc.data());
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

    final bool? invoiceUseBundledLogo;
    final String? invoiceLogoUrl;
    if (data.containsKey('invoiceUseBundledLogo')) {
      invoiceUseBundledLogo = data['invoiceUseBundledLogo'] as bool? ?? false;
      invoiceLogoUrl = data['invoiceLogoUrl'] as String?;
    } else {
      invoiceUseBundledLogo = null;
      invoiceLogoUrl = null;
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
      activityCategory: parseActivityCategoryField(data['activityCategory']),
      invoiceUseBundledLogo: invoiceUseBundledLogo,
      invoiceLogoUrl: invoiceLogoUrl,
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
