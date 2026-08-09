import 'package:flutter/material.dart';
import 'providers/athlete_provider.dart';
import 'package:provider/provider.dart';

// Imports de tu proyecto
import 'screens/home/athlete_main_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AthleteProvider()..fetchAllData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Deportiva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const AthleteMainScreen(),
    );
  }
}