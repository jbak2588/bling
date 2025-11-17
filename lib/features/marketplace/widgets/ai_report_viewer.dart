// lib/features/marketplace/widgets/ai_report_viewer.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// AI 검수 리포트의 내용을 구조화하여 표시하는 공용 위젯
/// [V3 개편] V3 "증거 연계" 스키마를 파싱하도록 전면 수정
class AiReportViewer extends StatelessWidget {
  // V3는 ProductModel이 아닌, Map 자체를 받습니다.
  final Map<String, dynamic>? aiReport; // Nullable 허용

  const AiReportViewer({super.key, required this.aiReport});

  @override
  Widget build(BuildContext context) {
    // [V3.1 Fix] 데이터가 없거나 초기화 중일 때 예외 처리
    if (aiReport == null || aiReport!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Text(
          "AI 분석 보고서를 불러오는 중이거나 데이터가 없습니다.",
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    // [V3 REFACTOR] V3 '단순 엔진' 스키마(Task 62)의 핵심 필드로 유효성 검사
    if (aiReport!['itemSummary'] == null || aiReport!['condition'] == null) {
      return const SizedBox.shrink();
    }

    // [V3 REFACTOR] '룰 엔진' V2 파싱 로직 (key_specs, condition_check, ...) 완전 삭제
    // [V3 REFACTOR] V3 '단순 엔진' 스키마(Task 62) 파싱
    final dynamic condition = aiReport!['condition'];
    final String? grade =
        (condition is Map) ? condition['grade'] as String? : null;
    final String? gradeReason =
        (condition is Map) ? condition['gradeReason'] as String? : null;
    final List<dynamic> conditionDetailsRaw =
        (condition is Map) ? condition['details'] as List<dynamic>? ?? [] : [];
    final List<Map<String, dynamic>> conditionDetails = conditionDetailsRaw
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    final dynamic price = aiReport!['priceAssessment'];
    final String? priceComment =
        (price is Map) ? price['comment'] as String? : null;
    final num? minPrice = (price is Map) ? price['suggestedMin'] as num? : null;
    final num? maxPrice = (price is Map) ? price['suggestedMax'] as num? : null;

    final String? notesForBuyer = aiReport!['notesForBuyer'] as String?;
    final String? summary = aiReport!['verificationSummary'] as String?;
    // [V3 REFACTOR] (중요) 구매자 뷰어는 'onSiteVerificationChecklist'를 절대 파싱하거나 표시하지 않습니다.

    final List<Widget> sections = [];

    // 1. Overall Summary
    if (summary != null && summary.isNotEmpty) {
      sections.add(_buildReportText(
        context,
        Icons.check_circle_outline,
        'ai_flow.final_report.summary'.tr(),
        summary,
      ));
    }

    // 2. Price Assessment
    if (priceComment != null && priceComment.isNotEmpty) {
      String priceText = priceComment;
      // 가격 범위를 예쁘게 포맷팅
      final formatter = NumberFormat.currency(
          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      if (minPrice != null && maxPrice != null) {
        priceText =
            "${formatter.format(minPrice)} ~ ${formatter.format(maxPrice)}\n$priceComment";
      } else if (minPrice != null) {
        priceText = "${formatter.format(minPrice)}\n$priceComment";
      }
      sections.add(_buildReportText(
        context,
        Icons.price_check_outlined,
        'ai_flow.final_report.suggested_price'.tr(args: ['']),
        priceText,
      ));
    }

    // 3. Condition & Details
    String conditionTitle = 'ai_flow.final_report.condition'.tr();
    if (grade != null && grade.isNotEmpty) {
      conditionTitle =
          "${'ai_flow.final_report.condition'.tr()} (Grade: $grade)";
    }

    if (conditionDetails.isNotEmpty) {
      sections.add(_buildV3Section(
        context,
        Icons.healing_outlined,
        conditionTitle,
        conditionDetails,
        gradeReason,
      ));
    } else if (gradeReason != null && gradeReason.isNotEmpty) {
      // 세부 사항(details)은 없지만 등급 사유만 있을 경우
      sections.add(_buildReportText(
        context,
        Icons.healing_outlined,
        conditionTitle,
        gradeReason,
      ));
    }

    // 4. Notes for Buyer
    if (notesForBuyer != null && notesForBuyer.isNotEmpty) {
      sections.add(_buildReportText(
        context,
        Icons.warning_amber_rounded,
        'ai_flow.final_report.notes'.tr(),
        notesForBuyer,
      ));
    }

    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children:
              sections.expand((e) => [e, const SizedBox(height: 16)]).toList()
                ..removeLast(),
        ),
      ),
    );
  }

  /// [V3] '증거 연계' 스키마 (List<Map>)를 렌더링하는 위젯
  Widget _buildV3Section(BuildContext context, IconData icon, String title,
      List<Map<String, dynamic>> items,
      [String? headerNote] // [V3 REFACTOR] 등급 사유 등을 표시하기 위한 헤더 노트 추가
      ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // [V3 REFACTOR] 헤더 노트(예: gradeReason) 표시
              if (headerNote != null && headerNote.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 28.0, bottom: 4.0),
                  child: Text(
                    headerNote,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
              ...items.map((item) {
                // [V3 REFACTOR] V3 'condition.details' 스키마 파싱
                final label = item['label'] as String? ?? 'N/A';
                final value = item['value'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // [V3 REFACTOR] 증거 썸네일(source_image_url) 및 reason_if_null 로직 삭제
                      // 라벨 및 값
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: theme.textTheme.labelMedium),
                            const SizedBox(height: 2),
                            Text(
                              value?.toString() ?? 'N/A',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                // ignore: unnecessary_to_list_in_spreads
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  /// 단순 텍스트 섹션 (Summary, Notes for Buyer 등)
  Widget _buildReportText(
      BuildContext context, IconData icon, String title, String data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(data.toString(), style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }
}
