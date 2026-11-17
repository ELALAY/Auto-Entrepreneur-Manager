import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/expense.dart';
import '../../providers/expense_providers.dart';
import '../../utils/quarter_bounds.dart';
import 'expense_l10n.dart';

enum _ExpenseFilterTab {
  all,
  month,
  quarter,
}

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  late _ExpenseFilterTab _tab;
  late DateTime _monthAnchor;
  late int _quarterYear;
  late int _quarterIndex;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final (qy, qq) = calendarQuarterContaining(now);
    _tab = _ExpenseFilterTab.all;
    _monthAnchor = DateTime(now.year, now.month, 1);
    _quarterYear = qy;
    _quarterIndex = qq;
  }

  List<Expense> _applyFilter(List<Expense> all) {
    switch (_tab) {
      case _ExpenseFilterTab.all:
        return all;
      case _ExpenseFilterTab.month:
        return all
            .where(
              (e) => dateInCalendarMonth(
                e.date,
                _monthAnchor.year,
                _monthAnchor.month,
              ),
            )
            .toList();
      case _ExpenseFilterTab.quarter:
        return all
            .where(
              (e) => dateOnlyInQuarter(e.date, _quarterYear, _quarterIndex),
            )
            .toList();
    }
  }

  double _sum(List<Expense> list) {
    var s = 0.0;
    for (final e in list) {
      s += e.amount;
    }
    return s;
  }

  static String _mad(num v) {
    final f = NumberFormat('#,##0.00', 'fr_FR');
    return '${f.format(v)} MAD';
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _monthAnchor,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
      helpText: AppLocalizations.of(context)!.expensePickMonthHint,
    );
    if (picked != null) {
      setState(() {
        _monthAnchor = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  Future<void> _pickQuarterDialog() async {
    final l10n = AppLocalizations.of(context)!;
    var y = _quarterYear;
    var q = _quarterIndex;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.expensePeriodDialogTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: y,
                    decoration: InputDecoration(labelText: l10n.declYear),
                    items: [
                      for (var year = 2000; year <= DateTime.now().year + 1; year++)
                        DropdownMenuItem(value: year, child: Text('$year')),
                    ],
                    onChanged: (v) => setDialogState(() => y = v ?? y),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: q,
                    decoration: InputDecoration(labelText: l10n.declQuarter),
                    items: [
                      for (var i = 1; i <= 4; i++)
                        DropdownMenuItem(value: i, child: Text('Q$i')),
                    ],
                    onChanged: (v) => setDialogState(() => q = v ?? q),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.expenseApply),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok == true && mounted) {
      setState(() {
        _quarterYear = y;
        _quarterIndex = q;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final async = ref.watch(expensesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.screenExpenses)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/expenses/add'),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.expenseSaveError)),
        data: (all) {
          final filtered = _applyFilter(all);
          final total = _sum(filtered);

          final locale = Localizations.localeOf(context).toString();
          final monthLabel = DateFormat.yMMMM(locale).format(_monthAnchor);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SegmentedButton<_ExpenseFilterTab>(
                  segments: [
                    ButtonSegment(
                      value: _ExpenseFilterTab.all,
                      label: Text(l10n.expenseFilterAll),
                    ),
                    ButtonSegment(
                      value: _ExpenseFilterTab.month,
                      label: Text(l10n.expenseFilterMonth),
                    ),
                    ButtonSegment(
                      value: _ExpenseFilterTab.quarter,
                      label: Text(l10n.expenseFilterQuarter),
                    ),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (s) {
                    setState(() => _tab = s.first);
                  },
                ),
              ),
              if (_tab == _ExpenseFilterTab.month)
                ListTile(
                  dense: true,
                  title: Text(l10n.expensePickMonthHint),
                  subtitle: Text(monthLabel),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_calendar_outlined),
                    onPressed: _pickMonth,
                  ),
                ),
              if (_tab == _ExpenseFilterTab.quarter)
                ListTile(
                  dense: true,
                  title: Text(l10n.expensePickQuarterHint),
                  subtitle: Text(
                    l10n.expensePeriodQuarter(_quarterIndex, _quarterYear),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_calendar_outlined),
                    onPressed: _pickQuarterDialog,
                  ),
                ),
              if (_tab != _ExpenseFilterTab.all && filtered.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    '${_mad(total)} · ${filtered.length}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            all.isEmpty
                                ? l10n.expenseEmptyAll
                                : l10n.expenseEmptyFiltered,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final e = filtered[i];
                          final dateStr =
                              MaterialLocalizations.of(context).formatMediumDate(e.date);
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  cs.secondaryContainer.withValues(alpha: 0.55),
                              child: Icon(
                                Icons.receipt_long_outlined,
                                color: cs.secondary,
                              ),
                            ),
                            title: Text(_mad(e.amount)),
                            subtitle: Text(
                              '${expenseCategoryLabel(l10n, e.category)} · $dateStr',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => context.push('/expenses/${e.id}'),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
