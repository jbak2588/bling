// lib/features/together/widgets/together_card.dart

import 'package:bling_app/features/together/models/together_post_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TogetherCard extends StatelessWidget {
  final TogetherPostModel post;
  final VoidCallback? onTap;

  const TogetherCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (post.designTheme) {
      case 'neon':
        backgroundColor = const Color(0xFFCCFF00);
        textColor = Colors.black;
        break;
      case 'paper':
        backgroundColor = const Color(0xFFF5F5DC);
        textColor = Colors.brown;
        break;
      case 'dark':
        backgroundColor = const Color(0xFF2C2C2C);
        textColor = const Color(0xFF00FFCC);
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
        width: 160,
        // height: 240, // ✅ [Fix] 고정 높이 제거 (내용물에 따라 유동적, 또는 상위에서 제어)
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(4, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지 영역 (유동적)
                  if (post.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 60, // 기존 70px → 60px (overflow 방지)
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.grey[200],
                        child: Image.network(
                          post.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.grey));
                          },
                        ),
                      ),
                    ),

                  // 여기서부터 텍스트 영역 전체를 Expanded로 감싸 overflow 불가
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // WHAT
                        Text(
                          post.title,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const Spacer(), // ✅ [Fix] 고정 SizedBox 대신 Spacer 사용

                        // WHEN
                        Row(
                          children: [
                            Icon(Icons.access_time_filled,
                                size: 14, color: textColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                formattedTime,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // WHERE
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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // QR 오버레이
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.0),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: textColor, width: 1.0),
                ),
                child: Icon(Icons.qr_code_2, size: 26, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
