// lib/features/clubs/data/club_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/club_member_model.dart';
import '../../../core/models/club_model.dart';

/// Handles CRUD operations for community clubs and their members.
class ClubRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createClub(ClubModel club) async {
    final docRef = await _firestore.collection('clubs').add(club.toJson());
    return docRef.id;
  }

  Future<void> updateClub(ClubModel club) async {
    await _firestore.collection('clubs').doc(club.id).update(club.toJson());
  }

  Future<void> deleteClub(String clubId) async {
    await _firestore.collection('clubs').doc(clubId).delete();
  }

  Future<ClubModel> fetchClub(String clubId) async {
    final doc = await _firestore.collection('clubs').doc(clubId).get();
    return ClubModel.fromFirestore(doc);
  }

  Stream<List<ClubModel>> fetchClubs() {
    return _firestore
        .collection('clubs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ClubModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addMember(String clubId, ClubMemberModel member) async {
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('members')
        .doc(member.id)
        .set(member.toJson());
  }

  Future<void> removeMember(String clubId, String memberId) async {
    await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('members')
        .doc(memberId)
        .delete();
  }

  Stream<List<ClubMemberModel>> fetchMembers(String clubId) {
    return _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('members')
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(ClubMemberModel.fromFirestore).toList());
  }
}
