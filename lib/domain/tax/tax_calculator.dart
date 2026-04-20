import 'activity_category.dart';
import 'cnss_quarter_bracket.dart';
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

  /// Basis used for CNSS message (matches revenue for flat brackets; plancher logic for legacy).
  final double cnssTaxableBase;

  final int ratesVersion;

  /// True when the user already contributes to CNSS through another scheme.
  final bool cnssExempt;
}

/// Rounds to two decimal places (MAD).
double roundMoneyMad(double value) => (value * 100).roundToDouble() / 100;

double _cnssFromLegacyRate({
  required double revenue,
  required TaxRatesConfig rates,
}) {
  final taxable = revenue < rates.cnssMinimumQuarterlyBaseMad
      ? rates.cnssMinimumQuarterlyBaseMad
      : revenue;
  return taxable * rates.cnssRate;
}

double _cnssFromQuarterBands(double revenue, List<CnssQuarterBracket> bands) {
  for (final b in bands) {
    if (revenue <= b.maxQuarterlyRevenueMad) {
      return b.amountMad;
    }
  }
  return bands.last.amountMad;
}

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

/// CNSS on **total** quarterly cash revenue (unchanged when activities are mixed).
/// Official rules for multi-activity CNSS should be validated separately.
(double cnssAmount, double cnssTaxableBase) _computeCnssForTotalRevenue({
  required double revenue,
  required TaxRatesConfig rates,
  required bool hasCnss,
}) {
  final rev = revenue < 0 ? 0.0 : revenue;
  if (hasCnss) {
    return (0.0, rev);
  }
  if (rates.usesQuarterlyFlatCnss) {
    return (
      roundMoneyMad(_cnssFromQuarterBands(rev, rates.quarterlyCnssBands!)),
      rev,
    );
  }
  final taxableBase = rev < rates.cnssMinimumQuarterlyBaseMad
      ? rates.cnssMinimumQuarterlyBaseMad
      : rev;
  return (
    roundMoneyMad(_cnssFromLegacyRate(revenue: rev, rates: rates)),
    taxableBase,
  );
}

/// Quarterly declaration when revenue is split by activity (IR) but CNSS uses [totalRevenueForCnss].
TaxComputation computeQuarterlyTaxFromActivityRevenues({
  required Map<ActivityCategory, double> revenueByCategory,
  required double totalRevenueForCnss,
  required TaxRatesConfig rates,
  bool hasCnss = false,
}) {
  final revenueTotal = totalRevenueForCnss < 0 ? 0.0 : totalRevenueForCnss;
  final irAmount = computeQuarterlyIrFromActivityRevenues(
    revenueByCategory,
    rates,
  );
  final (cnssRaw, cnssTaxableBase) = _computeCnssForTotalRevenue(
    revenue: revenueTotal,
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
/// CNSS = Morocco flat quarterly bands when configured, otherwise rate × base (minimum base rule).
TaxComputation computeQuarterlyTax({
  required double totalRevenue,
  required ActivityCategory category,
  required TaxRatesConfig rates,
  bool hasCnss = false,
}) {
  return computeQuarterlyTaxFromActivityRevenues(
    revenueByCategory: {category: totalRevenue < 0 ? 0.0 : totalRevenue},
    totalRevenueForCnss: totalRevenue,
    rates: rates,
    hasCnss: hasCnss,
  );
}
