import 'package:url_launcher/url_launcher.dart';
// lib/features/together/screens/together_detail_screen.dart
// 공용 링크 상수 사용 안내: 공유 및 딥링크 생성 시 `lib/core/constants/app_links.dart`의
// `kHostingBaseUrl` 상수를 사용하세요.

import 'package:bling_app/features/together/data/together_repository.dart';
import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:bling_app/features/together/screens/edit_together_screen.dart'
    as edit_screen; // import with prefix to avoid symbol collisions
import 'package:bling_app/core/models/bling_location.dart';
import 'package:bling_app/features/shared/widgets/app_bar_icon.dart'; // ✅ 추가 (공용 위젯 사용)
import 'package:easy_localization/easy_localization.dart'; // ✅ 추가 (다국어 지원)
import 'package:share_plus/share_plus.dart';
import 'package:bling_app/core/constants/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/my_bling/screens/my_bling_screen.dart';
import 'package:bling_app/features/together/screens/ticket_scan_screen.dart'; // ✅ 추가
import 'package:bling_app/features/shared/widgets/mini_map_view.dart'; // ✅ 미니맵 위젯 추가

// Helper: open external map for a given lat/lng
Future<void> _openMap(double lat, double lng) async {
  final Uri googleMapsUrl =
      Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
  if (await canLaunchUrl(googleMapsUrl)) {
    await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
  }
}

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

      // ✅ [작업 26] 참여 성공 시 팝업으로 안내 (UX 변경)
      showDialog(
        context: context,
        barrierDismissible: false, // 확인 버튼을 눌러야만 닫힘
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.confirmation_number_outlined,
                  color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'together.joinSuccess'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'together.joinSuccess'.tr(),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx); // 팝업 닫기
                // 사용자의 UserModel을 불러와서 MyBlingScreen으로 이동
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null) return;
                try {
                  final doc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .get();
                  if (!doc.exists) return;
                  final userModel = UserModel.fromFirestore(doc);
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyBlingScreen(
                        userModel: userModel,
                        onIconTap: (page, title) {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (_) => page));
                        },
                      ),
                    ),
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('together.joinFail'
                            .tr(namedArgs: {'error': e.toString()})),
                      ),
                    );
                  }
                }
              },
              child: Text('myBling.tickets'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // 팝업 닫기
              },
              child: Text('common.close'.tr()),
            ),
          ],
        ),
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
    final meetLoc = widget.post.meetLocation ??
        (widget.post.geoPoint != null
            ? BlingLocation(
                geoPoint: widget.post.geoPoint!,
                mainAddress: widget.post.location)
            : null);

    final locationText = meetLoc?.mainAddress ?? widget.post.location;

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
                      builder: (_) =>
                          edit_screen.EditTogetherScreen(post: widget.post),
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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: AppBarIcon(
              icon: Icons.share,
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                    text:
                        '${widget.post.title}\n$kHostingBaseUrl/together/${widget.post.id}'),
              ),
            ),
          ),
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

                  // Image banner (optional)
                  if (widget.post.imageUrl != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 160,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          widget.post.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(
                            color: Colors.grey[200],
                            child:
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

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
                      locationText, txtColor),
                  const SizedBox(height: 20),
                  _buildInfoRow(Icons.info_outline, "together.labelWhat".tr(),
                      widget.post.description, txtColor),

                  // ✅ [작업 32] 상세 화면에서 지도 표시
                  if (widget.post.geoPoint != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: txtColor.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(11), // border inside
                        child: GestureDetector(
                          onTap: () => _openMap(widget.post.geoPoint!.latitude,
                              widget.post.geoPoint!.longitude),
                          child: AbsorbPointer(
                            child: MiniMapView(
                              location: widget.post.geoPoint!,
                              markerId: widget.post.id,
                              height: 140,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

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
                // ✅ [수정] 주최자면 스캔 기능 활성화, 아니면 기존 로직
                onPressed: _isHost
                    ? () {
                        // ✅ 주최자: QR 스캐너 실행
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TicketScanScreen(eventId: widget.post.id),
                          ),
                        );
                      }
                    : (_isJoined || _isJoining)
                        ? null // 참여자는 버튼 비활성 (티켓함에서 확인)
                        : _handleJoin, // 미참여자는 참여 로직
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isJoining
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isHost) ...[
                            const Icon(Icons.qr_code_scanner, size: 24),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _isHost
                                ? "together.scanBtn".tr()
                                : _isJoined
                                    ? "together.statusJoined".tr()
                                    : "together.btnJoin".tr(),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
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
