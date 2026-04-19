import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../debug/agent_ndjson_log.dart';
import '../../models/invoice.dart';
import '../../models/user_profile.dart';

/// [DateFormat.yMMMd] for `fr_FR` throws until this completes (see unit test setUpAll).
Future<void>? _frLocaleInitFuture;

Future<void> _ensureFrenchLocaleData() =>
    _frLocaleInitFuture ??= initializeDateFormatting('fr_FR');

Future<Uint8List?> _loadUrlBytes(String? url) async {
  if (url == null || url.isEmpty) return null;
  try {
    final r = await http.get(Uri.parse(url));
    if (r.statusCode == 200) return r.bodyBytes;
  } catch (_) {}
  return null;
}

String _mad(num value) {
  final f = NumberFormat('#,##0.00', 'fr_FR');
  return '${f.format(value)} MAD';
}

/// Open Sans TTFs bundled under [assets/fonts] (same family as Google Fonts; no runtime download).
const _fontRegularAsset = 'assets/fonts/OpenSans-Regular.ttf';
const _fontBoldAsset = 'assets/fonts/OpenSans-Bold.ttf';

Future<List<pw.Font>> _loadOpenSansFromAssetsOrGoogle() async {
  try {
    final fonts = [
      pw.Font.ttf(await rootBundle.load(_fontRegularAsset)),
      pw.Font.ttf(await rootBundle.load(_fontBoldAsset)),
    ];
    // #region agent log
    await agentNdjsonLog(
      hypothesisId: 'C',
      location: 'invoice_pdf.dart:_loadOpenSansFromAssetsOrGoogle',
      message: 'fonts_loaded_assets',
      data: const {},
    );
    // #endregion
    return fonts;
  } catch (e) {
    // #region agent log
    await agentNdjsonLog(
      hypothesisId: 'C',
      location: 'invoice_pdf.dart:_loadOpenSansFromAssetsOrGoogle',
      message: 'assets_font_failed_trying_google',
      data: {
        'errorType': e.runtimeType.toString(),
        'error': e.toString(),
      },
    );
    // #endregion
    try {
      final fonts = [
        await PdfGoogleFonts.openSansRegular(),
        await PdfGoogleFonts.openSansBold(),
      ];
      // #region agent log
      await agentNdjsonLog(
        hypothesisId: 'C',
        location: 'invoice_pdf.dart:_loadOpenSansFromAssetsOrGoogle',
        message: 'fonts_loaded_google',
        data: const {},
      );
      // #endregion
      return fonts;
    } catch (e2) {
      // #region agent log
      await agentNdjsonLog(
        hypothesisId: 'C',
        location: 'invoice_pdf.dart:_loadOpenSansFromAssetsOrGoogle',
        message: 'google_font_also_failed',
        data: {
          'errorType': e2.runtimeType.toString(),
          'error': e2.toString(),
        },
      );
      // #endregion
      rethrow;
    }
  }
}

