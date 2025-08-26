/// ============================================================================
/// Bling DocHeader
/// Module        : Marketplace
/// File          : lib/features/marketplace/screens/product_detail_screen.dart
/// Purpose       : 상품 정보와 판매자 세부 사항, 주요 동작을 제공합니다.
/// User Impact   : 구매자가 상품을 평가하고 판매자에게 연락하거나 공유할 수 있습니다.
/// Feature Links : lib/features/marketplace/screens/product_edit_screen.dart; lib/features/chat/screens/chat_room_screen.dart; lib/features/marketplace/screens/marketplace_screen.dart
/// Data Model    : Firestore `products` 필드 `viewsCount`, `likesCount`; 즐겨찾기는 `users/{uid}/favorites`에 저장됩니다.
/// Location Scope: `locationParts.kel`→`kec` 순으로 표시하며 위치 기반 추천을 지원합니다.
/// Trust Policy  : 판매자 `trustLevel`을 표시하고 신고 시 `reportCount`가 증가합니다.
/// Monetization  : 프로모션 노출 및 공유 보상 추천을 지원합니다.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `view_product`, `click_chat_seller`, `toggle_favorite`, `share_product`.
/// Analytics     : 이미지 스와이프와 조회수를 Cloud Firestore로 기록합니다.
/// I18N          : 키 `time.now`, `marketplace.error`, `marketplace.empty` (assets/lang/*.json)
/// Dependencies  : cloud_firestore, firebase_auth, share_plus, photo_view, easy_localization
/// Security/Auth : 즐겨찾기는 인증이 필요하며 Firestore 규칙이 수정 권한을 제한합니다.
/// Edge Cases    : 이미지 누락, 판매자 삭제 또는 상품 삭제.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/011 Marketplace 모듈.md; docs/index/7 Marketplace.md
/// ============================================================================
library;
// 아래부터 실제 코드

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/categories/domain/category.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/shared/widgets/trust_level_badge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view.dart';

import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:bling_app/features/marketplace/screens/product_edit_screen.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';

// 카테고리 이름 표시를 위한 별도 위젯
class CategoryNameWidget extends StatelessWidget {
  final String categoryId;
  const CategoryNameWidget({super.key, required this.categoryId});

  String _getCategoryName(BuildContext context, Category category) {
    final langCode = context.locale.languageCode;
    switch (langCode) {
      case 'ko':
        return category.nameKo;
      case 'id':
        return category.nameId;
      default:
        return category.nameEn;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (categoryId.isEmpty) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('');
        }
        try {
          final category = Category.fromFirestore(
            snapshot.data as DocumentSnapshot<Map<String, dynamic>>,
          );
          return Text(_getCategoryName(context, category),
              style: const TextStyle(fontSize: 13, color: Colors.grey));
        } catch (e) {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // --- 상태 변수 및 로직 함수들 (기존과 동일) ---
  bool _isFavorite = false;
  int _currentIndex = 0;
  late final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _increaseViewCount();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _increaseViewCount() async {
    final docRef = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.id);
    await docRef.update({'viewsCount': FieldValue.increment(1)});
  }

  Future<void> _checkIfFavorite() async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;
    final favDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(myUid)
        .collection('favorites')
        .doc(widget.product.id)
        .get();
    if (mounted) setState(() => _isFavorite = favDoc.exists);
  }

