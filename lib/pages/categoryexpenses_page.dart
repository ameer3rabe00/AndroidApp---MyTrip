import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class CategoryExpensesPage extends StatelessWidget {
  final String categoryName;
  final List<Expense> expenses;
  final void Function(int expenseId) onDelete;

  const CategoryExpensesPage({
    super.key,
    required this.categoryName,
    required this.expenses,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("הוצאות עבור $categoryName")),
      body: expenses.isEmpty
          ? const Center(child: Text("אין הוצאות"))
          : ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              title: Text(expense.description.isEmpty ? "ללא תיאור" : expense.description),
              subtitle: Text("₪${expense.amount.toStringAsFixed(0)} - ${expense.formattedDate}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(expense.id),
                tooltip: "מחק הוצאה",
              ),
            ),
          );
        },
      ),
    );
  }
}
