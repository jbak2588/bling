// lib/features/auction/data/auction_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/auction_model.dart';
import '../../../core/models/bid_model.dart';
import 'package:easy_localization/easy_localization.dart';

/// Provides CRUD operations for auctions and bidding functionality.
class AuctionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _auctionsCollection =>
      _firestore.collection('auctions');

  Future<String> createAuction(AuctionModel auction) async {
    final doc = await _auctionsCollection.add(auction.toJson());
    return doc.id;
  }

  Future<void> updateAuction(AuctionModel auction) async {
    await _auctionsCollection.doc(auction.id).update(auction.toJson());
  }

  Future<void> deleteAuction(String auctionId) async {
    await _auctionsCollection.doc(auctionId).delete();
  }

  Future<AuctionModel> fetchAuction(String auctionId) async {
    final doc = await _auctionsCollection.doc(auctionId).get();
    return AuctionModel.fromFirestore(doc);
  }

// V V V --- [수정] 마감된 경매도 불러오도록 .where 필터 제거 --- V V V
  Stream<List<AuctionModel>> fetchAuctions() {
    return _auctionsCollection
        .orderBy('endAt', descending: false) // 마감 임박 순으로 정렬
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(AuctionModel.fromFirestore).toList());
  }

  // V V V --- [추가] 특정 경매 하나의 정보를 실시간으로 가져오는 Stream 함수 --- V V V
  Stream<AuctionModel> getAuctionStream(String auctionId) {
    return _auctionsCollection
        .doc(auctionId)
        .snapshots()
        .map((snapshot) => AuctionModel.fromFirestore(snapshot));
  }
  // ^ ^ ^ --- 여기까지 추가 --- ^ ^ ^

// V V V --- [수정] Firestore Transaction을 사용하여 안전하게 입찰을 처리합니다 --- V V V
  Future<void> placeBid(String auctionId, BidModel bid) async {
    final auctionRef = _auctionsCollection.doc(auctionId);
    final bidRef = auctionRef.collection('bids').doc();

    await _firestore.runTransaction((transaction) async {
      final auctionSnapshot = await transaction.get(auctionRef);
      if (!auctionSnapshot.exists) {
        throw Exception(tr('auctions.errors.notFound'));
      }

      final auction = AuctionModel.fromFirestore(auctionSnapshot);

      // 현재 입찰가보다 높은 금액인지 확인
      if (bid.bidAmount <= auction.currentBid) {
        throw Exception(tr('auctions.errors.lowerBid'));
      }

      // 마감 시간이 지났는지 확인
      if (auction.endAt.toDate().isBefore(DateTime.now())) {
        throw Exception(tr('auctions.errors.alreadyEnded'));
      }

      // 1. auctions 문서 업데이트
      transaction.update(auctionRef, {
        'currentBid': bid.bidAmount,
        'bidHistory': FieldValue.arrayUnion([bid.toJson()]) // 간단한 히스토리 기록
      });

      // 2. bids 하위 컬렉션에 입찰 기록 추가
      transaction.set(bidRef, bid.toJson());
    });
  }

  Stream<List<BidModel>> fetchBids(String auctionId) {
    return _auctionsCollection
        .doc(auctionId)
        .collection('bids')
        .orderBy('bidTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(BidModel.fromFirestore).toList());
  }
}
