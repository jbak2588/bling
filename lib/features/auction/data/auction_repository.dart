// lib/features/auction/data/auction_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/auction_model.dart';
import '../../../core/models/bid_model.dart';

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

  Stream<List<AuctionModel>> fetchAuctions() {
    return _auctionsCollection
        .orderBy('startAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(AuctionModel.fromFirestore).toList());
  }

  Future<String> placeBid(String auctionId, BidModel bid) async {
    final doc = await _auctionsCollection
        .doc(auctionId)
        .collection('bids')
        .add(bid.toJson());
    return doc.id;
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
