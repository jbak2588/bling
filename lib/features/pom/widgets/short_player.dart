// lib/features/pom/widgets/short_player.dart

import 'package:bling_app/features/pom/models/short_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/screens/find_friend_detail_screen.dart';
import 'package:bling_app/features/pom/data/short_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:easy_localization/easy_localization.dart';
import 'short_comments_sheet.dart';

class ShortPlayer extends StatefulWidget {
  final ShortModel short;
  const ShortPlayer({super.key, required this.short});

  @override
  State<ShortPlayer> createState() => _ShortPlayerState();
}

class _ShortPlayerState extends State<ShortPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  final ShortRepository _repository = ShortRepository();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // V V V --- [추가] '좋아요' 상태를 위젯 내부에서 직접 관리하기 위한 변수 --- V V V
  bool _isLiked = false;
  int _likesCount = 0;
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  @override
  void initState() {
    super.initState();
    _likesCount = widget.short.likesCount; // 초기 좋아요 수 설정
    _checkIfLiked(); // 내가 좋아요를 눌렀는지 확인

    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.short.videoUrl))
          ..initialize().then((_) {
            _controller.play();
            _controller.setLooping(true);
            if (mounted) setState(() => _isPlaying = true);
          });
  }

  // [추가] 화면이 처음 로드될 때, 내가 이 영상에 좋아요를 눌렀는지 확인하는 함수
  Future<void> _checkIfLiked() async {
    if (_currentUserId == null) return;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUserId).get();
    if (userDoc.exists && mounted) {
      final user = UserModel.fromFirestore(userDoc);
      setState(() {
        _isLiked = user.likedShortIds?.contains(widget.short.id) ?? false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

void _onLikeButtonPressed() {
    if (_currentUserId == null) return;
    // UI를 먼저 즉시 업데이트
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likesCount++;
      } else {
        _likesCount--;
      }
    });
    // 그 다음, 백그라운드에서 DB 작업 수행
    _repository.toggleShortLike(widget.short.id, !_isLiked);
  }

  @override
  Widget build(BuildContext context) {
    // V V V --- [추가] 정밀 진단을 위한 로그 --- V V V
    debugPrint(
        "--- [진단] short_player.dart (ID: ${widget.short.id})가 다시 빌드되었습니다! ---");

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(
          children: [
            Center(
              child: _controller.value.isInitialized
                  ? SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
            if (!_isPlaying)
              Center(
                  child: Icon(Icons.play_arrow,
                      size: 80, color: Colors.white.withValues(alpha: 0.7))),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: _buildVideoInfo()),
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

  Widget _buildVideoInfo() {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.short.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const SizedBox.shrink();
          }
          final user = UserModel.fromFirestore(
              snapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('@${user.nickname}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [Shadow(blurRadius: 2)])),
              const SizedBox(height: 8),
              Text(widget.short.description,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      shadows: [Shadow(blurRadius: 2)]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          );
        });
  }

  // V V V --- [수정] 좋아요/댓글 카운트를 실시간으로 감시 + 내부 상태 관리 --- V V V
  Widget _buildActionButtons() {
    if (_currentUserId == null) return const SizedBox.shrink();

    // 이 short 문서 하나만 실시간으로 감시하여 '댓글 수'만 업데이트
    return StreamBuilder<ShortModel>(
        stream: _repository.getShortStream(widget.short.id),
        builder: (context, shortSnapshot) {
          // 실시간 댓글 수는 shortSnapshot에서 가져오고, 없다면 기존 값을 사용
          final liveCommentsCount =
              shortSnapshot.data?.commentsCount ?? widget.short.commentsCount;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- 작성자 프로필 보기 ---
              StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.short.userId)
                      .snapshots(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const CircleAvatar(radius: 24);
                    }
                    final user = UserModel.fromFirestore(userSnapshot.data!
                        as DocumentSnapshot<Map<String, dynamic>>);
                    return InkWell(
                      onTap: () async {
                        final currentUserDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_currentUserId)
                            .get();
                        if (currentUserDoc.exists && mounted) {
                          final currentUser =
                              UserModel.fromFirestore(currentUserDoc);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => FindFriendDetailScreen(
                                  user: user, currentUserModel: currentUser)));
                        }
                      },

                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage:
                            (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                                ? NetworkImage(user.photoUrl!)
                                : null,
                        child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                    );
                  }),
              const SizedBox(height: 24),

              // --- 좋아요 기능 ---
              InkWell(
                onTap: _onLikeButtonPressed,
                child: _buildActionButton(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  label: _likesCount.toString(), // 내부 상태(_likesCount)를 사용
                  color: _isLiked ? Colors.red : Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // --- 댓글 보기 기능 ---
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: ShortCommentsSheet(shortId: widget.short.id),
                    ),
                  );
                },
                child: _buildActionButton(
                    icon: Icons.comment,
                    label: liveCommentsCount.toString()), // 실시간 댓글 수
              ),
              const SizedBox(height: 20),

              _buildActionButton(icon: Icons.share, label: 'pom.share'.tr()),
            ],
          );
        });
  }
  // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

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
