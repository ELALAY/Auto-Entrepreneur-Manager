class InvoiceItem {
  const InvoiceItem({
    this.serviceId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  final String? serviceId;
  final String description;
  final double quantity;
  final double unitPrice;

  double get lineTotal => quantity * unitPrice;

  InvoiceItem copyWith({
    String? serviceId,
    String? description,
    double? quantity,
    double? unitPrice,
    bool clearServiceId = false,
  }) {
    return InvoiceItem(
      serviceId: clearServiceId ? null : (serviceId ?? this.serviceId),
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
