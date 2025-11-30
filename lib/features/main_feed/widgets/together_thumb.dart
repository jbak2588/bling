import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:bling_app/features/together/widgets/together_card.dart';
import 'package:flutter/material.dart';

class TogetherThumb extends StatelessWidget {
  final TogetherPostModel post;
  final Function(Widget, String) onIconTap;

  const TogetherThumb({
    super.key,
    required this.post,
    required this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    // 기존 TogetherCard를 재활용하되, MainFeed에 맞는 크기 제어
    return SizedBox(
      width: 160,
      child: TogetherCard(
        post: post,
        onTap: () {
          // 썸네일 탭 시, 상세 화면으로 이동하거나
          // TogetherScreen으로 이동하도록 설정 가능
          // 여기서는 간단히 카드를 눌렀을 때의 동작을 정의
        },
      ),
    );
  }
}
