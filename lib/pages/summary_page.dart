import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage>
    with TickerProviderStateMixin {
  List<Activity> activities = [];
  List<Category> categories = [];
  List<Expense> expenses = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();


    String? activitiesData = prefs.getString('activities');
    if (activitiesData != null) {
      List<dynamic> decoded = jsonDecode(activitiesData);
      activities = decoded.map((item) => Activity.fromJson(item)).toList();
    }


    String? categoriesData = prefs.getString('categories');
    if (categoriesData != null) {
      List<dynamic> decoded = jsonDecode(categoriesData);
      categories = decoded.map((item) => Category.fromJson(item)).toList();
    }


    String? expensesData = prefs.getString('expenses');
    if (expensesData != null) {
      List<dynamic> decoded = jsonDecode(expensesData);
      expenses = decoded.map((item) => Expense.fromJson(item)).toList();
    }

    if (mounted) {
      setState(() {});
      _animationController.forward();
    }
  }


  int get totalActivities => activities.length;
  int get completedActivities => activities.where((a) => a.isDone).length;
  double get activitiesCompletionRate =>
      totalActivities > 0 ? (completedActivities / totalActivities) * 100 : 0;


  double get totalPlannedBudget =>
      categories.fold(0.0, (sum, c) => sum + c.plannedBudget);
  double get totalActualExpenses =>
      expenses.fold(0.0, (sum, e) => sum + e.amount);
  double get budgetUsageRate =>
      totalPlannedBudget > 0 ? (totalActualExpenses / totalPlannedBudget) * 100 : 0;
  double get budgetDifference => totalPlannedBudget - totalActualExpenses;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final padding = isSmallScreen ? 12.0 : 20.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.teal.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
             
                    Container(
                      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 20),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade400,
                                  Colors.teal.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.assessment,
                              color: Colors.white,
                              size: isSmallScreen ? 24 : 28,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 12 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'סיכום הטיול',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 24 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                                Text(
                                  'מבט כללי על התקדמות הטיול',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 12 : 20),

              
                    _buildSummaryCard(
                      title: 'סיכום פעילויות',
                      icon: Icons.event_note,
                      gradient: [Colors.blue.shade400, Colors.blue.shade600],
                      isSmallScreen: isSmallScreen,
                      child: Column(
                        children: [
                          _buildProgressCircle(
                            percentage: activitiesCompletionRate,
                            color: Colors.blue.shade600,
                            isSmallScreen: isSmallScreen,
                            centerWidget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${activitiesCompletionRate.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 20 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                Text(
                                  'הושלם',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 10 : 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 24),
                          _buildStatsRow(
                            isSmallScreen: isSmallScreen,
                            stats: [
                              StatData('סה"כ פעילויות', totalActivities.toString(),
                                  Icons.list_alt, Colors.blue.shade600),
                              StatData('הושלמו', completedActivities.toString(),
                                  Icons.check_circle, Colors.green.shade600),
                              StatData('נותרו', (totalActivities - completedActivities).toString(),
                                  Icons.schedule, Colors.orange.shade600),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 12 : 20),

             
                    _buildSummaryCard(
                      title: 'סיכום תקציב',
                      icon: Icons.account_balance_wallet,
                      gradient: [Colors.teal.shade400, Colors.teal.shade600],
                      isSmallScreen: isSmallScreen,
                      child: Column(
                        children: [
                          _buildProgressCircle(
                            percentage: budgetUsageRate > 100 ? 100 : budgetUsageRate,
                            color: budgetUsageRate > 100
                                ? Colors.red.shade600
                                : Colors.teal.shade600,
                            isSmallScreen: isSmallScreen,
                            centerWidget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${budgetUsageRate.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 20 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: budgetUsageRate > 100
                                        ? Colors.red.shade700
                                        : Colors.teal.shade700,
                                  ),
                                ),
                                Text(
                                  'ניצול',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 10 : 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            extraRing: budgetUsageRate > 100,
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 24),
                          _buildStatsRow(
                            isSmallScreen: isSmallScreen,
                            stats: [
                              StatData('תקציב מתוכנן', '₪${totalPlannedBudget.toStringAsFixed(0)}',
                                  Icons.savings, Colors.blue.shade600),
                              StatData('הוצאות בפועל', '₪${totalActualExpenses.toStringAsFixed(0)}',
                                  Icons.money_off, budgetUsageRate > 100
                                      ? Colors.red.shade600
                                      : Colors.orange.shade600),
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                            decoration: BoxDecoration(
                              color: budgetDifference >= 0
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: budgetDifference >= 0
                                    ? Colors.green.shade200
                                    : Colors.red.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  budgetDifference >= 0
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color: budgetDifference >= 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  size: isSmallScreen ? 18 : 24,
                                ),
                                SizedBox(width: isSmallScreen ? 6 : 8),
                                Flexible(
                                  child: Text(
                                    budgetDifference >= 0
                                        ? 'חסכת ₪${budgetDifference.toStringAsFixed(0)}'
                                        : 'חריגה של ₪${(-budgetDifference).toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: budgetDifference >= 0
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 12 : 20),

 
                    _buildQuickStatsGrid(isSmallScreen: isSmallScreen),

                    SizedBox(height: isSmallScreen ? 20 : 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required Widget child,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isSmallScreen ? 15 : 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        ),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isSmallScreen ? 20 : 24,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCircle({
    required double percentage,
    required Color color,
    required Widget centerWidget,
    required bool isSmallScreen,
    bool extraRing = false,
  }) {
    final circleSize = isSmallScreen ? 100.0 : 140.0;
    final strokeWidth = isSmallScreen ? 6.0 : 8.0;

    return Center(
      child: SizedBox(
        width: circleSize,
        height: circleSize,
        child: Stack(
          children: [

            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
            ),

            SizedBox(
              width: circleSize,
              height: circleSize,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: strokeWidth,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),

            if (extraRing)
              SizedBox(
                width: circleSize,
                height: circleSize,
                child: CircularProgressIndicator(
                  value: (percentage - 100) / 100,
                  strokeWidth: strokeWidth * 0.5,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade600),
                ),
              ),

            Center(child: centerWidget),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow({
    required bool isSmallScreen,
    required List<StatData> stats,
  }) {
    if (isSmallScreen && stats.length > 2) {

      return Column(
        children: [
          Row(
            children: stats.take(2).map((stat) =>
                Expanded(child: _buildStatItem(stat, isSmallScreen))
            ).toList(),
          ),
          if (stats.length > 2) ...[
            SizedBox(height: isSmallScreen ? 8 : 12),
            Row(
              children: [
                Expanded(flex: 1, child: Container()),
                Expanded(flex: 2, child: _buildStatItem(stats[2], isSmallScreen)),
                Expanded(flex: 1, child: Container()),
              ],
            ),
          ],
        ],
      );
    } else {

      return Row(
        children: stats.map((stat) =>
            Expanded(child: _buildStatItem(stat, isSmallScreen))
        ).toList(),
      );
    }
  }

  Widget _buildStatItem(StatData stat, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
      decoration: BoxDecoration(
        color: stat.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stat.color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(stat.icon, color: stat.color, size: isSmallScreen ? 20 : 24),
          SizedBox(height: isSmallScreen ? 6 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stat.value,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: stat.color,
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 2 : 4),
          Text(
            stat.label,
            style: TextStyle(
              fontSize: isSmallScreen ? 9 : 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid({required bool isSmallScreen}) {
    final upcomingActivities = activities
        .where((a) => !a.isDone && !a.isPast)
        .length;
    final overdueActivities = activities
        .where((a) => !a.isDone && a.isPast)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'סטטיסטיקות מהירות',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: isSmallScreen ? 0.85 : 1.0,
          crossAxisSpacing: isSmallScreen ? 8 : 12,
          mainAxisSpacing: isSmallScreen ? 8 : 12,
          children: [
            _buildQuickStatCard(
              'פעילויות קרובות',
              upcomingActivities.toString(),
              Icons.upcoming,
              Colors.blue.shade600,
              isSmallScreen,
            ),
            _buildQuickStatCard(
              'פעילויות שפג זמנן',
              overdueActivities.toString(),
              Icons.schedule_outlined,
              Colors.red.shade600,
              isSmallScreen,
            ),
            _buildQuickStatCard(
              'קטגוריות תקציב',
              categories.length.toString(),
              Icons.category,
              Colors.purple.shade600,
              isSmallScreen,
            ),
            _buildQuickStatCard(
              'סה"כ הוצאות',
              expenses.length.toString(),
              Icons.receipt_long,
              Colors.orange.shade600,
              isSmallScreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      bool isSmallScreen,
      ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: isSmallScreen ? 8 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        ),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isSmallScreen ? 22 : 28,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  StatData(this.label, this.value, this.icon, this.color);
}