import 'package:bling_app/features/real_estate/models/room_listing_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoomListingModel', () {
    test('fromFirestore parses and toJson preserves new fields', () async {
      final createdAt = Timestamp.fromMillisecondsSinceEpoch(1735000000000);
      final moveInDate = Timestamp.fromMillisecondsSinceEpoch(1735086400000);

      final data = <String, dynamic>{
        'userId': 'user_1',
        'title': 'Bright 2BR near subway',
        'description': 'South-facing, renovated, quiet street',
        'type': 'kos',
        'locationName': 'Gangnam-gu, Seoul',
        'locationParts': {'city': 'Seoul', 'district': 'Gangnam-gu'},
        'geoPoint': const GeoPoint(37.4979, 127.0276),
        'price': 500000,
        'priceUnit': 'monthly',
        'imageUrls': ['https://img/1.jpg', 'https://img/2.jpg'],
        'amenities': ['wifi', 'ac', 'parking'],
        'createdAt': createdAt,
        'isAvailable': true,

        // New fields
        'listingType': 'rent',
        'publisherType': 'agent',
        'area': 42.5,
        'roomCount': 2,
        'bathroomCount': 1,
        'moveInDate': moveInDate,
        'isSponsored': true,
        'isVerified': true,
        'viewCount': 123,

        // Tags
        'tags': ['near-subway', 'pet-friendly'],
      };

      final firestore = FakeFirebaseFirestore();
      final docRef = firestore.collection('room_listings').doc('doc123');
      await docRef.set(data);
      final snap = await docRef.get();

      // fromFirestore
      final model = RoomListingModel.fromFirestore(snap);
      expect(model.id, 'doc123');
      expect(model.userId, data['userId']);
      expect(model.title, data['title']);
      expect(model.description, data['description']);
      expect(model.type, data['type']);
      expect(model.locationName, data['locationName']);
      expect(model.locationParts, data['locationParts']);
      expect(model.geoPoint, data['geoPoint']);
      expect(model.price, data['price']);
      expect(model.priceUnit, data['priceUnit']);
      expect(model.imageUrls, data['imageUrls']);
      expect(model.amenities, data['amenities']);
      expect(model.createdAt, createdAt);
      expect(model.isAvailable, true);

      // New fields
      expect(model.listingType, data['listingType']);
      expect(model.publisherType, data['publisherType']);
      expect(model.area, data['area']);
      expect(model.roomCount, data['roomCount']);
      expect(model.bathroomCount, data['bathroomCount']);
      expect(model.moveInDate, data['moveInDate']);
      expect(model.isSponsored, data['isSponsored']);
      expect(model.isVerified, data['isVerified']);
      expect(model.viewCount, data['viewCount']);

      // Tags
      expect(model.tags, data['tags']);

      // toJson
      final json = model.toJson();
      expect(json['userId'], data['userId']);
      expect(json['title'], data['title']);
      expect(json['description'], data['description']);
      expect(json['type'], data['type']);
      expect(json['locationName'], data['locationName']);
      expect(json['locationParts'], data['locationParts']);
      expect(json['geoPoint'], data['geoPoint']);
      expect(json['price'], data['price']);
      expect(json['priceUnit'], data['priceUnit']);
      expect(json['imageUrls'], data['imageUrls']);
      expect(json['amenities'], data['amenities']);
      expect(json['createdAt'], createdAt);
      expect(json['isAvailable'], true);

      expect(json['listingType'], data['listingType']);
      expect(json['publisherType'], data['publisherType']);
      expect(json['area'], data['area']);
      expect(json['roomCount'], data['roomCount']);
      expect(json['bathroomCount'], data['bathroomCount']);
      expect(json['moveInDate'], data['moveInDate']);
      expect(json['isSponsored'], data['isSponsored']);
      expect(json['isVerified'], data['isVerified']);
      expect(json['viewCount'], data['viewCount']);

      expect(json['tags'], data['tags']);
    });

    test(
        'fromFirestore provides backwards-compatible defaults when fields are missing',
        () async {
      // Intentionally minimal data to trigger defaults
      final data = <String, dynamic>{};

      final firestore = FakeFirebaseFirestore();
      final docRef = firestore.collection('room_listings').doc('doc_missing');
      await docRef.set(data);
      final snap = await docRef.get();

      final model = RoomListingModel.fromFirestore(snap);

      // Identification and basic fields
      expect(model.id, 'doc_missing');
      expect(model.userId, '');
      expect(model.title, '');
      expect(model.description, '');
      expect(model.type, 'kos');

      // Location-related (nullable)
      expect(model.locationName, isNull);
      expect(model.locationParts, isNull);
      expect(model.geoPoint, isNull);

      // Pricing defaults
      expect(model.price, 0);
      expect(model.priceUnit, 'monthly');

      // Media/Amenities defaults
      expect(model.imageUrls, isEmpty);
      expect(model.amenities, isEmpty);

      // Timestamps and availability
      expect(model.createdAt, isA<Timestamp>());
      expect(model.isAvailable, isTrue);

      // Newly added fields defaults
      expect(model.listingType, 'rent');
      expect(model.publisherType, 'individual');
      expect(model.area, 0.0);
      expect(model.roomCount, 1);
      expect(model.bathroomCount, 1);
      expect(model.moveInDate, isNull);
      expect(model.isSponsored, isFalse);
      expect(model.isVerified, isFalse);
      expect(model.viewCount, 0);

      // Tags default
      expect(model.tags, isEmpty);

      // toJson should include defaults (createdAt is whatever model carries)
      final json = model.toJson();
      expect(json['userId'], '');
      expect(json['title'], '');
      expect(json['description'], '');
      expect(json['type'], 'kos');
      expect(json['locationName'], isNull);
      expect(json['locationParts'], isNull);
      expect(json['geoPoint'], isNull);
      expect(json['price'], 0);
      expect(json['priceUnit'], 'monthly');
      expect(json['imageUrls'], isEmpty);
      expect(json['amenities'], isEmpty);
      expect(json['createdAt'], model.createdAt);
      expect(json['isAvailable'], isTrue);

      expect(json['listingType'], 'rent');
      expect(json['publisherType'], 'individual');
      expect(json['area'], 0.0);
      expect(json['roomCount'], 1);
      expect(json['bathroomCount'], 1);
      expect(json['moveInDate'], isNull);
      expect(json['isSponsored'], isFalse);
      expect(json['isVerified'], isFalse);
      expect(json['viewCount'], 0);

      expect(json['tags'], isEmpty);
    });
  });
}
