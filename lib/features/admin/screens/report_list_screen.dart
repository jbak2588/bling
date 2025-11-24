// lib/features/admin/screens/report_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/i18n/strings.g.dart';
import 'package:intl/intl.dart';

import 'report_detail_screen.dart';

class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 다국어 키: admin.reportList.title
        title: Text(t.admin.reportList.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore 'reports' 컬렉션에서 'status'가 'pending'인 문서를
        // 'createdAt' 기준으로 내림차순 정렬하여 실시간으로 가져옴
        stream: FirebaseFirestore.instance
            .collection('reports')
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // 다국어 키: admin.reportList.error
            return Center(child: Text(t.admin.reportList.error));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // 다국어 키: admin.reportList.empty
            return Center(child: Text(t.admin.reportList.empty));
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final reportDoc = reports[index];
              final reportData =
                  reportDoc.data() as Map<String, dynamic>? ?? {}; // null 체크 추가

              // 필드 존재 여부 확인 및 기본값 설정
              final contentType =
                  reportData['reportedContentType'] as String? ?? 'unknown';
              final reason =
                  reportData['reason'] as String? ?? 'unknown reason';
              final createdAt = reportData['createdAt'] as Timestamp?;
              final formattedDate = createdAt != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt.toDate())
                  : 'N/A';

              IconData leadingIcon;
              switch (contentType) {
                case 'post':
                  leadingIcon = Icons.article_outlined;
                  break;
                case 'comment':
                  leadingIcon = Icons.comment_outlined;
                  break;
                case 'reply':
                  leadingIcon = Icons.subdirectory_arrow_right_outlined;
                  break;
                default:
                  leadingIcon = Icons.help_outline;
              }

              return ListTile(
                leading: Icon(leadingIcon),
                // 신고 사유 (다국어 처리 - reportReasons.* 키 사용)
                title: Text(t[reason]),
                subtitle: Text('Reported at: $formattedDate'), // 신고 시간
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReportDetailScreen(reportId: reportDoc.id),
                    ),
                  );
                  debugPrint('Tapped report: ${reportDoc.id}'); // 임시 로그
                },
              );
            },
          );
        },
      ),
    );
  }
}
