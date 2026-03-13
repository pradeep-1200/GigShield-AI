import 'package:flutter/material.dart';

import 'screens/registration_screen.dart';
import 'screens/risk_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/monitor_screen.dart';
import 'screens/payout_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const GigShieldApp());
}

class GigShieldApp extends StatelessWidget {
  const GigShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GigShield AI',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const RegistrationScreen(),
        '/risk': (context) => const RiskScreen(),
        '/premium': (context) => const PremiumScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/monitor': (context) => const MonitorScreen(),
        '/payout': (context) => const PayoutScreen(),
      },
    );
  }
}
