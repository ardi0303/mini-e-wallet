import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_e_wallet/main.dart';

void main() {
  testWidgets('login screen renders expected content', (tester) async {
    await tester.pumpWidget(const MiniEWalletApp());

    expect(find.text('E Pay'), findsOneWidget);
    expect(find.text('Simple Wallet'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
  });
}
