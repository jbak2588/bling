/// ============================================================================
/// Bling DocHeader
/// Module        : Location
/// File          : lib/features/location/screens/neighborhood_prompt_screen.dart
/// Purpose       : 회원가입 후 또는 위치 정보가 없는 사용자에게 동네 설정을 유도합니다.
/// User Impact   : GPS 자동 설정 또는 수동 선택을 통해 정확한 동네 정보를 입력받습니다.
/// Feature Links : LocationFilterScreen (수동 선택), LocationHelper (GPS/주소 변환)
/// Data Model    : users/{uid} 업데이트 (locationParts, locationName, geoPoint, neighborhoodVerified)
/// Privacy Note : 사용자의 상세 주소(`locationParts['street']`)나 전체 `locationName`은 피드(목록/카드) 화면에서 사용자 동의 없이 표시하지 마세요. 피드에는 행정구역을 축약형(`kel.`, `kec.`, `kab.`, `prov.`)으로 간략 표기하세요.
/// ============================================================================
library;

import 'package:bling_app/core/utils/location_helper.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; // Placemark 직접 사용
import 'package:google_fonts/google_fonts.dart';

class NeighborhoodPromptScreen extends StatefulWidget {
  const NeighborhoodPromptScreen({super.key});

  @override
  State<NeighborhoodPromptScreen> createState() =>
      _NeighborhoodPromptScreenState();
}

class _NeighborhoodPromptScreenState extends State<NeighborhoodPromptScreen> {
  bool _isLoading = false;
  String? _statusMessage;

