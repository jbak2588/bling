// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:bling_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Note: Avoid EasyLocalization.ensureInitialized in tests to prevent
  // SharedPreferences plugin access. Configure EasyLocalization inline.

  testWidgets('App builds with EasyLocalization', (WidgetTester tester) async {
    // Wrap BlingApp with EasyLocalization so context.* localization is available.
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ko'), Locale('id')],
        path: 'assets/lang',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        saveLocale: false,
        child: const BlingApp(isTest: true),
      ),
    );

    // Allow first frame and localization init.
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    // Smoke: MaterialApp should be present without throwing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
