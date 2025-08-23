// 파일 경로: lib/features/pom/widgets/short_player.dart

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
  // [신규] pom_screen.dart로부터 현재 사용자 정보를 직접 전달받기 위한 파라미터
  final UserModel? userModel; 
  
  const ShortPlayer({super.key, required this.short, this.userModel}); // [수정] 생성자에 userModel 추가

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

  // [유지] DB 조회를 최소화하기 위한 상태 변수는 그대로 유지합니다.
  UserModel? _author;
  // [수정] _currentUserModel은 이제 외부(widget.userModel)에서 주입받습니다.
  UserModel? _currentUserModel;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.short.likesCount;
    
    // [업그레이드] 
    // 1. 외부에서 받은 userModel을 현재 사용자 모델로 즉시 설정합니다.
    _currentUserModel = widget.userModel; 
    // 2. 나머지 초기 데이터를 불러옵니다.
    _fetchInitialData(); 

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

  // [업그레이드] 이제 이 함수는 '작성자' 정보만 불러오거나, 
  // 외부에서 userModel을 받지 못한 비상시에만 현재 사용자 정보를 불러옵니다.
  Future<void> _fetchInitialData() async {
    // 1. 동영상 작성자 정보 가져오기 (기존 로직 유지)
    final authorDoc = await FirebaseFirestore.instance.collection('users').doc(widget.short.userId).get();
    if (authorDoc.exists && mounted) {
      setState(() {
        _author = UserModel.fromFirestore(authorDoc);
      });
    }
    
    // 2. 현재 로그인한 사용자 정보 처리
    if (_currentUserModel != null) {
      // 이미 외부에서 userModel을 받았다면, '좋아요' 상태만 갱신합니다.
      if (mounted) {
        setState(() {
          _isLiked = _currentUserModel!.likedShortIds?.contains(widget.short.id) ?? false;
        });
      }
    } else if (_currentUserId != null) {
      // 외부에서 userModel을 받지 못한 경우에만, 기존 방식대로 DB에서 직접 가져옵니다.
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
    // [유지] build 메서드의 모든 UI 로직은 보스의 최적화된 코드를 그대로 유지합니다.
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
                            size: 80, color: Colors.white.withValues(alpha:0.7)))
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
  
  Widget _buildVideoInfo() {
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
        Text(widget.short.description, // null safety 추가
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
    if (_currentUserId == null || _author == null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        InkWell(
          onTap: _onLikeButtonPressed,
          child: _buildActionButton(
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            label: _likesCount.toString(),
            color: _isLiked ? Colors.red : Colors.white,
          ),
        ),
        const SizedBox(height: 20),
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