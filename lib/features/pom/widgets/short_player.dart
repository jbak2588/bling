// lib/features/pom/widgets/short_player.dart

import 'package:bling_app/core/models/short_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/screens/find_friend_detail_screen.dart';
import 'package:bling_app/features/pom/data/short_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final ShortRepository _repository = ShortRepository();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.short.videoUrl))
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        if (mounted) setState(() => _isPlaying = true);
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
        _controller.pause(); _isPlaying = false;
      } else {
        _controller.play(); _isPlaying = true;
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
            if (!_isPlaying) Center(child: Icon(Icons.play_arrow, size: 80, color: Colors.white.withValues(alpha:0.7))),
            
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
      stream: FirebaseFirestore.instance.collection('users').doc(widget.short.userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
        final user = UserModel.fromFirestore(snapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('@${user.nickname}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(blurRadius: 2)])),
            const SizedBox(height: 8),
            Text(widget.short.description, style: const TextStyle(color: Colors.white, fontSize: 15, shadows: [Shadow(blurRadius: 2)]), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        );
      }
    );
  }

  Widget _buildActionButtons() {
    if (_currentUserId == null) return const SizedBox.shrink();

    return StreamBuilder<ShortModel>(
      stream: _repository.getShortStream(widget.short.id),
      builder: (context, shortSnapshot) {
        if (!shortSnapshot.hasData) return const SizedBox.shrink();
        final liveShort = shortSnapshot.data!;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(widget.short.userId).snapshots(),
              builder: (context, userSnapshot) {
                 if (!userSnapshot.hasData) return const CircleAvatar(radius: 24);
                 final user = UserModel.fromFirestore(userSnapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
                 return InkWell(
                    onTap: () async {
                      final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUserId).get();
                      if (currentUserDoc.exists && mounted) {
                        final currentUser = UserModel.fromFirestore(currentUserDoc);
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => FindFriendDetailScreen(user: user, currentUserModel: currentUser)));
                      }
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty) ? NetworkImage(user.photoUrl!) : null,
                      child: (user.photoUrl == null || user.photoUrl!.isEmpty) ? const Icon(Icons.person) : null,
                    ),
                 );
              }
            ),
            const SizedBox(height: 24),
            
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(_currentUserId).snapshots(),
              builder: (context, userSnapshot) {
                bool isLiked = false;
                if(userSnapshot.hasData && userSnapshot.data!.exists){
                  final user = UserModel.fromFirestore(userSnapshot.data! as DocumentSnapshot<Map<String, dynamic>>);
                  isLiked = user.likedShortIds?.contains(widget.short.id) ?? false;
                }
                return InkWell(
                  onTap: () => _repository.toggleShortLike(widget.short.id, isLiked),
                  child: _buildActionButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    label: liveShort.likesCount.toString(),
                    color: isLiked ? Colors.red : Colors.white,
                  ),
                );
              }
            ),
            const SizedBox(height: 20),
            
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("댓글 기능은 아직 준비중입니다.")));
              },
              child: _buildActionButton(icon: Icons.comment, label: liveShort.commentsCount.toString()),
            ),
            const SizedBox(height: 20),
            
            _buildActionButton(icon: Icons.share, label: 'pom.share'.tr()),
          ],
        );
      }
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, Color color = Colors.white}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32, shadows: const [Shadow(blurRadius: 2)]),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, shadows: [Shadow(blurRadius: 2)])),
      ],
    );
  }
}