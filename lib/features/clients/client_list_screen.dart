import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/client_providers.dart';

class ClientListScreen extends ConsumerWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncClients = ref.watch(clientsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.screenClients)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/more/clients/add'),
        icon: const Icon(Icons.person_add_outlined),
        label: Text(l10n.clientAddTitle),
      ),
      body: asyncClients.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.clientListError)),
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.clientListEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: clients.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = clients[i];
              return ListTile(
                title: Text(c.name),
                subtitle: Text(
                  [c.ice, c.ifNumber].where((s) => s.isNotEmpty).join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/more/clients/${c.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
