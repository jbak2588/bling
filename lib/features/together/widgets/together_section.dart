// lib/features/together/widgets/together_section.dart

import 'package:bling_app/features/together/data/together_repository.dart';
import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:bling_app/features/together/widgets/together_card.dart';
import 'package:bling_app/features/together/screens/create_together_screen.dart'; // 다음 단계 파일
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ 추가

class TogetherSection extends StatelessWidget {
  const TogetherSection({super.key});

  @override
  Widget build(BuildContext context) {
    final TogetherRepository repository = TogetherRepository();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "together.sectionTitle".tr(), // ✅ 수정: "Together / 함께 해요"
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  // 생성 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CreateTogetherScreen()),
                  );
                },
              ),
            ],
          ),
        ),

        // 가로 스크롤 리스트
        SizedBox(
          height: 220, // 카드 높이 확보
          child: StreamBuilder<List<TogetherPostModel>>(
            stream: repository.fetchActivePosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final posts = snapshot.data ?? [];

              if (posts.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: posts.length +
                    1, // +1 for 'Create New' card at the end or start
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildCreateNewCard(context);
                  }
                  final post = posts[index - 1];
                  return TogetherCard(
                    post: post,
                    onTap: () {
                      // TODO: 상세 화면 또는 참여 바텀시트 띄우기
                      _showJoinDialog(context, post);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // '새로 만들기' 전용 카드
  Widget _buildCreateNewCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateTogetherScreen()),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: Colors.grey, style: BorderStyle.values[1]), // 점선 느낌(흉내)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              "New\nFlyer",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("together.emptyList".tr(), textAlign: TextAlign.center),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateTogetherScreen()),
              );
            },
            child: Text("together.createFirst".tr()),
          )
        ],
      ),
    );
  }

  // 임시 참여 다이얼로그 (상세 화면 개발 전 테스트용)
  void _showJoinDialog(BuildContext context, TogetherPostModel post) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(post.title),
              content: Text("together.joinConfirm".tr()),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("common.cancel".tr())),
                TextButton(
                    onPressed: () async {
                      // Repository join 호출 로직 연결 필요
                      Navigator.pop(context);
                    },
                    child: Text("together.btnJoin".tr())),
              ],
            ));
  }
}
