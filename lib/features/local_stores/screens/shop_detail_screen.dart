// ===================== DocHeader =====================
// [기획 요약]
// - 상점 상세 정보, 이미지 갤러리, 채팅 연동, 신뢰 등급, 연락처, 영업시간 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 상세 정보, 이미지 갤러리, 채팅 연동, 신뢰 등급, 연락처, 영업시간 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 채팅방 생성 및 상점주 정보 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 리뷰, 부스트 등).
// - 신고/차단/신뢰 등급 UI 노출 및 기능 강화, 알림/리뷰 UX 개선.
// =====================================================
// lib/features/local_stores/screens/shop_detail_screen.dart
// ===================== DocHeader =====================
// [기획 요약]
// - 상점 상세 정보, 이미지 갤러리, 채팅 연동, 신뢰 등급, 연락처, 영업시간 등 다양한 필드 지원.
//
// [실제 구현 비교]
// - 상세 정보, 이미지 갤러리, 채팅 연동, 신뢰 등급, 연락처, 영업시간 등 모든 주요 기능 정상 동작.
// - UI/UX 완비, 채팅방 생성 및 상점주 정보 연동 구현됨.
//
// [개선 제안]
// - KPI/통계/프리미엄 기능 실제 구현 필요(조회수, 리뷰, 부스트 등).
// - 신고/차단/신뢰 등급 UI 노출 및 기능 강화, 알림/리뷰 UX 개선.
// =====================================================

import 'package:bling_app/features/local_stores/models/shop_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/chat/data/chat_service.dart';
import 'package:bling_app/features/chat/screens/chat_room_screen.dart';
import 'package:bling_app/features/local_stores/data/shop_repository.dart';
import 'package:bling_app/features/local_stores/screens/edit_shop_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ShopDetailScreen extends StatefulWidget {
  final ShopModel shop;
  const ShopDetailScreen({super.key, required this.shop});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  final ShopRepository _repository = ShopRepository();
  final ChatService _chatService = ChatService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

 // V V V --- [수정] 이미지 슬라이더와 썸네일을 동기화하기 위한 PageController 추가 --- V V V
  late final PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose(); // PageController 메모리 해제
    super.dispose();
  }

  void _startChat(BuildContext context) async {
    try {
      final chatId = await _chatService.createOrGetChatRoom(
        otherUserId: widget.shop.ownerId,
        shopId: widget.shop.id,
        shopName: widget.shop.name,
        shopImage: widget.shop.imageUrls.isNotEmpty ? widget.shop.imageUrls.first : null,
      );

      final otherUser = await _chatService.getOtherUserInfo(widget.shop.ownerId);

      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(
            chatId: chatId,
            otherUserName: otherUser.nickname,
            otherUserId: otherUser.uid,
            productTitle: widget.shop.name,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('localStores.detail.startChatFail'
                  .tr(namedArgs: {'error': e.toString()})),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteShop() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('localStores.detail.deleteTitle'.tr()),
        content: Text('localStores.detail.deleteContent'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('common.cancel'.tr())),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('common.delete'.tr(), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _repository.deleteShop(widget.shop.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('localStores.detail.deleteSuccess'.tr()), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('localStores.detail.deleteFail'.tr(namedArgs: {'error': e.toString()})), backgroundColor: Colors.red));
      }
    }
  }

// V V V --- [수정] 이미지 슬라이더 + 하단 썸네일 UI --- V V V
  Widget _buildImageSlider(List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey.shade200,
        child: const Icon(Icons.storefront, size: 80, color: Colors.grey),
      );
    }
    return Column(
      children: [
        // --- 1. 메인 이미지 슬라이더 ---
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => FullScreenImageViewer(
                imageUrls: images,
                initialIndex: _currentImageIndex,
              ),
            ));
          },
          child: Container(
            height: 250,
            color: Colors.black,
            child: PageView.builder(
              controller: _pageController, // 컨트롤러 연결
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemBuilder: (context, index) {
                return Image.network(images[index], fit: BoxFit.contain);
              },
            ),
          ),
        ),
        
        // --- 2. 하단 썸네일 목록 ---
        if (images.length > 1)
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // 썸네일을 탭하면 메인 슬라이더가 해당 이미지로 이동
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _currentImageIndex == index
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
  // ^ ^ ^ --- 여기까지 이식 --- ^ ^ ^

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ShopModel>(
      stream: _repository.getShopStream(widget.shop.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final shop = snapshot.data!;
        final isOwner = shop.ownerId == _currentUserId;

        return Scaffold(
          appBar: AppBar(
            title: Text(shop.name),
            actions: [
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.edit_note_outlined),
                  tooltip: 'localStores.edit.tooltip'.tr(),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                              builder: (_) => EditShopScreen(shop: shop)),
                        )
                        .then((_) => setState(() {}));
                  },
                ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'localStores.detail.deleteTooltip'.tr(),
                  onPressed: _deleteShop,
                ),
            ],
          ),
          body: ListView(
            padding:
                const EdgeInsets.fromLTRB(0, 0, 0, 100.0),
            children: [
              // [수정] 기존 Image.network를 새로 이식한 _buildImageSlider로 교체
              _buildImageSlider(shop.imageUrls),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shop.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildInfoRow(context, Icons.location_on_outlined,
                        shop.locationName ?? 'localStores.noLocation'.tr()),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                        context, Icons.watch_later_outlined, shop.openHours),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                        context, Icons.phone_outlined, shop.contactNumber),
                    const Divider(height: 32),
                    Text('localStores.detail.description'.tr(),
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(shop.description,
                        style: const TextStyle(fontSize: 16, height: 1.5)),
                    const Divider(height: 32),
                    _buildOwnerInfo(shop.ownerId),
                  ],
                ),
              )
            ],
          ),
          bottomNavigationBar: isOwner
              ? null
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => _startChat(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('localStores.detail.inquire'.tr()),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 15, color: Colors.grey[800]))),
      ],
    );
  }

  Widget _buildOwnerInfo(String userId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return ListTile(title: Text('localStores.detail.noOwnerInfo'.tr()));
        }
        final user = UserModel.fromFirestore(snapshot.data!);
        return Card(
          elevation: 0,
          color: Colors.grey.shade100,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty) ? NetworkImage(user.photoUrl!) : null,
              child: (user.photoUrl == null || user.photoUrl!.isEmpty) ? const Icon(Icons.person) : null,
            ),
            title: Text(user.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user.locationName ?? ''),
          ),
        );
      },
    );
  }
}

// V V V --- [이식] 전체 화면 이미지 뷰어 (핀치 앤 줌 기능 포함) --- V V V
class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${widget.imageUrls.length}'),
        centerTitle: true,
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: widget.imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
// ^ ^ ^ --- 여기까지 이식 --- ^ ^ ^