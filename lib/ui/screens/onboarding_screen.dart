import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../views/wallet_app_scaffold.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WalletAppScaffold()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() => isLastPage = index == 2);
          },
          children: [
            _buildPage(
              color: const Color(0xFF0F172A),
              title: 'Benvenuto in AI Smart Wallet',
              description:
                  'La Dashboard è il tuo centro di controllo. Qui vedrai il saldo totale, le tue spese recenti e un riepilogo rapido del tuo andamento.',
              icon: Icons.dashboard_rounded,
            ),
            _buildPage(
              color: const Color(0xFF1E293B),
              title: 'Aggiungi Spese Velocemente',
              description:
                  'Usa il pulsante "+" per registrare entrate o uscite. L\'IA analizzerà e categorizzerà le tue abitudini.',
              icon: Icons.add_circle_outline,
            ),
            _buildPage(
              color: const Color(0xFF0F172A),
              title: 'Previsioni e Ricorrenze',
              description:
                  'Nella sezione Previsioni troverai stime per il mese in corso. Il sistema rileva anche abbonamenti e spese ricorrenti!',
              icon: Icons.insights_rounded,
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _controller.jumpToPage(2),
              child: const Text('SALTA'),
            ),
            Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: WormEffect(
                  spacing: 16,
                  dotColor: Colors.grey.shade700,
                  activeDotColor: Theme.of(context).primaryColor,
                ),
                onDotClicked: (index) => _controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (isLastPage) {
                  _completeOnboarding();
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                  );
                }
              },
              child: Text(isLastPage ? 'INIZIA' : 'AVANTI'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required Color color,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Theme.of(context).primaryColor),
          const SizedBox(height: 64),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            description,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
