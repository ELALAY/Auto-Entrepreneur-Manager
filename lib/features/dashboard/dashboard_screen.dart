import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../widgets/quick_link_tile.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: AppColors.heroGradientLight),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, top + 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.trending_up_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.screenDashboard,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.dashboardTagline,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.dashboardStatsHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              delegate: SliverChildListDelegate([
                StatCard(
                  icon: Icons.payments_outlined,
                  label: l10n.invoiceTotal,
                  value: '—',
                  iconColor: AppColors.moneyDeep,
                  onTap: () => context.go('/invoices'),
                ),
                StatCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: l10n.invoiceBalance,
                  value: '—',
                  onTap: () => context.go('/invoices'),
                ),
                StatCard(
                  icon: Icons.receipt_long_outlined,
                  label: l10n.screenInvoices,
                  value: '—',
                  onTap: () => context.go('/invoices'),
                ),
                StatCard(
                  icon: Icons.show_chart_rounded,
                  label: l10n.navTax,
                  value: '—',
                  onTap: () => context.go('/declarations'),
                ),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.dashboardSectionShortcuts,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                QuickLinkTile(
                  icon: Icons.add_card_rounded,
                  title: l10n.invoiceNewAction,
                  subtitle: l10n.placeholderInvoices,
                  accent: AppColors.growthDark,
                  onTap: () => context.push('/invoices/add'),
                ),
                const SizedBox(height: 10),
                QuickLinkTile(
                  icon: Icons.people_alt_outlined,
                  title: l10n.screenClients,
                  subtitle: l10n.placeholderClients,
                  accent: AppColors.moneyDeep,
                  onTap: () => context.push('/more/clients'),
                ),
                const SizedBox(height: 10),
                QuickLinkTile(
                  icon: Icons.verified_user_outlined,
                  title: l10n.screenProfile,
                  subtitle: l10n.placeholderProfile,
                  accent: theme.colorScheme.tertiary,
                  onTap: () => context.push('/more/profile'),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
