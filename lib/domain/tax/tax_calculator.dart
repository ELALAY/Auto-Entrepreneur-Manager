import 'activity_category.dart';
import 'tax_rates_config.dart';

/// Result of applying [TaxRatesConfig] to quarterly revenue (pure logic — no I/O).
class TaxComputation {
  const TaxComputation({
    required this.totalRevenue,
    required this.irAmount,
    required this.cnssAmount,
    required this.ratesVersion,
    required this.cnssExempt,
  });

  final double totalRevenue;
  final double irAmount;

  /// Flat bracket amount — 0.0 when [cnssExempt] is true.
  final double cnssAmount;

  final int ratesVersion;

  /// True when the user already contributes to CNSS through another scheme.
  final bool cnssExempt;
}

/// Rounds to two decimal places (MAD).
double roundMoneyMad(double value) => (value * 100).roundToDouble() / 100;

/// Quarterly IR = revenue × category IR rate.
/// CNSS = flat bracket amount from [rates.cnssBrackets], or 0 when [hasCnss] is true.
TaxComputation computeQuarterlyTax({
  required double totalRevenue,
  required ActivityCategory category,
  required TaxRatesConfig rates,
  bool hasCnss = false,
}) {
  final revenue = totalRevenue < 0 ? 0.0 : totalRevenue;
  final irRaw = revenue * rates.irRateFor(category);
  final cnssRaw = hasCnss ? 0.0 : rates.cnssBrackets.amountFor(revenue);

  return TaxComputation(
    totalRevenue: revenue,
    irAmount: roundMoneyMad(irRaw),
    cnssAmount: roundMoneyMad(cnssRaw),
    ratesVersion: rates.version,
    cnssExempt: hasCnss,
  );
}
