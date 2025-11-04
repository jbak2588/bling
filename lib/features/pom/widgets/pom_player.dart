// ===================== DocHeader =====================
// [개요]
// - POM 플레이어 (v2). 이미지/영상 모두 지원하는 PomModel 기반 플레이어.
// - 좋아요/댓글/조회수, 작성자/현재 사용자 정보 연동.
// =====================================================
// - 풀스크린(틱톡/릴스 스타일) 상세 뷰어의 개별 페이지 위젯.
// [V2 - 2025-11-03]
// - 'short_player'에서 리네이밍. 'PomModel' 기반으로 수정.
// [V3 - 2025-11-04]
// - 'PomPagerScreen'에 의해 호출됨.
// - 'showAppBar' 옵션을 추가하여 'PomPagerScreen'의 오버레이 백버튼과 충돌 방지.
// - 재생 오류(Source Error) 대응 로직 (데이터 마이그레이션 후 현재는 안정화됨).
// =====================================================
// 파일 경로: lib/features/pom/widgets/pom_player.dart

import 'package:bling_app/features/pom/models/pom_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/screens/find_friend_detail_screen.dart';
import 'package:bling_app/features/pom/data/pom_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:easy_localization/easy_localization.dart';
import 'pom_comments_sheet.dart';
import 'package:share_plus/share_plus.dart';

class PomPlayer extends StatefulWidget {
  final PomModel pom;
  final UserModel? userModel;
  final bool showAppBar; // 전체 화면 오버레이 백버튼 사용 시 false로 설정

  const PomPlayer({
    super.key,
    required this.pom,
    this.userModel,
    this.showAppBar = true,
  });

  @override
  State<PomPlayer> createState() => _PomPlayerState();
}

class _PomPlayerState extends State<PomPlayer> {
  VideoPlayerController? _controller;
  final ValueNotifier<bool> _isPlaying = ValueNotifier(false);
  final PomRepository _repository = PomRepository();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  bool _isLiked = false;
  int _likesCount = 0;

  UserModel? _author;
  UserModel? _currentUserModel;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.pom.likesCount;

    _currentUserModel = widget.userModel;
    _fetchInitialData();

    if (widget.pom.mediaType == PomMediaType.video &&
        widget.pom.mediaUrls.isNotEmpty) {
      final url = widget.pom.mediaUrls.first;
      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _controller!.play();
              _controller!.setLooping(true);
              _isPlaying.value = true;
            });
          }
        }).catchError((error) {
          // 초기화 실패 시 로그만 남김
          debugPrint('PomPlayer initialize error: $error');
        });
    }
  }

  Future<void> _fetchInitialData() async {
    // 작성자 정보
    final authorDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.pom.userId)
        .get();
    if (authorDoc.exists && mounted) {
      setState(() {
        _author = UserModel.fromFirestore(authorDoc);
      });
    }

    // 현재 사용자 정보 및 좋아요 상태
    if (_currentUserModel != null) {
      if (mounted) {
        setState(() {
          _isLiked =
              _currentUserModel!.likedPomIds?.contains(widget.pom.id) ?? false;
        });
      }
    } else if (_currentUserId != null) {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .get();
      if (currentUserDoc.exists && mounted) {
        final user = UserModel.fromFirestore(currentUserDoc);
        setState(() {
          _currentUserModel = user;
          _isLiked = user.likedPomIds?.contains(widget.pom.id) ?? false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _isPlaying.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      _isPlaying.value = false;
    } else {
      _controller!.play();
      _isPlaying.value = true;
    }
  }

  void _onLikeButtonPressed() {
    if (_currentUserId == null) return;
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    _repository.togglePomLike(widget.pom.id, !_isLiked);
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.pom.mediaType == PomMediaType.video &&
        widget.pom.mediaUrls.isNotEmpty;
    final hasImage = widget.pom.mediaType == PomMediaType.image &&
        widget.pom.mediaUrls.isNotEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,
      body: GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(
          children: [
            Center(
              child: isVideo
                  ? (_controller != null && _controller!.value.isInitialized)
                      ? SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller!.value.size.width,
                              height: _controller!.value.size.height,
                              child: VideoPlayer(_controller!),
                            ),
                          ),
                        )
                      : const CircularProgressIndicator(color: Colors.white)
                  : hasImage
                      ? SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Image.network(
                              widget.pom.mediaUrls.first,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : const Icon(Icons.photo,
                          color: Colors.white70, size: 64),
            ),
            if (isVideo)
              ValueListenableBuilder<bool>(
                valueListenable: _isPlaying,
                builder: (context, isPlaying, _) {
                  return !isPlaying
                      ? Center(
                          child: Icon(Icons.play_arrow,
                              size: 80,
                              color: Colors.white.withValues(alpha: 0.7)))
                      : const SizedBox.shrink();
                },
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: _buildInfo()),
                      _buildActionButtons(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    if (_author == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('@${_author!.nickname}',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [Shadow(blurRadius: 2)])),
        const SizedBox(height: 8),
        Text(widget.pom.description,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                shadows: [Shadow(blurRadius: 2)]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_currentUserId == null || _author == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            if (_currentUserModel != null) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => FindFriendDetailScreen(
                      user: _author!, currentUserModel: _currentUserModel!)));
            }
          },
          child: CircleAvatar(
            radius: 24,
            backgroundImage:
                (_author!.photoUrl != null && _author!.photoUrl!.isNotEmpty)
                    ? NetworkImage(_author!.photoUrl!)
                    : null,
            child: (_author!.photoUrl == null || _author!.photoUrl!.isEmpty)
                ? const Icon(Icons.person)
                : null,
          ),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: _onLikeButtonPressed,
          child: _buildActionButton(
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            label: _likesCount.toString(),
            color: _isLiked ? Colors.red : Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        StreamBuilder<PomModel>(
            stream: _repository.getPomStream(widget.pom.id),
            builder: (context, pomSnapshot) {
              final liveCommentsCount =
                  pomSnapshot.data?.commentsCount ?? widget.pom.commentsCount;
              return InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: PomCommentsSheet(pomId: widget.pom.id),
                    ),
                  );
                },
                child: _buildActionButton(
                    icon: Icons.comment, label: liveCommentsCount.toString()),
              );
            }),
        const SizedBox(height: 20),
        InkWell(
          onTap: _onShare,
          child: _buildActionButton(icon: Icons.share, label: 'pom.share'.tr()),
        ),
      ],
    );
  }

  void _onShare() {
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

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      Color color = Colors.white}) {
    return Column(
      children: [
        Icon(icon,
            color: color, size: 32, shadows: const [Shadow(blurRadius: 2)]),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                shadows: [Shadow(blurRadius: 2)])),
      ],
    );
  }
}
