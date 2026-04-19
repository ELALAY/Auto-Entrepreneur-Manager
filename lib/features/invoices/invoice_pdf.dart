import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/invoice.dart';
import '../../models/user_profile.dart';

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

String _dhs(num value) =>
    '${NumberFormat('#,##0.00', 'fr_FR').format(value)} Dhs';

const _fontRegularAsset = 'assets/fonts/OpenSans-Regular.ttf';
const _fontBoldAsset = 'assets/fonts/OpenSans-Bold.ttf';
const _defaultLogoAsset = 'assets/images/ae.png';

Future<List<pw.Font>> _loadFonts() async {
  try {
    return [
      pw.Font.ttf(await rootBundle.load(_fontRegularAsset)),
      pw.Font.ttf(await rootBundle.load(_fontBoldAsset)),
    ];
  } catch (_) {
    return [
      await PdfGoogleFonts.openSansRegular(),
      await PdfGoogleFonts.openSansBold(),
    ];
  }
}

/// Builds the invoice PDF bytes.
/// Pass [fontBase]/[fontBold] in tests to avoid loading assets.
Future<Uint8List> buildInvoicePdfBytes({
  required Invoice invoice,
  required UserProfile profile,
  pw.Font? fontBase,
  pw.Font? fontBold,
}) async {
  await _ensureFrenchLocaleData();

  final pw.Font base;
  final pw.Font bold;
  if (fontBase != null && fontBold != null) {
    base = fontBase;
    bold = fontBold;
  } else {
    final loaded = await _loadFonts();
    base = loaded[0];
    bold = loaded[1];
  }

  // Logo: user's uploaded logo → fallback to bundled ae.png
  Uint8List? logoBytes = await _loadUrlBytes(profile.logoUrl);
  if (logoBytes == null) {
    try {
      final data = await rootBundle.load(_defaultLogoAsset);
      logoBytes = data.buffer.asUint8List();
    } catch (_) {}
  }

  final signatureBytes =
      invoice.signatureEnabled ? await _loadUrlBytes(profile.signatureUrl) : null;

  final accentArgb = profile.branding.accentColorArgb ?? 0xFF00695C;
  final accent = PdfColor.fromInt(accentArgb);

  final dateStr = DateFormat('yyyy-MM-dd').format(invoice.issueDate);

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: base, bold: bold),
  );

  // ── Footer (seller info) ───────────────────────────────────────────────────
  pw.Widget _footer(pw.Context ctx) {
    const small = pw.TextStyle(fontSize: 7.5);
    final smallBold = pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold);
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Divider(thickness: 0.5, color: PdfColors.grey600),
        pw.SizedBox(height: 4),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Auto Entrepreneur : ${profile.name}', style: smallBold),
                  pw.Text('Numéro d\'identification fiscale : ${profile.ifNumber}', style: small),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Adresse : ${profile.address}', style: small),
                  pw.Text('Numéro Taxe professionnelle : ${profile.taxProfessionnelle}', style: small),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Téléphone : ${profile.phone}', style: small),
                  pw.Text('CNIE : ${profile.cin}', style: small),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 3),
        pw.Center(
          child: pw.Text(
            'ICE (N° d\'inscription au registre national de l\'auto-entrepreneur) : ${profile.ice}',
            style: small,
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    );
  }

  doc.addPage(
    pw.MultiPage(
      pageTheme: const pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.fromLTRB(40, 40, 40, 75),
      ),
      footer: _footer,
      build: (ctx) => [
        // ── Header: logo left | FACTURE box right ─────────────────────────
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logoBytes != null)
              pw.Image(
                pw.MemoryImage(logoBytes),
                width: 100,
                height: 100,
                fit: pw.BoxFit.contain,
              )
            else
              pw.SizedBox(width: 100, height: 100),
            pw.Spacer(),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  decoration: const pw.BoxDecoration(color: PdfColors.black),
                  child: pw.Text(
                    'FACTURE',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text('Le $dateStr', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 24),

        // ── Invoice number (centered) ──────────────────────────────────────
        pw.Center(
          child: pw.Text(
            'FACTURE N° : ${invoice.number}',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 28),

        // ── Client block ──────────────────────────────────────────────────
        pw.Text(
          invoice.clientName,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.RichText(
          text: pw.TextSpan(children: [
            pw.TextSpan(
              text: 'Adresse : ',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(
              text: invoice.clientAddress,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ]),
        ),
        if (invoice.clientIce.isNotEmpty)
          pw.RichText(
            text: pw.TextSpan(children: [
              pw.TextSpan(
                text: 'Ice : ',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(
                text: invoice.clientIce,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ]),
          ),
        if (invoice.clientIf.isNotEmpty)
          pw.RichText(
            text: pw.TextSpan(children: [
              pw.TextSpan(
                text: 'IF : ',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(
                text: invoice.clientIf,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ]),
          ),
        pw.SizedBox(height: 28),

        // ── Line items table ───────────────────────────────────────────────
        pw.TableHelper.fromTextArray(
          headers: ['Désignation', 'Quantité', 'Prix', 'Total'],
          data: invoice.items
              .map((i) => [
                    i.description,
                    i.quantity.toString(),
                    _dhs(i.unitPrice),
                    _dhs(i.lineTotal),
                  ])
              .toList(),
          headerStyle: pw.TextStyle(
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
          ),
          headerDecoration: pw.BoxDecoration(color: accent),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellHeight: 24,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
          },
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        ),
        pw.SizedBox(height: 6),

        // ── VAT exemption note ────────────────────────────────────────────
        pw.Text(
          'Montant en dirhams exonéré de la TVA ( Art 91 - || - 1° du Code Général Des Impôts )',
          style: pw.TextStyle(
            fontSize: 7.5,
            color: accent,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
        pw.SizedBox(height: 16),

        // ── Totals (right-aligned) ────────────────────────────────────────
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.SizedBox(
            width: 230,
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL H.T :',
                      style: pw.TextStyle(
                          fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      _dhs(invoice.subtotal),
                      style: pw.TextStyle(
                          fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Divider(thickness: 0.5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL T.T.C :',
                      style: pw.TextStyle(
                          fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      _dhs(invoice.subtotal),
                      style: pw.TextStyle(
                          fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Signature ─────────────────────────────────────────────────────
        if (signatureBytes != null) ...[
          pw.SizedBox(height: 40),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Signature',
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Image(pw.MemoryImage(signatureBytes), width: 140),
              ],
            ),
          ),
        ],
      ],
    ),
  );

  return await doc.save();
}
