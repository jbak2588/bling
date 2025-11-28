// lib/features/auction/data/auction_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auction_model.dart';
import '../models/bid_model.dart';
import 'package:easy_localization/easy_localization.dart';

class AuctionRepository {
  // Use a getter so constructing AuctionRepository in tests doesn't require
  // Firebase to be initialized. Accessing `_firestore` will still call
  // FirebaseFirestore.instance when methods that use it run.
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

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

  // V V V --- [수정] locationFilter를 적용하고, 정렬 기준을 'endAt'으로 되돌립니다 --- V V V
  // ✅ [탐색 기능] 1. categoryId 파라미터 추가
  Stream<List<AuctionModel>> fetchAuctions({
    Map<String, String?>? locationFilter,
    String? categoryId,
  }) {
    Query query = _auctionsCollection.orderBy('endAt',
        descending: false); // [핵심] 마감 임박 순으로 정렬

    // locationFilter가 null이 아닐 경우, 필터링 쿼리를 동적으로 추가합니다.
    if (locationFilter != null) {
      final kab = locationFilter['kab'];
      if (kab != null && kab.isNotEmpty) {
        query = query.where('locationParts.kab', isEqualTo: kab);
      }
      // 다른 지역 단위(kec, kel)에 대한 필터가 필요하면 여기에 추가합니다.
    }

    // ✅ [탐색 기능] 2. categoryId가 'all'이 아니면 쿼리에 필터 추가
    if (categoryId != null && categoryId != 'all') {
      query = query.where('category', isEqualTo: categoryId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AuctionModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    });
  }
  // ^ ^ ^ --- 여기까지 수정 --- ^ ^ ^

  Stream<AuctionModel> getAuctionStream(String auctionId) {
    return _auctionsCollection
        .doc(auctionId)
        .snapshots()
        .map((snapshot) => AuctionModel.fromFirestore(snapshot));
  }

  Future<void> placeBid(String auctionId, BidModel bid) async {
    final auctionRef = _auctionsCollection.doc(auctionId);
    final bidRef = auctionRef.collection('bids').doc();

    await _firestore.runTransaction((transaction) async {
      final auctionSnapshot = await transaction.get(auctionRef);
      if (!auctionSnapshot.exists) {
        throw Exception('auctions.errors.notFound'.tr());
      }

      final auction = AuctionModel.fromFirestore(auctionSnapshot);

      if (bid.bidAmount <= auction.currentBid) {
        throw Exception('auctions.errors.lowerBid'.tr());
      }

      if (auction.endAt.toDate().isBefore(DateTime.now())) {
        throw Exception('auctions.errors.alreadyEnded'.tr());
      }

      transaction.update(auctionRef, {
        'currentBid': bid.bidAmount,
        'bidHistory': FieldValue.arrayUnion([bid.toJson()])
      });

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
