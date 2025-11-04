// lib/features/pom/widgets/pom_card.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 'PomFeedList' (피드)에 표시되는 개별 '뽐' 카드 (인스타그램 스타일).
// [V2 - 2025-11-03]
// - 'mediaType'에 따라 사진('PageView') 또는 비디오('_PomVideoPlayer') 인라인 재생.
// - 좋아요(낙관적 UI), 댓글, 신고, 공유, '더보기' 기능 구현.
// [V3 - 2025-11-04]
// - 미디어(사진/비디오) 클릭 시 'PomPagerScreen' (풀스크린 뷰어)으로 이동 로직 추가.
// =====================================================

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/pom/models/pom_model.dart';
import 'package:bling_app/features/pom/widgets/pom_comments_sheet.dart';
import 'package:bling_app/features/pom/data/pom_repository.dart'; // [V2]
import 'package:share_plus/share_plus.dart'; // [V2]
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart'; // [V2]
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart'; // [V2]
import 'package:bling_app/features/pom/screens/pom_pager_screen.dart';

/// 기획서(백서) Page 28의 '콘텐츠 카드 구성(피드 UI 기본 단위)'
/// PomModel을 받아 이미지, 작성자, 내용, 반응(좋아요/댓글)을 표시하는 카드 위젯.
class PomCard extends StatefulWidget {
  final PomModel pom;
  final UserModel? currentUserModel; // 좋아요 상태 등을 확인하기 위함
  final List<PomModel>? allPoms; // 리스트에서 스와이프 탐색을 위한 전체 목록
  final int? currentIndex; // 현재 카드의 인덱스

  const PomCard({
    super.key,
    required this.pom,
    this.currentUserModel,
    this.allPoms,
    this.currentIndex,
  });

  @override
  State<PomCard> createState() => _PomCardState();
}

class _PomCardState extends State<PomCard> {
  // [V2] _author를 FutureBuilder에서 관리하도록 변경
  // UserModel? _author;
  final PomRepository _repository = PomRepository(); // [V2]

  // [V2] 좋아요/공유 상태 관리를 위한 로컬 변수
  late bool _isLiked;
  late int _likesCount;

  // [V2] '더보기' 상태
  bool _isExpanded = false;
  static const int _contentMaxChar = 100; // '더보기' 기준 글자 수

  // [V2] 신고 처리 중 상태
  bool _isReporting = false;

