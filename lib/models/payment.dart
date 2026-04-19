import 'enums.dart';

class Payment {
  const Payment({
    required this.id,
    required this.userId,
    required this.invoiceId,
    required this.date,
    required this.amount,
    required this.method,
  });

  final String id;
  final String userId;
  final String invoiceId;
  final DateTime date;
  final double amount;
  final PaymentMethod method;

  Payment copyWith({
    String? id,
    String? userId,
    String? invoiceId,
    DateTime? date,
    double? amount,
    PaymentMethod? method,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      invoiceId: invoiceId ?? this.invoiceId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      method: method ?? this.method,
    );
  }
}
