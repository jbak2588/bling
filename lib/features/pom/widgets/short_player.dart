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
  final ValueNotifier<bool> _isPlaying = ValueNotifier(false);
  final ShortRepository _repository = ShortRepository();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  bool _isLiked = false;
  int _likesCount = 0;

  // V V V --- [추가] DB 조회를 최소화하기 위한 상태 변수 --- V V V
  UserModel? _author;
  UserModel? _currentUserModel;
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

  @override
  void initState() {
    super.initState();
    _likesCount = widget.short.likesCount;
    _fetchInitialData(); // [수정] 모든 초기 데이터를 한 번에 불러옵니다.

    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.short.videoUrl))
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _controller.play();
                _controller.setLooping(true);
                _isPlaying.value = true;
              });
            }
          });
  }

  // [수정] initState에서 필요한 모든 데이터를 한 번만 가져오는 함수
  Future<void> _fetchInitialData() async {
    // 1. 동영상 작성자 정보 가져오기
    final authorDoc = await FirebaseFirestore.instance.collection('users').doc(widget.short.userId).get();
    if (authorDoc.exists && mounted) {
      setState(() {
        _author = UserModel.fromFirestore(authorDoc);
      });
    }
    
    // 2. 현재 로그인한 사용자 정보 가져오기 (좋아요 확인 및 프로필 이동에 사용)
    if (_currentUserId != null) {
      final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUserId).get();
      if (currentUserDoc.exists && mounted) {
        final user = UserModel.fromFirestore(currentUserDoc);
        setState(() {
          _currentUserModel = user;
          _isLiked = user.likedShortIds?.contains(widget.short.id) ?? false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _isPlaying.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _isPlaying.value = false;
    } else {
      _controller.play();
      _isPlaying.value = true;
    }
  }

  void _onLikeButtonPressed() {
    if (_currentUserId == null) return;
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likesCount++;
      } else {
        _likesCount--;
      }
    });
    _repository.toggleShortLike(widget.short.id, !_isLiked);
  }

  @override
  Widget build(BuildContext context) {
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
            ValueListenableBuilder<bool>(
              valueListenable: _isPlaying,
              builder: (context, isPlaying, _) {
                return !isPlaying
                    ? Center(
                        child: Icon(Icons.play_arrow,
                            size: 80, color: Colors.white.withOpacity(0.7)))
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

  // [수정] StreamBuilder -> 일반 위젯으로 변경하여 성능 최적화
  Widget _buildVideoInfo() {
    if (_author == null) return const SizedBox.shrink(); // 작성자 정보가 없으면 표시하지 않음
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
        Text(widget.short.description,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                shadows: [Shadow(blurRadius: 2)]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  // [수정] StreamBuilder를 최소화하여 성능 최적화
  Widget _buildActionButtons() {
    if (_currentUserId == null || _author == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- 작성자 프로필 보기 ---
        InkWell(
          onTap: () {
            if (_currentUserModel != null) {
               Navigator.of(context).push(MaterialPageRoute(builder: (_) => FindFriendDetailScreen(user: _author!, currentUserModel: _currentUserModel!)));
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

        // --- 좋아요 기능 ---
        InkWell(
          onTap: _onLikeButtonPressed,
          child: _buildActionButton(
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            label: _likesCount.toString(),
            color: _isLiked ? Colors.red : Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        // --- 댓글 보기 기능 (카운트는 실시간) ---
        StreamBuilder<ShortModel>(
          stream: _repository.getShortStream(widget.short.id),
          builder: (context, shortSnapshot) {
            final liveCommentsCount = shortSnapshot.data?.commentsCount ?? widget.short.commentsCount;
            return InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: ShortCommentsSheet(shortId: widget.short.id),
                  ),
                );
              },
              child: _buildActionButton(
                  icon: Icons.comment,
                  label: liveCommentsCount.toString()),
            );
          }
        ),
        const SizedBox(height: 20),

        _buildActionButton(icon: Icons.share, label: 'pom.share'.tr()),
      ],
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