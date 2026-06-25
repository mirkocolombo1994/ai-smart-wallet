import 'package:flutter_test/flutter_test.dart';
import 'package:ai_smart_wallet/models/transaction.dart';

void main() {
  group('Transaction Model Tests', () {
    final testDate = DateTime(2026, 6, 25);

    test('toJson and fromJson work correctly', () {
      final tx = Transaction(
        id: '123',
        description: 'Test Spesa',
        amount: 50.0,
        date: testDate,
        category: 'Spese',
        type: TransactionType.expenseMain,
        isProjected: false,
        recurrence: 'monthly',
      );

      final json = tx.toJson();
      expect(json['id'], '123');
      expect(json['amount'], 50.0);
      expect(json['date'], testDate.toIso8601String());
      expect(json['type'], 'expenseMain');
      expect(json['isProjected'], false);
      expect(json['recurrence'], 'monthly');

      final parsedTx = Transaction.fromJson(json);
      expect(parsedTx.id, tx.id);
      expect(parsedTx.description, tx.description);
      expect(parsedTx.amount, tx.amount);
      expect(parsedTx.date, tx.date);
      expect(parsedTx.category, tx.category);
      expect(parsedTx.type, tx.type);
      expect(parsedTx.isProjected, tx.isProjected);
      expect(parsedTx.recurrence, tx.recurrence);
    });

    test('copyWith creates modified copy correctly', () {
      final tx = Transaction(
        id: '123',
        description: 'Test Spesa',
        amount: 50.0,
        date: testDate,
        category: 'Spese',
        type: TransactionType.expenseMain,
        isProjected: false,
      );

      final copy = tx.copyWith(
        amount: 100.0,
        isProjected: true,
      );

      expect(copy.id, '123');
      expect(copy.amount, 100.0);
      expect(copy.isProjected, true);
      expect(copy.description, 'Test Spesa');
    });
  });
}
