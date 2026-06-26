import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../state/wallet_state.dart';
import '../widgets/interactive_forecast_chart.dart';
import '../utils/currency_formatter.dart';
import 'feasibility_screen.dart';

class AIForecastScreen extends StatefulWidget {
  final WalletState state;
  const AIForecastScreen({super.key, required this.state});

  @override
  State<AIForecastScreen> createState() => _AIForecastScreenState();
}

class _AIForecastScreenState extends State<AIForecastScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF0F172A),
            child: SafeArea(
              bottom: false,
              child: TabBar(
                indicatorColor: const Color(0xFF6366F1),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF94A3B8),
                tabs: [
                  Tab(text: AppStrings.get('aiBalanceForecast')),
                  Tab(text: AppStrings.get('feasibilityTitle')),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildForecastTab(),
                FeasibilityScreen(state: widget.state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastTab() {
    final timeline = widget.state.calculateForecastTimeline(widget.state.selectedForecastDays);
    final finalPredValue = timeline.isNotEmpty ? timeline.last : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF38BDF8), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.get('aiDisclaimerTitle'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF38BDF8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.get('aiDisclaimerText'),
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
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
                      value: widget.state.selectedForecastDays,
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
                        if (val != null) {
                          setState(() {
                            widget.state.changeForecastDays(val);
                          });
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Grafico Custom Painter reattivo e interattivo
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: InteractiveForecastChart(
                    data: timeline,
                    lineColor: const Color(0xFF6366F1),
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
        ],
      ),
    );
  }
}
