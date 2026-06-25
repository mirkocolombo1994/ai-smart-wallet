import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_data.dart';
import '../models/transaction.dart';

/// Gestore globale dello stato dell'applicazione (MVVM / Controller)
class WalletState extends ChangeNotifier {
  static const String _prefsKey = 'transactions_list';
  static const String _ccStartDayKey = 'cc_start_day';
  static const String _ccPaymentDayKey = 'cc_payment_day';

  int _currentTab = 0;
  int get currentTab => _currentTab;

  int _selectedForecastDays = 30;
  int get selectedForecastDays => _selectedForecastDays;

  String _ledgerFilter = 'all'; // 'all' | 'projected' | 'actual'
  String get ledgerFilter => _ledgerFilter;

  final List<Transaction> _transactions = [];
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  int _ccStartDay = 1;
  int get ccStartDay => _ccStartDay;

  int _ccPaymentDay = 15;
  int get ccPaymentDay => _ccPaymentDay;

  WalletState() {
    _init();
  }

  Future<void> _init() async {
    await _loadFromPrefs();
  }

  void changeTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  void changeForecastDays(int days) {
    _selectedForecastDays = days;
    notifyListeners();
  }

  void changeLedgerFilter(String filter) {
    _ledgerFilter = filter;
    notifyListeners();
  }

  Future<void> changeCreditCardSettings(int startDay, int paymentDay) async {
    _ccStartDay = startDay;
    _ccPaymentDay = paymentDay;
    await _saveToPrefs();
    notifyListeners();
  }

  void _loadInitialMockData() {
    final now = DateTime.now();
    _transactions.addAll(getInitialMockData(now));
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _ccStartDay = prefs.getInt(_ccStartDayKey) ?? 1;
      _ccPaymentDay = prefs.getInt(_ccPaymentDayKey) ?? 15;

      final listString = prefs.getString(_prefsKey);
      if (listString != null && listString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(listString);
        _transactions.clear();
        _transactions.addAll(
          decoded.map((item) => Transaction.fromJson(item as Map<String, dynamic>)),
        );
      } else {
        // Se non c'è nulla in memoria locale, carichiamo il mock
        _loadInitialMockData();
        await _saveToPrefs();
      }
    } catch (e) {
      debugPrint('Errore nel caricamento da SharedPreferences: $e');
      _loadInitialMockData();
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_ccStartDayKey, _ccStartDay);
      await prefs.setInt(_ccPaymentDayKey, _ccPaymentDay);

