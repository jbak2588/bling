// lib/features/real_estate/data/room_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/room_listing_model.dart';

/// Repository handling CRUD and favorite operations for room listings.
class RoomRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _listingsCollection =>
      _firestore.collection('rooms_listings');

  Future<String> createListing(RoomListingModel listing) async {
    final doc = await _listingsCollection.add(listing.toJson());
    return doc.id;
  }

  Future<void> updateListing(RoomListingModel listing) async {
    await _listingsCollection.doc(listing.id).update(listing.toJson());
  }

  Future<void> deleteListing(String listingId) async {
    await _listingsCollection.doc(listingId).delete();
  }

  Future<RoomListingModel> fetchListing(String listingId) async {
    final doc = await _listingsCollection.doc(listingId).get();
    return RoomListingModel.fromFirestore(doc);
  }

  Stream<List<RoomListingModel>> fetchListings() {
    return _listingsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(RoomListingModel.fromFirestore).toList());
  }

  Future<void> addFavorite(String userId, String listingId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(listingId)
        .set({'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeFavorite(String userId, String listingId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(listingId)
        .delete();
  }

  Future<bool> isFavorite(String userId, String listingId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(listingId)
        .get();
    return doc.exists;
  }

  Stream<List<String>> watchFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toList());
  }
}
