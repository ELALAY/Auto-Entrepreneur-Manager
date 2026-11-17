import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/catalog_providers.dart';
import '../providers/client_providers.dart';
import '../providers/profile_providers.dart';
import '../utils/profile_completion.dart';
import 'shortcut_inbox.dart';

/// Loads prerequisites without constructing the form or reserving a number.
class NewInvoiceShortcutGate extends ConsumerWidget {
  const NewInvoiceShortcutGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pending = ref.watch(shortcutInboxProvider).pending;
    final auth = ref.watch(authStateProvider);
    void leave(String path) {
      ref.read(shortcutInboxProvider).cancel();
      context.go(path);
    }

    Widget message(String text, {String? label, VoidCallback? action}) =>
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text, textAlign: TextAlign.center),
                if (action != null) ...[
                  const SizedBox(height: 16),
                  FilledButton(onPressed: action, child: Text(label!)),
                ],
              ],
            ),
          ),
        );

    Widget body = const Center(child: CircularProgressIndicator());
    if (pending == null) {
      body = message(
        l10n.shortcutNoPending,
        label: l10n.actionDone,
        action: () => leave('/dashboard'),
      );
    } else if (auth.hasError) {
      body = message(
        l10n.authErrorGeneric,
        label: l10n.shortcutRetry,
        action: () => ref.invalidate(authStateProvider),
      );
    } else if (!auth.isLoading && auth.valueOrNull != null) {
      final profile = ref.watch(userProfileStreamProvider);
      final clients = ref.watch(clientsStreamProvider);
      final catalog = ref.watch(catalogItemsStreamProvider);
      if (profile.hasError || clients.hasError || catalog.hasError) {
        body = message(
          l10n.shortcutLoadError,
          label: l10n.shortcutRetry,
          action: () {
            ref.invalidate(userProfileStreamProvider);
            ref.invalidate(clientsStreamProvider);
            ref.invalidate(catalogItemsStreamProvider);
          },
        );
      } else if (!profile.isLoading &&
          !clients.isLoading &&
          !catalog.isLoading) {
        if (!isProfileComplete(profile.valueOrNull)) {
          body = message(
            l10n.invoiceProfileRequiredBody,
            label: l10n.invoiceGoToProfile,
            action: () => leave('/more/profile'),
          );
        } else if (clients.requireValue.isEmpty) {
          body = message(
            l10n.shortcutClientRequired,
            label: l10n.clientAddTitle,
            action: () => leave('/more/clients/add'),
          );
        } else {
          final uid = auth.requireValue!.uid;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            // Recheck after the frame: auth/data or the pending delivery may
            // have changed while this callback was waiting.
            final currentAuth = ref.read(authStateProvider);
            final currentProfile = ref.read(userProfileStreamProvider);
            final currentClients = ref.read(clientsStreamProvider);
            final currentCatalog = ref.read(catalogItemsStreamProvider);
            if (currentAuth.isLoading ||
                currentAuth.hasError ||
                currentAuth.valueOrNull?.uid != uid ||
                currentProfile.isLoading ||
                currentProfile.hasError ||
                !isProfileComplete(currentProfile.valueOrNull) ||
                currentClients.isLoading ||
                currentClients.hasError ||
                (currentClients.valueOrNull?.isEmpty ?? true) ||
                currentCatalog.isLoading ||
                currentCatalog.hasError)
              return;
            if (ref.read(shortcutInboxProvider).consume(pending)) {
              context.go('/invoices/add');
            }
          });
        }
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoiceFormCreateTitle),
        leading: IconButton(
          tooltip: l10n.actionCancel,
          icon: const Icon(Icons.close),
          onPressed: () => leave('/dashboard'),
        ),
      ),
      body: body,
    );
  }
}
