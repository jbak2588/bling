/// ============================================================================
/// Bling 공용 위젯: ImageCarouselCard
/// 파일: lib/features/shared/widgets/image_carousel_card.dart
///
/// 목적:
/// 이 위젯은 ListView와 같은 목록형 UI 내의 작은 카드(예: PostCard, ProductCard)에
/// 포함되어, 여러 장의 이미지를 보여주는 '미리보기'용 캐러셀(이미지 슬라이더)입니다.
///
/// 핵심 기능:
/// - 좌우 스와이프를 통한 이미지 넘김 기능
/// - '현재 페이지 / 전체 페이지' (예: '3/5') 형태의 카운터 오버레이 표시
/// - 목록 스크롤 시에도 페이지 상태를 안정적으로 유지
///
/// 사용 화면:
/// - local_news_screen.dart (PostCard 내부)
/// - marketplace_screen.dart (ProductCard 내부)
/// - jobs_screen.dart (JobCard 내부) 등
/// ============================================================================
//
// 중요 사용법 ★★★
// TabBarView 내 ListView에서 발생할 수 있는 '상태 소멸' 및 '자동 슬라이딩' 버그를
// 방지하려면 아래 규칙을 반드시 준수해야 합니다.
//
// 1. [필수] storageId 전달:
//    각 캐러셀의 상태를 고유하게 식별하기 위해 게시물 ID와 같은 고유 값을
//    storageId 파라미터로 반드시 전달해야 합니다.
//    (예: storageId: post.id)
//
// 2. [필수] 부모 카드 위젯(PostCard 등)에 KeepAlive 적용:
//    이 위젯을 사용하는 부모 카드는 반드시 StatefulWidget이어야 하며,
//    'with AutomaticKeepAliveClientMixin'을 사용하여 상태를 보존해야 합니다.
//    이렇게 해야 탭이 전환될 때 카드의 상태가 파괴되지 않습니다.
//
// 3. [내부 구현] PageController의 keepPage: false:
//    위젯 내부적으로 페이지 상태를 자동 복원하지 않도록 설정되어 있습니다.
//    이는 목록이 다시 그려질 때, 다른 카드의 페이지 위치를 잘못 가져오는
//    '상태 공유' 현상을 원천적으로 차단합니다.
//
// ### 올바른 사용 예시 (PostCard.dart 내부):
//
// // 1. PostCard를 StatefulWidget + AutomaticKeepAliveClientMixin으로 선언
// class _PostCardState extends State<PostCard> with AutomaticKeepAliveClientMixin {
//
//   @override
//   bool get wantKeepAlive => true; // 상태 유지 선언
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // super.build 호출
//     // ...
//     ImageCarouselCard(
//       storageId: post.id, // 2. 고유 ID 전달
//       imageUrls: post.mediaUrl!,
//     );
//     // ...
//   }
// }
// ============================================================================
library;

// lib/features/shared/widgets/image_carousel_card.dart

import 'package:flutter/material.dart';
import 'package:bling_app/features/shared/screens/image_gallery_screen.dart';

class ImageCarouselCard extends StatefulWidget {
  final List<String> imageUrls;
  final double? width;
  final double height;
  final String storageId;

  const ImageCarouselCard({
    super.key,
    required this.imageUrls,
    required this.storageId,
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
    _pageController = PageController(initialPage: 0, keepPage: false);
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

    if (imageUrls.length <= 1) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImageItem(
              imageUrls.isNotEmpty
                  ? imageUrls.first
                  : 'https://via.placeholder.com/100',
              0,
              context),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            key: PageStorageKey('img-carousel:${widget.storageId}'),
            controller: _pageController,
            itemCount: imageUrls.length,
            onPageChanged: (index) {
              if (!mounted) return;
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageItem(imageUrls[index], index, context),
              );
            },
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.6),
                borderRadius: BorderRadius.circular(16),
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

  // [v2.2] InteractiveViewer 기반 핀치-줌은 PageView와 제스처 충돌을 일으켜
  // 목록 뷰에서 불안정한 동작을 유발합니다. 따라서 캐러셀에서는 간단한 이미지
  // 뷰(탭 시 전체화면 갤러리로 이동)를 제공하고, 확대/상세보기는
  // `ImageGalleryScreen`에 위임합니다.
  Widget _buildImageItem(String url, int index, BuildContext context) {
    final imageWidget = Image.network(
      url,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => Container(
          color: Colors.grey.shade100, child: const Icon(Icons.broken_image)),
    );

    // Avoid nesting Hero widgets: if an ancestor Hero exists, do not wrap.
    final wrappedImage = context.findAncestorWidgetOfExactType<Hero>() == null
        ? Hero(tag: url, child: imageWidget)
        : imageWidget;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ImageGalleryScreen(
            imageUrls: widget.imageUrls,
            initialIndex: index,
          ),
        ));
      },
      child: wrappedImage,
    );
  }
}
