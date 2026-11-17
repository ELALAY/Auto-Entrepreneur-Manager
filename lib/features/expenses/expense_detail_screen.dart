import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/firebase_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/expense_providers.dart';
import 'expense_l10n.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});

  final String expenseId;

  static String _mad(num v) {
    final f = NumberFormat('#,##0.00', 'fr_FR');
    return '${f.format(v)} MAD';
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.expenseDeleteConfirmTitle),
        content: Text(l10n.expenseDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await ref.read(expenseRepositoryProvider).deleteExpense(uid, expenseId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.expenseDeleted)),
      );
      context.pop();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.expenseDeleteError),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final async = ref.watch(expenseStreamProvider(expenseId));

    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.screenExpenseDetail)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: Text(l10n.screenExpenseDetail)),
        body: Center(child: Text(l10n.expenseSaveError)),
      ),
      data: (expense) {
        if (expense == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.screenExpenseDetail)),
            body: Center(child: Text(l10n.expenseSaveError)),
          );
        }

        final dateStr = MaterialLocalizations.of(context).formatFullDate(expense.date);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.screenExpenseDetail),
            actions: [
              IconButton(
                tooltip: l10n.expenseFormEditTitle,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/expenses/$expenseId/edit'),
              ),
              IconButton(
                tooltip: l10n.actionDelete,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                _mad(expense.amount),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                expenseCategoryLabel(l10n, expense.category),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(dateStr, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 24),
              Text(
                l10n.expenseFieldDescription,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(expense.description.isEmpty ? '—' : expense.description),
              if (expense.receiptUrl != null && expense.receiptUrl!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.expenseFieldReceipt,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    expense.receiptUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.expenseSaveError),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
