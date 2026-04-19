import '../domain/tax/activity_category.dart';
import 'enums.dart';
import 'invoice_item.dart';

class Invoice {
  const Invoice({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.clientName,
    required this.clientAddress,
    required this.clientIce,
    required this.clientIf,
    required this.number,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    required this.items,
    required this.signatureEnabled,
    required this.paidTotal,
    this.templateId,
    this.notes,
    this.activityCategory,
    this.invoiceUseBundledLogo,
    this.invoiceLogoUrl,
  });

  final String id;
  final String userId;
  final String clientId;

  /// Snapshot at save time (INVC-05).
  final String clientName;
  final String clientAddress;
  final String clientIce;
  final String clientIf;

  final String number;
  final DateTime issueDate;
  final DateTime dueDate;
  final InvoiceStatus status;
  final List<InvoiceItem> items;
  final bool signatureEnabled;
  final String? templateId;
  final String? notes;

  /// Tax activity family snapshot at save time (for filtering and history).
  final ActivityCategory? activityCategory;

  /// Denormalized sum of payments (updated when payments are recorded).
  final double paidTotal;

  /// null: invoice has no logo fields (legacy) — PDF uses first profile brand logo if any.
  /// true: use bundled app default image only.
  /// false: use [invoiceLogoUrl] when set.
  final bool? invoiceUseBundledLogo;
  final String? invoiceLogoUrl;

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  double get balance => (subtotal - paidTotal).clamp(0.0, double.infinity);

  bool get isPartiallyPaid => paidTotal > 0.001 && balance > 0.001;

  Invoice copyWith({
    String? id,
    String? userId,
    String? clientId,
    String? clientName,
    String? clientAddress,
    String? clientIce,
    String? clientIf,
    String? number,
    DateTime? issueDate,
    DateTime? dueDate,
    InvoiceStatus? status,
    List<InvoiceItem>? items,
    bool? signatureEnabled,
    String? templateId,
    String? notes,
    double? paidTotal,
    ActivityCategory? activityCategory,
    bool? invoiceUseBundledLogo,
    String? invoiceLogoUrl,
    bool clearTemplateId = false,
    bool clearNotes = false,
    bool clearActivityCategory = false,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientAddress: clientAddress ?? this.clientAddress,
      clientIce: clientIce ?? this.clientIce,
      clientIf: clientIf ?? this.clientIf,
      number: number ?? this.number,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      items: items ?? this.items,
      signatureEnabled: signatureEnabled ?? this.signatureEnabled,
      templateId: clearTemplateId ? null : (templateId ?? this.templateId),
      notes: clearNotes ? null : (notes ?? this.notes),
      paidTotal: paidTotal ?? this.paidTotal,
      activityCategory: clearActivityCategory
          ? null
          : (activityCategory ?? this.activityCategory),
      invoiceUseBundledLogo:
          invoiceUseBundledLogo ?? this.invoiceUseBundledLogo,
      invoiceLogoUrl: invoiceLogoUrl ?? this.invoiceLogoUrl,
    );
  }
}
