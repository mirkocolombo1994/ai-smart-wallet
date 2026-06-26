enum AppLanguage { it, en }

class AppStrings {
  static AppLanguage currentLanguage = AppLanguage.it;

  static const Map<String, Map<AppLanguage, String>> _localizedValues = {
    'appTitle': {
      AppLanguage.it: 'Smart Wallet AI',
      AppLanguage.en: 'Smart Wallet AI',
    },
    'welcome': {
      AppLanguage.it: 'Benvenuto in',
      AppLanguage.en: 'Welcome to',
    },
    'smartWallet': {
      AppLanguage.it: 'Smart Wallet',
      AppLanguage.en: 'Smart Wallet',
    },
    'ai': {
      AppLanguage.it: 'AI',
      AppLanguage.en: 'AI',
    },
    'resetSuccess': {
      AppLanguage.it: 'Dati ripristinati allo stato iniziale!',
      AppLanguage.en: 'Data reset to initial state!',
    },
    'actualBalance': {
      AppLanguage.it: 'Saldo Effettivo',
      AppLanguage.en: 'Actual Balance',
    },
    'actualBalanceWithDate': {
      AppLanguage.it: 'Saldo Effettivo (aggiornato al {date})',
      AppLanguage.en: 'Actual Balance (updated to {date})',
    },
    'liquidAccount': {
      AppLanguage.it: 'Conto Liquido',
      AppLanguage.en: 'Liquid Account',
    },
    'forecastBalance': {
      AppLanguage.it: 'Saldo Previsto',
      AppLanguage.en: 'Forecast Balance',
    },
    'forecastBalanceWithDate': {
      AppLanguage.it: 'Saldo Previsto (proiettato al {date})',
      AppLanguage.en: 'Forecast Balance (projected to {date})',
    },
    'insertedProjection': {
      AppLanguage.it: 'Proiezione Inserita',
      AppLanguage.en: 'Inserted Projection',
    },
    'balanceDiff': {
      AppLanguage.it: 'Differenza Saldi',
      AppLanguage.en: 'Balances Difference',
    },
    'creditCardExpenses': {
      AppLanguage.it: 'Spese Carta Credito',
      AppLanguage.en: 'Credit Card Expenses',
    },
    'creditCardExpensesRange': {
      AppLanguage.it: 'Spese Carta ({start} - {end})',
      AppLanguage.en: 'Card Expenses ({start} - {end})',
    },
    'aiBalanceForecast': {
      AppLanguage.it: 'PREVISIONE AI SALDO',
      AppLanguage.en: 'AI BALANCE FORECAST',
    },
    'days30': {
      AppLanguage.it: '30 Giorni',
      AppLanguage.en: '30 Days',
    },
    'months3': {
      AppLanguage.it: '3 Mesi',
      AppLanguage.en: '3 Months',
    },
    'months6': {
      AppLanguage.it: '6 Mesi',
      AppLanguage.en: '6 Months',
    },
    'finalBalanceEstimate': {
      AppLanguage.it: 'Stima Saldo Finale:',
      AppLanguage.en: 'Final Balance Estimate:',
    },
    'lastMovements': {
      AppLanguage.it: 'ULTIMI MOVIMENTI',
      AppLanguage.en: 'LAST TRANSACTIONS',
    },
    'actualMovementsHeader': {
      AppLanguage.it: 'MOVIMENTI EFFETTIVI',
      AppLanguage.en: 'ACTUAL TRANSACTIONS',
    },
    'forecastMovementsHeader': {
      AppLanguage.it: 'SCADENZE E PREVISIONI (30 GG)',
      AppLanguage.en: 'UPCOMING FORECASTS (30 DAYS)',
    },
    'seeAll': {
      AppLanguage.it: 'Vedi tutti',
      AppLanguage.en: 'See all',
    },
    'feasibilityTitle': {
      AppLanguage.it: 'Analisi Fattibilità Spesa',
      AppLanguage.en: 'Expense Feasibility Analysis',
    },
    'feasibilityDesc': {
      AppLanguage.it: 'Verifica l\'impatto finanziario di un nuovo acquisto o abbonamento pianificato.',
      AppLanguage.en: 'Verify the financial impact of a new planned purchase or subscription.',
    },
    'expenseServiceName': {
      AppLanguage.it: 'Nome Spesa / Servizio',
      AppLanguage.en: 'Expense / Service Name',
    },
    'optional': {
      AppLanguage.it: 'Opzionale',
      AppLanguage.en: 'Optional',
    },
    'exampleExpense': {
      AppLanguage.it: 'Es. MacBook Pro, Palestra',
      AppLanguage.en: 'e.g. MacBook Pro, Gym',
    },
    'amountEuro': {
      AppLanguage.it: 'Importo (€)',
      AppLanguage.en: 'Amount (€)',
    },
    'expenseFrequency': {
      AppLanguage.it: 'Frequenza Spesa',
      AppLanguage.en: 'Expense Frequency',
    },
    'single': {
      AppLanguage.it: 'Singola',
      AppLanguage.en: 'One-time',
    },
    'monthly': {
      AppLanguage.it: 'Mensile',
      AppLanguage.en: 'Monthly',
    },
    'yearly': {
      AppLanguage.it: 'Annuale',
      AppLanguage.en: 'Yearly',
    },
    'weekly': {
      AppLanguage.it: 'Settimanale',
      AppLanguage.en: 'Weekly',
    },
    'analyzeButton': {
      AppLanguage.it: 'Analizza Fattibilità Spesa',
      AppLanguage.en: 'Analyze Expense Feasibility',
    },
    'validAmountError': {
      AppLanguage.it: 'Inserisci un importo valido!',
      AppLanguage.en: 'Please enter a valid amount!',
    },
    'evaluationResult': {
      AppLanguage.it: 'Esito Valutazione',
      AppLanguage.en: 'Evaluation Outcome',
    },
    'forecastBudgetAnalysis': {
      AppLanguage.it: 'ANALISI BUDGET PREVISTO',
      AppLanguage.en: 'FORECAST BUDGET ANALYSIS',
    },
    'currentMonthImpact': {
      AppLanguage.it: 'Impatto sul mese corrente:',
      AppLanguage.en: 'Impact on current month:',
    },
    'newBalance': {
      AppLanguage.it: 'Nuovo saldo: ',
      AppLanguage.en: 'New balance: ',
    },
    'nextMonthImpact': {
      AppLanguage.it: 'Impatto sul mese successivo:',
      AppLanguage.en: 'Impact on next month:',
    },
    'recommendedSafetyThreshold': {
      AppLanguage.it: 'Soglia di Sicurezza Consigliata:',
      AppLanguage.en: 'Recommended Safety Threshold:',
    },
    'aiStrategicAdvice': {
      AppLanguage.it: 'Consiglio Strategico AI:',
      AppLanguage.en: 'AI Strategic Advice:',
    },
    'statusRed': {
      AppLanguage.it: 'Acquisto Sconsigliato! Rischio di scoperto',
      AppLanguage.en: 'Purchase Not Recommended! Risk of overdraft',
    },
    'statusYellow': {
      AppLanguage.it: 'Fattibile con Cautela (Budget Stretto)',
      AppLanguage.en: 'Feasible with Caution (Tight Budget)',
    },
    'statusGreen': {
      AppLanguage.it: 'Spesa Sostenibile con Facilità!',
      AppLanguage.en: 'Easily Sustainable Expense!',
    },
    'adviceRed': {
      AppLanguage.it: 'L\'acquisto di "{name}" rischia di portare il tuo conto principale sotto lo zero. Ti consigliamo di rimandare questa spesa di almeno 2 mesi, oppure di ridurre le tue spese quotidiane volatili.',
      AppLanguage.en: 'Purchasing "{name}" risks driving your main account below zero. We recommend postponing this expense by at least 2 months, or reducing your daily volatile expenses.',
    },
    'adviceYellow': {
      AppLanguage.it: 'Puoi sostenere "{name}", ma il tuo saldo scenderà sotto la soglia di sicurezza minima consigliata di {threshold}. Se decidi di procedere, riduci le spese variabili per questo periodo.',
      AppLanguage.en: 'You can afford "{name}", but your balance will drop below the recommended safety threshold of {threshold}. If you decide to proceed, reduce variable expenses for this period.',
    },
    'adviceGreen': {
      AppLanguage.it: 'Ottime notizie! Il tuo flusso di cassa e le tue entrate ricorrenti coprono ampiamente la spesa per "{name}". Puoi procedere tranquillamente senza intaccare i tuoi risparmi.',
      AppLanguage.en: 'Great news! Your cash flow and recurring income easily cover the expense for "{name}". You can proceed safely without impacting your savings.',
    },
    'addMovement': {
      AppLanguage.it: 'Aggiungi Movimento',
      AppLanguage.en: 'Add Transaction',
    },
    'stateType': {
      AppLanguage.it: 'Tipo Stato',
      AppLanguage.en: 'Status Type',
    },
    'forecast': {
      AppLanguage.it: 'Previsione',
      AppLanguage.en: 'Forecast',
    },
    'actual': {
      AppLanguage.it: 'Effettivo',
      AppLanguage.en: 'Actual',
    },
    'accountCreditCard': {
      AppLanguage.it: 'Conto / Carta di Credito',
      AppLanguage.en: 'Account / Credit Card',
    },
    'mainAccount': {
      AppLanguage.it: 'Conto Principale',
      AppLanguage.en: 'Main Account',
    },
    'creditCard': {
      AppLanguage.it: 'Carta Credito',
      AppLanguage.en: 'Credit Card',
    },
    'flow': {
      AppLanguage.it: 'Flusso',
      AppLanguage.en: 'Flow',
    },
    'income': {
      AppLanguage.it: 'Entrata',
      AppLanguage.en: 'Income',
    },
    'expense': {
      AppLanguage.it: 'Spesa',
      AppLanguage.en: 'Expense',
    },
    'descHintProjected': {
      AppLanguage.it: 'Previsione auto-nominata se vuota',
      AppLanguage.en: 'Auto-named forecast if left empty',
    },
    'descHintActual': {
      AppLanguage.it: 'Es. Spesa Supermercato, Stipendio',
      AppLanguage.en: 'e.g. Supermarket, Salary',
    },
    'descLabel': {
      AppLanguage.it: 'Descrizione',
      AppLanguage.en: 'Description',
    },
    'category': {
      AppLanguage.it: 'Categoria',
      AppLanguage.en: 'Category',
    },
    'date': {
      AppLanguage.it: 'Data',
      AppLanguage.en: 'Date',
    },
    'clean': {
      AppLanguage.it: 'Pulisci',
      AppLanguage.en: 'Clear',
    },
    'save': {
      AppLanguage.it: 'Salva',
      AppLanguage.en: 'Save',
    },
    'categoryJob': {
      AppLanguage.it: 'Lavoro',
      AppLanguage.en: 'Work',
    },
    'categoryHome': {
      AppLanguage.it: 'Casa',
      AppLanguage.en: 'Home',
    },
    'categoryFood': {
      AppLanguage.it: 'Alimentari',
      AppLanguage.en: 'Groceries',
    },
    'categoryBills': {
      AppLanguage.it: 'Bollette',
      AppLanguage.en: 'Bills',
    },
    'categoryLeisure': {
      AppLanguage.it: 'Svago',
      AppLanguage.en: 'Leisure',
    },
    'categoryTransport': {
      AppLanguage.it: 'Trasporti',
      AppLanguage.en: 'Transport',
    },
    'categoryOther': {
      AppLanguage.it: 'Altro',
      AppLanguage.en: 'Other',
    },
    'formCleaned': {
      AppLanguage.it: 'Form ripulita!',
      AppLanguage.en: 'Form cleared!',
    },
    'descriptionRequiredActual': {
      AppLanguage.it: 'Inserisci una descrizione valida per il movimento reale!',
      AppLanguage.en: 'Please enter a valid description for the actual transaction!',
    },
    'amountGreaterThanZero': {
      AppLanguage.it: 'L\'importo deve essere maggiore di zero!',
      AppLanguage.en: 'Amount must be greater than zero!',
    },
    'noFutureActual': {
      AppLanguage.it: 'Errore di integrità: Non puoi collocare transazioni effettive nel futuro!',
      AppLanguage.en: 'Integrity Error: You cannot place actual transactions in the future!',
    },
    'saveSuccess': {
      AppLanguage.it: 'Movimento salvato con successo!',
      AppLanguage.en: 'Transaction saved successfully!',
    },
    'ledgerTitle': {
      AppLanguage.it: 'Registro Movimenti',
      AppLanguage.en: 'Transaction Ledger',
    },
    'chipAll': {
      AppLanguage.it: 'Tutti',
      AppLanguage.en: 'All',
    },
    'chipForecast': {
      AppLanguage.it: 'Previsti',
      AppLanguage.en: 'Forecasts',
    },
    'chipActual': {
      AppLanguage.it: 'Effettivi',
      AppLanguage.en: 'Actuals',
    },
    'noTransactions': {
      AppLanguage.it: 'Nessuna transazione registrata',
      AppLanguage.en: 'No transactions recorded',
    },
    'noForecastTransactions': {
      AppLanguage.it: 'Nessuna scadenza prevista nei prossimi 30 giorni',
      AppLanguage.en: 'No forecasts projected in the next 30 days',
    },
    'labelPrev': {
      AppLanguage.it: 'PREV',
      AppLanguage.en: 'FORECAST',
    },
    'labelCard': {
      AppLanguage.it: 'CARTA',
      AppLanguage.en: 'CARD',
    },
    'concretizeForecast': {
      AppLanguage.it: 'Concretizza Previsione',
      AppLanguage.en: 'Realize Forecast',
    },
    'concretizeDesc': {
      AppLanguage.it: 'Inserisci i dati reali per registrare la spesa effettiva avvenuta.',
      AppLanguage.en: 'Enter actual data to record the occurred real transaction.',
    },
    'concretizeName': {
      AppLanguage.it: 'Nome / Descrizione',
      AppLanguage.en: 'Name / Description',
    },
    'concretizeDate': {
      AppLanguage.it: 'Data Pagamento Effettivo',
      AppLanguage.en: 'Actual Payment Date',
    },
    'concretizeAccount': {
      AppLanguage.it: 'Conto Addebito',
      AppLanguage.en: 'Debit Account',
    },
    'cancel': {
      AppLanguage.it: 'Annulla',
      AppLanguage.en: 'Cancel',
    },
    'confirm': {
      AppLanguage.it: 'Conferma',
      AppLanguage.en: 'Confirm',
    },
    'validationName': {
      AppLanguage.it: 'Inserisci un nome valido!',
      AppLanguage.en: 'Please enter a valid name!',
    },
    'validationAmount': {
      AppLanguage.it: 'Inserisci un importo valido!',
      AppLanguage.en: 'Please enter a valid amount!',
    },
    'validationFutureDate': {
      AppLanguage.it: 'La data effettiva non può essere nel futuro!',
      AppLanguage.en: 'The actual date cannot be in the future!',
    },
    'concretizeSuccess': {
      AppLanguage.it: 'Previsione concretizzata con successo!',
      AppLanguage.en: 'Forecast realized successfully!',
    },
    'navHome': {
      AppLanguage.it: 'Home',
      AppLanguage.en: 'Home',
    },
    'navFeasibility': {
      AppLanguage.it: 'Fattibilità',
      AppLanguage.en: 'Feasibility',
    },
    'navLedger': {
      AppLanguage.it: 'Registro',
      AppLanguage.en: 'Ledger',
    },
    'defaultForecastName': {
      AppLanguage.it: 'Previsione {category}',
      AppLanguage.en: 'Forecast {category}',
    },
    'defaultSimName': {
      AppLanguage.it: 'Acquisto simulato',
      AppLanguage.en: 'Simulated purchase',
    },
    'recurrence': {
      AppLanguage.it: 'Ricorrenza',
      AppLanguage.en: 'Recurrence',
    },
    'recurrenceNone': {
      AppLanguage.it: 'Nessuna',
      AppLanguage.en: 'None',
    },
    'creditCardSettingsTitle': {
      AppLanguage.it: 'Impostazioni Carta di Credito',
      AppLanguage.en: 'Credit Card Settings',
    },
    'ccCycleStartDay': {
      AppLanguage.it: 'Inizio Ciclo (Giorno)',
      AppLanguage.en: 'Cycle Start (Day)',
    },
    'ccPaymentDay': {
      AppLanguage.it: 'Addebito (Giorno del mese successivo)',
      AppLanguage.en: 'Debit (Day of next month)',
    },
    'saveSettings': {
      AppLanguage.it: 'Salva Impostazioni',
      AppLanguage.en: 'Save Settings',
    },
    'settingsSaved': {
      AppLanguage.it: 'Impostazioni carta aggiornate!',
      AppLanguage.en: 'Card settings updated!',
    },
    'isRecurringAlert': {
      AppLanguage.it: 'Questo movimento fa parte di una serie ricorrente.',
      AppLanguage.en: 'This transaction is part of a recurring series.',
    },
    'settings': {
      AppLanguage.it: 'Impostazioni',
      AppLanguage.en: 'Settings',
    },
    'language': {
      AppLanguage.it: 'Lingua',
      AppLanguage.en: 'Language',
    },
    'dangerZone': {
      AppLanguage.it: 'Area Pericolosa',
      AppLanguage.en: 'Danger Zone',
    },
    'deleteAllData': {
      AppLanguage.it: 'Elimina tutti i dati',
      AppLanguage.en: 'Delete all data',
    },
    'deleteAllDataConfirmTitle': {
      AppLanguage.it: 'Attenzione',
      AppLanguage.en: 'Warning',
    },
    'deleteAllDataConfirmText': {
      AppLanguage.it: 'Sei sicuro di voler eliminare definitivamente tutti i dati? L\'operazione è irreversibile.',
      AppLanguage.en: 'Are you sure you want to permanently delete all data? This cannot be undone.',
    },
    'appInfo': {
      AppLanguage.it: 'Informazioni App',
      AppLanguage.en: 'App Info',
    },
    'ccCurrentMonth': {
      AppLanguage.it: 'Carta Mese Corrente',
      AppLanguage.en: 'Card Current Month',
    },
    'ccPreviousMonth': {
      AppLanguage.it: 'Carta Mese Precedente',
      AppLanguage.en: 'Card Previous Month',
    },
    'aiDisclaimerTitle': {
      AppLanguage.it: 'Come funziona la Previsione AI?',
      AppLanguage.en: 'How does AI Forecast work?',
    },
    'aiDisclaimerText': {
      AppLanguage.it: 'Il grafico e i saldi stimati mostrati in questa sezione sono generati sommando le scadenze ricorrenti e i movimenti previsti che hai inserito. Questa è una stima puramente matematica. Eventuali imprevisti reali non inseriti non verranno considerati dall\'algoritmo finché non li inserirai.',
      AppLanguage.en: 'The chart and estimated balances shown in this section are generated by summing up your recurring transactions and the projected movements you added. This is a purely mathematical estimation. Any real-world unexpected expenses will not be considered until you input them.',
    },
    'navAIForecast': {
      AppLanguage.it: 'Previsioni & AI',
      AppLanguage.en: 'Forecast & AI',
    },
  };

  static String get(String key, {Map<String, String>? placeholders}) {
    String text = _localizedValues[key]?[currentLanguage] ?? key;
    if (placeholders != null) {
      placeholders.forEach((placeholderKey, value) {
        text = text.replaceAll('{$placeholderKey}', value);
      });
    }
    return text;
  }
}
