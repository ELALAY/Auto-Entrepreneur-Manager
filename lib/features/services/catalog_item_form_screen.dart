import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/firebase_providers.dart';
import '../../domain/tax/activity_category.dart';
import '../../l10n/app_localizations.dart';
import '../../models/catalog_item.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/profile_providers.dart';

/// Create (`itemId == null`) or edit an existing catalog entry.
class CatalogItemFormScreen extends ConsumerStatefulWidget {
  const CatalogItemFormScreen({super.key, this.itemId});

  final String? itemId;

  @override
  ConsumerState<CatalogItemFormScreen> createState() =>
      _CatalogItemFormScreenState();
}

class _CatalogItemFormScreenState extends ConsumerState<CatalogItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _unitPrice = TextEditingController();
  CatalogKind _kind = CatalogKind.service;
  ActivityCategory _activityCategory = ActivityCategory.commercial;

  bool _synced = false;
  bool _saving = false;

  bool get _isEdit => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    if (!_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _synced = true);
      });
    }
  }

  @override
  void dispose() {
    _description.dispose();
    _unitPrice.dispose();
    super.dispose();
  }

  void _applyItem(CatalogItem? item) {
    if (_synced) return;
    _synced = true;
    if (item == null) return;
    _description.text = item.description;
    _unitPrice.text = item.defaultUnitPrice.toString();
    _kind = item.kind;
    _activityCategory = item.activityCategory;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final price = double.tryParse(_unitPrice.text.replaceAll(',', '.')) ?? 0;
    if (price < 0) return;

    final fs = ref.read(firebaseFirestoreProvider);
    final id = widget.itemId ?? fs.collection('users/$uid/catalogItems').doc().id;

    final item = CatalogItem(
      id: id,
      userId: uid,
      description: _description.text.trim(),
      defaultUnitPrice: price,
      kind: _kind,
      activityCategory: _activityCategory,
    );

    setState(() => _saving = true);
    try {
      await ref.read(catalogRepositoryProvider).upsertItem(item);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogSaved)),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.catalogSaveError),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final id = widget.itemId;
    if (uid == null || id == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.catalogDeleteTitle),
        content: Text(l10n.catalogDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await ref.read(catalogRepositoryProvider).deleteItem(uid, id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.catalogDeleted)),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.catalogSaveError),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isEdit) {
      final itemAsync = ref.watch(catalogItemStreamProvider(widget.itemId!));
      return itemAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: Text(l10n.catalogEditTitle)),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => Scaffold(
          appBar: AppBar(title: Text(l10n.catalogEditTitle)),
          body: Center(child: Text(l10n.catalogListError)),
        ),
        data: (item) {
          if (!_synced) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (item != null) {
                setState(() => _applyItem(item));
              } else {
                setState(() => _synced = true);
              }
            });
            return Scaffold(
              appBar: AppBar(title: Text(l10n.catalogEditTitle)),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (item == null) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.catalogEditTitle)),
              body: Center(child: Text(l10n.catalogNotFound)),
            );
          }
          return _formScaffold(context, l10n);
        },
      );
    }

    return _formScaffold(context, l10n);
  }

  Widget _formScaffold(BuildContext context, AppLocalizations l10n) {
    final profile = ref.watch(userProfileStreamProvider).valueOrNull;
    final activityChoices = profile != null && profile.activityCategories.isNotEmpty
        ? profile.activityCategories
        : ActivityCategory.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.catalogEditTitle : l10n.catalogAddTitle),
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<CatalogKind>(
              value: _kind,
              decoration: InputDecoration(
                labelText: l10n.catalogFieldKind,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: CatalogKind.service,
                  child: Text(l10n.catalogKindService),
                ),
                DropdownMenuItem(
                  value: CatalogKind.product,
                  child: Text(l10n.catalogKindProduct),
                ),
              ],
              onChanged: _saving
                  ? null
                  : (v) {
                      if (v != null) setState(() => _kind = v);
                    },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ActivityCategory>(
              value: activityChoices.contains(_activityCategory)
                  ? _activityCategory
                  : activityChoices.first,
              decoration: InputDecoration(
                labelText: l10n.catalogFieldActivityCategory,
                border: const OutlineInputBorder(),
              ),
              items: activityChoices
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(_activityLabel(l10n, c)),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (v) {
                      if (v != null) setState(() => _activityCategory = v);
                    },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              decoration: InputDecoration(
                labelText: l10n.catalogFieldDescription,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.catalogValidationDescription;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _unitPrice,
              decoration: InputDecoration(
                labelText: l10n.catalogFieldDefaultUnitPrice,
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.catalogValidationPrice;
                }
                final n = double.tryParse(v.replaceAll(',', '.'));
                if (n == null || n < 0) return l10n.catalogValidationPrice;
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }

  String _activityLabel(AppLocalizations l10n, ActivityCategory c) {
    switch (c) {
      case ActivityCategory.commercial:
        return l10n.activityCommercialShort;
      case ActivityCategory.artisanal:
        return l10n.activityArtisanalShort;
      case ActivityCategory.liberal:
        return l10n.activityLiberalShort;
      case ActivityCategory.services:
        return l10n.activityServicesShort;
    }
  }
}
