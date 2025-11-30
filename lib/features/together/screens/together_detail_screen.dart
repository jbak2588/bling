// lib/features/together/screens/together_detail_screen.dart

import 'package:bling_app/features/together/data/together_repository.dart';
import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:bling_app/features/together/screens/edit_together_screen.dart'; // ✅ 추가
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart'; // ✅ 추가 (공용 위젯 사용)
import 'package:easy_localization/easy_localization.dart'; // ✅ 추가 (다국어 지원)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TogetherDetailScreen extends StatefulWidget {
  final TogetherPostModel post;

  const TogetherDetailScreen({super.key, required this.post});

  @override
  State<TogetherDetailScreen> createState() => _TogetherDetailScreenState();
}

class _TogetherDetailScreenState extends State<TogetherDetailScreen> {
  bool _isJoining = false;
  late bool _isJoined;
  late bool _isHost;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    _isHost = widget.post.hostId == userId;
    _isJoined = widget.post.participants.contains(userId);
  }

  // 테마 색상 헬퍼
  Color _getThemeColor(String theme) {
    switch (theme) {
      case 'neon':
        return const Color(0xFFCCFF00);
      case 'paper':
        return const Color(0xFFF5F5DC);
      case 'dark':
        return const Color(0xFF2C2C2C);
      default:
        return Colors.white;
    }
  }

  Color _getTextColor(String theme) {
    return theme == 'dark' ? const Color(0xFF00FFCC) : Colors.black;
  }

  Future<void> _handleJoin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("together.loginRequired".tr()))); // ✅ 수정
      return;
    }

    setState(() => _isJoining = true);

    try {
      await TogetherRepository().joinPost(
        postId: widget.post.id,
        userId: user.uid,
      );

      if (!mounted) return;

      setState(() {
        _isJoined = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("together.joinSuccess".tr())), // ✅ 수정
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'together.joinFail'.tr(namedArgs: {'error': e.toString()}))));
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  // ✅ [작업 21] 게시글 삭제 로직 (주최자 전용)
  Future<void> _deletePost() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('common.deleteTitle'.tr()),
        content: Text('together.deleteConfirm'.tr()), // ✅ 수정
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('common.delete'.tr(),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await TogetherRepository().deletePost(widget.post.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('together.deleted'.tr())), // ✅ 수정
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'together.deleteFail'.tr(namedArgs: {'error': e.toString()})),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getThemeColor(widget.post.designTheme);
    final txtColor = _getTextColor(widget.post.designTheme);
    final dateStr =
        DateFormat('yyyy.MM.dd HH:mm').format(widget.post.meetTime.toDate());

    return Scaffold(
      backgroundColor: Colors.grey[100], // 배경은 깔끔하게
      appBar: AppBar(
        title: Text("together.detailTitle".tr()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        // ✅ [작업 21] 주최자 전용 수정/삭제 버튼 추가
        actions: [
          if (_isHost) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AppBarIcon(
                icon: Icons.edit_outlined,
                onPressed: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (_) => EditTogetherScreen(post: widget.post),
                    ),
                  )
                      .then((_) {
                    setState(() {});
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AppBarIcon(
                icon: Icons.delete_outline,
                onPressed: _deletePost,
              ),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. 전단지 본문 (Flyer)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    offset: const Offset(8, 8),
                    blurRadius: 10,
                  ),
                ],
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // QR Stamp (상단 배치)
                  Align(
                    alignment: Alignment.topRight,
                    child: Opacity(
                      opacity: 0.8,
                      child: Icon(Icons.qr_code_2, size: 60, color: txtColor),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    widget.post.title,
                    style: TextStyle(
                      color: txtColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Info Rows
                  _buildInfoRow(Icons.calendar_today, "together.labelWhen".tr(),
                      dateStr, txtColor),
                  const SizedBox(height: 20),
                  _buildInfoRow(Icons.location_on, "together.labelWhere".tr(),
                      widget.post.location, txtColor),
                  const SizedBox(height: 20),
                  _buildInfoRow(Icons.info_outline, "together.labelWhat".tr(),
                      widget.post.description, txtColor),

                  const SizedBox(height: 40),

                  // Participants Count
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: txtColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people, color: txtColor),
                        const SizedBox(width: 8),
                        Text(
                          "together.participants".tr(namedArgs: {
                            'current': '${widget.post.participants.length}',
                            'max': '${widget.post.maxParticipants}'
                          }),
                          style: TextStyle(
                              color: txtColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 2. 하단 액션 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    (_isHost || _isJoined || _isJoining) ? null : _handleJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isJoining
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isHost
                            ? "together.statusHost".tr()
                            : _isJoined
                                ? "together.statusJoined".tr()
                                : "together.btnJoin".tr(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    color: color.withValues(alpha: 0.70),
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                    color: color, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