  @override
  void initState() {
    super.initState();
    _isLiked =
        widget.currentUserModel?.likedPomIds?.contains(widget.pom.id) ?? false;
    _likesCount = widget.pom.likesCount;
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: PomCommentsSheet(pomId: widget.pom.id),
      ),
    );
  }

  // [V2] 좋아요 버튼 로직
  void _onLikeButtonPressed() {
    if (widget.currentUserModel == null) return; // 로그인 사용자만

    final bool newLikeState = !_isLiked;

    setState(() {
      _isLiked = newLikeState;
      if (newLikeState) {
        _likesCount++;
      } else {
        _likesCount--;
      }
    });

    // DB 업데이트 (이전 상태를 전달: !newLikeState == oldState)
    _repository.togglePomLike(widget.pom.id, !newLikeState);
  }

  // [V2] 공유 버튼 로직
  void _onShareButtonPressed() {
    const String kHostingBaseUrl =
        'https://blingbling-app.web.app'; // Assumption: Firebase Hosting URL
    final String title =
        (widget.pom.title.isNotEmpty) ? widget.pom.title : 'POM';
    final String link = '$kHostingBaseUrl/pom/${widget.pom.id}';
    final String message = 'Check out this POM on Bling!';

    SharePlus.instance.share(
      ShareParams(
        text: '$title\n\n$message\n$link',
        subject: title,
      ),
    );
  }

  // [V2] '신고하기/차단하기' BottomSheet
  void _showMoreOptions(UserModel? author) {
    final authorNickname = author?.nickname ?? 'this user';
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: Text('pom.report'.tr(args: [authorNickname])),
              onTap: () {
                Navigator.pop(context);
                // [V2] 신고 다이얼로그 호출
                _showReportDialog(context, author);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: Text('pom.block'.tr(args: [authorNickname])),
              onTap: () {
                Navigator.pop(context);
                // TODO: 차단하기 로직 연결
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Block logic pending...')));
              },
            ),
          ],
        );
      },
    );
  }

  // [V2] 신고 다이얼로그
  void _showReportDialog(BuildContext context, UserModel? author) {
    String? selectedReason;
    final reportReasons = [
      'reportReasons.spam',
      'reportReasons.abuse',
      'reportReasons.inappropriate',
      'reportReasons.illegal',
      'reportReasons.etc',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('reportDialog.title'.tr()),
              content: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: reportReasons.map((reasonKey) {
                    final isSelected = selectedReason == reasonKey;
                    return ChoiceChip(
                      label: Text(reasonKey.tr()),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => selectedReason = reasonKey),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('common.cancel'.tr()),
                ),
                ElevatedButton(
                  onPressed: (selectedReason != null && !_isReporting)
                      ? () async {
                          Navigator.pop(dialogContext);
                          await _submitReport(context, selectedReason!, author);
                        }
                      : null,
                  child: _isReporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('common.report'.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // [V2] 신고 제출 로직
  Future<void> _submitReport(
      BuildContext context, String reasonKey, UserModel? author) async {
    if (_isReporting) return;

    final reporterId = FirebaseAuth.instance.currentUser?.uid;
    if (reporterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('main.errors.loginRequired'.tr())));
      return;
    }

    if (author == null || author.uid == reporterId) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('reportDialog.cannotReportSelf'.tr())));
      return;
    }

    setState(() => _isReporting = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await _repository.addPomReport(
        reportedPomId: widget.pom.id,
        reportedUserId: author.uid,
        reasonKey: reasonKey,
      );

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('reportDialog.success'.tr())),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'reportDialog.fail'.tr(namedArgs: {'error': e.toString()}),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isReporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildMediaContent(),
          // [V2] Action/Body는 Header의 FutureBuilder 완료 후 렌더링
        ],
      ),
    );
  }

  /// 1. 카드 헤더: 작성자 프로필
  Widget _buildHeader() {
    // [V2] FutureBuilder로 작성자 정보 비동기 로드 (캐싱 TODO 해결)
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.pom.userId)
          .get(),
      builder: (context, snapshot) {
        UserModel? author;
        if (snapshot.hasData && snapshot.data!.exists) {
          author = UserModel.fromFirestore(snapshot.data!);
        }

        // [V2] 위치 정보 + 시간
        final location = widget.pom.location ?? '';
        final time = timeago.format(widget.pom.createdAt.toDate());
        final locationAndTime =
            location.isNotEmpty ? '$location • $time' : time;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: (author?.photoUrl != null &&
                            author!.photoUrl!.isNotEmpty)
                        ? NetworkImage(author.photoUrl!)
                        : null,
                    child: (author?.photoUrl == null ||
                            (author?.photoUrl?.isEmpty ?? true))
                        ? const Icon(Icons.person, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author?.nickname ?? '...',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          locationAndTime,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      // 신고하기/차단하기
                      _showMoreOptions(author);
                    },
                  )
                ],
              ),
            ),
            // Header 이후 동작/본문 렌더링
            _buildActions(),
            _buildContentBody(author),
          ],
        );
      },
    );
  }

  /// 2. 미디어 콘텐츠: 사진(앨범) 또는 비디오 썸네일
  Widget _buildMediaContent() {
    // [V2] 다중 이미지/비디오 구현
    if (widget.pom.mediaUrls.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: Colors.grey.shade200,
          child: const Center(
              child:
                  Icon(Icons.image_not_supported_outlined, color: Colors.grey)),
        ),
      );
    }

    if (widget.pom.mediaType == PomMediaType.image) {
      return AspectRatio(
        aspectRatio: 1,
        child: PageView.builder(
          itemCount: widget.pom.mediaUrls.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: widget.pom.mediaUrls[index],
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: Colors.grey.shade200),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                    child:
                        Icon(Icons.broken_image_outlined, color: Colors.grey)),
              ),
            );
          },
        ),
      );
    } else {
      return _PomVideoPlayer(
        pom: widget.pom,
        userModel: widget.currentUserModel,
        allPoms: widget.allPoms,
        currentIndex: widget.currentIndex,
      );
    }
  }

  /// 3. 액션 버튼: 좋아요, 댓글
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border, // [V2]
              color: _isLiked ? Colors.red : Colors.black87, // [V2]
            ),
            onPressed: _onLikeButtonPressed, // [V2]
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: _showComments,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _onShareButtonPressed, // [V2]
          ),
        ],
      ),
    );
  }

  /// 4. 콘텐츠 본문: 좋아요 수, 제목, 설명, 댓글 미리보기
  Widget _buildContentBody(UserModel? author) {
    final String title = widget.pom.title;
    final String description = widget.pom.description;
    final String combinedContent = '$title $description'.trim();
    final bool isLongContent = combinedContent.length > _contentMaxChar;
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 좋아요 수
          if (_likesCount > 0) // [V2]
            Text(
              'pom.likesCount'.tr(args: [_likesCount.toString()]), // [V2]
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          if (_likesCount > 0) const SizedBox(height: 4),
          // 제목과 설명
          if (combinedContent.isNotEmpty)
            RichText(
              maxLines: _isExpanded ? null : 2,
              overflow:
                  _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              text: TextSpan(
                style:
                    DefaultTextStyle.of(context).style.copyWith(fontSize: 14),
                children: [
                  TextSpan(
                    // TODO: 작성자 닉네임 클릭 시 프로필 이동
                    text: author?.nickname ?? '...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (author != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Navigating to ${author.nickname}'s profile...")),
                          );
                        }
                      },
                  ),
                  const TextSpan(text: ' '),
                  if (title.isNotEmpty)
                    const TextSpan(
                        text: '',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  TextSpan(text: title.isNotEmpty ? '$title ' : ''),
                  TextSpan(text: description),
                ],
              ),
            ),
          if (isLongContent)
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Text(
                _isExpanded ? 'pom.less'.tr() : 'pom.more'.tr(),
                style: const TextStyle(color: Colors.grey, height: 1.8),
              ),
            ),
          const SizedBox(height: 6),
          // 댓글 모두 보기
          if (widget.pom.commentsCount > 0)
            InkWell(
              onTap: _showComments,
              child: Text(
                'pom.comments.viewAll'
                    .tr(args: [widget.pom.commentsCount.toString()]),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

// [V2] 비디오 인라인 플레이어 위젯
}

class _PomVideoPlayer extends StatefulWidget {
  final PomModel pom;
  final UserModel? userModel;
  final List<PomModel>? allPoms;
  final int? currentIndex;
  const _PomVideoPlayer(
      {required this.pom, this.userModel, this.allPoms, this.currentIndex});

  @override
  State<_PomVideoPlayer> createState() => _PomVideoPlayerState();
}

class _PomVideoPlayerState extends State<_PomVideoPlayer> {
  VideoPlayerController? _controller;
  // 인라인 재생 상태는 사용하지 않음 (탭 시 전체 화면으로 이동)

  @override
  void initState() {
    super.initState();
    if (widget.pom.mediaUrls.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.pom.mediaUrls.first),
      )..initialize().then((_) {
          if (mounted) setState(() {});
        }).catchError((e) {
          debugPrint('PomCard inline player init error: $e');
        });
      _controller?.setLooping(true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    // 리스트 카드에서의 동영상 탭은 스와이프 가능한 전체 화면 뷰어로 이동
    final poms = widget.allPoms;
    final startIndex = (widget.currentIndex ?? 0);
    if (poms != null && poms.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PomPagerScreen(
            poms: poms,
            startIndex: startIndex.clamp(0, poms.length - 1),
            userModel: widget.userModel,
          ),
        ),
      );
    } else {
      // 목록 정보가 없는 경우 단일 항목만 보여줌
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PomPagerScreen(
            poms: [widget.pom],
            startIndex: 0,
            userModel: widget.userModel,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: Colors.black,
          child: const Center(
              child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: GestureDetector(
        onTap: _togglePlay,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 미리보기 프레임만 표시 (인라인 자동재생 없음)
            VideoPlayer(_controller!),
            // 항상 풀스크린 진입 유도 아이콘
            Icon(Icons.play_circle_fill,
                color: Colors.white.withValues(alpha: 0.85), size: 64),
          ],
        ),
      ),
    );
  }
}
