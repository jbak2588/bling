import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:bling_app/features/marketplace/screens/ai_final_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('buyer notes are trimmed on init', (WidgetTester tester) async {
    final finalReport = {'notes_for_buyer': '   '};

    final rule = AiVerificationRule(
      id: 'r1',
      nameKo: '',
      nameEn: '',
      nameId: '',
      isAiVerificationSupported: false,
      minGalleryPhotos: 0,
      suggestedShots: <String, RequiredShot>{},
      reportTemplatePrompt: '',
      initialAnalysisPromptTemplate: '',
    );

    await tester.pumpWidget(MaterialApp(
      home: AiFinalReportScreen(
        productId: 'p1',
        categoryId: 'c1',
        finalReport: finalReport,
        rule: rule,
        initialImages: [],
        takenShots: {},
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