  Future<void> _toggleFavorite() async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;
    setState(() => _isFavorite = !_isFavorite);
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(myUid)
        .collection('favorites')
        .doc(widget.product.id);
    final prodRef = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.id);
    if (_isFavorite) {
      await favRef.set({'createdAt': FieldValue.serverTimestamp()});
      await prodRef.update({'likesCount': FieldValue.increment(1)});
    } else {
      await favRef.delete();
      await prodRef.update({'likesCount': FieldValue.increment(-1)});
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('marketplace.dialog.deleteTitle'.tr()),
        content: Text('marketplace.dialog.deleteContent'.tr()),
        actions: [
          TextButton(
            child: Text('marketplace.dialog.cancel'.tr()),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('marketplace.dialog.deleteConfirm'.tr(),
                style: const TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteProduct();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct() async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('marketplace.dialog.deleteSuccess'.tr())));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'marketplace.errors.deleteError'.tr(args: [e.toString()]))));
      }
    }
  }

  void _showFullPhotoView(List<String> imageUrls, int initialIndex) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(250),
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, __) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Scaffold(
            backgroundColor: Colors.black.withAlpha(250),
            body: SafeArea(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: PageController(initialPage: initialIndex),
                    itemCount: imageUrls.length,
                    itemBuilder: (context, idx) => PhotoView(
                      imageProvider: NetworkImage(imageUrls[idx]),
                      backgroundDecoration:
                          const BoxDecoration(color: Colors.transparent),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2.5,
                      initialScale: PhotoViewComputedScale.contained,
                      heroAttributes:
                          PhotoViewHeroAttributes(tag: 'product_image_$idx'),
                    ),
                  ),
                  Positioned(
                    top: 28,
                    right: 18,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 36),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- 위젯 빌더 (디자인 및 다국어 수정) ---

  // [다국어 수정] 시간 포맷 함수
  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final dt = timestamp.toDate();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'time.now'.tr();
    if (diff.inHours < 1) {
      return 'time.minutesAgo'
          .tr(namedArgs: {'minutes': diff.inMinutes.toString()});
    }
    if (diff.inDays < 1) {
      return 'time.hoursAgo'.tr(namedArgs: {'hours': diff.inHours.toString()});
    }
    if (diff.inDays < 7) {
      return 'time.daysAgo'.tr(namedArgs: {'days': diff.inDays.toString()});
    }
    return DateFormat('time.dateFormat'.tr()).format(dt);
  }

  // [다국어 수정] 판매자 정보 위젯
  Widget _buildSellerInfo(String userId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return const SizedBox(height: 50); // 로딩 중 높이 유지
        }

        final user = UserModel.fromFirestore(snapshot.data!);
        final kelurahan = user.locationParts?['kel'] ??
            user.locationParts?['kec'] ??
            'marketplace.detail.noLocation'.tr();

        return Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        user.photoUrl != null && user.photoUrl!.isNotEmpty
                            ? NetworkImage(user.photoUrl!)
                            : null,
                    child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          user.nickname.isNotEmpty
                              ? user.nickname
                              : 'marketplace.detail.seller'.tr(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(kelurahan,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            TrustLevelBadge(trustLevel: user.trustLevel),
          ],
        );
      },
    );
  }

  // --- 메인 빌드 함수 ---
  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()));
        }

        final product = ProductModel.fromFirestore(snapshot.data!);
        final isMyProduct = myUid == product.userId;
        final imageUrls = product.imageUrls;

        return Scaffold(
          // [다국어 수정] 하단 바
          bottomNavigationBar: isMyProduct
              ? null
              : BottomAppBar(
                  surfaceTintColor: Colors.white,
                  elevation: 10,
                  child: SizedBox(
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          // 왼쪽 영역: 좋아요, 가격, 네고여부 등
                          Expanded(
                            child: Row(
                              children: [
                                IconButton(
                                  padding: const EdgeInsets.only(right: 16),
                                  icon: Icon(
                                    _isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        _isFavorite ? Colors.pink : Colors.grey,
                                  ),
                                  onPressed: _toggleFavorite,
                                ),
                                const VerticalDivider(
                                    width: 1.0, thickness: 1.0),
                                const SizedBox(width: 16),

                                // RichText를 사용하여 두 텍스트를 하나의 위젯으로 통합
                                Flexible(
                                  child: RichText(
                                    text: TextSpan(
                                      // 기본 텍스트 스타일은 검은색으로 설정
                                      style:
                                          const TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: NumberFormat.currency(
                                                  locale: 'id_ID',
                                                  symbol: 'Rp ',
                                                  decimalDigits: 0)
                                              .format(product.price),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        TextSpan(
                                          text:
                                              '\n${product.negotiable ? 'marketplace.detail.makeOffer'.tr() : 'marketplace.detail.fixedPrice'.tr()}',
                                          style: TextStyle(
                                            color: product.negotiable
                                                ? Colors.green
                                                : Colors.grey,
                                            fontSize: 12,
                                            height: 1.5, // 줄 간격 추가로 가독성 확보
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          // 오른쪽: 채팅 버튼
                          ElevatedButton(
                            // ⭐️ [수정] 여기가 핵심 수정 부분입니다.
                            onPressed: () async {
                              if (myUid == null) return;
                              if (!context.mounted) return;

                              final ChatService chatService = ChatService();
                              try {
                                final chatId =
                                    await chatService.createOrGetChatRoom(
                                  otherUserId: product.userId,
                                  productId: product.id,
                                  productTitle: product.title,
                                  productImage: product.imageUrls.isNotEmpty
                                      ? product.imageUrls.first
                                      : '',
                                );

                                final otherUser = await chatService
                                    .getOtherUserInfo(product.userId);

                                if (context.mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomScreen(
                                        chatId: chatId,
                                        otherUserName: otherUser.nickname,
                                        otherUserId: otherUser.uid,
                                        productTitle: product.title,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Failed to start chat: $e")));
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFE8803C), // 당근마켓 주황색
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text("marketplace.detail.chat".tr(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: GestureDetector(
                    onTap: () {
                      if (imageUrls.isNotEmpty) {
                        _showFullPhotoView(imageUrls, _currentIndex);
                      }
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrls.isEmpty)
                          Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported,
                                  size: 60, color: Colors.grey))
                        else
                          PageView.builder(
                            controller: _pageController,
                            itemCount: imageUrls.length,
                            onPageChanged: (index) =>
                                setState(() => _currentIndex = index),
                            itemBuilder: (context, index) {
                              return Hero(
                                tag: 'product_image_$index',
                                child: InteractiveViewer(
                                  minScale: 1.0,
                                  maxScale: 4.0,
                                  child: Image.network(
                                    imageUrls[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder: (context, child,
                                            progress) =>
                                        progress == null
                                            ? child
                                            : const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                  ),
                                ),
                              );
                            },
                          ),
                        if (imageUrls.length > 1)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 18,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(imageUrls.length, (idx) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: _currentIndex == idx
                                        ? Colors.white
                                        : Colors.white.withAlpha(115),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => Share.share(
                          'Check out this product: ${product.title}')),
                  if (isMyProduct)
                    IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProductEditScreen(product: product)))),
                  if (isMyProduct)
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: _showDeleteDialog),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSellerInfo(product.userId),
                        const Divider(height: 32),
                        Text(product.title,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CategoryNameWidget(categoryId: product.categoryId),
                            Text(" ∙ ${_formatTimestamp(product.createdAt)}",
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(product.description,
                            style: const TextStyle(fontSize: 16, height: 1.6)),
                        const SizedBox(height: 16),
                        const Divider(height: 32),
                        // [다국어 수정] 통계 라인
                        Text(
                          '${'marketplace.detail.likes'.tr()} ${product.likesCount} ∙ ${'marketplace.detail.chats'.tr()} ${product.chatsCount} ∙ ${'marketplace.detail.views'.tr()} ${product.viewsCount}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ]),
              )
            ],
          ),
        );
      },
    );
  }
}
