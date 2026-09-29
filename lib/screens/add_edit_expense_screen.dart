import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expense_form.dart';

class AddEditExpenseScreen extends StatelessWidget {
  final Expense? expense;

  const AddEditExpenseScreen({super.key, this.expense});

  @override
  Widget build(BuildContext context) {
    final isEditing = expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: SafeArea(
        child: ExpenseForm(expense: expense),
      ),
    );
  }
}