      final String serialized = jsonEncode(_transactions.map((tx) => tx.toJson()).toList());
      await prefs.setString(_prefsKey, serialized);
    } catch (e) {
      debugPrint('Errore nel salvataggio su SharedPreferences: $e');
    }
  }

  Future<void> resetToMockData() async {
    _transactions.clear();
    _loadInitialMockData();
    await _saveToPrefs();
    notifyListeners();
  }

  bool addTransaction(Transaction tx) {
    // Validazione temporale: transazioni reali non possono essere collocate nel futuro
    if (!tx.isProjected && tx.date.isAfter(DateTime.now())) {
      return false;
    }
    _transactions.add(tx);
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  bool concretizeTransaction(
    String id,
    String newDescription,
    double newAmount,
    DateTime realDate,
    TransactionType targetType,
  ) {
    if (realDate.isAfter(DateTime.now())) {
      return false; // Blocco date future per l'effettivo
    }

    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index != -1) {
      final oldTx = _transactions[index];

      // Se la transazione è ricorrente, creiamo la nuova scadenza futura prima di modificare quella attuale
      if (oldTx.isProjected && oldTx.recurrence != null) {
        DateTime nextDate;
        if (oldTx.recurrence == 'weekly') {
          nextDate = oldTx.date.add(const Duration(days: 7));
        } else if (oldTx.recurrence == 'yearly') {
          nextDate = DateTime(oldTx.date.year + 1, oldTx.date.month, oldTx.date.day);
        } else {
          // Mensile (default o 'monthly')
          nextDate = DateTime(oldTx.date.year, oldTx.date.month + 1, oldTx.date.day);
          // Gestiamo l'overflow dei giorni se il mese successivo ha meno giorni
          if (nextDate.month > (oldTx.date.month == 12 ? 1 : oldTx.date.month + 1)) {
            nextDate = DateTime(oldTx.date.year, oldTx.date.month + 2, 0); // Ultimo giorno del mese corretto
          }
        }

        // Creiamo la transazione futura come proiezione
        final futureTx = Transaction(
          id: 'tx-${DateTime.now().millisecondsSinceEpoch}-next',
          description: oldTx.description,
          amount: oldTx.amount, // mantiene l'importo fisso originario della previsione
          date: nextDate,
          category: oldTx.category,
          type: oldTx.type,
          isProjected: true,
          recurrence: oldTx.recurrence,
        );

        // Aggiungiamo la transazione futura
        _transactions.add(futureTx);
      }

      // Aggiorniamo la transazione corrente rendendola reale
      _transactions[index] = oldTx.copyWith(
        description: newDescription,
        amount: newAmount,
        date: realDate,
        type: targetType,
        isProjected: false, // Diventa transazione reale
        recurrence: null, // Rimuoviamo la ricorrenza dalla transazione reale
      );

      _saveToPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  double get saldoEffettivo {
    double total = 0.0;
    for (var tx in _transactions) {
      if (!tx.isProjected) {
        if (tx.type == TransactionType.income) {
          total += tx.amount;
        } else if (tx.type == TransactionType.expenseMain) {
          total -= tx.amount;
        }
        // Nota: expenseCard è esclusa dal calcolo liquido immediato
      }
    }
    return total;
  }

  double get saldoPrevisto {
    double total = 0.0;
    for (var tx in _transactions) {
      if (tx.isProjected) {
        if (tx.type == TransactionType.income) {
          total += tx.amount;
        } else {
          total -= tx.amount;
        }
      } else {
        if (tx.type == TransactionType.income) {
          total += tx.amount;
        } else if (tx.type == TransactionType.expenseMain) {
          total -= tx.amount;
        }
      }
    }
    return total;
  }

  double get differenzaSaldi => saldoPrevisto - saldoEffettivo;

  /// Helper per calcolare le date di inizio e fine del ciclo di fatturazione della carta di credito per una certa data
  Map<String, DateTime> getCreditCardPeriod(DateTime targetDate) {
    final int s = _ccStartDay;
    DateTime start;
    DateTime end;

    if (targetDate.day >= s) {
      start = DateTime(targetDate.year, targetDate.month, s);
      // Fine del periodo è il giorno prima del giorno S del mese successivo
      end = DateTime(targetDate.year, targetDate.month + 1, s).subtract(const Duration(days: 1));
    } else {
      start = DateTime(targetDate.year, targetDate.month - 1, s);
      end = DateTime(targetDate.year, targetDate.month, s).subtract(const Duration(days: 1));
    }

    return {'start': start, 'end': end};
  }

  /// Somma le spese carta di credito per il periodo di fatturazione corrente
  double get speseCartaCredito {
    final period = getCreditCardPeriod(DateTime.now());
    final start = period['start']!;
    final end = period['end']!;

    double total = 0.0;
    for (var tx in _transactions) {
      if (!tx.isProjected && tx.type == TransactionType.expenseCard) {
        if ((tx.date.isAfter(start) || tx.date.isAtSameMomentAs(start)) &&
            (tx.date.isBefore(end) || tx.date.isAtSameMomentAs(end))) {
          total += tx.amount;
        }
      }
    }
    return total;
  }

  /// Somma le spese carta di credito per un periodo di fatturazione specifico (usato nella proiezione)
  double getCreditCardExpensesForPeriod(DateTime start, DateTime end) {
    double total = 0.0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.expenseCard) {
        if ((tx.date.isAfter(start) || tx.date.isAtSameMomentAs(start)) &&
            (tx.date.isBefore(end) || tx.date.isAtSameMomentAs(end))) {
          total += tx.amount;
        }
      }
    }
    return total;
  }

  /// Genera una linea temporale proiettata giorno per giorno basata su trend e ricorrenze passate
  List<double> calculateForecastTimeline(int daysHorizon) {
    final now = DateTime.now();
    double runningBalance = saldoEffettivo;

    // 1. Identificazione delle ricorrenze fisse
    final Map<String, List<Transaction>> groupHistory = {};
    for (var tx in _transactions) {
      if (!tx.isProjected) {
        final key = '${tx.description.toLowerCase()}_${tx.category}';
        groupHistory.putIfAbsent(key, () => []).add(tx);
      }
    }

    final List<Map<String, dynamic>> recurringRules = [];
    groupHistory.forEach((key, list) {
      list.sort((a, b) => a.date.compareTo(b.date));
      if (list.length >= 2) {
        double sumDiffs = 0;
        for (int i = 1; i < list.length; i++) {
          sumDiffs += list[i].date.difference(list[i - 1].date).inDays;
        }
        final avgInterval = sumDiffs / (list.length - 1);

        // Se si ripete circa ogni 25-35 giorni (mensile) o 5-9 giorni (settimanale)
        if ((avgInterval >= 25 && avgInterval <= 35) || (avgInterval >= 5 && avgInterval <= 9)) {
          final lastTx = list.last;
          recurringRules.add({
            'description': lastTx.description,
            'amount': lastTx.amount,
            'type': lastTx.type,
            'intervalDays': avgInterval.round(),
            'lastDate': lastTx.date,
          });
        }
      }
    });

    // 2. Trend delle spese volatili (non fisse) negli ultimi 30 giorni
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    double totalVolatileExpenses = 0.0;

    for (var tx in _transactions) {
      if (!tx.isProjected && tx.type == TransactionType.expenseMain && tx.date.isAfter(thirtyDaysAgo)) {
        final isRecurring = recurringRules.any(
          (r) => r['description'].toString().toLowerCase() == tx.description.toLowerCase(),
        );
        if (!isRecurring) {
          totalVolatileExpenses += tx.amount;
        }
      }
    }
    final dailyVolatileAverageSpend = totalVolatileExpenses / 30.0;

    // 3. Simulazione predittiva
    final List<double> timelinePoints = [];

    // Raccoglie eventi pianificati futuri (ricorrenze stimate + proiezioni utente)
    final List<Map<String, dynamic>> futureEvents = [];
    for (int day = 1; day <= daysHorizon; day++) {
      final simDate = now.add(Duration(days: day));

      // Ricorrenze calcolate dall'AI
      for (var rule in recurringRules) {
        final daysSinceLast = simDate.difference(rule['lastDate'] as DateTime).inDays;
        if (daysSinceLast % (rule['intervalDays'] as int) == 0) {
          futureEvents.add({
            'date': simDate,
            'amount': rule['amount'] as double,
            'type': rule['type'] as TransactionType,
          });
        }
      }

      // Previsioni inserite manualmente
      for (var tx in _transactions) {
        if (tx.isProjected &&
            tx.date.year == simDate.year &&
            tx.date.month == simDate.month &&
            tx.date.day == simDate.day) {
          futureEvents.add({
            'date': simDate,
            'amount': tx.amount,
            'type': tx.type,
          });
        }
      }

      // Addebito carta di credito automatico proiettato al giorno ccPaymentDay
      if (simDate.day == _ccPaymentDay) {
        // Controlliamo se esiste già un addebito manuale per la carta in questo giorno
        bool hasManualCcPayment = _transactions.any((tx) =>
            tx.date.year == simDate.year &&
            tx.date.month == simDate.month &&
            tx.date.day == simDate.day &&
            tx.type == TransactionType.expenseMain &&
            (tx.description.toLowerCase().contains('cc.') ||
                tx.description.toLowerCase().contains('carta')));

        if (!hasManualCcPayment) {
          // Andiamo al giorno 28 del mese precedente per calcolare il periodo di fatturazione corretto
          final previousMonthDate = DateTime(simDate.year, simDate.month - 1, 28);
          final ccPeriod = getCreditCardPeriod(previousMonthDate);
          final ccExpenses = getCreditCardExpensesForPeriod(
            ccPeriod['start']!,
            ccPeriod['end']!,
          );
          if (ccExpenses > 0) {
            futureEvents.add({
              'date': simDate,
              'amount': ccExpenses,
              'type': TransactionType.expenseMain,
            });
          }
        }
      }
    }

    // Proietta il bilancio giorno per giorno
    for (int day = 1; day <= daysHorizon; day++) {
      final simDate = now.add(Duration(days: day));

      // Decadimento naturale per spese volatili giornaliere
      runningBalance -= dailyVolatileAverageSpend;

      // Applica transazioni strutturate pianificate per questo giorno
      for (var evt in futureEvents) {
        final eDate = evt['date'] as DateTime;
        if (eDate.year == simDate.year && eDate.month == simDate.month && eDate.day == simDate.day) {
          if (evt['type'] == TransactionType.income) {
            runningBalance += evt['amount'] as double;
          } else if (evt['type'] == TransactionType.expenseMain) {
            runningBalance -= evt['amount'] as double;
          }
        }
      }
      timelinePoints.add(runningBalance);
    }

    return timelinePoints;
  }
}
