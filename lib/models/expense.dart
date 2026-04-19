class Expense {
  const Expense({
    required this.id,
    required this.userId,
    required this.date,
    required this.amount,
    required this.category,
    required this.description,
    this.receiptUrl,
  });

  final String id;
  final String userId;
  final DateTime date;
  final double amount;
  final String category;
  final String description;
  final String? receiptUrl;

  Expense copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? amount,
    String? category,
    String? description,
    String? receiptUrl,
    bool clearReceiptUrl = false,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      receiptUrl: clearReceiptUrl ? null : (receiptUrl ?? this.receiptUrl),
    );
  }
}
