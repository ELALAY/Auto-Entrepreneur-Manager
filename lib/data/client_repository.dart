import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/client.dart';
import '../models/invoice_summary.dart';

class ClientRepository {
  ClientRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _clients(String uid) =>
      _firestore.collection('users/$uid/clients');

  CollectionReference<Map<String, dynamic>> _invoices(String uid) =>
      _firestore.collection('users/$uid/invoices');

  Stream<List<Client>> watchClients(String uid) {
    return _clients(uid).orderBy('name').snapshots().map((snap) {
      return snap.docs.map((d) => _clientFromDoc(uid, d)).toList();
    });
  }

  Stream<Client?> watchClient(String uid, String clientId) {
    return _clients(uid).doc(clientId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return _clientFromDoc(uid, snap);
    });
  }

  Stream<List<InvoiceSummary>> watchInvoicesForClient(String uid, String clientId) {
    return _invoices(uid)
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(_invoiceSummaryFromDoc).toList();
          list.sort((a, b) => b.issueDate.compareTo(a.issueDate));
          return list;
        });
  }

  Future<void> upsertClient(Client client) {
    return _clients(client.userId).doc(client.id).set(_clientToMap(client));
  }

  Future<void> deleteClient(String uid, String clientId) {
    return _clients(uid).doc(clientId).delete();
  }

  Client _clientFromDoc(String uid, DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Client(
      id: doc.id,
      userId: uid,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      ice: data['ice'] as String? ?? '',
      ifNumber: data['ifNumber'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> _clientToMap(Client c) {
    return {
      'name': c.name.trim(),
      'address': c.address.trim(),
      'ice': c.ice.trim(),
      'ifNumber': c.ifNumber.trim(),
      'email': c.email.trim(),
      'phone': c.phone.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  InvoiceSummary _invoiceSummaryFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
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
}
