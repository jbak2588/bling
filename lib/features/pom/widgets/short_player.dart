// lib/features/pom/widgets/short_player.dart

// ignore_for_file: deprecated_member_use

import 'package:bling_app/core/models/short_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:easy_localization/easy_localization.dart';

class ShortPlayer extends StatefulWidget {
  final ShortModel short;
  const ShortPlayer({super.key, required this.short});

  @override
  State<ShortPlayer> createState() => _ShortPlayerState();
}

class _ShortPlayerState extends State<ShortPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.short.videoUrl))
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
        }
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(
          children: [
            // --- 1. 비디오 플레이어 (배경) ---
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
            
            // --- 2. 재생/일시정지 아이콘 (중앙) ---
            if (!_isPlaying)
              Center(child: Icon(Icons.play_arrow, size: 80, color: Colors.white.withOpacity(0.7))),

            // --- 3. UI 오버레이 (하단 정보 및 우측 버튼) ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // --- 3-1. 좌측 하단 (작성자, 캡션 정보) ---
                      Expanded(
                        child: _buildVideoInfo(),
                      ),
                      // --- 3-2. 우측 (좋아요, 댓글, 공유 버튼) ---
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

  // [수정] 좌측 하단 정보 위젯
  Widget _buildVideoInfo() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.short.userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final user = UserModel.fromFirestore(snapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '@${user.nickname}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            // V V V --- [수정] 'caption' -> 'description'으로 변경 --- V V V
            Text(
              widget.short.description,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
          ],
        );
      }
    );
  }

  // [수정] 우측 액션 버튼 위젯
  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TODO: 작성자 프로필 보기 기능 연결
        const CircleAvatar(radius: 24, child: Icon(Icons.person)),
        const SizedBox(height: 24),
        // TODO: 좋아요 기능 연결
        _buildActionButton(icon: Icons.favorite, label: widget.short.likesCount.toString()),
        const SizedBox(height: 20),
        // TODO: 댓글 보기 기능 연결
        // V V V --- [수정] 'commentsCount' 대신 임시로 '0'을 표시합니다 --- V V V
        _buildActionButton(icon: Icons.comment, label: widget.short.commentsCount.toString()),
        // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^
        const SizedBox(height: 20),
        _buildActionButton(icon: Icons.share, label: 'pom.share'.tr()),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }
}