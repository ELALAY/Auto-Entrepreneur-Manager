/// Reusable product or service line template for invoices.
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.userId,
    required this.description,
    required this.defaultUnitPrice,
    required this.kind,
  });

  final String id;
  final String userId;
  final String description;
  final double defaultUnitPrice;
  final CatalogKind kind;

  CatalogItem copyWith({
    String? id,
    String? userId,
    String? description,
    double? defaultUnitPrice,
    CatalogKind? kind,
  }) {
    return CatalogItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      defaultUnitPrice: defaultUnitPrice ?? this.defaultUnitPrice,
      kind: kind ?? this.kind,
    );
  }
}

enum CatalogKind {
  product,
  service,
}
