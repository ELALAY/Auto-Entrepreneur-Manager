import 'activity_category.dart';
import 'tax_rates_config.dart';

/// Result of applying [TaxRatesConfig] to quarterly revenue (pure logic — no I/O).
class TaxComputation {
  const TaxComputation({
    required this.totalRevenue,
    required this.irAmount,
    required this.cnssAmount,
    required this.ratesVersion,
    required this.cnssTaxableBase,
  });

  final double totalRevenue;
  final double irAmount;
  final double cnssAmount;
  final int ratesVersion;

  /// Revenue after applying CNSS minimum base (plancher): max(revenue, minimum).
  final double cnssTaxableBase;
}

/// Rounds to two decimal places (MAD).
double roundMoneyMad(double value) => (value * 100).roundToDouble() / 100;

/// Quarterly IR = revenue × category IR rate.
/// CNSS = max(revenue, plancher) × CNSS rate.
TaxComputation computeQuarterlyTax({
  required double totalRevenue,
  required ActivityCategory category,
  required TaxRatesConfig rates,
}) {
  final revenue = totalRevenue < 0 ? 0.0 : totalRevenue;
  final irRaw = revenue * rates.irRateFor(category);
  final cnssBase = revenue < rates.cnssMinimumQuarterlyBaseMad
      ? rates.cnssMinimumQuarterlyBaseMad
      : revenue;
  final cnssRaw = cnssBase * rates.cnssRate;

  return TaxComputation(
    totalRevenue: revenue,
    irAmount: roundMoneyMad(irRaw),
    cnssAmount: roundMoneyMad(cnssRaw),
    ratesVersion: rates.version,
    cnssTaxableBase: cnssBase,
  );
}
