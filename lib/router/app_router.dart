import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/clients/client_detail_screen.dart';
import '../features/clients/client_form_screen.dart';
import '../features/clients/client_list_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/declarations/declaration_detail_screen.dart';
import '../features/declarations/declaration_list_screen.dart';
import '../features/expenses/expense_detail_screen.dart';
import '../features/expenses/expense_list_screen.dart';
import '../features/invoices/invoice_detail_screen.dart';
import '../features/invoices/invoice_form_screen.dart';
import '../features/invoices/invoice_list_screen.dart';
import '../features/more/more_screen.dart';
import '../features/onboarding/activity_onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/services/service_catalog_screen.dart';
import '../providers/auth_provider.dart';
import '../shell/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// A ChangeNotifier that triggers GoRouter to re-evaluate redirects
/// whenever the Firebase auth state changes.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = _AuthListenable(ref);
  ref.onDispose(authListenable.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);

      // Still loading auth state — don't redirect yet
      if (authAsync.isLoading) return null;

      final isLoggedIn = authAsync.valueOrNull != null;
      final path = state.uri.path;
      final isAuthRoute = path == '/login' || path == '/sign-up';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      // New accounts must pick activity category before the shell (DECL-01).
      if (isLoggedIn && path == '/sign-up') return '/onboarding/activity';
      if (isLoggedIn && path == '/login') return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/onboarding/activity',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ActivityOnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/invoices',
                builder: (context, state) => const InvoiceListScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const InvoiceFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => InvoiceDetailScreen(
                      invoiceId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => InvoiceFormScreen(
                          invoiceId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expenses',
                builder: (context, state) => const ExpenseListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => ExpenseDetailScreen(
                      expenseId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/declarations',
                builder: (context, state) => const DeclarationListScreen(),
                routes: [
                  GoRoute(
                    path: ':year/:quarter',
                    builder: (context, state) => DeclarationDetailScreen(
                      year: int.parse(state.pathParameters['year']!),
                      quarter: int.parse(state.pathParameters['quarter']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreScreen(),
                routes: [
                  GoRoute(
                    path: 'clients',
                    builder: (context, state) => const ClientListScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) =>
                            const ClientFormScreen(),
                      ),
                      GoRoute(
                        path: ':clientId',
                        builder: (context, state) => ClientDetailScreen(
                          clientId: state.pathParameters['clientId']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'edit',
                            builder: (context, state) => ClientFormScreen(
                              clientId: state.pathParameters['clientId']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'services',
                    builder: (context, state) => const ServiceCatalogScreen(),
                  ),
                  GoRoute(
                    path: 'profile',
                    builder: (context, state) => const ProfileScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
