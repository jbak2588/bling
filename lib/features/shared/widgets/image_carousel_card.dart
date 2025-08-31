// ============================================================================
// Bling 공용 위젯: ImageCarouselCard
// 파일: lib/features/shared/widgets/image_carousel_card.dart
//
// 목적:
// 이 위젯은 ListView와 같은 목록형 UI 내의 작은 카드(예: PostCard, ProductCard)에
// 포함되어, 여러 장의 이미지를 보여주는 '미리보기'용 캐러셀(이미지 슬라이더)입니다.
//
// 핵심 기능:
// - 좌우 스와이프를 통한 이미지 넘김 기능
// - '현재 페이지 / 전체 페이지' (예: '3/5') 형태의 카운터 오버레이 표시
// - 목록 스크롤 시에도 페이지 상태를 안정적으로 유지
//
// 사용 화면:
// - local_news_screen.dart (PostCard 내부)
// - marketplace_screen.dart (ProductCard 내부)
// - jobs_screen.dart (JobCard 내부) 등
// ============================================================================

import 'package:flutter/material.dart';

class ImageCarouselCard extends StatefulWidget {
  final List<String> imageUrls;
  final double? width;
  final double height;

  const ImageCarouselCard({
    super.key,
    required this.imageUrls,
    this.width = double.infinity,
    this.height = 180.0,
  });

  @override
  State<ImageCarouselCard> createState() => _ImageCarouselCardState();
}

class _ImageCarouselCardState extends State<ImageCarouselCard> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _currentPage = 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.imageUrls;

    // 디버그: 이미지 배열 정보 출력
    // print('[ImageCarouselCard] imageUrls count: ${imageUrls.length}');
    // print('[ImageCarouselCard] imageUrls: $imageUrls');

    if (imageUrls.length <= 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrls.isNotEmpty ? imageUrls.first : 'https://via.placeholder.com/100',
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.shade100,
            child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey.shade700),
          ),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.bottomRight, // 오버레이 위치 명확히 지정
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: imageUrls.length,
            onPageChanged: (index) {
              if (mounted) {
                setState(() {
                  _currentPage = index;
                });
              }
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrls[index],
                  width: widget.width,
                  height: widget.height,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade100),
                ),
              );
            },
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.6),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                '${_currentPage + 1} / ${imageUrls.length}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}