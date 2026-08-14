import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/athlete_provider.dart';
import 'providers/training_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/school_provider.dart';
import 'providers/school_history_provider.dart';
import 'providers/school_request_provider.dart';
import 'providers/event_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/transfer_provider.dart';

// Screens
import 'screens/auth/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => AthleteProvider()),
          ChangeNotifierProvider(create: (_) => SchoolProvider()),
          ChangeNotifierProvider(create: (_) => TransferProvider()),
          ChangeNotifierProvider(create: (_) => TrainingProvider()),
          ChangeNotifierProvider(create: (_) => PaymentProvider()),
          ChangeNotifierProvider(create: (_) => SchoolRequestProvider()),
          ChangeNotifierProvider(create: (_) => EventProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => SchoolHistoryProvider()),  // <-- NUEVO
        ],
      child: MaterialApp(
        title: 'Rolla',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}