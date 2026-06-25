import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../models/transaction.dart';
import '../state/wallet_state.dart';
import '../utils/currency_formatter.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final WalletState state;
  final bool showActions;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.state,
    required this.showActions,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == TransactionType.income;
    final bool isCard = transaction.type == TransactionType.expenseCard;

    Color iconBg = const Color(0xFFF43F5E).withOpacity(0.1);
    Color iconFg = const Color(0xFFF43F5E);
    IconData icon = Icons.arrow_downward_rounded;

    if (isIncome) {
      iconBg = const Color(0xFF10B981).withOpacity(0.1);
      iconFg = const Color(0xFF10B981);
      icon = Icons.arrow_upward_rounded;
    } else if (isCard) {
      iconBg = const Color(0xFFF59E0B).withOpacity(0.1);
      iconFg = const Color(0xFFF59E0B);
      icon = Icons.credit_card_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconFg, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        transaction.description,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      if (transaction.isProjected) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppStrings.get('labelPrev'),
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
                      ],
                      if (isCard) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppStrings.get('labelCard'),
                            style: const TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} • ${_getLocalCategory(transaction.category)}',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                  ),
                ],
              )
            ],
          ),
          Row(
            children: [
              Text(
                '${isIncome ? '+' : '-'} ${formatCurrency(transaction.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isIncome ? const Color(0xFF10B981) : Colors.white,
                ),
              ),
              if (showActions) ...[
                const SizedBox(width: 8),
                if (transaction.isProjected)
                  IconButton(
                    icon: const Icon(Icons.flash_on_rounded, color: Color(0xFF10B981), size: 18),
                    onPressed: () => _openConcretizeDialog(context),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF43F5E), size: 18),
                  onPressed: () => state.deleteTransaction(transaction.id),
                ),
              ]
            ],
          )
        ],
      ),
    );
  }

  String _getLocalCategory(String category) {
    switch (category.toLowerCase()) {
      case 'lavoro':
        return AppStrings.get('categoryJob');
      case 'casa':
        return AppStrings.get('categoryHome');
      case 'alimentari':
        return AppStrings.get('categoryFood');
      case 'bollette':
        return AppStrings.get('categoryBills');
      case 'svago':
        return AppStrings.get('categoryLeisure');
      case 'trasporti':
        return AppStrings.get('categoryTransport');
      case 'altro':
        return AppStrings.get('categoryOther');
      default:
        return category;
    }
  }

  void _openConcretizeDialog(BuildContext context) {
    final TextEditingController descController = TextEditingController(text: transaction.description);
    final TextEditingController amountController = TextEditingController(text: transaction.amount.toStringAsFixed(2));
    DateTime chosenDate = DateTime.now();
    String destination = 'main'; // 'main' | 'card'

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final now = DateTime.now();
            final maxSafeDate = now; // Impedisce date future

            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.get('concretizeForecast'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('concretizeDesc'),
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                    const SizedBox(height: 16),

                    if (transaction.recurrence != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFFEF4444), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppStrings.get('isRecurringAlert'),
                                style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Nome
                    Text(
                      AppStrings.get('concretizeName'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Importo
                    Text(
                      AppStrings.get('amountEuro'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date selector
                    Text(
                      AppStrings.get('concretizeDate'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: chosenDate.isAfter(maxSafeDate) ? maxSafeDate : chosenDate,
                          firstDate: now.subtract(const Duration(days: 365)),
                          lastDate: maxSafeDate, // Cappa rigidamente a oggi
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFF10B981),
                                surface: Color(0xFF1E293B),
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() => chosenDate = picked);
                        }
                      },
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${chosenDate.day}/${chosenDate.month}/${chosenDate.year}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF94A3B8)),
                          ],
                        ),
                      ),
                    ),

                    // Selettore destinazione se uscita
                    if (transaction.type != TransactionType.income) ...[
                      const SizedBox(height: 14),
                      Text(
                        AppStrings.get('concretizeAccount'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildDialogOption(
                              setDialogState,
                              AppStrings.get('mainAccount'),
                              'main',
                              destination,
                              (val) => destination = val,
                            ),
                            _buildDialogOption(
                              setDialogState,
                              AppStrings.get('creditCard'),
                              'card',
                              destination,
                              (val) => destination = val,
                            ),
                          ],
                        ),
                      )
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppStrings.get('cancel'),
                    style: const TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final newDesc = descController.text.trim();
                    final newAmount = double.tryParse(amountController.text) ?? 0.0;

                    if (newDesc.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.get('validationName'))),
                      );
                      return;
                    }
                    if (newAmount <= 0.0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.get('validationAmount'))),
                      );
                      return;
                    }
                    if (chosenDate.isAfter(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.get('validationFutureDate'))),
                      );
                      return;
                    }

                    final success = state.concretizeTransaction(
                      transaction.id,
                      newDesc,
                      newAmount,
                      chosenDate,
                      transaction.type == TransactionType.income
                          ? TransactionType.income
                          : (destination == 'main'
                              ? TransactionType.expenseMain
                              : TransactionType.expenseCard),
                    );

                    if (success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.get('concretizeSuccess')),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  child: Text(
                    AppStrings.get('confirm'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogOption(
    StateSetter setDialogState,
    String text,
    String key,
    String currentDest,
    Function(String) onSelect,
  ) {
    final isSelected = key == currentDest;
    return Expanded(
      child: GestureDetector(
        onTap: () => setDialogState(() => onSelect(key)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }
}
