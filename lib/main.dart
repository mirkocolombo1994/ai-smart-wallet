import 'package:flutter/material.dart';
import 'constants/app_strings.dart';
import 'views/wallet_app_scaffold.dart';

void main() {
  runApp(const SmartWalletApp());
}

class SmartWalletApp extends StatelessWidget {
  const SmartWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.get('appTitle'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        primaryColor: const Color(0xFF6366F1), // Indigo 500
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF10B981), // Emerald 500
          surface: Color(0xFF1E293B), // Slate 800
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const WalletAppScaffold(),
    );
  }
}
