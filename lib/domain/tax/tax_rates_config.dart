import 'activity_category.dart';

/// Fixed-amount CNSS brackets loaded from Firestore `config/taxRates`.
/// Each bracket maps a quarterly revenue range to a flat CNSS amount (MAD).
class CnssBrackets {
  const CnssBrackets({
    required this.nil,
    required this.to2500,
    required this.to5000,
    required this.to10000,
    required this.to25000,
    required this.to50000,
    required this.above50000,
  });

  final double nil;         // Revenue = 0 DH
  final double to2500;      // 1 – 2,500 DH
  final double to5000;      // 2,501 – 5,000 DH
  final double to10000;     // 5,001 – 10,000 DH
  final double to25000;     // 10,001 – 25,000 DH
  final double to50000;     // 25,001 – 50,000 DH
  final double above50000;  // > 50,000 DH

  double amountFor(double quarterlyRevenue) {
    if (quarterlyRevenue <= 0) return nil;
    if (quarterlyRevenue <= 2500) return to2500;
    if (quarterlyRevenue <= 5000) return to5000;
    if (quarterlyRevenue <= 10000) return to10000;
    if (quarterlyRevenue <= 25000) return to25000;
    if (quarterlyRevenue <= 50000) return to50000;
    return above50000;
  }
}

/// Versioned IR/CNSS parameters loaded from Firestore `config/taxRates`.
class TaxRatesConfig {
  const TaxRatesConfig({
    required this.version,
    this.effectiveFromIso,
    required this.irRateCommercial,
    required this.irRateArtisanal,
    required this.irRateLiberal,
    required this.irRateServices,
    required this.cnssBrackets,
  });

  final int version;
  final String? effectiveFromIso;

  final double irRateCommercial;
  final double irRateArtisanal;
  final double irRateLiberal;
  final double irRateServices;

  final CnssBrackets cnssBrackets;

  double irRateFor(ActivityCategory category) => switch (category) {
        ActivityCategory.commercial => irRateCommercial,
        ActivityCategory.artisanal => irRateArtisanal,
        ActivityCategory.liberal => irRateLiberal,
        ActivityCategory.services => irRateServices,
      };

  /// Parses Firestore document data. Returns null if required fields are missing.
  static TaxRatesConfig? fromFirestoreData(Map<String, dynamic>? data) {
    if (data == null) return null;
    final version = (data['version'] as num?)?.toInt();
    if (version == null) return null;

    double? d(String key) => (data[key] as num?)?.toDouble();

    final irC = d('irRateCommercial');
    final irA = d('irRateArtisanal');
    final irL = d('irRateLiberal');
    final irS = d('irRateServices');
    final cnssNil = d('cnssNil');
    final to2500 = d('cnssTo2500');
    final to5000 = d('cnssTo5000');
    final to10000 = d('cnssTo10000');
    final to25000 = d('cnssTo25000');
    final to50000 = d('cnssTo50000');
    final above = d('cnssAbove50000');

    if (irC == null || irA == null || irL == null || irS == null ||
        cnssNil == null || to2500 == null || to5000 == null ||
        to10000 == null || to25000 == null || to50000 == null || above == null) {
      return null;
    }

    return TaxRatesConfig(
      version: version,
      effectiveFromIso: data['effectiveFrom'] as String?,
      irRateCommercial: irC,
      irRateArtisanal: irA,
      irRateLiberal: irL,
      irRateServices: irS,
      cnssBrackets: CnssBrackets(
        nil: cnssNil,
        to2500: to2500,
        to5000: to5000,
        to10000: to10000,
        to25000: to25000,
        to50000: to50000,
        above50000: above,
      ),
    );
  }
}
