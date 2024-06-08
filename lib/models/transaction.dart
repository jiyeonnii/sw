// lib/models/transaction.dart
class Transaction {
  final String name;
  final double amount;
  final String type;
  final bool isExpected;

  Transaction({
    required this.name,
    required this.amount,
    required this.type,
    required this.isExpected,
  });
}
