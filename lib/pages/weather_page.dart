import 'package:flutter/material.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context){
    return Center(
      child:  Text(
        "Weather Page",
        style: TextStyle(fontSize: 24,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}