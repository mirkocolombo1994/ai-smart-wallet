import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../state/wallet_state.dart';
import '../../models/transaction.dart';

class MonthlyReportScreen extends StatelessWidget {
  final WalletState state;

  const MonthlyReportScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    // Filtra spese del mese corrente
    final monthlyExpenses = state.transactions
        .where(
          (tx) =>
              !tx.isProjected &&
              tx.date.isAfter(
                firstDayOfMonth.subtract(const Duration(days: 1)),
              ) &&
              tx.type == TransactionType.expenseMain,
        )
        .toList();

    double totalSpent = 0;
    Map<String, double> categoryTotals = {};

    for (var tx in monthlyExpenses) {
      totalSpent += tx.amount;
      categoryTotals[tx.category] =
          (categoryTotals[tx.category] ?? 0) + tx.amount;
    }

    String topCategory = '';
    double maxCatSpent = 0;
    categoryTotals.forEach((key, value) {
      if (value > maxCatSpent) {
        maxCatSpent = value;
        topCategory = key;
      }
    });

    String saverLevel = 'Bronzo';
    Color levelColor = Colors.brown;

    // Livelli basati su quanto è stato speso (esempio semplice)
    if (totalSpent < 500) {
      saverLevel = 'Oro';
      levelColor = Colors.amber;
    } else if (totalSpent < 1000) {
      saverLevel = 'Argento';
      levelColor = Colors.grey.shade300;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Il Tuo Mese'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Questo mese sei stato un\nrisparmiatore di livello:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Text(
                saverLevel.toUpperCase(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: levelColor,
                  shadows: [
                    Shadow(
                      color: levelColor.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Spesa Totale:',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              Text(
                '€${totalSpent.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              if (categoryTotals.isNotEmpty) ...[
                const Text(
                  'Ripartizione Spese',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _generateChartSections(
                        categoryTotals,
                        totalSpent,
                      ),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'La tua categoria più dispendiosa è stata "$topCategory".',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ] else
                const Text(
                  'Nessuna spesa registrata questo mese. Ottimo lavoro!',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateChartSections(
    Map<String, double> data,
    double total,
  ) {
    final colors = [
      Colors.indigo,
      Colors.green,
      Colors.amber,
      Colors.pink,
      Colors.cyan,
      Colors.purple,
    ];

    int colorIndex = 0;
    return data.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final section = PieChartSectionData(
        color: colors[colorIndex % colors.length],
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
      colorIndex++;
      return section;
    }).toList();
  }
}
