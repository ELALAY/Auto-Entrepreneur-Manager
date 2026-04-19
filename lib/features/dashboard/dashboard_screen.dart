import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/invoice_summary.dart';
import '../../models/enums.dart';
import '../../providers/declaration_providers.dart';
import '../../providers/invoice_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/declaration_filing_deadline.dart';
import '../../utils/quarter_bounds.dart';
import '../../widgets/quick_link_tile.dart';
import '../../widgets/stat_card.dart';
import 'dashboard_declaration_reminder.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _mad(double v) {
    final f = NumberFormat('#,##0', 'fr_FR');
    return '${f.format(v)} MAD';
  }

  static int _currentQuarter(DateTime now) => ((now.month - 1) ~/ 3) + 1;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final summariesAsync = ref.watch(invoicesSummaryStreamProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero header ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: AppColors.heroGradientLight),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, top + 16, 20, 28),
                child: Row(
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
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: DashboardDeclarationReminder(),
          ),

          // ── Stats ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: summariesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (summaries) =>
                  _StatsSection(summaries: summaries),
            ),
          ),

          // ── Shortcuts ─────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
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
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats section (extracted so it has its own context for formatting) ────────

class _StatsSection extends ConsumerWidget {
  const _StatsSection({required this.summaries});

  final List<InvoiceSummary> summaries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final calendarQ = DashboardScreen._currentQuarter(now);
    final year = now.year;
    final declarationsAsync = ref.watch(declarationsListStreamProvider);
    DeclarationFilingStatus? filing = declarationsAsync.maybeWhen(
      data: (list) {
        bool filed(int y, int q) => list.any(
              (d) =>
                  d.year == y &&
                  d.quarter == q &&
                  d.status == DeclarationStatus.filed,
            );
        final urgent =
            outstandingDeclarationFiling(now: now, isQuarterFiled: filed);
        return urgent ??
            nextDeclarationFilingCountdown(now, isQuarterFiled: filed);
      },
      orElse: () => null,
    );
    final fq = filing?.declarationQuarter ?? calendarQ;
    final fy = filing?.declarationYear ?? year;
    final daysLeft = filing?.daysRemaining;

    // ── Compute stats from summaries ─────────────────────────────────────────
    double qRevenue = 0;
    double ytdRevenue = 0;
    double outstanding = 0;
    int overdueCount = 0;

    for (final s in summaries) {
      // Quarter revenue: payments collected on invoices issued this quarter
      // (approximation: uses issueDate for bucketing, same as billing period)
      if (dateOnlyInQuarter(s.issueDate, year, calendarQ)) {
        qRevenue += s.paidTotal;
      }
      // YTD: all invoices issued this calendar year
      if (s.issueDate.year == year) {
        ytdRevenue += s.paidTotal;
      }
      // Outstanding across all invoices
      outstanding += s.balance;
      if (s.isOverdueNotPaid()) overdueCount++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Overdue alert ──────────────────────────────────────────────────
        if (overdueCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.55),
              child: ListTile(
                leading: Icon(Icons.warning_amber_rounded,
                    color: theme.colorScheme.error),
                title: Text(
                  '$overdueCount facture${overdueCount > 1 ? 's' : ''} en retard',
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
                onTap: () => Navigator.of(context)
                    .pushNamed('/invoices'), // navigates to invoice list
              ),
            ),
          ),

        // ── Hint ──────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(16, overdueCount > 0 ? 12 : 16, 16, 8),
          child: Text(
            AppLocalizations.of(context)!.dashboardStatsHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        // ── 2×2 stat grid ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(
                icon: Icons.payments_outlined,
                label: 'Encaissé Q$calendarQ · $year',
                value: DashboardScreen._mad(qRevenue),
                iconColor: AppColors.growthDark,
              ),
              StatCard(
                icon: Icons.calendar_today_outlined,
                label: 'Encaissé YTD $year',
                value: DashboardScreen._mad(ytdRevenue),
                iconColor: AppColors.growth,
              ),
              StatCard(
                icon: Icons.account_balance_wallet_outlined,
                label: 'En attente de paiement',
                value: DashboardScreen._mad(outstanding),
                iconColor: outstanding > 0
                    ? AppColors.moneyDeep
                    : AppColors.growthDark,
                onTap: () => context.go('/invoices'),
              ),
              StatCard(
                icon: Icons.event_outlined,
                label: 'Délai déclaration Q$fq · $fy',
                value: daysLeft == null
                    ? '—'
                    : (daysLeft >= 0 ? '$daysLeft j' : 'Passé'),
                iconColor: daysLeft == null
                    ? AppColors.growthDark
                    : daysLeft <= 14
                        ? theme.colorScheme.error
                        : daysLeft <= 30
                            ? AppColors.moneyDeep
                            : AppColors.growthDark,
                onTap: () => context.go('/declarations'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
