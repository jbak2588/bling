// lib/core/models/bling_location.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Bling 전역에서 사용하는 표준 위치 모델.
/// - geoPoint      : Firestore용 위/경도
/// - mainAddress   : Google formatted_address 등, 사람이 읽는 전체 주소
/// - placeId       : Google Place ID (선택)
/// - shortLabel    : 사용자가 적는 짧은 라벨 (예: "SMS 스타벅스 앞")
class BlingLocation {
  final GeoPoint geoPoint;
  final String mainAddress;
  final String? placeId;
  final String? shortLabel;

  const BlingLocation({
    required this.geoPoint,
    required this.mainAddress,
    this.placeId,
    this.shortLabel,
  });

  BlingLocation copyWith({
    GeoPoint? geoPoint,
    String? mainAddress,
    String? placeId,
    String? shortLabel,
  }) {
    return BlingLocation(
      geoPoint: geoPoint ?? this.geoPoint,
      mainAddress: mainAddress ?? this.mainAddress,
      placeId: placeId ?? this.placeId,
      shortLabel: shortLabel ?? this.shortLabel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geoPoint': geoPoint,
      'mainAddress': mainAddress,
      if (placeId != null) 'placeId': placeId,
      if (shortLabel != null) 'shortLabel': shortLabel,
    };
  }

  factory BlingLocation.fromJson(Map<String, dynamic> json) {
    final geo = json['geoPoint'];
    if (geo is! GeoPoint) {
      throw ArgumentError('geoPoint must be a GeoPoint');
    }

    return BlingLocation(
      geoPoint: geo,
      mainAddress: json['mainAddress'] as String? ?? '',
      placeId: json['placeId'] as String?,
      shortLabel: json['shortLabel'] as String?,
    );
  }
}
