// lib/core/services/location_search_service.dart
/* 
  LocationSearchService
  - Google Places API 및 Geocoding API를 사용하여 주소 자동완성, 장소 상세 조회, 역지오코딩 기능을 제공합니다.
  - BlingLocation 모델을 사용하여 위치 정보를 표준화합니다.
2. 공용 서비스: Google Places / Geocoding

파일 경로: lib/core/services/location_search_service.dart

Google Places Autocomplete + Place Details + Reverse Geocoding 을 담당하는 서비스입니다.
lib/api_keys.dart 안에  ApiKeys.serverKey; 같은 변수가 있다고 가정하고 사용합니다.
  주요 기능:
*/



import 'dart:convert';

import 'package:bling_app/api_keys.dart'; // ApiKeys.serverKey 사용
import 'package:bling_app/core/models/bling_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

/// 주소 자동완성 후보 한 줄
class LocationSuggestion {
  final String description;
  final String placeId;

  const LocationSuggestion({
    required this.description,
    required this.placeId,
  });
}

/// Google Places / Geocoding API 연동 서비스.
/// - 앱 전역에서 이 서비스만 사용하도록 규칙 통일하는 게 포인트입니다.
class LocationSearchService {
  LocationSearchService({
    String? apiKeyOverride,
    this.countryFilter = 'id', // 인도네시아 중심. 필요하면 null 로 열 수 있음.
  }) : apiKey = apiKeyOverride ?? ApiKeys.serverKey;

  final String apiKey;
  final String? countryFilter;

  /// 주소 문자열을 입력하면 Google Places Autocomplete 결과를 돌려줍니다.
  Future<List<LocationSuggestion>> autocomplete({
    required String input,
    String? languageCode,
    String? sessionToken,
  }) async {
    if (input.trim().isEmpty) return [];

    final params = <String, String>{
      'input': input,
      'key': apiKey,
      'language': languageCode ?? 'en',
    };

    if (countryFilter != null) {
      // 인도네시아만: components=country:id
      params['components'] = 'country:$countryFilter';
    }

    if (sessionToken != null) {
      params['sessiontoken'] = sessionToken;
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      params,
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Places Autocomplete HTTP ${resp.statusCode}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'UNKNOWN_ERROR';

    if (status != 'OK' && status != 'ZERO_RESULTS') {
      // OVER_QUERY_LIMIT, REQUEST_DENIED 등
      throw Exception('Places Autocomplete error: $status');
    }

    final predictions = data['predictions'] as List<dynamic>? ?? [];
    return predictions
        .map((item) {
          final map = item as Map<String, dynamic>;
          return LocationSuggestion(
            description: map['description'] as String? ?? '',
            placeId: map['place_id'] as String? ?? '',
          );
        })
        .where((s) => s.placeId.isNotEmpty && s.description.isNotEmpty)
        .toList();
  }

  /// placeId 기준으로 좌표 + formatted_address 를 조회합니다.
  Future<BlingLocation> getLocationFromPlaceId({
    required String placeId,
    String? languageCode,
    String? sessionToken,
  }) async {
    final params = <String, String>{
      'place_id': placeId,
      'key': apiKey,
      'fields': 'formatted_address,geometry/location,place_id',
      'language': languageCode ?? 'en',
    };

    if (sessionToken != null) {
      params['sessiontoken'] = sessionToken;
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      params,
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Place Details HTTP ${resp.statusCode}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'UNKNOWN_ERROR';
    if (status != 'OK') {
      throw Exception('Place Details error: $status');
    }

    final result = data['result'] as Map<String, dynamic>? ?? {};
    final geometry = result['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};

    final lat = (location['lat'] as num?)?.toDouble();
    final lng = (location['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) {
      throw Exception('Place Details missing location');
    }

    final formattedAddress = result['formatted_address'] as String? ?? '';

    return BlingLocation(
      geoPoint: GeoPoint(lat, lng),
      mainAddress: formattedAddress,
      placeId: result['place_id'] as String? ?? placeId,
    );
  }

  /// 좌표 → 사람이 읽는 주소 (Reverse Geocoding)
  Future<BlingLocation> reverseGeocode({
    required double latitude,
    required double longitude,
    String? languageCode,
  }) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/geocode/json',
      <String, String>{
        'latlng': '$latitude,$longitude',
        'key': apiKey,
        'language': languageCode ?? 'en',
      },
    );

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Reverse geocode HTTP ${resp.statusCode}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'UNKNOWN_ERROR';

    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw Exception('Reverse geocode error: $status');
    }

    final results = data['results'] as List<dynamic>? ?? [];
    final first =
        results.isNotEmpty ? results.first as Map<String, dynamic> : {};

    final formattedAddress = first['formatted_address'] as String? ?? '';
    return BlingLocation(
      geoPoint: GeoPoint(latitude, longitude),
      mainAddress: formattedAddress,
      // reverse geocode 에서는 placeId 없을 수도 있음
      placeId: (first['place_id'] as String?),
    );
  }
}
