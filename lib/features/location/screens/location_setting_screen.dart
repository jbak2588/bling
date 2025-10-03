/// ============================================================================
/// Bling DocHeader
/// Module        : Location
/// File          : lib/features/location/screens/location_setting_screen.dart
/// Purpose       : Capture and verify user location via Google Places and Firestore.
/// User Impact   : Ensures features operate within correct Kelurahan and RT/RW.
/// Feature Links : lib/features/location/screens/location_filter_screen.dart; lib/features/location/screens/neighborhood_prompt_screen.dart
/// Data Model    : Writes to `users/{uid}.locationParts{prov,kota/kab,kec,kel,rt,rw}` and `geoPoint`; reads `provinces/{prov}/kota/{kota}/kecamatan`.
/// Location Scope: Requires Province→Kota/Kabupaten→Kecamatan→Kelurahan; RT/RW optional; fallback to Google reverse geocode.
/// Trust Policy  : Verified location boosts TrustLevel; privacy respected via `privacySettings`.
/// Monetization  : Location data enables localized ads and promotion targeting.
/// KPIs          : Key Performance Indicator (KPI) events `set_location`, `location_verified`.
/// Analytics     : Log permission grants and location updates.
/// I18N          : Keys `location.set` and related prompts in assets/lang/*.json.
/// Dependencies  : cloud_firestore, firebase_auth, flutter_google_maps_webservices, geolocator, permission_handler
/// Security/Auth : Requires authenticated user and Google API key; handle permission denial.
/// Edge Cases    : Missing admin levels, disabled GPS, or Firestore mismatch.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/Bling_Location_GeoQuery_Structure.md; docs/index/피드 관련 위치 검색 규칙과 예시.md; docs/team/teamD_GeoQuery_Location_Module_통합_작업문서.md
/// ============================================================================
library;
// 아래부터 실제 코드

import 'package:bling_app/api_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationSettingScreen extends StatefulWidget {
  const LocationSettingScreen({super.key});

  @override
  State<LocationSettingScreen> createState() => _LocationSettingScreenState();
}

class _LocationSettingScreenState extends State<LocationSettingScreen> {
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: ApiKeys.serverKey);
  bool _isLoading = false;

  // neighborhood_prompt_screen.dart의 최신 DB 검증 함수를 그대로 가져옵니다.
  Future<Map<String, String?>?> _buildCorrectLocationParts(
      List<AddressComponent> components) async {
    String? provName, kecName, kelName;
    for (var component in components) {
      final types = component.types;
      if (types.contains('administrative_area_level_1')) {
        provName = component.longName;
      } else if (types.contains('administrative_area_level_3') ||
          types.contains('locality') ||
          types.contains('sublocality_level_1')) {
        kecName = component.longName;
      } else if (types.contains('administrative_area_level_4') ||
          types.contains('sublocality_level_2')) {
        kelName = component.longName;
      }
    }

    if (provName == null || kecName == null) return null;
    final cleanKecName = kecName.replaceFirst('Kecamatan ', '').trim();
    final provDocRef =
        FirebaseFirestore.instance.collection('provinces').doc(provName);

    final kotaSnapshot = await provDocRef.collection('kota').get();
    for (final kotaDoc in kotaSnapshot.docs) {
      final kecSnapshot = await kotaDoc.reference
          .collection('kecamatan')
          .doc(cleanKecName)
          .get();
      if (kecSnapshot.exists) {
        return {
          'prov': provName,
          'kota': kotaDoc.id,
          'kab': null,
          'kec': cleanKecName,
          'kel': kelName
        };
      }
    }

    final kabSnapshot = await provDocRef.collection('kabupaten').get();
    for (final kabDoc in kabSnapshot.docs) {
      final kecSnapshot = await kabDoc.reference
          .collection('kecamatan')
          .doc(cleanKecName)
          .get();
      if (kecSnapshot.exists) {
        return {
          'prov': provName,
          'kota': null,
          'kab': kabDoc.id,
          'kec': cleanKecName,
          'kel': kelName
        };
      }
    }
    return null;
  }

  // GPS 위치를 설정하고, 그 결과를 이전 화면으로 돌려주는 함수
  Future<void> _setNeighborhoodWithGPS() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        throw Exception('GPS service is disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        openAppSettings();
        throw Exception('Location permissions are permanently denied');
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // ✅ DEBUG: 1. 기기에서 GPS 좌표를 제대로 받아왔는지 확인

      final response = await _places.searchNearbyWithRadius(
          Location(lat: position.latitude, lng: position.longitude), 100);

      if (mounted && response.isOkay && response.results.isNotEmpty) {
        final place = response.results.first;
        final detailResult = await _places.getDetailsByPlaceId(place.placeId);

        // ✅ DEBUG: 2. Google Places API의 응답 상태를 직접 확인

        if (mounted &&
            detailResult.isOkay &&
            detailResult.result.geometry != null) {
          final location = detailResult.result.geometry!.location;
          final components = detailResult.result.addressComponents;
          final locationMap = await _buildCorrectLocationParts(components);

          if (locationMap == null) {
            throw Exception("Could not verify address in DB.");
          }

          final addressParts = [
            locationMap['kel'],
            locationMap['kec'],
            locationMap['kab'] ?? locationMap['kota'],
            locationMap['prov']
          ];
          final fullAddress = addressParts.where((p) => p != null).join(', ');
          final geoPoint = GeoPoint(location.lat, location.lng);

          final filteredLocationMap = <String, String>{};
          locationMap.forEach((key, value) {
            if (value != null) filteredLocationMap[key] = value;
          });

          // ✅ DEBUG: 3. 최종적으로 생성된 데이터 확인

          // ✅✅✅ 핵심 수정: DB에 직접 저장하는 대신, 결과를 가지고 이전 화면으로 돌아갑니다. ✅✅✅
          if (mounted) {
            Navigator.pop(context, {
              'locationName': fullAddress,
              'locationParts': filteredLocationMap,
              'geoPoint': geoPoint,
            });
          }
        } else {
          throw Exception("Could not get place details.");
        }
      } else {
        throw Exception("Could not find address for current location.");
      }
    } catch (e) {
      if (mounted) {
        // ✅ DEBUG: 4. 에러 발생 시, 어떤 종류의 에러인지 확인
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('location.error'.tr(namedArgs: {'error': e.toString()}))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI는 neighborhood_prompt_screen.dart와 동일한 것을 사용합니다.
    return Scaffold(
      appBar: AppBar(title: Text('location.title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.location_on_rounded,
                size: 80, color: Color(0xFF00A66C)),
            const SizedBox(height: 24),
            Text('prompt.title'.tr(),
                style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text('prompt.subtitle'.tr(),
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isLoading ? null : _setNeighborhoodWithGPS,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF00A66C),
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('prompt.button'.tr(),
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
