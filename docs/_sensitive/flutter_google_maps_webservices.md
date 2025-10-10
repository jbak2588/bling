/// ============================================================================
/// Bling DocHeader
/// Module        : Location
/// File          : lib/features/location/screens/neighborhood_prompt_screen.dart
/// Purpose       : Google Places를 통해 사용자의 동네를 검증하고 Firestore를 갱신합니다.
/// User Impact   : 정확한 RT/RW 소속이 초근접 기능을 활성화합니다.
/// Feature Links : lib/features/location/screens/location_setting_screen.dart
/// Data Model    : Firestore `users` 필드 `locationName`, `locationParts`, `geoPoint`, `neighborhoodVerified`; `provinces/{prov}/kota`와 `kabupaten`을 조회합니다.
/// Location Scope: Prov→Kota/Kabupaten→Kecamatan→Kelurahan을 검증하며 마지막 기기 GPS를 기본값으로 사용합니다.
/// Trust Policy  : 검증 성공 시 `trustScore`가 상승하고 실패 시 기능이 제한됩니다.
/// Monetization  : 검증된 위치는 지역 광고와 마켓플레이스 노출을 가능하게 합니다.
/// KPIs          : 핵심성과지표(Key Performance Indicator, KPI) 이벤트 `complete_location_verification`.
/// Analytics     : Google API 호출과 검증 결과를 기록합니다.
/// I18N          : 키 `location.success`, `location.error` (assets/lang/*.json)
/// Dependencies  : firebase_auth, cloud_firestore, google_places, geolocator, permission_handler, easy_localization
/// Security/Auth : 로그인된 사용자가 필요하며 API 키는 `ApiKeys.googleApiKey`에 있습니다.
/// Edge Cases    : GPS 거부 또는 DB에서 행정 계층을 찾지 못하는 경우.
/// Changelog     : 2025-08-26 DocHeader 최초 삽입(자동)
/// Source Docs   : docs/index/5 지역-위치-개인정보.md; docs/Bling_Location_GeoQuery_Structure.md; docs/team/teamD_GeoQuery_Location_Module_통합_작업문서.md
/// ============================================================================
/// [기획의도 요약]
/// - 동네 인증을 통해 사용자의 정확한 위치를 검증하고, 신뢰등급(TrustScore) 및 지역 기반 서비스(광고, 마켓플레이스 등)를 활성화한다.
/// - KPI, Analytics, 보안, I18N 등 다양한 정책을 반영한다.
/// [실제 구현 기능]
/// - Google Places API와 Firestore DB를 연동하여, GPS 기반 위치 검증 및 DB 행정구역 매칭을 수행.
/// - 검증된 위치 정보는 Firestore에 저장되고, UI에서 인증 성공/실패 메시지 및 권한 안내를 제공.
/// - 위치 인증 실패 시 사용자에게 안내 및 재시도 기능 제공.
/// [기획의도와 실제 기능의 차이점]
/// - 기획의도보다 좋아진 점: DB 행정구역 검증 로직이 추가되어, 실제 위치와 DB의 일치도를 높임. 인증 실패 시 사용자 경험 개선(재시도, 안내).
/// - 기획의도에 못 미친 점: KPI/Analytics/수익화(광고 노출, 마켓플레이스 연계) 기능은 코드상에서 일부만 구현되어 있음. UI/UX 세부 안내 및 다국어 메시지 다양성은 추가 개선 필요.
/// [UI/UX 기능개선 제안]
/// - 인증 실패/성공 시 더 다양한 피드백(애니메이션, 상세 안내, 위치 재설정 옵션 등) 제공
/// - 위치 인증 과정에서 지도 시각화 및 선택 UI 추가
/// [수익화 제안]
/// - 인증된 위치 기반으로 지역 광고, 마켓플레이스 추천, 프로모션 배너 노출 기능 연계
/// [코드 안정성 및 실행 속도 개선 제안]
/// - 위치 권한/서비스 체크 로직을 별도 함수로 분리하여 재사용성 및 유지보수성 강화
/// - Firestore/Google API 호출 시 에러 핸들링 및 로딩 상태 관리 강화
/// - 인증 성공/실패 이벤트를 별도 로깅하여 KPI/Analytics 연동 강화
library;
// 아래부터 실제 코드

