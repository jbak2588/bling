import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/together/data/together_repository.dart';
import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:bling_app/features/together/widgets/together_card.dart';
import 'package:bling_app/features/together/screens/together_detail_screen.dart'; // ✅ 추가
import 'package:flutter/material.dart';

class TogetherScreen extends StatelessWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;

  const TogetherScreen({super.key, this.userModel, this.locationFilter});

  @override
  Widget build(BuildContext context) {
    final repository = TogetherRepository();

    // TODO: locationFilter를 Repository 쿼리에 반영하려면 Repository 수정 필요 (현재는 전체 조회)
    // repository.fetchActivePosts(locationFilter: locationFilter);

    return StreamBuilder<List<TogetherPostModel>>(
      stream: repository.fetchActivePosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.volunteer_activism,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  "아직 등록된 모임이 없어요.\n첫 번째 모임을 주최해보세요!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          separatorBuilder: (ctx, idx) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            // 전단지 카드를 리스트 형태로 큼직하게 보여줍니다.
            return SizedBox(
              height: 200, // 세로 리스트이므로 높이 고정 혹은 aspect ratio 사용
              child: TogetherCard(
                post: posts[index],
                onTap: () {
                  // ✅ [작업 20] 상세 화면 이동 연결
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TogetherDetailScreen(post: posts[index]),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
