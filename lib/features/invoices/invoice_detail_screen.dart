import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../data/firebase_providers.dart';
import '../../debug/agent_ndjson_log.dart';
import '../../l10n/app_localizations.dart';
import '../../models/enums.dart';
import '../../models/invoice.dart';
import '../../models/user_profile.dart';
import '../../providers/invoice_providers.dart';
import '../../providers/profile_providers.dart';
import 'invoice_pdf.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  final String invoiceId;

  static String _mad(num v) {
    final f = NumberFormat('#,##0.00', 'fr_FR');
    return '${f.format(v)} MAD';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final invAsync = ref.watch(invoiceStreamProvider(invoiceId));
    final payAsync = ref.watch(invoicePaymentsStreamProvider(invoiceId));
    final profileAsync = ref.watch(userProfileStreamProvider);

    return invAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.screenInvoiceDetail)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: Text(l10n.screenInvoiceDetail)),
        body: Center(child: Text(l10n.clientListError)),
      ),
      data: (inv) {
        if (inv == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.screenInvoiceDetail)),
            body: Center(child: Text(l10n.clientNotFound)),
          );
        }
        final overdue = inv.status != InvoiceStatus.paid &&
            inv.balance > 0.001 &&
            DateTime(inv.dueDate.year, inv.dueDate.month, inv.dueDate.day)
                .isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

        return Scaffold(
          appBar: AppBar(
            title: Text('${l10n.screenInvoiceDetail} ${inv.number}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/invoices/$invoiceId/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: () => _exportPdf(
                  context,
                  inv,
                  profileAsync.valueOrNull,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (overdue)
                Card(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                  child: ListTile(
                    leading: Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                    title: Text(l10n.invoiceOverdueBanner),
                  ),
                ),
              if (inv.isPartiallyPaid)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: Text(l10n.invoicePartiallyPaidBanner),
                  ),
                ),
              Text(l10n.invoiceSectionSeller, style: theme.textTheme.titleMedium),
              profileAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => Text(l10n.profileSaveError),
                data: (p) {
                  if (p == null) return Text(l10n.invoiceProfileMissing);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: theme.textTheme.bodyLarge),
                      Text(p.address),
                      Text('ICE: ${p.ice}'),
                      Text('IF: ${p.ifNumber}'),
                      Text('CNSS: ${p.cnssNumber}'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(l10n.invoiceSectionClient, style: theme.textTheme.titleMedium),
              Text(inv.clientName, style: theme.textTheme.bodyLarge),
              Text(inv.clientAddress),
              Text('ICE: ${inv.clientIce}'),
              Text('IF: ${inv.clientIf}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(l10n.invoiceFieldStatus, style: theme.textTheme.labelLarge),
                  const SizedBox(width: 12),
                  DropdownButton<InvoiceStatus>(
                    value: inv.status,
                    items: InvoiceStatus.values
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(_statusLabel(l10n, s)),
                          ),
                        )
                        .toList(),
                    onChanged: (s) async {
                      if (s == null) return;
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) return;
                      await ref.read(invoiceRepositoryProvider).updateInvoice(
                            inv.copyWith(status: s),
                          );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.invoiceFieldIssueDate}: ${MaterialLocalizations.of(context).formatMediumDate(inv.issueDate)}',
              ),
              Text(
                '${l10n.invoiceFieldDueDate}: ${MaterialLocalizations.of(context).formatMediumDate(inv.dueDate)}',
              ),
              const SizedBox(height: 16),
              Text(l10n.invoiceLineItems, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...inv.items.map(
                (i) => ListTile(
                  dense: true,
                  title: Text(i.description),
                  subtitle: Text('${i.quantity} × ${_mad(i.unitPrice)}'),
                  trailing: Text(_mad(i.lineTotal)),
                ),
              ),
              const Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${l10n.invoiceTotal}: ${_mad(inv.subtotal)}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text('${l10n.invoicePaid}: ${_mad(inv.paidTotal)}'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${l10n.invoiceBalance}: ${_mad(inv.balance)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: inv.balance > 0.001 ? theme.colorScheme.primary : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.invoicePaymentsSection, style: theme.textTheme.titleMedium),
              payAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => Text(l10n.clientListError),
                data: (payments) {
                  if (payments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(l10n.invoiceNoPayments, style: theme.textTheme.bodySmall),
                    );
                  }
                  return Column(
                    children: payments
                        .map(
                          (p) => ListTile(
                            title: Text(_mad(p.amount)),
                            subtitle: Text(
                              '${MaterialLocalizations.of(context).formatMediumDate(p.date)} · ${_methodLabel(l10n, p.method)}',
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => _showAddPayment(context, ref, inv),
                child: Text(l10n.invoiceAddPayment),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _statusLabel(AppLocalizations l10n, InvoiceStatus s) {
    return switch (s) {
      InvoiceStatus.draft => l10n.invoiceStatusDraft,
      InvoiceStatus.sent => l10n.invoiceStatusSent,
      InvoiceStatus.paid => l10n.invoiceStatusPaid,
      InvoiceStatus.overdue => l10n.invoiceStatusOverdue,
    };
  }

  static String _methodLabel(AppLocalizations l10n, PaymentMethod m) {
    return switch (m) {
      PaymentMethod.cash => l10n.paymentMethodCash,
      PaymentMethod.virement => l10n.paymentMethodVirement,
      PaymentMethod.cheque => l10n.paymentMethodCheque,
      PaymentMethod.autre => l10n.paymentMethodAutre,
    };
  }

  static Future<void> _exportPdf(
    BuildContext context,
    Invoice inv,
    UserProfile? profile,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invoiceProfileMissing)),
      );
      return;
    }
    final parentContext = context;

    // Keep the dialog on the shell branch navigator; defer work until after the
    // route is committed — otherwise a fast PDF build + pop can run before the
    // dialog exists and root pop removes the GoRouter page (empty stack assert).
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (dialogCtx) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            // #region agent log
            await agentNdjsonLog(
              hypothesisId: 'E',
              location: 'invoice_detail_screen.dart:_exportPdf',
              message: 'pdf_export_callback_start',
              data: {'invoiceId': inv.id},
            );
            // #endregion
            final bytes =
                await buildInvoicePdfBytes(invoice: inv, profile: profile);
            // #region agent log
            await agentNdjsonLog(
              hypothesisId: 'A',
              location: 'invoice_detail_screen.dart:_exportPdf',
              message: 'buildInvoicePdfBytes_returned',
              data: {'byteLength': bytes.length},
            );
            // #endregion
            if (!dialogCtx.mounted) return;
            Navigator.of(dialogCtx).pop();
            try {
              await Printing.layoutPdf(onLayout: (_) async => bytes);
              // #region agent log
              await agentNdjsonLog(
                hypothesisId: 'E',
                location: 'invoice_detail_screen.dart:_exportPdf',
                message: 'layoutPdf_ok',
                data: const {},
              );
              // #endregion
            } catch (e) {
              // #region agent log
              await agentNdjsonLog(
                hypothesisId: 'E',
                location: 'invoice_detail_screen.dart:_exportPdf',
                message: 'layoutPdf_failed',
                data: {
                  'errorType': e.runtimeType.toString(),
                  'error': e.toString(),
                },
              );
              // #endregion
              rethrow;
            }
          } catch (e) {
            // #region agent log
            await agentNdjsonLog(
              hypothesisId: 'A',
              location: 'invoice_detail_screen.dart:_exportPdf',
              message: 'pdf_export_caught',
              data: {
                'errorType': e.runtimeType.toString(),
                'error': e.toString(),
              },
            );
            // #endregion
            if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
            if (parentContext.mounted) {
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(content: Text(l10n.invoicePdfError)),
              );
            }
          }
        });
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  static Future<void> _showAddPayment(
    BuildContext context,
    WidgetRef ref,
    Invoice inv,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final amountCtrl = TextEditingController();
    var date = DateTime.now();
    var method = PaymentMethod.virement;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(l10n.invoiceAddPayment),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.invoicePaymentAmount,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(l10n.invoicePaymentDate),
                  subtitle: Text(MaterialLocalizations.of(ctx).formatMediumDate(date)),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setSt(() => date = d);
                  },
                ),
                DropdownButtonFormField<PaymentMethod>(
                  value: method,
                  decoration: InputDecoration(
                    labelText: l10n.invoicePaymentMethod,
                    border: const OutlineInputBorder(),
                  ),
                  items: PaymentMethod.values
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(_methodLabel(l10n, m)),
                        ),
                      )
                      .toList(),
                  onChanged: (m) {
                    if (m != null) setSt(() => method = m);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.actionDone),
            ),
          ],
        ),
      ),
    );

    final amountText = amountCtrl.text;
    amountCtrl.dispose();

    if (ok != true || !context.mounted) return;
    final amt = double.tryParse(amountText.replaceAll(',', '.'));
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invoiceFormValidation)),
      );
      return;
    }

    try {
      await ref.read(invoiceRepositoryProvider).addPayment(
            uid: uid,
            invoiceId: inv.id,
            amount: amt,
            date: date,
            method: method,
          );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invoiceSaveError)),
        );
      }
    }
  }
}
