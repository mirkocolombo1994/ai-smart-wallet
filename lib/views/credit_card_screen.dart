import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../state/wallet_state.dart';
import '../utils/currency_formatter.dart';
import '../widgets/transaction_list_item.dart';

class CreditCardScreen extends StatelessWidget {
  final WalletState state;
  const CreditCardScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Raggruppiamo le spese carta di credito passate (reali) per mese di fatturazione
    // Per semplicità le raggruppiamo per mese e anno della transazione, 
    // oppure calcoliamo il periodo di fatturazione esatto.
    final ccTransactions = state.transactions
        .where((tx) => !tx.isProjected && tx.type == TransactionType.expenseCard)
        .toList();
    
    // Ordine decrescente
    ccTransactions.sort((a, b) => b.date.compareTo(a.date));

    // Raggruppa per chiave "Anno-Mese" basata sulla data di chiusura estratto conto
    final Map<String, List<Transaction>> grouped = {};
    for (var tx in ccTransactions) {
      // Troviamo il periodo a cui appartiene
      final period = state.getCreditCardPeriod(tx.date);
      final key = '${period['start']!.year}-${period['start']!.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card_rounded, color: Color(0xFF94A3B8)),
              const SizedBox(width: 8),
              Text(
                'Spese Carta di Credito',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: sortedKeys.isEmpty
                ? Center(
                    child: Text(
                      'Nessuna spesa con carta di credito',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, idx) {
                      final key = sortedKeys[idx];
                      final list = grouped[key]!;
                      final total = list.fold(0.0, (sum, item) => sum + item.amount);
                      
                      final startMonth = list.first.date;
                      final period = state.getCreditCardPeriod(startMonth);
                      final startStr = '${period['start']!.day.toString().padLeft(2, '0')}/${period['start']!.month.toString().padLeft(2, '0')}';
                      final endStr = '${period['end']!.day.toString().padLeft(2, '0')}/${period['end']!.month.toString().padLeft(2, '0')}/${period['end']!.year}';

                      return Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: Card(
                          color: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            title: Text(
                              'Estratto Conto ($startStr - $endStr)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            subtitle: Text(
                              'Totale: ${formatCurrency(total)}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                            ),
                            children: list.map((tx) {
                              return TransactionListItem(
                                transaction: tx,
                                state: state,
                                showActions: true,
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
