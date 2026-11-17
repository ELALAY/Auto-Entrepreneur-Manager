import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'home_widget/home_widget_config.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'shortcuts/android_shortcut_delivery.dart';
import 'shortcuts/shortcut_inbox.dart';
import 'theme/app_theme.dart';

class AutoEntrepreneurApp extends ConsumerStatefulWidget {
  const AutoEntrepreneurApp({super.key});

  @override
  ConsumerState<AutoEntrepreneurApp> createState() =>
      _AutoEntrepreneurAppState();
}

class _AutoEntrepreneurAppState extends ConsumerState<AutoEntrepreneurApp> {
  StreamSubscription<Uri?>? _widgetClickSub;
  AndroidShortcutDelivery? _shortcuts;

  @override
  void initState() {
    super.initState();
    _widgetClickSub = HomeWidget.widgetClicked.listen(_handleWidgetUri);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _shortcuts = AndroidShortcutDelivery(_handleShortcut);
      unawaited(_shortcuts!.start());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapWidgetLaunch();
    });
  }

  void _handleShortcut(Object? payload) {
    if (!mounted || !ref.read(shortcutInboxProvider).receive(payload)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || ref.read(shortcutInboxProvider).pending == null) return;
      final router = ref.read(routerProvider);
      final path = router.routeInformationProvider.value.uri.path;
      // Keep an ongoing sign-in/sign-up/onboarding flow intact. The router
      // resumes the pending action at its normal authenticated landing point.
      if (path == '/login' ||
          path == '/sign-up' ||
          path == '/onboarding/activity') {
        return;
      }
      router.go(shortcutGatePath);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Future<void> _bootstrapWidgetLaunch() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    _handleWidgetUri(uri);
  }

  void _handleWidgetUri(Uri? uri) {
    if (uri == null) return;
    if (AeHomeWidgetConfig.matchesNewInvoiceLaunch(uri)) {
      ref.read(shortcutInboxProvider).cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(routerProvider).go('/invoices/add');
      });
      return;
    }
    if (AeHomeWidgetConfig.matchesDashboardLaunch(uri)) {
      ref.read(shortcutInboxProvider).cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(routerProvider).go('/dashboard');
      });
    }
  }

  @override
  void dispose() {
    _widgetClickSub?.cancel();
    _shortcuts?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'Auto-Entrepreneur Manager',
      theme: buildAppTheme(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('fr')],
      routerConfig: router,
    );
  }
}
