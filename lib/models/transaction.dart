/// Tipologie di transazioni gestite dal sistema
enum TransactionType {
  income,        // Entrata (Stipendio, rimborsi, ecc.)
  expenseMain,   // Spesa da Conto Principale (detratta subito dal saldo liquido)
  expenseCard,   // Spesa da Carta di Credito (tracciata a parte, non influisce sul saldo effettivo immediato)
}

/// Rappresentazione di un singolo movimento finanziario
class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType type;
  final bool isProjected; // true = Previsione, false = Movimento Reale Effettivo
  final String? recurrence; // null = Nessuna, 'weekly' = Settimanale, 'monthly' = Mensile, 'yearly' = Annuale

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    required this.isProjected,
    this.recurrence,
  });

  /// Permette di clonare e modificare facilmente la transazione (es. in fase di concretizzazione)
  Transaction copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    String? category,
    TransactionType? type,
    bool? isProjected,
    String? recurrence,
    bool clearRecurrence = false,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      isProjected: isProjected ?? this.isProjected,
      recurrence: clearRecurrence ? null : (recurrence ?? this.recurrence),
    );
  }

  /// Converte la transazione in formato JSON per il salvataggio locale
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type': type.name,
      'isProjected': isProjected,
      'recurrence': recurrence,
    };
  }

  /// Crea una transazione a partire da una mappa JSON caricata localmente
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      type: TransactionType.values.byName(json['type'] as String),
      isProjected: json['isProjected'] as bool,
      recurrence: json['recurrence'] as String?,
    );
  }
}
