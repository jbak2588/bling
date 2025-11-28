import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:bling_app/features/jobs/models/talent_model.dart';
import 'package:bling_app/features/jobs/data/talent_repository.dart';
import 'package:bling_app/features/jobs/screens/edit_talent_screen.dart';
import 'package:bling_app/core/utils/popups/snackbars.dart';

class TalentDetailScreen extends StatelessWidget {
  final TalentModel talent;

  const TalentDetailScreen({super.key, required this.talent});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = user != null && user.uid == talent.userId;
    final repo = TalentRepository();

    void deletePost() async {
      // 삭제 확인 다이얼로그
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('정말 이 재능을 삭제하시겠습니까?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('취소')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('삭제', style: TextStyle(color: Colors.red))),
          ],
        ),
      );

      if (confirm == true) {
        await repo.deleteTalent(talent.id);
        if (context.mounted) {
          Navigator.pop(context); // 상세 화면 닫기
          BArtSnackBar.showSuccessSnackBar(title: '완료', message: '삭제되었습니다.');
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('재능 상세'),
        actions: [
          if (isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditTalentScreen(talent: talent)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deletePost,
            ),
          ]
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 슬라이더 (구현 생략, PageView 사용 권장)
            if (talent.portfolioUrls.isNotEmpty)
              SizedBox(
                height: 250,
                child: Image.network(talent.portfolioUrls.first,
                    fit: BoxFit.cover, width: double.infinity),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(talent.title,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${NumberFormat('#,###').format(talent.price)} / ${talent.priceUnit}',
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text('상세 설명',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(talent.description),
                  const SizedBox(height: 24),
                  // 위치 정보
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(talent.locationName ?? '위치 정보 없음',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: isOwner
                ? null
                : () {
                    // 채팅하기 또는 구매하기 로직 연결
                    BArtSnackBar.showSuccessSnackBar(
                        title: '테스트', message: '구매/채팅 기능은 추후 구현됩니다.');
                  },
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('문의하기'),
          ),
        ),
      ),
    );
  }
}
