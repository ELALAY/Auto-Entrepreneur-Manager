import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/firebase_providers.dart';
import '../../domain/expense/expense_category.dart';
import '../../l10n/app_localizations.dart';
import '../../models/expense.dart';
import '../../providers/expense_providers.dart';
import 'expense_l10n.dart';

/// Create ([expenseId] null) or edit an expense.
class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, this.expenseId});

  final String? expenseId;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  DateTime _date = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  ExpenseCategory _category = ExpenseCategory.other;
  bool _synced = false;
  bool _saving = false;

  Uint8List? _pickedBytes;
  String? _pickedContentType;
  bool _removeReceipt = false;
  String? _existingReceiptUrl;

  @override
  void initState() {
    super.initState();
    if (widget.expenseId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _synced = true);
      });
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _applyExpense(Expense? e) {
    if (_synced || e == null) return;
    setState(() {
      _synced = true;
      _amountCtrl.text = e.amount.toStringAsFixed(2).replaceAll('.', ',');
      _descriptionCtrl.text = e.description;
      _date = e.date;
      _category = e.category;
      _existingReceiptUrl = e.receiptUrl;
    });
  }

  double? _parseAmount(String raw) {
    final t = raw.trim().replaceAll(RegExp(r'\s'), '').replaceAll(',', '.');
    return double.tryParse(t);
  }

  String _guessContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 88,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    final mime = x.mimeType ?? _guessContentType(x.path);
    setState(() {
      _pickedBytes = bytes;
      _pickedContentType = mime;
      _removeReceipt = false;
    });
  }

  void _clearReceipt() {
    setState(() {
      _pickedBytes = null;
      _pickedContentType = null;
      _removeReceipt = true;
    });
  }

  Future<void> _pickDate() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 2),
      helpText: l10n.expenseFieldDate,
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final amt = _parseAmount(_amountCtrl.text);
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.expenseAmountInvalid)),
      );
      return;
    }

    final fs = ref.read(firebaseFirestoreProvider);
    final repo = ref.read(expenseRepositoryProvider);
    final id = widget.expenseId ??
        fs.collection('users/$uid/expenses').doc().id;

    setState(() => _saving = true);
    try {
      String? receiptUrl = _existingReceiptUrl;

      if (_removeReceipt && _pickedBytes == null) {
        if (_existingReceiptUrl != null && _existingReceiptUrl!.isNotEmpty) {
          await repo.deleteReceiptInStorage(_existingReceiptUrl!);
        }
        receiptUrl = null;
      }

      if (_pickedBytes != null && _pickedContentType != null) {
        if (_existingReceiptUrl != null &&
            _existingReceiptUrl!.isNotEmpty &&
            !_removeReceipt) {
          await repo.deleteReceiptInStorage(_existingReceiptUrl!);
        }
        receiptUrl = await repo.uploadReceipt(
          uid,
          id,
          _pickedBytes!,
          _pickedContentType!,
        );
      }

      final expense = Expense(
        id: id,
        userId: uid,
        date: _date,
        amount: amt,
        category: _category,
        description: _descriptionCtrl.text.trim(),
        receiptUrl: receiptUrl,
      );

      await repo.upsertExpense(expense);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.expenseSaved)),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.expenseSaveError),
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
    final theme = Theme.of(context);
    final isEdit = widget.expenseId != null;

    if (isEdit) {
      final async = ref.watch(expenseStreamProvider(widget.expenseId!));
      async.whenData(_applyExpense);
      if (!async.hasValue && !async.hasError) {
        return Scaffold(
          appBar: AppBar(
            title: Text(isEdit ? l10n.expenseFormEditTitle : l10n.expenseFormAddTitle),
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      if (async.hasError || async.value == null) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.expenseFormEditTitle)),
          body: Center(child: Text(l10n.expenseSaveError)),
        );
      }
      if (!_synced) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.expenseFormEditTitle)),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
    }

    final showReceiptPreview =
        !_removeReceipt &&
            ((_pickedBytes != null) ||
                (_existingReceiptUrl != null && _existingReceiptUrl!.isNotEmpty));

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l10n.expenseFormEditTitle : l10n.expenseFormAddTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountCtrl,
              decoration: InputDecoration(
                labelText: l10n.expenseFieldAmount,
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
              ],
              validator: (v) {
                final n = _parseAmount(v ?? '');
                if (n == null || n <= 0) return l10n.expenseAmountInvalid;
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.expenseFieldDate),
              subtitle: Text(
                MaterialLocalizations.of(context).formatFullDate(_date),
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _saving ? null : _pickDate,
            ),
            const Divider(),
            DropdownButtonFormField<ExpenseCategory>(
              value: _category,
              decoration: InputDecoration(
                labelText: l10n.expenseFieldCategory,
                border: const OutlineInputBorder(),
              ),
              items: ExpenseCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(expenseCategoryLabel(l10n, c)),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (v) {
                      if (v != null) setState(() => _category = v);
                    },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: InputDecoration(
                labelText: l10n.expenseFieldDescription,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.expenseFieldReceipt,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (showReceiptPreview)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _pickedBytes != null
                    ? Image.memory(
                        _pickedBytes!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        _existingReceiptUrl!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(l10n.expenseSaveError),
                        ),
                      ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickReceipt,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(
                    showReceiptPreview && !_removeReceipt
                        ? l10n.expenseReplaceReceipt
                        : l10n.expenseAttachReceipt,
                  ),
                ),
                if (showReceiptPreview)
                  TextButton.icon(
                    onPressed: _saving ? null : _clearReceipt,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.expenseRemoveReceipt),
                  ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: (_saving || (isEdit && !_synced)) ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.actionSave),
          ),
        ),
      ),
    );
  }
}
