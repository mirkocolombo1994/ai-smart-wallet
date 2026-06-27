import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_data.dart';
import '../models/transaction.dart';
import '../models/savings_goal.dart';
import '../constants/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';

/// Gestore globale dello stato dell'applicazione (MVVM / Controller)
class WalletState extends ChangeNotifier {
  static const String _prefsKey = 'transactions_list';
  static const String _ccStartDayKey = 'cc_start_day';
  static const String _ccPaymentDayKey = 'cc_payment_day';
  static const String _languageKey = 'app_language';

  int _currentTab = 0;
  int get currentTab => _currentTab;

  int _selectedForecastDays = 30;
  int get selectedForecastDays => _selectedForecastDays;

  String _ledgerFilter = 'all'; // 'all' | 'projected' | 'actual'
  String get ledgerFilter => _ledgerFilter;

  final List<Transaction> _transactions = [];
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  final List<SavingsGoal> _savingsGoals = [];
  List<SavingsGoal> get savingsGoals => List.unmodifiable(_savingsGoals);

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

  Future<void> changeLanguage(AppLanguage lang) async {
    AppStrings.currentLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, lang == AppLanguage.en ? 'en' : 'it');
    notifyListeners();
  }

  Future<void> deleteAllData() async {
    _transactions.clear();
    _savingsGoals.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    await prefs.remove('savings_goals');
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
    }
    
    notifyListeners();
  }

  Future<void> changeCreditCardSettings(int startDay, int paymentDay) async {
    _ccStartDay = startDay;
    _ccPaymentDay = paymentDay;
    await _saveToPrefs();
    notifyListeners();
  }

  void _loadInitialMockData() {
    // Mock data rimosso per permettere l'utilizzo reale senza dati finti iniziali.
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _ccStartDay = prefs.getInt(_ccStartDayKey) ?? 1;
      _ccPaymentDay = prefs.getInt(_ccPaymentDayKey) ?? 15;
      
      final savedLang = prefs.getString(_languageKey);
      if (savedLang == 'en') {
        AppStrings.currentLanguage = AppLanguage.en;
      } else {
        AppStrings.currentLanguage = AppLanguage.it;
      }

      final listString = prefs.getString(_prefsKey);
      if (listString != null && listString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(listString);
        _transactions.clear();
        _transactions.addAll(
          decoded.map((item) => Transaction.fromJson(item as Map<String, dynamic>)),
        );
      } else {
        _loadInitialMockData();
      }

      final goalsString = prefs.getString('savings_goals');
      if (goalsString != null && goalsString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(goalsString);
        _savingsGoals.clear();
        _savingsGoals.addAll(
          decoded.map((item) => SavingsGoal.fromJson(item as Map<String, dynamic>)),
        );
      }

      // Try to sync with Firebase if logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          if (data['transactions'] != null) {
             final List<dynamic> fbTxs = data['transactions'];
             _transactions.clear();
             _transactions.addAll(fbTxs.map((item) => Transaction.fromJson(item as Map<String, dynamic>)));
          }
          if (data['savingsGoals'] != null) {
             final List<dynamic> fbGoals = data['savingsGoals'];
             _savingsGoals.clear();
             _savingsGoals.addAll(fbGoals.map((item) => SavingsGoal.fromJson(item as Map<String, dynamic>)));
          }
        }
      }

      // save back to sync prefs and possible new data from mock
      await _saveToPrefs();

    } catch (e) {
      debugPrint('Errore nel caricamento: $e');
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
      
      final String serializedGoals = jsonEncode(_savingsGoals.map((g) => g.toJson()).toList());
      await prefs.setString('savings_goals', serializedGoals);

      // Sync with Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'transactions': _transactions.map((tx) => tx.toJson()).toList(),
          'savingsGoals': _savingsGoals.map((g) => g.toJson()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Errore nel salvataggio su SharedPreferences: $e');
    }
  }

  Future<void> resetToMockData() async {
    _transactions.clear();
    await _saveToPrefs();
    notifyListeners();
  }

  String? addTransaction(Transaction tx) {
    // Validazione temporale: transazioni reali non possono essere collocate nel futuro
    if (!tx.isProjected && tx.date.isAfter(DateTime.now())) {
      return null; // Failure
    }
    _transactions.add(tx);
    _saveToPrefs();
    notifyListeners();
    
    // Rilevamento ricorrenze
    if (!tx.isProjected && (tx.recurrence == null || tx.recurrence!.isEmpty)) {
      int count = 0;
      for (var existing in _transactions) {
        if (!existing.isProjected && 
            existing.description.toLowerCase().trim() == tx.description.toLowerCase().trim() && 
            existing.amount == tx.amount &&
            (existing.recurrence == null || existing.recurrence!.isEmpty)) {
          count++;
        }
      }
      if (count >= 3) {
        return "RECURRING:${tx.description}"; // Rilevato pattern!
      }
    }
    return "SUCCESS";
  }

  void makeTransactionsRecurring(String description, String recurrence) {
    for (int i = 0; i < _transactions.length; i++) {
      if (!_transactions[i].isProjected && 
          _transactions[i].description.toLowerCase().trim() == description.toLowerCase().trim()) {
        _transactions[i] = _transactions[i].copyWith(recurrence: recurrence);
      }
    }
    _saveToPrefs();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  bool updateTransaction(Transaction updatedTx) {
    final index = _transactions.indexWhere((tx) => tx.id == updatedTx.id);
    if (index != -1) {
      _transactions[index] = updatedTx;
      _saveToPrefs();
      notifyListeners();
      return true;
    }
    return false;
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

      // Creiamo la transazione reale
      final realTx = Transaction(
        id: 'tx-${DateTime.now().millisecondsSinceEpoch}-real',
        description: newDescription,
        amount: newAmount,
        date: realDate,
        category: oldTx.category,
        type: targetType,
        isProjected: false, // Diventa transazione reale
      );
      _transactions.add(realTx);

      // Aggiorniamo la transazione corrente (previsione)
      _transactions[index] = oldTx.copyWith(
        associatedTransactionId: realTx.id, // Colleghiamo alla reale
        clearRecurrence: true, // Rimuoviamo la ricorrenza dalla transazione prevista
      );

      _saveToPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }

  // ----- NUOVE METRICHE DASHBOARD -----

  double get saldoEffettivoOdierno {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    double total = 0.0;
    for (var tx in _transactions) {
      if (!tx.isProjected && tx.date.isBefore(todayEnd)) {
        if (tx.type == TransactionType.income) {
          total += tx.amount;
        } else if (tx.type == TransactionType.expenseMain) {
          total -= tx.amount;
        }
      }
    }
    return total;
  }

  double get saldoPrevistoOdierno {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    double total = 0.0;
    for (var tx in _transactions) {
      if (tx.date.isBefore(todayEnd)) {
        if (tx.isProjected) {
          if (tx.type == TransactionType.income) {
            total += tx.amount;
          } else if (tx.type == TransactionType.expenseMain || tx.type == TransactionType.expenseCard) {
            total -= tx.amount;
          }
        }
      }
    }
    return total;
  }

  double get differenzaSaldiOdierna {
    return saldoEffettivoOdierno - saldoPrevistoOdierno;
  }

  // Supporto retro-compatibilità ove usato
  double get saldoEffettivo => saldoEffettivoOdierno;
  double get saldoPrevisto => saldoPrevistoOdierno;
  double get differenzaSaldi => differenzaSaldiOdierna;
  double get differenzaFinoAdOggi => differenzaSaldiOdierna;

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
  double get speseCartaCreditoMeseCorrente {
    final period = getCreditCardPeriod(DateTime.now());
    return getCreditCardExpensesForPeriod(period['start']!, period['end']!);
  }

  double get speseCartaCreditoMesePrecedente {
    // Il mese precedente si ottiene andando indietro di un mese dalla data odierna, o prendendo la data "start" - 1 giorno.
    final period = getCreditCardPeriod(DateTime.now());
    final prevPeriod = getCreditCardPeriod(period['start']!.subtract(const Duration(days: 1)));
    return getCreditCardExpensesForPeriod(prevPeriod['start']!, prevPeriod['end']!);
  }

  // Retro-compatibilità
  double get speseCartaCredito => speseCartaCreditoMeseCorrente;

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

  // ----- SAVINGS GOALS METHODS -----

  bool addSavingsGoal(SavingsGoal goal) {
    _savingsGoals.add(goal);
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  void deleteSavingsGoal(String id) {
    _savingsGoals.removeWhere((g) => g.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  bool updateSavingsGoal(SavingsGoal updatedGoal) {
    final index = _savingsGoals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _savingsGoals[index] = updatedGoal;
      _saveToPrefs();
      notifyListeners();
      return true;
    }
    return false;
  }
}

