import '../main.dart';
import '../models/transaction_model.dart';

class TransactionService {
  static const String tableName = 'transactions';

  // READ: get only the signed-in user's records.
  static Future<List<TransactionModel>> getTransactions() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Please log in first.');
    }

    final response = await supabase
        .from(tableName)
        .select()
        .eq('user_id', user.id)
        .order('transaction_date', ascending: false);

    return (response as List)
        .map((row) => TransactionModel.fromMap(row))
        .toList();
  }

  // CREATE: add a new income or expense.
  static Future<void> addTransaction(TransactionModel transaction) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Please log in first.');
    }

    await supabase.from(tableName).insert({
      ...transaction.toMap(),
      'user_id': user.id,
    });
  }

  // UPDATE: change an existing record.
  static Future<void> updateTransaction(
    TransactionModel transaction,
  ) async {
    await supabase
        .from(tableName)
        .update(transaction.toMap())
        .eq('id', transaction.id)
        .eq('user_id', supabase.auth.currentUser!.id);
  }

  // DELETE: remove a record.
  static Future<void> deleteTransaction(String id) async {
    await supabase
        .from(tableName)
        .delete()
        .eq('id', id)
        .eq('user_id', supabase.auth.currentUser!.id);
  }
}
