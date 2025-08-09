import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';

class BudgetBarChart extends StatelessWidget {
  final List<Category> categories;
  final List<Expense> expenses;

  const BudgetBarChart({
    super.key,
    required this.categories,
    required this.expenses,
  });

  double _sumExpensesForCategory(int categoryId) {
    return expenses
        .where((e) => e.categoryId == categoryId)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final actual = _sumExpensesForCategory(category.id);
      final planned = category.plannedBudget;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: planned,
              color: Colors.blue,
              width: 14,
              borderRadius: BorderRadius.circular(4),
            ),
            BarChartRodData(
              toY: actual,
              color: Colors.orange,
              width: 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            'השוואת תקציב מול הוצאות',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // 🟡 מקרא הצבעים מתחת לכותרת
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.square, color: Colors.orange, size: 14),
              SizedBox(width: 4),
              Text('הוצאות בפועל'),
              SizedBox(width: 16),
              Icon(Icons.square, color: Colors.blue, size: 14),
              SizedBox(width: 4),
              Text('תקציב מתוכנן'),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 🟢 הגרף עצמו
        SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < categories.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              categories[index].name,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}