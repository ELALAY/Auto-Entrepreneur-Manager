import 'package:auto_entrepreneur_manager/domain/tax/activity_category.dart';
import 'package:auto_entrepreneur_manager/domain/tax/tax_calculator.dart';
import 'package:auto_entrepreneur_manager/domain/tax/tax_rates_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('computeQuarterlyIrFromActivityRevenues sums per-activity IR', () {
    const rates = TaxRatesConfig(
      version: 1,
      irRateCommercial: 0.1,
      irRateArtisanal: 0.1,
      irRateLiberal: 0.2,
      irRateServices: 0.3,
      cnssRate: 0.04,
      cnssMinimumQuarterlyBaseMad: 0,
    );
    final ir = computeQuarterlyIrFromActivityRevenues(
      {
        ActivityCategory.commercial: 1000,
        ActivityCategory.services: 500,
      },
      rates,
    );
    expect(ir, 1000 * 0.1 + 500 * 0.3);
  });

  test('computeQuarterlyTaxFromActivityRevenues uses total for CNSS basis', () {
    const rates = TaxRatesConfig(
      version: 1,
      irRateCommercial: 0.1,
      irRateArtisanal: 0.1,
      irRateLiberal: 0.1,
      irRateServices: 0.1,
      cnssRate: 0.04,
      cnssMinimumQuarterlyBaseMad: 0,
    );
    final t = computeQuarterlyTaxFromActivityRevenues(
      revenueByCategory: {ActivityCategory.commercial: 1000},
      totalRevenueForCnss: 1000,
      rates: rates,
      hasCnss: true,
    );
    expect(t.totalRevenue, 1000);
    expect(t.irAmount, 100.0);
    expect(t.cnssAmount, 0.0);
  });
}
