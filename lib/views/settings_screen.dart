import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../state/wallet_state.dart';
import '../ui/screens/user_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  final WalletState state;
  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _startDay;
  late int _paymentDay;

  @override
  void initState() {
    super.initState();
    _startDay = widget.state.ccStartDay;
    _paymentDay = widget.state.ccPaymentDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('settings')),
        backgroundColor: const Color(0xFF0F172A),
      ),
      backgroundColor: const Color(0xFF0F172A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lingua
            _buildSectionTitle(AppStrings.get('language'), Icons.language),
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AppLanguage>(
                    value: AppStrings.currentLanguage,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    items: const [
                      DropdownMenuItem(
                        value: AppLanguage.it,
                        child: Text('Italiano'),
                      ),
                      DropdownMenuItem(
                        value: AppLanguage.en,
                        child: Text('English'),
                      ),
                    ],
                    onChanged: (lang) {
                      if (lang != null) {
                        widget.state.changeLanguage(lang);
                        setState(() {});
                      }
                    },
                  ),
                ),
              ),
            ),
            // Account
            _buildSectionTitle('Account', Icons.account_circle),
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: const Text('Profilo Utente'),
                trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Impostazioni Carta
            _buildSectionTitle(AppStrings.get('creditCardSettingsTitle'), Icons.credit_card),
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.get('ccCycleStartDay'), style: const TextStyle(fontSize: 13)),
                        DropdownButton<int>(
                          value: _startDay,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          items: List.generate(28, (index) => index + 1).map((d) {
                            return DropdownMenuItem(value: d, child: Text(d.toString()));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _startDay = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.get('ccPaymentDay'), style: const TextStyle(fontSize: 13)),
                        DropdownButton<int>(
                          value: _paymentDay,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          items: List.generate(28, (index) => index + 1).map((d) {
                            return DropdownMenuItem(value: d, child: Text(d.toString()));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _paymentDay = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          widget.state.changeCreditCardSettings(_startDay, _paymentDay);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppStrings.get('settingsSaved'))),
                          );
                        },
                        child: Text(AppStrings.get('saveSettings')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Informazioni App
            _buildSectionTitle(AppStrings.get('appInfo'), Icons.info_outline),
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text(AppStrings.get('appInfo')),
                trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: AppStrings.get('appTitle'),
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2026 Smart Wallet AI',
                    applicationIcon: const Icon(Icons.account_balance_wallet, size: 48, color: Color(0xFF6366F1)),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Danger Zone
            _buildSectionTitle(AppStrings.get('dangerZone'), Icons.warning_amber_rounded, color: Colors.redAccent),
            Card(
              color: Colors.redAccent.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.redAccent),
              ),
              child: ListTile(
                title: Text(
                  AppStrings.get('deleteAllData'),
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.delete_forever, color: Colors.redAccent),
                onTap: () => _confirmDeleteData(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(AppStrings.get('deleteAllDataConfirmTitle'), style: const TextStyle(color: Colors.redAccent)),
        content: Text(AppStrings.get('deleteAllDataConfirmText')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.get('cancel'), style: const TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              widget.state.deleteAllData();
              Navigator.pop(ctx);
              Navigator.pop(context); // Torna alla dashboard
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.get('resetSuccess'))),
              );
            },
            child: Text(AppStrings.get('confirm')),
          ),
        ],
      ),
    );
  }
}
