// lib/features/admin/screens/report_detail_screen.dart
// 주의: 공유/딥링크를 만들 때 호스트를 직접 하드코딩하지 마세요.
// 대신 `lib/core/constants/app_links.dart`의 `kHostingBaseUrl`을 사용하세요.
import 'package:bling_app/core/models/comment_model.dart';
import 'package:bling_app/core/models/reply_model.dart';
import 'package:bling_app/features/local_news/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// ✅ User Profile Screen import (사용자 ID 클릭 시 이동)
import 'package:bling_app/features/user_profile/screens/user_profile_screen.dart';
// ✅ Post Detail Screen import (게시글 ID 클릭 시 이동)
import 'package:bling_app/features/local_news/screens/local_news_detail_screen.dart';
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  // 신고 문서와 신고된 콘텐츠를 비동기로 로드하기 위한 Future 변수
  late Future<DocumentSnapshot<Map<String, dynamic>>> _reportFuture;
  Future<dynamic>?
      _contentFuture; // PostModel, CommentModel, ReplyModel 등을 담을 Future

  String _reportedContentType = 'unknown'; // 로드 후 타입 저장
  String _reportedContentId = ''; // 로드 후 ID 저장
  String _reportedParentId = ''; // 댓글/답글의 경우 상위 ID 저장
  String _reportedGrandparentId = ''; // 답글의 경우 게시글 ID 저장

  bool _isUpdatingStatus = false; // 상태 업데이트 처리 중 플래그

  @override
  void initState() {
    super.initState();
    _reportFuture = _fetchReportDetails();
  }

  // 신고 상세 정보 가져오기
  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchReportDetails() async {
    final reportDoc = await FirebaseFirestore.instance
        .collection('reports')
        .doc(widget.reportId)
        .get();

    if (reportDoc.exists && reportDoc.data() != null) {
      final data = reportDoc.data()!;
      _reportedContentType = data['reportedContentType'] ?? 'unknown';
      _reportedContentId = data['reportedContentId'] ?? '';
      _reportedParentId = data['reportedParentId'] ?? ''; // 댓글/답글용
      _reportedGrandparentId = data['reportedGrandparentId'] ?? ''; // 답글용

      // 콘텐츠 타입에 따라 원본 콘텐츠 로드 Future 설정
      if (_reportedContentId.isNotEmpty) {
        setState(() {
          _contentFuture = _fetchReportedContent();
        });
      }
    } else {
      throw Exception('Report not found');
    }
    return reportDoc;
  }

  // 신고된 원본 콘텐츠 가져오기
  Future<dynamic> _fetchReportedContent() async {
    try {
      DocumentSnapshot doc;
      switch (_reportedContentType) {
        case 'post':
          doc = await FirebaseFirestore.instance
              .collection('posts')
              .doc(_reportedContentId)
              .get();
          return doc.exists
              ? PostModel.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>)
              : null;
        case 'comment':
          // 댓글은 postId가 필요
          if (_reportedParentId.isEmpty) {
            return Future.value(null); // 상위 ID 없으면 로드 불가
          }
          doc = await FirebaseFirestore.instance
              .collection('posts')
              .doc(_reportedParentId)
              .collection('comments')
              .doc(_reportedContentId)
              .get();
          // CommentModel.fromDocument 사용 (이전 코드 참조)
          return doc.exists ? CommentModel.fromDocument(doc) : null;
        case 'reply':
          // 답글은 postId와 commentId가 필요
          if (_reportedGrandparentId.isEmpty || _reportedParentId.isEmpty) {
            return Future.value(null);
          }
          doc = await FirebaseFirestore.instance
              .collection('posts')
              .doc(_reportedGrandparentId)
              .collection('comments')
              .doc(_reportedParentId)
              .collection('replies')
              .doc(_reportedContentId)
              .get();
          // ReplyModel.fromDocument 사용 (이전 코드 참조)
          return doc.exists ? ReplyModel.fromDocument(doc) : null;
        default:
          return Future.value(null); // 알 수 없는 타입
      }
    } catch (e) {
      debugPrint('Error fetching reported content: $e');
      return Future.error('Failed to load content');
    }
  }

  // 신고 상태 업데이트
  Future<void> _updateReportStatus(String newStatus) async {
    if (_isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);

    try {
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId)
          .update({'status': newStatus});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('admin.reportDetail.statusUpdateSuccess'
                  .tr(namedArgs: {'status': newStatus}))), // 다국어 키 추가 필요
        );
        // 상태 업데이트 후 목록 화면으로 돌아가기 (선택 사항)
        // Navigator.pop(context);
        // 상태 업데이트 후 현재 화면 새로고침 위해 Future 재설정
        setState(() {
          _reportFuture = _fetchReportDetails();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('admin.reportDetail.statusUpdateFail'
                  .tr(namedArgs: {'error': e.toString()}))), // 다국어 키 추가 필요
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  // 원본 게시글 상세로 이동하는 헬퍼 (ID로 조회 후 화면 이동)
  Future<void> _openPostById(String postId) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();
      if (!mounted) return;
      if (postDoc.exists) {
        final post = PostModel.fromFirestore(postDoc);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LocalNewsDetailScreen(post: post)),
        );
      } else {
        messenger?.showSnackBar(
          SnackBar(
              content: Text('admin.reportDetail.originalPostNotFound'.tr())),
        );
      }
    } catch (e) {
      debugPrint('Error navigating to original post: $e');
      if (!mounted) return;
      messenger?.showSnackBar(
        SnackBar(
            content: Text('admin.reportDetail.couldNotOpenOriginalPost'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: AppBarIcon(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        // 다국어 키: admin.reportDetail.title
        title: Text('admin.reportDetail.title'.tr()),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.data!.exists) {
            // 다국어 키: admin.reportDetail.loadError
            return Center(child: Text('admin.reportDetail.loadError'.tr()));
          }

          final reportData = snapshot.data!.data() ?? {};
          final createdAt = reportData['createdAt'] as Timestamp?;
          final formattedDate = createdAt != null
              ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt.toDate())
              : 'N/A';
          final currentStatus = reportData['status'] as String? ?? 'pending';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailSectionTitle(context,
                    'admin.reportDetail.sectionReportInfo'.tr()), // '신고 정보'
                _buildInfoRow(
                    'admin.reportDetail.idLabel'.tr(), widget.reportId),
                _buildInfoRow('admin.reportDetail.reporter'.tr(),
                    reportData['reporterUserId'] ?? 'N/A',
                    isUserId: true), // '신고자'
                _buildInfoRow('admin.reportDetail.reportedUser'.tr(),
                    reportData['reportedUserId'] ?? 'N/A',
                    isUserId: true), // '피신고자'
                _buildInfoRow('admin.reportDetail.reason'.tr(),
                    (reportData['reason'] as String? ?? '').tr()), // '신고 사유'
                _buildInfoRow('admin.reportDetail.reportedAt'.tr(),
                    formattedDate), // '신고 시각'
                _buildInfoRow('admin.reportDetail.currentStatus'.tr(),
                    currentStatus), // '현재 상태'

                // 신고된 게시글 ID (탭하면 상세로 이동)
                if (_reportedContentType == 'post' &&
                    _reportedContentId.isNotEmpty)
                  _buildLinkRow(
                    'admin.reportDetail.postIdLabel'.tr(),
                    _reportedContentId,
                    onTap: () => _openPostById(_reportedContentId),
                  )
                else if (_reportedContentType == 'comment' &&
                    _reportedParentId.isNotEmpty)
                  _buildLinkRow(
                    'admin.reportDetail.postIdLabel'.tr(),
                    _reportedParentId,
                    onTap: () => _openPostById(_reportedParentId),
                  )
                else if (_reportedContentType == 'reply' &&
                    _reportedGrandparentId.isNotEmpty)
                  _buildLinkRow(
                    'admin.reportDetail.postIdLabel'.tr(),
                    _reportedGrandparentId,
                    onTap: () => _openPostById(_reportedGrandparentId),
                  ),

                const Divider(height: 32),

                _buildDetailSectionTitle(context,
                    'admin.reportDetail.sectionContent'.tr()), // '신고된 콘텐츠'

                // 신고된 콘텐츠 표시 영역
                if (_contentFuture == null)
                  Center(
                      child: Text(
                          'admin.reportDetail.loadingContent'.tr())) // 로딩 표시
                else
                  FutureBuilder<dynamic>(
                    future: _contentFuture,
                    builder: (context, contentSnapshot) {
                      if (contentSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (contentSnapshot.hasError ||
                          contentSnapshot.data == null) {
                        return Center(
                            child: Text('admin.reportDetail.contentLoadError'
                                .tr())); // '콘텐츠 로드 실패'
                      }

                      // 콘텐츠 타입별 위젯 반환
                      return _buildReportedContentWidget(contentSnapshot.data);
                    },
                  ),

                const Divider(height: 32),

                _buildDetailSectionTitle(
                    context, 'admin.reportDetail.sectionActions'.tr()), // '처리'

                // 상태 변경 버튼들
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    ElevatedButton(
                      onPressed:
                          (currentStatus == 'pending' && !_isUpdatingStatus)
                              ? () => _updateReportStatus('reviewed') // 검토 완료
                              : null,
                      child: Text(
                          'admin.reportDetail.actionReviewed'.tr()), // '검토 완료'
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      onPressed: (currentStatus != 'action_taken' &&
                              !_isUpdatingStatus)
                          ? () => _updateReportStatus('action_taken') // 조치 완료
                          : null,
                      child: Text('admin.reportDetail.actionTaken'
                          .tr()), // '조치 완료 (예: 삭제)'
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey),
                      onPressed:
                          (currentStatus != 'dismissed' && !_isUpdatingStatus)
                              ? () => _updateReportStatus('dismissed') // 기각
                              : null,
                      child: Text(
                          'admin.reportDetail.actionDismissed'.tr()), // '기각'
                    ),
                    // 필요시 'pending'으로 되돌리는 버튼 등 추가
                  ],
                ),
                if (_isUpdatingStatus)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 섹션 제목 위젯
  Widget _buildDetailSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // 정보 행 위젯 (사용자 ID 클릭 가능)
  Widget _buildInfoRow(String label, String value, {bool isUserId = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: isUserId
                ? InkWell(
                    onTap: (value != 'N/A')
                        ? () {
                            // UserProfileScreen이 userId만 받아서 내부에서 UserModel을 fetch한다고 가정
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      UserProfileScreen(userId: value)),
                            );
                            debugPrint('Tapped User ID: $value'); // 임시 로그
                          }
                        : null,
                    child: Text(value,
                        style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline)),
                  )
                : Text(value),
          ),
        ],
      ),
    );
  }

  // 링크 형태의 정보 행 위젯 (값 탭 시 onTap 실행)
  Widget _buildLinkRow(String label, String value, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Text(
                value,
                style: const TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 신고된 콘텐츠 표시 위젯
  Widget _buildReportedContentWidget(dynamic content) {
    String contentText =
        'admin.reportDetail.contentNotAvailable'.tr(); // '콘텐츠 정보 없음'
    String? contentOwnerId;
    String? linkToPostId; // 댓글/답글의 경우 원본 게시글 ID 저장

    if (content is PostModel) {
      contentText = 'admin.reportDetail.content.post'.tr(
        namedArgs: {
          'title': content.title ?? '',
          'body': content.body,
        },
      );
      contentOwnerId = content.userId;
      linkToPostId = content.id;
    } else if (content is CommentModel) {
      contentText = 'admin.reportDetail.content.comment'.tr(
        namedArgs: {
          'content': content.content,
        },
      );
      contentOwnerId = content.userId;
      linkToPostId = _reportedParentId; // 상위 게시글 ID
    } else if (content is ReplyModel) {
      contentText = 'admin.reportDetail.content.reply'.tr(
        namedArgs: {
          'content': content.content,
        },
      );
      contentOwnerId = content.userId;
      linkToPostId = _reportedGrandparentId; // 상위 게시글 ID
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(contentText, style: const TextStyle(fontSize: 14)),
          if (contentOwnerId != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                  '${'admin.reportDetail.authorIdLabel'.tr()}: $contentOwnerId',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ),
          if (linkToPostId != null &&
              _reportedContentType != 'post') // 댓글/답글일 때만 원본 게시글 링크 표시
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: InkWell(
                onTap: () => _openPostById(linkToPostId!),
                child: Text(
                  'admin.reportDetail.viewOriginalPost'.tr(), // '원본 게시글 보기'
                  style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 12),
                ),
              ),
            )
        ],
      ),
    );
  }
}
