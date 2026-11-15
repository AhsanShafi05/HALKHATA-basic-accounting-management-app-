import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/transaction-service.dart';
import 'package:flutter_application_1/widgets/custom-text-field.dart';

import '../../models/transaction_model.dart';
import '../../validators/validators.dart';


class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _categoryController;
  late final TextEditingController _notesController;

  late String _type;
  late DateTime _date;
  bool _loading = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final item = widget.transaction;
    _titleController = TextEditingController(text: item?.title ?? '');
    _amountController =
        TextEditingController(text: item?.amount.toString() ?? '');
    _categoryController =
        TextEditingController(text: item?.category ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');
    _type = item?.type ?? 'income';
    _date = item?.transactionDate ?? DateTime.now();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final userId = _isEditing
          ? widget.transaction!.userId
          : ''; // Service supplies the current user's ID on insert.

      final item = TransactionModel(
        id: widget.transaction?.id ?? '',
        userId: userId,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        type: _type,
        category: _categoryController.text.trim(),
        transactionDate: _date,
        notes: _notesController.text.trim(),
      );

      if (_isEditing) {
        await TransactionService.updateTransaction(item);
      } else {
        await TransactionService.addTransaction(item);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save record: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) setState(() => _date = selected);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit record' : 'Add record'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Record type'),
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _titleController,
                label: 'Title (e.g. Product sales)',
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _amountController,
                label: 'Amount',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.validateAmount,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _categoryController,
                label: 'Category (e.g. Sales, Rent)',
                validator: Validators.validateRequired,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Transaction date'),
                subtitle: Text(_date.toLocal().toString().split(' ').first),
                trailing: IconButton(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month),
                ),
              ),
              CustomTextField(
                controller: _notesController,
                label: 'Notes (optional)',
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _save,
                  child: Text(_loading ? 'Saving...' : 'Save record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
