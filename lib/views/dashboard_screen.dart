import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../state/wallet_state.dart';
import '../utils/currency_formatter.dart';
import '../widgets/forecast_chart_painter.dart';
import '../widgets/transaction_list_item.dart';

class DashboardScreen extends StatelessWidget {
  final WalletState state;
  const DashboardScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final timeline = state.calculateForecastTimeline(state.selectedForecastDays);
    final finalPredValue = timeline.isNotEmpty ? timeline.last : 0.0;

    // Calcolo date per le label dei saldi
    final actualTxs = state.transactions.where((tx) => !tx.isProjected).toList();
    DateTime latestActualDate = DateTime.now();
    if (actualTxs.isNotEmpty) {
      latestActualDate = actualTxs
          .map((tx) => tx.date)
          .fold(actualTxs.first.date, (prev, elem) => elem.isAfter(prev) ? elem : prev);
    }
    final String formattedActualDate =
        '${latestActualDate.day.toString().padLeft(2, '0')}/${latestActualDate.month.toString().padLeft(2, '0')}/${latestActualDate.year}';

    final DateTime forecastDate = DateTime.now().add(Duration(days: state.selectedForecastDays));
    final String formattedForecastDate =
        '${forecastDate.day.toString().padLeft(2, '0')}/${forecastDate.month.toString().padLeft(2, '0')}/${forecastDate.year}';

    // Rileva il periodo carta di credito per la label
    final ccPeriod = state.getCreditCardPeriod(DateTime.now());
    final ccStartStr =
        '${ccPeriod['start']!.day.toString().padLeft(2, '0')}/${ccPeriod['start']!.month.toString().padLeft(2, '0')}';
    final ccEndStr =
        '${ccPeriod['end']!.day.toString().padLeft(2, '0')}/${ccPeriod['end']!.month.toString().padLeft(2, '0')}';

    // Liste di transazioni
    actualTxs.sort((a, b) => b.date.compareTo(a.date)); // decrescente (ultimi movimenti)
    final recentActual = actualTxs.take(4).toList();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final endRange = todayStart.add(const Duration(days: 30));

    final forecastTxs = state.transactions.where((tx) {
      return tx.isProjected &&
          (tx.date.isAfter(todayStart) || tx.date.isAtSameMomentAs(todayStart)) &&
          tx.date.isBefore(endRange);
    }).toList();
    forecastTxs.sort((a, b) => a.date.compareTo(b.date)); // crescente (prossime scadenze)
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
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                  Row(
                    children: [
                      Text(
                        AppStrings.get('smartWallet'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                      )
                    ],
                  )
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF94A3B8)),
                onPressed: () {
                  state.resetToMockData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.get('resetSuccess')),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              )
            ],
          ),
          const SizedBox(height: 20),

          // Saldi principali con date dinamiche
          Row(
            children: [
              Expanded(
                child: _buildBalanceCard(
                  AppStrings.get('actualBalanceWithDate', placeholders: {'date': formattedActualDate}),
                  state.saldoEffettivo,
                  const Color(0xFF10B981),
                  AppStrings.get('liquidAccount'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBalanceCard(
                  AppStrings.get('forecastBalanceWithDate', placeholders: {'date': formattedForecastDate}),
                  state.saldoPrevisto,
                  const Color(0xFF38BDF8),
                  AppStrings.get('insertedProjection'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Differenza e Carta Credito
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155), width: 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('balanceDiff'),
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(state.differenzaSaldi),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: state.differenzaSaldi >= 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF43F5E),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppStrings.get(
                        'creditCardExpensesRange',
                        placeholders: {'start': ccStartStr, 'end': ccEndStr},
                      ),
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(state.speseCartaCredito),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Card Impostazioni Carta di Credito
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                AppStrings.get('creditCardSettingsTitle'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
              ),
              leading: const Icon(Icons.credit_card_rounded, color: Color(0xFF94A3B8), size: 18),
              backgroundColor: const Color(0xFF1E293B),
              collapsedBackgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('ccCycleStartDay'),
                            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            initialValue: state.ccStartDay,
                            dropdownColor: const Color(0xFF1E293B),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: List.generate(
                              28,
                              (index) => DropdownMenuItem(value: index + 1, child: Text('${index + 1}')),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                state.changeCreditCardSettings(val, state.ccPaymentDay);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('ccPaymentDay'),
                            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            initialValue: state.ccPaymentDay,
                            dropdownColor: const Color(0xFF1E293B),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: List.generate(
                              28,
                              (index) => DropdownMenuItem(value: index + 1, child: Text('${index + 1}')),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                state.changeCreditCardSettings(state.ccStartDay, val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sezione Predittiva AI
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6366F1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppStrings.get('aiBalanceForecast'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    DropdownButton<int>(
                      value: state.selectedForecastDays,
                      dropdownColor: const Color(0xFF1E293B),
                      underline: const SizedBox(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 30,
                          child: Text(AppStrings.get('days30')),
                        ),
                        DropdownMenuItem(
                          value: 90,
                          child: Text(AppStrings.get('months3')),
                        ),
                        DropdownMenuItem(
                          value: 180,
                          child: Text(AppStrings.get('months6')),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) state.changeForecastDays(val);
                      },
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Grafico Custom Painter reattivo
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: ForecastChartPainter(
                      data: timeline,
                      lineColor: const Color(0xFF6366F1),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(color: Color(0xFF334155)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.get('finalBalanceEstimate'),
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                    Text(
                      formatCurrency(finalPredValue),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: finalPredValue >= 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF43F5E),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

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
                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 12),
                ),
              )
            ],
          ),
          if (recentActual.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  AppStrings.get('noTransactions'),
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
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
                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12),
                ),
              )
            ],
          ),
          if (upcomingForecast.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  AppStrings.get('noForecastTransactions'),
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
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
    String subtitle,
  ) {
    return Container(
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
          Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 9)),
        ],
      ),
    );
  }
}
