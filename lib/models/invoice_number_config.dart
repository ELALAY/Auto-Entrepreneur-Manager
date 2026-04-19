/// User-configurable display format for invoice numbers.
///
/// [pattern] may include the placeholders `{prefix}`, `{year}`, and `{count}`.
/// `{count}` is required so every new invoice gets a unique sequence for that year.
class InvoiceNumberConfig {
  const InvoiceNumberConfig({
    this.prefix = 'INV',
    this.pattern = '{prefix}_{year}_{count}',
    this.countDigits = 3,
  });

  final String prefix;
  final String pattern;
  final int countDigits;
}

/// Whether [pattern] is allowed (must contain `{count}` for a per-year sequence).
bool isValidInvoiceNumberPattern(String pattern) {
  return pattern.contains('{count}');
}

/// Ensures a safe pattern and digit width when loading from Firestore or creating invoices.
InvoiceNumberConfig normalizeInvoiceNumberConfig(InvoiceNumberConfig config) {
  final pattern = config.pattern.trim().isEmpty ||
          !isValidInvoiceNumberPattern(config.pattern)
      ? '{prefix}_{year}_{count}'
      : config.pattern.trim();
  return InvoiceNumberConfig(
    prefix: config.prefix,
    pattern: pattern,
    countDigits: config.countDigits.clamp(1, 12),
  );
}

/// Builds the final invoice number for storage and PDFs.
String formatInvoiceNumber(
  InvoiceNumberConfig config, {
  required int year,
  required int count,
}) {
  final rawPrefix = config.prefix.trim();
  final prefix = rawPrefix.isEmpty ? 'INV' : rawPrefix;
  final digits = config.countDigits.clamp(1, 12);
  final countStr = count.toString().padLeft(digits, '0');
  var p = config.pattern.trim();
  if (p.isEmpty) {
    p = '{prefix}_{year}_{count}';
  }
  return p
      .replaceAll('{prefix}', prefix)
      .replaceAll('{year}', year.toString())
      .replaceAll('{count}', countStr);
}
