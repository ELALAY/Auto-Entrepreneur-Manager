import 'activity_category.dart';

/// One flat CNSS amount for a quarterly income-tax (IR) band.
///
/// Moroccan auto-entrepreneur CNSS is not a percentage of turnover. The
/// quarter's IR selects the band: the first row whose [maxQuarterlyIrMad]
/// is greater than or equal to that IR. The last row uses [double.infinity].
class CnssIrBracket {
  const CnssIrBracket({
    required this.maxQuarterlyIrMad,
    required this.amountMad,
  });

  /// Inclusive upper bound on quarterly IR (MAD).
  final double maxQuarterlyIrMad;

  /// Quarterly CNSS due (MAD) when IR falls in this band.
  final double amountMad;
}

/// Fixed-amount CNSS brackets loaded from Firestore `config/taxRates`.
///
/// Bands are keyed by quarterly IR, not by quarterly revenue.
/// Official scale (quarterly IR → CNSS): 125→300, 250→390, 625→570,
/// 1250→720, 2500→1050, 6250→1500, 12500→2250, above→3600.
class CnssBrackets {
  const CnssBrackets(this.bands);

  final List<CnssIrBracket> bands;

  /// Droit complémentaire from the CGI / rn.ae.gov.ma quarterly IR scale.
  static const moroccoAeDefaults = CnssBrackets([
    CnssIrBracket(maxQuarterlyIrMad: 125, amountMad: 300),
    CnssIrBracket(maxQuarterlyIrMad: 250, amountMad: 390),
    CnssIrBracket(maxQuarterlyIrMad: 625, amountMad: 570),
    CnssIrBracket(maxQuarterlyIrMad: 1250, amountMad: 720),
    CnssIrBracket(maxQuarterlyIrMad: 2500, amountMad: 1050),
    CnssIrBracket(maxQuarterlyIrMad: 6250, amountMad: 1500),
    CnssIrBracket(maxQuarterlyIrMad: 12500, amountMad: 2250),
    CnssIrBracket(maxQuarterlyIrMad: double.infinity, amountMad: 3600),
  ]);

  /// Flat CNSS for [quarterlyIrMad]. An empty band list yields 0.
  double amountForQuarterlyIr(double quarterlyIrMad) {
    if (bands.isEmpty) return 0;
    final ir = quarterlyIrMad < 0 ? 0.0 : quarterlyIrMad;
    for (final band in bands) {
      if (ir <= band.maxQuarterlyIrMad) return band.amountMad;
    }
    return bands.last.amountMad;
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

  /// Rates used when `config/taxRates` is missing or not the IR-band schema.
  ///
  /// IR: 0.5% commerce / artisanat / liberal, 1% services.
  /// CNSS: official quarterly-IR brackets (see [CnssBrackets.moroccoAeDefaults]).
  static TaxRatesConfig bundledMoroccoDefaults() => const TaxRatesConfig(
        version: 4,
        effectiveFromIso: '2026-01-01',
        irRateCommercial: 0.005,
        irRateArtisanal: 0.005,
        irRateLiberal: 0.005,
        irRateServices: 0.01,
        cnssBrackets: CnssBrackets.moroccoAeDefaults,
      );

  /// Parses Firestore document data. Returns null if required fields are missing.
  ///
  /// CNSS must be `cnssIrBands`: a list of `{maxQuarterlyIrMad, amountMad}`.
  /// A null `maxQuarterlyIrMad` is the open top band. Documents that still
  /// store revenue caps (`cnssNil`, `cnssTo2500`, …) are rejected so the app
  /// falls back to [bundledMoroccoDefaults].
  static TaxRatesConfig? fromFirestoreData(Map<String, dynamic>? data) {
    if (data == null) return null;
    final version = (data['version'] as num?)?.toInt();
    if (version == null) return null;

    double? d(String key) => (data[key] as num?)?.toDouble();

    final irC = d('irRateCommercial');
    final irA = d('irRateArtisanal');
    final irL = d('irRateLiberal');
    final irS = d('irRateServices');
    final bands = _parseCnssIrBands(data['cnssIrBands']);

    if (irC == null || irA == null || irL == null || irS == null || bands == null) {
      return null;
    }

    return TaxRatesConfig(
      version: version,
      effectiveFromIso: data['effectiveFrom'] as String?,
      irRateCommercial: irC,
      irRateArtisanal: irA,
      irRateLiberal: irL,
      irRateServices: irS,
      cnssBrackets: CnssBrackets(bands),
    );
  }

  static List<CnssIrBracket>? _parseCnssIrBands(Object? raw) {
    if (raw is! List || raw.isEmpty) return null;
    final bands = <CnssIrBracket>[];
    for (final item in raw) {
      if (item is! Map) return null;
      final amount = (item['amountMad'] as num?)?.toDouble();
      if (amount == null) return null;
      final maxRaw = item['maxQuarterlyIrMad'];
      final double max;
      if (maxRaw == null) {
        max = double.infinity;
      } else if (maxRaw is num) {
        max = maxRaw.toDouble();
      } else {
        return null;
      }
      bands.add(CnssIrBracket(maxQuarterlyIrMad: max, amountMad: amount));
    }
    bands.sort((a, b) => a.maxQuarterlyIrMad.compareTo(b.maxQuarterlyIrMad));
    return bands;
  }
}
