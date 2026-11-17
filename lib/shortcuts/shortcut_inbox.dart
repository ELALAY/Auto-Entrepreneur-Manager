import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const newInvoiceShortcutId = 'New Invoice';
const shortcutGatePath = '/launch/new-invoice';

/// One pending navigation, never a business operation. Duplicate transport
/// deliveries are ignored, but a later launcher tap has a new delivery ID.
class ShortcutInbox extends ChangeNotifier {
  String? _pending;
  final _seen = <String>{};
  String? get pending => _pending;

  bool receive(Object? payload) {
    if (payload is! Map || payload['shortcutId'] != newInvoiceShortcutId) {
      return false;
    }
    final id = payload['deliveryId'];
    if (id is! String || id.isEmpty || id.length > 128 || _seen.contains(id)) {
      return false;
    }
    _seen.add(id);
    if (_seen.length > 64) _seen.remove(_seen.first);
    _pending = id;
    notifyListeners();
    return true;
  }

  bool consume(String deliveryId) {
    if (_pending != deliveryId) return false;
    _pending = null;
    notifyListeners();
    return true;
  }

  void cancel() {
    if (_pending == null) return;
    _pending = null;
    notifyListeners();
  }
}

final shortcutInboxProvider = ChangeNotifierProvider((ref) => ShortcutInbox());

/// Resume only at auth's existing landing points. Never override onboarding,
/// widget destinations, arbitrary deep links, or other feature routes.
String? shortcutResumeRedirect({required String path, required bool pending}) =>
    pending && (path == '/login' || path == '/dashboard')
    ? shortcutGatePath
    : null;