  // 1. GPS로 위치 가져오기 및 저장
  Future<void> _setNeighborhoodWithGPS() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'location.neighborhoodPrompt.gpsWaiting';
    });

    try {
      final position = await LocationHelper.getCurrentLocation();
      if (position == null) {
        throw Exception('location.neighborhoodPrompt.noLocation'.tr());
      }

      setState(() => _statusMessage = 'location.neighborhoodPrompt.geocoding');

      // Placemark 객체를 직접 가져와서 정밀 파싱
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception('location.neighborhoodPrompt.addressNotFound'.tr());
      }

      final place = placemarks.first;

      // 전체 주소 문자열 조합
      final String fullAddress = [
        place.street,
        place.subLocality,
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
        place.postalCode
      ].where((e) => e != null && e.isNotEmpty).join(', ');

      // 정교한 파싱 (LocationHelper.parsePlacemark 사용)
      // subLocality가 Kelurahan, locality가 Kecamatan, subAdminArea가 Kab/Kota
      Map<String, dynamic> parts = LocationHelper.parsePlacemark(place);

      // [추가] 만약 Kelurahan(subLocality)이 비어있다면,
      // locality(Kec) 정보라도 저장하고, street 정보를 parts에 포함

      setState(() => _statusMessage = 'location.neighborhoodPrompt.saving');

      await _saveLocationToUser(
        locationName: fullAddress,
        locationParts: parts,
        geoPoint: GeoPoint(position.latitude, position.longitude),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('location.neighborhoodPrompt.saved'.tr())),
        );
        // ✅ 화면 종료 (이전 화면으로 복귀)
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('location.neighborhoodPrompt.error'
                  .tr(namedArgs: {'error': e.toString()}))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = null;
        });
      }
    }
  }

  // 2. 수동 선택 화면 열기
  Future<void> _openManualSelection() async {
    // LocationFilterScreen에서 결과를 받아옵니다.
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LocationFilterScreen()),
    );

    // 결과가 Map 형태(행정구역 필터)로 돌아왔다면 저장 로직 수행
    if (result != null && result is Map<String, String?> && mounted) {
      // 필수 값(최소 Kab/Kota) 확인
      if (result['kab'] == null && result['kota'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('location.neighborhoodPrompt.selectAtLeastCity'.tr())),
        );
        return;
      }

      setState(() {
        _isLoading = true;
        _statusMessage = 'location.neighborhoodPrompt.manualSaving';
      });

      try {
        // 수동 선택이므로 좌표는 기본적으로 없음 — 가능하면 주소->좌표(지오코딩) 시도
        // 주소 문자열 조합 (예: Kelurahan A, Kecamatan B, Kabupaten C, Provinsi D)
        String locName = [
          result['prov'],
          result['kab'],
          result['kec'],
          result['kel']
        ].where((e) => e != null).join(', ');

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception(
              'location.neighborhoodPrompt.userNotAuthenticated'.tr());
        }

        // Firestore 업데이트
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        // [Fix] 수동 선택 시에도 geoPoint 저장을 위한 지오코딩(주소->좌표) 로직 추가
        GeoPoint? newGeoPoint;
        try {
          // 주소 문자열 조합 (예: Kelurahan A, Kecamatan B, Kabupaten C, Provinsi D)
          // 검색 정확도를 위해 하위 행정구역부터 상위 순으로 조합
          List<String> addressComponents = [];
          if (result['kel'] != null && result['kel']!.isNotEmpty) {
            addressComponents.add("Kelurahan ${result['kel']}");
          }
          if (result['kec'] != null && result['kec']!.isNotEmpty) {
            addressComponents.add("Kecamatan ${result['kec']}");
          }
          if (result['kab'] != null && result['kab']!.isNotEmpty) {
            addressComponents.add(result['kab']!);
          }
          if (result['prov'] != null && result['prov']!.isNotEmpty) {
            addressComponents.add(result['prov']!);
          }

          if (addressComponents.isNotEmpty) {
            final String fullAddress = addressComponents.join(", ");
            // geocoding 패키지를 이용해 좌표 변환
            List<Location> locations = await locationFromAddress(fullAddress);
            if (locations.isNotEmpty) {
              newGeoPoint =
                  GeoPoint(locations.first.latitude, locations.first.longitude);
            }
          }
        } catch (e) {
          debugPrint("Manual geocoding failed: $e");
          // 실패 시 geoPoint는 null 또는 기존 값 유지 (여기서는 업데이트 맵에 포함 안 함)
        }

        final Map<String, dynamic> updateData = {
          'locationParts': result,
          'locationName': locName,
          'neighborhoodVerified': true, // 수동 선택도 인증된 것으로 처리 (정책에 따라 false 가능)
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (newGeoPoint != null) {
          updateData['geoPoint'] = newGeoPoint;
        }

        await userRef.update(updateData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('location.neighborhoodPrompt.saved'.tr())),
          );
          // ✅ 화면 종료
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('location.neighborhoodPrompt.saveFailed'
                    .tr(namedArgs: {'error': e.toString()}))),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // 3. Firestore 저장 공통 로직
  Future<void> _saveLocationToUser({
    required String locationName,
    required Map<String, dynamic> locationParts,
    GeoPoint? geoPoint,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'locationName': locationName,
      'locationParts': locationParts,
      'geoPoint': geoPoint,
      'neighborhoodVerified': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ 뒤로가기 버튼 (수동 진입 시 탈출구)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? const BackButton(color: Colors.black)
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 80, color: Color(0xFF00A66C)),
              const SizedBox(height: 24),
              Text(
                'location.neighborhoodPrompt.title'.tr(),
                style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'location.neighborhoodPrompt.subtitle'.tr(),
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (_isLoading)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                        _statusMessage != null
                            ? _statusMessage!.tr()
                            : 'location.neighborhoodPrompt.processing'.tr(),
                        style: const TextStyle(color: Colors.grey)),
                  ],
                )
              else ...[
                ElevatedButton.icon(
                  onPressed: _setNeighborhoodWithGPS,
                  icon: const Icon(Icons.my_location),
                  label: Text(
                      'location.neighborhoodPrompt.currentLocationButton'.tr()),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF00A66C),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _openManualSelection,
                  icon: const Icon(Icons.list),
                  label: Text(
                      'location.neighborhoodPrompt.manualSelectButton'.tr()),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
