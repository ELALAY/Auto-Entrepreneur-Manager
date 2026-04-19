import 'activity_category.dart';
import 'cnss_quarter_bracket.dart';

/// Versioned IR/CNSS parameters loaded from Firestore `config/taxRates`.
class TaxRatesConfig {
  const TaxRatesConfig({
    required this.version,
    this.effectiveFromIso,
    required this.irRateCommercial,
    required this.irRateArtisanal,
    required this.irRateLiberal,
    required this.irRateServices,
    required this.cnssRate,
    required this.cnssMinimumQuarterlyBaseMad,
    this.quarterlyCnssBands,
  });

  final int version;
  final String? effectiveFromIso;

  final double irRateCommercial;
  final double irRateArtisanal;
  final double irRateLiberal;
  final double irRateServices;

  /// Legacy model: CNSS ≈ taxable base × rate with a minimum quarterly base (plancher).
  final double cnssRate;
  final double cnssMinimumQuarterlyBaseMad;

  /// Morocco AE flat quarterly CNSS by revenue band — when non-empty, replaces [cnssRate] math.
  final List<CnssQuarterBracket>? quarterlyCnssBands;

  bool get usesQuarterlyFlatCnss =>
      quarterlyCnssBands != null && quarterlyCnssBands!.isNotEmpty;

  double irRateFor(ActivityCategory category) => switch (category) {
        ActivityCategory.commercial => irRateCommercial,
        ActivityCategory.artisanal => irRateArtisanal,
        ActivityCategory.liberal => irRateLiberal,
        ActivityCategory.services => irRateServices,
      };

  /// Bundled defaults (matches [config/taxRates.firestore.json]) when Firestore has no doc yet.
  static TaxRatesConfig bundledMoroccoDefaults() {
    final parsed = fromFirestoreData(_bundledMoroccoMap);
    assert(parsed != null, 'bundledMoroccoDefaults map must parse');
    return parsed!;
  }

  static final Map<String, dynamic> _bundledMoroccoMap = {
    'version': 3,
    'effectiveFrom': '2026-01-01',
    'irRateCommercial': 0.005,
    'irRateArtisanal': 0.005,
    'irRateLiberal': 0.005,
    'irRateServices': 0.01,
    'cnssQuarterBands': [
      {'maxQuarterlyMad': 2500, 'amountMad': 300},
      {'maxQuarterlyMad': 5000, 'amountMad': 570},
      {'maxQuarterlyMad': 10000, 'amountMad': 720},
      {'maxQuarterlyMad': 25000, 'amountMad': 1050},
      {'maxQuarterlyMad': 50000, 'amountMad': 2250},
      {'maxQuarterlyMad': null, 'amountMad': 3600},
    ],
  };

  /// Parses Firestore document data. Returns null only when IR rates are unusable.
  static TaxRatesConfig? fromFirestoreData(Map<String, dynamic>? data) {
    if (data == null) return null;
    final version = (data['version'] as num?)?.toInt();
    if (version == null) return null;

    double? d(String key) => (data[key] as num?)?.toDouble();

    final irC = d('irRateCommercial');
    final irA = d('irRateArtisanal');
    final irL = d('irRateLiberal');
    final irS = d('irRateServices');
    if (irC == null || irA == null || irL == null || irS == null) {
      return null;
    }

    final bands = parseQuarterBandsFromFirestore(data['cnssQuarterBands']);
    final cnssRate = d('cnssRate');
    final cnssMinBase = d('cnssMinimumQuarterlyBaseMad');

    final hasLegacy = cnssRate != null && cnssMinBase != null;
    final hasBands = bands != null && bands.isNotEmpty;

    if (!hasBands && !hasLegacy) return null;

    final effectiveBands = bands;
    final effectiveRate = cnssRate ?? (hasBands ? 0.0 : null);
    final effectiveMinBase = cnssMinBase ?? (hasBands ? 0.0 : null);
    if (effectiveRate == null || effectiveMinBase == null) return null;

    return TaxRatesConfig(
      version: version,
      effectiveFromIso: data['effectiveFrom'] as String?,
      irRateCommercial: irC,
      irRateArtisanal: irA,
      irRateLiberal: irL,
      irRateServices: irS,
      cnssRate: effectiveRate,
      cnssMinimumQuarterlyBaseMad: effectiveMinBase,
      quarterlyCnssBands: effectiveBands,
    );
  }

  static List<CnssQuarterBracket>? parseQuarterBandsFromFirestore(dynamic raw) {
    if (raw is! List || raw.isEmpty) return null;
    final list = <CnssQuarterBracket>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final amount = (e['amountMad'] as num?)?.toDouble();
      if (amount == null) continue;
      final maxRaw = e['maxQuarterlyMad'];
      final maxMad = maxRaw == null
          ? double.infinity
          : (maxRaw as num).toDouble();
      list.add(
        CnssQuarterBracket(
          maxQuarterlyRevenueMad: maxMad,
          amountMad: amount,
        ),
      );
    }
    if (list.isEmpty) return null;
    list.sort(
      (a, b) => _sortKey(a).compareTo(_sortKey(b)),
    );
    return list;
  }

  static double _sortKey(CnssQuarterBracket b) =>
      b.maxQuarterlyRevenueMad.isFinite ? b.maxQuarterlyRevenueMad : double.maxFinite;
}
