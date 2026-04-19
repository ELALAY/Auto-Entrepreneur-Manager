import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/firebase_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../models/client.dart';
import '../../models/enums.dart';
import '../../models/invoice.dart';
import '../../models/invoice_item.dart';
import '../../providers/client_providers.dart';
import '../../providers/invoice_providers.dart';

class InvoiceFormScreen extends ConsumerStatefulWidget {
  const InvoiceFormScreen({super.key, this.invoiceId});

  final String? invoiceId;

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _LineRow {
  _LineRow({required this.description, required this.qty, required this.unit});

  final TextEditingController description;
  final TextEditingController qty;
  final TextEditingController unit;
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  String? _clientId;
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  InvoiceStatus _status = InvoiceStatus.draft;
  bool _signatureEnabled = false;
  final _notes = TextEditingController();
  final List<_LineRow> _lines = [];
  bool _synced = false;
  bool _saving = false;
  String _number = '';

  bool get _isEdit => widget.invoiceId != null;

  @override
  void initState() {
    super.initState();
    _lines.add(_LineRow(
      description: TextEditingController(),
      qty: TextEditingController(text: '1'),
      unit: TextEditingController(),
    ));
    if (!_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _synced = true);
      });
    }
  }

  @override
  void dispose() {
    for (final l in _lines) {
      l.description.dispose();
      l.qty.dispose();
      l.unit.dispose();
    }
    _notes.dispose();
    super.dispose();
  }

  void _applyInvoice(Invoice? inv) {
    if (_synced) return;
    _synced = true;
    if (inv == null) return;
    _clientId = inv.clientId;
    _issueDate = inv.issueDate;
    _dueDate = inv.dueDate;
    _status = inv.status;
    _signatureEnabled = inv.signatureEnabled;
    _notes.text = inv.notes ?? '';
    _number = inv.number;
    for (final l in _lines) {
      l.description.dispose();
      l.qty.dispose();
      l.unit.dispose();
    }
    _lines.clear();
    for (final i in inv.items) {
      _lines.add(_LineRow(
        description: TextEditingController(text: i.description),
        qty: TextEditingController(text: i.quantity.toString()),
        unit: TextEditingController(text: i.unitPrice.toString()),
      ));
    }
    if (_lines.isEmpty) {
      _lines.add(_LineRow(
        description: TextEditingController(),
        qty: TextEditingController(text: '1'),
        unit: TextEditingController(),
      ));
    }
    setState(() {});
  }

  List<InvoiceItem> _buildItems() {
    return _lines.map((l) {
      final q = double.tryParse(l.qty.text.replaceAll(',', '.')) ?? 0;
      final u = double.tryParse(l.unit.text.replaceAll(',', '.')) ?? 0;
      return InvoiceItem(
        description: l.description.text.trim(),
        quantity: q,
        unitPrice: u,
      );
    }).where((i) => i.description.isNotEmpty).toList();
  }

  Client? _selectedClient(List<Client> clients) {
    if (_clientId == null) return null;
    try {
      return clients.firstWhere((c) => c.id == _clientId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final items = _buildItems();
    if (_clientId == null || items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invoiceFormValidation)),
      );
      return;
    }

    final clients = ref.read(clientsStreamProvider).valueOrNull ?? [];
    final client = _selectedClient(clients);
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invoiceFormValidation)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        final id = widget.invoiceId!;
        final existing = ref.read(invoiceStreamProvider(id)).valueOrNull;
        if (existing == null) throw StateError('missing');
        final updated = Invoice(
          id: id,
          userId: uid,
          clientId: client.id,
          clientName: client.name,
          clientAddress: client.address,
          clientIce: client.ice,
          clientIf: client.ifNumber,
          number: existing.number,
          issueDate: _issueDate,
          dueDate: _dueDate,
          status: _status,
          items: items,
          signatureEnabled: _signatureEnabled,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          paidTotal: existing.paidTotal,
        );
        await ref.read(invoiceRepositoryProvider).updateInvoice(updated);
      } else {
        final newId = await ref.read(invoiceRepositoryProvider).createInvoice(
              uid: uid,
              clientId: client.id,
              clientName: client.name,
              clientAddress: client.address,
              clientIce: client.ice,
              clientIf: client.ifNumber,
              issueDate: _issueDate,
              dueDate: _dueDate,
              status: _status,
              items: items,
              signatureEnabled: _signatureEnabled,
              notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invoiceSaved)),
        );
        context.go('/invoices/$newId');
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invoiceSaved)),
      );
      if (_isEdit) {
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.invoiceSaveError),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final clientsAsync = ref.watch(clientsStreamProvider);

    if (_isEdit) {
      ref.listen(invoiceStreamProvider(widget.invoiceId!), (prev, next) {
        next.whenData((inv) {
          if (_synced) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _applyInvoice(inv));
          });
        });
      });
    }

    final invAsync =
        _isEdit ? ref.watch(invoiceStreamProvider(widget.invoiceId!)) : null;

    if (_isEdit) {
      return invAsync!.when(
        loading: () => Scaffold(
          appBar: AppBar(title: Text(l10n.invoiceFormEditTitle)),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => Scaffold(
          appBar: AppBar(title: Text(l10n.invoiceFormEditTitle)),
          body: Center(child: Text(l10n.clientListError)),
        ),
        data: (inv) {
          if (!_synced) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.invoiceFormEditTitle)),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          if (inv == null) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.invoiceFormEditTitle)),
              body: Center(child: Text(l10n.clientNotFound)),
            );
          }
          return _scaffold(context, l10n, clientsAsync);
        },
      );
    }

    return _scaffold(context, l10n, clientsAsync);
  }

  Widget _scaffold(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<List<Client>> clientsAsync,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.invoiceFormEditTitle : l10n.invoiceFormCreateTitle),
      ),
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.clientListError)),
        data: (clients) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_isEdit && _number.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${l10n.invoiceNumberLabel}: $_number',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              DropdownButtonFormField<String>(
                value: _clientId != null &&
                        clients.any((c) => c.id == _clientId)
                    ? _clientId
                    : null,
                decoration: InputDecoration(
                  labelText: l10n.invoiceFieldClient,
                  border: const OutlineInputBorder(),
                ),
                items: clients
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _clientId = v),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(l10n.invoiceFieldIssueDate),
                subtitle: Text(MaterialLocalizations.of(context).formatMediumDate(_issueDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _issueDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) setState(() => _issueDate = d);
                },
              ),
              ListTile(
                title: Text(l10n.invoiceFieldDueDate),
                subtitle: Text(MaterialLocalizations.of(context).formatMediumDate(_dueDate)),
                trailing: const Icon(Icons.event),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) setState(() => _dueDate = d);
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<InvoiceStatus>(
                value: _status,
                decoration: InputDecoration(
                  labelText: l10n.invoiceFieldStatus,
                  border: const OutlineInputBorder(),
                ),
                items: InvoiceStatus.values
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(_statusLabel(l10n, s)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _status = v);
                },
              ),
              const SizedBox(height: 16),
              Text(l10n.invoiceLineItems, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...List.generate(_lines.length, (index) {
                final row = _lines[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: row.description,
                          decoration: InputDecoration(
                            labelText: l10n.invoiceLineDescription,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: row.qty,
                                decoration: InputDecoration(
                                  labelText: l10n.invoiceLineQty,
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: row.unit,
                                decoration: InputDecoration(
                                  labelText: l10n.invoiceLineUnitPrice,
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            IconButton(
                              onPressed: _lines.length <= 1
                                  ? null
                                  : () {
                                      setState(() {
                                        row.description.dispose();
                                        row.qty.dispose();
                                        row.unit.dispose();
                                        _lines.removeAt(index);
                                      });
                                    },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _lines.add(_LineRow(
                      description: TextEditingController(),
                      qty: TextEditingController(text: '1'),
                      unit: TextEditingController(),
                    ));
                  });
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.invoiceAddLine),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(l10n.invoiceSignatureOnPdf),
                value: _signatureEnabled,
                onChanged: (v) => setState(() => _signatureEnabled = v),
              ),
              TextField(
                controller: _notes,
                decoration: InputDecoration(
                  labelText: l10n.invoiceFieldNotes,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
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
          );
        },
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, InvoiceStatus s) {
    return switch (s) {
      InvoiceStatus.draft => l10n.invoiceStatusDraft,
      InvoiceStatus.sent => l10n.invoiceStatusSent,
      InvoiceStatus.paid => l10n.invoiceStatusPaid,
      InvoiceStatus.overdue => l10n.invoiceStatusOverdue,
    };
  }
}
