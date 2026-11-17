import 'dart:async';

import 'package:auto_entrepreneur_manager/l10n/app_localizations.dart';
import 'package:auto_entrepreneur_manager/models/catalog_item.dart';
import 'package:auto_entrepreneur_manager/models/client.dart';
import 'package:auto_entrepreneur_manager/models/user_profile.dart';
import 'package:auto_entrepreneur_manager/providers/auth_provider.dart';
import 'package:auto_entrepreneur_manager/providers/catalog_providers.dart';
import 'package:auto_entrepreneur_manager/providers/client_providers.dart';
import 'package:auto_entrepreneur_manager/providers/profile_providers.dart';
import 'package:auto_entrepreneur_manager/shortcuts/new_invoice_shortcut_gate.dart';
import 'package:auto_entrepreneur_manager/shortcuts/shortcut_inbox.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class SignedInUser extends Fake implements User {
  @override
  String get uid => 'user';
}

const profile = UserProfile(
  uid: 'user',
  name: 'Business',
  cin: 'CIN',
  ice: 'ICE',
  ifNumber: 'IF',
  cnssNumber: 'CNSS',
  taxProfessionnelle: '',
  phone: '',
  address: 'Address',
);
const client = Client(
  id: 'client',
  userId: 'user',
  name: 'Client',
  address: '',
  ice: '',
  ifNumber: '',
  email: '',
  phone: '',
);

void main() {
  Future<({ProviderContainer container, GoRouter router})> mount(
    WidgetTester tester, {
    Stream<User?>? auth,
    Stream<UserProfile?>? profiles,
    Stream<List<Client>>? clients,
    Stream<List<CatalogItem>>? catalog,
    void Function()? opened,
  }) async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(
          (_) => auth ?? Stream.value(SignedInUser()),
        ),
        userProfileStreamProvider.overrideWith(
          (_) => profiles ?? Stream.value(profile),
        ),
        clientsStreamProvider.overrideWith(
          (_) => clients ?? Stream.value([client]),
        ),
        catalogItemsStreamProvider.overrideWith(
          (_) => catalog ?? Stream.value([]),
        ),
      ],
    );
    container.read(shortcutInboxProvider).receive({
      'deliveryId': 'tap',
      'shortcutId': 'New Invoice',
    });
    final router = GoRouter(
      initialLocation: shortcutGatePath,
      routes: [
        GoRoute(
          path: shortcutGatePath,
          builder: (_, __) => const NewInvoiceShortcutGate(),
        ),
        GoRoute(
          path: '/invoices/add',
          builder: (_, __) {
            opened?.call();
            return const Scaffold(body: Text('Empty invoice form'));
          },
        ),
        for (final path in ['/dashboard', '/more/profile', '/more/clients/add'])
          GoRoute(
            path: path,
            builder: (_, __) => Scaffold(body: Text(path)),
          ),
      ],
    );
    addTearDown(router.dispose);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump();
    return (container: container, router: router);
  }

  testWidgets(
    'retains action through signed-out state and waits for every prerequisite',
    (tester) async {
      final auth = StreamController<User?>();
      final catalog = StreamController<List<CatalogItem>>();
      addTearDown(auth.close);
      addTearDown(catalog.close);
      var opened = 0;
      final app = await mount(
        tester,
        auth: auth.stream,
        catalog: catalog.stream,
        opened: () => opened++,
      );
      auth.add(null);
      await tester.pump();
      expect(app.container.read(shortcutInboxProvider).pending, 'tap');
      expect(opened, 0);
      auth.add(SignedInUser());
      await tester.pump();
      await tester.pump();
      expect(
        opened,
        0,
      ); // Catalog is still loading, even though it is optional/empty.
      catalog.add([]);
      await tester.pumpAndSettle();
      expect(find.text('Empty invoice form'), findsOneWidget);
      expect(app.container.read(shortcutInboxProvider).pending, isNull);
      final count = opened;
      catalog.add([]);
      await tester.pumpAndSettle();
      expect(opened, count);
      expect(
        app.container.read(shortcutInboxProvider).receive({
          'deliveryId': 'tap',
          'shortcutId': 'New Invoice',
        }),
        isFalse,
      );
    },
  );

  testWidgets(
    'missing profile offers setup without opening or saving an invoice',
    (tester) async {
      final app = await mount(tester, profiles: Stream.value(null));
      await tester.pumpAndSettle();
      expect(find.text('Empty invoice form'), findsNothing);
      expect(app.container.read(shortcutInboxProvider).pending, 'tap');
      await tester.tap(find.widgetWithText(FilledButton, 'Go to profile'));
      await tester.pumpAndSettle();
      expect(
        app.router.routeInformationProvider.value.uri.path,
        '/more/profile',
      );
      expect(app.container.read(shortcutInboxProvider).pending, isNull);
    },
  );

  testWidgets('empty clients offers client creation and ends pending action', (
    tester,
  ) async {
    final app = await mount(tester, clients: Stream.value([]));
    await tester.pumpAndSettle();
    expect(find.text('Empty invoice form'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'New client'));
    await tester.pumpAndSettle();
    expect(
      app.router.routeInformationProvider.value.uri.path,
      '/more/clients/add',
    );
    expect(app.container.read(shortcutInboxProvider).pending, isNull);
  });

  testWidgets(
    'data errors retain action, retry loads again and consumes once',
    (tester) async {
      var attempts = 0;
      final source = StreamController<List<Client>>();
      addTearDown(source.close);
      final app = await mount(
        tester,
        clients: source.stream.asBroadcastStream(),
      );
      source.addError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Could not load invoice setup data'),
        findsOneWidget,
      );
      expect(app.container.read(shortcutInboxProvider).pending, 'tap');
      app.container.updateOverrides([
        authStateProvider.overrideWith((_) => Stream.value(SignedInUser())),
        userProfileStreamProvider.overrideWith((_) => Stream.value(profile)),
        clientsStreamProvider.overrideWith((_) {
          attempts++;
          return Stream.value([client]);
        }),
        catalogItemsStreamProvider.overrideWith((_) => Stream.value([])),
      ]);
      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pumpAndSettle();
      expect(attempts, greaterThan(0));
      expect(find.text('Empty invoice form'), findsOneWidget);
      expect(app.container.read(shortcutInboxProvider).pending, isNull);
    },
  );

  testWidgets('cancel prevents a later data load from navigating', (
    tester,
  ) async {
    final catalog = StreamController<List<CatalogItem>>();
    addTearDown(catalog.close);
    final app = await mount(tester, catalog: catalog.stream);
    await tester.tap(find.byTooltip('Cancel'));
    catalog.add([]);
    await tester.pumpAndSettle();
    expect(app.router.routeInformationProvider.value.uri.path, '/dashboard');
    expect(app.container.read(shortcutInboxProvider).pending, isNull);
  });
}
