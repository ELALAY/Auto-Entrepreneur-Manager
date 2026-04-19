import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/catalog_item.dart';
import '../../providers/catalog_providers.dart';

class ServiceCatalogScreen extends ConsumerWidget {
  const ServiceCatalogScreen({super.key});

  static String _mad(num v) {
    return '${NumberFormat('#,##0.00', 'fr_FR').format(v)} MAD';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(catalogItemsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.screenServices)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/more/services/add'),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.catalogListError)),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: theme.colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      l10n.catalogListEmpty,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.catalogListEmptyHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, i) {
              final item = items[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Material(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: Icon(
                      item.kind == CatalogKind.product
                          ? Icons.shopping_bag_outlined
                          : Icons.handyman_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${_kindLabel(l10n, item.kind)} · ${_mad(item.defaultUnitPrice)}',
                    ),
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: theme.colorScheme.onSurfaceVariant),
                    onTap: () => context.push('/more/services/${item.id}/edit'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _kindLabel(AppLocalizations l10n, CatalogKind k) {
    return switch (k) {
      CatalogKind.product => l10n.catalogKindProduct,
      CatalogKind.service => l10n.catalogKindService,
    };
  }
}
