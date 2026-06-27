import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../state/wallet_state.dart';
import '../utils/currency_formatter.dart';
import '../widgets/transaction_list_item.dart';
import '../ui/widgets/goal_card.dart';
import 'settings_screen.dart';
import '../ui/screens/monthly_report_screen.dart';

class DashboardScreen extends StatelessWidget {
  final WalletState state;
  const DashboardScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final actualTxs = state.transactions
        .where((tx) => !tx.isProjected)
        .toList();

    // Liste di transazioni
    actualTxs.sort(
      (a, b) => b.date.compareTo(a.date),
    ); // decrescente (ultimi movimenti)
    final recentActual = actualTxs.take(4).toList();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final endRange = todayStart.add(const Duration(days: 30));

    final forecastTxs = state.transactions.where((tx) {
      return tx.isProjected &&
          tx.associatedTransactionId == null && // Hide concretized projections
          (tx.date.isAfter(todayStart) ||
              tx.date.isAtSameMomentAs(todayStart)) &&
          tx.date.isBefore(endRange);
    }).toList();
    forecastTxs.sort(
      (a, b) => a.date.compareTo(b.date),
    ); // crescente (prossime scadenze)
    final upcomingForecast = forecastTxs.take(4).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get('welcome'),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        AppStrings.get('smartWallet'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppStrings.get('ai'),
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.bar_chart_rounded,
                      color: Color(0xFFF59E0B),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MonthlyReportScreen(state: state),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Color(0xFF94A3B8)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(state: state),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Prima riga saldi
          Row(
            children: [
              Expanded(
                child: _buildBalanceCard(
                  AppStrings.get('actual'),
                  state.saldoEffettivoOdierno,
                  const Color(0xFF10B981),
                  'Fino ad oggi',
                  onTap: () {
                    state.changeLedgerFilter('actual');
                    state.changeTab(3);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBalanceCard(
                  AppStrings.get('forecast'),
                  state.saldoPrevistoOdierno,
                  const Color(0xFF38BDF8),
                  'Budget ad oggi',
                  onTap: () {
                    state.changeLedgerFilter('projected');
                    state.changeTab(3);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Seconda riga saldi
          Row(
            children: [
              Expanded(
                child: _buildBalanceCard(
                  AppStrings.get('balanceDiff'),
                  state.differenzaSaldiOdierna,
                  state.differenzaSaldiOdierna >= 0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF43F5E),
                  'Effettivo - Previsto',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBalanceCard(
                  AppStrings.get('creditCardExpenses'),
                  state.speseCartaCreditoMeseCorrente,
                  const Color(0xFFF59E0B),
                  'Prec: ${formatCurrency(state.speseCartaCreditoMesePrecedente)}',
                  onTap: () {
                    state.changeTab(4); // Vai a tab Carte di Credito
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // LISTA OBIETTIVI DI RISPARMIO (Savings Goals)
          if (state.savingsGoals.isNotEmpty) ...[
            const Text(
              'OBIETTIVI DI RISPARMIO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF59E0B),
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 140, // Altezza fissa per lo scrolling orizzontale
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.savingsGoals.length,
                itemBuilder: (context, idx) {
                  return SizedBox(
                    width: 260, // Larghezza fissa per le card
                    child: GoalCard(goal: state.savingsGoals[idx]),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],

          // LISTA 1: Movimenti Effettivi (Storico)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.get('actualMovementsHeader'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 1.1,
                ),
              ),
              TextButton(
                onPressed: () {
                  state.changeLedgerFilter('actual');
                  state.changeTab(3); // Vai al registro
                },
                child: Text(
                  AppStrings.get('seeAll'),
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (recentActual.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  AppStrings.get('noTransactions'),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentActual.length,
              itemBuilder: (context, idx) {
                final tx = recentActual[idx];
                return TransactionListItem(
                  transaction: tx,
                  state: state,
                  showActions: false,
                );
              },
            ),
          const SizedBox(height: 20),

          // LISTA 2: Scadenze e Previsioni (Prossimi 30 GG)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.get('forecastMovementsHeader'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF38BDF8),
                  letterSpacing: 1.1,
                ),
              ),
              TextButton(
                onPressed: () {
                  state.changeLedgerFilter('projected');
                  state.changeTab(3); // Vai al registro
                },
                child: Text(
                  AppStrings.get('seeAll'),
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (upcomingForecast.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  AppStrings.get('noForecastTransactions'),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingForecast.length,
              itemBuilder: (context, idx) {
                final tx = upcomingForecast[idx];
                return TransactionListItem(
                  transaction: tx,
                  state: state,
                  showActions: false,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    String title,
    double value,
    Color accentColor,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E293B),
              const Color(0xFF0F172A).withValues(alpha: 0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF334155), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(value),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
