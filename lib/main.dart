import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'start_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyTripApp());
}

class MyTripApp extends StatelessWidget {
  const MyTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTrip',
      debugShowCheckedModeBanner: false,

      locale: const Locale('he'),
      supportedLocales: const [Locale('he'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),

      home: const StartPage(),
    );
  }
}