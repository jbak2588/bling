// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bling_app/i18n/strings.g.dart';

import 'package:bling_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App builds', (WidgetTester tester) async {
    // Set Slang locale for tests
    LocaleSettings.setLocaleRaw('en');

    // Pump the app directly for a smoke test
    await tester.pumpWidget(const BlingApp(isTest: true));

    // Allow first frame to settle
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    // Smoke: MaterialApp should be present without throwing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
