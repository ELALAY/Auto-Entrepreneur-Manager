import 'package:auto_entrepreneur_manager/domain/tax/activity_category.dart';
import 'package:auto_entrepreneur_manager/domain/tax/tax_calculator.dart';
import 'package:auto_entrepreneur_manager/domain/tax/tax_rates_config.dart';
import 'package:flutter_test/flutter_test.dart';

TaxRatesConfig _rates() => TaxRatesConfig.bundledMoroccoDefaults();

void main() {
  test('computeQuarterlyIrFromActivityRevenues sums per-activity IR', () {
    final rates = _rates();
    final ir = computeQuarterlyIrFromActivityRevenues(
      {
        ActivityCategory.commercial: 1000,
        ActivityCategory.services: 500,
      },
      rates,
    );
    expect(ir, roundMoneyMad(1000 * 0.005 + 500 * 0.01));
  });

  test('CNSS follows quarterly IR, so the same turnover can differ by activity', () {
    final rates = _rates();
    final commercial = computeQuarterlyTax(
      totalRevenue: 30000,
      category: ActivityCategory.commercial,
      rates: rates,
    );
    final services = computeQuarterlyTax(
      totalRevenue: 30000,
      category: ActivityCategory.services,
      rates: rates,
    );

    expect(commercial.irAmount, 150);
    expect(commercial.cnssAmount, 390);
    expect(commercial.cnssTaxableBase, 150);

    expect(services.irAmount, 300);
    expect(services.cnssAmount, 570);
  });

  test('10,000 MAD commercial revenue is IR 50 and CNSS 300', () {
    final t = computeQuarterlyTax(
      totalRevenue: 10000,
      category: ActivityCategory.commercial,
      rates: _rates(),
    );
    expect(t.irAmount, 50);
    expect(t.cnssAmount, 300);
  });

  test('zero revenue still owes the minimum CNSS bracket', () {
    final t = computeQuarterlyTax(
      totalRevenue: 0,
      category: ActivityCategory.services,
      rates: _rates(),
    );
    expect(t.irAmount, 0);
    expect(t.cnssAmount, 300);
  });

  test('IR band edges are inclusive on the upper bound', () {
    final rates = _rates();
    expect(rates.cnssBrackets.amountForQuarterlyIr(125), 300);
    expect(rates.cnssBrackets.amountForQuarterlyIr(125.01), 390);
    expect(rates.cnssBrackets.amountForQuarterlyIr(12500), 2250);
    expect(rates.cnssBrackets.amountForQuarterlyIr(12500.01), 3600);
  });

  test('computeQuarterlyTaxFromActivityRevenues uses total IR for CNSS', () {
    final t = computeQuarterlyTaxFromActivityRevenues(
      revenueByCategory: {
        ActivityCategory.commercial: 10000,
        ActivityCategory.services: 20000,
      },
      totalRevenue: 30000,
      rates: _rates(),
    );
    expect(t.totalRevenue, 30000);
    expect(t.irAmount, roundMoneyMad(10000 * 0.005 + 20000 * 0.01));
    expect(t.cnssTaxableBase, 250);
    expect(t.cnssAmount, 390);
  });

  test('an existing CNSS affiliation zeroes the contribution', () {
    final t = computeQuarterlyTaxFromActivityRevenues(
      revenueByCategory: {ActivityCategory.services: 200000},
      totalRevenue: 200000,
      rates: _rates(),
      hasCnss: true,
    );
    expect(t.irAmount, 2000);
    expect(t.cnssAmount, 0);
    expect(t.cnssExempt, isTrue);
    expect(t.cnssTaxableBase, 2000);
  });

  test('fromFirestoreData reads IR bands and rejects revenue-cap documents', () {
    final parsed = TaxRatesConfig.fromFirestoreData({
      'version': 4,
      'irRateCommercial': 0.005,
      'irRateArtisanal': 0.005,
      'irRateLiberal': 0.005,
      'irRateServices': 0.01,
      'cnssIrBands': [
        {'maxQuarterlyIrMad': 250, 'amountMad': 390},
        {'maxQuarterlyIrMad': 125, 'amountMad': 300},
        {'maxQuarterlyIrMad': null, 'amountMad': 3600},
      ],
    });
    expect(parsed, isNotNull);
    expect(parsed!.cnssBrackets.amountForQuarterlyIr(100), 300);
    expect(parsed.cnssBrackets.amountForQuarterlyIr(200), 390);
    expect(parsed.cnssBrackets.amountForQuarterlyIr(10000), 3600);

    expect(
      TaxRatesConfig.fromFirestoreData({
        'version': 3,
        'irRateCommercial': 0.005,
        'irRateArtisanal': 0.005,
        'irRateLiberal': 0.005,
        'irRateServices': 0.01,
        'cnssNil': 300,
        'cnssTo2500': 570,
        'cnssTo5000': 720,
        'cnssTo10000': 1050,
        'cnssTo25000': 1500,
        'cnssTo50000': 2250,
        'cnssAbove50000': 3600,
      }),
      isNull,
    );
  });
}
