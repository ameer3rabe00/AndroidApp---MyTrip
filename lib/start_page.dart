import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'pages/activities_page.dart';
import 'pages/budget_page.dart';
import 'pages/weather_page.dart';
import 'pages/summary_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ActivitiesPage(),
    BudgetPage(),
    WeatherPage(),
    SummaryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal, // CHANGED: From Color(0xFF02F2F6) to Colors.teal
      child: SafeArea(
        top: false, left: false, right: false,
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: CurvedNavigationBar(
            color: Colors.teal,
            buttonBackgroundColor: Colors.teal,
            backgroundColor: Colors.transparent,
            onTap: (value) => setState(() => _currentIndex = value),
            items: [
              Icon(_currentIndex == 0 ? Icons.event : Icons.event_outlined, size: 30, color: Colors.white),
              Icon(_currentIndex == 1 ? Icons.attach_money : Icons.attach_money_outlined, size: 30, color: Colors.white),
              Icon(_currentIndex == 2 ? Icons.cloud : Icons.cloud_outlined, size: 30, color: Colors.white),
              Icon(_currentIndex == 3 ? Icons.pie_chart : Icons.pie_chart_outline_outlined, size: 30, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}