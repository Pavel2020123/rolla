import 'package:flutter/material.dart';

import '../screens/auth/splash_screen.dart';
import 'theme/app_theme.dart';

class RollaApp extends StatelessWidget {
  const RollaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rolla',
      theme: RollaTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}