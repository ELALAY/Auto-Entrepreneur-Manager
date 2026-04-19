import 'enums.dart';

class ServiceProduct {
  const ServiceProduct({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.unitPrice,
    required this.unitType,
    this.category,
  });

  final String id;
  final String userId;
  final String name;
  final String description;
  final double unitPrice;
  final ServiceUnitType unitType;

  /// Optional grouping label for catalog or reporting.
  final String? category;

  ServiceProduct copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    double? unitPrice,
    ServiceUnitType? unitType,
    String? category,
    bool clearCategory = false,
  }) {
    return ServiceProduct(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      unitType: unitType ?? this.unitType,
      category: clearCategory ? null : (category ?? this.category),
    );
  }
}
