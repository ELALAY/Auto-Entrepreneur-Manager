import 'dart:async';
import 'dart:ui' as ui;

import 'package:auto_entrepreneur_manager/shortcuts/android_shortcut_delivery.dart';
import 'package:auto_entrepreneur_manager/shortcuts/shortcut_inbox.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('auto_entrepreneur_manager/shortcuts');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  Map<String, String> delivery(String id) => {
    'deliveryId': id,
    'shortcutId': 'New Invoice',
  };
  Future<void> notify() {
    final done = Completer<void>();
    ui.channelBuffers.push(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('shortcutAvailable'),
      ),
      (_) => done.complete(),
    );
    return done.future;
  }

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
    'cold drain and warm notification deliver each queued action once',
    () async {
      Object? queued = delivery('cold');
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'takePendingShortcut');
        final value = queued;
        queued = null;
        return value;
      });
      final received = <Object?>[];
      final bridge = AndroidShortcutDelivery(received.add);
      addTearDown(bridge.dispose);
      await bridge.start();
      expect(received, [delivery('cold')]);
      await notify();
      expect(received, hasLength(1));
      queued = delivery('warm');
      await notify();
      expect(received, [delivery('cold'), delivery('warm')]);
    },
  );

  test(
    'startup drain racing a warm notification does not duplicate navigation',
    () async {
      final waiting = Completer<Object?>();
      var calls = 0;
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => ++calls == 1 ? waiting.future : delivery('same'),
      );
      final inbox = ShortcutInbox();
      var accepted = 0;
      final bridge = AndroidShortcutDelivery((value) {
        if (inbox.receive(value)) accepted++;
      });
      addTearDown(bridge.dispose);
      final starting = bridge.start();
      await Future<void>.delayed(Duration.zero);
      await notify();
      waiting.complete(delivery('same'));
      await starting;
      expect(accepted, 1);
      expect(inbox.consume('same'), isTrue);
      expect(inbox.consume('same'), isFalse);
    },
  );

  test('disposal suppresses an outstanding cold response', () async {
    final waiting = Completer<Object?>();
    messenger.setMockMethodCallHandler(channel, (_) => waiting.future);
    final received = <Object?>[];
    final bridge = AndroidShortcutDelivery(received.add);
    final starting = bridge.start();
    bridge.dispose();
    waiting.complete(delivery('late'));
    await starting;
    expect(received, isEmpty);
  });

  test('missing native implementation does not break normal startup', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw MissingPluginException(),
    );
    final bridge = AndroidShortcutDelivery((_) => fail('No delivery expected'));
    addTearDown(bridge.dispose);
    await bridge.start();
  });

  test(
    'invalid actions do not replace pending action; consumption is exact',
    () {
      final inbox = ShortcutInbox();
      expect(inbox.receive(delivery('one')), isTrue);
      for (final invalid in [
        null,
        'New Invoice',
        {},
        {'shortcutId': 'Delete Invoice', 'deliveryId': 'bad'},
        {'shortcutId': 'New Invoice', 'deliveryId': ''},
      ]) {
        expect(inbox.receive(invalid), isFalse);
      }
      expect(inbox.pending, 'one');
      expect(inbox.consume('wrong'), isFalse);
      expect(inbox.consume('one'), isTrue);
      expect(inbox.receive(delivery('one')), isFalse);
      expect(inbox.receive(delivery('two')), isTrue);
      inbox.cancel();
      expect(inbox.pending, isNull);
    },
  );

  test(
    'resume affects only auth landing points and preserves other navigation',
    () {
      for (final path in ['/login', '/dashboard']) {
        expect(
          shortcutResumeRedirect(path: path, pending: true),
          shortcutGatePath,
        );
        expect(shortcutResumeRedirect(path: path, pending: false), isNull);
      }
      for (final path in [
        '/sign-up',
        '/onboarding/activity',
        '/invoices/123',
        '/more/profile',
        '/declarations',
      ]) {
        expect(shortcutResumeRedirect(path: path, pending: true), isNull);
      }
    },
  );
}
