/// One row of Morocco AE-style **flat** quarterly CNSS (MAD due for revenue up to cap).
///
/// Pick the **first** bracket where [quarterlyRevenueMad] ≤ [maxQuarterlyRevenueMad].
/// Last row should use [double.infinity] so every revenue value matches.
class CnssQuarterBracket {
  const CnssQuarterBracket({
    required this.maxQuarterlyRevenueMad,
    required this.amountMad,
  });

  /// Inclusive upper bound on quarterly turnover (same basis as invoiced collections).
  final double maxQuarterlyRevenueMad;

  /// Quarterly CNSS due (flat amount) when revenue falls in this band.
  final double amountMad;
}
