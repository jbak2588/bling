// lib/features/auction/screens/auction_detail_screen.dart

import 'package:bling_app/core/models/auction_model.dart';
import 'package:bling_app/core/models/bid_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/auction/data/auction_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bling_app/features/auction/screens/edit_auction_screen.dart';


import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';



class AuctionDetailScreen extends StatefulWidget {
  final AuctionModel auction;
  const AuctionDetailScreen({super.key, required this.auction});

  @override
  State<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  final AuctionRepository _repository = AuctionRepository();
  final _bidAmountController = TextEditingController();
  int _currentImageIndex = 0; // [추가] 현재 보이는 이미지 인덱스

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('올바른 입찰 금액을 입력해주세요.')));
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('입찰에 성공했습니다!'), backgroundColor: Colors.green));
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('입찰 실패: ${e.toString()}'), backgroundColor: Colors.red));
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
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('common.cancel'.tr())),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('common.delete'.tr(), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteAuction(widget.auction.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('auctions.delete.success'.tr()), backgroundColor: Colors.green));
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('auctions.delete.fail'.tr(namedArgs: {'error': e.toString()})), backgroundColor: Colors.red));
        }
      }
    }
  }

  // V V V --- [이식] product_detail_screen.dart에서 가져온 이미지 슬라이더 --- V V V
  Widget _buildImageSlider(List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey.shade200,
        child: const Icon(Icons.gavel_outlined, size: 80, color: Colors.grey),
      );
    }
    return Column(
      children: [
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
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(images[index], fit: BoxFit.contain);
              },
            ),
          ),
        ),
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(_currentImageIndex == entry.key ? 0.9 : 0.4),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
  // ^ ^ ^ --- 여기까지 이식 --- ^ ^ ^

  @override
  Widget build(BuildContext context) {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // [수정] StreamBuilder를 Scaffold 바깥으로 이동하여 AppBar에서도 실시간 데이터를 사용
    return StreamBuilder<AuctionModel>(
      stream: _repository.getAuctionStream(widget.auction.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                      MaterialPageRoute(builder: (_) => EditAuctionScreen(auction: auction)),
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
                    _buildImageSlider(auction.images),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auction.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text('현재 입찰가: ${currencyFormat.format(auction.currentBid)}'),
                          Text('마감 시간: ${DateFormat('MM/dd HH:mm').format(auction.endAt.toDate())}'),
                          const Divider(height: 32),
                          Text(auction.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                 const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('입찰 현황', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              // V V V --- [수정] 입찰자 정보를 가져오는 로직을 복원합니다 --- V V V
              StreamBuilder<List<BidModel>>(
                stream: _repository.fetchBids(widget.auction.id),
                builder: (context, bidSnapshot) {
                  if (!bidSnapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                  final bids = bidSnapshot.data!;
                  if (bids.isEmpty) return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('아직 입찰자가 없습니다.'))));

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final bid = bids[index];
                        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance.collection('users').doc(bid.userId).get(),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                              return const ListTile(leading: CircleAvatar(child: Icon(Icons.person_off)), title: Text('알 수 없는 입찰자'));
                            }
                            final user = UserModel.fromFirestore(userSnapshot.data!);
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty) ? NetworkImage(user.photoUrl!) : null,
                                ),
                                title: Text(user.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(currencyFormat.format(bid.bidAmount)),
                                trailing: Text(DateFormat('HH:mm').format(bid.bidTime.toDate())),
                              ),
                            );
                          }
                        );
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
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 8, right: 8, top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _bidAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '입찰가 입력 (Rp)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isBidding ? null : _placeBid,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isBidding ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('입찰하기'),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}



// V V V --- [이식] product_detail_screen.dart에서 가져온 전체 화면 이미지 뷰어 --- V V V
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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