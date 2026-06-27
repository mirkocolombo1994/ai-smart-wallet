import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'constants/app_strings.dart';
import 'views/wallet_app_scaffold.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/onboarding_screen.dart';
import 'services/biometric_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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

class SmartWalletApp extends StatelessWidget {
  const SmartWalletApp({super.key});

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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasData && snapshot.data != null) {
            // L'utente è loggato, avviamo il controllo biometrico.
            return const BiometricWrapper(
              child: InitialDecisionScreen(),
            );
          }

          // Non loggato, andiamo alla schermata di login. NESSUN controllo biometrico.
          return const AuthScreen();
        },
      ),
    );
  }
}

class InitialDecisionScreen extends StatefulWidget {
  const InitialDecisionScreen({super.key});

  @override
  State<InitialDecisionScreen> createState() => _InitialDecisionScreenState();
}

class _InitialDecisionScreenState extends State<InitialDecisionScreen> {
  bool _isLoading = true;
  bool _hasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (!_hasSeenOnboarding) {
      return const OnboardingScreen();
    }
    
    return const WalletAppScaffold();
  }
}

class BiometricWrapper extends StatefulWidget {
  final Widget child;
  const BiometricWrapper({super.key, required this.child});

  @override
  State<BiometricWrapper> createState() => _BiometricWrapperState();
}

class _BiometricWrapperState extends State<BiometricWrapper> with WidgetsBindingObserver {
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
    if (!_isAuthenticatedBiometrically) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Sblocco richiesto',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _checkBiometric,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Usa Biometria'),
              )
            ],
          ),
        ),
      );
    }
    return widget.child;
  }
}