import 'package:bling_app/api_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class NeighborhoodPromptScreen extends StatefulWidget {
  const NeighborhoodPromptScreen({super.key});

  @override
  State<NeighborhoodPromptScreen> createState() =>
      _NeighborhoodPromptScreenState();
}

class _NeighborhoodPromptScreenState extends State<NeighborhoodPromptScreen> {
  bool _isLoading = false;
  final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: ApiKeys.googleApiKey);

  // ✅ DB 검증 로직을 더욱 강화하여 이름 불일치 문제를 해결합니다.
  Future<Map<String, String?>?> _buildCorrectLocationParts(
      List<AddressComponent> components) async {
    String? provName, kecName, kelName;
    for (var component in components) {
      final types = component.types;
      if (types.contains('administrative_area_level_1')) {
        provName = component.longName;
      // ignore: curly_braces_in_flow_control_structures
      } else if (types.contains('administrative_area_level_3') || types.contains('locality') || types.contains('sublocality_level_1')) kecName = component.longName;
      // ignore: curly_braces_in_flow_control_structures
      else if (types.contains('administrative_area_level_4') || types.contains('sublocality_level_2')) kelName = component.longName;
    }

    if (provName == null || kecName == null) return null;
    
    // Google API가 주는 이름에서 'Kecamatan ' 접두사를 제거하여 DB와 비교할 준비를 합니다.
    final cleanKecName = kecName.replaceFirst('Kecamatan ', '').trim();
    final provDocRef = FirebaseFirestore.instance.collection('provinces').doc(provName);

    // 1. 'kota' 컬렉션 탐색
    final kotaSnapshot = await provDocRef.collection('kota').get();
    for (final kotaDoc in kotaSnapshot.docs) {
      final kecSnapshot = await kotaDoc.reference.collection('kecamatan').doc(cleanKecName).get();
      if (kecSnapshot.exists) {
        return {'prov': provName, 'kota': kotaDoc.id, 'kab': null, 'kec': cleanKecName, 'kel': kelName};
      }
    }

    // 2. 'kabupaten' 컬렉션 탐색
    final kabSnapshot = await provDocRef.collection('kabupaten').get();
    for (final kabDoc in kabSnapshot.docs) {
      final kecSnapshot = await kabDoc.reference.collection('kecamatan').doc(cleanKecName).get();
      if (kecSnapshot.exists) {
        return {'prov': provName, 'kota': null, 'kab': kabDoc.id, 'kec': cleanKecName, 'kel': kelName};
      }
    }

    // 3. 만약 위에서 못 찾으면, Google API가 준 주소에 'Kota'나 'Kabupaten'이 생략되었을 가능성을 대비해
    //    DB의 모든 kota/kabupaten을 순회하며 하위 kecamatan을 다시 한번 찾습니다.
    for (final kotaDoc in kotaSnapshot.docs) {
        final kecSubSnapshot = await kotaDoc.reference.collection('kecamatan').where('name', isEqualTo: cleanKecName).limit(1).get();
        if (kecSubSnapshot.docs.isNotEmpty) {
            return {'prov': provName, 'kota': kotaDoc.id, 'kab': null, 'kec': kecSubSnapshot.docs.first.id, 'kel': kelName};
        }
    }
    for (final kabDoc in kabSnapshot.docs) {
        final kecSubSnapshot = await kabDoc.reference.collection('kecamatan').where('name', isEqualTo: cleanKecName).limit(1).get();
        if (kecSubSnapshot.docs.isNotEmpty) {
            return {'prov': provName, 'kota': null, 'kab': kabDoc.id, 'kec': kecSubSnapshot.docs.first.id, 'kel': kelName};
        }
    }

    return null; // 최종적으로 DB에서 일치하는 주소를 찾지 못함
  }

   // ✅✅✅ 아래 누락된 함수를 여기에 추가해주세요 ✅✅✅
  Future<String?> _showKelurahanSelectionDialog(BuildContext context, List<String> kelurahanList) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false, // 사용자가 반드시 선택하도록 강제
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('location.selectKelurahan'.tr()),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: kelurahanList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(kelurahanList[index]),
                  onTap: () {
                    Navigator.pop(context, kelurahanList[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }


  // [핵심 추가] Firestore에 사용자 위치 정보를 저장하는 함수가 누락되어 있었습니다.
  Future<void> _updateUserLocation(String locationName,
      Map<String, String> locationParts, GeoPoint geoPoint) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'neighborhoodVerified': true,
    }, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('location.success'.tr())));
    }
  }

  // 버튼 클릭 시, GPS 위치를 가져와 DB에 저장하는 모든 로직을 이 함수 하나에서 처리
   Future<void> _setNeighborhoodWithGPS() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) throw Exception('GPS service is disabled');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        openAppSettings();
        throw Exception('Location permissions are permanently denied');
      }
      if (permission == LocationPermission.denied) throw Exception('Location permissions are denied');

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final response = await _places.searchNearbyWithRadius(Location(lat: position.latitude, lng: position.longitude), 100);
      
      if (mounted && response.isOkay && response.results.isNotEmpty) {
        final place = response.results.first;
        final detailResult = await _places.getDetailsByPlaceId(place.placeId);

        if (mounted && detailResult.isOkay && detailResult.result.geometry != null) {
          final location = detailResult.result.geometry!.location;
          final components = detailResult.result.addressComponents;
          final Map<String, String?>? locationMap = await _buildCorrectLocationParts(components);

          if (locationMap == null) throw Exception("Could not verify address in DB.");

          final prov = locationMap['prov'];
          final kab = locationMap['kab'];
          final kota = locationMap['kota'];
          final kec = locationMap['kec'];

          if (prov != null && (kab != null || kota != null) && kec != null) {
            final parentRef = FirebaseFirestore.instance.collection('provinces').doc(prov);
            final kecRef = (kab != null)
                ? parentRef.collection('kabupaten').doc(kab).collection('kecamatan').doc(kec)
                : parentRef.collection('kota').doc(kota!).collection('kecamatan').doc(kec);
            
            // ✅ JS 코드에 맞춰 'kelurahan' 컬렉션을 조회합니다.
            final kelurahanSnapshot = await kecRef.collection('kelurahan').get();
            final kelurahanList = kelurahanSnapshot.docs.map((doc) => doc.id).toList();

            if (mounted && kelurahanList.isNotEmpty) {
              final selectedKelurahan = await _showKelurahanSelectionDialog(context, kelurahanList);
              if (selectedKelurahan != null) {
                locationMap['kel'] = selectedKelurahan;
              } else {
                 // 사용자가 선택하지 않고 팝업을 닫은 경우, 저장을 중단합니다.
                 setState(() => _isLoading = false);
                 return;
              }
            } 
            else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('location.noKelurahanFound'.tr()))
              );
            }
          }

          final addressParts = [locationMap['kel'], locationMap['kec'], locationMap['kab'] ?? locationMap['kota'], locationMap['prov']];
          final fullAddress = addressParts.where((p) => p != null).join(', ');
          final geoPoint = GeoPoint(location.lat, location.lng);

          final filteredLocationMap = <String, String>{};
          locationMap.forEach((key, value) {
            if (value != null) filteredLocationMap[key] = value;
          });

          // ✅ 모든 정보가 완성된 후, Firestore에 저장하는 함수를 호출합니다.
          await _updateUserLocation(fullAddress, filteredLocationMap, geoPoint);
        } else { throw Exception("Could not get place details."); }
      } else { throw Exception("Could not find address for current location."); }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('location.error'.tr(namedArgs: {'error': e.toString()}))));
      }
    } 
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // const Icon(Icons.my_location, size: 80, color: Color(0xFF00A66C)),
              const Icon(Icons.location_on_rounded,
                  size: 80, color: Color(0xFF00A66C)),

              const SizedBox(height: 24),
              Text('prompt.title'.tr(),
                  style: GoogleFonts.inter(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text('prompt.subtitle'.tr(),
                  style:
                      GoogleFonts.inter(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isLoading ? null : _setNeighborhoodWithGPS,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFFF6B00),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('prompt.button'.tr(),
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: Text('drawer.logout'.tr(),
                    style: TextStyle(color: Colors.grey[600])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
