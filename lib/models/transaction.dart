// lib/models/transaction.dart
class Transaction {
  final String memo;
  final double amount;
  final String type; // '+' for income, '-' for expense
  final bool isExpected;

  Transaction({
    required this.memo,
    required this.amount,
    required this.type,
    required this.isExpected,
  });

  Map<String, dynamic> toJson() => {
    'memo': memo,
    'amount': amount,
    'type': type,
    'isExpected': isExpected,
  };

  static Transaction fromJson(Map<String, dynamic> json) => Transaction(
    memo: json['memo'],
    amount: json['amount'],
    type: json['type'],
    isExpected: json['isExpected'],
  );
}
