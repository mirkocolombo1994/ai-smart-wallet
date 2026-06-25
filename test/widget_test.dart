import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_smart_wallet/main.dart';
import 'package:ai_smart_wallet/constants/app_strings.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SmartWalletApp renders navigation items correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartWalletApp());
    await tester.pumpAndSettle();

    // Verify navigation tabs are built
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.psychology_rounded), findsOneWidget);
    expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);

    // Verify initial title or tab content exists
    expect(find.text(AppStrings.get('smartWallet')), findsWidgets);
  });
}
