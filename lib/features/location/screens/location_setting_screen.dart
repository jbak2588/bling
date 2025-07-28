// lib/features/location/screens/location_setting_screen.dart

import 'package:bling_app/api_keys.dart';
// import 'package:bling_app/features/main_screen/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: ApiKeys.googleApiKey);
  bool _isLoading = false;

  // [최종 해결 버전] DB를 기준으로 주소를 역추적하는 '상향식' 검증 함수
  Future<Map<String, String?>?> _buildCorrectLocationParts(
      List<AddressComponent> components) async {
    // 1. Google API에서 필요한 최소 정보(prov, kec, kel)를 추출합니다.
    String? provName;
    String? kecName;
    String? kelName;

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

    // 2. 필수 정보가 없으면 진행할 수 없으므로 null을 반환합니다.
    if (provName == null || kecName == null) {
      debugPrint("Provinsi 또는 Kecamatan 정보를 찾을 수 없습니다.");
      return null;
    }

    // [핵심 수정] kecName에서도 "Kecamatan " 접두사를 제거합니다.
    final cleanKecName = kecName.replaceFirst('Kecamatan ', '').trim();

    final provDocRef =
        FirebaseFirestore.instance.collection('provinces').doc(provName);

    // 3. 'kota' 컬렉션을 먼저 탐색합니다.
    final kotaSnapshot = await provDocRef.collection('kota').get();
    for (final kotaDoc in kotaSnapshot.docs) {
      final kecSnapshot = await kotaDoc.reference
          .collection('kecamatan')
          .doc(cleanKecName)
          .get();
      if (kecSnapshot.exists) {
        debugPrint(
            "DB 검증: Kota '${kotaDoc.id}'에서 Kecamatan '$cleanKecName'을 찾았습니다.");
        return {
          'prov': provName,
          'kota': kotaDoc.id,
          'kab': null,
          'kec': cleanKecName,
          'kel': kelName,
        };
      }
    }

    // 4. 'kota'에 없으면, 'kabupaten' 컬렉션을 탐색합니다.
    final kabSnapshot = await provDocRef.collection('kabupaten').get();
    for (final kabDoc in kabSnapshot.docs) {
      final kecSnapshot = await kabDoc.reference
          .collection('kecamatan')
          .doc(cleanKecName)
          .get();
      if (kecSnapshot.exists) {
        debugPrint(
            "DB 검증: Kabupaten '${kabDoc.id}'에서 Kecamatan '$cleanKecName'을 찾았습니다.");
        return {
          'prov': provName,
          'kota': null,
          'kab': kabDoc.id,
          'kec': cleanKecName,
          'kel': kelName,
        };
      }
    }

    // 5. 우리 DB 어디에서도 해당 Kecamatan을 찾지 못한 경우
    debugPrint("DB 오류: '$provName' 주에서 '$cleanKecName' Kecamatan을 찾을 수 없습니다.");
    return null;
  }

// 기존의 _createLocationParts 함수는 삭제합니다.

  // Firestore에 사용자 위치 정보를 생성 또는 업데이트하는 통합 함수
  Future<void> _updateUserLocation(String locationName,
      Map<String, String> locationParts, GeoPoint geoPoint) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // .set(..., merge: true)를 사용하여, 문서가 없으면 생성하고 있으면 필드를 업데이트합니다.
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'neighborhoodVerified': true,
    }, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('location.success'.tr())));
      Navigator.pop(context, {
        'locationName': locationName,
        'locationParts': locationParts,
        'geoPoint': geoPoint,
      });
    }
  }

  // 현재 GPS 위치로 주소 업데이트
  Future<void> _setNeighborhoodWithGPS() async {
    setState(() => _isLoading = true);

    try {
      // 1. 위치 서비스 활성화 여부 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('location.error'
                .tr(namedArgs: {'error': 'GPS service is disabled'}))));
        setState(() => _isLoading = false);
        return;
      }

      // 2. 위치 권한 요청
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('location.permissionDenied'.tr())));
        }
        openAppSettings();
        setState(() => _isLoading = false);
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // 3. 현재 위치 가져오기
        final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        // 4. 좌표를 주소로 변환
        final response = await _places.searchNearbyWithRadius(
            Location(lat: position.latitude, lng: position.longitude), 100,
            language: context.locale.languageCode);

        if (mounted && response.isOkay && response.results.isNotEmpty) {
          final place = response.results.first;
          final detailResult = await _places.getDetailsByPlaceId(place.placeId);

          if (mounted &&
              detailResult.isOkay &&
              detailResult.result.geometry != null) {
            final location = detailResult.result.geometry!.location;
            final components = detailResult.result.addressComponents;
            // final locationMap = _createLocationParts(components);

            // [핵심 수정] 새로운 DB 검증 함수를 호출하여 정확한 locationParts를 생성합니다.
            final Map<String, String?>? locationMap =
                await _buildCorrectLocationParts(components);

            // 만약 DB에서 정확한 주소를 찾지 못하면, 사용자에게 알리고 중단합니다.
            if (locationMap == null) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("정확한 주소를 찾을 수 없습니다. 다른 위치에서 시도해주세요.")));
              }
              setState(() => _isLoading = false);
              return;
            }

            // [핵심 수정] 검증된 locationMap을 기반으로 직접 fullAddress를 생성합니다.
            final addressParts = [
              locationMap['kel'],
              locationMap['kec'],
              locationMap['kab'] ??
                  locationMap['kota'], // kab이나 kota 중 null이 아닌 값 사용
              locationMap['prov'],
            ];
            // null이 아닌 주소 부분만 합쳐서 문자열로 만듭니다.
            final fullAddress = addressParts.where((p) => p != null).join(', ');

            final geoPoint = GeoPoint(location.lat, location.lng);

            // ✅ [수정] Map<String, String?>을 Map<String, String>으로 변환합니다.
            final filteredLocationMap = <String, String>{};
            locationMap.forEach((key, value) {
              if (value != null) {
                filteredLocationMap[key] = value;
              }
            });

            // ✅ [수정] 다시 _updateUserLocation 함수를 호출하도록 변경하여 코드 중복을 없애고 에러를 해결합니다.
            await _updateUserLocation(
                fullAddress, filteredLocationMap, geoPoint);
          }
        } else {
          throw Exception("Could not find address for current location.");
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('location.error'.tr(namedArgs: {'error': e.toString()}))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 검색어 입력 시 자동완성 목록을 가져오는 함수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('location.title'.tr())),
      body: Column(
        children: [
          Padding(
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
                    style: GoogleFonts.inter(
                        fontSize: 16, color: Colors.grey[700]),
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
        ],
      ),
    );
  }
}
