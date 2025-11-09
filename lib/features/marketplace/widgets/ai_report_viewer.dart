// lib/features/marketplace/widgets/ai_report_viewer.dart
import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// AI 검수 리포트의 내용을 구조화하여 표시하는 공용 위젯
class AiReportViewer extends StatelessWidget {
  final ProductModel product;

  const AiReportViewer({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    if (!product.isAiVerified || product.aiReport == null) {
      return const SizedBox.shrink();
    }

    final report = product.aiReport!;
    final summary = report['verification_summary'];
    final specs = report['key_specs'];
    final condition = report['condition_check'];
    final items = report['included_items'];
    final buyerNotes = report['notes_for_buyer'];
    final skipped = report['skipped_items'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary != null)
          _buildReportItem(context, Icons.task_alt,
              'ai_flow.final_report.summary'.tr(), summary),
        if (specs is Map && specs.isNotEmpty)
          _buildReportMap(context, Icons.list_alt,
              'ai_flow.final_report.key_specs'.tr(), specs),
        if (condition != null)
          _buildReportItem(context, Icons.healing,
              'ai_flow.final_report.condition'.tr(), condition),
        if (items is List && items.isNotEmpty)
          _buildReportList(context, Icons.inbox,
              'ai_flow.final_report.included_items_label'.tr(), items),
        if (buyerNotes is String && buyerNotes.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildReportItem(context, Icons.info_outline,
              'ai_flow.final_report.buyer_notes_label'.tr(), buyerNotes,
              isWarning: true),
        ],
        if (skipped is List && skipped.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildReportList(
              context,
              Icons.photo_size_select_actual_outlined,
              'ai_flow.final_report.skipped_items'.tr(),
              List<String>.from(skipped)),
        ],
        const Divider(height: 32),
      ],
    );
  }

  // 리포트 항목을 표시하는 헬퍼 위젯들
  Widget _buildReportItem(
      BuildContext context, IconData icon, String title, dynamic content,
      {bool isWarning = false}) {
    final theme = Theme.of(context);
    final color = isWarning ? Colors.orange.shade700 : theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content.toString(), style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildReportMap(BuildContext context, IconData icon, String title,
      Map<dynamic, dynamic> data) {
    return Column(
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
        ...data.entries.map((e) => Padding(
              padding: const EdgeInsets.only(left: 28.0, bottom: 4.0),
              child: Text("- ${e.key}: ${e.value}"),
            )),
      ],
    );
  }

  Widget _buildReportList(
      BuildContext context, IconData icon, String title, List<dynamic> data) {
    return Column(
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
        ...data.map((e) => Padding(
              padding: const EdgeInsets.only(left: 28.0, bottom: 4.0),
              child: Text("- ${e.toString()}"),
            )),
      ],
    );
  }
}
