/// Constants shared with Android/iOS home screen widgets and Dart routing.
abstract final class AeHomeWidgetConfig {
  /// Must match the App Group on **Runner** and the widget extension (Xcode).
  static const String iosAppGroupId =
      'group.com.example.autoEntrepreneurManager.home';

  static const String scheme = 'autoentinvoice';
  static const String invoiceHost = 'invoice';

  /// Same string as Android [NewInvoiceWidgetProvider] and iOS `widgetURL`.
  /// Includes `homeWidget` query — required by iOS [HomeWidgetPlugin] URL filtering.
  static Uri get newInvoiceLaunchUri => Uri(
        scheme: scheme,
        host: invoiceHost,
        path: '/new',
        queryParameters: const {'homeWidget': '1'},
      );

  static bool matchesNewInvoiceLaunch(Uri uri) =>
      uri.scheme == scheme &&
      uri.host == invoiceHost &&
      uri.path == '/new';

  static const String dashboardHost = 'dashboard';

  /// Same URI as [DashboardPeekWidgetProvider] on Android (`autoentinvoice://dashboard/`).
  static Uri get dashboardLaunchUri =>
      Uri(scheme: scheme, host: dashboardHost, path: '/');

  static bool matchesDashboardLaunch(Uri uri) =>
      uri.scheme == scheme &&
      uri.host == dashboardHost &&
      (uri.path == '/' || uri.path.isEmpty);

  /// For [HomeWidget.updateWidget] on Android.
  static const String androidQualifiedWidgetReceiver =
      'com.example.auto_entrepreneur_manager.NewInvoiceWidgetProvider';

  static const String androidQualifiedDashboardPeekReceiver =
      'com.example.auto_entrepreneur_manager.DashboardPeekWidgetProvider';

  /// Widget `kind` / iOS name for [HomeWidget.updateWidget].
  static const String iosWidgetKind = 'NewInvoiceWidget';
}
