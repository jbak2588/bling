// lib/features/admin/screens/ai_audit_screen.dart

/// ============================================================================
/// Bling DocHeader (V3.1 Admin Dashboard, 2025-11-18)
/// Module        : Admin / AI Audit
/// File          : lib/features/admin/screens/ai_audit_screen.dart
/// Purpose       : AI 검수 및 인수 건수 통합 조회/관리 화면.
///
/// [Features]
/// 1. List View: 'ai_cases' 컬렉션을 실시간 스트림으로 조회.
/// 2. Filtering: 전체(All) / 현장 인수(Takeover) / 등록 검수(Enhancement) 탭 구분.
///    - Firestore 복합 색인(stage ASC + createdAt DESC) 최적화 적용.
/// 3. Status Indicators: AI 판정 결과(Pass/Fail/Suspicious)를 시각적으로 구분.
/// 4. Navigation: 개별 건 클릭 시 상세 화면(AiCaseDetailScreen)으로 이동.
/// ============================================================================
library;

import 'package:bling_app/features/admin/models/ai_case_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/features/admin/screens/ai_case_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

// [Next Step] 상세 화면은 다음 단계에서 구현할 예정이므로 임시 placeholder 사용
// import 'ai_case_detail_screen.dart';

class AiAuditScreen extends StatefulWidget {
  const AiAuditScreen({super.key});

  @override
  State<AiAuditScreen> createState() => _AiAuditScreenState();
}

class _AiAuditScreenState extends State<AiAuditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3개의 탭: 전체, 현장 인수(Takeover), 등록 검수(Enhancement)
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('ai_audit.title')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: tr('ai_audit.tabs.all')),
            Tab(text: tr('ai_audit.tabs.takeover')),
            Tab(text: tr('ai_audit.tabs.registration')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCaseList(null), // All
          _buildCaseList('takeover'), // Takeover Only
          _buildCaseList('enhancement'), // Enhancement Only
        ],
      ),
    );
  }

  Widget _buildCaseList(String? stageFilter) {
    // [Fix] 쿼리 순서 변경: where(필터) -> orderBy(정렬) 순서로 해야 복합 색인이 작동합니다.
    Query query = FirebaseFirestore.instance.collection('ai_cases');

    if (stageFilter != null) {
      query = query.where('stage', isEqualTo: stageFilter);
    }

    // 정렬은 마지막에
    query = query.orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text("${tr('ai_audit.list.error')}: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(tr('ai_audit.list.no_records')));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final caseModel = AiCaseModel.fromFirestore(docs[index]);
            return _buildCaseTile(caseModel);
          },
        );
      },
    );
  }

  Widget _buildCaseTile(AiCaseModel item) {
    // 상태에 따른 아이콘 및 색상 설정
    IconData statusIcon;
    Color statusColor;

    if (item.status == 'pass' || item.status == 'completed') {
      if (item.verdict == 'match_confirmed' || item.verdict == 'safe') {
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
      } else {
        statusIcon = Icons.warning;
        statusColor = Colors.orange;
      }
    } else if (item.status == 'fail') {
      statusIcon = Icons.cancel;
      statusColor = Colors.red;
    } else {
      statusIcon = Icons.hourglass_top;
      statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          item.stage == 'takeover'
              ? tr('ai_audit.list.takeover_title')
              : tr('ai_audit.list.registration_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("${tr('ai_audit.list.verdict')}: ${item.verdict ?? 'N/A'}"),
            Text(
              "${tr('ai_audit.list.id')}: ${item.caseId.substring(0, 8)}... • ${timeago.format(item.createdAt.toDate())}",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // [Next Step] 상세 화면으로 이동 (구현 완료)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AiCaseDetailScreen(aiCase: item)),
          );
        },
      ),
    );
  }
}
