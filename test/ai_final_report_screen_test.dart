import 'package:bling_app/features/marketplace/screens/ai_final_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('buyer notes are trimmed on init', (WidgetTester tester) async {
    // [V3 REFACTOR] V3 '단순 엔진' 스키마(Task 62)의 키('notesForBuyer')를 사용
    final finalReport = {
      'notesForBuyer': '   ', // V3 키
      // V3 스키마 유효성 검사를 통과하기 위한 최소한의 필수 맵
      'itemSummary': {},
      'condition': {},
    };

    await tester.pumpWidget(MaterialApp(
      home: AiFinalReportScreen(
        // [V3 REFACTOR] 'AiFinalReportScreen' V3 생성자 호출
        productId: 'p1',
        categoryId: 'c1',
        finalReport: finalReport,
        initialImageUrls: const [], // V3 필수 파라미터
        guidedImageUrls: const {}, // V3 필수 파라미터
        confirmedProductName: 'Test',
        skipUserFetch: true,
      ),
    ));

    await tester.pumpAndSettle();

    final finder = find.byKey(const Key('buyerNotesField'));
    expect(finder, findsOneWidget);

    final textField = tester.widget<TextFormField>(finder);
    expect(textField.controller?.text, '');
  });
}
