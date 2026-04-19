import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/firebase_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../models/client.dart';
import '../../providers/client_providers.dart';

/// Create (`clientId == null`) or edit an existing client.
class ClientFormScreen extends ConsumerStatefulWidget {
  const ClientFormScreen({super.key, this.clientId});

  final String? clientId;

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _ice = TextEditingController();
  final _ifNumber = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  bool _synced = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.clientId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _synced = true);
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _ice.dispose();
    _ifNumber.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _applyClient(Client? c) {
    if (_synced) return;
    _synced = true;
    if (c == null) return;
    _name.text = c.name;
    _address.text = c.address;
    _ice.text = c.ice;
    _ifNumber.text = c.ifNumber;
    _email.text = c.email;
    _phone.text = c.phone;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final fs = ref.read(firebaseFirestoreProvider);
    final id = widget.clientId ??
        fs.collection('users/$uid/clients').doc().id;

    final client = Client(
      id: id,
      userId: uid,
      name: _name.text.trim(),
      address: _address.text.trim(),
      ice: _ice.text.trim(),
      ifNumber: _ifNumber.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
    );

    setState(() => _saving = true);
    try {
      await ref.read(clientRepositoryProvider).upsertClient(client);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.clientSaved)),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.clientSaveError),
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
    final id = widget.clientId;
    if (uid == null || id == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clientDeleteTitle),
        content: Text(l10n.clientDeleteBody),
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
    if (ok != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await ref.read(clientRepositoryProvider).deleteClient(uid, id);
      if (!mounted) return;
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.clientSaveError),
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
    final isEdit = widget.clientId != null;

    if (isEdit) {
      ref.listen(clientStreamProvider(widget.clientId!), (prev, next) {
        next.whenData((c) {
          if (_synced) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _applyClient(c));
          });
        });
      });
    }

    final clientAsync =
        isEdit ? ref.watch(clientStreamProvider(widget.clientId!)) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l10n.clientEditTitle : l10n.clientAddTitle),
        actions: [
          if (isEdit)
            IconButton(
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: isEdit
          ? clientAsync!.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(child: Text(l10n.clientListError)),
              data: (c) {
                if (!_synced) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (c == null) {
                  return Center(child: Text(l10n.clientNotFound));
                }
                return _buildForm(context, l10n, isEdit);
              },
            )
          : _buildForm(context, l10n, isEdit),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    bool isEdit,
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _name,
            decoration: InputDecoration(
              labelText: l10n.clientFieldName,
              border: const OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l10n.clientValidationRequired : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _address,
            decoration: InputDecoration(
              labelText: l10n.clientFieldAddress,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l10n.clientValidationRequired : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ice,
            decoration: InputDecoration(
              labelText: l10n.clientFieldIce,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ifNumber,
            decoration: InputDecoration(
              labelText: l10n.clientFieldIf,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            decoration: InputDecoration(
              labelText: l10n.clientFieldEmail,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            decoration: InputDecoration(
              labelText: l10n.clientFieldPhone,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
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
    );
  }
}
