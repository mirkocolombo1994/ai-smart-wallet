import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../models/transaction.dart';
import '../state/wallet_state.dart';
import '../widgets/transaction_list_item.dart';

class LedgerScreen extends StatelessWidget {
  final WalletState state;
  const LedgerScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Filtra transazioni
    final List<Transaction> filtered = state.transactions.where((tx) {
      if (state.ledgerFilter == 'projected') return tx.isProjected;
      if (state.ledgerFilter == 'actual') return !tx.isProjected;
      return true;
    }).toList();

    // Ordina per data decrescente
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.get('ledgerTitle'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // Filter Switchers
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildFilterChip(AppStrings.get('chipAll'), 'all'),
                    _buildFilterChip(AppStrings.get('chipForecast'), 'projected'),
                    _buildFilterChip(AppStrings.get('chipActual'), 'actual'),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.get('noTransactions'),
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      return TransactionListItem(
                        transaction: filtered[idx],
                        state: state,
                        showActions: true,
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String key) {
    final active = state.ledgerFilter == key;
    return GestureDetector(
      onTap: () => state.changeLedgerFilter(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
