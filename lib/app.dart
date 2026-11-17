import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'home_widget/home_widget_config.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class AutoEntrepreneurApp extends ConsumerStatefulWidget {
  const AutoEntrepreneurApp({super.key});

  @override
  ConsumerState<AutoEntrepreneurApp> createState() =>
      _AutoEntrepreneurAppState();
}

class _AutoEntrepreneurAppState extends ConsumerState<AutoEntrepreneurApp> {
  StreamSubscription<Uri?>? _widgetClickSub;

  @override
  void initState() {
    super.initState();
    _widgetClickSub = HomeWidget.widgetClicked.listen(_handleWidgetUri);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapWidgetLaunch();
    });
  }

  Future<void> _bootstrapWidgetLaunch() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    _handleWidgetUri(uri);
  }

  void _handleWidgetUri(Uri? uri) {
    if (uri == null) return;
    if (AeHomeWidgetConfig.matchesNewInvoiceLaunch(uri)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(routerProvider).go('/invoices/add');
      });
      return;
    }
    if (AeHomeWidgetConfig.matchesDashboardLaunch(uri)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(routerProvider).go('/dashboard');
      });
    }
  }

  @override
  void dispose() {
    _widgetClickSub?.cancel();
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
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      routerConfig: router,
    );
  }
}
