// ============================================================================
// Bling 공용 화면: ImageGalleryScreen
// 파일: lib/features/shared/screens/image_gallery_screen.dart
//
// 목적:
// 이 위젯은 사용자가 게시물이나 상품의 이미지를 클릭했을 때, 이미지를 상세하게
// 보여주는 '전체 화면' 갤러리입니다.
//
// 핵심 기능:
// - 스마트폰 화면 전체를 사용하여 이미지를 크게 표시
// - 핀치-투-줌(Pinch-to-zoom)을 통한 이미지 확대/축소 기능
// - 좌우 스와이프로 여러 이미지 간 이동
//
// 사용 화면:
// - local_news_detail_screen.dart
// - product_detail_screen.dart
// - job_detail_screen.dart 등 이미지를 상세히 보여줘야 하는 모든 화면
// ============================================================================

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageGalleryScreen extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageGalleryScreen({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PhotoViewGallery.builder(
        itemCount: imageUrls.length,
        pageController: PageController(initialPage: initialIndex),
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}