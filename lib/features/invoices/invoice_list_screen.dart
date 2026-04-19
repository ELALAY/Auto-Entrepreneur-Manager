import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/enums.dart';
import '../../providers/invoice_providers.dart';
import '../../providers/profile_providers.dart';
import '../../theme/app_colors.dart';

class InvoiceListScreen extends ConsumerWidget {
  const InvoiceListScreen({super.key});

  static String _mad(num v) {
    final f = NumberFormat('#,##0.00', 'fr_FR');
    return '${f.format(v)} MAD';
  }

  void _onCreateInvoiceTap(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final complete = ref.read(profileCompleteProvider).valueOrNull ?? false;
    if (complete) {
      context.push('/invoices/add');
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.invoiceProfileRequiredTitle),
        content: Text(l10n.invoiceProfileRequiredBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/more/profile');
            },
            child: Text(l10n.invoiceGoToProfile),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final asyncInv = ref.watch(invoicesSummaryStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.screenInvoices),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onCreateInvoiceTap(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.invoiceNewAction),
      ),
      body: asyncInv.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.clientListError)),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 48,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.invoiceListEmpty,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.placeholderInvoices,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final inv = list[i];
              final status = InvoiceStatus.values.firstWhere(
                (e) => e.name == inv.status,
                orElse: () => InvoiceStatus.draft,
              );
              final overdue = inv.isOverdueNotPaid();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push('/invoices/${inv.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${l10n.screenInvoiceDetail} ${inv.number}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  inv.clientName.isEmpty ? '—' : inv.clientName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    _StatusChip(
                                      label: _statusLabel(l10n, status),
                                      color: cs.primaryContainer,
                                      foreground: cs.onPrimaryContainer,
                                    ),
                                    if (overdue)
                                      _StatusChip(
                                        label: l10n.invoiceBadgeOverdue,
                                        color: cs.errorContainer,
                                        foreground: cs.onErrorContainer,
                                      ),
                                    if (inv.isPartiallyPaid)
                                      _StatusChip(
                                        label: l10n.invoiceBadgePartial,
                                        color: AppColors.money.withValues(alpha: 0.25),
                                        foreground: AppColors.moneyDeep,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _mad(inv.total),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.primary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                MaterialLocalizations.of(context)
                                    .formatMediumDate(inv.issueDate),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _statusLabel(AppLocalizations l10n, InvoiceStatus s) {
    return switch (s) {
      InvoiceStatus.draft => l10n.invoiceStatusDraft,
      InvoiceStatus.sent => l10n.invoiceStatusSent,
      InvoiceStatus.paid => l10n.invoiceStatusPaid,
      InvoiceStatus.overdue => l10n.invoiceStatusOverdue,
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.foreground,
  });

  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
