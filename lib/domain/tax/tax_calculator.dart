import 'activity_category.dart';
import 'tax_rates_config.dart';

/// Result of applying [TaxRatesConfig] to quarterly revenue (pure logic — no I/O).
class TaxComputation {
  const TaxComputation({
    required this.totalRevenue,
    required this.irAmount,
    required this.cnssAmount,
    required this.cnssTaxableBase,
    required this.ratesVersion,
    required this.cnssExempt,
  });

  final double totalRevenue;
  final double irAmount;

  /// Flat bracket amount — 0.0 when [cnssExempt] is true.
  final double cnssAmount;

  /// Quarterly IR (MAD) used to select the CNSS bracket.
  final double cnssTaxableBase;

  final int ratesVersion;

  /// True when the user already contributes to CNSS through another scheme.
  final bool cnssExempt;
}

/// Rounds to two decimal places (MAD).
double roundMoneyMad(double value) => (value * 100).roundToDouble() / 100;

/// IR only: sum over activities of (cash revenue × IR rate for that activity).
/// Morocco mixed-activity AE: validate against official guidance.
double computeQuarterlyIrFromActivityRevenues(
  Map<ActivityCategory, double> revenueByCategory,
  TaxRatesConfig rates,
) {
  var ir = 0.0;
  revenueByCategory.forEach((cat, rev) {
    final r = rev < 0 ? 0.0 : rev;
    ir += r * rates.irRateFor(cat);
  });
  return roundMoneyMad(ir);
}

/// CNSS is the flat amount for the quarter's total IR, not a cut of turnover.
/// Each quarter is classified on its own IR (equivalent to annualizing that IR,
/// because the official annual caps are exactly four times these thresholds).
(double cnssAmount, double cnssTaxableBase) _computeCnssFromQuarterlyIr({
  required double quarterlyIr,
  required TaxRatesConfig rates,
  required bool hasCnss,
}) {
  final ir = quarterlyIr < 0 ? 0.0 : quarterlyIr;
  if (hasCnss) {
    return (0.0, ir);
  }
  return (
    roundMoneyMad(rates.cnssBrackets.amountForQuarterlyIr(ir)),
    ir,
  );
}

/// Quarterly declaration: IR is summed per activity; CNSS follows that total IR.
TaxComputation computeQuarterlyTaxFromActivityRevenues({
  required Map<ActivityCategory, double> revenueByCategory,
  required double totalRevenue,
  required TaxRatesConfig rates,
  bool hasCnss = false,
}) {
  final revenueTotal = totalRevenue < 0 ? 0.0 : totalRevenue;
  final irAmount = computeQuarterlyIrFromActivityRevenues(
    revenueByCategory,
    rates,
  );
  final (cnssRaw, cnssTaxableBase) = _computeCnssFromQuarterlyIr(
    quarterlyIr: irAmount,
    rates: rates,
    hasCnss: hasCnss,
  );
  return TaxComputation(
    totalRevenue: revenueTotal,
    irAmount: irAmount,
    cnssAmount: cnssRaw,
    cnssTaxableBase: cnssTaxableBase,
    ratesVersion: rates.version,
    cnssExempt: hasCnss,
  );
}

/// Quarterly IR = revenue × category IR rate.
/// CNSS = flat amount for that quarterly IR (0 when [hasCnss] is true).
TaxComputation computeQuarterlyTax({
  required double totalRevenue,
  required ActivityCategory category,
  required TaxRatesConfig rates,
  bool hasCnss = false,
}) {
  final revenue = totalRevenue < 0 ? 0.0 : totalRevenue;
  return computeQuarterlyTaxFromActivityRevenues(
    revenueByCategory: {category: revenue},
    totalRevenue: revenue,
    rates: rates,
    hasCnss: hasCnss,
  );
}
