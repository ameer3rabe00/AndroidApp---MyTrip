import 'package:flutter/material.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context){
    return Center(
      child:  Text(
        "Summary Page",
        style: TextStyle(fontSize: 24,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}