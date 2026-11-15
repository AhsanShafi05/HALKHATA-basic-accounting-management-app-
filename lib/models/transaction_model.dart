class TransactionModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String type;
  final String category;
  final DateTime transactionDate;
  final String notes;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.transactionDate,
    required this.notes,
  });

  // Convert a Supabase row (Map) into a Dart object.
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      category: map['category'] as String,
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      notes: (map['notes'] ?? '') as String,
    );
  }

  // Convert a Dart object into the fields we want to save.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'transaction_date':
          '${transactionDate.year.toString().padLeft(4, '0')}-'
          '${transactionDate.month.toString().padLeft(2, '0')}-'
          '${transactionDate.day.toString().padLeft(2, '0')}',
      'notes': notes,
    };
  }
}
