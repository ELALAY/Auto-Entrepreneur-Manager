import 'package:auto_entrepreneur_manager/models/invoice_number_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatInvoiceNumber produces INV_2026_045 style', () {
    const cfg = InvoiceNumberConfig(
      prefix: 'INV',
      pattern: '{prefix}_{year}_{count}',
      countDigits: 3,
    );
    expect(
      formatInvoiceNumber(cfg, year: 2026, count: 45),
      'INV_2026_045',
    );
  });

  test('formatInvoiceNumber uses FA prefix', () {
    const cfg = InvoiceNumberConfig(
      prefix: 'FA',
      pattern: '{prefix}-{year}-{count}',
      countDigits: 4,
    );
    expect(
      formatInvoiceNumber(cfg, year: 2026, count: 7),
      'FA-2026-0007',
    );
  });

  test('normalizeInvoiceNumberConfig fixes invalid pattern', () {
    const broken = InvoiceNumberConfig(prefix: 'X', pattern: 'BAD', countDigits: 99);
    final n = normalizeInvoiceNumberConfig(broken);
    expect(n.pattern, '{prefix}_{year}_{count}');
    expect(n.countDigits, 12);
    expect(
      formatInvoiceNumber(n, year: 2026, count: 1),
      'X_2026_000000000001',
    );
  });

  test('empty prefix defaults to INV in formatted output', () {
    const cfg = InvoiceNumberConfig(prefix: '   ');
    expect(
      formatInvoiceNumber(cfg, year: 2026, count: 1),
      'INV_2026_001',
    );
  });

  test('parseTrailingInvoiceSequence reads final digit group', () {
    expect(parseTrailingInvoiceSequence('INV_2026_016'), 16);
    expect(parseTrailingInvoiceSequence('FA-2026-0007'), 7);
    expect(parseTrailingInvoiceSequence('PROVISOIRE'), isNull);
  });
}
