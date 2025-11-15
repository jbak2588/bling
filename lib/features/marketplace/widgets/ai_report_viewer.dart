// lib/features/marketplace/widgets/ai_report_viewer.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// AI 검수 리포트의 내용을 구조화하여 표시하는 공용 위젯
/// [V3 개편] V3 "증거 연계" 스키마를 파싱하도록 전면 수정
class AiReportViewer extends StatelessWidget {
  // V3는 ProductModel이 아닌, Map 자체를 받습니다.
  final Map<String, dynamic> aiReport;

  const AiReportViewer({super.key, required this.aiReport});

  @override
  Widget build(BuildContext context) {
    // V3 스키마의 유효성을 검사합니다.
    if (aiReport['key_specs'] == null || aiReport['key_specs'] is! List) {
      return const SizedBox.shrink();
    }

    // [FIX] V3 스키마 파싱 - 런타임 타입 에러 방지를 위한 안전한 캐스팅

    // 1. Key Specs (List<Map>)
    final List<dynamic> keySpecsRaw = aiReport['key_specs'] ?? [];
    final List<Map<String, dynamic>> keySpecs = keySpecsRaw
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    // 2. Condition Check (List<Map>)
    final List<dynamic> conditionCheckRaw = aiReport['condition_check'] ?? [];
    final List<Map<String, dynamic>> conditionCheck = conditionCheckRaw
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    // 3. Included Items (List<Map>)
    final List<dynamic> includedItemsRaw = aiReport['included_items'] ?? [];
    final List<Map<String, dynamic>> includedItems = includedItemsRaw
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    // 4. Notes for Buyer (Map)
    final dynamic notesRaw = aiReport['notes_for_buyer'];
    final Map<String, dynamic> notesForBuyer =
        (notesRaw is Map) ? Map<String, dynamic>.from(notesRaw) : {};
    final String? buyerNoteValue = notesForBuyer['value'] as String?;

    final List<Widget> sections = [];

    // --- V2 섹션 (제거) ---

    // [V3] 1. Key Specs 섹션
    if (keySpecs.isNotEmpty) {
      sections.add(_buildV3Section(
        context,
        Icons.memory_outlined,
        'ai_flow.final_report.specs'.tr(),
        keySpecs,
      ));
    }

    // [V3] 2. Condition 섹션
    if (conditionCheck.isNotEmpty) {
      sections.add(_buildV3Section(
        context,
        Icons.healing_outlined,
        'ai_flow.final_report.condition'.tr(),
        conditionCheck,
      ));
    }

    // [V3] 3. Included Items 섹션
    if (includedItems.isNotEmpty) {
      sections.add(_buildV3Section(
        context,
        Icons.inventory_2_outlined,
        'ai_flow.final_report.items'.tr(),
        includedItems,
      ));
    }

    // [V3] 4. Notes for Buyer 섹션
    if (buyerNoteValue != null && buyerNoteValue.isNotEmpty) {
      sections.add(_buildReportText(
        context,
        Icons.warning_amber_rounded,
        'ai_flow.final_report.notes'.tr(),
        buyerNoteValue,
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
  Widget _buildV3Section(
    BuildContext context,
    IconData icon,
    String title,
    List<Map<String, dynamic>> items,
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
            children: items.map((item) {
              final label = item['label'] as String? ?? 'N/A';
              final value = item['value'];
              final reasonIfNull = item['reason_if_null'] as String?;
              final sourceImageUrl = item['source_image_url'] as String?;

              Widget valueWidget;
              if (value == null) {
                valueWidget = Text(
                  reasonIfNull ?? 'N/A',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.error),
                );
              } else {
                valueWidget = Text(
                  value.toString(),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 증거 썸네일
                    if (sourceImageUrl != null)
                      Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: NetworkImage(sourceImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        child: Icon(Icons.image_not_supported_outlined,
                            size: 20, color: theme.colorScheme.outline),
                      ),

                    // 라벨 및 값
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: theme.textTheme.labelMedium),
                          const SizedBox(height: 2),
                          valueWidget,
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
