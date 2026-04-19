/// Minimal invoice row for lists (e.g. client detail, invoice list).
class InvoiceSummary {
  const InvoiceSummary({
    required this.id,
    required this.number,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    required this.clientId,
    this.clientName = '',
    this.total = 0,
    this.paidTotal = 0,
  });

  final String id;
  final String number;
  final DateTime issueDate;
  final DateTime dueDate;
  final String status;
  final String clientId;
  final String clientName;
  final double total;
  final double paidTotal;

  double get balance => (total - paidTotal).clamp(0.0, double.infinity);

  bool get isPartiallyPaid => paidTotal > 0 && balance > 0.001;

  bool isOverdueNotPaid() {
    if (status == 'paid' || balance <= 0.001) return false;
    final now = DateTime.now();
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(due);
  }
}
