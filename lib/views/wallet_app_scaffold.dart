import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../state/wallet_state.dart';
import 'add_transaction_screen.dart';
import 'dashboard_screen.dart';
import 'feasibility_screen.dart';
import 'ledger_screen.dart';

class WalletAppScaffold extends StatefulWidget {
  const WalletAppScaffold({super.key});

  @override
  State<WalletAppScaffold> createState() => _WalletAppScaffoldState();
}

class _WalletAppScaffoldState extends State<WalletAppScaffold> {
  late WalletState _state;

  @override
  void initState() {
    super.initState();
    _state = WalletState();
    _state.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(state: _state),
      FeasibilityScreen(state: _state),
      AddTransactionScreen(state: _state),
      LedgerScreen(state: _state),
    ];

    return Scaffold(
      body: SafeArea(
        child: screens[_state.currentTab],
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          border: Border(top: BorderSide(color: Color(0xFF334155), width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, AppStrings.get('navHome')),
            _buildNavItem(
              1,
              Icons.psychology_rounded,
              AppStrings.get('navFeasibility'),
            ),
            _buildAddNavItem(),
            _buildNavItem(3, Icons.receipt_long_rounded, AppStrings.get('navLedger')),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _state.currentTab == index;
    final activeColor = index == 0 ? const Color(0xFF10B981) : const Color(0xFF6366F1);

    return InkWell(
      onTap: () => _state.changeTab(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNavItem() {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: GestureDetector(
        onTap: () => _state.changeTab(2),
        child: Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            color: Color(0xFF6366F1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
