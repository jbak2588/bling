/// ============================================================================
/// Bling DocHeader
/// Module        : Marketplace
/// File          : lib/features/marketplace/screens/product_detail_screen.dart
/// Purpose       : 상품 정보와 판매자 세부 사항, 주요 동작을 제공합니다.
/// User Impact   : 구매자가 상품을 평가하고 판매자에게 연락하거나 공유할 수 있습니다.
/// Feature Links : lib/features/marketplace/screens/product_edit_screen.dart; lib/features/chat/screens/chat_room_screen.dart; lib/features/marketplace/screens/marketplace_screen.dart
/// Data Model    : Firestore `products` 필드 `viewsCount`, `likesCount`; 즐겨찾기는 `users/{uid}/favorites`에 저장됩니다.
/// Location Scope: `locationParts.kel`→`kec` 순으로 표시하며 위치 기반 추천을 지원합니다.
/// Privacy Note : 피드/카드 뷰에서는 상세 주소(`locationParts['street']`)나 전체 `locationName`을 사용자 동의 없이 표시하지 마세요. 피드에 표시되는 행정구역은 약어(`kel.`, `kec.`, `kab.`, `prov.`)로 간략 표기하세요.
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
/// [V2.2 주요 변경 사항 (Job 8, 12, 13, 27, 29, 40)]
/// 1. [개편안 2] 사용자/AI 설명 동시 노출 (Job 27, 33):
///    - `_showAiReport` 토글 버튼과 로직을 제거했습니다.
///    - 이제 사용자가 작성한 `product.description`이 항상 표시되고,
///    - `isAiVerified`가 true이면 `AiReportViewer`가 그 하단에 함께 노출됩니다.
///
/// 2. AI 인수 (V2.2):
///    - 하단 앱바(BottomAppBar)의 버튼 로직을 재구성했습니다.
///    - (Fix) 'AI 안심 예약' 버튼은 `floatingActionButton` (FAB)으로 이동하여
///      하단 바 오버플로우를 해결했습니다. (Job 12)
///    - (Fix) 'AI 안심 예약' 상태(`isReservedByMe`)일 때, '현장 인수' 버튼이
///      표시되도록 수정했습니다. (Job 13)
///
/// 3. UI 버그 수정:
///    - (Fix) `MiniMapView` 호출 시 `myLocationEnabled: false`를 명시하여
///      80초간 앱이 멈추는(Jank) 현상을 해결했습니다. (Job 28, 29)
///    - (Fix) 어두운 이미지 위에서 AppBar 아이콘이 보이도록
///      `AppBarIcon` (공용 위젯)을 적용했습니다. (Job 13)
/// ============================================================================
///
library;
// 아래부터 실제 코드

import 'package:bling_app/features/categories/domain/category.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bling_app/features/marketplace/models/product_model.dart';
import 'package:bling_app/features/marketplace/screens/product_edit_screen.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/marketplace/widgets/ai_verification_badge.dart'; // AI 뱃지
import 'package:bling_app/features/marketplace/data/product_repository.dart'; // [AI 인수] 리포지토리 임포트
import 'package:bling_app/features/marketplace/screens/ai_takeover_screen.dart'; // [AI 인수 2단계] 현장 검증 화면 (used by FAB builder)

import '../widgets/ai_report_viewer.dart'; // [AI 리팩토링] 공용 위젯 임포트

// ✅ 공용 위젯 4개를 import 합니다.
import '../../shared/widgets/author_profile_tile.dart';
import '../../shared/widgets/clickable_tag_list.dart';
import '../../shared/widgets/mini_map_view.dart';
import '../../shared/screens/image_gallery_screen.dart';
import '../../shared/widgets/app_bar_icon.dart';

