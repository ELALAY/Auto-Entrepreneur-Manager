import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/enums.dart';
import '../../providers/declaration_providers.dart';

class DeclarationListScreen extends ConsumerWidget {
  const DeclarationListScreen({super.key});

  static String _statusLabel(AppLocalizations l10n, DeclarationStatus s) {
    return switch (s) {
      DeclarationStatus.draft => l10n.declStatusDraft,
      DeclarationStatus.readyToFile => l10n.declStatusReady,
      DeclarationStatus.filed => l10n.declStatusFiled,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final listAsync = ref.watch(declarationsListStreamProvider);
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(locale);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.screenDeclarations)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickQuarter(context),
        icon: const Icon(Icons.calendar_month_outlined),
        label: Text(l10n.declOpenQuarter),
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.declLoadError)),
        data: (items) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: [
              Text(
                l10n.declHistoryTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.declHistoryEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...items.map(
                  (d) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${d.year} · Q${d.quarter}'),
                      subtitle: Text(
                        d.status == DeclarationStatus.filed && d.filedDate != null
                            ? l10n.declFiledOn(dateFmt.format(d.filedDate!))
                            : _statusLabel(l10n, d.status),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/declarations/${d.year}/${d.quarter}'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _pickQuarter(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    var year = now.year;
    var quarter = (now.month - 1) ~/ 3 + 1;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.declPickQuarterTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: l10n.declYear),
                    value: year,
                    items: [
                      for (var y = now.year + 1; y >= now.year - 3; y--)
                        DropdownMenuItem(value: y, child: Text('$y')),
                    ],
                    onChanged: (v) {
                      if (v != null) setDialogState(() => year = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: l10n.declQuarter),
                    value: quarter,
                    items: [
                      for (var q = 1; q <= 4; q++)
                        DropdownMenuItem(value: q, child: Text('Q$q')),
                    ],
                    onChanged: (v) {
                      if (v != null) setDialogState(() => quarter = v);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/declarations/$year/$quarter');
                  },
                  child: Text(l10n.declGo),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
