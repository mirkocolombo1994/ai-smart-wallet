import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../state/wallet_state.dart';
import '../utils/currency_formatter.dart';

class FeasibilityScreen extends StatefulWidget {
  final WalletState state;
  const FeasibilityScreen({super.key, required this.state});

  @override
  State<FeasibilityScreen> createState() => _FeasibilityScreenState();
}

class _FeasibilityScreenState extends State<FeasibilityScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _frequency = 'single'; // 'single' | 'monthly' | 'yearly'

  bool _hasResult = false;
  String _status = 'green'; // 'green' | 'yellow' | 'red'
  String _statusText = '';
  String _advice = '';
  double _m1Impact = 0.0;
  double _m2Impact = 0.0;
  double _simulatedM1Balance = 0.0;
  double _simulatedM2Balance = 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.psychology_rounded, color: Color(0xFF6366F1)),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.get('feasibilityTitle'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
                Text(
                  AppStrings.get('feasibilityDesc'),
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
                const SizedBox(height: 16),

                // Campo Nome (Opzionale)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.get('expenseServiceName'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF0284C7).withOpacity(0.3)),
                      ),
                      child: Text(
                        AppStrings.get('optional'),
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: AppStrings.get('exampleExpense'),
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),

                // Campo Importo
                Text(
                  AppStrings.get('amountEuro'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),

                // Selezione Frequenza
                Text(
                  AppStrings.get('expenseFrequency'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _buildFreqButton('single', AppStrings.get('single')),
                      _buildFreqButton('monthly', AppStrings.get('monthly')),
                      _buildFreqButton('yearly', AppStrings.get('yearly')),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tasto Analisi
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.analytics_rounded, size: 20),
                    label: Text(
                      AppStrings.get('analyzeButton'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _evaluateFeasibility,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card Risultato
          if (_hasResult) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getResultBgColor(),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getResultBorderColor(), width: 1),
              ),
              child: Row(
                children: [
                  Text(_getResultIcon(), style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.get('evaluationResult'),
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _statusText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getResultTextColor(),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Report Dettaglio
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
                    children: [
                      const Icon(
                        Icons.insert_chart_outlined_rounded,
                        color: Color(0xFF6366F1),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.get('forecastBudgetAnalysis'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReportRow(
                    AppStrings.get('currentMonthImpact'),
                    '-${formatCurrency(_m1Impact)}',
                    '${AppStrings.get('newBalance')}${formatCurrency(_simulatedM1Balance)}',
                  ),
                  const SizedBox(height: 12),
                  _buildReportRow(
                    AppStrings.get('nextMonthImpact'),
                    '-${formatCurrency(_m2Impact)}',
                    '${AppStrings.get('newBalance')}${formatCurrency(_simulatedM2Balance)}',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.get('recommendedSafetyThreshold'),
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                      ),
                      const Text(
                        '€ 400,00',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.assistant_outlined, color: Color(0xFF6366F1), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              AppStrings.get('aiStrategicAdvice'),
                              style: const TextStyle(
                                color: Color(0xFF6366F1),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _advice,
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildFreqButton(String val, String text) {
    final active = _frequency == val;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _frequency = val),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF6366F1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value, String subtext) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                const SizedBox(height: 4),
                Text(subtext, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
              ],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFF43F5E),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _evaluateFeasibility() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('validAmountError'))),
      );
      return;
    }

    final name = _nameController.text.trim();
    final finalName = name.isEmpty ? AppStrings.get('defaultSimName') : name;

    // Genera simulazione dei prossimi 2 mesi (60 giorni)
    final timeline = widget.state.calculateForecastTimeline(60);
    if (timeline.length < 60) return;

    final balanceEndMonth1 = timeline[29]; // Fine mese 1 stima
    final balanceEndMonth2 = timeline[59]; // Fine mese 2 stima

    if (_frequency == 'monthly') {
      _m1Impact = amount;
      _m2Impact = amount;
    } else if (_frequency == 'yearly') {
      _m1Impact = amount;
      _m2Impact = 0.0; // Addebito iniziale immediato
    } else {
      _m1Impact = amount;
      _m2Impact = 0.0;
    }

    _simulatedM1Balance = balanceEndMonth1 - _m1Impact;
    _simulatedM2Balance = balanceEndMonth2 - (_m1Impact + _m2Impact);

    const safetyThreshold = 400.0;

    // Logica semaforo
    if (_simulatedM1Balance < 0 || _simulatedM2Balance < 0) {
      _status = 'red';
      _statusText = AppStrings.get('statusRed');
      _advice = AppStrings.get('adviceRed', placeholders: {'name': finalName});
    } else if (_simulatedM1Balance < safetyThreshold || _simulatedM2Balance < safetyThreshold) {
      _status = 'yellow';
      _statusText = AppStrings.get('statusYellow');
      _advice = AppStrings.get(
        'adviceYellow',
        placeholders: {
          'name': finalName,
          'threshold': formatCurrency(safetyThreshold),
        },
      );
    } else {
      _status = 'green';
      _statusText = AppStrings.get('statusGreen');
      _advice = AppStrings.get('adviceGreen', placeholders: {'name': finalName});
    }

    setState(() {
      _hasResult = true;
    });
  }

  Color _getResultBgColor() {
    if (_status == 'red') return const Color(0xFFF43F5E).withOpacity(0.08);
    if (_status == 'yellow') return const Color(0xFFF59E0B).withOpacity(0.08);
    return const Color(0xFF10B981).withOpacity(0.08);
  }

  Color _getResultBorderColor() {
    if (_status == 'red') return const Color(0xFFF43F5E).withOpacity(0.4);
    if (_status == 'yellow') return const Color(0xFFF59E0B).withOpacity(0.4);
    return const Color(0xFF10B981).withOpacity(0.4);
  }

  Color _getResultTextColor() {
    if (_status == 'red') return const Color(0xFFFDA4AF);
    if (_status == 'yellow') return const Color(0xFFFDE047);
    return const Color(0xFFA7F3D0);
  }

  String _getResultIcon() {
    if (_status == 'red') return '🔴';
    if (_status == 'yellow') return '🟡';
    return '🟢';
  }
}
