// lib/features/auction/screens/auction_detail_screen.dart

import 'package:bling_app/features/auction/models/auction_model.dart';
import 'package:bling_app/features/auction/models/bid_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/auction/data/auction_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/auction/screens/edit_auction_screen.dart';

import 'package:bling_app/features/shared/widgets/author_profile_tile.dart';
import 'package:bling_app/features/shared/widgets/clickable_tag_list.dart';
import 'package:bling_app/features/shared/widgets/mini_map_view.dart';
import 'package:bling_app/features/shared/screens/image_gallery_screen.dart';
import 'package:bling_app/features/shared/widgets/image_carousel_card.dart';

class AuctionDetailScreen extends StatefulWidget {
  final AuctionModel auction;
  const AuctionDetailScreen({super.key, required this.auction});

  @override
  State<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  final AuctionRepository _repository = AuctionRepository();
  final _bidAmountController = TextEditingController();
  // int _currentImageIndex = 0; // [추가] 현재 보이는 이미지 인덱스

  bool _isBidding = false; // [추가] 입찰 중 상태

  @override
  void dispose() {
    _bidAmountController.dispose();
    super.dispose();
  }

  // V V V --- [수정] 입찰하기 로직 구현 --- V V V
  Future<void> _placeBid() async {
    final user = FirebaseAuth.instance.currentUser;
    final amount = int.tryParse(_bidAmountController.text);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('auctions.detail.errors.loginRequired'.tr())));
      return;
    }
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('auctions.detail.errors.invalidAmount'.tr())));
      return;
    }

    setState(() => _isBidding = true);

    try {
      final newBid = BidModel(
        id: '',
        userId: user.uid,
        bidAmount: amount,
        bidTime: Timestamp.now(),
      );
      await _repository.placeBid(widget.auction.id, newBid);

      _bidAmountController.clear();
      FocusScope.of(context).unfocus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('auctions.detail.bidSuccess'.tr()),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('auctions.detail.bidFail'
                .tr(namedArgs: {'error': e.toString()})),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isBidding = false);
    }
  }

  // V V V --- [추가] 경매 삭제 로직 --- V V V
  Future<void> _deleteAuction() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('auctions.delete.confirmTitle'.tr()),
        content: Text('auctions.delete.confirmContent'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('common.cancel'.tr())),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('common.delete'.tr(),
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteAuction(widget.auction.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('auctions.delete.success'.tr()),
              backgroundColor: Colors.green));
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('auctions.delete.fail'
                  .tr(namedArgs: {'error': e.toString()})),
              backgroundColor: Colors.red));
        }
      }
    }
  }

  // V V V --- [이식] product_detail_screen.dart에서 가져온 이미지 슬라이더 --- V V V

  // ^ ^ ^ --- 여기까지 이식 --- ^ ^ ^

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // [수정] StreamBuilder를 Scaffold 바깥으로 이동하여 AppBar에서도 실시간 데이터를 사용
    return StreamBuilder<AuctionModel>(
      stream: _repository.getAuctionStream(widget.auction.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final auction = snapshot.data!;
        final isOwner = auction.ownerId == currentUserId;

        return Scaffold(
          appBar: AppBar(
            title: Text(auction.title),
            // V V V --- [추가] 경매 주인에게만 보이는 수정/삭제 버튼 --- V V V
            actions: [
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.edit_note_outlined),
                  tooltip: 'auctions.edit.tooltip'.tr(),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => EditAuctionScreen(auction: auction)),
                    );
                  },
                ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'auctions.delete.tooltip'.tr(),
                  onPressed: _deleteAuction,
                ),
            ],
            // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ 기존 이미지 슬라이더를 공용 위젯으로 교체
                    if (auction.images.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        // ✅ [추가] Stack을 사용하여 이미지 캐러셀 위에 오버레이 추가
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ImageGalleryScreen(
                                      imageUrls: auction.images),
                                ),
                              ),
                              child: ImageCarouselCard(
                                storageId: auction.id,
                                imageUrls: auction.images,
                                height: 250,
                              ),
                            ),
                            // ✅ 경매 종료 여부 확인 및 오버레이 표시
                            if (auction.endAt.toDate().isBefore(DateTime.now()))
                              Positioned.fill(
                                // Stack 전체를 덮도록 설정 (탭은 통과)
                                child: IgnorePointer(
                                  ignoring: true,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                      // ImageCarouselCard의 borderRadius와 맞춤
                                    ),
                                    child: Center(
                                      child: Text(
                                        'auctions.card.ended'.tr(),
                                        // "경매 종료" 텍스트
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auction.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text('auctions.detail.currentBid'.tr(namedArgs: {
                            'amount': currencyFormat.format(auction.currentBid)
                          })),
                          Text('auctions.detail.endTime'.tr(namedArgs: {
                            'time': DateFormat('MM/dd HH:mm')
                                .format(auction.endAt.toDate())
                          })),
                          const Divider(height: 32),
                          Text(auction.description,
                              style:
                                  const TextStyle(fontSize: 16, height: 1.5)),
                          const SizedBox(height: 16),

                          // ✅ 태그, 지도, 작성자 정보 공용 위젯 추가
                          ClickableTagList(tags: auction.tags),
                          if (auction.geoPoint != null) ...[
                            const Divider(height: 32),
                            Text('auctions.detail.location'.tr(),
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 12),
                            MiniMapView(
                                location: auction.geoPoint!,
                                markerId: auction.id),
                          ],
                          const Divider(height: 32),
                          Text('auctions.detail.seller'.tr(),
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          AuthorProfileTile(userId: auction.ownerId),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text('auctions.detail.bidsTitle'.tr(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              // V V V --- [수정] 입찰자 정보를 가져오는 로직을 복원합니다 --- V V V
              StreamBuilder<List<BidModel>>(
                stream: _repository.fetchBids(widget.auction.id),
                builder: (context, bidSnapshot) {
                  if (!bidSnapshot.hasData) {
                    return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()));
                  }
                  final bids = bidSnapshot.data!;
                  if (bids.isEmpty) {
                    return SliverToBoxAdapter(
                        child: Center(
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('auctions.detail.noBids'.tr()))));
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final bid = bids[index];
                        return FutureBuilder<
                                DocumentSnapshot<Map<String, dynamic>>>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(bid.userId)
                                .get(),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData ||
                                  !userSnapshot.data!.exists) {
                                return ListTile(
                                    leading: const CircleAvatar(
                                        child: Icon(Icons.person_off)),
                                    title: Text(
                                        'auctions.detail.unknownBidder'.tr()));
                              }
                              final user =
                                  UserModel.fromFirestore(userSnapshot.data!);

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: (user.photoUrl != null &&
                                            user.photoUrl!.isNotEmpty)
                                        ? NetworkImage(user.photoUrl!)
                                        : null,
                                  ),
                                  title: Text(user.nickname,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      currencyFormat.format(bid.bidAmount)),
                                  trailing: Text(DateFormat('HH:mm')
                                      .format(bid.bidTime.toDate())),
                                ),
                              );
                            });
                      },
                      childCount: bids.length,
                    ),
                  );
                },
              ),
              //
            ],
          ),
          // [수정] 경매 주인이 아닐 경우에만 입찰하기 UI 표시
          bottomNavigationBar: isOwner
              ? null
              : Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 8,
                      right: 8,
                      top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _bidAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'auctions.detail.bidAmountLabel'.tr(),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isBidding ? null : _placeBid,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isBidding
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text('auctions.detail.placeBid'.tr()),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
