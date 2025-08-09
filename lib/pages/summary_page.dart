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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
        
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade400,
                                  Colors.teal.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.assessment,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'סיכום הטיול',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                                Text(
                                  'מבט כללי על התקדמות הטיול',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

               
                    _buildSummaryCard(
                      title: 'סיכום פעילויות',
                      icon: Icons.event_note,
                      gradient: [Colors.blue.shade400, Colors.blue.shade600],
                      child: Column(
                        children: [
                          _buildProgressCircle(
                            percentage: activitiesCompletionRate,
                            color: Colors.blue.shade600,
                            centerWidget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${activitiesCompletionRate.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                Text(
                                  'הושלם',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  'סה"כ פעילויות',
                                  totalActivities.toString(),
                                  Icons.list_alt,
                                  Colors.blue.shade600,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  'הושלמו',
                                  completedActivities.toString(),
                                  Icons.check_circle,
                                  Colors.green.shade600,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  'נותרו',
                                  (totalActivities - completedActivities).toString(),
                                  Icons.schedule,
                                  Colors.orange.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

              
                    _buildSummaryCard(
                      title: 'סיכום תקציב',
                      icon: Icons.account_balance_wallet,
                      gradient: [Colors.teal.shade400, Colors.teal.shade600],
                      child: Column(
                        children: [
                          _buildProgressCircle(
                            percentage: budgetUsageRate > 100 ? 100 : budgetUsageRate,
                            color: budgetUsageRate > 100 
                                ? Colors.red.shade600 
                                : Colors.teal.shade600,
                            centerWidget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${budgetUsageRate.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: budgetUsageRate > 100 
                                        ? Colors.red.shade700 
                                        : Colors.teal.shade700,
                                  ),
                                ),
                                Text(
                                  'ניצול',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            extraRing: budgetUsageRate > 100,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  'תקציב מתוכנן',
                                  '₪${totalPlannedBudget.toStringAsFixed(0)}',
                                  Icons.savings,
                                  Colors.blue.shade600,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  'הוצאות בפועל',
                                  '₪${totalActualExpenses.toStringAsFixed(0)}',
                                  Icons.money_off,
                                  budgetUsageRate > 100 
                                      ? Colors.red.shade600 
                                      : Colors.orange.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
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
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  budgetDifference >= 0 
                                      ? 'חסכת ₪${budgetDifference.toStringAsFixed(0)}'
                                      : 'חריגה של ₪${(-budgetDifference).toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: budgetDifference >= 0 
                                        ? Colors.green.shade700 
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

          
                    _buildQuickStatsGrid(),

                    const SizedBox(height: 32),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
    bool extraRing = false,
  }) {
    return Center(
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          children: [
 
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
            ),
    
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 8,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
        
            if (extraRing)
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: (percentage - 100) / 100,
                  strokeWidth: 4,
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildQuickStatCard(
              'פעילויות קרובות',
              upcomingActivities.toString(),
              Icons.upcoming,
              Colors.blue.shade600,
            ),
            _buildQuickStatCard(
              'פעילויות שפג זמנן',
              overdueActivities.toString(),
              Icons.schedule_outlined,
              Colors.red.shade600,
            ),
            _buildQuickStatCard(
              'קטגוריות תקציב',
              categories.length.toString(),
              Icons.category,
              Colors.purple.shade600,
            ),
            _buildQuickStatCard(
              'סה"כ הוצאות',
              expenses.length.toString(),
              Icons.receipt_long,
              Colors.orange.shade600,
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
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}