/// Builds invoice PDF. Pass [fontBase]/[fontBold] in tests to avoid loading assets.
Future<Uint8List> buildInvoicePdfBytes({
  required Invoice invoice,
  required UserProfile profile,
  pw.Font? fontBase,
  pw.Font? fontBold,
}) async {
  // #region agent log
  await agentNdjsonLog(
    hypothesisId: 'A',
    location: 'invoice_pdf.dart:buildInvoicePdfBytes',
    message: 'build_start',
    data: {'invoiceId': invoice.id, 'itemCount': invoice.items.length},
  );
  // #endregion
  try {
    await _ensureFrenchLocaleData();
    // #region agent log
    await agentNdjsonLog(
      hypothesisId: 'B',
      location: 'invoice_pdf.dart:buildInvoicePdfBytes',
      message: 'locale_init_ok',
      data: const {},
    );
    // #endregion
  } catch (e) {
    // #region agent log
    await agentNdjsonLog(
      hypothesisId: 'B',
      location: 'invoice_pdf.dart:buildInvoicePdfBytes',
      message: 'locale_init_failed',
      data: {
        'errorType': e.runtimeType.toString(),
        'error': e.toString(),
      },
    );
    // #endregion
    rethrow;
  }

  final pw.Font base;
  final pw.Font bold;
  if (fontBase != null && fontBold != null) {
    base = fontBase;
    bold = fontBold;
  } else {
    final loaded = await _loadOpenSansFromAssetsOrGoogle();
    base = loaded[0];
    bold = loaded[1];
  }

  final logoBytes = await _loadUrlBytes(profile.logoUrl);
  final signatureBytes =
      invoice.signatureEnabled ? await _loadUrlBytes(profile.signatureUrl) : null;

  // #region agent log
  await agentNdjsonLog(
    hypothesisId: 'D',
    location: 'invoice_pdf.dart:buildInvoicePdfBytes',
    message: 'images_resolved',
    data: {
      'logoBytes': logoBytes?.length ?? 0,
      'signatureBytes': signatureBytes?.length ?? 0,
      'signatureEnabled': invoice.signatureEnabled,
    },
  );
  // #endregion

  final accentArgb = profile.branding.accentColorArgb ?? 0xFF00695C;
  final accent = PdfColor.fromInt(accentArgb);

  final issueStr = DateFormat.yMMMd('fr_FR').format(invoice.issueDate);
  final dueStr = DateFormat.yMMMd('fr_FR').format(invoice.dueDate);

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: base, bold: bold),
  );

  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        margin: const pw.EdgeInsets.all(40),
        buildBackground: (ctx) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: accent, width: 6),
              ),
            ),
          ),
        ),
      ),
      build: (ctx) => [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logoBytes != null)
              pw.Padding(
                padding: const pw.EdgeInsets.only(right: 16),
                child: pw.Image(
                  pw.MemoryImage(logoBytes),
                  width: 72,
                  height: 72,
                ),
              ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    profile.name,
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(profile.address, style: const pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 8),
                  pw.Text('ICE: ${profile.ice}', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('IF: ${profile.ifNumber}', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text('CNSS: ${profile.cnssNumber}', style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'FACTURE',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: accent),
                ),
                pw.Text('N° ${invoice.number}', style: const pw.TextStyle(fontSize: 11)),
                pw.Text('Date: $issueStr', style: const pw.TextStyle(fontSize: 9)),
                pw.Text('Échéance: $dueStr', style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 24),
        pw.Text('Client', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(invoice.clientName, style: const pw.TextStyle(fontSize: 10)),
        pw.Text(invoice.clientAddress, style: const pw.TextStyle(fontSize: 10)),
        pw.Text('ICE: ${invoice.clientIce}', style: const pw.TextStyle(fontSize: 9)),
        pw.Text('IF: ${invoice.clientIf}', style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 20),
        pw.TableHelper.fromTextArray(
          headers: ['Description', 'Qté', 'P.U.', 'Total'],
          data: [
            ...invoice.items.map(
              (i) => [
                i.description,
                i.quantity.toString(),
                _mad(i.unitPrice),
                _mad(i.lineTotal),
              ],
            ),
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
          cellHeight: 22,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
          },
        ),
        pw.SizedBox(height: 12),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Total: ${_mad(invoice.subtotal)}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
        ),
        if (signatureBytes != null) ...[
          pw.SizedBox(height: 28),
          pw.Text('Signature', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Image(pw.MemoryImage(signatureBytes), width: 160),
        ],
        pw.SizedBox(height: 16),
        pw.Text(
          'TVA non applicable — régime auto-entrepreneur (Maroc).',
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ],
    ),
  );

  // #region agent log
  await agentNdjsonLog(
    hypothesisId: 'D',
    location: 'invoice_pdf.dart:buildInvoicePdfBytes',
    message: 'pre_doc_save',
    data: const {},
  );
  // #endregion
  try {
    final out = await doc.save();
    // #region agent log
    await agentNdjsonLog(
      hypothesisId: 'A',
      location: 'invoice_pdf.dart:buildInvoicePdfBytes',
      message: 'doc_save_ok',
      data: {'byteLength': out.length},
    );
    // #endregion
    return out;
  } catch (e) {
    // #region agent log
    await agentNdjsonLog(
      hypothesisId: 'D',
      location: 'invoice_pdf.dart:buildInvoicePdfBytes',
      message: 'doc_save_failed',
      data: {
        'errorType': e.runtimeType.toString(),
        'error': e.toString(),
      },
    );
    // #endregion
    rethrow;
  }
}