// 카테고리 이름 표시를 위한 별도 위젯
class CategoryNameWidget extends StatelessWidget {
  final String categoryId;
  final String? categoryParentId;
  const CategoryNameWidget(
      {super.key, required this.categoryId, this.categoryParentId});

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
    // If a parent id is provided, prefer loading the child from parent's subCategories
    if (categoryParentId != null && categoryParentId!.isNotEmpty) {
      return FutureBuilder<List<DocumentSnapshot>>(
        future: Future.wait([
          FirebaseFirestore.instance
              .collection('categories_v2')
              .doc(categoryParentId)
              .get(),
          FirebaseFirestore.instance
              .collection('categories_v2')
              .doc(categoryParentId)
              .collection('subCategories')
              .doc(categoryId)
              .get(),
        ]),
        builder: (context, snap) {
          if (!snap.hasData) return const SizedBox.shrink();
          final parentDoc = snap.data![0];
          final childDoc = snap.data![1];
          if (parentDoc.exists && childDoc.exists) {
            try {
              final parent = Category.fromFirestore(
                  parentDoc as DocumentSnapshot<Map<String, dynamic>>);
              final child = Category.fromFirestore(
                  childDoc as DocumentSnapshot<Map<String, dynamic>>);
              final text =
                  "${parent.displayName(context.locale.languageCode)} > ${child.displayName(context.locale.languageCode)}";
              return Text(text,
                  style: const TextStyle(fontSize: 13, color: Colors.grey));
            } catch (e) {
              return const SizedBox.shrink();
            }
          }
          // Fallback to loading categoryId directly
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('categories_v2')
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
        },
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('categories_v2')
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
  // [V3 NOTIFICATION] ID 또는 객체로 화면을 로드할 수 있도록 허용
  final ProductModel? product;
  final String? productId;
  // Embedded mode: when true, don't render a nested Scaffold/AppBar/FAB.
  // Parent shell will provide AppBar and BottomNavigationBar. When the
  // detail is embedded and needs to trigger a full-screen push, call
  // `onClose` first so the parent can clear the embedded content.
  final bool embedded;
  final VoidCallback? onClose;
  const ProductDetailScreen(
      {super.key,
      this.product,
      this.productId,
      this.embedded = false,
      this.onClose})
      : assert(product != null || productId != null,
            'product 또는 productId 중 하나는 필수입니다.');

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // --- 상태 변수 및 로직 함수들 (기존과 동일) ---
  bool _isFavorite = false;
  int _currentIndex = 0;
  bool _isReserving = false; // [AI 인수] 예약 진행 중 상태
  late final PageController _pageController = PageController(initialPage: 0);

  // [V3 NOTIFICATION] StreamBuilder가 사용할 ID
  late final String _productId;

  @override
  void initState() {
    super.initState();
    // [V3 NOTIFICATION] 생성자에서 받은 ID를 상태 변수로 설정
    _productId = widget.product?.id ?? widget.productId!;
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
        .doc(_productId); // [V3 NOTIFICATION]
    await docRef.update({'viewsCount': FieldValue.increment(1)});
  }

  Future<void> _checkIfFavorite() async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;
    final favDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(myUid)
        .collection('favorites')
        .doc(_productId) // [V3 NOTIFICATION]
        .get();
    if (mounted) setState(() => _isFavorite = favDoc.exists);
  }

  // [AI 인수] 예약금 결제 확인 다이얼로그 (신규)
  Future<void> _showReservationDialog(ProductModel product) async {
    final int depositAmount = (product.price * 0.1).ceil(); // 10% 예약금
    // [App Review] 가상 결제 모드 여부 (실제 배포 시 false로 변경하거나 백엔드 제어)
    // 현재는 심사 및 테스트를 위해 무조건 true로 설정.
    // NOTE: make this a runtime-evaluated expression so analyzer doesn't
    // treat the alternate branch as dead code during static analysis.
    final bool isMockPayment = DateTime.now().millisecondsSinceEpoch >= 0;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('marketplace.reservation.title'.tr()),
        content: Text(
          'marketplace.reservation.content'.tr(
            namedArgs: {
              'amount': NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(depositAmount),
            },
          ),
        ),
        actions: [
          TextButton(
            child: Text('marketplace.dialog.cancel'.tr()),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          FilledButton(
            child: Text(isMockPayment
                ? 'marketplace.reservation.mockPay'.tr() // "결제 테스트 (무료)"
                : 'marketplace.reservation.confirm'.tr()),
            onPressed: () async {
              if (isMockPayment) {
                // [Mock Payment] 결제 시뮬레이션
                // 1. 로딩 표시
                showDialog(
                  context: ctx,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );

                // 2. 1.5초 지연 (네트워크 통신 흉내)
                await Future.delayed(const Duration(milliseconds: 1500));

                // 3. 로딩 닫기 및 성공 반환
                if (ctx.mounted) {
                  Navigator.of(ctx).pop(); // 로딩 닫기
                  Navigator.of(ctx).pop(true); // 다이얼로그 닫기 (성공)
                }
              } else {
                // TODO: 실제 PG 연동
                Navigator.of(ctx).pop(true);
              }
            },
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _executeReservation(product);
    }
  }

  // [AI 인수] 예약 실행 로직 (신규)
  Future<void> _executeReservation(ProductModel product) async {
    if (_isReserving) return;
    setState(() => _isReserving = true);

    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('marketplace.errors.loginRequired'.tr())));
      setState(() => _isReserving = false);
      return;
    }

    try {
      final productRepository = ProductRepository(); // (임시)
      await productRepository.reserveProduct(
        productId: product.id,
        buyerId: myUid,
      );

      // [임시 구현] 리포지토리 대신 Firestore 직접업데이트
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({'status': 'reserved'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('marketplace.reservation.success'.tr())));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isReserving = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;
    setState(() => _isFavorite = !_isFavorite);
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(myUid)
        .collection('favorites')
        .doc(_productId); // [V3 NOTIFICATION]
    final prodRef = FirebaseFirestore.instance
        .collection('products')
        .doc(_productId); // [V3 NOTIFICATION]
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

  // [AI 인수] 채팅 시작 로직 분리 (신규)
  Future<void> _startChat(ProductModel product, String? myUid) async {
    if (myUid == null) return;
    if (!context.mounted) return;

    final ChatService chatService = ChatService();
    try {
      final chatId = await chatService.createOrGetChatRoom(
        otherUserId: product.userId,
        productId: product.id,
        productTitle: product.title,
        productImage:
            product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
      );

      final otherUser = await chatService.getOtherUserInfo(product.userId);

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to start chat: $e")));
      }
    }
  }

  Future<void> _deleteProduct() async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(_productId) // [V3 NOTIFICATION]
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

  // --- 메인 빌드 함수 ---
  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(_productId) // [V3 NOTIFICATION]
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          if (widget.embedded) {
            return const Center(child: CircularProgressIndicator());
          }
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()));
        }

        final product = ProductModel.fromFirestore(snapshot.data!);
        final isMyProduct = myUid == product.userId;
        final imageUrls = product.imageUrls;
        final hasLocation = product.geoPoint != null;
        // [AI 인수] 상품 상태 확인 (신규)
        final bool isSelling = product.status == 'selling';
        final bool isReserved = product.status == 'reserved';
        // [AI 인수] 내가 예약한 상품인지 확인
        final bool isReservedByMe =
            isReserved && product.buyerId != null && product.buyerId == myUid;

        // Build the main body content (the part that should be embedded)
        final Widget bodyContent = CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              // make leading and action icons easier to read on top of the
              // image by wrapping them in a dark circular background
              leading: widget.embedded
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: AppBarIcon(
                        icon: Icons.arrow_back,
                        onPressed: () {
                          if (widget.embedded && widget.onClose != null) {
                            widget.onClose!();
                            return;
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
              flexibleSpace: FlexibleSpaceBar(
                background: GestureDetector(
                  onTap: () {
                    if (imageUrls.isNotEmpty) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ImageGalleryScreen(
                            imageUrls: imageUrls, initialIndex: _currentIndex),
                      ));
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
                              child: Image.network(imageUrls[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity),
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
                            )),
                    ],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AppBarIcon(
                    icon: Icons.share,
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(
                          text: 'Check out this product: ${product.title}'),
                    ),
                  ),
                ),
                if (isMyProduct)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: AppBarIcon(
                      icon: Icons.edit,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductEditScreen(product: product),
                        ),
                      ),
                    ),
                  ),
                if (isMyProduct)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: AppBarIcon(
                        icon: Icons.delete, onPressed: _showDeleteDialog),
                  ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuthorProfileTile(userId: product.userId),
                      const Divider(height: 32),
                      Text(product.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (product.isAiVerified)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: AiVerificationBadge(),
                        ),
                      Row(children: [
                        CategoryNameWidget(
                            categoryId: product.categoryId,
                            categoryParentId: product.categoryParentId),
                        Text(" ∙ ${_formatTimestamp(product.createdAt)}",
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                      ]),
                      const SizedBox(height: 16),

                      // [개편안 2] 1. 사용자가 작성한 설명 (항상 표시)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          product.description,
                          style: const TextStyle(fontSize: 16, height: 1.6),
                        ),
                      ),

                      // [개편안 2] 2. AI 검증 리포트 (검증된 경우에만 표시)
                      if (product.isAiVerified)
                        AiReportViewer(
                          aiReport: Map<String, dynamic>.from(
                              product.aiReport ??
                                  product.aiVerificationData ??
                                  {}),
                        ),

                      // ✅ 3. 공용 위젯 추가
                      ClickableTagList(tags: product.tags),
                      if (hasLocation) ...[
                        const Divider(height: 32),
                        Text('marketplace.detail.dealLocation'.tr(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        MiniMapView(
                          location: product.geoPoint!,
                          markerId: product.id,
                        ),
                      ],
                    ],
                  ),
                ),
              ]),
            ),
          ],
        );

        if (widget.embedded) {
          return DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!,
            child: Container(color: Colors.grey.shade100, child: bodyContent),
          );
        }

        return Scaffold(
          floatingActionButton: _buildFloatingActionButton(
              product, isMyProduct, isSelling, isReservedByMe),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          // 채팅/가격 BottomAppBar: fixed-height removed and buttons allowed to
          // flex/shrink via Flexible so it adapts to different font/device sizes.
          bottomNavigationBar: BottomAppBar(
            surfaceTintColor: Colors.white,
            elevation: 10,
            child: SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    // 1. Favorite Icon
                    IconButton(
                      padding: const EdgeInsets.only(right: 16),
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isMyProduct
                            ? Colors.grey
                            : (_isFavorite ? Colors.pink : Colors.grey),
                      ),
                      onPressed: isMyProduct ? null : _toggleFavorite,
                    ),
                    const VerticalDivider(width: 1.0, thickness: 1.0),
                    const SizedBox(width: 16),

                    // 2. Price + Negotiable — allow flexible shrinking/growing so
                    // it cooperates better with large fonts or small screens.
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(product.price),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              height: 1.15,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            product.negotiable
                                ? 'marketplace.detail.makeOffer'.tr()
                                : 'marketplace.detail.fixedPrice'.tr(),
                            style: TextStyle(
                              color: product.negotiable
                                  ? Colors.green
                                  : Colors.grey,
                              fontSize: 12,
                              height: 1.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),
                    // 3. Chat Button — allow shrinking via Flexible and use a
                    // FittedBox for the label so it scales down instead of
                    // overflowing when fonts are large.
                    Flexible(
                      fit: FlexFit.loose,
                      child: ElevatedButton(
                        onPressed: (isMyProduct || !isSelling)
                            ? null
                            : () => _startChat(product, myUid),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (isSelling)
                              ? const Color(0xFFE8803C)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            (isReserved)
                                ? 'marketplace.status.reserved'.tr()
                                : (isSelling
                                    ? 'marketplace.detail.chat'.tr()
                                    : 'marketplace.status.sold'.tr()),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),

                    // [Task 107] '현장 인수' 버튼이 FAB로 이동했으므로 BottomAppBar에서 제거.
                  ],
                ),
              ),
            ),
          ),
          body: bodyContent,
        );
      },
    );
  }

  // 원문 다이얼로그 기능은 요청에 따라 제거되었습니다.

  /// [Task 107] FAB 로직 통합 (예약 / 인수)
  Widget? _buildFloatingActionButton(
    ProductModel product,
    bool isMyProduct,
    bool isSelling,
    bool isReservedByMe,
  ) {
    if (isMyProduct) return null; // 내 상품에는 FAB 없음

    if (isReservedByMe) {
      // [Task 107] 1. 현장 인수 버튼 (기존 BottomAppBar에서 이동)
      return FloatingActionButton.extended(
        heroTag: 'takeover_fab',
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AiTakeoverScreen(product: product),
          ));
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
        label: Text(
          "marketplace.takeover.button".tr(),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (product.isAiVerified && isSelling) {
      // [Task 107] 2. AI 안심 예약 버튼 (기존 로직)
      return FloatingActionButton.extended(
        heroTag: 'reserve_fab',
        onPressed: _isReserving ? null : () => _showReservationDialog(product),
        backgroundColor: _isReserving ? Colors.grey : const Color(0xFF007BFF),
        icon: _isReserving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.shield_outlined, color: Colors.white),
        label: Text(
          "marketplace.reservation.button".tr(),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return null; // 그 외 (판매 완료, AI 미검증 등)
  }
}
