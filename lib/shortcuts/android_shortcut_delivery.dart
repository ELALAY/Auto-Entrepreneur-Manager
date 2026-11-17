import 'package:flutter/services.dart';

/// Native owns the queue until drained. Register first, then drain for cold
/// launches; warm notifications use the exact same drain, eliminating races.
class AndroidShortcutDelivery {
  AndroidShortcutDelivery(this.onDelivery, {MethodChannel? channel})
    : _channel =
          channel ?? const MethodChannel('auto_entrepreneur_manager/shortcuts');

  final void Function(Object?) onDelivery;
  final MethodChannel _channel;
  bool _disposed = false;

  Future<void> start() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'shortcutAvailable') await _drain();
    });
    await _drain();
  }

  Future<void> _drain() async {
    try {
      final payload = await _channel.invokeMethod<Object?>(
        'takePendingShortcut',
      );
      if (!_disposed && payload != null) onDelivery(payload);
    } on MissingPluginException {
      // Unsupported platform/older host: launch normally.
    } on PlatformException {
      // A malformed platform delivery must not prevent normal app startup.
    }
  }

  void dispose() {
    _disposed = true;
    _channel.setMethodCallHandler(null);
  }
}
