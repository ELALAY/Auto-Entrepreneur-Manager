import 'enums.dart';

class Declaration {
  const Declaration({
    required this.id,
    required this.userId,
    required this.year,
    required this.quarter,
    required this.totalRevenue,
    required this.irAmount,
    required this.cnssAmount,
    required this.status,
    this.filedDate,
    this.taxRatesVersion,
  }) : assert(quarter >= 1 && quarter <= 4);

  final String id;
  final String userId;
  final int year;

  /// 1–4
  final int quarter;
  final double totalRevenue;
  final double irAmount;
  final double cnssAmount;
  final DeclarationStatus status;
  final DateTime? filedDate;

  /// Snapshot of `config/taxRates` version used when this record was saved.
  final int? taxRatesVersion;

  /// Matches [declarationPeriodKey] / Firestore doc id convention.
  String get periodKey => '$year-$quarter';

  Declaration copyWith({
    String? id,
    String? userId,
    int? year,
    int? quarter,
    double? totalRevenue,
    double? irAmount,
    double? cnssAmount,
    DeclarationStatus? status,
    DateTime? filedDate,
    bool clearFiledDate = false,
    int? taxRatesVersion,
    bool clearTaxRatesVersion = false,
  }) {
    return Declaration(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      year: year ?? this.year,
      quarter: quarter ?? this.quarter,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      irAmount: irAmount ?? this.irAmount,
      cnssAmount: cnssAmount ?? this.cnssAmount,
      status: status ?? this.status,
      filedDate: clearFiledDate ? null : (filedDate ?? this.filedDate),
      taxRatesVersion:
          clearTaxRatesVersion ? null : (taxRatesVersion ?? this.taxRatesVersion),
    );
  }
}
