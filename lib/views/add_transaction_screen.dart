import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../models/transaction.dart';
import '../state/wallet_state.dart';

class AddTransactionScreen extends StatefulWidget {
  final WalletState state;
  final Transaction? editingTransaction;
  const AddTransactionScreen({super.key, required this.state, this.editingTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _isProjected = false; // true = Previsione, false = Effettivo
  String _flow = 'expense'; // 'expense' | 'income'
  String _destination = 'main'; // 'main' | 'card'
  String _category = 'Alimentari';
  DateTime _selectedDate = DateTime.now();
  String? _recurrence; // null, 'weekly', 'monthly', 'yearly'

  @override
  void initState() {
    super.initState();
    if (widget.editingTransaction != null) {
      final tx = widget.editingTransaction!;
      _descController.text = tx.description;
      _amountController.text = tx.amount.toString();
      _isProjected = tx.isProjected;
      _flow = tx.type == TransactionType.income ? 'income' : 'expense';
      _destination = tx.type == TransactionType.expenseCard ? 'card' : 'main';
      _category = tx.category;
      _selectedDate = tx.date;
      _recurrence = tx.recurrence;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
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
              if (widget.editingTransaction != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              Text(
                widget.editingTransaction != null ? 'Modifica Movimento' : AppStrings.get('addMovement'),
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
                // Stato: Previsione vs Effettivo
                Text(
                  AppStrings.get('stateType'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                _buildSegmentedControl(
                  [AppStrings.get('forecast'), AppStrings.get('actual')],
                  _isProjected ? 0 : 1,
                  (idx) {
                    setState(() {
                      _isProjected = idx == 0;
                      // Cappa la data a oggi se cambia a effettivo e la data impostata è futura
                      if (!_isProjected && _selectedDate.isAfter(DateTime.now())) {
                        _selectedDate = DateTime.now();
                      }
                    });
                  },
                ),
                const SizedBox(height: 14),

                // Destinazione (Addebito) - Mostra solo se Effettivo e non è un'entrata
                if (!_isProjected && _flow == 'expense') ...[
                  Text(
                    AppStrings.get('accountCreditCard'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  _buildSegmentedControl(
                    [AppStrings.get('mainAccount'), AppStrings.get('creditCard')],
                    _destination == 'main' ? 0 : 1,
                    (idx) => setState(() => _destination = idx == 0 ? 'main' : 'card'),
                  ),
                  const SizedBox(height: 14),
                ],

                // Flusso: Entrata vs Spesa
                Text(
                  AppStrings.get('flow'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                _buildSegmentedControl(
                  [AppStrings.get('income'), AppStrings.get('expense')],
                  _flow == 'income' ? 0 : 1,
                  (idx) => setState(() => _flow = idx == 0 ? 'income' : 'expense'),
                ),
                const SizedBox(height: 14),

                // Descrizione
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.get('descLabel'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    if (_isProjected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
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
                  controller: _descController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: _isProjected
                        ? AppStrings.get('descHintProjected')
                        : AppStrings.get('descHintActual'),
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Importo
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
                  ),
                ),
                const SizedBox(height: 14),

                // Categoria e Data in riga responsive
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('category'),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _category,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF1E293B),
                                style: const TextStyle(fontSize: 13, color: Colors.white),
                                items: [
                                  DropdownMenuItem(
                                    value: 'Lavoro',
                                    child: Text(AppStrings.get('categoryJob')),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Casa',
                                    child: Text(AppStrings.get('categoryHome')),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Alimentari',
                                    child: Text(AppStrings.get('categoryFood')),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Bollette',
                                    child: Text(AppStrings.get('categoryBills')),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Svago',
                                    child: Text(AppStrings.get('categoryLeisure')),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Trasporti',
                                    child: Text(AppStrings.get('categoryTransport')),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Altro',
                                    child: Text(AppStrings.get('categoryOther')),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _category = val);
                                },
                              ),
                            ),
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
                            AppStrings.get('date'),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickDate,
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
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 16,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 14),

                // Selettore Ricorrenza
                Text(
                  AppStrings.get('recurrence'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _recurrence,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(AppStrings.get('recurrenceNone')),
                        ),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text(AppStrings.get('weekly')),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text(AppStrings.get('monthly')),
                        ),
                        DropdownMenuItem(
                          value: 'yearly',
                          child: Text(AppStrings.get('yearly')),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => _recurrence = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bottoni d'azione
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF334155)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _clearFields,
                        child: Text(
                          AppStrings.get('clean'),
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: Text(
                          AppStrings.get('save'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _saveTransaction,
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSegmentedControl(
    List<String> options,
    int selectedIdx,
    Function(int) onChange,
  ) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(options.length, (idx) {
          final isSel = idx == selectedIdx;
          final activeColor = _isProjected ? const Color(0xFF0284C7) : const Color(0xFF10B981);

          return Expanded(
            child: InkWell(
              onTap: () => onChange(idx),
              borderRadius: BorderRadius.circular(9),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSel ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  options[idx],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSel ? Colors.white : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _clearFields() {
    _descController.clear();
    _amountController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _category = 'Alimentari';
      _recurrence = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('formCleaned')),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = now.subtract(const Duration(days: 365 * 2));
    // Se è transazione effettiva, blocca la scelta di date future cappa a oggi
    final lastDate = _isProjected ? now.add(const Duration(days: 365 * 2)) : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(lastDate) ? lastDate : _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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

  void _saveTransaction() {
    final desc = _descController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    // Vincolo: Descrizione obbligatoria se effettivo
    if (!_isProjected && desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('descriptionRequiredActual'))),
      );
      return;
    }

    if (amount <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('amountGreaterThanZero'))),
      );
      return;
    }

    // Vincolo temporale di sicurezza
    if (!_isProjected && _selectedDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get('noFutureActual'))),
      );
      return;
    }

    // Auto-compilazione nome per le previsioni se vuote
    final finalDesc = desc.isEmpty && _isProjected
        ? AppStrings.get(
            'defaultForecastName',
            placeholders: {'category': _getLocalCategory(_category)},
          )
        : desc;

    TransactionType finalType = TransactionType.expenseMain;
    if (_flow == 'income') {
      finalType = TransactionType.income;
    } else if (!_isProjected && _destination == 'card') {
      finalType = TransactionType.expenseCard;
    }

    if (widget.editingTransaction != null) {
      final updatedTx = widget.editingTransaction!.copyWith(
        description: finalDesc,
        amount: amount,
        date: _selectedDate,
        category: _category,
        type: finalType,
        isProjected: _isProjected,
        recurrence: _recurrence,
        clearRecurrence: _recurrence == null,
      );
      final success = widget.state.updateTransaction(updatedTx);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Modifica salvata'),
            duration: const Duration(seconds: 1),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      final newTx = Transaction(
        id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
        description: finalDesc,
        amount: amount,
        date: _selectedDate,
        category: _category,
        type: finalType,
        isProjected: _isProjected,
        recurrence: _recurrence,
      );

      final success = widget.state.addTransaction(newTx);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.get('saveSuccess')),
            duration: const Duration(seconds: 1),
          ),
        );
        _clearFields();
        widget.state.changeTab(0); // Ritorna a home
      }
    }
  }
}
