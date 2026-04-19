import 'package:auto_entrepreneur_manager/domain/tax/activity_category.dart';
import 'package:auto_entrepreneur_manager/features/invoices/invoice_pdf.dart';
import 'package:auto_entrepreneur_manager/models/branding_config.dart';
import 'package:auto_entrepreneur_manager/models/invoice.dart';
import 'package:auto_entrepreneur_manager/models/invoice_item.dart';
import 'package:auto_entrepreneur_manager/models/enums.dart';
import 'package:auto_entrepreneur_manager/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
  });

  test('buildInvoicePdfBytes succeeds with bundled Helvetica (no network)', () async {
    final invoice = Invoice(
      id: 'i1',
      userId: 'u1',
      clientId: 'c1',
      clientName: 'Client SARL',
      clientAddress: 'Casablanca',
      clientIce: 'ICE123',
      clientIf: 'IF456',
      number: '000001',
      issueDate: DateTime(2026, 1, 15),
      dueDate: DateTime(2026, 2, 15),
      status: InvoiceStatus.sent,
      items: [
        InvoiceItem(description: 'Prestation — développement', quantity: 2, unitPrice: 1500),
      ],
      signatureEnabled: false,
      paidTotal: 0,
    );

    const profile = UserProfile(
      uid: 'u1',
      name: 'Auto Entrepreneur',
      cin: 'AB12',
      ice: 'ICE999',
      ifNumber: 'IF888',
      cnssNumber: 'CNSS1',
      activityCategory: ActivityCategory.liberal,
      address: 'Rabat',
      branding: BrandingConfig(accentColorArgb: 0xFF00695C),
    );

    final bytes = await buildInvoicePdfBytes(
      invoice: invoice,
      profile: profile,
      fontBase: pw.Font.helvetica(),
      fontBold: pw.Font.helveticaBold(),
    );

    expect(bytes, isNotEmpty);
    expect(bytes.sublist(0, 4), equals('%PDF'.codeUnits));
  });
}
