import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'constants/app_strings.dart';
import 'views/wallet_app_scaffold.dart';
import 'ui/screens/auth_screen.dart';
import 'services/biometric_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init failed (maybe options missing): $e');
  }
  
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }

  runApp(const SmartWalletApp());
}

class SmartWalletApp extends StatefulWidget {
  const SmartWalletApp({super.key});

  @override
  State<SmartWalletApp> createState() => _SmartWalletAppState();
}

class _SmartWalletAppState extends State<SmartWalletApp> with WidgetsBindingObserver {
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticatedBiometrically = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometric();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBiometric();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      setState(() {
        _isAuthenticatedBiometrically = false;
      });
    }
  }

  Future<void> _checkBiometric() async {
    if (_isAuthenticating || _isAuthenticatedBiometrically) return;

    setState(() {
      _isAuthenticating = true;
    });

    bool canAuth = await _biometricService.isBiometricAvailable();
    if (canAuth) {
      bool success = await _biometricService.authenticate();
      if (mounted) {
        setState(() {
          _isAuthenticatedBiometrically = success;
          _isAuthenticating = false;
        });
      }
    } else {
      // Se la biometria non è disponibile, passiamo oltre.
      if (mounted) {
        setState(() {
          _isAuthenticatedBiometrically = true;
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.get('appTitle'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF6366F1),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (!_isAuthenticatedBiometrically) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const WalletAppScaffold();
        }

        return const AuthScreen();
      },
    );
  }
}
