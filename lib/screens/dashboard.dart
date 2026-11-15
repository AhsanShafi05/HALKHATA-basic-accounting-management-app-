import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/transaction_from_model.dart';
import 'package:flutter_application_1/services/auth-service.dart';
import 'package:flutter_application_1/services/transaction-service.dart';
import 'package:flutter_application_1/widgets/transaction-card.dart';

import '../../main.dart';
import '../../models/transaction_model.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactionsFuture = TransactionService.getTransactions();
  }

  Future<void> _refresh() async {
    setState(_loadTransactions);
    await _transactionsFuture;
  }

  Future<void> _openForm({TransactionModel? transaction}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(transaction: transaction),
      ),
    );
    if (saved == true && mounted) {
      setState(_loadTransactions);
    }
  }

  Future<void> _delete(TransactionModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete record?'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await TransactionService.deleteTransaction(item.id);
      if (mounted) setState(_loadTransactions);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $error')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
  }

  Widget _summaryCard(String title, double amount, Color color) {
  return Expanded(
    child: Card(
      color: color,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                amount.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final userEmail = supabase.auth.currentUser?.email ?? 'Business owner';

    return Scaffold(
      appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 234, 227, 156), // Light yellow
                foregroundColor: Colors.black87,
                title: const Text('Halkhata Dashboard'),
                actions: [
                  IconButton(
                    tooltip: 'Logout',
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add record'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<TransactionModel>>(
          future: _transactionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text('Error: ${snapshot.error}')),
                  TextButton(
                    onPressed: () => setState(_loadTransactions),
                    child: const Text('Try again'),
                  ),
                ],
              );
            }

            final items = snapshot.data ?? [];
            final income = items
                .where((item) => item.type == 'income')
                .fold<double>(0, (sum, item) => sum + item.amount);
            final expenses = items
                .where((item) => item.type == 'expense')
                .fold<double>(0, (sum, item) => sum + item.amount);
            final balance = income - expenses;

            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              children: [
                Text('Welcome, $userEmail'),
                const SizedBox(height: 12),
                Row(
                    children: [
                      _summaryCard(
                        'Income',
                        income,
                        const Color(0xFFC8E6C9), // Light green
                      ),
                      _summaryCard(
                        'Expenses',
                        expenses,
                        const Color.fromARGB(255, 255, 205, 210), // Light red
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _summaryCard(
                        'Current balance',
                        balance,
                        const Color.fromARGB(255, 216, 191, 216), // Mauve
                      ),
                    ],
                  ),
                const SizedBox(height: 18),
                Text(
                  'Your transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(
                      child: Text(
                        'No records yet. Tap "Add record" to create your first one.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...items.map(
                    (item) => TransactionCard(
                      transaction: item,
                      onEdit: () => _openForm(transaction: item),
                      onDelete: () => _delete(item),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
