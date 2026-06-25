import 'package:flutter_test/flutter_test.dart';
import 'package:ai_smart_wallet/utils/currency_formatter.dart';

void main() {
  group('Currency Formatter Tests', () {
    test('Formats normal values correctly', () {
      expect(formatCurrency(1200.50), '€ 1.200,50');
      expect(formatCurrency(0.0), '€ 0,00');
      expect(formatCurrency(5.99), '€ 5,99');
    });

    test('Formats large values with correct thousands separators', () {
      expect(formatCurrency(1000000.0), '€ 1.000.000,00');
      expect(formatCurrency(123456.78), '€ 123.456,78');
    });

    test('Formats negative values correctly', () {
      expect(formatCurrency(-50.50), '€ -50,50');
      expect(formatCurrency(-1500.0), '€ -1.500,00');
    });
  });
}
