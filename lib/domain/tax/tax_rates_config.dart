import 'activity_category.dart';

/// Versioned IR/CNSS parameters loaded from Firestore `config/taxRates` — not hardcoded in app logic.
class TaxRatesConfig {
  const TaxRatesConfig({
    required this.version,
    this.effectiveFromIso,
    required this.irRateCommercial,
    required this.irRateArtisanal,
    required this.irRateLiberal,
    required this.cnssRate,
    required this.cnssMinimumQuarterlyBaseMad,
  });

  final int version;
  final String? effectiveFromIso;

  final double irRateCommercial;
  final double irRateArtisanal;
  final double irRateLiberal;

  /// CNSS rate applied to the quarterly base (after plancher).
  final double cnssRate;

  /// Minimum quarterly revenue base (MAD) for CNSS when actual revenue is lower (plancher).
  final double cnssMinimumQuarterlyBaseMad;

  double irRateFor(ActivityCategory category) => switch (category) {
        ActivityCategory.commercial => irRateCommercial,
        ActivityCategory.artisanal => irRateArtisanal,
        ActivityCategory.liberal => irRateLiberal,
      };

  /// Parses Firestore document data. Returns null if required fields are missing or invalid.
  static TaxRatesConfig? fromFirestoreData(Map<String, dynamic>? data) {
    if (data == null) return null;
    final version = (data['version'] as num?)?.toInt();
    if (version == null) return null;

    double? d(String key) => (data[key] as num?)?.toDouble();

    final irC = d('irRateCommercial');
    final irA = d('irRateArtisanal');
    final irL = d('irRateLiberal');
    final cnss = d('cnssRate');
    final base = d('cnssMinimumQuarterlyBaseMad');

    if (irC == null || irA == null || irL == null || cnss == null || base == null) {
      return null;
    }

    return TaxRatesConfig(
      version: version,
      effectiveFromIso: data['effectiveFrom'] as String?,
      irRateCommercial: irC,
      irRateArtisanal: irA,
      irRateLiberal: irL,
      cnssRate: cnss,
      cnssMinimumQuarterlyBaseMad: base,
    );
  }
}
