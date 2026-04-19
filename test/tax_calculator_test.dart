import 'package:auto_entrepreneur_manager/domain/tax/activity_category.dart';
import 'package:auto_entrepreneur_manager/domain/tax/cnss_quarter_bracket.dart';
import 'package:auto_entrepreneur_manager/domain/tax/tax_calculator.dart';
import 'package:auto_entrepreneur_manager/domain/tax/tax_rates_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleRates = TaxRatesConfig(
    version: 42,
    irRateCommercial: 0.005,
    irRateArtisanal: 0.005,
    irRateLiberal: 0.02,
    irRateServices: 0.01,
    cnssRate: 0.0226,
    cnssMinimumQuarterlyBaseMad: 10_000,
  );

  test('IR uses category-specific rate', () {
    final r = 100_000.0;
    final commercial = computeQuarterlyTax(
      totalRevenue: r,
      category: ActivityCategory.commercial,
      rates: sampleRates,
    );
    expect(commercial.irAmount, 500.0);
    final liberal = computeQuarterlyTax(
      totalRevenue: r,
      category: ActivityCategory.liberal,
      rates: sampleRates,
    );
    expect(liberal.irAmount, 2000.0);
  });

  test('CNSS uses plancher when revenue is below minimum base', () {
    final c = computeQuarterlyTax(
      totalRevenue: 2000,
      category: ActivityCategory.commercial,
      rates: sampleRates,
    );
    expect(c.cnssTaxableBase, 10_000.0);
    expect(c.cnssAmount, roundMoneyMad(10_000 * 0.0226));
  });

  test('CNSS uses actual revenue when above plancher', () {
    final c = computeQuarterlyTax(
      totalRevenue: 50_000,
      category: ActivityCategory.artisanal,
      rates: sampleRates,
    );
    expect(c.cnssTaxableBase, 50_000.0);
    expect(c.cnssAmount, roundMoneyMad(50_000 * 0.0226));
  });

  test('TaxRatesConfig.fromFirestoreData returns null when incomplete', () {
    expect(TaxRatesConfig.fromFirestoreData(null), isNull);
    expect(TaxRatesConfig.fromFirestoreData({'version': 1}), isNull);
  });

  test('TaxRatesConfig.fromFirestoreData parses legacy rate document', () {
    final cfg = TaxRatesConfig.fromFirestoreData({
      'version': 7,
      'effectiveFrom': '2026-01-01',
      'irRateCommercial': 0.01,
      'irRateArtisanal': 0.01,
      'irRateLiberal': 0.03,
      'irRateServices': 0.02,
      'cnssRate': 0.05,
      'cnssMinimumQuarterlyBaseMad': 2500.5,
    });
    expect(cfg, isNotNull);
    expect(cfg!.version, 7);
    expect(cfg.irRateFor(ActivityCategory.liberal), 0.03);
    expect(cfg.cnssMinimumQuarterlyBaseMad, 2500.5);
    expect(cfg.usesQuarterlyFlatCnss, isFalse);
  });

  test('TaxRatesConfig.fromFirestoreData parses cnssQuarterBands', () {
    final cfg = TaxRatesConfig.fromFirestoreData({
      'version': 3,
      'irRateCommercial': 0.005,
      'irRateArtisanal': 0.005,
      'irRateLiberal': 0.005,
      'irRateServices': 0.01,
      'cnssQuarterBands': [
        {'maxQuarterlyMad': 2500, 'amountMad': 300},
        {'maxQuarterlyMad': 5000, 'amountMad': 570},
        {'maxQuarterlyMad': null, 'amountMad': 3600},
      ],
    });
    expect(cfg, isNotNull);
    expect(cfg!.usesQuarterlyFlatCnss, isTrue);
    final flat = TaxRatesConfig(
      version: cfg.version,
      irRateCommercial: cfg.irRateCommercial,
      irRateArtisanal: cfg.irRateArtisanal,
      irRateLiberal: cfg.irRateLiberal,
      irRateServices: cfg.irRateServices,
      cnssRate: 0,
      cnssMinimumQuarterlyBaseMad: 0,
      quarterlyCnssBands: [
        const CnssQuarterBracket(maxQuarterlyRevenueMad: 2500, amountMad: 300),
        const CnssQuarterBracket(maxQuarterlyRevenueMad: 5000, amountMad: 570),
        const CnssQuarterBracket(
          maxQuarterlyRevenueMad: double.infinity,
          amountMad: 3600,
        ),
      ],
    );
    final mid = computeQuarterlyTax(
      totalRevenue: 4000,
      category: ActivityCategory.commercial,
      rates: flat,
    );
    expect(mid.cnssAmount, 570);
    final high = computeQuarterlyTax(
      totalRevenue: 9000,
      category: ActivityCategory.commercial,
      rates: flat,
    );
    expect(high.cnssAmount, 3600);
  });

  test('bundledMoroccoDefaults parses and flat CNSS tier', () {
    final cfg = TaxRatesConfig.bundledMoroccoDefaults();
    expect(cfg.usesQuarterlyFlatCnss, isTrue);
    final low = computeQuarterlyTax(
      totalRevenue: 2000,
      category: ActivityCategory.commercial,
      rates: cfg,
    );
    expect(low.cnssAmount, 300);
  });
}
