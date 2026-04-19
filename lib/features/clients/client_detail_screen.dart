import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/client_providers.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final clientAsync = ref.watch(clientStreamProvider(clientId));
    final invoicesAsync = ref.watch(invoicesForClientProvider(clientId));

    return Scaffold(
      appBar: AppBar(
        title: clientAsync.maybeWhen(
          data: (c) => Text(c?.name ?? l10n.screenClientDetail),
          orElse: () => Text(l10n.screenClientDetail),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/more/clients/$clientId/edit'),
          ),
        ],
      ),
      body: clientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.clientListError)),
        data: (client) {
          if (client == null) {
            return Center(child: Text(l10n.clientNotFound));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.clientFieldAddress, style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(client.address, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      Text(l10n.clientFieldIce, style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(client.ice.isEmpty ? '—' : client.ice),
                      const SizedBox(height: 12),
                      Text(l10n.clientFieldIf, style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(client.ifNumber.isEmpty ? '—' : client.ifNumber),
                      const SizedBox(height: 12),
                      Text(l10n.clientFieldEmail, style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(client.email.isEmpty ? '—' : client.email),
                      const SizedBox(height: 12),
                      Text(l10n.clientFieldPhone, style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(client.phone.isEmpty ? '—' : client.phone),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.clientLinkedInvoices,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              invoicesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => Text(l10n.clientListError),
                data: (invoices) {
                  if (invoices.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        l10n.clientNoInvoicesYet,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: invoices
                        .map(
                          (inv) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('${l10n.screenInvoiceDetail} ${inv.number}'),
                            subtitle: Text(
                              '${MaterialLocalizations.of(context).formatMediumDate(inv.issueDate)} · ${inv.status}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push('/invoices/${inv.id}'),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
