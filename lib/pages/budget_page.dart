import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../pages/categoryexpenses_page.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  List<Category> categories = [];
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final catData = prefs.getString('categories');
    final expData = prefs.getString('expenses');

    if (catData != null) {
      final decoded = jsonDecode(catData);
      categories = List<Map<String, dynamic>>.from(decoded)
          .map((item) => Category.fromJson(item))
          .toList();
    }

    if (expData != null) {
      final decoded = jsonDecode(expData);
      expenses = List<Map<String, dynamic>>.from(decoded)
          .map((item) => Expense.fromJson(item))
          .toList();
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String encodedCategories = jsonEncode(
      categories.map((c) => c.toJson()).toList(),
    );
    String encodedExpenses = jsonEncode(
      expenses.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('categories', encodedCategories);
    await prefs.setString('expenses', encodedExpenses);
  }

  double _sumExpensesForCategory(int categoryId) {
    return expenses
        .where((e) => e.categoryId == categoryId)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  void _addCategory() {
    String name = "";
    String budgetStr = "";
    bool nameError = false;
    bool budgetError = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("הוסף קטגוריה"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: "שם קטגוריה *",
                      errorText: nameError ? "שדה חובה" : null,
                    ),
                    onChanged: (val) {
                      name = val;
                      if (nameError) {
                        setStateDialog(() => nameError = false);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "תקציב מתוכנן *",
                      errorText: budgetError ? "שדה חובה / לא תקין" : null,
                    ),
                    onChanged: (val) {
                      budgetStr = val;
                      if (budgetError) {
                        setStateDialog(() => budgetError = false);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ביטול"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final parsedBudget = double.tryParse(budgetStr);
                    setStateDialog(() {
                      nameError = name.trim().isEmpty;
                      budgetError = parsedBudget == null || parsedBudget <= 0;
                    });

                    if (!nameError && !budgetError) {
                      setState(() {
                        final newCategory = Category(
                          id: DateTime.now().millisecondsSinceEpoch,
                          name: name.trim(),
                          plannedBudget: parsedBudget!,
                        );
                        categories.add(newCategory);
                      });

                      Navigator.pop(context);
                      await _saveData();
                    }
                  },
                  child: const Text("שמור"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addExpense(int categoryId) {
    String description = "";
    String amountStr = "";
    DateTime selectedDate = DateTime.now();

    bool amountError = false;
    bool dateError = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("הוסף הוצאה"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "סכום *",
                      errorText: amountError ? "שדה חובה / לא תקין" : null,
                    ),
                    onChanged: (val) {
                      amountStr = val;
                      if (amountError) {
                        setDialogState(() => amountError = false);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "תיאור (אופציונלי)",
                    ),
                    onChanged: (val) {
                      description = val;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    ),
                    decoration: InputDecoration(
                      labelText: "תאריך *",
                      suffixIcon: const Icon(Icons.calendar_today),
                      errorText: dateError ? "חובה לבחור תאריך" : null,
                    ),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                          dateError = false;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ביטול"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final parsedAmount = double.tryParse(amountStr);
                    setDialogState(() {
                      amountError = parsedAmount == null || parsedAmount <= 0;
                    });

                    if (!amountError && !dateError) {
                      setState(() {
                        expenses.add(
                          Expense(
                            id: DateTime.now().millisecondsSinceEpoch,
                            categoryId: categoryId,
                            amount: parsedAmount!,
                            description: description.trim(),
                            date: selectedDate,
                          ),
                        );
                      });

                      Navigator.pop(context);
                      await _saveData();
                    }
                  },
                  child: const Text("שמור"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ניהול תקציב")),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final totalSpent = _sumExpensesForCategory(category.id);
          final expenseCount = expenses.where((e) => e.categoryId == category.id).length;

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              onTap: () {
                final categoryExpenses = expenses
                    .where((e) => e.categoryId == category.id)
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryExpensesPage(
                      categoryName: category.name,
                      expenses: categoryExpenses,
                      onDelete: (expenseId) async {
                        setState(() {
                          expenses.removeWhere((e) => e.id == expenseId);
                        });
                        Navigator.pop(context);
                        await _saveData();
                      },
                    ),
                  ),
                );
              },
              title: Text(category.name),
              subtitle: Text(
                "מתוכנן: ₪${category.plannedBudget.toStringAsFixed(0)}"
                    "\nהוצאות בפועל: ₪${totalSpent.toStringAsFixed(0)}"
                    "\n📄 סה\"כ הוצאות: $expenseCount",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addExpense(category.id),
                    tooltip: "הוסף הוצאה",
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: "מחק קטגוריה",
                    onPressed: () async {
                      setState(() {
                        expenses.removeWhere((e) => e.categoryId == category.id);
                        categories.removeAt(index);
                      });
                      await _saveData();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        tooltip: "הוסף קטגוריה",
        child: const Icon(Icons.add),
      ),
    );
  }
}