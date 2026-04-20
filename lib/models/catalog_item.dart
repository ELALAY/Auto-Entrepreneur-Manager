import '../domain/tax/activity_category.dart';

/// Reusable product or service line template for invoices.
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.userId,
    required this.description,
    required this.defaultUnitPrice,
    required this.kind,
    required this.activityCategory,
  });

  final String id;
  final String userId;
  final String description;
  final double defaultUnitPrice;
  final CatalogKind kind;

  /// Tax activity family (IR rate); used when this template is added to an invoice.
  final ActivityCategory activityCategory;

  CatalogItem copyWith({
    String? id,
    String? userId,
    String? description,
    double? defaultUnitPrice,
    CatalogKind? kind,
    ActivityCategory? activityCategory,
  }) {
    return CatalogItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      defaultUnitPrice: defaultUnitPrice ?? this.defaultUnitPrice,
      kind: kind ?? this.kind,
      activityCategory: activityCategory ?? this.activityCategory,
    );
  }
}

enum CatalogKind {
  product,
  service,
}
