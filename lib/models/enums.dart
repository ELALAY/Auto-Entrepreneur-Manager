enum InvoiceStatus {
  draft,
  sent,
  paid,
  overdue,
}

enum PaymentMethod {
  cash,
  virement,
  cheque,
  autre,
}

enum ServiceUnitType {
  hour,
  day,
  forfait,
  unit,
}

enum DeclarationStatus {
  draft,
  readyToFile,
  filed,
}
