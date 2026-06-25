import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_smart_wallet/state/wallet_state.dart';
import 'package:ai_smart_wallet/models/transaction.dart';

void main() {
  // Configurazione globale per i test di SharedPreferences
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WalletState Core Tests', () {
    test('Initializes with default settings and loads mock data if empty', () async {
      final state = WalletState();
      // Aspettiamo che l'inizializzazione asincrona finisca
      await Future.delayed(Duration.zero);

      expect(state.currentTab, 0);
      expect(state.selectedForecastDays, 30);
      expect(state.ledgerFilter, 'all');
      expect(state.ccStartDay, 1);
      expect(state.ccPaymentDay, 15);
      expect(state.transactions.isNotEmpty, true);
    });

    test('Changes tabs, forecast days, and filters', () {
      final state = WalletState();

      state.changeTab(1);
      expect(state.currentTab, 1);

      state.changeForecastDays(60);
      expect(state.selectedForecastDays, 60);

      state.changeLedgerFilter('projected');
      expect(state.ledgerFilter, 'projected');
    });

    test('Updates credit card settings', () async {
      final state = WalletState();
      await Future.delayed(Duration.zero);

      await state.changeCreditCardSettings(5, 20);
      expect(state.ccStartDay, 5);
      expect(state.ccPaymentDay, 20);

      // Verifica che persista in memoria
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('cc_start_day'), 5);
      expect(prefs.getInt('cc_payment_day'), 20);
    });
  });

  group('WalletState Transaction Operations', () {
    test('Adds and deletes transactions correctly', () async {
      final state = WalletState();
      await Future.delayed(Duration.zero);

      final initialCount = state.transactions.length;

      final realTx = Transaction(
        id: 'new-1',
        description: 'Spesa reale',
        amount: 25.50,
        date: DateTime.now().subtract(const Duration(minutes: 5)),
        category: 'Spese',
        type: TransactionType.expenseMain,
        isProjected: false,
      );

      final added = state.addTransaction(realTx);
      expect(added, true);
      expect(state.transactions.length, initialCount + 1);

      state.deleteTransaction('new-1');
      expect(state.transactions.length, initialCount);
    });

    test('Rejects future real transactions', () async {
      final state = WalletState();
      await Future.delayed(Duration.zero);

      final futureRealTx = Transaction(
        id: 'future-real',
        description: 'Spesa reale futura errata',
        amount: 100.0,
        date: DateTime.now().add(const Duration(days: 2)),
        category: 'Altro',
        type: TransactionType.expenseMain,
        isProjected: false,
      );

      final added = state.addTransaction(futureRealTx);
      expect(added, false);
    });

    test('Allows future projected transactions', () async {
      final state = WalletState();
      await Future.delayed(Duration.zero);

      final futureProjectedTx = Transaction(
        id: 'future-proj',
        description: 'Spesa prevista futura',
        amount: 100.0,
        date: DateTime.now().add(const Duration(days: 2)),
        category: 'Altro',
        type: TransactionType.expenseMain,
        isProjected: true,
      );

      final added = state.addTransaction(futureProjectedTx);
      expect(added, true);
    });
  });

  group('WalletState Calculations & Forecasts', () {
    test('Calculates saldoEffettivo and saldoPrevisto correctly', () async {
      // Inizializziamo con lista vuota per fare calcoli precisi
      SharedPreferences.setMockInitialValues({'transactions_list': '[]'});

      final state = WalletState();
      await Future.delayed(Duration.zero);

      expect(state.saldoEffettivo, 0.0);
      expect(state.saldoPrevisto, 0.0);

      // Aggiungiamo un'entrata reale
      state.addTransaction(Transaction(
        id: 'in-1',
        description: 'Stipendio',
        amount: 2000.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Entrate',
        type: TransactionType.income,
        isProjected: false,
      ));

      // Aggiungiamo una spesa reale
      state.addTransaction(Transaction(
        id: 'ex-1',
        description: 'Spesa principale',
        amount: 500.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Spese',
        type: TransactionType.expenseMain,
        isProjected: false,
      ));

      // Aggiungiamo una spesa carta di credito (non influenza saldoEffettivo ma previsto sì)
      state.addTransaction(Transaction(
        id: 'cc-1',
        description: 'Spesa carta',
        amount: 300.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Spese',
        type: TransactionType.expenseCard,
        isProjected: false,
      ));

      // Aggiungiamo una previsione futura
      state.addTransaction(Transaction(
        id: 'proj-1',
        description: 'Previsto futuro',
        amount: 200.0,
        date: DateTime.now().add(const Duration(days: 2)),
        category: 'Spese',
        type: TransactionType.expenseMain,
        isProjected: true,
      ));

      expect(state.saldoEffettivo, 1500.0); // 2000 - 500
      expect(state.saldoPrevisto, 1300.0); // 1500 - 200 (la spesa carta non influisce immediatamente sul previsto in base all'algoritmo attuale, o meglio: saldoPrevisto esegue income - expenses per i proiettati. Controlliamo wallet_state.dart:207)
      // Nel codice:
      // saldoPrevisto somma income e sottrae expense (sia main che card) per i proiettati. E per i reali sottrae solo expenseMain.
      // Vediamo:
      // Real:
      // - income 2000
      // - expenseMain 500
      // - expenseCard 300 (isProjected: false) -> non viene toccato da saldoPrevisto (saldoPrevisto riga 219: else: type == expenseMain)
      // Projected:
      // - expenseMain 200 (isProjected: true) -> viene sottratto
      // Quindi previsto = 2000 - 500 - 200 = 1300.0
      expect(state.differenzaSaldi, -200.0);
    });

    test('Concretize transaction with weekly recurrence', () async {
      SharedPreferences.setMockInitialValues({'transactions_list': '[]'});
      final state = WalletState();
      await Future.delayed(Duration.zero);

      final initialDate = DateTime.now().add(const Duration(days: 1));

      // Transazione prevista ricorrente
      final projTx = Transaction(
        id: 'recur-1',
        description: 'Abbonamento ricorrente',
        amount: 10.0,
        date: initialDate,
        category: 'Servizi',
        type: TransactionType.expenseMain,
        isProjected: true,
        recurrence: 'weekly',
      );

      state.addTransaction(projTx);
      expect(state.transactions.length, 1);

      // Concretizziamo
      final success = state.concretizeTransaction(
        'recur-1',
        'Abbonamento Pagato',
        12.0,
        DateTime.now().subtract(const Duration(minutes: 1)),
        TransactionType.expenseMain,
      );

      expect(success, true);
      // Ora ci dovrebbero essere 2 transazioni: quella concretizzata (isProjected: false, recurrence: null)
      // e la nuova scadenza proiettata a +7 giorni
      expect(state.transactions.length, 2);

      final concretized = state.transactions.firstWhere((tx) => !tx.isProjected);
      expect(concretized.description, 'Abbonamento Pagato');
      expect(concretized.amount, 12.0);
      expect(concretized.recurrence, null);

      final nextScheduled = state.transactions.firstWhere((tx) => tx.isProjected);
      expect(nextScheduled.recurrence, 'weekly');
      expect(nextScheduled.amount, 10.0); // mantiene importo stimato originario
      expect(nextScheduled.date.difference(initialDate).inDays, 7);
    });

    test('Calculates forecast timeline', () async {
      final state = WalletState();
      await Future.delayed(Duration.zero);

      final timeline = state.calculateForecastTimeline(30);
      expect(timeline.length, 30);
    });
  });
}
