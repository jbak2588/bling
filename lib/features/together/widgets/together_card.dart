// lib/features/together/widgets/together_card.dart

import 'package:bling_app/features/together/models/together_post_model.dart';
// import 'package:bling_app/features/together/data/together_repository.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TogetherCard extends StatelessWidget {
  final TogetherPostModel post;
  final VoidCallback? onTap;

  const TogetherCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    // 테마별 배경색 설정 (하드코딩된 예시, 추후 디자인 고도화 가능)
    Color backgroundColor;
    Color textColor;

    switch (post.designTheme) {
      case 'neon':
        backgroundColor = const Color(0xFFCCFF00); // 형광 라임
        textColor = Colors.black;
        break;
      case 'paper':
        backgroundColor = const Color(0xFFF5F5DC); // 베이지색 종이
        textColor = Colors.brown;
        break;
      case 'dark':
        backgroundColor = const Color(0xFF2C2C2C);
        textColor = const Color(0xFF00FFCC); // 형광 민트
        break;
      default:
        backgroundColor = Colors.white;
        textColor = Colors.black;
    }

    final formattedTime =
        DateFormat('MM/dd HH:mm').format(post.meetTime.toDate());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160, // 가로 스크롤 카드 너비
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(2), // 투박한 전단지 느낌 (둥근 모서리 최소화)
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(4, 4), // 그림자를 깊게 주어 붕 뜬 느낌
              blurRadius: 4,
            ),
          ],
          border: Border.all(color: Colors.black, width: 1.5), // 검은 테두리 강조
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. WHAT (제목)
            Text(
              post.title,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w900, // 가장 굵게
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // 2. WHEN (시간)
            Row(
              children: [
                Icon(Icons.access_time_filled, size: 14, color: textColor),
                const SizedBox(width: 4),
                Text(
                  formattedTime,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // 3. WHERE (장소)
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: textColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    post.location,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 4. QR Stamp (참여 상징)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: textColor, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.qr_code_2, size: 32, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
