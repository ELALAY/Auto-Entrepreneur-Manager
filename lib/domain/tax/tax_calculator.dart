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

/// Quarterly IR = revenue × category IR rate.
/// CNSS = Morocco flat quarterly bands when configured, otherwise rate × base (minimum base rule).
TaxComputation computeQuarterlyTax({
  required double totalRevenue,
  required ActivityCategory category,
  required TaxRatesConfig rates,
  bool hasCnss = false,
}) {
  final revenue = totalRevenue < 0 ? 0.0 : totalRevenue;
  final irRaw = revenue * rates.irRateFor(category);

  final double cnssTaxableBase;
  final double cnssRaw;

  if (hasCnss) {
    cnssTaxableBase = revenue;
    cnssRaw = 0.0;
  } else if (rates.usesQuarterlyFlatCnss) {
    cnssTaxableBase = revenue;
    cnssRaw = _cnssFromQuarterBands(revenue, rates.quarterlyCnssBands!);
  } else {
    cnssTaxableBase = revenue < rates.cnssMinimumQuarterlyBaseMad
        ? rates.cnssMinimumQuarterlyBaseMad
        : revenue;
    cnssRaw = _cnssFromLegacyRate(revenue: revenue, rates: rates);
  }

  return TaxComputation(
    totalRevenue: revenue,
    irAmount: roundMoneyMad(irRaw),
    cnssAmount: roundMoneyMad(cnssRaw),
    cnssTaxableBase: cnssTaxableBase,
    ratesVersion: rates.version,
    cnssExempt: hasCnss,
  );
}
